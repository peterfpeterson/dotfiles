#!/usr/bin/env python3
from __future__ import (absolute_import, division, print_function)
import json
import os
import requests # python-requests
import smtplib
import sys
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

# Some links about html formatting email
# https://css-tricks.com/using-css-in-html-emails-the-real-story/
# http://templates.mailchimp.com/?_ga=1.192270638.523823784.1476384638

# global variables are bad
jobsAll = {}

COLORS = {
    'blue':'black',
    'yellow':'yellow',
    'red':'red',
    'disabled': 'grey',
    'aborted': 'grey',
    '': 'black',

    'SUCCESS':  'black',
    'FAILURE':  'red',
    'UNSTABLE': 'yellow',
    'ABORTED':  'grey',
    'DISABLED': 'grey'
}

class BuildJob:
    def __init__(self, url, prev):
        params={}

        # convert known status to something more usable
        known_status = {}
        for key in prev.keys():
            known_status[int(key)] = prev[key]
        keys = list(known_status.keys())
        keys.sort()
        if len(keys) > 0:
            self.numberLast = keys[-1]
            self.resultLast = known_status[self.numberLast]
        else:
            self.numberLast = ''
            self.resultLast = ''

        if not url.startswith(JOB_URL):
            url = os.path.join(JOB_URL, url)

        self.urlJob = url
        if not url.endswith('api/json'):
            url = os.path.join(url, 'api/json')

        req = requests.get(url, timeout=15., params=params)
        if req.status_code != 200:
            raise RuntimeError('failed to get information from %s' % url)

        self.name = req.json()['displayName']
        self.color = req.json()['color']
        lastCompletedBuild = req.json()['lastCompletedBuild']
        self.number = lastCompletedBuild['number']

        self.urlBuild = lastCompletedBuild['url']
        url =  self.urlBuild + '/api/json'

        if self.number in known_status.keys():
            self.result = known_status[self.number]
        else:
            req = requests.get(url, timeout=15., params=params)
            if req.status_code != 200:
                raise RuntimeError('failed to get information from %s' % url)
            self.result = req.json()['result']
            self.timestamp = req.json()['timestamp'] # TODO convert to object

    def show(self):
        if self.result == 'SUCCESS' and \
           self.result == self.resultLast:
            return False

        return True

    def __str__(self):
        return '%35s %6s %8s %6d %8s' % (self.name,
                                         str(self.numberLast), self.resultLast,
                                         self.number, self.result)

    def __statusToHtml(url, number, result):
        number = '<a href=\'%s\'>%d</a>' % (url, number)
        result = '<font color=\'%s\'>%s</font>' % (COLORS[result], result)

        return '<td>%s</td><td>%s</td>' % (number, result)

    def toHtml(self, bgcolor=None):
        name = '<td><a href=\'%s\'>%s</a></td>' % (self.urlJob, self.name)

        if len(self.resultLast) > 0 and self.number != self.numberLast:
            jobUrl = self.urlBuild.replace(str(self.number),
                                           str(self.numberLast))
            previous = BuildJob.__statusToHtml(jobUrl, self.numberLast,
                                               self.resultLast)
        else:
            previous = '<td COLSPAN=\'2\'>&nbsp;</td>'


        current = BuildJob.__statusToHtml(self.urlBuild, self.number,
                                          self.result)

        cells = [name, previous, current]

        result = '<tr'
        if bgcolor is not None:
            result += ' bgcolor=\'%s\'' % bgcolor
        result += '>%s</tr>\n' % '\n'.join(cells)

        return result

class JobsList:
    def __init__(self, name, prev={}, jobs=None):
        self.name = name
        self.prev = prev.get(name, {})

        if jobs is not None:
            self.jobs = jobs
        else:
            url = name.replace(' ', '%20')
            if not url.startswith(VIEW_URL):
                url = os.path.join(VIEW_URL, url)

            self.__jobsFromView(url)

    def __jobsFromView(self, url):
        if not url.endswith('api/json'):
            url = os.path.join(url, 'api/json')

        req = requests.get(url, timeout=15.)
        if req.status_code != 200:
            raise RuntimeError('failed to get information from %s' % url)

        self.jobs = [job['name'] for job in req.json()['jobs']]
        self.jobs.sort()

    def __getJob(self, name):
        if name in jobsAll:
            job = jobsAll[name]
        else:
            prev = self.prev.get(name, {})
            job = BuildJob(name, prev)
            jobsAll[job.name] = job
        return job

    def __str__(self):
        text = self.name + '\n'
        text += '-' * len(self.name) +'\n'
        for name in self.jobs:
            job = self.__getJob(name)
            if job.show():
                text += str(job) + '\n'
        return text

    def toHtml(self):
        text = '<tr><th bgcolor=\'#424242\' COLSPAN=\'5\'><b><font color=\'#EEEEEE\'>%s</font></b></th></tr>\n' % self.name
        i = 0
        for name in self.jobs:
            job = self.__getJob(name)
            if job.show():
                if i % 2:
                    text += job.toHtml('#E6E6E6')
                else:
                    text += job.toHtml()
                i += 1
        return text

    def toDict(self):
        result = {}
        for name in self.jobs:
            job = self.__getJob(name)
            result[name] = {job.number: job.result}
        return result

#################### read in the configuration
configfile = os.path.expanduser('~/.build-list.config')
if len(sys.argv) == 2:
    configfile = sys.argv[1]
if not os.path.exists(configfile):
    print('Did not find configuration file \'%s\'' % s)
    print('Either supply one as an argument or create default one')
    sys.exit(-1)

print('Loading configuration from \'%s\'' % configfile)
with open(configfile, 'r') as handle:
    lines = handle.readlines()
    lines = [line.strip() for line in lines]
    (BASE_URL,
     email_from,
     email_to,
     email_smtp) = lines

print('  base_url =', BASE_URL)
print('  from     =', email_from)
print('  to       =', email_to) # can separate addresses with ';'
print('  smtp     =', email_smtp)

VIEW_URL = os.path.join(BASE_URL, 'view')
JOB_URL  = os.path.join(BASE_URL, 'job')

#################### load the last round of information
last_file = os.path.expanduser('~/.build-list.json')
if os.path.exists(last_file):
    print('Loading last known states from \'%s\'' % last_file)
    with open(last_file, 'r') as handle:
        last_dict = json.load(handle)
else:
    last_dict = {}

#################### generate the report
print('Collecting information about jobs')
msg_dict = {}
msg_text = ''
msg_html = '<html><head></head><body>\n'
msg_html += '<table>\n'

jobsList = JobsList('Critical Jobs', last_dict)
msg_text += str(jobsList)
msg_html += jobsList.toHtml()
msg_dict[jobsList.name] = jobsList.toDict()

jobsList = JobsList('Master Pipeline', last_dict)
msg_text += str(jobsList)
msg_html += jobsList.toHtml()
msg_dict[jobsList.name] = jobsList.toDict()

jobsList = JobsList('Static Analysis', last_dict)
msg_text += str(jobsList)
msg_html += jobsList.toHtml()
msg_dict[jobsList.name] = jobsList.toDict()

jobs = ['master_clean-archlinux',
        'master_clean-archlinux-clang',
        'master_clean-fedora24',
        'master_clean-fedora25',
]
jobsList = JobsList('Builds of Interest', last_dict, jobs)
msg_text += str(jobsList)
msg_html += jobsList.toHtml()
msg_dict[jobsList.name] = jobsList.toDict()

msg_html += '</table>\n'
msg_html += '<p>Jobs that succeeded the last two times they were ' \
            'run are not displayed</p>\n'
msg_html += '</body></html>'

#################### save the last round of information
print('Saving last known states to \'%s\'' % last_file)
with open(last_file, 'w') as handle:
    json.dump(msg_dict, handle)

#################### debug print message
print('********************')
print(msg_text,)
print('********************')
#print(msg_html)
#print('********************')

#################### send the email
print('Sending email')
msg = MIMEMultipart('alternative')
msg['Subject'] = 'Summary of build status'
msg['From'] = email_from
msg['To'] = email_to

# Record the MIME types of both parts - text/plain and text/html.
part1 = MIMEText(msg_text, 'plain')
part2 = MIMEText(msg_html, 'html')

# Attach parts into message container.
# According to RFC 2046, the last part of a multipart message, in this case
# the HTML message, is best and preferred.
msg.attach(part1)
msg.attach(part2)

# Send the message via local SMTP server.
with smtplib.SMTP(email_smtp) as s:
    # sendmail function takes 3 arguments: sender's address, recipient's address
    # and message to send - here it is sent as one string.
    s.sendmail(email_from, email_to, msg.as_string())
    s.quit()
