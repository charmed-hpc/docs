(reference-monitoring-loki)=
# Loki logs

The following table lists all the charms used as part of Charmed HPC that expose logs to Loki, and the
corresponding query to see the exported logs in the Grafana UI.
Follow the [Visualize log data](https://grafana.com/docs/loki/latest/visualize/grafana/#grafana-explore)
tutorial from the Grafana documentation for instructions on where and how to query for Loki logs.

:::{csv-table}
:header: >
: charm, query

<!-- TODO: track https://github.com/canonical/grafana-agent-operator/issues/46 to use juju labels instead of filenames -->
slurmctld, `{juju_charm="grafana-agent"} | filename =~ ".*/var/log/slurm/.*"`{l=shell}
mysql, `{juju_charm="grafana-agent"} | filename =~ ".*/var/log/mysql/.*"`{l=shell}
postgresql-k8s, `{juju_charm="postgresql-k8s"}`{l=shell}

<!-- TODO: enable when traefik exposes logs to Loki (https://github.com/canonical/traefik-k8s-operator/pull/363) -->
<!-- traefik-k8s, `{juju_charm="traefik-k8s"}`{l=shell} -->

<!-- TODO: change to `juju_charm` when https://github.com/canonical/loki-k8s-operator/issues/466 gets fixed. -->
glauth-k8s, `{charm="glauth-k8s"}`{l=shell}
:::

## Ignoring log files

By default, every instance of the `grafana-agent` charm will log all the files in the `var/log` directory.
This is sometimes not ideal, since it increases the amount of logs stored by Loki which are unrelated
to the running application. A solution for this is to set the `path_exclude` configuration for
`grafana-agent`, which will allow it to ignore such log files:

:::{code-block} shell
juju config grafana-agent path_exclude="/var/log/{unattended-upgrades,apt,}/*.log"
:::
