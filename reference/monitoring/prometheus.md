(reference-monitoring-prometheus)=
# Prometheus metrics and alerts

This is an overview of all the charms used in Charmed HPC that provide monitoring metrics and alerts
for {term}`Prometheus`, a metrics aggregator and alerts manager for applications.

All metrics and alerts can be viewed from Prometheus or from the {term}`Grafana` web interface.
See {ref}`howto-manage-integrate-with-cos` for more information.

The following table lists all the charms on Charmed HPC that expose metrics and alerts to Prometheus
with their corresponding upstream documentation to know more about the metrics exported. The last
column shows the corresponding query to list the exported metrics in Prometheus or Grafana.

:::{csv-table}
:header: >
: charm, upstream docs, query

slurmctld, [Documentation](https://slurm.schedmd.com/metrics.html), `{juju_charm="slurmctld"}`{l=javascript}
mysql, [Documentation](https://charmhub.io/mysql), `{juju_charm="mysql"}`{l=javascript}
postgresql-k8s, [Documentation](https://charmhub.io/postgresql-k8s), `{juju_charm="postgresql-k8s"}`{l=javascript}
glauth-k8s, [Documentation](https://charmhub.io/glauth-k8s), `{juju_charm="glauth-k8s"}`{l=javascript}
traefik-k8s, [Documentation](https://charmhub.io/traefik-k8s), `{juju_charm="traefik-k8s"}`{l=javascript}
:::

## Slurmctld

The `slurmctld` charm exposes metrics related to:

- Job and node statuses.
- Resource usage for each partition, node, Slurm account or user.
- Cluster-wide information such as total CPU or memory utilization.
- Scheduler information such scheduling cycle times and queue lengths.
