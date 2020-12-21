#!/bin/bash

./P.sh "$1"
if [ "$#" -ne 2 ]; then
        echo "Error: parameters problem"
elif [ ! -d "$1" ]; then
        echo "Error: user does not exist"
elif [ ! -e "./$1/$2" ]; then
        echo "Error: service does not exist"
else
        rm -rf "./$1/$2"
	echo "OK: service removed"
fi      
./V.sh "$1"         
