#!/bin/bash

# Requires that SSH keys have been exchanged for no password authentication
remote_host_user="daniel.higgins-umw@hpc.umassmed.edu"

username=$(echo $remote_host_user | cut -d "@" -f 1)

function start_on_port(){
	local port=$1

    # Loop to find the first open port above 8000
    while true; do
		local result=$(lsof -i :"$port" -sTCP:LISTEN -t)
		if ! [[ -n "$result" ]]; then
			# The port is open
			echo $port
			break
		fi

        # If the port is not open, check the next port
        ((port++))
    done
}


ssh ${remote_host_user} 'launch_jupyter_lab.sh'
if [ $? -eq 0 ]
then
	JUPYTER_IP_PORT=`ssh ${remote_host_user} "cat /home/${username}/var/jupyter/jupyter_host_ip.txt"`
	start_port=$(start_on_port 8088)
	echo "Jupyter Lab is running at http://127.0.0.1:${start_port}"
	ssh -L ${start_port}:${JUPYTER_IP_PORT} ${remote_host_user}
fi
