---
relatedlinks: "[Apptainer&#32;website](https://apptainer.org), [Apptainer&#32;(Charmhub)](https://charmhub.io/apptainer), [Apptainer&#32;charm&#32;repository](https://github.com/charmed-hpc/apptainer-operator)"
---

(howto-manage-integrate-with-apptainer)=
# Integrate with Apptainer

Charmed HPC can integrate with Apptainer to enable container workload scheduling with Slurm.

This guide explains how to enable container workload scheduling by
deploying and integrating Apptainer with Charmed HPC.

:::{hint}
If you're unfamiliar with operating Apptainer, see the [Apptainer admin quick start](https://apptainer.org/docs/admin/latest/admin_quickstart.html)
guide for a high-level introduction to administering Apptainer.
:::

## Prerequisites

- A [deployed Slurm cluster](#howto-setup-deploy-slurm).

## Deploy and integrate Apptainer

First, in the same model holding your Slurm deployment, deploy Apptainer with `juju deploy`{l=shell}:

:::{code-block} shell
juju deploy apptainer
:::

Now, with `juju integrate`{l=shell}, integrate Apptainer with the Slurm:

:::{code-block} shell
juju integrate apptainer sackd
juju integrate apptainer slurmd
juju integrate apptainer slurmctld
:::

Apptainer will be installed on all the `sackd` and `slurmd` units, and will share its configuration
with the Slurm controller, `slurmctld`.

## Test that Apptainer is integrated with Slurm

Submit a test job with `juju exec`{l=shell}:

:::{code-block} shell
juju exec -u sackd/0 -- \
  srun --partition slurmd --container=docker://ubuntu:jammy \
  cat /etc/os-release | \
  grep ^VERSION
:::

If Apptainer has been successfully integrated with Slurm, the output of your test
job should be similar to the following:

:::{terminal}
:input: juju exec -u sackd/0 -- srun --partition slurmd --container=docker://ubuntu:jammy cat /etc/os-release | grep ^VERSION
INFO:    Converting OCI blobs to SIF format
INFO:    Starting build...
INFO:    Fetching OCI image...
INFO:    Extracting OCI image...
INFO:    Inserting Apptainer configuration...
INFO:    Creating SIF file...
VERSION_ID="22.04"
VERSION="22.04.5 LTS (Jammy Jellyfish)"
VERSION_CODENAME=jammy
:::

## Next steps

You can now use Apptainer to run workloads and build container images on your Charmed HPC cluster.
Explore the {ref}`howto-use-apptainer` how-to for more information on using Apptainer on your Charmed HPC cluster.
