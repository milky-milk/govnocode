#!/bin/bash
# Script to fetch nginx statuses for tribily monitoring systems
# Author: krish@toonheart.com
# License: GPLv2

# Set Variables
BKUP_DATE=`date +%Y%m%d`
LOG="/var/log/zabbix/nginx_status.log"
HOST="127.0.0.1"
PORT="8899"

# Functions to return nginx stats

function active {
elinks -source "http://$HOST:$PORT/nginx_status" | grep 'Active' | awk '{print $NF}'
}

function reading {
elinks -source "http://$HOST:$PORT/nginx_status" | grep 'Reading' | awk '{print $2}'
}

function writing {
elinks -source "http://$HOST:$PORT/nginx_status" | grep 'Writing' | awk '{print $4}'
}

function waiting {
elinks -source "http://$HOST:$PORT/nginx_status" | grep 'Waiting' | awk '{print $6}'
}

function accepts {
elinks -source "http://$HOST:$PORT/nginx_status" | awk NR==3 | awk '{print $1}'
}

function handled {
elinks -source "http://$HOST:$PORT/nginx_status" | awk NR==3 | awk '{print $2}'
}

function requests {
elinks -source "http://$HOST:$PORT/nginx_status" | awk NR==3 | awk '{print $3}'
}

# Run the requested function
$1
