#!/usr/bin/env python
# -*- coding: utf-8 -*-

# This script is a simple wrapper which prefixes each i3status line with custom
# information. It is a python reimplementation of:
# http://code.stapelberg.de/git/i3status/tree/contrib/wrapper.pl
#
# To use it, ensure your ~/.i3status.conf contains this line:
#     output_format = "i3bar"
# in the 'general' section.
# Then, in your ~/.i3/config, use:
#     status_command i3status | ~/i3status/contrib/wrapper.py
# In the 'bar' section.
#
# In its current version it will display the cpu frequency governor, but you
# are free to change it to display whatever you like, see the comment in the
# source code below.
#
# © 2012 Valentin Haenel <valentin.haenel@gmx.de>
#
# This program is free software. It comes without any warranty, to the extent
# permitted by applicable law. You can redistribute it and/or modify it under
# the terms of the Do What The Fuck You Want To Public License (WTFPL), Version
# 2, as published by Sam Hocevar. See http://sam.zoy.org/wtfpl/COPYING for more
# details.

import json
import os
import sys
sys.path.insert(0, os.path.join(os.environ['HOME'],'bin'))
from beamstatus import getPower
from monitorautoreduction import getRunList

GREEN  = '#00CC00'
YELLOW = '#CCCC00'
RED    = '#CC0000'

def getBeamstatus(facility):
    if facility == 'HFIR':
        formatstr = '{} {:>5}'
    else:
        formatstr = '{} {:>6}'
    try:
        text = getPower(facility, False)
        color = None
        if text.lower().strip() == 'off':
            color = RED
        text = formatstr.format(facility, text)
    except: # any error
        return createRecord(facility, facility + '_ERROR', RED)

    return createRecord(facility, text, color)


def getLastRun(instrument):
    instrument = instrument.upper()
    try:
        record = getRunList(instrument, 2)
        rec_status = record['recording_status']
        runinfo = record['runs']
        # select the correct run to display
        if rec_status.lower() == 'recording' and len(runinfo) > 1:
            runinfo = runinfo[1]
        else:
            runinfo = runinfo[0]

        text = '{}_{} {}'.format(instrument, runinfo['run'], rec_status[0])
        status = str(runinfo['status']).lower()
    except:  # any error
        return createRecord(instrument, instrument + ' ERROR', RED)

    color = None
    if status == 'incomplete':
        color = YELLOW
    elif status == 'error':
        color = RED
    elif status == 'complete':
        color = GREEN

    return createRecord(instrument, text, color)

def createRecord(name, fulltext, color=None):
    result = {'full_text' : fulltext,
              'name': name}
    if color is not None:
        result['color'] = color
    return result

def print_line(message):
    """ Non-buffered printing to stdout. """
    sys.stdout.write(message + '\n')
    sys.stdout.flush()

def read_line():
    """ Interrupted respecting reader for stdin. """
    # try reading a line, removing any extra whitespace
    try:
        line = sys.stdin.readline().strip()
        # i3status sends EOF, or an empty line
        if not line:
            sys.exit(3)
        return line
    # exit on ctrl-c
    except KeyboardInterrupt:
        sys.exit()

if __name__ == '__main__':
    # Skip the first line which contains the version header.
    print_line(read_line())

    # The second line contains the start of the infinite array.
    print_line(read_line())

    while True:
        line, prefix = read_line(), ''
        # ignore comma at start of lines
        if line.startswith(','):
            line, prefix = line[1:], ','

        j = json.loads(line)
        # insert information into the start of the json, but could be anywhere
        for name in 'HFIR', 'SNS':
            j.insert(0, getBeamstatus(name))
        for name in 'SNAP', 'PG3', 'NOM':
            j.insert(0, getLastRun(name))

        # and echo back new encoded json
        print_line(prefix+json.dumps(j))
