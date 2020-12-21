#!/bin/bash

if [ -z "$1" ]; then 
	exit 1
else
	while ! mkdir "$1.lock" 2>/dev/null; do
		sleep 1
	done
	exit 0
fi

