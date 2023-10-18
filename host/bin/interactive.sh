#!/bin/bash

## The Queue Name / Type
## The interactive Queue is the one we are interested in
HAS_INTERACTIVE='interactive'

## This function looks at the running batch jobs and returns the 
## JOBID of the first job using the interactive QUEUE
function get_jobid(){
	local bjobs_output=$(bjobs -o "jobid queue")
	while IFS= read -r line ; do 
		if [[ "${line}" == *"$HAS_INTERACTIVE"* ]]; then
			jbod_id=`echo $line |cut -f1 -d' '`
			echo $jbod_id
			break
		fi
	done <<< "$bjobs_output"
}

## capture jobids and queues in a variable
bjobs_output=$(bjobs -o "jobid queue")

## If we are already runing an interactive job attach to it
## If we are not running an interactive job start one
if [[ "${bjobs_output}" == *"$HAS_INTERACTIVE"* ]]; then
	jobid=$(get_jobid)
	echo "Interactive session $jobid is already running!!"
	battach $jobid
else
	bsub -Is -q interactive -n 2  -W 4:00 -R rusage[mem=16GB] /bin/bash
fi
