#!/bin/bash

if [ -z "$1" ]; then
	exit 1
else
	rm -rf "$1.lock"
	exit 0
fi

