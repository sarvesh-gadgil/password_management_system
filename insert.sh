#!/bin/bash

if [ "$#" -ne 4 ]; then
	echo "Error: parameters problem"
elif [ ! -d "$1" ]; then
	echo "Error: user does not exist"
elif [[ $2 != *"/"* ]]; then
	./P.sh "$1"
	if [ -e "./$1/$2" ]; then
		if [ "$3" == "f" ]; then  
			rm -rf "./$1/$2"
        		echo "$4" | sed 's/\\n/\n/g' > "./$1/$2"
        		echo "OK: service updated"   
		else
			echo "Error: service already exists"
		fi
	else
		echo "$4" | sed 's/\\n/\n/g' > "./$1/$2"
        	echo "OK: service created"	
	fi
	./V.sh "$1"
else
	#folder_name=$(echo $2 | cut -f1 -d/)
	folder_name="$(dirname "$2")"
        #file_name=$(echo $2 | cut -f2 -d/)
	file_name="$(basename "$2")"
	
	./P.sh "$1"
	if [ ! -d "./$1/$folder_name" ]; then
		mkdir -p "./$1/$folder_name"
	fi

	if [ -e "./$1/$folder_name/$file_name" ]; then
                if [ "$3" == "f" ]; then
                        rm -rf "./$1/$folder_name/$file_name"
                        echo "$4" | sed 's/\\n/\n/g' > "./$1/$folder_name/$file_name"
                        echo "OK: service updated"   
                else
                        echo "Error: service already exists"
                fi
        else
                echo "$4" | sed 's/\\n/\n/g' > "./$1/$folder_name/$file_name"
                echo "OK: service created"      
        fi
	./V.sh "$1"
fi

