:::{admonition} Deploying Slurm on LXD
:class: warning

Do not follow the instructions below for deploying Slurm if your backing cloud is LXD.
On LXD, if you deploy the Slurm charms to system containers rather than virtual machines,
Slurm cannot use the recommended process tracking plugin `proctrack/cgroup`,
and additional modifications must be made to the default LXD profile.

See the [Deploy Slurm on LXD](deploy-slurm-lxd) section for instructions on the
additional constraints that must be passed to Juju so that Slurm is deployed on virtual
machines instead of system containers.
:::
