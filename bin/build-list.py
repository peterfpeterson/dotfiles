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
    'aborted': 'grey'
}

class BuildJob:
    def __init__(self, url):
        params={}

        if not url.startswith(JOB_URL):
            url = os.path.join(JOB_URL, url)

        self.urlJob = url
        if not url.endswith('api/json'):
            url = os.path.join(url, 'api/json')

        req = requests.get(url, params=params)
        if req.status_code != 200:
            raise RuntimeError('failed to get information from %s' % url)

        self.name = req.json()['displayName']
        self.color = req.json()['color']
        lastCompletedBuild = req.json()['lastCompletedBuild']
        self.number = lastCompletedBuild['number']

        self.urlBuild = lastCompletedBuild['url']
        url =  self.urlBuild + '/api/json'
        req = requests.get(url, params=params)
        if req.status_code != 200:
            raise RuntimeError('failed to get information from %s' % url)
        self.result = req.json()['result']
        self.timestamp = req.json()['timestamp'] # TODO convert to object

    def __str__(self):
        return '%35s %6d %s' % (self.name, self.number, self.result)

    def toHtml(self, bgcolor=None):
        name = '<a href=\'%s\'>%s</a>' % (self.urlJob, self.name)
        number = '<a href=\'%s\'>%d</a>' % (self.urlBuild, self.number)

        result = self.result
        color = self.color.replace('_anime', '')
        result = '<font color=\'%s\'>%s</font>' % (COLORS[color], result)

        cells = [name, number, result]
        cells = ['  <td>%s</td>\n' % cell for cell in cells]

        result = '<tr'
        if bgcolor is not None:
            result += ' bgcolor=\'%s\'' % bgcolor
        result += '>%s</tr>\n' % ' '.join(cells)

        return result

class JobsList:
    def __init__(self, name, jobs=None):
        self.name = name

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

        req = requests.get(url)
        if req.status_code != 200:
            raise RuntimeError('failed to get information from %s' % url)

        self.jobs = [job['name'] for job in req.json()['jobs']]
        self.jobs.sort()

    def __getJob(name):
        if name in jobsAll:
            job = jobsAll[name]
        else:
            job = BuildJob(name)
            jobsAll[job.name] = job
        return job

    def __str__(self):
        text = self.name + '\n'
        text += '-' * len(self.name) +'\n'
        for name in self.jobs:
            job = __class__.__getJob(name)
            text += str(job) + '\n'
        return text

    def toHtml(self):
        text = '<tr><th bgcolor=\'#424242\' COLSPAN=\'3\'><b><font color=\'#EEEEEE\'>%s</font></b></th></tr>\n' % self.name
        for i, name in enumerate(self.jobs):
            job = __class__.__getJob(name)
            if i % 2:
                text += job.toHtml('#E6E6E6')
            else:
                text += job.toHtml()
        return text

#################### read in the configuration
if len(sys.argv) != 2:
    print('Must supply a configuration file')
    sys.exit(-1)
print('Loading configuration from \'%s\'' % sys.argv[1])
with open(sys.argv[1], 'r') as handle:
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

#################### generate the report
print('Collecting information about jobs')
msg_text = ''
msg_html = '<html><head></head><body>\n'
msg_html += '<table>\n'

jobsList = JobsList('Critical Jobs')
msg_text += str(jobsList)
msg_html += jobsList.toHtml()

jobsList = JobsList('Master Pipeline')
msg_text += str(jobsList)
msg_html += jobsList.toHtml()

jobsList = JobsList('Static Analysis')
msg_text += str(jobsList)
msg_html += jobsList.toHtml()

jobs = ['master_clean-archlinux',
        'master_clean-archlinux-clang',
        'master_clean-fedora23',
        'master_clean-fedora24',
]
jobsList = JobsList('Builds of Interest', jobs)
msg_text += str(jobsList)
msg_html += jobsList.toHtml()

msg_html += '</table>\n'
msg_html += '</body></html>'

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
