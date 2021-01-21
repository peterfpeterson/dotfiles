#!/usr/bin/env python
from __future__ import (absolute_import, division, print_function, unicode_literals)
import json
import requests
import sys

BASE_URL = 'http://builds.mantidproject.org/'


def cmp(a, b):
    return (a > b) - (a < b)


class ParametersAction(dict):
    def __init__(self, partial):
        for parameter in partial['parameters']:
            name = str(parameter['name'])
            value = parameter['value']
            if name == 'PR':
                value = int(value)
            self.__setitem__(name, value)


class QueueItem(object):
    def __init__(self, partial):
        self.name = partial['task']['name']
        self.why = partial['why']
        self.inQueueSince = partial['inQueueSince']
        self.id = partial['id']
        # print('>>>>>>>>>>>>>>>>>>>>')
        # print(json.dumps(partial, indent=2))
        # print('<<<<<<<<<<<<<<<<<<<<')

        self.url = partial['url']

        actions = partial['actions']

        # print(json.dumps(actions, indent=2))

        self.actions = []
        for action in actions:
            if action == {}:
                continue
            if action['_class'] == 'hudson.model.ParametersAction':
                self.actions.append(ParametersAction(action))
                # print(self.actions[-1])
            elif action['_class'] == 'hudson.model.CauseAction':
                # print('CA', json.dumps(action, indent=2))
                continue
            elif action['_class'] == 'hudson.matrix.MatrixChildParametersAction':
                # print('MCPA', json.dumps(action, indent=2))
                continue
            else:
                # print('---', json.dumps(action, indent=2))
                continue

    def __getattr__(self, name):
        if name == 'PR':
            for action in self.actions:
                pr = action.get('PR')
                if pr is not None:
                    return pr
            return None

    def __cmp__(self, other):
        '''sort by name then PR then inQueueSince'''
        if self.name == other.name:
            if self.PR == other.PR:
                return cmp(self.inQueueSince, other.inQueueSince)
            else:
                return cmp(self.PR, other.PR)
        else:
            return cmp(self.name, other.name)


if len(sys.argv) == 2:  # read from the command line
    with open(sys.argv[1]) as handle:
        doc = json.loads(handle.read())
else:
    req = requests.get(BASE_URL + 'queue/api/json')
    doc = req.json()

queue = []
for item in doc['items']:
    # print('##############################')
    if 'actions' in item:
        # print('num actions:', len(item['actions']))
        queue.append(QueueItem(item))
        # print('num actions:', len(queue[-1].actions))
        if len(queue[-1].actions) == 0:
            del (queue[-1])
    # else:
    #     print('NO ACTIONS:', item)
    # print('>>>>>', queue[-1])

# print('##############################')
name_length = 0
why_length = 0
for item in queue:
    length = len(item.name)
    if length > name_length:
        name_length = length
    length = len(item.why)
    if length > why_length:
        why_length = length

fmt = '{:<' + str(name_length + 1) + '} {:<6}  {:<' + str(why_length + 1) + '}'

queue.sort()

print(fmt.format('job', 'PR', 'why'), 'jobid')
for item in queue:
    print(fmt.format(item.name, str(item.PR), item.why), item.id, item.url)  # inQueueSince)

# #####################################################################
# An example of deleting the (queued) jobs is found in
# https://github.com/docker/leeroy/blob/master/jenkins/jenkins.go#L197
# https://github.com/docker/leeroy/blob/master/jenkins/jenkins.go#L238-L242
# #####################################################################

# doc['items'][2]['actions'][0]['parameters'].keys()
