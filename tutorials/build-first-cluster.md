(build-first-cluster)=
# Build and use your first Charmed HPC cluster

<!-- A tutorial is a practical activity, in which the student learns by doing something meaningful, towards some achievable goal. What the student does is not necessarily what they will learn. -->

<!-- Goal: Get a new potential user familiar with the various tools used for Charmed HPC, and build a basic cluster that feels recognizable by the end. Show how Charmed HPC provides a turn-key cluster smoothly and why its worth using. -->

In this tutorial we will build a small Charmed HPC cluster, submit a job to the new batch queue, and view the job and cluster status metrics. By the end of this tutorial, we will have worked with Multipass, Juju and Charms, Kubernetes, the Canonical Observability Stack (COS), and Slurm.

This tutorial expects that you have some familiarity with classic high-performance computing concepts and programs, but does not expect any prior experience with Juju, Kubernetes, COS, or prior experience launching a Slurm cluster.

<!-- How long should this tutorial take to complete? -->

:::{note}
This tutorial builds a minimal cluster deployment within a virtual machine and should not be used as the basis for a production cluster.
:::

## Prerequisites and dependencies

To successfully complete this tutorial, you will need:


* 8 CPU cores, 20GB RAM, and 40GB storage available
* [Multipass installed](https://canonical.com/multipass/install)
* An active internet connection
* A local copy of the `charmed-hpc-tutorial-cloud-init.yaml`

## Create Multipass VM

Using the `charmed-hpc-tutorial-cloud-init.yaml`, launch a Multipass VM:

:::{code-block} shell
multipass launch 24.04 --name charmed-hpc-tutorial-vm --cloud-init charmed-hpc-tutorial-cloud-init.yml --memory 16G --disk 40G --cpus 8
:::

<!-- Rephrase this section -->
The virtual machine launch process should take five minutes or less to complete.

<!-- If the instance states that it has failed to launch due to timing out, check `multipass list`{l=shell} to confirm the status of the instance as it may have actually successfully created the vm. If the `State` is `Running`, then the vm was launched successfully and may simply be completing the cloud-init process. -->

<!-- Steps if the vm does not say running? -->

The cloud init process creates and configures our lxd machine cloud `localhost` with the `charmed-hpc-controller` juju controller and our `charmed-hpc-k8s` Kubernetes control cloud.
<!-- Add ref arch pieces -->

To check the status of cloud-init, first, enter the vm:

:::{code-block} shell
multipass shell charmed-hpc-tutorial-vm
:::

Then check `cloud init status`{l=shell}:

:::{terminal}
:input: cloud-init status --long
:copy:
status: done
extended_status: done
boot_status_code: enabled-by-genertor
last_update: Thu, 01 Jan 1970 00:03:45 +0000
detail: DataSourceNoCloud [seed=/dev/sr0]
errors: []
recoverable_errors: {}
:::



## Deploy Slurm and file system

Next, we will deploy Slurm as the resource management and job scheduling service. Here we will use the [Juju Terraform client](https://canonical-terraform-provider-juju.readthedocs-hosted.com/en/latest/).
<!-- Add brief explanation of what Terraform does and why it's useful here -->

<!--see the
[Manage `terraform-provider-juju`](https://canonical-terraform-provider-juju.readthedocs-hosted.com/en/latest/howto/manage-terraform-provider-juju/) how-to guide for additional
requirements - what additional requirements would be needed here?  -->

<!-- Initial steps of creating empty terraform plan and/or getting a copy of the plan we provide? -->

First, we will configure Terraform to use the Juju provider in the deployment plan:

:::{code-block} terraform
:caption: `main.tf`
terraform {
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 0.16.0"
    }
  }
}
:::

Then deploy the Slurm management daemon `slurmctld`, the Slurm compute node daemon with partition name 'tutorial-partition' and two nodes, the authentication and credential kiosk daemon `sackd`:

:::{code-block} shell
juju deploy slurmctld --base "ubuntu@24.04" --channel "edge" --constraints="virt-type=virtual-machine"
juju deploy slurmd tutorial-partition -n 2 --base "ubuntu@24.04" --channel "edge" --constraints="virt-type=virtual-machine"
juju deploy sackd --base "ubuntu@24.04" --channel "edge" --constraints="virt-type=virtual-machine"
:::

<!-- Note about use of --constraints="virt-type=virtual-machine" ? -->

Next, deploy the filesystem pieces to create a MicroCeph shared filesystem:

:::{dropdown} Full Slurm deployment plan
:::{code-block} terraform
:caption: `main.tf`
:linenos:
terraform {
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 0.16.0"
    }
  }
}

resource "juju_model" "slurm" {
  name = "slurm"

  cloud {
    name = "charmed-hpc"
  }
}

module "sackd" {
  source      = "git::https://github.com/charmed-hpc/slurm-charms//charms/sackd/terraform"
  model_name  = juju_model.slurm.name
}

module "slurmctld" {
  source      = "git::https://github.com/charmed-hpc/slurm-charms//charms/slurmctld/terraform"
  model_name  = juju_model.slurm.name
}

module "slurmd" {
  source      = "git::https://github.com/charmed-hpc/slurm-charms//charms/slurmd/terraform"
  model_name  = juju_model.slurm.name
}

module "slurmdbd" {
  source      = "git::https://github.com/charmed-hpc/slurm-charms//charms/slurmdbd/terraform"
  model_name  = juju_model.slurm.name
}

module "slurmrestd" {
  source      = "git::https://github.com/charmed-hpc/slurm-charms//charms/slurmrestd/terraform"
  model_name  = juju_model.slurm.name
}

module "mysql" {
  source          = "git::https://github.com/canonical/mysql-operator//terraform"
  juju_model_name = juju_model.slurm.name
}

resource "juju_integration" "sackd-to-slurmctld" {
  model = juju_model.slurm.name

  application {
    name     = module.sackd.app_name
    endpoint = module.sackd.provides.slurmctld
  }

  application {
    name     = module.slurmctld.app_name
    endpoint = module.slurmctld.requires.login-node
  }
}

resource "juju_integration" "slurmd-to-slurmctld" {
  model = juju_model.slurm.name

  application {
    name     = module.slurmd.app_name
    endpoint = module.slurmd.provides.slurmctld
  }

  application {
    name     = module.slurmctld.app_name
    endpoint = module.slurmctld.requires.slurmd
  }
}

resource "juju_integration" "slurmdbd-to-slurmctld" {
  model = juju_model.slurm.name

  application {
    name     = module.slurmdbd.app_name
    endpoint = module.slurmdbd.provides.slurmctld
  }

  application {
    name     = module.slurmctld.app_name
    endpoint = module.slurmctld.requires.slurmdbd
  }
}

resource "juju_integration" "slurmrestd-to-slurmctld" {
  model = juju_model.slurm.name

  application {
    name     = module.slurmrestd.app_name
    endpoint = module.slurmrestd.provides.slurmctld
  }

  application {
    name     = module.slurmctld.app_name
    endpoint = module.slurmctld.requires.slurmrestd
  }
}

resource "juju_integration" "slurmdbd-to-mysql" {
  model = juju_model.slurm.name

  application {
    name     = module.mysql.application_name
    endpoint = module.mysql.provides.database
  }

  application {
    name     = module.slurmdbd.app_name
    endpoint = module.slurmdbd.requires.database
  }
}
:::
:::

After verifying that the plan is correct, run the following set of commands to deploy Slurm
using Terraform and the Juju provider:

<!-- Within a specific directory? Any other precautions or notes necessary here for someone who has never used Terraform? -->

:::{code-block} shell
juju integrate slurmctld sackd
juju integrate slurmctld tutorial-partition
juju integrate data ceph-fs
juju integrate ceph-fs microceph
juju integrate data:juju-info tutorial-partition:juju-info
juju integrate sackd data
:::

<!-- What will the terminal look like after the prior command? Will there be any on-screen logging happening? -->

After a few minutes, the Slurm deployment will become active. The output of the
`juju status`{l=shell} command should be similar to the following:

:::{terminal}
:input: juju status
:copy:
Model  Controller              Cloud/Region         Version  SLA          Timestamp
slurm  charmed-hpc-controller  localhost/localhost  3.6.9    unsupported  10:53:50-04:00

App                 Version          Status  Scale  Charm              Channel      Rev  Exposed  Message
ceph-fs             19.2.1           active      1  ceph-fs            latest/edge  196  no       Unit is ready
data                                 active      3  filesystem-client  latest/edge   20  no       Integrated with `cephfs` provider
microceph                            active      1  microceph          latest/edge  159  no       (workload) charm is ready
sackd               23.11.4-1.2u...  active      1  sackd              latest/edge   38  no
slurmctld           23.11.4-1.2u...  active      1  slurmctld          latest/edge  120  no       primary - UP
tutorial-partition  23.11.4-1.2u...  active      2  slurmd             latest/edge  141  no

Unit                   Workload  Agent  Machine  Public address  Ports          Message
ceph-fs/0*             active    idle   5        10.248.240.129                 Unit is ready
microceph/0*           active    idle   4        10.248.240.102                 (workload) charm is ready
sackd/0*               active    idle   3        10.248.240.49   6818/tcp
  data/0*              active    idle            10.248.240.49                  Mounted filesystem at `/data`
slurmctld/0*           active    idle   0        10.248.240.162  6817,9092/tcp  primary - UP
tutorial-partition/0   active    idle   1        10.248.240.218  6818/tcp
  data/2               active    idle            10.248.240.218                 Mounted filesystem at `/data`
tutorial-partition/1*  active    idle   2        10.248.240.130  6818/tcp
  data/1               active    idle            10.248.240.130                 Mounted filesystem at `/data`

Machine  State    Address         Inst id        Base          AZ                       Message
0        started  10.248.240.162  juju-2586ad-0  ubuntu@24.04  charmed-hpc-tutorial-vm  Running
1        started  10.248.240.218  juju-2586ad-1  ubuntu@24.04  charmed-hpc-tutorial-vm  Running
2        started  10.248.240.130  juju-2586ad-2  ubuntu@24.04  charmed-hpc-tutorial-vm  Running
3        started  10.248.240.49   juju-2586ad-3  ubuntu@24.04  charmed-hpc-tutorial-vm  Running
4        started  10.248.240.102  juju-2586ad-4  ubuntu@24.04  charmed-hpc-tutorial-vm  Running
5        started  10.248.240.129  juju-2586ad-5  ubuntu@24.04  charmed-hpc-tutorial-vm  Running
:::

<!-- Test the file system set up  -->
<!-- Add summary of what the last few steps accomplished and what juju status is showing-->

## Get compute nodes ready for jobs

Now that Slurm and the file system have been successfully deployed, the next step is to set up the compute nodes themselves. The compute nodes must be moved from the `down` state to the `idle` state so that they can start having jobs ran on them.

First, check that the compute nodes are still down, which will show something similar to:

:::{terminal}
:input: juju exec -u sackd/0 -- sinfo
:copy:
PARTITION         AVAIL  TIMELIMIT  NODES  STATE NODELIST
tutorial-parition    up   infinite      2   down juju-e16200-[1-2]
:::

Then, bring up the compute nodes:

:::{code-block} shell
juju run tutorial-partition/0 node-configured
juju run tutorial-partition/1 node-configured
:::

And verify that the `STATE` is now set to `idle`, which should now show:

:::{terminal}
:input: juju exec -u sackd/0 -- sinfo
:copy:
PARTITION         AVAIL  TIMELIMIT  NODES  STATE NODELIST
tutorial-parition    up   infinite      2   idle juju-e16200-[1-2]
:::

<!-- Add summary of what the last few steps accomplished -->

## Run a batch job

In the following steps, we will pull down a small MPI script, compile it, and run it via a batch job.

### Gather files and compile
First ssh into the login node (sackd), move to the `/data` directory, and create and enter your new `/tutorial` directory:

:::{code-block} shell
juju ssh sackd/0
cd /data/
sudo mkdir tutorial
cd tutorial/
:::

Then you'll need to download the [mpi_hello_world.c] and [submit_hello.sh] scripts:

:::{code-block} shell
sudo wget https://raw.githubusercontent.com/charmed-hpc/docs/refs/heads/main/reuse/tutorial/mpi_hello_world.c
sudo wget https://raw.githubusercontent.com/charmed-hpc/docs/refs/heads/main/reuse/tutorial/submit_hello.sh
:::

For quick referencing, the two files are provided in dropdowns here as well.

::::{dropdown} MPI Hello World Script
:::{literalinclude} /reuse/tutorial/mpi_hello_world.c
:caption: [mpi_hello_world.c]
:language: c
:::
::::

::::{dropdown} Submit Hello World Script
:::{literalinclude} /reuse/tutorial/submit_hello.sh
:caption: [submit_hello.sh]
:language: bash
:::
::::

[mpi_hello_world.c]: /reuse/tutorial/mpi_hello_world.c
[submit_hello.sh]: /reuse/tutorial/submit_hello.sh

To compile and run the c file, we'll need to install the openmpi libraries and run the `mpicc` compile command:

:::{code-block} shell
sudo apt install build-essential openmpi-bin libopenmpi-dev
sudo mpicc -o mpi_hello_world mpi_hello_world.c
:::

### Submit batch job
Now that we have the mpi_hello_world executable, we can submit our job to the queue:

:::{code-block} shell
sbatch submit_hello.sh
:::

Once the job is complete, which should be within a few seconds, the output.txt file will look similar to:

:::{code-block} text
:caption: output.txt

Hello world from processor juju-640476-1, rank 0 out of 2 processors
Hello world from processor juju-640476-2, rank 1 out of 2 processors
:::

## Run a container job

The following steps will build a container job using `apptainer` and run the container job on the cluster.

### Build the container

Before you can submit your container workload to your Charmed HPC cluster,
you must build the container so that it can be located by the Slurm workload
scheduler.

First, you'll need to upload your workload's resources to a new `container_example` directory on the login node. Our example workload has two resources that must be uploaded: the _[generate.py]_ script will generate the example data set,
and the _[workload.py]_ script will plot the example data set as a bar graph.

:::{code-block} shell
mkdir container_example
cd container_example
sudo wget https://raw.githubusercontent.com/charmed-hpc/docs/refs/heads/main/reuse/tutorial/generate.py
sudo wget https://raw.githubusercontent.com/charmed-hpc/docs/refs/heads/main/reuse/tutorial/workload.py
:::

::::{dropdown} _[generate.py]_ - Generate example data set
:::{literalinclude} /reuse/tutorial/generate.py
:caption: [generate.py]
:language: python
:linenos:
:::
::::

::::{dropdown} _[workload.py]_ - Plot example data set
:::{literalinclude} /reuse/tutorial/workload.py
:caption: [workload.py]
:language: python
:linenos:
:::
::::

[workload.py]: /reuse/tutorial/workload.py
[generate.py]: /reuse/tutorial/generate.py

### Create the container build recipe

Now, on the login node, use `nano` or your preferred command line text editor to create
the file _workload.def_. This file is the build recipe you will use to build your container:

:::{code-block} shell
nano workload.def
:::

Next, in _workload.def_ define your build recipe:

:::{literalinclude} /reuse/tutorial/workload.def
:caption: workload.def
:::

###  Build the container image using `apptainer`

Now that we have the build recipe file, we'll build the container image:

:::{code-block} shell
apptainer build workload.sif workload.def
:::

### Use the image to run jobs

First, we'll submit a job to the cluster that uses the new  _workload.sif_ image with the _generate.py_ script to generate one million lines in table:

:::{code-block} shell
srun -p tutorial-partition --container /data/tutorial/workload.sif generate --rows 1000000
:::

With the resulting _favorite_lts_mascot.csv_, we can create our batch script:

:::{literalinclude} /reuse/tutorial/submit_apptainer_mascot.sh
:caption: submit_apptainer_mascot.sh
:::

and submit it:

:::{code-block} shell
sbatch submit_apptainer_mascot.sh
:::


<!-- Steps for downloading resulting png to local machine. -->


## Success!