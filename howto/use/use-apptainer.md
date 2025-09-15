(howto-use-apptainer)=
# Use Apptainer

Apptainer can be used as a container runtime environment on Charmed HPC for running
containerized workloads. This guide explains how to use different features of Apptainer
on Charmed HPC.

:::{hint}
If you're unfamiliar with using Apptainer, see the [Apptainer user quick start](https://apptainer.org/docs/user/latest/quick_start.html)
guide for a high-level introduction to using Apptainer.
:::

## Prerequisites

To successfully use Apptainer on your Charmed HPC cluster, you will at least need:

- A [deployed Slurm cluster](#howto-setup-deploy-slurm).
- An [active Apptainer integration](#howto-manage-integrate-with-apptainer).

Once you have verified that Apptainer is integrated with your Charmed HPC, refer
to the sections below for the different ways that you can use Apptainer on Charmed HPC.

## Create a container image

Apptainer can create container images on your cluster that can then be used within
your workloads. The sections below demonstrate the different ways Apptainer can create
container images on your Charmed HPC cluster.

### Using a pre-existing container image from a public container registry

Apptainer can pull pre-existing container images from public container registries.
For example, to pull a Valkey container image from Dockerhub and start a local
Valkey service on your cluster:

:::{terminal}
:copy:
:host: login
:input: apptainer pull valkey.sif docker://ubuntu/valkey:7.2.10-24.04_stable

:input: apptainer overlay create --size 1024 valkey.img
:input: apptainer instance run --overlay valkey.img valkey.sif valkey
INFO:    instance started successfully
:input: apptainer exec instance://valkey valkey-cli ping
PONG
:::

Use `apptainer help pull`{l=text} to see the full list of public container registries
Apptainer can pull container images from.

### Building your own custom container image

Apptainer can build container images using instructions from a container definition file.
For example, to build an Ubuntu 24.04 LTS-based container image with the `gfortran` compiler
pre-installed, create the container definition file _workload.def_:

:::{code-block} shell
:caption: workload.def
bootstrap: docker
from: ubuntu:24.04

%post
    apt-get -y update
    apt-get -y install gfortran

%test
    gfortran --version
    exit 0
:::

Now use `apptainer build`{l=shell} to build the container image:

:::{terminal}
:copy:
:host: login
:input: apptainer build workload.sif workload.def
:::

The built container image can now be used to compile and run Fortran workloads. For
example, create a simple Fortran program the prints "Hello world!" in the file _hello.f90_:

:::{code-block} fortran
:caption: hello.f90
PROGRAM hello_world
  IMPLICIT NONE
  PRINT *, "Hello world!"
END PROGRAM hello_world
:::

Now use the built container to compile and run your Fortran program:

:::{terminal}
:copy:
:host: login
:input: apptainer exec workload.sif gfortran --output hello hello.f90

:input: apptainer exec workload.sif ./hello
Hello world!
:::

:::{warning}
Check with your cluster administrator before attempting to build container images
on your Charmed HPC cluster. Each site has different policies about whether you
can build container images directly on your cluster, and some disallow
building container images on specific cluster resources such as login nodes.
:::

## Provide your workload's runtime environment

Apptainer can provide the runtime environment for your workloads.
The sections below demonstrate the different ways Apptainer can provide
your workload's runtime environment.

### Using the `apptainer`{l=shell} command directly in your workload

Declare in your batch script the partition you want your workload to run within and call the
`apptainer`{l=shell} command from directly within your script. For example, to select `compute`
as the partition your workload will run within, and run some Python code using a containerized
Python 3.13 interpreter, create the batch script _job.batch_:

:::{code-block} shell
:caption: job.batch
#!/usr/bin/env bash
#SBATCH --partition compute
#SBATCH --output %j.out

apptainer pull python-3.13.sif docker://ubuntu/python:3.13-25.04
apptainer --silent exec python-3.13.sif \
  python3 -c 'import sys; print(f"Hello from Python {sys.version}!")'
:::

Now submit the _job.batch_ script to Slurm with `sbatch`{l=shell}:

:::{terminal}
:copy:
:host: login
:input: sbatch job.batch
Submitted batch job 1
:::

Use `cat`{l=shell} to view the results of your workload after it completes:

:::{terminal}
:copy:
:host: login
:input: cat 1.out
Hello from Python 3.13.3 (main, Aug 14 2025, 11:53:40) [GCC 14.2.0]!
:::

:::{important}
Remember your job identification number after submitting your batch script
with `sbatch`{l=shell}. It may be different from the example output above.
:::

[//]: # (TODO: Uncomment once https://github.com/charmed-hpc/slurm-charms/issues/143 is fixed.)
<!--
### Using the `--container` flag with `sbatch`{l=shell}

Declare in your batch script's front matter both the partition you want your workload to run within
and the container that will provide the runtime environment of your workload. For example, to create
a batch script with `compute ` selected as the partition your workload will run
within, and use a container with Python 3.13 pre-installed as the runtime environment:

:::{code-block} shell
#!/usr/bin/env bash
#SBATCH --partition compute
#SBATCH --container docker://ubuntu/python:3.13-25.04
#SBATCH --output stdout-%j.log

python3 --version
:::

Now submit your batch script using the `sbatch`{l=shell} command:

:::{terminal}
:copy:
:host: login
:input: sbatch my-job.batch
:::
-->

### Using the `--container` flag with `srun`{l=shell}

Declare both the partition you want your workload to run within and the container that
will provide the runtime environment of your workload. For example, to select `compute`
as the partition your workload will run within, and use an Ubuntu 22.04 LTS container
as the runtime environment:

:::{terminal}
:copy:
:host: login
:input: PARTITION=slurmd

:input: CONTAINER=docker://ubuntu:22.04
:::

Now run your workload with `srun`{l=shell}:

:::{terminal}
:copy:
:host: login
:input: srun --partition $PARTITION --container $CONTAINER cat /etc/os-release | grep ^VERSION
INFO:    Converting OCI blobs to SIF format
INFO:    Starting build...
INFO:    Fetching OCI image...
INFO:    Extracting OCI image...
INFO:    Inserting Apptainer configuration...
INFO:    Creating SIF file...
VERSION_ID="22.04"
VERSION="22.04.5 LTS (Jammy Jellyfish)"
VERSION_CODENAME=jammy
:::







