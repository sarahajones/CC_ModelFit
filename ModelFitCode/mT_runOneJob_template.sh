#!/bin/bash

#SBATCH --nodes=1
#SBATCH --time=50:00:00
#SBATCH --job-name=fit-ml
#SBATCH --mail-type=NONE
#SBATCH --mail-user=j.calder.travis@gmail.com

# Joshua Calder-Travis, j.calder.travis@gmail.com


# INPUT
# $1 directory. All relevant MATLAB scripts should be in the folder 
#    directory/scripts or a subfolder of this directory
# $2 file name of the job to run

umask 077 

jobDirectory="$1"
filename="$2"


# Set a unique folder for this job's matlab preference data
export MATLAB_PREFDIR=$(mktemp -d "$(pwd)/temp_matlab-XXXXXX")


# Need to provide matlab input as a string
in1="'$jobDirectory'"
in2="'$filename'"

module load matlab/2018b

matlab -nodisplay -nosplash -r "mT_runOnCluster($in1, $in2)"


# Delete temp folder
rm -rf $MATLAB_PREFDIR

