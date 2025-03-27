(reference-monitoring-prometheus)=
# Prometheus metrics and alerts

This is an overview of all the charms used in Charmed HPC that provide monitoring metrics and alerts
for [Prometheus](https://prometheus.io), a metrics aggregator and alerts manager for applications.

All metrics and alerts can be viewed from Prometheus or from the [Grafana](https://grafana.com) web interface.
See {ref}`howto-manage-integrate-with-cos` for more information.

The following table lists all the charms on Charmed HPC that expose metrics and alerts to Prometheus,
with their corresponding upstream documentation to know more about the metrics exported. The last
column shows the corresponding query to list the exported metrics in Prometheus or the Grafana UI.

:::{csv-table}
:header: >
: charm, upstream docs, query

slurmctld, [Documentation](https://github.com/rivosinc/prometheus-slurm-exporter), `{juju_charm="slurmctld"}`{l=javascript}
mysql, [Documentation](https://charmhub.io/mysql), `{juju_charm="mysql"}`{l=javascript}
postgresql-k8s, [Documentation](https://charmhub.io/postgresql-k8s), `{juju_charm="postgresql-k8s"}`{l=javascript}
glauth-k8s, [Documentation](https://charmhub.io/glauth-k8s), `{juju_charm="glauth-k8s"}`{l=javascript}
traefik-k8s, [Documentation](https://charmhub.io/traefik-k8s), `{juju_charm="traefik-k8s"}`{l=javascript}
:::

## Slurmctld

The `slurmctld` charm exposes metrics related to:

- Resource usage per partition, account or user.
- Jobs statuses.
- RPC messages for `slurmctld`.
- Prometheus Slurm Exporter statistics.
