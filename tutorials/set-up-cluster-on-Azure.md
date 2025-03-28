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

[//]: # (* [Adjusted quotas for suitable virtual machine (VM) families](https://learn.microsoft.com/en-us/azure/quotas/per-vm-quota-requests) )

## Cloud Environment Initialization


## Deploy Slurm


## Deploy an NFS filesystem 


## Deploy the identity stack


## Test the cluster and submit a job

## Success!