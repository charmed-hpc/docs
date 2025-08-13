---
relatedlinks: "[Slurm&#32;website](https://slurm.schedmd.com/overview.html), [Slurm&#32;charms&#32;repository](https://github.com/charmed-hpc/slurm-charms)"
---

(howto-setup-deploy-slurm)=
# How to deploy Slurm

This how-to guide shows you how to deploy the Slurm workload manager as the
resource management and job scheduling service of your Charmed HPC cluster.
The deployment, management, and operations of Slurm are controlled by the Slurm charms.

## Prerequisites

To successfully deploy Slurm in your Charmed HPC cluster, you will at least need:

- An [initialized cloud environment](#howto-initialize-cloud-environment).
- The [Juju CLI client](https://documentation.ubuntu.com/juju/latest/user/howto/manage-juju/) installed on your machine.

Once you have verified that you have met the prerequisites above, proceed to the instructions below.

## Deploy Slurm

You have two options for deploying Slurm:

1. Using the [Juju CLI client](https://documentation.ubuntu.com/juju/latest/user/reference/juju-cli/).
2. Using the [Juju Terraform client](https://canonical-terraform-provider-juju.readthedocs-hosted.com/latest/).

If you want to use Terraform to deploy Slurm, see the
[Manage `terraform-provider-juju`](https://canonical-terraform-provider-juju.readthedocs-hosted.com/latest/howto/manage-terraform-provider-juju/) how-to guide for additional
requirements.

If you are deploying Slurm on [LXD](https://canonical.com/lxd), see
[Deploying Slurm on LXD](#deploy-slurm-lxd) for more information on additional constraints
that must be passed to Juju.

:::::{tab-set}

::::{tab-item} CLI
:sync: cli

To deploy Slurm using the Juju CLI client, first create the `slurm` model that will hold the
deployment. The `slurm` model is the abstraction that will hold the resources &mdash;
machines, integrations, network spaces, storage, etc. &mdash; that are provisioned as
part of your Slurm deployment.

Run the following command to create the `slurm` model in your `charmed-hpc` machine cloud:

:::{code-block} shell
juju add-model slurm charmed-hpc
:::

Now, with `slurm` model created, run the following set of commands to deploy the Slurm
daemons with MySQL as the storage back-end for `slurmdbd`:

:::{code-block} shell
juju deploy sackd --base "ubuntu@24.04" --channel "edge"
juju deploy slurmctld --base "ubuntu@24.04" --channel "edge"
juju deploy slurmd --base "ubuntu@24.04" --channel "edge"
juju deploy slurmdbd --base "ubuntu@24.04" --channel "edge"
juju deploy slurmrestd --base "ubuntu@24.04" --channel "edge"
juju deploy mysql --channel "8.0/stable"
:::

`juju deploy`{l=shell} only deploys the Slurm charms. `juju integrate`{l=shell} integrates
the charms together which will trigger the necessary events for the
Slurm daemons to reach active status. Run the following set of commands
to integrate the Slurm daemons together:

:::{code-block} shell
juju integrate slurmctld sackd
juju integrate slurmctld slurmd
juju integrate slurmctld slurmdbd
juju integrate slurmctld slurmrestd
juju integrate slurmdbd mysql:database
:::

After a few minutes, your Slurm deployment will become active. The output of the
`juju status`{l=shell} command should be similar to the following:

:::{terminal}
:input: juju status
Model  Controller   Cloud/Region         Version  SLA          Timestamp
slurm  charmed-hpc  localhost/localhost  3.6.0    unsupported  17:16:37Z

App         Version          Status  Scale  Charm       Channel      Rev  Exposed  Message
mysql       8.0.39-0ubun...  active      1  mysql       8.0/stable   313  no
sackd       23.11.4-1.2u...  active      1  sackd       latest/edge    4  no
slurmctld   23.11.4-1.2u...  active      1  slurmctld   latest/edge   86  no       primary - UP
slurmd      23.11.4-1.2u...  active      1  slurmd      latest/edge  107  no
slurmdbd    23.11.4-1.2u...  active      1  slurmdbd    latest/edge   78  no
slurmrestd  23.11.4-1.2u...  active      1  slurmrestd  latest/edge   80  no

Unit           Workload  Agent      Machine  Public address  Ports           Message
mysql/0*       active    idle       5        10.32.18.127    3306,33060/tcp  Primary
sackd/0*       active    idle       4        10.32.18.203
slurmctld/0*   active    idle       0        10.32.18.15                     primary - UP
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

::::

::::{tab-item} Terraform
:sync: terraform

To deploy Slurm using the Juju Terraform client, first configure Terraform
to use the Juju provider in your deployment plan.

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

Now create the `slurm` model that will hold the deployment. The `slurm` model is the
abstraction that will hold the resources &mdash; machines, integrations, network spaces,
storage, etc. &mdash; that are provisioned as part of your Slurm deployment. This
resource will direct Juju to create the model `slurm`:

:::{code-block} terraform
:caption: `main.tf`
resource "juju_model" "slurm" {
  name = "slurm"

  cloud {
    name = "charmed-hpc"
  }
}
:::

With the `slurm` `juju_model` resource defined, declare the following set of modules
in your Terraform plan. These modules will direct Juju to deploy the Slurm daemons with
MySQL as the storage back-end for `slurmdbd`:

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

Declaring the modules only deploys the Slurm charms. Integrations are still required
to trigger the necessary events for the Slurm daemons to reach active status.
Declare the following set of resources in your deployment plan.
These resources will direct Juju to integrate the Slurm daemons together:

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

With all the charm modules, `juju_model`, and `juju_integration` resources
declared in your deployment plan, you are now ready time to deploy Slurm.
Expand the dropdown below to see the full deployment plan:

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

After verifying that your plan is correct, run the following set of commands to deploy Slurm
using Terraform and the Juju provider:

:::{code-block} shell
terraform init
terraform apply -auto-approve
:::

:::{tip}
You can run `terraform validate`{l=shell} to validate your Slurm deployment plan before applying it.
You can also run `terraform plan`{l=shell} to see the speculative execution plan that Terraform
will follow to deploy the Slurm charms, however, note that `terraform plan`{l=shell} will not
actually execute plan.
:::


After a few minutes, your Slurm deployment will become active. The output of the
`juju status`{l=shell} command should be similar to the following:

:::{terminal}
:input: juju status
Model  Controller   Cloud/Region         Version  SLA          Timestamp
slurm  charmed-hpc  localhost/localhost  3.6.0    unsupported  17:16:37Z

App         Version          Status  Scale  Charm       Channel      Rev  Exposed  Message
mysql       8.0.39-0ubun...  active      1  mysql       8.0/stable   313  no
sackd       23.11.4-1.2u...  active      1  sackd       latest/edge    4  no
slurmctld   23.11.4-1.2u...  active      1  slurmctld   latest/edge   86  no       primary - UP
slurmd      23.11.4-1.2u...  active      1  slurmd      latest/edge  107  no
slurmdbd    23.11.4-1.2u...  active      1  slurmdbd    latest/edge   78  no
slurmrestd  23.11.4-1.2u...  active      1  slurmrestd  latest/edge   80  no

Unit           Workload  Agent      Machine  Public address  Ports           Message
mysql/0*       active    idle       5        10.32.18.127    3306,33060/tcp  Primary
sackd/0*       active    idle       4        10.32.18.203
slurmctld/0*   active    idle       0        10.32.18.15                     primary - UP
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

::::

:::::


(deploy-slurmctld-high-availability)=
### Deploying `slurmctld` in high availability

The `slurmcltd` charm optionally supports [high availability (HA)](explanation-high-availability) through the native functionality provided by Slurm: an active-passive setup where additional units are backups to a single primary.

This functionality requires a low-latency [shared file system to be deployed](howto-setup-deploy-shared-filesystem) and a `filesystem-client` charm, without a user-configured mount point, to be integrated with `slurmctld` on the `mount` endpoint to allow sharing of data across all `slurmctld` units. For guidance on choosing a file system, see the [Shared `StateSaveLocation` using `filesystem-client` charm](explanation-slurmctld-high-availability-state-save-location) section.

Once a chosen shared file system has been deployed and made available via a proxy charm, run the following, substituting `[filesystem-provider]` with the name of the proxy charm, for a `slurmctld` HA setup with two units (a primary and single backup):

:::::{tab-set}

::::{tab-item} CLI
:sync: cli

:::{code-block} shell
juju deploy filesystem-client --channel latest/edge
juju integrate filesystem-client:filesystem [filesystem-provider]:filesystem

juju deploy slurmctld --base "ubuntu@24.04" --channel "edge" --num-units 2
juju integrate slurmctld:mount filesystem-client:mount
:::

::::

::::{tab-item} Terraform
:sync: terraform

:::{code-block} terraform
:caption: `main.tf`
module "filesystem-client" {
  source     = "git::https://github.com/charmed-hpc/filesystem-charms//charms/filesystem-client/terraform"
  model_name  = juju_model.slurm.name
}

resource "juju_integration" "provider-to-filesystem" {
  model = juju_model.slurm.name

  application {
    name     = module.[filesystem-provider].app_name
    endpoint = module.[filesystem-provider].provides.filesystem
  }

  application {
    name     = module.filesystem-client.app_name
    endpoint = module.filesystem-client.requires.filesystem
  }
}

module "slurmctld" {
  source      = "git::https://github.com/charmed-hpc/slurm-charms//charms/slurmctld/terraform"
  model_name  = juju_model.slurm.name
  constraints = "arch=amd64 virt-type=virtual-machine"
  units       = 2
}

resource "juju_integration" "filesystem-to-slurmctld" {
  model = juju_model.slurm.name

  application {
    name     = module.slurmctld.app_name
    endpoint = module.slurmctld.provides.mount
  }

  application {
    name     = module.filesystem-client.app_name
    endpoint = module.filesystem-client.requires.mount
  }
}
:::

::::

:::::

(deploy-slurm-lxd)=
### Deploying Slurm on LXD

The Slurm charms can deploy, manage, and operate Slurm on any
[supported machine cloud](https://documentation.ubuntu.com/juju/latest/user/reference/cloud/list-of-supported-clouds/), however, each
cloud has their own permutations. On LXD, if you deploy the charms to system containers rather
than virtual machines, Slurm cannot use the recommended process tracking plugin `proctrack/cgroup`,
and additional modifications must be made to the default LXD profile.

To deploy the Slurm charms to virtual machines rather than system containers, pass the constraint
`"virt-type=virtual-machine"`{l=shell} to Juju when deploying the charms:

:::::{tab-set}

::::{tab-item} CLI
:sync: cli

:::{code-block} shell
juju deploy sackd --base "ubuntu@24.04" --channel "edge" --constraints="virt-type=virtual-machine"
juju deploy slurmctld --base "ubuntu@24.04" --channel "edge" --constraints="virt-type=virtual-machine"
juju deploy slurmd --base "ubuntu@24.04" --channel "edge" --constraints="virt-type=virtual-machine"
juju deploy slurmdbd --base "ubuntu@24.04" --channel "edge" --constraints="virt-type=virtual-machine"
juju deploy slurmrestd --base "ubuntu@24.04" --channel "edge" --constraints="virt-type=virtual-machine"
juju deploy mysql --channel "8.0/stable" --constraints="virt-type=virtual-machine"
:::

::::

::::{tab-item} Terraform
:sync: terraform

:::{code-block} terraform
:caption: `main.tf`
module "sackd" {
  source      = "git::https://github.com/charmed-hpc/slurm-charms//charms/sackd/terraform"
  model_name  = juju_model.slurm.name
  constraints = "arch=amd64 virt-type=virtual-machine"
}

module "slurmctld" {
  source      = "git::https://github.com/charmed-hpc/slurm-charms//charms/slurmctld/terraform"
  model_name  = juju_model.slurm.name
  constraints = "arch=amd64 virt-type=virtual-machine"
}

module "slurmd" {
  source      = "git::https://github.com/charmed-hpc/slurm-charms//charms/slurmd/terraform"
  model_name  = juju_model.slurm.name
  constraints = "arch=amd64 virt-type=virtual-machine"
}

module "slurmdbd" {
  source      = "git::https://github.com/charmed-hpc/slurm-charms//charms/slurmdbd/terraform"
  model_name  = juju_model.slurm.name
  constraints = "arch=amd64 virt-type=virtual-machine"
}

module "slurmrestd" {
  source      = "git::https://github.com/charmed-hpc/slurm-charms//charms/slurmrestd/terraform"
  model_name  = juju_model.slurm.name
  constraints = "arch=amd64 virt-type=virtual-machine"
}

module "mysql" {
  source          = "git::https://github.com/canonical/mysql-operator//terraform"
  juju_model_name = juju_model.slurm.name
  constraints     = "arch=amd64 virt-type=virtual-machine"
}
:::

::::

:::::

## Set compute nodes to `IDLE`

Compute nodes are initially enlisted with their state set to `DOWN` after your Slurm deployment
becomes active. To set the compute nodes' state to `IDLE` so that they can start having jobs
scheduled on them, use `juju run`{l=shell} to run the `resume` action on the leading controller:

:::{code-block} shell
juju run slurmctld/leader resume nodename="<machine-instance-id/hostname>"
:::

::::{admonition} Tips
:class: tip
1. You can get the hostname of all your compute nodes with `juju exec`{l=shell}:

:::{code-block} shell
juju exec --application slurmd -- hostname -s
:::

2. The `nodename` parameter of the `resume` action also accepts node ranges for setting the state
   of compute nodes to `IDLE` in bulk:

:::{code-block}
juju run slurmctld/leader resume nodename="<machine-instance-id/hostname>[range]"
:::

::::

## Verify compute nodes are `IDLE`

The sackd charm installs the Slurm client commands. To use `sinfo`{l=shell} to verify that a compute
node's state is `IDLE`, run the following command with `juju exec`{l=shell} in your sackd unit:

:::{code-block} shell
juju exec -u sackd/0 -- sinfo --nodes $(juju exec -u slurmd/0 -- hostname)
:::

To verify that the entire partition is `IDLE`, run `sinfo`{l=shell} without the
`--nodes`{l=shell} flag:

:::{code-block} shell
juju exec -u sackd/0 -- sinfo
:::
