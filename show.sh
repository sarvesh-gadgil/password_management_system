#!/bin/bash

if [ "$#" -ne 2 ]; then
        echo "Error: parameters problem"
elif [ ! -d "$1" ]; then
        echo "Error: user does not exist"
elif [ ! -e "./$1/$2" ]; then
        echo "Error: service does not exist"
elif [ -d "./$1/$2" ]; then
	echo "Error: provided input is not a file"
else
        cat "./$1/$2"
fi
