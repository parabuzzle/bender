#!/bin/bash
pidfile=`cat ./config.yml | grep pid_file | awk '{print $2}'`
if [ -e $pidfile ]; then
	pid=`cat $pidfile`
	kill $pid
else
	echo "pid file ($pidfile) doesn't exist"
	exit 1
fi