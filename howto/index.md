(howtos)=
# How-to guides

The guides in this section provide detailed steps for key operations and common tasks for Charmed HPC.


## First steps

It is **strongly recommended** that you go through the {ref}`Initialize cloud environment <howto-initialize-cloud-environment>` guide first before going through the {ref}`Setup <howto-setup>` section. This guide will show you how to set up access to the compute, storage, and networking resources your Charmed HPC cluster will need.

- {ref}`howto-initialize-cloud-environment`

(howto-setup)=
## Setup

These how-to guides will get you started with Charmed HPC by
taking you through the setup of your own Charmed HPC cluster.

- {ref}`howto-setup-deploy-slurm`
- {ref}`howto-setup-deploy-shared-filesystem`
- {ref}`How to deploy GLAuth and SSSD for Identity and Access Management (IAM) <howto-setup-deploy-glauth>`

(howto-manage)=
## Manage

The how-to guides in this section show you how to integrate with optional services and perform common management tasks after you have
deployed Charmed HPC.

- {ref}`howto-manage-integrate-with-apptainer`
- {ref}`howto-manage-integrate-with-cos`
- {ref}`howto-manage-integrate-with-influxdb`
- {ref}`howto-manage-slurm`

## Clean-up

It is important to clean up resources that are no longer necessary, especially in the case of public clouds where abandoned resources can incur significant costs. This guide demonstrates how to clean up and delete unneeded Charmed HPC resources.

- {ref}`howto-cleanup-cloud-resources`

:::{toctree}
:titlesonly:
:maxdepth: 1
:hidden:

Initialize cloud environment <initialize-cloud-environment>
setup/index
manage/index
use/index
Clean up cloud resources <cleanup-cloud-resources>
:::
