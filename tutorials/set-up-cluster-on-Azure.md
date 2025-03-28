(tutorials-set-up-cluster-on-Azure)=
# Set up a Charmed HPC cluster on Azure

In this tutorial we will walk through the various steps to set up a Charmed HPC cluster on Azure, Microsoft's cloud platform. By the end of this tutorial, we will have deployed the various components of a Charmed HPC cluster on Azure VMs and submitted a basic script to the batch queue. 

This tutorial expects that you have some passing familiarity with classic high-performance computing concepts and programs, but does not expect any prior experience with Juju, Kubernetes, or Azure clouds.

## Prerequisits and dependencies

To successfully follow along with this tutorial, you will need:

* The [Juju CLI client](https://documentation.ubuntu.com/juju/latest/user/howto/manage-juju/) installed on your machine.
* [A valid Azure subscription ID](https://learn.microsoft.com/en-us/azure/azure-portal/get-subscription-tenant-id)
* [Installed the Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
* [Signed into the Azure CLI](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli-interactively)

<!-- * [Adjusted quotas for suitable virtual machine (VM) families](https://learn.microsoft.com/en-us/azure/quotas/per-vm-quota-requests) - which specific VMs are we using here?-->

## Cloud Environment Initialization


### Add Azure cloud credentials to Juju

First, add your Azure credentials to Juju by running:

:::{code-block} shell
juju add-credential azure
:::

This will start a script where you will be asked for the parameters in the left column, and will provide the value in the right:

| Parameter              | Value                          |
|------------------------|--------------------------------|
| `credential-name`      | `my-az-credential`             |
| `region`               | `eastus`                       |
| `auth type`            | `interactive`                  |
| `subscription-id`      | `<your-azure-subscription-ID>` |
| `application_name`     | ` `                            |
| `role-definition-name` | ` `                            |


You will then be asked to authenticate the requests via your web browser with the following message:

:::{code-block} shell
To sign in, use a web browser to open the page https://microsoft.com/devicelogin
and enter the code <auth-code> to authenticate.
:::

In a web browser, open the [authentication page](https://microsoft.com/devicelogin), sign in as required, and enter the `<auth-code>` from the end of the authentication request shown in the terminal window. You will be asked to authenticate twice, to allow creation of two different resources in Azure.

Once the credentials have been added successfully, the following message will be displayed:

:::{code-block} shell
Credential "my-az-credential" added locally for cloud "azure".
:::

## Deploy Slurm


## Deploy an NFS filesystem 


## Deploy the identity stack


## Test the cluster and submit a job

## Success!