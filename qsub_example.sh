#!/bin/bash
# Bash wrapper to qsubmit spm .mat jobs to the Medusa. -JSM 20170523
#
# QSUB OPTIONS:
# This options starts in the current working directory
#$ -cwd
# Combine the output and error logs into one
#$ -j y
# Use the bash environment
#$ -S /bin/bash
# Use same environment variables
#$ -V
# Send email when job is finished.
#$ -m e -M jm3080@georgetown.edu
# Name the job
#$ -N qSubSpmJob
# Allocate 16 gb of ram for this job.
#$ -l h_vmem=16G

# COMMANDS TO RUN:
# load latest matlab module
module load matlab/R2017a 

# Start matlab, submit the matlab commands entered after the ‘-r’ option, then exits matlab. 
# $1 variable is the SPM batch .mat file submitted with this script.

matlab -nosplash -nodisplay -nodesktop –r “clear; addpath('/share/apps/spm/spm12’);
spm_jobman('initcfg'); load $1; spm_jobman('run',matlabbatch); exit”