#!/usr/bin/env bash
#SBATCH --job-name=hello_world
#SBATCH --partition=tutorial-partition
#SBATCH --nodes=2
#SBATCH --error=/data/mpi_example/error.txt
#SBATCH --output=/data/mpi_example/output.txt

mpirun /data/mpi_example/mpi_hello_world

