(build-first-cluster)=
# Build your first Charmed HPC cluster

<!-- A tutorial is a practical activity, in which the student learns by doing something meaningful, towards some achievable goal. What the student does is not necessarily what they will learn. -->

<!-- Goal: Get a new potential user familiar with the various tools used for Charmed HPC, and build a basic cluster that feels recognizable by the end. Show how Charmed HPC provides a turn-key cluster smoothly and why its worth using. -->

In this tutorial we will build a small Charmed HPC cluster, deployed a job to the new batch queue, and viewed the job and cluster status metrics. By the end of this tutorial, we will have worked with Multipass, Juju and Charms, Slurm, and the Canonical Observability Stack (COS). 

This tutorial expects that you have some familiarity with classic high-performance computing concepts and programs, but does not expect any prior experience with Juju, Kubernetes, COS, or prior experience launching a Slurm cluster.

<!-- How long should this tutorial take to complete? -->

:::{note}
This tutorial builds a minimal cluster deployment within a virtual machine and should not be used as the basis for a production cluster.
:::

## Prerequisites and dependencies

To successfully complete this tutorial, you will need:

* A computer with:
  * 8 cpus, 20GB RAM, and 40GB storage available
  * Multipass installed 
* A local copy of the cloud-init.yaml

<!-- Warning about using public wifi and multipass launch taking a while and may need the --timeout increase and/or the vm launching successfully even if the timeout error shows up? -->


<!-- Quick commands to test that various cloud init pieces have been set up correctly:

`juju status -m controller` should show...
`juju clouds` should show...
 -->

## Deploy Slurm

Next, we will deploy Slurm as the resource management and job scheduling service. 

first create the `slurm` model that will hold the
deployment:

:::{code-block} shell
juju add-model slurm charmed-hpc
:::

deploy the Slurm
daemons with MySQL as the storage back-end for `slurmdbd`:

:::{code-block} shell
juju deploy sackd --base "ubuntu@24.04" --channel "edge"
juju deploy slurmctld --base "ubuntu@24.04" --channel "edge"
juju deploy slurmd --base "ubuntu@24.04" --channel "edge"
juju deploy slurmdbd --base "ubuntu@24.04" --channel "edge"
juju deploy slurmrestd --base "ubuntu@24.04" --channel "edge"
juju deploy mysql --channel "8.0/stable"
:::

and integrate them together:

:::{code-block} shell
juju integrate slurmctld sackd
juju integrate slurmctld slurmd
juju integrate slurmctld slurmdbd
juju integrate slurmctld slurmrestd
juju integrate slurmdbd mysql:database
:::



After a few minutes, the Slurm deployment will become active. The output of the
`juju status`{l=shell} command should be similar to the following:

<!-- specificly these exact models, controllers, etc? What will be exactly the same vs what will differ. -->

<!-- Why is Cloud/Region localhost? -->

:::{terminal}
:input: juju status
Model  Controller   Cloud/Region         Version  SLA          Timestamp
slurm  charmed-hpc  localhost/localhost  3.6.0    unsupported  17:16:37Z

App         Version          Status  Scale  Charm       Channel      Rev  Exposed  Message
mysql       8.0.39-0ubun...  active      1  mysql       8.0/stable   313  no
sackd       23.11.4-1.2u...  active      1  sackd       latest/edge    4  no
slurmctld   23.11.4-1.2u...  active      1  slurmctld   latest/edge   86  no
slurmd      23.11.4-1.2u...  active      1  slurmd      latest/edge  107  no
slurmdbd    23.11.4-1.2u...  active      1  slurmdbd    latest/edge   78  no
slurmrestd  23.11.4-1.2u...  active      1  slurmrestd  latest/edge   80  no

Unit           Workload  Agent      Machine  Public address  Ports           Message
mysql/0*       active    idle       5        10.32.18.127    3306,33060/tcp  Primary
sackd/0*       active    idle       4        10.32.18.203
slurmctld/0*   active    idle       0        10.32.18.15
slurmd/0*      active    idle       1        10.32.18.207
slurmdbd/0*    active    idle       2        10.32.18.102
slurmrestd/0*  active    idle       3        10.32.18.9

Machine  State    Address       Inst id        Base          AZ  Message
0        started  10.32.18.15   juju-d566c2-0  ubuntu@24.04      Running
1        started  10.32.18.207  juju-d566c2-1  ubuntu@24.04      Running
2        started  10.32.18.102  juju-d566c2-2  ubuntu@24.04      Running
3        started  10.32.18.9    juju-d566c2-3  ubuntu@24.04      Running
4        started  10.32.18.203  juju-d566c2-4  ubuntu@24.04      Running
5        started  10.32.18.127  juju-d566c2-5  ubuntu@22.04      Running
:::

<!-- Add summary of what the last few steps accomplished -->

## Get compute nodes ready for jobs

Now that Slurm has been successfully deployed, the next step is to set up the compute nodes themselves. The compute nodes must be set to the `IDLE` state so that they can start having jobs ran on them.

### Set compute nodes to `IDLE`

Bring up the compute node 
`juju run slurmd/0 node-configured`

### Verify compute nodes are `IDLE`

To verify the lead node's state is `IDLE`, run the following command:

:::{code-block} shell
juju exec -u sackd/0 -- sinfo --nodes $(juju exec -u slurmd/0 -- hostname)
:::

and to verify the rest of the nodes on the cluster are `IDLE`, run:

:::{code-block} shell
juju exec -u sackd/0 -- sinfo
:::

<!-- Add summary of what the last few steps accomplished -->
## Deploy an NFS filesystem





## Deploy the identity stack


## Test the cluster and submit a job

## Success!