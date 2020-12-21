#!/bin/bash

input=""
for elem in "$@"; do
	input+=" $elem"	
done
input=$(echo "$input" | sed -e 's/^[[:space:]]*//')
if [ "$input" != "" ]; then
	./P.sh "$input"
	if [ "$#" -lt 1 ]; then
		echo "Error: parameters problem"
	elif [ -d "$input" ]; then
		echo "Error: user already exists"
	else
		mkdir "$input"
		echo "OK: user created"
	fi
	./V.sh "$input"
else
	echo "Error: parameters problem"
fi
