#!/bin/bash
VAR_DIR=${HOME}/var/jupyter
mkdir -p ${VAR_DIR}
JUPYTER_IP_FILE=`echo ${VAR_DIR}/jupyter_host_ip.txt`

function start_on_port(){
    # netstat -tuln  --> list all the ports in use
    # tr -s ' '      --> squeezes multiple space into one space (make a consistent delimiter)
    # cut -d' ' -f4  --> gets the fourth field of the output (which is address and port)
    # rev | cut -d':' -f1 | rev --> reverse the input get the port as the first field and reverse back to original (required because ipv6 notation is :::)
    # grep -v '^$'   --> drop blank lines
    # sort -n | uniq --> only include unique port numbers

    port_list=$(netstat -tuln | \
        tr -s ' ' | \
        cut -d' ' -f4 | \
        rev | cut -d':' -f1 | rev | \
        grep -v '^$' | \
        sort -n | uniq)

    # Start port number to search from
    start_port=8001

    # Loop to find the first open port above 8000
    while true; do
        # Check if the port is open using netstat and grep
        if ! echo $port_list | grep -q "$start_port\b"; then
            echo $start_port
            break
        fi

        # If the port is not open, check the next port
        ((start_port++))
    done
}

mkdir -p ${HOME}/Notebooks
cd ${HOME}/Notebooks

# Delete any old jupyter ip files if they exist
# we check this file after startup for the ssh tunnel
if [ -f "$JUPYTER_IP_FILE" ] ; then
    rm "$JUPYTER_IP_FILE"
fi

# Make sure we are starting jupyter lab in the base conda environment
active_env=`conda info|egrep "active environment"|cut -d: -f2|tr -d '[:space:]'`
if [ "$active_env" == "base" ]; then
    host_ip=`ifconfig 2>/dev/null|grep inet|grep 255.255.252.0|sed -e's/^[ ]*//'|cut -d' ' -f2`
	host_port=$(start_on_port)
	echo jupyter-lab --ip $host_ip --port=$host_port  
	echo "$host_ip:$host_port" >${JUPYTER_IP_FILE}
	nohup jupyter-lab  --no-browser --ip $host_ip --port=$host_port 1>${VAR_DIR}/jupyter-lab.log 2>${VAR_DIR}/jupyter-lab.err & 
else
	echo "You Must start in the base conda environment!"
fi
