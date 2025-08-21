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

<!-- Warning about using public wifi and multipass launch taking a while and may need the --timeout increase -->




## Deploy Slurm

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

Now, in the same file, create the `slurm` model that will hold the deployment:

:::{code-block} terraform
:caption: `main.tf`
resource "juju_model" "slurm" {
  name = "slurm"

  cloud {
    name = "charmed-hpc-controller"
  }
}
:::

With the `slurm` `juju_model` resource defined, declare the following set of modules in the Terraform plan:

:::{code-block} terraform
:caption: `main.tf`
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
:::

Now declare the following set of resources in the same deployment plan, to integrate the Slurm daemons together:

:::{code-block} terraform
:caption: `main.tf`
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

The full deployment plan is availble in the dropdown. Compare yours to the full plan to confirm everything was added correctly.

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

First, get the hostnames for the compute nodes:

:::{code-block} shell
juju exec --application slurmd -- hostname -s
:::

<!-- What does the output look like here? -->

Then use `juju run`{l=shell} to run the `resume` action on the leading controller:
<!-- leading controller? Leading node? -->

<!-- Is the machine instance ID something we can set or is it assigned by azure or juju? -->

:::{code-block} shell
juju run slurmctld/leader resume nodename="<machine-instance-id/hostname>"
:::

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