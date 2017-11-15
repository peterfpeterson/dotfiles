#!/usr/bin/env python
from __future__ import (absolute_import, division, print_function, unicode_literals)
import requests

instrument = "nom"

URL_BASE = 'https://monitor.sns.gov/'
URL = URL_BASE + 'dasmon/{0}/runs/'

def getJson(url, params):
    '''anything other than a 200 generates an exception'''
    req = requests.get(url, params, timeout=1) # seconds
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

def getRunList(instrument):
    return getJson(URL.format(instrument), params={'format':'json'})

json_doc = getRunList(instrument)
print(json_doc)
