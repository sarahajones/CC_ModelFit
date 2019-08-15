#!/bin/bash

# Submits all jobs which don't have an associated results file.

# Joshua Calder-Travis, j.calder.travis@gmail.com

# INPUT
# $1    Directory in which to look for jobs. All relevant scripts should be in a
#       folder (or subfolder) of this directory named "scripts". Resutls will be 
#       saved here.

jobDirectory=$1

# Loop through all job files in the direcotry
for filename in $jobDirectory/*job.mat; do

	# Does this job already have a results file?
	rootName=${filename:0:$((${#filename} - 7))}
	resultFile=$rootName"1_result_PACKED.mat"

	if [ ! -f "$resultFile" ] 
	then

	    	# Submit the job
    		sbatch ./mT_runOneJob.sh "$jobDirectory" "$filename" 

    		echo "$jobDirectory"
    		echo "$filename"

	fi

done
