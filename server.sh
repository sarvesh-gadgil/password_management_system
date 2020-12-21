#!/bin/bash

if [ ! -p "server.pipe" ]; then
	mkfifo server.pipe
fi

is_shutdown_request_sent=false

while true; do
while read -r input; do
array_input=($input)
	case "${array_input[0]}" in 
		init)
			pipeOutput=$(./init.sh ${array_input[1]})
			echo "$pipeOutput" > "${array_input[2]}.pipe"
			;;
		
		insert)
			login=$(echo "${array_input[3]}" | sed 's/.####./ /g' | sed -e 's/^[[:space:]]*//')
			password=$(echo "${array_input[4]}" | sed -e 's/^[[:space:]]*//')
			loginAndPassword="login: $login\npassword: $password"
                        trimmedLoginAndPassword=$(echo $loginAndPassword | sed -e 's/^[[:space:]]*//')
			pipeOutput=$(./insert.sh ${array_input[1]} ${array_input[2]} "" "$trimmedLoginAndPassword")
			echo "$pipeOutput" > "${array_input[5]}.pipe"
			;;
		
		show)
			pipeOutput=$(./show.sh ${array_input[1]} ${array_input[2]})
                       	echo "$pipeOutput" > "${array_input[3]}.pipe"
			;;
		
		update)
			login=$(echo "${array_input[3]}" | sed 's/.####./ /g' | sed -e 's/^[[:space:]]*//')
                        password=$(echo "${array_input[4]}" | sed -e 's/^[[:space:]]*//')
                        loginAndPassword="login: $login\npassword: $password"
                        trimmedLoginAndPassword=$(echo $loginAndPassword | sed -e 's/^[[:space:]]*//')
     	                pipeOutput=$(./insert.sh ${array_input[1]} ${array_input[2]} f "$trimmedLoginAndPassword")
                        echo "$pipeOutput" > "${array_input[5]}.pipe"
			;;

		rm)
			pipeOutput=$(./rm.sh ${array_input[1]} ${array_input[2]})
                       	echo "$pipeOutput" > "${array_input[3]}.pipe"
			;;

		ls)
			if [ ${array_input[2]} == "no_service" ]; then
				pipeOutput=$(./ls.sh ${array_input[1]})
			else
				pipeOutput=$(./ls.sh ${array_input[1]} ${array_input[2]})
			fi
                        echo "$pipeOutput" > "${array_input[3]}.pipe"
			;;
		
		shutdown)
			echo "Shutting down..." > "${array_input[1]}.pipe"
			is_shutdown_request_sent=true
			break
			;;
		
		*)
			echo "Error: bad request" > "${array_input[1]}.pipe"
	esac
done < server.pipe
if [ "$is_shutdown_request_sent" == true ]; then
	break
fi
done
