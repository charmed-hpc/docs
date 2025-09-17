(build-first-cluster)=
# Getting started with Charmed HPC

<!-- A tutorial is a practical activity, in which the student learns by doing something meaningful, towards some achievable goal. What the student does is not necessarily what they will learn. -->

<!-- Goal: Get a new potential user familiar with the various tools used for Charmed HPC, and build a basic cluster that feels recognizable by the end. Show how Charmed HPC provides a turn-key cluster smoothly and why its worth using. -->

This tutorial goes through multiple aspects of Charmed HPC, namely building a small Charmed HPC cluster with a shared file system, preparing and submitting a multi-node job to the new batch queue, and building and using a container for a container-based workload. By the end of this tutorial, you will have worked with Multipass, Juju and Charms, Apptainer, and Slurm.

This tutorial expects that you have some familiarity with classic high-performance computing concepts and programs, but does not expect any prior experience with Multipass, Juju, Apptainer, or prior experience launching a Slurm cluster.

<!-- How long should this tutorial take to complete? -->

:::{note}
This tutorial builds a minimal cluster deployment within a virtual machine for learning purposes and should not be used as the basis for a production cluster. For more in-depth steps on how to deploy a fully operational cluster, see [Charmed HPC's How-to guides](#howtos)
:::

## Prerequisites

To successfully complete this tutorial, you will need:


* 8 CPU cores, 20GB RAM, and 40GB storage available
* [Multipass installed](https://canonical.com/multipass/install)
* An active internet connection
* A local copy of [charmed-hpc-tutorial-cloud-init.yml]

[charmed-hpc-tutorial-cloud-init.yml]: /reuse/tutorial/charmed-hpc-tutorial-cloud-init.yml

## Create Multipass VM

Using [charmed-hpc-tutorial-cloud-init.yml], launch a Multipass VM:

:::{terminal}
:user: ubuntu
:host: local
:copy:
:input: multipass launch 24.04 --name charmed-hpc-tutorial-vm --cloud-init charmed-hpc-tutorial-cloud-init.yml --memory 16G --disk 40G --cpus 8
:::

<!-- Rephrase this section -->
The virtual machine launch process should take five minutes or less to complete. The cloud init process creates and configures our lxd machine cloud `localhost` with the `charmed-hpc-controller` juju controller and creates workload and submit scripts for the example jobs.

Upon completion of the launch process, check the status of cloud-init to confirm that all processes completed successfully. First, enter the vm:

:::{terminal}
:user: ubuntu
:host: local
:copy:
:input: multipass shell charmed-hpc-tutorial-vm
:::

Then check `cloud-init status`{l=shell}:

:::{terminal}
:user: ubuntu
:host: charmed-hpc-tutorial-vm
:copy:
:input: cloud-init status --long
status: done
extended_status: done
boot_status_code: enabled-by-genertor
last_update: Thu, 01 Jan 1970 00:03:45 +0000
detail: DataSourceNoCloud [seed=/dev/sr0]
errors: []
recoverable_errors: {}
:::

If the status shows `done` and there are no errors, then you are ready to move on to deploying the cluster charms.

## Deploy Slurm and file system

Next, you will deploy Slurm and the file system. The Slurm components of your deployment will be composed of:
- The Slurm management daemon: `slurmctld`.
- Two Slurm compute daemons: `slurmd`, grouped in a partition named `tutorial-partition`.
- The authentication and credential kiosk daemon: `sackd` to provide the login node.

First, create the `slurm` model on our cloud `localhost`:

:::{terminal}
:user: ubuntu
:host: charmed-hpc-tutorial-vm
:copy:
:input: juju add-model slurm localhost
:::

Then deploy the Slurm components:

:::{terminal}
:user: ubuntu
:host: charmed-hpc-tutorial-vm
:copy:
:input: juju deploy slurmctld --base "ubuntu@24.04" --channel "edge" --constraints="virt-type=virtual-machine"

:input: juju deploy slurmd tutorial-partition -n 2 --base "ubuntu@24.04" --channel "edge" --constraints="virt-type=virtual-machine"
:input: juju deploy sackd --base "ubuntu@24.04" --channel "edge" --constraints="virt-type=virtual-machine"
:::

<!-- Note about use of --constraints="virt-type=virtual-machine" ? -->

Next, deploy the filesystem pieces to create a MicroCeph shared file system:

<!-- "Composed of" - similar to what's shown above for the slurm pieces -->

:::{terminal}
:user: ubuntu
:host: charmed-hpc-tutorial-vm
:copy:
:input: juju deploy microceph --channel latest/edge --constraints="virt-type=virtual-machine mem=4G root-disk=20G"

:input: juju deploy ceph-fs --channel latest/edge
:input: juju deploy filesystem-client data --channel latest/edge --config mountpoint=/data
:input: juju add-storage microceph/0 osd-standalone=loop,2G,3
:::

After verifying that the plan is correct, run the following set of commands to deploy Slurm
using Terraform and the Juju provider:

<!-- Within a specific directory? Any other precautions or notes necessary here for someone who has never used Terraform? -->

:::{terminal}
:user: ubuntu
:host: charmed-hpc-tutorial-vm
:copy:
:input: juju integrate slurmctld sackd

:input: juju integrate slurmctld tutorial-partition
:input: juju integrate data ceph-fs
:input: juju integrate ceph-fs microceph
:input: juju integrate data:juju-info tutorial-partition:juju-info
:input: juju integrate sackd data
:::

<!-- What will the terminal look like after the prior command? Will there be any on-screen logging happening? -->

After a few minutes, the Slurm deployment will become active. The output of the
`juju status`{l=shell} command should be similar to the following:

:::{terminal}
:user: ubuntu
:host: charmed-hpc-tutorial-vm
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

The `juju status` command shows 
<!-- Add summary of what the last few steps accomplished and what juju status is showing-->

## Get compute nodes ready for jobs

Now that Slurm and the file system have been successfully deployed, the next step is to set up the compute nodes themselves. The compute nodes must be moved from the `down` state to the `idle` state so that they can start having jobs ran on them. First, check that the compute nodes are still down, which will show something similar to:

:::{terminal}
:input: juju exec -u sackd/0 -- sinfo
:copy:
PARTITION         AVAIL  TIMELIMIT  NODES  STATE NODELIST
tutorial-partition    up   infinite      2   down juju-e16200-[1-2]
:::

Then, bring up the compute nodes:

:::{terminal}
:user: ubuntu
:host: charmed-hpc-tutorial-vm
:copy:
:input: juju run tutorial-partition/0 node-configured

:input: juju run tutorial-partition/1 node-configured
:::

And verify that the `STATE` is now set to `idle`, which should now show:

:::{terminal}
:user: ubuntu
:host: charmed-hpc-tutorial-vm
:copy:
:input: juju exec -u sackd/0 -- sinfo
PARTITION         AVAIL  TIMELIMIT  NODES  STATE NODELIST
tutorial-parition    up   infinite      2   idle juju-e16200-[1-2]
:::

<!-- Add summary of what the last few steps accomplished -->

## Copy files onto cluster

The workload files that were created during the cloud initialization step now need to be copied onto the cluster file system from the vm file system:

:::{terminal}
:user: ubuntu
:host: charmed-hpc-tutorial-vm
:copy:
:input: juju scp workload.py sackd/0:/home/ubuntu

:input: juju scp workload.def sackd/0:/home/ubuntu
:input: juju scp submit_hello.sh sackd/0:/home/ubuntu
:input: juju scp mpi_hello_world.c sackd/0:/home/ubuntu
:input: juju scp generate.py sackd/0:/home/ubuntu
:input: juju scp submit_apptainer_mascot.sh sackd/0:/home/ubuntu
:::

## Run a batch job

In the following steps, you will compile a small Hello World MPI script and run it via a batch job.

### Gather files and compile
First ssh into the login node (sackd): 

:::{terminal}
:user: ubuntu
:host: charmed-hpc-tutorial-vm
:copy:
:input: juju ssh sackd/0

:::

This will place you in your home directory `/home/ubuntu`. Next, you will need to compile the _mpi_hello_world.c_ file, which requires first installing the Open MPI libraries and then running the `mpicc` compile command:

:::{terminal}
:user: ubuntu
:host: login
:copy:
:input: sudo apt install build-essential openmpi-bin libopenmpi-dev

:input: mpicc -o mpi_hello_world mpi_hello_world.c
:::

From here you will move to the `/data` directory, and create and enter your new `/mpi_example` directory with appropriate user permissions:

:::{terminal}
:user: ubuntu
:host: login
:copy:
:input: cd /data/

:input: sudo mkdir mpi_example
:input: sudo chown $USER: mpi_example/
:input: cd mpi_example/
:::

The `/data` directory is mounted on the compute nodes and will be used to read and write from during the batch job. Next, copy the newly created _mpi_hello_world_ executable and the _submit_hello.sh_ batch script to the `mpi_example/` directory:

:::{terminal}
:user: ubuntu
:host: login
:copy:
:input: cp /home/ubuntu/mpi_hello_world .

:input: cp /home/ubuntu/submit_hello.sh .
:::

For quick referencing, the two files are provided in dropdowns here as well.

::::{dropdown} mpi_hello_world.c
:::{literalinclude} /reuse/tutorial/mpi_hello_world.c
:caption: [mpi_hello_world.c]
:language: c
:::
::::

::::{dropdown} submit_hello.sh
:::{literalinclude} /reuse/tutorial/submit_hello.sh
:caption: [submit_hello.sh]
:language: bash
:::
::::

[mpi_hello_world.c]: /reuse/tutorial/mpi_hello_world.c
[submit_hello.sh]: /reuse/tutorial/submit_hello.sh

### Submit batch job
You can now submit your batch job to the queue:

:::{terminal}
:user: ubuntu
:host: login
:copy:
:input: sbatch submit_hello.sh
:::

Once the job is complete, which should be within a few seconds, the output.txt file will look similar to:

:::{code-block} text
:caption: output.txt

Hello world from processor juju-640476-1, rank 0 out of 2 processors
Hello world from processor juju-640476-2, rank 1 out of 2 processors
:::

The batch job successfully spread the MPI job across two nodes that were able to report back their MPI rank to a common output file.

## Run a container job

Next you will go through the steps to set up Apptainer, build a container job and run the job on the cluster.

### Set up Apptainer

Apptainer must deployed and integrated with the Slurm deployment via Juju. These steps must be completed from `charmed-hpc-tutorial-vm` environment; to return to that environment from within `sackd/0`, simply type `exit`{l=shell} and return.

To deploy and integrate Apptainer:

:::{terminal}
:user: ubuntu
:host: charmed-hpc-tutorial-vm
:copy:
:input: juju deploy apptainer

:input: juju integrate apptainer tutorial-partition
:input: juju integrate apptainer sackd
:input: juju integrate apptainer slurmctld
:::

After a few minutes, `juju status` should look similar to the following:

:::{terminal}
:user: ubuntu
:host: charmed-hpc-tutorial-vm
:copy:
:input: juju status

Model  Controller              Cloud/Region         Version  SLA          Timestamp
slurm  charmed-hpc-controller  localhost/localhost  3.6.9    unsupported  17:34:46-04:00

App                 Version          Status  Scale  Charm              Channel        Rev  Exposed  Message
apptainer           1.4.2            active      3  apptainer          latest/stable    6  no       
ceph-fs             19.2.1           active      1  ceph-fs            latest/edge    196  no       Unit is ready
data                                 active      3  filesystem-client  latest/edge     20  no       Integrated with `cephfs` provider
microceph                            active      1  microceph          latest/edge    161  no       (workload) charm is ready
sackd               23.11.4-1.2u...  active      1  sackd              latest/edge     38  no       
slurmctld           23.11.4-1.2u...  active      1  slurmctld          latest/edge    120  no       primary - UP
tutorial-partition  23.11.4-1.2u...  active      2  slurmd             latest/edge    141  no       

Unit                   Workload  Agent  Machine  Public address  Ports          Message
ceph-fs/0*             active    idle   5        10.196.78.232                  Unit is ready
microceph/1*           active    idle   6        10.196.78.238                  (workload) charm is ready
sackd/0*               active    idle   3        10.196.78.117   6818/tcp       
  apptainer/2          active    idle            10.196.78.117                  
  data/2               active    idle            10.196.78.117                  Mounted filesystem at `/data`
slurmctld/0*           active    idle   0        10.196.78.49    6817,9092/tcp  primary - UP
tutorial-partition/0   active    idle   1        10.196.78.244   6818/tcp       
  apptainer/0          active    idle            10.196.78.244                  
  data/0*              active    idle            10.196.78.244                  Mounted filesystem at `/data`
tutorial-partition/1*  active    idle   2        10.196.78.26    6818/tcp       
  apptainer/1*         active    idle            10.196.78.26                   
  data/1               active    idle            10.196.78.26                   Mounted filesystem at `/data`

Machine  State    Address        Inst id        Base          AZ                       Message
0        started  10.196.78.49   juju-808105-0  ubuntu@24.04  charmed-hpc-tutorial-vm  Running
1        started  10.196.78.244  juju-808105-1  ubuntu@24.04  charmed-hpc-tutorial-vm  Running
2        started  10.196.78.26   juju-808105-2  ubuntu@24.04  charmed-hpc-tutorial-vm  Running
3        started  10.196.78.117  juju-808105-3  ubuntu@24.04  charmed-hpc-tutorial-vm  Running
5        started  10.196.78.232  juju-808105-5  ubuntu@24.04  charmed-hpc-tutorial-vm  Running
6        started  10.196.78.238  juju-808105-6  ubuntu@24.04  charmed-hpc-tutorial-vm  Running
:::

### Build the container image using `apptainer`

Before you can submit your container workload to your Charmed HPC cluster,
you must build the container image and move it so that it can be located by the Slurm workload scheduler. The build recipe file _workload.def_ defines what will be in the container image. To build the image:

:::{terminal}
:user: ubuntu
:host: login
:copy:
:input: juju ssh sackd/0

:input: apptainer build workload.sif workload.def
:::

Once the image is complete, copy it and the submit to a new `apptainer_example` directory on `/data`:

:::{terminal}
:user: ubuntu
:host: login
:copy:
:input: cd /data/

:input: sudo mkdir apptainer_example
:input: sudo chown $USER: apptainer_example
:input: cd apptainer_example
:input: cp /home/ubuntu/workload.sif .
:input: cp /home/ubuntu/submit_apptainer_mascot.sh .
:::
<!-- Description of what the image will contain? -->

The workload files are provided here for reference.

::::{dropdown} generate.py
:::{literalinclude} /reuse/tutorial/generate.py
:caption: [generate.py]
:language: python
:linenos:
:::
::::

::::{dropdown} workload.py
:::{literalinclude} /reuse/tutorial/workload.py
:caption: [workload.py]
:language: python
:linenos:
:::
::::

::::{dropdown} workload.def
:::{literalinclude} /reuse/tutorial/workload.def
:caption: [workload.def]
:::
::::

::::{dropdown} submit_apptainer_mascot.sh
:::{literalinclude} /reuse/tutorial/submit_apptainer_mascot.sh
:caption: [submit_apptainer_mascot.sh]
:::
::::

[workload.py]: /reuse/tutorial/workload.py
[generate.py]: /reuse/tutorial/generate.py
[workload.def]: /reuse/tutorial/workload.def
[submit_apptainer_mascot.sh]: /reuse/tutorial/submit_apptainer_mascot.sh



### Use the image to run jobs

Now that you have the container image, you can submit a job to the cluster that uses the new  _workload.sif_ image to generate one million lines in a table:

:::{terminal}
:user: ubuntu
:host: login
:copy:
:input: srun -p tutorial-partition --container /data/apptainer_example/workload.sif generate --rows 1000000
:::

With the resulting _favorite_lts_mascot.csv_, you can now submit the batch job to build the bar plot:

:::{terminal}
:user: ubuntu
:host: login
:copy:
:input: sbatch submit_apptainer_mascot.sh
:::


<!-- Steps for downloading resulting png to local machine. -->


## Success!

