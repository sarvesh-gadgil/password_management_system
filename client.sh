#!/bin/bash

masterPassword="sEcRe!"

if [ "$#" -lt 2 ];then
	echo "Error: parameters problem"
elif [ "$1" == "" -o "$3" == "" -a "$2" != 'shutdown' ]; then
	echo "Either client id or user name not provided"
else
	case "$2" in 
		init)
			if [ "$#" -ne 3 ]; then
				echo "Error: Invalid request"
			else
				mkfifo "$1.pipe"
				echo "init $3 $1" > server.pipe
				read pipeOutput < "$1.pipe"
				echo "$pipeOutput"
				rm -rf "$1.pipe"
			fi
			;;
		
		insert)

			if [ "$#" -ne 4 ]; then
                                echo "Error: Invalid request"
                        else
				is_generate_password_input_valid=true
				read -r -p 'Please write login: ' login
				echo "$login"
				read -r -p 'Do you want to generate password (type y or n)? ' generate_password
				if [ "$generate_password" == "y" ]; then
					password=$(openssl rand -base64 32)
					echo "$password"
				elif [ "$generate_password" == "n" ]; then
					read -r -p 'Please write password: ' password
					echo "$password"
				else
					is_generate_password_input_valid=false
				fi
				if [ "$is_generate_password_input_valid" == true ]; then
					if [ "$login" == "" -o "$password" == "" ]; then
						echo "Either login or password is empty"
					else
						if [[ $login == *".####."* ]]; then
                                        		echo "Invalid login pattern found"
						elif [[ $password == *".####."* ]]; then
							echo "Invalid password pattern found"
                                		else
							login=$(echo "$login" | sed 's/ /.####./g' | sed -e 's/^[[:space:]]*//')
							password=$(echo "$password" | sed 's/ /.####./g' | sed -e 's/^[[:space:]]*//')
							encryptedPassword=$(echo "$password" | openssl aes-256-ctr -e -base64 -pass "pass:$masterPassword" | tr -d '\n')
							mkfifo "$1.pipe"
                                			echo "insert $3 $4 $login $encryptedPassword $1" > server.pipe
                                			read pipeOutput < "$1.pipe"
                                			echo "$pipeOutput"
                                			rm -rf "$1.pipe"
						fi
					fi
				else
					echo "Error: Invalid generate password input found"
				fi
			fi
			;;
		
		show)
			if [ "$#" -ne 4 ]; then
                                echo "Error: Invalid request"
                        else
                                mkfifo "$1.pipe"
                                echo "show $3 $4 $1" > server.pipe
				op_array=()
                                while read pipeOutput; do
                                	op_array+=("$pipeOutput")
                        	done < "$1.pipe"
				rm -rf "$1.pipe"
				if [[ ${op_array[0]} == *"Error"* ]]; then
  					echo "${op_array[0]}"
				else
					login=$(echo "${op_array[0]}" | cut -d ":" -f2- | sed -e 's/^[[:space:]]*//')
                                        password=$(echo "${op_array[1]}" | cut -d ":" -f2- | sed -e 's/^[[:space:]]*//')
					decryptedPassword=$(echo "$password" | openssl aes-256-ctr -d -base64 -pass "pass:$masterPassword")
					password=$(echo "$decryptedPassword" | sed 's/.####./ /g' | sed -e 's/^[[:space:]]*//')
					echo "$3's login for $4 is: $login"
					echo "$3's password for $4 is: $password"
				fi
                        fi
			;;
		
		edit)
			if [ "$#" -ne 4 ]; then
                                echo "Error: Invalid request"
                        else
                                mkfifo "$1.pipe"
                                echo "show $3 $4 $1" > server.pipe
				op_array=()
                                while read pipeOutput; do
                                        op_array+=("$pipeOutput")
                                done < "$1.pipe"
				if [[ ${op_array[0]} == *"Error"* ]]; then
                                        echo "${op_array[0]}"
                                else
					tempFile=$(mktemp)
					login=$(echo "${op_array[0]}" | cut -d ":" -f2- | sed -e 's/^[[:space:]]*//')
					password=$(echo "${op_array[1]}" | cut -d ":" -f2- | sed -e 's/^[[:space:]]*//')
					decryptedPassword=$(echo "$password" | openssl aes-256-ctr -d -base64 -pass "pass:$masterPassword")
                                        password=$(echo "$decryptedPassword" | sed 's/.####./ /g' | sed -e 's/^[[:space:]]*//')
					loginAndPassword="login: $login\npassword: $password"
					echo "$loginAndPassword" | sed 's/\\n/\n/g' >> "$tempFile"
					vim "$tempFile"
					login=$(grep "login:" "$tempFile")
					password=$(grep "password:" "$tempFile")
					rm -rf "$tempFile"
					if [[ $login == *".####."* ]]; then
                                                echo "Invalid login pattern found"
                                        elif [[ $password == *".####."* ]]; then
                                                echo "Invalid password pattern found"
                                        else
						login=$(echo "$login" | cut -d ":" -f2- | sed -e 's/^[[:space:]]*//')
                                                password=$(echo "$password" | cut -d ":" -f2- | sed -e 's/^[[:space:]]*//')
						if [ "$login" == "" -o "$password" == ""  ]; then
							echo "Either login or password is empty"
						else
							login=$(echo "$login" | sed 's/ /.####./g' | sed -e 's/^[[:space:]]*//')
                                                	password=$(echo "$password" | sed 's/ /.####./g' | sed -e 's/^[[:space:]]*//')
                                                	encryptedPassword=$(echo "$password" | openssl aes-256-ctr -e -base64 -pass "pass:$masterPassword" | tr -d '\n')
							echo "update $3 $4 $login $encryptedPassword $1" > server.pipe
                                        		read pipeOutput < "$1.pipe"
                                        		echo "$pipeOutput"
						fi
					fi
				fi
				rm -rf "$1.pipe"
			fi			
			;;

		rm)
			if [ "$#" -ne 4 ]; then
                                echo "Error: Invalid request"
                        else
                                mkfifo "$1.pipe"
                                echo "rm $3 $4 $1" > server.pipe
                                read pipeOutput < "$1.pipe"
                                echo "$pipeOutput"
                                rm -rf "$1.pipe"
                        fi
			;;

		ls)
			mkfifo "$1.pipe"
			if [ "$4" == "" ]; then
				echo "ls $3 no_service $1" > server.pipe
			else
				echo "ls $3 $4 $1" > server.pipe
			fi
			while read pipeOutput; do
				echo "$pipeOutput"
			done < "$1.pipe"
			rm -rf "$1.pipe"
			;;
		
		shutdown)
			 mkfifo "$1.pipe"
                         echo "shutdown $1" > server.pipe
                         read pipeOutput < "$1.pipe"
                         echo "$pipeOutput"
                         rm -rf "$1.pipe"
			;;
		
		*)
			echo "Error: bad request"
			exit 1
	esac

fi
