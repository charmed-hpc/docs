#! /bin/bash
#SBATCH --job-name=apptainer_mascot
#SBATCH --partition=tutorial-partition
#SBATCH --nodes=2
#SBATCH --error=/data/tutorial/mascot_error.txt
#SBATCH --output=/data/tutorial/mascot_output.txt


apptainer run workload.sif favorite_lts_mascot.csv --output graph.png
