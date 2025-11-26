---
relatedlinks: "[Apptainer&#32;admin&#32;documentation](https://apptainer.org/docs/admin/latest/), [Apptainer&#32;(Charmhub)](https://charmhub.io/apptainer), [Apptainer&#32;charm&#32;repository](https://github.com/charmed-hpc/apptainer-operator)"
---

(howto-manage-integrate-with-apptainer)=
# Integrate with Apptainer

Charmed HPC can integrate with Apptainer to enable container workload scheduling with Slurm.
This guide explains how to enable container workload scheduling by deploying and integrating
Apptainer with Charmed HPC.

:::{admonition} New to Apptainer?
:class: note

If you're unfamiliar with operating Apptainer installations, see the [Apptainer admin quick start guide](https://apptainer.org/docs/admin/latest/admin_quickstart.html)
for a high-level introduction to administering Apptainer.
:::

## Prerequisites

- A [deployed Slurm cluster](#howto-setup-deploy-slurm).

## Deploy and integrate Apptainer

First, in the same model holding your Slurm deployment, deploy Apptainer with `juju deploy`{l=shell}:

:::{terminal}
:copy:
juju deploy apptainer
:::

::::{dropdown} Tip: Determining the current Juju model
You can use `juju switch`{l=shell} to determine the current model you're operating on:

:::{terminal}
:copy:
juju switch

charmed-hpc-controller:admin/slurm
:::

<!--
  This raw `<br>` element is here because :terminal: directive does not add padding to the
  bottom of the rendered block that the text is too close
-->
<br>

The output above shows that we're operating on the `slurm` model as the `admin` user
through the Juju controller `charmed-hpc-controller`.
::::

Now integrate Apptainer with Slurm using `juju integrate`{l=shell}:

:::{terminal}
:copy:
juju integrate apptainer sackd
:::

:::{terminal}
:copy:

juju integrate apptainer slurmd
:::

:::{terminal}
:copy:
juju integrate apptainer slurmctld
:::

Apptainer will be installed on all the `sackd` and `slurmd` units, and will share its configuration
with the Slurm controller, `slurmctld`.

## Test that Apptainer is integrated with Slurm

Submit a test job with `juju exec`{l=text}. If Apptainer has been successfully integrated with
Slurm, the output of your test job will be similar to the following:

:::{terminal}
:copy:
juju exec -u sackd/0 -- srun --partition slurmd --container=docker://ubuntu:22.04 cat /etc/os-release | grep ^VERSION

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
