(tutorial-getting-started-with-charmed-hpc)=
# Getting started with Charmed HPC

This tutorial takes you through multiple aspects of Charmed HPC, such as:

* Building a small Charmed HPC cluster with a shared filesystem
* Preparing and submitting a multi-node batch job to your Charmed HPC cluster's workload scheduler
* Creating and using a container image to provide the runtime environment for a submitted batch job

By the end of this tutorial, you will have worked with a variety of open source projects, such as:

* Multipass
* Juju
* Charms
* Apptainer
* Ceph
* Slurm

This tutorial assumes that you have had some exposure to high-performance computing concepts such as batch scheduling, but does not assume prior experience building HPC clusters. This tutorial also does not expect you to have any prior experience with the listed projects.

<!-- How long should this tutorial take to complete? -->

:::{admonition} Using Charmed HPC in production
:class: note
The Charmed HPC cluster built in this tutorial is for learning purposes and should not be used as the basis for a production HPC cluster. For more in-depth steps on how to deploy a fully operational Charmed HPC cluster, see [Charmed HPC's How-to guides](#howtos).
:::

## Prerequisites

To successfully complete this tutorial, you will need:

* At least 8 CPU cores, 16GB RAM, and 40GB storage available
* [Multipass installed](https://canonical.com/multipass/install)
* An active internet connection

## Create a virtual machine with Multipass

First, download a copy of the cloud initialization (cloud-init) file, [charmed-hpc-tutorial-cloud-init.yml], that defines the underlying cloud infrastructure for the virtual machine. 

For this tutorial, the file includes instructions for creating and configuring your LXD machine cloud `localhost` with the `charmed-hpc-controller` Juju controller and creating workload and submit scripts for the example jobs. The cloud-init step will be completed as part of the virtual machine launch and will not be something you need to set up manually. You can expand the dropdown below to view the full cloud-init file before downloading onto your local system:

::::{dropdown} charmed-hpc-tutorial-cloud-init.yml
:::{literalinclude} /reuse/tutorial/charmed-hpc-tutorial-cloud-init.yml 
:caption: [charmed-hpc-tutorial-cloud-init.yml]
:language: yaml
:linenos:
:::
::::

From the local directory holding the cloud-init file, launch a virtual machine using Multipass:

[charmed-hpc-tutorial-cloud-init.yml]: /reuse/tutorial/charmed-hpc-tutorial-cloud-init.yml

:::{terminal}
:user: ubuntu
:host: local
:copy:
:input: multipass launch 24.04 --name charmed-hpc-tutorial --cloud-init charmed-hpc-tutorial-cloud-init.yml --memory 16G --disk 40G --cpus 8 --timeout 1000
:::

The virtual machine launch process should take five minutes or less to complete, but may take longer due to network strength. Upon completion of the launch process, check the status of cloud-init to confirm that all processes completed successfully.

Enter the virtual machine:

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
boot_status_code: enabled-by-generator
last_update: Thu, 01 Jan 1970 00:03:45 +0000
detail: DataSourceNoCloud [seed=/dev/sr0]
errors: []
recoverable_errors: {}
:::

If the status shows `done` and there are no errors, then you are ready to move on to deploying the cluster charms.

## Deploy Slurm and shared filesystem
Next, you will deploy Slurm and the filesystem. The Slurm components of your deployment will be composed of:
* The Slurm management daemon: `slurmctld`
* Two Slurm compute daemons: `slurmd`, grouped in a partition named `tutorial-partition`
* The authentication and credential kiosk daemon: `sackd` to provide the login node

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

Next, you will deploy the filesystem pieces, which are:

- `microceph`, the distributed storage system
- `ceph-fs` to expose the MicroCeph cluster as a shared filesystem using [CephFS](https://docs.ceph.com/en/reef/cephfs/)
- `filesystem-client` to mount the filesystem, named `scratch` 

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
scratch                              active      3  filesystem-client  latest/edge   20  no       Integrated with `cephfs` provider
microceph                            active      1  microceph          latest/edge  159  no       (workload) charm is ready
sackd               23.11.4-1.2u...  active      1  sackd              latest/edge   38  no
slurmctld           23.11.4-1.2u...  active      1  slurmctld          latest/edge  120  no       primary - UP
tutorial-partition  23.11.4-1.2u...  active      2  slurmd             latest/edge  141  no

Unit                   Workload  Agent  Machine  Public address  Ports          Message
ceph-fs/0*             active    idle   5        10.248.240.129                 Unit is ready
microceph/0*           active    idle   4        10.248.240.102                 (workload) charm is ready
sackd/0*               active    idle   3        10.248.240.49   6818/tcp
  scratch/0*           active    idle            10.248.240.49                  Mounted filesystem at `/scratch`
slurmctld/0*           active    idle   0        10.248.240.162  6817,9092/tcp  primary - UP
tutorial-partition/0   active    idle   1        10.248.240.218  6818/tcp
  scratch/2            active    idle            10.248.240.218                 Mounted filesystem at `/scratch`
tutorial-partition/1*  active    idle   2        10.248.240.130  6818/tcp
  scratch/1            active    idle            10.248.240.130                 Mounted filesystem at `/scratch`

Machine  State    Address         Inst id        Base          AZ                       Message
0        started  10.248.240.162  juju-2586ad-0  ubuntu@24.04  charmed-hpc-tutorial  Running
1        started  10.248.240.218  juju-2586ad-1  ubuntu@24.04  charmed-hpc-tutorial  Running
2        started  10.248.240.130  juju-2586ad-2  ubuntu@24.04  charmed-hpc-tutorial  Running
3        started  10.248.240.49   juju-2586ad-3  ubuntu@24.04  charmed-hpc-tutorial  Running
4        started  10.248.240.102  juju-2586ad-4  ubuntu@24.04  charmed-hpc-tutorial  Running
5        started  10.248.240.129  juju-2586ad-5  ubuntu@24.04  charmed-hpc-tutorial  Running
:::


<!-- Add summary of what the last few steps accomplished and what juju status is showing-->

## Get compute nodes ready for jobs

Now that Slurm and the filesystem have been successfully deployed, the next step is to set up the compute nodes themselves. The compute nodes must be moved from the `down` state to the `idle` state so that they can start having jobs ran on them. First, check that the compute nodes are still down, which will show something similar to:

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
tutorial-partition    up   infinite      2   idle juju-e16200-[1-2]
:::

<!-- Add summary of what the last few steps accomplished -->

## Copy files onto cluster

The workload files that were created during the cloud initialization step now need to be copied onto the cluster filesystem from the virtual machine filesystem. First you will make the new example directories, then set appropriate permissions, and finally copy the files over:

:::{terminal}
:user: ubuntu
:host: charmed-hpc-tutorial
:copy:
:input: juju exec -u sackd/0 -- sudo mkdir /scratch/mpi_example /scratch/apptainer_example

:input: juju exec -u sackd/0 -- sudo chown $USER: /scratch/*
:input: juju scp submit_hello.sh mpi_hello_world.c sackd/0:/scratch/mpi_example
:input: juju scp submit_apptainer_mascot.sh generate.py workload.py workload.def sackd/0:/scratch/apptainer_example
:::

The `/scratch` directory is mounted on the compute nodes and will be used to read and write from during the batch jobs.

## Run a batch job

In the following steps, you will compile a small Hello World MPI script and run it by submitting a batch job to Slurm.

### Compile

First, SSH into the login node, `sackd/0`:

:::{terminal}
:user: ubuntu
:host: charmed-hpc-tutorial
:copy:
:input: juju ssh sackd/0

:::

This will place you in your home directory `/home/ubuntu`. Next, you will need to move to the `/scratch/mpi_example` directory, install the Open MPI libraries needed for compiling, and then compile the _mpi_hello_world.c_ file by running the `mpicc` command:

:::{terminal}
:user: ubuntu
:host: login
:copy:
:input: cd /scratch/mpi_example

:input: sudo apt install build-essential openmpi-bin libopenmpi-dev
:input: mpicc -o mpi_hello_world mpi_hello_world.c
:::

For quick referencing, the two files for the MPI Hello World example are provided in dropdowns here:

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

Your job will complete after a few seconds. The generated _output.txt_ file will look similar to the following:

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

Next you will go through the steps to generate a random sample of Ubuntu mascot votes and plot the results. The process requires Python and a few specific libraries so you will use Apptainer to build a container job and run the job on the cluster.

### Set up Apptainer

Apptainer must be deployed and integrated with the existing Slurm deployment using Juju and these steps need to be completed from the `charmed-hpc-tutorial` environment; to return to that environment from within `sackd/0`, use the `exit`{l=shell} command.

Deploy and integrate Apptainer:

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
scratch                              active      3  filesystem-client  latest/edge     20  no       Integrated with `cephfs` provider
microceph                            active      1  microceph          latest/edge    161  no       (workload) charm is ready
sackd               23.11.4-1.2u...  active      1  sackd              latest/edge     38  no       
slurmctld           23.11.4-1.2u...  active      1  slurmctld          latest/edge    120  no       primary - UP
tutorial-partition  23.11.4-1.2u...  active      2  slurmd             latest/edge    141  no       

Unit                   Workload  Agent  Machine  Public address  Ports          Message
ceph-fs/0*             active    idle   5        10.196.78.232                  Unit is ready
microceph/1*           active    idle   6        10.196.78.238                  (workload) charm is ready
sackd/0*               active    idle   3        10.196.78.117   6818/tcp       
  apptainer/2          active    idle            10.196.78.117                  
  scratch/2            active    idle            10.196.78.117                  Mounted filesystem at `/scratch`
slurmctld/0*           active    idle   0        10.196.78.49    6817,9092/tcp  primary - UP
tutorial-partition/0   active    idle   1        10.196.78.244   6818/tcp       
  apptainer/0          active    idle            10.196.78.244                  
  scratch/0*           active    idle            10.196.78.244                  Mounted filesystem at `/scratch`
tutorial-partition/1*  active    idle   2        10.196.78.26    6818/tcp       
  apptainer/1*         active    idle            10.196.78.26                   
  scratch/1            active    idle            10.196.78.26                   Mounted filesystem at `/scratch`

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
you must build the container image from the build recipe. The build recipe file _workload.def_ defines the environment and libraries that will be in the container image. 

To build the image, return to the cluster login node, move to the example directory, and call `apptainer build`:

:::{terminal}
:user: ubuntu
:host: login
:copy:
:input: juju ssh sackd/0

:input: cd /scratch/apptainer_example
:input: apptainer build workload.sif workload.def
:::

The files for the Apptainer Mascot Vote example are provided here for reference.

::::{dropdown} generate\.py
:::{literalinclude} /reuse/tutorial/generate.py
:caption: [generate.py]
:language: python
:linenos:
:::
::::

::::{dropdown} workload\.py
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

Once the job has completed, view the generated bar plot that will look similar to the following:

:::{terminal}
:user: ubuntu
:host: login
:copy:
:input: cat graph.out

────────────────────── Favorite LTS mascot ───────────────────────
│Bionic Beaver    ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 101124.00
│Dapper Drake     ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 99889.00
│Focal Fossa      ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 99956.00
│Hardy Heron      ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 99872.00
│Jammy Jellyfish  ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 99848.00
│Lucid Lynx       ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 99651.00
│Noble Numbat     ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 100625.00
│Precise Pangolin ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 99670.00
│Trusty Tahr      ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 99366.00
│Xenial Xerus     ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 99999.00
:::


## Summary and clean up

In this tutorial, you:

* Deployed and integrated Slurm and a shared filesystem
* Launched an MPI batch job and saw cross-node communication results
* Built a container image with Apptainer and used it to run a batch job and generate a bar plot

Now that you have completed the tutorial, if you would like to completely remove the virtual machine, return to your local terminal and `multipass delete` the virtual machine as follows:

:::{terminal}
:user: ubuntu
:host: local
:copy:
:input: multipass delete -p charmed-hpc-tutorial

:::

## Next steps

Now that you have gotten started with Charmed HPC, check out the {ref}`explanation` section for details on important concepts and the {ref}`howtos` for how to use more of Charmed HPC's features. 
