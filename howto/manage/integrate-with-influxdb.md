---
relatedlinks: "[InfluxDB&#32;website](https://www.influxdata.com), [InfluxDB&#32;(Charmhub)](https://charmhub.io/influxdb), [InfluxDB&#32;charm&#32;repository](https://code.launchpad.net/influxdb-charm)"
---

(howto-manage-integrate-with-influxdb)=
# Integrate with InfluxDB

Charmed HPC can integrate with InfluxDB to enable job profiling in Slurm.

This guide explains how to enable job profiling by deploying and integrating InfluxDB with Charmed HPC.

## Prerequisites

- A [deployed Slurm cluster](#howto-setup-deploy-slurm).

## Deploy and Integrate InfluxDB

First, in the same model holding your Slurm deployment, deploy InfluxDB with `juju deploy`{l=shell}:

:::{code-block} shell
juju deploy influxdb
:::

Now, with `juju integrate`{l=shell}, integrate InfluxDB with the Slurm controller:

:::{code-block} shell
juju integrate influxdb slurmctld
:::

Once the InfluxDB has been integrated with the Slurm controller, Slurm is now configured
to send job profiling metrics to InfluxDB, enabling the use of the `sstat` command.
