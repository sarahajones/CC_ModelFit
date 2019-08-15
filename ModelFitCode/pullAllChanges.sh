#!/bin/bash

echo "Pulling changes to any repo in this directory... "


# Find current directory
startingDir=$(pwd)


# Loop through all directories and pull changes
for directory in */; do

	echo $'\n'
	

	# Check this is not a directory which we want to ignore
	if [ "$directory" == "dm/" ] || [ "$directory" == "jsPsych/" ]  || [ "$directory" == "Other people's code/" ] 
	then
	
		echo "Ignoring $directory"
		
		continue
		
	fi
	
	
	cd $directory
	
	
	echo $directory
	
	
	git pull
	

	# Return to the starting directory
	cd $startingDir
	
	
done
	
	
echo "All changes pulled."