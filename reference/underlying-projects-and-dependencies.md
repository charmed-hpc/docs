(reference-underlying-projects-and-dependencies)=
# Underlying projects and dependencies

Charmed HPC is a modular composition of underlying projects and dependencies. The tables below list the
projects, charms, integrations, libraries, packages, and deployment plans that drive and manage the
operations of a Charmed HPC cluster.

## Projects

The underlying projects that compose Charmed HPC can be divided into three categories.

### Core

Core projects are projects that are maintained directly as part of Charmed HPC.

:::{csv-table}
:header: >
: project, source code, bug report
:widths: 15, 10, 10

slurm-charms, [Source](https://github.com/charmed-hpc/slurm-charms), [Issue tracker](https://github.com/charmed-hpc/slurm-charms/issues)
filesystem-charms, [Source](https://github.com/charmed-hpc/filesystem-charms), [Issue tracker](https://github.com/charmed-hpc/filesystem-charms/issues)
sssd-operator, [Source](https://github.com/canonical/sssd-operator), [Issue tracker](https://github.com/canonical/sssd-operator/issues)
slurmutils, [Source](https://github.com/charmed-hpc/slurmutils), [Issue tracker](https://github.com/charmed-hpc/slurmutils/issues)
hpc-libs, [Source](https://github.com/charmed-hpc/hpc-libs), [Issue tracker](https://github.com/charmed-hpc/hpc-libs/issues)
charmed-hpc-terraform, [Source](https://github.com/charmed-hpc/charmed-hpc-terraform), [Issue tracker](https://github.com/charmed-hpc/charmed-hpc-terraform/issues)
:::

### Dependencies

Dependency projects are projects that are required for Charmed HPC to operate successfully, but
are not maintained directly as part of Charmed HPC.

:::{csv-table}
:header: >
: project, source code, bug report
:widths: 15, 10, 10

juju, [Source](https://github.com/juju/juju), [Issue tracker](https://github.com/juju/juju/issues)
mysql, [Source](https://github.com/canonical/mysql-operator), [Issue tracker](https://github.com/canonical/mysql-operator/issues)
mysql-router, [Source](https://github.com/canonical/mysql-router-operator), [Issue tracker](https://github.com/canonical/mysql-router-operator/issues)
traefik-k8s, [Source](https://github.com/canonical/traefik-k8s-operator), [Issue tracker](https://github.com/canonical/traefik-k8s-operator/issues)
glauth-k8s, [Source](https://github.com/canonical/glauth-k8s-operator), [Issue tracker](https://github.com/canonical/glauth-k8s-operator/issues)
postgresql-k8s, [Source](https://github.com/canonical/postgresql-k8s-operator), [Issue tracker](https://github.com/canonical/postgresql-k8s-operator/issues)
:::

### Optional dependencies

Optional dependency projects are projects that are not required for Charmed HPC to operate successfully, but
can enhance the operations of a Charmed HPC cluster. Like dependency projects, optional dependency projects
are not maintained directly as part of Charmed HPC.

:::{csv-table}
:header: >
: project, source code, bug report
:widths: 15, 10, 10

grafana-agent, [Source](https://github.com/canonical/grafana-agent), [Issue tracker](https://github.com/canonical/grafana-agent/issues)
grafana-k8s, [Source](https://github.com/canonical/grafana-k8s-operator), [Issue tracker](https://github.com/canonical/grafana-k8s-operator/issues)
prometheus-k8s, [Source](https://github.com/canonical/prometheus-k8s-operator), [Issue tracker](https://github.com/canonical/prometheus-k8s-operator/issues)
alertmanager-k8s, [Source](https://github.com/canonical/alertmanager-k8s-operator), [Issue tracker](https://github.com/canonical/alertmanager-k8s-operator/issues)
loki-k8s, [Source](https://github.com/canonical/loki-k8s-operator), [Issue tracker](https://github.com/canonical/loki-k8s-operator/issues)
catalogue-k8s, [Source](https://github.com/canonical/catalogue-k8s-operator), [Issue tracker](https://github.com/canonical/catalogue-k8s-operator/issues)
influxdb, [Source](https://code.launchpad.net/influxdb-charm), [Issue tracker](https://bugs.launchpad.net/influxdb-charm)
:::

## Charms

Charmed HPC is composed of both Machine and Kubernetes charms.

Several of the charms include configuration options that are useful for customizing Charmed HPC deployments. These
charms can also include actions that are useful for running common lifecycle operations on a deployed Charmed
HPC cluster.

:::{note}
A charm does not have any modifiable configuration options or runnable actions if a table cell below is blank.
:::

### Machine charms

:::{csv-table}
:header: >
: charm, configuration options, actions
:widths: 15, 10, 10

[sackd](https://charmhub.io/sackd)
[slurmctld](https://charmhub.io/slurmctld), [Options](https://charmhub.io/slurmctld/configurations), [Actions](https://charmhub.io/slurmctld/actions)
[slurmd](https://charmhub.io/slurmd), [Options](https://charmhub.io/slurmd/configurations), [Actions](https://charmhub.io/slurmd/actions)
[slurmdbd](https://charmhub.io/slurmdbd)
[slurmrestd](https://charmhub.io/slurmrestd)
[filesystem-client](https://charmhub.io/filesystem-client), [Options](https://charmhub.io/filesystem-client/configurations)
[nfs-server-proxy](https://charmhub.io/nfs-server-proxy), [Options](https://charmhub.io/nfs-server-proxy/configurations)
[cephfs-server-proxy](https://charmhub.io/cephfs-server-proxy), [Options](https://charmhub.io/cephfs-server-proxy/configurations)
[sssd](https://charmhub.io/sssd)
[grafana-agent](https://charmhub.io/grafana-agent), [Options](https://charmhub.io/grafana-agent/configurations)
[mysql](https://charmhub.io/mysql), [Options](https://charmhub.io/mysql/configurations), [Actions](https://charmhub.io/mysql/actions)
[mysql-router](https://charmhub.io/mysql-router), [Options](https://charmhub.io/mysql-router/configurations), [Actions](https://charmhub.io/mysql-router/actions)
[influxdb](https://charmhub.io/influxdb), [Options](https://charmhub.io/influxdb/configurations), [Actions](https://charmhub.io/influxdb/actions)
:::

### Kubernetes charms

:::{csv-table}
:header: >
: charm, configuration options, actions
:widths: 15, 10, 10

[glauth-k8s](https://charmhub.io/glauth-k8s), [Options](https://charmhub.io/glauth-k8s/configurations)
[postgresql-k8s](https://charmhub.io/postgresql-k8s), [Options](https://charmhub.io/postgresql-k8s/configurations), [Actions](https://charmhub.io/postgresql-k8s/actions)
[traefik-k8s](https://charmhub.io/traefik-k8s), [Options](https://charmhub.io/traefik-k8s/configurations), [Actions](https://charmhub.io/traefik-k8s/actions)
[grafana-k8s](https://charmhub.io/grafana-k8s), [Options](https://charmhub.io/grafana-k8s/configurations), [Actions](https://charmhub.io/grafana-k8s/actions)
[prometheus-k8s](https://charmhub.io/prometheus-k8s), [Options](https://charmhub.io/prometheus-k8s/configurations), [Actions](https://charmhub.io/prometheus-k8s/actions)
[alertmanager-k8s](https://charmhub.io/alertmanager-k8s), [Options](https://charmhub.io/alertmanager-k8s/configurations), [Actions](https://charmhub.io/alertmanager-k8s/actions)
[loki-k8s](https://charmhub.io/loki-k8s), [Options](https://charmhub.io/loki-k8s/configurations)
[catalogue-k8s](https://charmhub.io/catalogue-k8s), [Options](https://charmhub.io/catalogue-k8s/configurations), [Actions](https://charmhub.io/catalogue-k8s/actions)
:::

## Integrations

Charmed HPC uses integrations to dictate how charmed applications communicate with each other.

:::{csv-table}
:header: >
: integration, interface implementation
:widths: 15, 10

[sackd](https://charmhub.io/integrations/sackd), [Charm library](https://github.com/charmed-hpc/slurm-charms/blob/main/charms/slurmctld/src/interface_sackd.py)
slurmctld, [Charm library](https://github.com/charmed-hpc/slurm-charms/blob/main/charms/slurmd/src/interface_slurmctld.py)
[slurmd](https://charmhub.io/integrations/slurmd), [Charm library](https://github.com/charmed-hpc/slurm-charms/blob/main/charms/slurmctld/src/interface_slurmd.py)
[slurmdbd](https://charmhub.io/integrations/slurmdbd), [Charm library](https://github.com/charmed-hpc/slurm-charms/blob/main/charms/slurmctld/src/interface_slurmdbd.py)
[slurmrestd](https://charmhub.io/integrations/slurmrestd), [Charm library](https://github.com/charmed-hpc/slurm-charms/blob/main/charms/slurmctld/src/interface_slurmrestd.py)
[cos_agent](https://charmhub.io/integrations/cos_agent), [Charm library](https://charmhub.io/grafana-agent/libraries/cos_agent)
[ldap](https://charmhub.io/integrations/ldap/), [Charm library](https://charmhub.io/glauth-k8s/libraries/ldap)
[mysql_client](https://charmhub.io/integrations/mysql_client), [Charm library](https://charmhub.io/data-platform-libs/libraries/data_interfaces)
[filesystem_info](https://charmhub.io/integrations/filesystem_info), [Charm library](https://charmhub.io/filesystem-client/libraries/filesystem_info)
[mount_info](https://charmhub.io/integrations/mount_info), [Charm library](https://charmhub.io/filesystem-client/libraries/mount_info)
:::
