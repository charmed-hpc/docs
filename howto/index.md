(howtos)=
# How-to guides

These guides provide detailed steps for key operations and common tasks.


## First steps

Environment setup prior to initial deployment varies by backing cloud. See instructions for local and public cloud initialization, as well as Kubernetes cloud set up.  

- {ref}`howto-initialize-cloud-environment`

(howto-setup)=
## Setup

Deploy and configure the core components of your cluster.

- {ref}`howto-setup-deploy-slurm`
- {ref}`howto-setup-deploy-shared-filesystem`
- {ref}`howto-setup-deploy-identity-provider`

(howto-integrate)=
## Integrate

Connect your cluster with additional observability or workload management tools.

- {ref}`howto-manage-integrate-with-apptainer`
- {ref}`howto-manage-integrate-with-cos`
- {ref}`howto-manage-integrate-with-influxdb`
- {ref}`howto-integrate-email-notifications`

(howto-manage)=
## Manage

Perform common cluster management tasks, such as migrating to high availability or modifying the default node state. 

- {ref}`howto-manage-slurm`

## Use

Custom processes for running workloads on your cluster.

- {ref}`howto-use-apptainer`

## Clean-up

Remove resources that are no longer needed.

- {ref}`howto-cleanup-slurm`
- {ref}`howto-cleanup-cloud-resources`

:::{toctree}
:titlesonly:
:maxdepth: 1
:hidden:

Initialize cloud environment <initialize-cloud-environment>
setup/index
integrate/index
manage/index
use/index
cleanup/index
:::
