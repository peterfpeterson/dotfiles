#!/usr/bin/env python
from __future__ import (absolute_import, division, print_function, unicode_literals)
import os
import requests
import time

INSTRUMENTS = ['ARCS', 'BSS', 'CNCS', 'CORELLI', 'EQSANS', 'HYS', 'MANDI', 'NOM', 'PG3',
               'REF_L', 'REF_M', 'SEQ', 'SNAP', 'TOPAZ', 'USANS', 'VIS', 'VULCAN']
LEGACY_DAS = ['ARCS', 'BSS', 'TOPAZ']
STATUS = {'incomplete':'incmp',
          'complete':  'compl',
          'error':     'error'}

URL_BASE = 'https://monitor.sns.gov/'
URL = URL_BASE + 'dasmon/{0}/runs/'

def getJson(url, timeout, params):
    '''anything other than a 200 generates an exception'''
    req = requests.get(url, params=params, timeout=timeout) # seconds
    status_code = req.status_code

    if status_code != requests.codes.ALL_OK:
        status_name = requests.status_codes._codes[status_code][0] # first is common name
        raise RuntimeError('Encountered status [{0}] {1}'.format(status_code, status_name))

    # test that it is not a login
    if 'login' in req.url:
        raise RuntimeError('Appears to be login page. URL: {0}'.format(req.url))

    try:
        json_doc = req.json()
    except TypeError:
        json_doc = req.json

    return json_doc

def getRunList(instrument, timeout):
    return getJson(URL.format(instrument), timeout, params={'format':'json'})

class Reporter(object):
    def __init__(self, instrument, fullWidth, withHeader, timeout):
        self.instrument = instrument
        self.fullWidth = fullWidth
        self.withHeader = withHeader
        self.timeout = timeout
        self.update()

    def update(self):
        json_doc = getRunList(self.instrument, self.timeout)

        # get the header information together
        proposal = json_doc.get('proposal_id', '')
        title = json_doc.get('run_title', '').strip()
        recording_status = json_doc.get('recording_status', '')
        count_rate = '{0:.0f} counts/sec'.format(float(json_doc.get('count_rate', 0.)))

        # put together all off the run information
        runs = json_doc['runs']
        run_list = {}
        for status in runs:
            runid = '{0}_{1}'.format(self.instrument.upper(), status['run'])
            timestamp = status['timestamp'].split()
            timestamp = '{0} {1}'.format(timestamp[0], timestamp[3])
            run_list[runid] = {'timestamp':timestamp,
                               'status':STATUS.get(status['status'], status['status'])}
        runs = list(run_list.keys())
        runs.sort()


        # put together list of runs
        self.lines = []
        for runid in runs[::-1]:
            info = run_list[runid]
            info = '{}  {}  {}'.format(runid, info['timestamp'], info['status'])
            self.lines.append(info)

        self.width = len(self.lines[0])

        # put together header
        if self.withHeader:
            fullWidth = min(self.fullWidth, self.width)
            propline = '{:<} {:>' + str(self.width-len(self.instrument)-1) + '}'
            self.lines.insert(0, propline.format(self.instrument.upper(), proposal))
            rateline = '{:<} {:>' + str(self.width-len(recording_status)-1) + '}'
            self.lines.insert(1, rateline.format(recording_status, count_rate))
            if len(title) > fullWidth: # trim the title to width
                title = title[:fullWidth-1]
            titleline = '{:^' + str(self.width) + '}'
            self.lines.insert(2, titleline.format(title))

        self.numlines = len(self.lines)

    def line(self, index):
        if index >= self.numlines:
            return ' '*self.width
        else:
            return self.lines[index]

if __name__ == '__main__':
    try:
        # python3 has a method built in
        term_size = os.get_terminal_size()
        def_columns = term_size.columns
        def_lines = term_size.lines
    except AttributeError:
        # default terminal size is often 80x24
        def_columns = 80
        def_lines = 24

    import argparse     # for command line options
    import argcomplete  # for bash completion
    parser = argparse.ArgumentParser(description="Print current status of autoreduction")
    allowed_instruments = [instr.lower() for instr in INSTRUMENTS]
    allowed_instruments.extend(INSTRUMENTS)
    parser.add_argument('instruments', nargs='+', choices=allowed_instruments,
                         help='Specify the instruments')
    parser.add_argument('--width', type=int, default=def_columns,
                        help='Width of terminal (default=%(default)s)')
    parser.add_argument('--height', type=int, default=def_lines,
                        help='Height of terminal (default=%(default)s)')
    parser.add_argument('--refresh', type=int, default=60, metavar='SECONDS',
                        help='Refresh rate (default=%(default)s)')
    parser.add_argument('--timeout', type=int, default=5, metavar='SECONDS',
                        help='Timeout of requests (default=%(default)s)')


    # set up bash completion
    argcomplete.autocomplete(parser)
    # parse the command line
    options = parser.parse_args()
    options.instruments = [instr.upper() for instr in options.instruments]
    numinstr = len(options.instruments)

    # get all of the reporters
    reporters = [Reporter(instr, fullWidth=(options.width // numinstr),
                          withHeader=(instr not in LEGACY_DAS), timeout=options.timeout)
                 for instr in options.instruments]

    # create the format string
    # determine width for space between columns
    width = options.width
    for reporter in reporters:
        width -= reporter.width
    width -= (len(reporters) - 1)
    if width < 0:
        parser.error('Terminal width ({}) is too small by {} characters'.format(options.width,
                                                                                    -1*width))
    if numinstr > 1:
        width = width // (numinstr-1)
    lineformat = ['{{}}' for reporter in reporters]

    lineformat = ('{:^' + str(width)+ '}').join(lineformat)
    bars = tuple(['|' for reporter in reporters])
    lineformat = lineformat.format(*bars)

    starttime=time.time()
    while True:
        for reporter in reporters:
            reporter.update()

        # find the maximum number of lines for the reporters, but limit to height
        numlines = min(options.height, max([reporter.numlines for reporter in reporters]))

        # put together final version
        for index in range(options.height):
            args = []
            for reporter in reporters:
                args.append(reporter.line(index))
            print(lineformat.format(*tuple(args)))

        # sleep for the prescribed time
        time.sleep(options.refresh - ((time.time() - starttime) % options.refresh))
