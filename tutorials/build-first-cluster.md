(build-first-cluster)=
# Build your first Charmed HPC cluster

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
Note that the virtual machine launch process may take ten minutes or longer to complete. If the instance states that it has failed to launch due to timing out, check `multipass list`{l=shell} to confirm the status of the instance as it may have actually successfully created the vm. If the `State` is `Running`, then the vm was launched successfully and may simply be completing the cloud-init process.
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
juju deploy slurmd tutorial-partition --base "ubuntu@24.04" --channel "edge" --constraints="virt-type=virtual-machine" -n 2
juju deploy sackd --base "ubuntu@24.04" --channel "edge" --constraints="virt-type=virtual-machine"
:::

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
terraform init
terraform apply -auto-approve
:::

<!-- What will the terminal look like after the prior command? Will there be any on-screen logging happening? -->

After a few minutes, the Slurm deployment will become active. The output of the
`juju status`{l=shell} command should be similar to the following:

:::{terminal}
:input: juju status
:copy:
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

First move to the login node (sackd):

:::{code-block} shell
juju ssh sackd/0
:::

<!-- Set up and run a batch job (and/or interactive?) -->

## Run a container job

<!-- Set up and run an Apptainer job -->


## Success!