(howtos)=
# How-to guides

The guides in this section provide detailed steps for key operations and common tasks.


## First steps

Prepare your cloud environment before deploying a cluster.

- {ref}`howto-initialize-cloud-environment`

(howto-setup)=
## Setup

Deploy and configure the core components of your cluster.

- {ref}`howto-setup-deploy-slurm`
- {ref}`howto-setup-deploy-shared-filesystem`
- {ref}`howto-setup-deploy-identity-provider`

(howto-integrate)=
## Integrate

Connect your cluster with additional applications and services.

- {ref}`howto-manage-integrate-with-apptainer`
- {ref}`howto-manage-integrate-with-cos`
- {ref}`howto-manage-integrate-with-influxdb`
- {ref}`howto-integrate-email-notifications`

(howto-manage)=
## Manage

Perform common cluster management tasks.

- {ref}`howto-manage-slurm`

## Use

Run workloads on your cluster.

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
