(howto-enable-job-profiling-with-influxdb)=
# How to enable job profiling with InfluxDB

Charmed HPC can integrate with the [InfluxDB Charm](https://charmhub.io/influxdb) to enable job profiling in Slurm.

This guide explains how to enable job profiling by deploying and integrating `influxdb` with charmed-hpc.

## Prerequisites

- A [deployed Slurm cluster](#howto-setup-deploy-slurm).

## Deploy and Integrate InfluxDB

InfluxDB can be deployed using Juju in a single command.
:::{code-block} shell
$ juju deploy influxdb
:::

Now [integrate](https://canonical-juju.readthedocs-hosted.com/en/latest/user/reference/juju-cli/list-of-juju-cli-commands/integrate/) the newly deployed influxdb charm with slurmctld.
:::{code-block} shell
$ juju integrate influxdb slurmctld
:::

Once the InfluxDB charm deployment and integration are complete slurm will be configured to send job profiling metrics to influxdb, enabling the use of the [`sstat`](https://slurm.schedmd.com/sstat.html) command.
