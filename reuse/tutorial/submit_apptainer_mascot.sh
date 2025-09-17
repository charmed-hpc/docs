#! /bin/bash
#SBATCH --job-name=apptainer_mascot
#SBATCH --partition=tutorial-partition
#SBATCH --nodes=2
#SBATCH --error=/data/apptainer_example/mascot_error.txt
#SBATCH --output=/data/apptainer_example/mascot_output.txt


apptainer run /data/apptainer_example/workload.sif /data/apptainer_example/favorite_lts_mascot.csv --output graph.png
