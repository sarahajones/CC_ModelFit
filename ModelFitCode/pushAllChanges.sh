#!/bin/bash

# Pass one argument. This arguement should be a string message that want attched to all git commits. .

echo "Pushing changes to any repo in this directory... "


# Find current directory
startingDir=$(pwd)


# Loop through all directories and pull changes
for directory in */; do

	echo $'\n'
	

	# Check this is not a directory which we want to ignore
	if [ "$directory" == "dm/" ] || [ "$directory" == "jsPsych/" ]  || [ "$directory" == "Other people's code/" ] ||  [ "$directory" == "scaan.github.io/" ] || [ "$directory" == "TempSimData/" ]
	then
	
		echo "Ignoring $directory"
		
		continue
		
	fi
	
	
	cd $directory
	
	
	echo $directory
	
	
	git add -A
	git commit -m "$1"
	git push
	

	# Return to the starting directory
	cd $startingDir
	
	
done
	
	
echo $'\n'	
echo "All changes pushed."