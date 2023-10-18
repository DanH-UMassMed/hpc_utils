#!/bin/bash

function get_jobid(){
	local bjobs_output=$(bjobs -o "jobid job_name")
	while IFS= read -r line ; do 
		if [[ "${line}" == *"$HAS_JOB_NAME"* ]]; then
			jbod_id=`echo $line |cut -f1 -d' '`
			echo $jbod_id
			break
		fi
	done <<< "$bjobs_output"
}

bjobs_output=$(bjobs -o "jobid job_name")

HAS_JOB_NAME='start_jupyter_lab.sh'
if [[ "${bjobs_output}" == *"$HAS_JOB_NAME"* ]]; then
	jobid=$(get_jobid)
	echo "GPU session $jobid is already running!!"
	#battach $jobid
else
	bsub -Is -q gpu -W 6:00 -n 4 -R "rusage[mem=16384]" -gpu "num=1:mode=exclusive_process:mps=yes:j_exclusive=yes:gvendor=nvidia" start_jupyter_lab.sh
fi





