#!/bin/bash
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


bjobs_output=$(bjobs -o "jobid queue")

HAS_INTERACTIVE='gpu'
if [[ "${bjobs_output}" == *"$HAS_INTERACTIVE"* ]]; then
	jobid=$(get_jobid)
	echo "GPU session $jobid is already running!!"
	battach $jobid
else
	bsub -Is -q gpu -gpu "num=1:mode=exclusive_process:mps=yes:j_exclusive=yes:gvendor=nvidia" /bin/bash
fi