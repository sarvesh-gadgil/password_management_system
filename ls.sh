#!/bin/bash

if [ "$#" -gt 2 -o "$#" -eq 0 ]; then
        echo "Error: parameters problem"
elif [ ! -d "$1" ]; then
        echo "Error: user does not exist"
elif [ "$2" == "" ]; then
	echo "OK:"
        tree "./$1"
else
	if [ ! -d "./$1/$2" ]; then
		echo "Error: folder does not exist"
	else
		echo "OK:"
		tree "./$1/$2"
	fi
fi
