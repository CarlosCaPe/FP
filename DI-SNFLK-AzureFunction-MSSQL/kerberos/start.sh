#!/bin/bash

env >> /etc/environment

crontab /kerberos/crontab

cron

/usr/local/bin/python /kerberos/login.py

/azure-functions-host/start.sh
