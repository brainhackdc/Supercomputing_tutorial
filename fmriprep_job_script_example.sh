#!/bin/bash
# This is an example of a job script that runs fmriprep on a single subject using a singularity container. The following lines are parameters for SLURM, which is a job scheduling software:
#SBATCH --time=168:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=6
#SBATCH --mem=24000
#SBATCH --output=J72prep2.log
#SBATCH --mail-user=jmerch@terpmail.umd.edu
#SBATCH --mail-type=ALL
#
# Define the subject. You can use this approach to run prep on many subjects. 
Sub=sub-JAM072
#

#
# load the singularity module. This is required on a HPC, but may not be if you are running on your own server that has all software installed. 
module load singularity/2.6.0
#
# The lines below simply add a time stamp, but aren't required for fmriprep to run
echo "------------------------------------------------------------------"
echo "Starting fMRIprep at:"
echo working on ${Sub}
date
echo "------------------------------------------------------------------"
#
# 
# The line below is something that is specific to this version of fmriprep, and may not be an issue for future version. Ignore this for now. 
export SINGULARITYENV_TEMPLATEFLOW_HOME=/home/${USER}/templateflow
#
#
# The following lines are the main functions of this script--running fmriprep using a singularity container. The backslashes at the end of each line indicate that it is continuing the command on the next line.
# Thus, I cannot comment between lines, so I'll describe what each line is doing. 1) telling singularity to run the following with a clean environment. 
# 2-3) binding the local directories on your server with the directory mapping inside the container (as you can see, you can bind any local directory to the home directory in the container). format is:
# /your/local/path:/path/inside/container
# Directory binding is what took me the longest time to understand. 4) gives the full, local path to the singularity container you want to run. 5) gives the input and output directories, 
# and that you are running fmriprep on a participant. Note that the paths to the input/output directories are now using the paths within the container. 6) the participant ID. 7) the 
# working directory. This is where intermediary files are written as fmriprep processes data, which saves the amount of RAM that is needed. This folder ends up taking up a lot of storage, so I recommend deleting 
# it once everything has finished running, and you have quality checked the data. 8) template from which you want to do your skull-stripping, and the output spaces you want the data in. You can specify numerous 
# output spaces, and fmriprep will give you all your data in each of those spaces. As is, this script is asking for 2 MNI templates, native space (T1w), and the freesurfer 5 template (fsaverage5). 
# 9) use the ICA-AROMA (automatic removal of motion artifact). This is an excellent option for anyone doing univariate analysis of task data or resting state analyses. It cleans up motion related noise, and outputs
# denoised data that are ready to analyze. This option is by no means required though. 10-11) specify the hardware specs. Adjust these to fit the specs available on your machine. 12) Cifti is the file format created
# by the human connectome project, and allows for quicker analyses in surface space. Not required. 13) I skip the bids validation because I don't have the timing files needed for full bids validation. fmriprep can 
# still run with the data without these task timing files. 14) This is a huge time saving option if you have structural data that is in a resolution smaller than 1mm cubed. By default, fmriprep will run freesurfer 
# with sub mm option if your structural data has resolution smaller than 1mm. However, even freesurfer recommends not using this option if your structural data is smaller than .75 mm cubed, which is the case for
# our data. Finally, you have to give it the path (within container path) for where the freesurfer license file is, so that FS can run. It is a wierd bug that I thought fmriprep would have resolved by now, but hasnt
#
singularity run --cleanenv \
--home /data/bswift-1/${USER}:/home/${USER} \
--bind /data/bswift-1/${USER}/templateflow:/home/${USER}/templateflow \
/data/bswift-1/jmerch/fmriprep-1.4.1.simg \
/home/jmerch/JAM/in /home/jmerch/JAM/out participant \
--participant-label ${Sub} \
-w /home/jmerch/JAM/out/working \
--skull-strip-template MNI152NLin2009cAsym --output-spaces MNI152NLin2009cAsym:res-2 MNI152NLin6Asym:res-2 T1w fsaverage5 \
--use-aroma \
--nthreads 6 --n_cpus 6 --omp-nthreads 6 \
--mem-mb 24000 \
--cifti-output \
--skip_bids_validation \
--no-submm-recon \
--fs-license-file /home/jmerch/CHT/license.txt
#
# The following lines simply give a time stamp of when it ended. =
echo "------------------------------------------------------------------"
echo "Ended fMRIprep"
echo ${Sub}
date
echo "------------------------------------------------------------------"