#!/usr/bin/sh
if [[ $(hostname) == molly* ]]; then
    echo "installing crontab"
    crontab crontab
else
    echo "not installing crontab"
fi
