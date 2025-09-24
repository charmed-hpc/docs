(tutorial-getting-started-with-charmed-hpc)=
# Getting started with Charmed HPC

<!-- A tutorial is a practical activity, in which the student learns by doing something meaningful, towards some achievable goal. What the student does is not necessarily what they will learn. -->

<!-- Goal: Get a new potential user familiar with the various tools used for Charmed HPC, and build a basic cluster that feels recognizable by the end. Show how Charmed HPC provides a turn-key cluster smoothly and why its worth using. -->

This tutorial takes you through multiple aspects of Charmed HPC, such as:

* Building a small Charmed HPC cluster inside a virtual machine on LXD
* Preparing and submitting a multi-node batch job to your Charmed HPC cluster's workload scheduler
* Creating and using a container image to provide the runtime environment for a submitted batch job

By the end of this tutorial, you will have worked with several open source projects such as:

* Multipass
* Juju
* Charms
* Apptainer
* Ceph
* Slurm

This tutorial assumes that you have had some exposure to high-performance computing concepts such as batch scheduling, but does not assume prior experience building HPC clusters. This tutorial also does not expect you to have any prior experience with Multipass, Juju, Apptainer, Ceph, or Slurm.

<!-- How long should this tutorial take to complete? -->

:::{admonition} Using Charmed HPC in production
:class: note
The Charmed HPC cluster built in this tutorial is for learning purposes and should not be used as the basis for a production HPC cluster. For more in-depth steps on how to deploy a fully operational Charmed HPC cluster, see [Charmed HPC's How-to guides](#howtos)
:::

## Prerequisites

To successfully complete this tutorial, you will need:


* 8 CPU cores, 20GB RAM, and 40GB storage available
* [Multipass installed](https://canonical.com/multipass/install)
* An active internet connection



## Create a virtual machine with Multipass

First, download a copy of the cloud initialization (cloud-init) file, [charmed-hpc-tutorial-cloud-init.yml], that defines the underlying cloud infrastructure for the virtual machine. Here, that will include creating and configuring your LXD machine cloud `localhost` with the `charmed-hpc-controller` Juju controller and creating workload and submit scripts for the example jobs. You can expand the dropdown below to view the full cloud-init file before downloading onto your local system:

::::{dropdown} charmed-hpc-tutorial-cloud-init.yml
:::{literalinclude} /reuse/tutorial/charmed-hpc-tutorial-cloud-init.yml 
:caption: [charmed-hpc-tutorial-cloud-init.yml]
:language: yaml
:linenos:
:::
::::


Then, from the local directory holding the cloud-init file, launch a virtual machine using Multipass:

[charmed-hpc-tutorial-cloud-init.yml]: /reuse/tutorial/charmed-hpc-tutorial-cloud-init.yml

:::{terminal}
:user: ubuntu
:host: local
:copy:
:input: multipass launch 24.04 --name charmed-hpc-tutorial --cloud-init charmed-hpc-tutorial-cloud-init.yml --memory 16G --disk 40G --cpus 8
:::

The virtual machine launch process should take five minutes or less to complete. Upon completion of the launch process, check the status of cloud-init to confirm that all processes completed successfully. First, enter the virtual machine:

:::{terminal}
:user: ubuntu
:host: local
:copy:
:input: multipass shell charmed-hpc-tutorial
:::

Then check `cloud-init status`{l=shell}:

:::{terminal}
:user: ubuntu
:host: charmed-hpc-tutorial
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

## Deploy Slurm and shared filesystem
Next, you will deploy Slurm and the file system. The Slurm components of your deployment will be composed of:
- The Slurm management daemon: `slurmctld`.
- Two Slurm compute daemons: `slurmd`, grouped in a partition named `tutorial-partition`.
- The authentication and credential kiosk daemon: `sackd` to provide the login node.

First, create the `slurm` model on your cloud `localhost`:

:::{terminal}
:user: ubuntu
:host: charmed-hpc-tutorial
:copy:
:input: juju add-model slurm localhost
:::

Then deploy the Slurm components:

:::{terminal}
:user: ubuntu
:host: charmed-hpc-tutorial
:copy:
:input: juju deploy slurmctld --base "ubuntu@24.04" --channel "edge" --constraints="virt-type=virtual-machine"

:input: juju deploy slurmd tutorial-partition -n 2 --base "ubuntu@24.04" --channel "edge" --constraints="virt-type=virtual-machine"
:input: juju deploy sackd --base "ubuntu@24.04" --channel "edge" --constraints="virt-type=virtual-machine"
:::

And integrate them together:

:::{terminal}
:user: ubuntu
:host: charmed-hpc-tutorial
:copy:
:input: juju integrate slurmctld sackd

:input: juju integrate slurmctld tutorial-partition
:::

<!-- Note about use of --constraints="virt-type=virtual-machine" ? -->

Next, you will deploy the file system pieces, which are:

- `microceph` for our distributed storage system
- `ceph-fs` to expose the MicroCeph cluster as a shared file system using [CephFS](https://docs.ceph.com/en/reef/cephfs/)
- `filesystem-client` to mount the file system 

:::{terminal}
:user: ubuntu
:host: charmed-hpc-tutorial
:copy:
:input: juju deploy microceph --channel latest/edge --constraints="virt-type=virtual-machine mem=4G root-disk=20G"

:input: juju deploy ceph-fs --channel latest/edge
:input: juju deploy filesystem-client scratch --channel latest/edge --config mountpoint=/scratch
:input: juju add-storage microceph/0 osd-standalone=loop,2G,3
:::

And then integrate the filesystem components together: 

:::{terminal}
:user: ubuntu
:host: charmed-hpc-tutorial
:copy:
:input: juju integrate scratch ceph-fs

:input: juju integrate ceph-fs microceph
:input: juju integrate scratch tutorial-partition
:input: juju integrate sackd scratch
:::

<!-- What will the terminal look like after the prior command? Will there be any on-screen logging happening? -->

After a few minutes, the Slurm deployment will become active. The output of the
`juju status`{l=shell} command should be similar to the following:

:::{terminal}
:user: ubuntu
:host: charmed-hpc-tutorial
:input: juju status
:copy:
Model  Controller              Cloud/Region         Version  SLA          Timestamp
slurm  charmed-hpc-controller  localhost/localhost  3.6.9    unsupported  10:53:50-04:00

App                 Version          Status  Scale  Charm              Channel      Rev  Exposed  Message
ceph-fs             19.2.1           active      1  ceph-fs            latest/edge  196  no       Unit is ready
scratch                                 active      3  filesystem-client  latest/edge   20  no       Integrated with `cephfs` provider
microceph                            active      1  microceph          latest/edge  159  no       (workload) charm is ready
sackd               23.11.4-1.2u...  active      1  sackd              latest/edge   38  no
slurmctld           23.11.4-1.2u...  active      1  slurmctld          latest/edge  120  no       primary - UP
tutorial-partition  23.11.4-1.2u...  active      2  slurmd             latest/edge  141  no

Unit                   Workload  Agent  Machine  Public address  Ports          Message
ceph-fs/0*             active    idle   5        10.248.240.129                 Unit is ready
microceph/0*           active    idle   4        10.248.240.102                 (workload) charm is ready
sackd/0*               active    idle   3        10.248.240.49   6818/tcp
  scratch/0*              active    idle            10.248.240.49                  Mounted filesystem at `/scratch`
slurmctld/0*           active    idle   0        10.248.240.162  6817,9092/tcp  primary - UP
tutorial-partition/0   active    idle   1        10.248.240.218  6818/tcp
  scratch/2               active    idle            10.248.240.218                 Mounted filesystem at `/scratch`
tutorial-partition/1*  active    idle   2        10.248.240.130  6818/tcp
  scratch/1               active    idle            10.248.240.130                 Mounted filesystem at `/scratch`

Machine  State    Address         Inst id        Base          AZ                       Message
0        started  10.248.240.162  juju-2586ad-0  ubuntu@24.04  charmed-hpc-tutorial  Running
1        started  10.248.240.218  juju-2586ad-1  ubuntu@24.04  charmed-hpc-tutorial  Running
2        started  10.248.240.130  juju-2586ad-2  ubuntu@24.04  charmed-hpc-tutorial  Running
3        started  10.248.240.49   juju-2586ad-3  ubuntu@24.04  charmed-hpc-tutorial  Running
4        started  10.248.240.102  juju-2586ad-4  ubuntu@24.04  charmed-hpc-tutorial  Running
5        started  10.248.240.129  juju-2586ad-5  ubuntu@24.04  charmed-hpc-tutorial  Running
:::

<!-- Test the file system set up  -->

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
:host: charmed-hpc-tutorial
:copy:
:input: juju run tutorial-partition/0 node-configured

:input: juju run tutorial-partition/1 node-configured
:::

And verify that the `STATE` is now set to `idle`, which should now show:

:::{terminal}
:user: ubuntu
:host: charmed-hpc-tutorial
:copy:
:input: juju exec -u sackd/0 -- sinfo
PARTITION         AVAIL  TIMELIMIT  NODES  STATE NODELIST
tutorial-parition    up   infinite      2   idle juju-e16200-[1-2]
:::

<!-- Add summary of what the last few steps accomplished -->

## Copy files onto cluster

The workload files that were created during the cloud initialization step now need to be copied onto the cluster file system from the virtual machine filesystem:

:::{terminal}
:user: ubuntu
:host: charmed-hpc-tutorial
:copy:
:input: juju scp workload.py sackd/0:/home/ubuntu

:input: juju scp workload.def sackd/0:/home/ubuntu
:input: juju scp submit_hello.sh sackd/0:/home/ubuntu
:input: juju scp mpi_hello_world.c sackd/0:/home/ubuntu
:input: juju scp generate.py sackd/0:/home/ubuntu
:input: juju scp submit_apptainer_mascot.sh sackd/0:/home/ubuntu
:::

## Run a batch job

In the following steps, you will compile a small Hello World MPI script and run it by submitting a batch job to Slurm.

### Gather files and compile
First, SSH into the login node, `sackd/0`: 

:::{terminal}
:user: ubuntu
:host: charmed-hpc-tutorial
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

From here you will move to the `/scratch` directory, and create and enter your new `/mpi_example` directory with appropriate user permissions:

:::{terminal}
:user: ubuntu
:host: login
:copy:
:input: cd /scratch/

:input: sudo mkdir mpi_example
:input: sudo chown $USER: mpi_example/
:input: cd mpi_example/
:::

The `/scratch` directory is mounted on the compute nodes and will be used to read and write from during the batch job. Next, copy the newly created _mpi_hello_world_ executable and the _submit_hello.sh_ batch script to the `mpi_example/` directory:

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
Now, submit your batch job to the queue using `sbatch`{l=shell}:

:::{terminal}
:user: ubuntu
:host: login
:copy:
:input: sbatch submit_hello.sh
:::

You job will complete after a few seconds. The generated _output.txt_ file will look similar to the following:

:::{terminal}
:user: ubuntu 
:host: login
:copy:
:input: cat output.txt

Hello world from processor juju-640476-1, rank 0 out of 2 processors
Hello world from processor juju-640476-2, rank 1 out of 2 processors
:::

The batch job successfully spread the MPI job across two nodes that were able to report back their MPI rank to a shared output file.

## Run a container job

Next you will go through the steps to set up Apptainer, build a container job and run the job on the cluster.

### Set up Apptainer

Apptainer must deployed and integrated with the existing Slurm deployment using Juju. These steps must be completed from `charmed-hpc-tutorial` environment; to return to that environment from within `sackd/0`, use the `exit`{l=shell} command.

To deploy and integrate Apptainer:

:::{terminal}
:user: ubuntu
:host: charmed-hpc-tutorial
:copy:
:input: juju deploy apptainer

:input: juju integrate apptainer tutorial-partition
:input: juju integrate apptainer sackd
:input: juju integrate apptainer slurmctld
:::

After a few minutes, `juju status` should look similar to the following:

:::{terminal}
:user: ubuntu
:host: charmed-hpc-tutorial
:copy:
:input: juju status

Model  Controller              Cloud/Region         Version  SLA          Timestamp
slurm  charmed-hpc-controller  localhost/localhost  3.6.9    unsupported  17:34:46-04:00

App                 Version          Status  Scale  Charm              Channel        Rev  Exposed  Message
apptainer           1.4.2            active      3  apptainer          latest/stable    6  no       
ceph-fs             19.2.1           active      1  ceph-fs            latest/edge    196  no       Unit is ready
scratch                                 active      3  filesystem-client  latest/edge     20  no       Integrated with `cephfs` provider
microceph                            active      1  microceph          latest/edge    161  no       (workload) charm is ready
sackd               23.11.4-1.2u...  active      1  sackd              latest/edge     38  no       
slurmctld           23.11.4-1.2u...  active      1  slurmctld          latest/edge    120  no       primary - UP
tutorial-partition  23.11.4-1.2u...  active      2  slurmd             latest/edge    141  no       

Unit                   Workload  Agent  Machine  Public address  Ports          Message
ceph-fs/0*             active    idle   5        10.196.78.232                  Unit is ready
microceph/1*           active    idle   6        10.196.78.238                  (workload) charm is ready
sackd/0*               active    idle   3        10.196.78.117   6818/tcp       
  apptainer/2          active    idle            10.196.78.117                  
  scratch/2               active    idle            10.196.78.117                  Mounted filesystem at `/scratch`
slurmctld/0*           active    idle   0        10.196.78.49    6817,9092/tcp  primary - UP
tutorial-partition/0   active    idle   1        10.196.78.244   6818/tcp       
  apptainer/0          active    idle            10.196.78.244                  
  scratch/0*              active    idle            10.196.78.244                  Mounted filesystem at `/scratch`
tutorial-partition/1*  active    idle   2        10.196.78.26    6818/tcp       
  apptainer/1*         active    idle            10.196.78.26                   
  scratch/1               active    idle            10.196.78.26                   Mounted filesystem at `/scratch`

Machine  State    Address        Inst id        Base          AZ                       Message
0        started  10.196.78.49   juju-808105-0  ubuntu@24.04  charmed-hpc-tutorial  Running
1        started  10.196.78.244  juju-808105-1  ubuntu@24.04  charmed-hpc-tutorial  Running
2        started  10.196.78.26   juju-808105-2  ubuntu@24.04  charmed-hpc-tutorial  Running
3        started  10.196.78.117  juju-808105-3  ubuntu@24.04  charmed-hpc-tutorial  Running
5        started  10.196.78.232  juju-808105-5  ubuntu@24.04  charmed-hpc-tutorial  Running
6        started  10.196.78.238  juju-808105-6  ubuntu@24.04  charmed-hpc-tutorial  Running
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

Once the image is complete, copy it and the submit script to a new `apptainer_example` directory on `/scratch`:

:::{terminal}
:user: ubuntu
:host: login
:copy:
:input: cd /scratch/

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

Now that you have built the container image, you can submit a job to the cluster that uses the new  _workload.sif_ image to generate one million lines in a table and then uses the resulting _favorite_lts_mascot.csv_ to build the bar plot:

:::{terminal}
:user: ubuntu
:host: login
:copy:
:input: sbatch submit_apptainer_mascot.sh
:::

To view the status of the job while it is running, run `squeue`.

Once the job has completed, view the generated bar plot:

:::{terminal}
:user: ubuntu
:host: login
:copy:
:input: cat graph.out

:::


## Summary

Is this tutorial, you:

  * Created a Multipass VM and lxd cloud
  * Deployed and integrated Slurm and a shared file system
  * Launched an MPI batch job and saw cross-node communicated results
  * Build a container image with Apptainer and used it to run a batch job and generate a bar plot

## Next Steps

Now that you have gotten started with Charmed HPC, check out the {ref}`explanation` section for details on important concepts and the {ref}`howtos` for how to use more of Charmed HPC's features. 
