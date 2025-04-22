(build-first-cluster)=
# Build your first Charmed HPC cluster

<!-- A tutorial is a practical activity, in which the student learns by doing something meaningful, towards some achievable goal. What the student does is not necessarily what they will learn. -->

<!-- Goal: Get a new potential user familiar with the various tools used for Charmed HPC, and build a basic cluster that feels recognizable by the end. -->

In this tutorial we will build  a Charmed HPC cluster on Azure, Microsoft's cloud platform, and deploy a job to the new batch queue. By the end of this tutorial, we will have worked with Azure virtual machines, Juju, Charms, and Terraform, and submitted our first job to the batch queue. 

This tutorial expects that you have some passing familiarity with classic high-performance computing concepts and programs, but does not expect any prior experience with Juju, Kubernetes, or Azure clouds.

## Prerequisites and dependencies

To successfully complete this tutorial, we will need:


<!-- The set up is likely assuming an Ubuntu local system - should we make that explicit? -->

* The [Juju CLI client](https://documentation.ubuntu.com/juju/latest/user/howto/manage-juju/) installed on your machine.
* [A valid Azure subscription ID](https://learn.microsoft.com/en-us/azure/azure-portal/get-subscription-tenant-id)
* [Installed the Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
* [Signed into the Azure CLI](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli-interactively)

<!-- * [Adjusted quotas for suitable virtual machine (VM) families](https://learn.microsoft.com/en-us/azure/quotas/per-vm-quota-requests) - which specific VMs are we using here?-->



## Cloud Environment Initialization


### Add Azure cloud credentials to Juju

First, we add our Azure credentials to Juju by running:

:::{code-block} shell
juju add-credential azure
:::

This will start a script where we will be asked for the parameters in the left column, and will provide the value in the right:

| Parameter              | Value                          |
|------------------------|--------------------------------|
| `credential-name`      | `my-az-credential`             |
| `region`               | `eastus`                       |
| `auth type`            | `interactive`                  |
| `subscription-id`      | `<my-azure-subscription-ID>` |
| `application_name`     | ` `                            |
| `role-definition-name` | ` `                            |

We will then be asked to authenticate the requests via web browser with the following message:

:::{code-block} shell
To sign in, use a web browser to open the page https://microsoft.com/devicelogin
and enter the code <auth-code> to authenticate.
:::

In a web browser, open the [authentication page](https://microsoft.com/devicelogin), sign in as required, and enter the `<auth-code>` from the end of the authentication request shown in the terminal window. We will be asked to authenticate twice, to allow creation of two different resources in Azure.

Once the credentials have been added successfully, the following message will be displayed:

:::{code-block} shell
Credential "my-az-credential" added locally for cloud "azure".
:::

### Widen scope for credentials

To allow Juju to automatically create resources in Azure, further privileges should be granted to the credentials created above. Run:

:::{terminal}
:input: juju show-credentials azure my-az-credential
:::

which will show:

:::{terminal}
client-credentials:
  azure:
    my-az-credential:
      content:
        auth-type: service-principal-secret
        application-id: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
        application-object-id: <application-object-id>
        subscription-id: my-azure-subscription-id
:::

Copy the value of `<application-object-id>` and run:

:::{code-block} shell
az role assignment create --assignee <application-object-id> --role Owner --scope /subscriptions/my-azure-subscription-id
:::

This will grant the credential "full access to manage all resources". 

### Bootstrap Azure cloud controller

To bootstrap the Azure cloud controller, first set the default region to East US:

:::{code-block} shell
juju default-region azure eastus
:::

Then deploy the cloud controller with:

:::{code-block} shell
juju bootstrap azure charmed-hpc-controller --constraints "instance-role=auto"
:::

After a few minutes, the Azure cloud controller will become active. The output of the `juju status`{l=shell} command should show the following:

:::{terminal}
:input: juju status -m controller

Model       Controller              Cloud/Region  Version  SLA          Timestamp
controller  charmed-hpc-controller  azure/eastus  3.6.3    unsupported  10:39:56Z

App         Version  Status  Scale  Charm            Channel     Rev  Exposed  Message
controller           active      1  juju-controller  3.6/stable  116  no

Unit           Workload  Agent  Machine  Public address  Ports  Message
controller/0*  active    idle   0        x.x.x.x

Machine  State    Address      Inst id        Base          AZ  Message
0        started  x.x.x.x      juju-e63b38-0  ubuntu@24.04
:::

<!-- Add summary of what the last few steps accomplished -->

## Deploy Slurm

Next, we will deploy Slurm as the resource management and job scheduling service. Here we will use the [Juju Terraform client](https://canonical-terraform-provider-juju.readthedocs-hosted.com/en/latest/).  


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

Now create the `slurm` model that will hold the deployment:

<!-- Does this cloud name need to match the conotroller name from the prior steps? ie charmed-hpc-controller (Answer from Jason - No, different pieces)-->

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

After verifying that the plan is correct, we will run the following set of commands to deploy Slurm
using Terraform and the Juju provider:

:::{code-block} shell
terraform init
terraform apply -auto-approve
:::

<!-- What will the terminal look like after the prior command? -->

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

Next, the compute nodes must be set to the `IDLE` state so that they can start having jobs ran on them.

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