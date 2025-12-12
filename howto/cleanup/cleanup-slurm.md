(howto-cleanup-slurm)=
# How to clean up Slurm deployments

This how-to guide shows you how to remove a [previously deployed Slurm workload manager](#howto-setup-deploy-slurm)
in a Charmed HPC cluster.

## Destroying the Slurm model

To destroy a Slurm deployment, the name of the Juju model containing the Slurm resources is required.
Run the following command to list all Juju models:

:::{terminal}
:copy:
juju models

Controller: charmed-hpc-controller

Model       Cloud/Region         Type  Status     Machines  Units  Access  Last connection
controller  localhost/localhost  lxd   available         1      1  admin   just now
slurm*      localhost/localhost  lxd   available         6      6  admin   never connected
:::

Locate the model containing Slurm resources, here the name is `slurm`. Run the following command,
read the warnings, and enter the model name when prompted to destroy it and all associated storage:

:::{admonition} Data loss warning
:class: warning

Destroying storage may result in **permanent data loss**. Ensure all data you wish to preserve has
been migrated to a safe location before proceeding or consider using flag `--release-storage` to
release the storage rather than destroy it.
:::

:::{terminal}
:copy:
juju destroy-model --destroy-storage slurm

WARNING This command will destroy the "slurm" model and affect the following resources. It cannot be stopped.

 - 6 machines will be destroyed
  - machine list: "0 (juju-e88112-0)" "1 (juju-e88112-1)" "2 (juju-e88112-2)" "3 (juju-e88112-3)" "4 (juju-e88112-4)" "5 (juju-e88112-5)"
 - 6 applications will be removed
  - application list: "mysql" "sackd" "slurmctld" "slurmd" "slurmdbd" "slurmrestd"
 - 1 filesystem and 0 volume will be destroyed

To continue, enter the name of the model to be unregistered: slurm
Destroying model
Waiting for model to be removed, 6 machine(s), 6 application(s), 1 filesystems(s)..........
Waiting for model to be removed, 2 machine(s), 3 application(s), 1 filesystems(s)...
Waiting for model to be removed, 2 machine(s), 2 application(s), 1 filesystems(s)...
Waiting for model to be removed, 2 machine(s), 1 application(s)...
Waiting for model to be removed, 1 machine(s).....
Model destroyed.
:::

## Force-destroying a stuck model

If resources in the model are in an error state the `destroy-model` process may become stuck,
indicated by repeated `Waiting for model to be removed` messages. In this case, add the `--force`
flag to the command to remove resources while ignoring errors:

:::{terminal}
juju destroy-model --destroy-storage --force slurm
:::

See the [Juju `destroy-model` documentation](https://documentation.ubuntu.com/juju/3.6/reference/juju-cli/list-of-juju-cli-commands/destroy-model/)
for the implications of this flag and details of further available options.