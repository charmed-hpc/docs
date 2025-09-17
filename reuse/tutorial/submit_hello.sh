#!/usr/bin/env bash
#SBATCH --job-name=hello_world
#SBATCH --partition=tutorial-partition
#SBATCH --nodes=2
#SBATCH --error=/data/tutorial/error.txt
#SBATCH --output=/data/tutorial/output.txt

mpirun /data/tutorial/mpi_hello_world

