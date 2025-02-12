(howtos)=
# How-to guides

The guides in this section provide detailed steps for key operations and common tasks for Charmed HPC.


## First Steps

It is **strongly recommended** that you go through the {ref}`Initialize cloud environment <howto-initialize-cloud-environment>` guide first before going through the {ref}`Setup <howto-setup>` section. This guide will show you how to set up access to the compute, storage, and networking resources your Charmed HPC cluster will need.

- {ref}`howto-initialize-cloud-environment`

(howto-setup)=
## Setup

These how-to guides will get you started with Charmed HPC by
taking you through the setup of your own Charmed HPC cluster.

- {ref}`howto-setup-deploy-slurm`
- {ref}`howto-setup-deploy-shared-filesystem`

(howto-manage)=
## Manage

The how-to guides in this section show you how to perform common management tasks after you have
deployed Charmed HPC. These guides are for system administrators and HPC engineers that are
responsible for managing Charmed HPC after deployment.

- {ref}`howto-manage-integrate-with-cos`

:::{toctree}
:titlesonly:
:maxdepth: 1
:hidden:

Initialize cloud environment <initialize-cloud-environment>
setup/index
manage/index
:::
