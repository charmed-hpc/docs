---
relatedlinks: "[Get&#32;started&#32;with&#32;LXD](https://documentation.ubuntu.com/lxd/en/latest/tutorial/first_steps/), [Get&#32;started&#32;with&#32;Juju](https://juju.is/docs/juju/tutorial), [Slurm&#32;website](https://slurm.schedmd.com/overview.html)"
---

# Deploy the workload manager

An HPC workload manager is the base component of your Charmed HPC cluster.
All the applications and auxiliary services that can be deployed with Charmed HPC
are integrated with the workload manager to compose the functionality of your cluster.

[Slurm](https://slurm.schedmd.com/overview.html) is currently the only
supported workload manager implementation for Charmed HPC.

## Prerequisites

To successfully deploy the workload manager of your Charmed HPC cluster, you
will at least need:

- A machine running a [currently supported Ubuntu LTS version](https://ubuntu.com/about/release-cycle).
- An initialised [LXD](https://canonical.com/lxd) instance.
- A [Juju](https://juju.is) client.

## Getting started

Now, before you can deploy the workload manager of your cluster, you need to:

1. Initialise the machine cloud that will provide the instances that the workload
   manager's services will run within.
2. Create the model that will hold the workload manager's services.

### Initialise the machine cloud

To initialise the machine cloud that will provide the instances to your cluster,
bootstrap a Juju controller on your LXD instance:

```shell
juju bootstrap localhost charmed-hpc-controller
```

It will take a few minutes to bootstrap the Juju controller. Once the controller
has finished bootstrapping, move onto the next step for creating a model for the cluster.

### Create a model for the cluster

To create a Juju model for your cluster, use the following command:

```shell
juju add-model charmed-hpc
```

Now you're ready to deploy the workload manager for your Charmed HPC cluster!

## Deploy Slurm

Slurm can be deployed multiple ways using Juju.

```````{tabs}

``````{group-tab} CLI

To deploy Slurm via the Juju CLI, use the following commands:

```shell
# Deploy Slurm services.
juju deploy slurmctld --constraints="virt-type=virtual-machine"
juju deploy slurmd --constraints="virt-type=virtual-machine"
juju deploy slurmdbd --constraints="virt-type=virtual-machine"
juju deploy slurmrestd --constraints="virt-type=virtual-machine"
juju deploy mysql --channel "8.0/stable"
juju deploy mysql-router slurmdbd-mysql-router --channel "dpe/beta"

# Integrate services together.
juju integrate slurmctld:slurmd slurmd:slurmctld
juju integrate slurmctld:slurmdbd slurmdbd:slurmctld
juju integrate slurmctld:slurmrestd slurmrestd:slurmctld
juju integrate slurmdbd-mysql-router:backend-database mysql:database
juju integrate slurmdbd:database slurmdbd-mysql-router:database
```

``````

``````{group-tab} Bundle

`````{tabs}

````{group-tab} Charmhub

To deploy Slurm via the Slurm bundle published on [Charmhub](https://charmhub.io/slurm),
use the following command:

```shell
juju deploy slurm
```

````

````{group-tab} bundle.yaml

To deploy Slurm via a Juju bundle file, first open a file named _bundle.yaml_ in
your favourite text editor, and enter the following YAML content:

```yaml
description: Deploy a ready-to-go Slurm cluster.
series: jammy
name: slurm
applications:
  slurmctld:
    charm: slurmctld
    constraints: virt-type=virtual-machine
  slurmd:
    charm: slurmd
    constraints: virt-type=virtual-machine
  slurmdbd:
    charm: slurmdbd
    constraints: virt-type=virtual-machine
  slurmrestd:
    charm: slurmrestd
    constraints: virt-type=virtual-machine
  mysql:
    charm: mysql
    channel: 8.0/stable
  slurmdbd-mysql-router:
    charm: mysql-router
    channel: dpe/beta
relations:
- - slurmctld:slurmd
  - slurmd:slurmctld
- - slurmctld:slurmdbd
  - slurmdbd:slurmctld
- - slurmctld:slurmrestd
  - slurmrestd:slurmctld
- - slurmdbd-mysql-router:backend-database
  - mysql:database
- - slurmdbd:database
  - slurmdbd-mysql-router:database
```

Save and close the file after entering the YAML content, and use the following
command to deploy Slurm using your custom _bundle.yaml_ file:

```shell
juju deploy ./bundle.yaml
```

````

`````

``````

```````

```{note}
The instructions above pass `virt-type=virtual-machine` as a constraint to the Slurm charms
to instruct LXD to provide a virtual machine rather than a system container. Slurm does not
fully work within system containers unless some configuration modifications are applied to
the default LXD profile.
```

Your deployment will become active after a few minutes. The Slurm operators
will handle exchanging the necessary information such as compute node configuration,
partition data, and munge keys, so you can sit back and enjoy your coffee while
the operators handle the hard work ☕
