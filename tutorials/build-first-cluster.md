(build-first-cluster)=
# Build your first Charmed HPC cluster

<!-- A tutorial is a practical activity, in which the student learns by doing something meaningful, towards some achievable goal. What the student does is not necessarily what they will learn. -->

<!-- Goal: Get a new potential user familiar with the various tools used for Charmed HPC, and build a basic cluster that feels recognizable by the end. Show how Charmed HPC provides a turn-key cluster smoothly and why its worth using. -->

In this tutorial we will build a small Charmed HPC cluster, deployed a job to the new batch queue, and viewed the job and cluster status metrics. By the end of this tutorial, we will have worked with Multipass, Juju and Charms, Kubernetes, the Canonical Observability Stack (COS), and Slurm.

This tutorial expects that you have some familiarity with classic high-performance computing concepts and programs, but does not expect any prior experience with Juju, Kubernetes, COS, or prior experience launching a Slurm cluster.

<!-- How long should this tutorial take to complete? -->

:::{note}
This tutorial builds a minimal cluster deployment within a virtual machine and should not be used as the basis for a production cluster.
:::

## Prerequisites and dependencies

To successfully complete this tutorial, you will need:


* 8 cpus, 20GB RAM, and 40GB storage available
* [Multipass installed](https://canonical.com/multipass/install)
* An active wifi connection
* A local copy of the `charmed-hpc-tutorial-cloud-init.yaml`

## Create Multipass VM

Using the `charmed-hpc-tutorial-cloud-init.yaml`, launch a Multipass VM:

:::{code-block} shell
multipass launch 24.04 --name charmed-hpc-tutorial-vm --cloud-init charmed-hpc-tutorial-cloud-init.yml --memory 16G --disk 40G --cpus 8
:::

<!-- Rephrase this section -->
Note that the virtual machine launch process may take ten minutes or longer to complete. If the instance states that it has failed to launch due to timing out, check `multipass list`{l=shell} to confirm the status of the instance as it may have actually successfully created the vm. If the `State` is `Running`, then the vm was launched successfully and may simply be completing the cloud-init process.
<!-- Steps if the vm does not say running? -->

The cloud init process creates and configures our lxd machine cloud `localhost` with the `charmed-hpc-controller` juju controller and our `charmed-hpc-k8s` Kubernetes control cloud.
<!-- Add ref arch pieces -->

To check the status of cloud-init, first, enter the vm:

:::{code-block} shell
multipass shell charmed-hpc-tutorial-vm
:::

Then check `cloud init status`{l=shell} with:

:::{code-block} shell
cloud-init status --long
:::

Which will show something similar to the following when complete:

:::{terminal}
:input: cloud-init status --long
status: done
extended_status: done
boot_status_code: enabled-by-genertor
last_update: Thu, 01 Jan 1970 00:03:45 +0000
detail: DataSourceNoCloud [seed=/dev/sr0]
errors: []
recoverable_errors: {}
:::

<!-- Quick commands to test that various cloud init pieces have been set up correctly:

`juju status -m controller` should show...
`juju clouds` should show...
 -->

## Deploy Slurm and file system

Next, we will deploy Slurm as the resource management and job scheduling service.

First create the `slurm` model that will hold the
deployment in our cloud `localhost`:

:::{code-block} shell
juju add-model slurm localhost
:::

Then deploy the Slurm management daemon `slurmctld`:

:::{code-block} shell
juju deploy slurmctld --base "ubuntu@24.04" --channel "edge" --constraints="virt-type=virtual-machine"
:::

and the Slurm compute node daemon with partition name 'tutorial-partition' and two nodes:

:::{code-block} shell
juju deploy slurmd tutorial-partition --base "ubuntu@24.04" --channel "edge" --constraints="virt-type=virtual-machine" -n 2
:::

and the authentication and credential kiosk daemon `sackd`:

:::{code-block} shell
juju deploy sackd --base "ubuntu@24.04" --channel "edge" --constraints="virt-type=virtual-machine"
:::

Then deploy the filesystem pieces to create a MicroCeph shared filesystem:

:::{code-block} shell
juju deploy microceph --channel latest/edge --constraints="virt-type=virtual-machine mem=4G root-disk=20G"
juju deploy ceph-fs --channel latest/edge
juju deploy filesystem-client data --channel latest/edge --config mountpoint=/data
juju add-storage microceph/0 osd-standalone=loop,2G,3
:::

and integrate them together:

:::{code-block} shell
juju integrate slurmctld sackd
juju integrate slurmctld tutorial-partition
juju integrate data ceph-fs
juju integrate ceph-fs microceph
juju integrate data:juju-info tutorial-partition:juju-info
:::

After a few minutes, the Slurm deployment will become active. The output of the
`juju status`{l=shell} command should be similar to the following:

:::{terminal}
:input: juju status
Model  Controller              Cloud/Region         Version    SLA          Timestamp
slurm  charmed-hpc-controller  localhost/localhost    3.6.9    unsupported  17:16:37Z

App                 Version               Status  Scale  Charm             Channel      Rev  Exposed  Message
ceph-fs             19.2.1                active      1  ceph-fs           latest/edge   196 no       Unit is ready
data                                      active      2  filesystem-client latest/edge   20  no       Integrated with `cephfs` provider
microceph                                 active      1  microceph         latest/edge   159 no       (workload) charm is ready
sackd               23.11.4-1.2u...       active      1  sackd             latest/edge   32  no
slurmctld           23.11.4-1.2u...       active      1  slurmctld         latest/edge   114 no
tutorial-partition  23.11.4-1.2u...       active      2  slurmd            latest/edge   135 no


Unit                      Workload  Agent      Machine  Public address                         Ports           Message
ceph-fs/0*                active    idle       5        10.125.192.110                                         Unit is ready
microceph/0*              active    idle       4        fd42:4e69:6c2a:c4a9:216:3eff:fe0c:f9f5                 (workload) charm is ready
sackd/0*                  active    idle       3        fd42:4e69:6c2a:c4a9:216:3eff:fe5b:75c6 6818/tcp
slurmctld/0*              active    idle       0        10.125.192.7                           6817,9092/tcp
tutorial-partition/0      active    idle       1        10.125.192.109                         6818/tcp                 
  data/0*                 active    idle                10.125.192.109                                          Mounted filesystem at '/data'
tutorial-partition/1*     active    idle       2        10.125.192.132                         6818/tcp
  data/1                  active    idle                10.125.192.132                                          Mounted filesystem at '/data'

Machine  State    Address                                 Inst id        Base          AZ                         Message
0        started  10.125.192.7                            juju-e16200-0  ubuntu@24.04  charmed-hpc-tutorial-vm    Running
1        started  10.125.192.109                          juju-e16200-1  ubuntu@24.04  charmed-hpc-tutorial-vm    Running
2        started  10.125.192.132                          juju-e16200-2  ubuntu@24.04  charmed-hpc-tutorial-vm    Running
3        started  fd42:4e69:6c2a:c4a9:216:3eff:fe5b:75c6  juju-e16200-3  ubuntu@24.04  charmed-hpc-tutorial-vm    Running
4        started  fd42:4e69:6c2a:c4a9:216:3eff:fe0c:f9f5  juju-e16200-4  ubuntu@24.04  charmed-hpc-tutorial-vm    Running
5        started  10.125.192.110                          juju-e16200-5  ubuntu@22.04  charmed-hpc-tutorial-vm    Running
:::

<!-- Test the file system set up  -->
<!-- Add summary of what the last few steps accomplished and what juju status is showing-->

## Get compute nodes ready for jobs

Now that Slurm and the file system have been successfully deployed, the next step is to set up the compute nodes themselves. The compute nodes must be moved from the `down` state to the `idle` state so that they can start having jobs ran on them.

First, check that the compute nodes are still down:

:::{code-block} shell
juju exec -u sackd/0 -- sinfo
:::

which will show something similar to:

:::{terminal}
:input: juju exec -u sackd/0 -- sinfo
PARTITION         AVAIL  TIMELIMIT  NODES  STATE NODELIST
tutorial-parition    up   infinite      2   down juju-e16200-[1-2]
:::

Then, to bring up the compute nodes:

:::{code-block} shell
juju run tutorial-partition/0 node-configured
juju run tutorial-partition/1 node-configured
:::

And verify that the `STATE` is now set to `idle`:

:::{code-block} shell
juju exec -u sackd/0 -- sinfo
:::

which should now show:

:::{terminal}
:input: juju exec -u sackd/0 -- sinfo
PARTITION         AVAIL  TIMELIMIT  NODES  STATE NODELIST
tutorial-parition    up   infinite      2   idle juju-e16200-[1-2]
:::

<!-- Add summary of what the last few steps accomplished -->

## Run a batch job

First move to the login node (sackd):

:::{code-block} shell
juju ssh sackd/0
:::

<!-- Set up and run a batch job (and/or interactive?) -->

## Run a container job

<!-- Set up and run an Apptainer job -->

## Deploy the identity stack

Now that we have a functional cluster, we'll want to be able to view cluster health metrics. For this, we will deploy the Canonical Observability Stack (COS) to our `charmed-hpc-k8s` cloud.

<!-- slurmdbd and mysql? -->
<!-- context on what's about to be done -->
:::{code-block} shell
juju add-model cos charmed-hpc-k8s
juju deploy --model cos cos-lite --trust
:::

:::{code-block} shell
juju deploy --model slurm grafana-agent --base "ubuntu@24.04"
juju integrate --model slurm grafana-agent slurmctld
:::

The grafana-agent deployment and integration pieces take a few minutes to complete all steps and must be complete prior to the next steps. To check, run:

:::{code-block} shell
juju status --watch 2s
:::

and wait until the `Status` states `active` for all `Apps` and there are no messages stating that any app is waiting or installing. To leave the watch session, press `ctrl+c`.

<!-- context on what's about to be done -->
:::{code-block} shell
juju show-unit --model cos catalogue/0 --format json | \
  jq '.[]."relation-info".[]."application-data".url | select (. != null)'
:::

which will show something similar to:

:::{terminal}
:input: juju show-unit --model cos catalogue/0 --format json | jq '.[]."relation-info".[]."application-data".url | select (. != null)'
"http://10.9.115.212/cos-grafana"
"http://10.9.115.212/cos-prometheus-0"
"http://10.9.115.212/cos-alertmanager"
:::

and then use the full `cos-prometheus-0` address (here: http://10.9.115.212/cos-prometheus-0) to run:

<!-- context on what's about to be done -->

:::{code-block} shell
juju exec --model slurm --unit grafana-agent/0 \
  "curl -s <cos-prometheus-0 address>/api/v1/status/runtimeinfo"
:::

<!-- output of the curl command -->
<!-- context on what's about to be done -->
:::{code-block} shell
juju switch cos
juju offer cos.grafana:grafana-dashboard grafana-dashboards
juju offer cos.loki:logging loki-logging
juju offer cos.prometheus:receive-remote-write prometheus-receive-remote-write
:::

<!-- `juju status` state on cos model and on slurm model at this stage -->

:::{code-block} shell
juju switch slurm 
juju consume charmed-hpc-controller:cos.prometheus-receive-remote-write
juju consume charmed-hpc-controller:cos.grafana-dashboards
juju consume charmed-hpc-controller:cos.loki-logging
juju integrate grafana-agent prometheus-receive-remote-write
juju integrate grafana-agent loki-logging
juju integrate grafana-agent grafana-dashboards
:::

and then check `juju status`{l=shell} and wait until `grafana-agent/0` is `idle`.


<!-- is the wait necessary if juju status is checked prior to this step? -->
:::{code-block} shell
juju run grafana/leader --model charmed-hpc-controller:cos \
  --wait 1m \
  get-admin-password
:::

Open the resulting `url` in your browser and log in with username `admin` and the admin-password listed.

<!-- quick walk through of what to look at once logged in -->

## Success!