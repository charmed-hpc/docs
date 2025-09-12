#!/usr/bin/env bash

# This script shows you how to run the example workload with the Apptainer image.

apptainer build workload.sif workload.def  # `generate.py` and `workload.py` must be located in the same directory.
srun -p <partition name> --container ${PWD}/workload.sif generate --rows 1000000

cat << 'EOF' > example-job.batch
#!/usr/bin/env bash
#SBATCH --partition <partition name>
#SBATCH other necessary front-matter
apptainer run workload.sif favorite_lts_mascot.csv --output graph.png
EOF

sbatch example-job.batch
display graph.png  # Must have imagemagick installed. You can also download `graph.png` onto your local machine.
