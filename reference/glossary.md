(reference-glossary)=
# Glossary

```{glossary}

Amazon Web Services (AWS)
    A cloud platform provided by Amazon.

    Resources: 🌐[AWS website](https://aws.amazon.com/)

Apptainer
    HPC-focused container runtime. Formerly Singularity.

    Resources: 🌐[Apptainer - Portable, Reproducible Containers](https://apptainer.org/), 🌐[apptainer charm](https://charmhub.io/apptainer)

Canonical Observability Stack (COS)
    Suite of charms providing open-source monitoring and logging tools.

    Resources: 🌐[Canonical observability documentation](https://documentation.ubuntu.com/observability)

Ceph
    Distributed storage system that provides object, block, and file storage. Can be deployed and
    managed using {term}`MicroCeph`.

    Resources: 🌐[Ceph website](https://ceph.io)

CephFS
    POSIX-compliant file system interface that runs on top of a Ceph storage cluster.

    Resources: 🌐[Ceph file system](https://docs.ceph.com/en/latest/cephfs/), 🌐[ceph-fs charm](https://charmhub.io/ceph-fs)

Charm
    Python software for automating the lifecycle of applications. Also known as a charmed operator.
    Managed with Juju. Two kinds of charm exist:

    1. **Machine charms:** charms made to deploy on a bare-metal server, virtual machine, or system
    container
    2. **Kubernetes charms:** charms built to deploy on Kubernetes.

    Resources: 🌐[Juju charm definition](https://documentation.ubuntu.com/juju/latest/reference/charm/)

Cluster
    A collection of distinct computers, known as nodes, networked together to act as a single, more
    powerful system.

`filesystem-client`
    A charm that requests and mounts exported filesystems on virtual machines.

    Resources: 🌐[filesystem-client charm](https://charmhub.io/filesystem-client)

Graphics Processing Unit (GPU)
    A specialized processor that is designed to accelerate image processing and graphics rendering
    for output to a display device.

High-Performance Computing (HPC)
    The practice of aggregating computing power using clusters and parallel processing to complete
    tasks faster than standard computing.

InfluxDB
    An open-source, distributed, time series database.

    Resources: 🌐[InfluxData site](https://www.influxdata.com/), 🌐[influxdb charm](https://charmhub.io/influxdb)

Integration
    An exchange of data between two charms that allows for interoperability. Formerly known as a
    relation.

    Resources: 🌐[Juju integrations explained](https://canonical.com/juju/integrations)

Job
    A user-submitted workload managed by the cluster workload manager. Consists of a script
    containing the executable commands to run an application and declarations of the resources
    required for that application, such as CPU core count and walltime.

Juju
    A charmed operator tool that helps deploy, integrate and manage applications across multiple
    environments.

    Resources: 🌐[Juju documentation](https://documentation.ubuntu.com/juju/latest/)

MicroCeph
    A tool that simplifies deployment and management of Ceph storage both standalone and in a
    charmed environment using Juju.

    Resources: 🌐[MicroCeph documentation](https://canonical-microceph.readthedocs-hosted.com/stable/), 🌐[microceph charm](https://charmhub.io/microceph)

Microsoft Azure
    A cloud platform provided by Microsoft.

    Resources: 🌐[Microsoft Azure website](https://azure.microsoft.com/)

Proxy charm
    An intermediary charm that enables charms to integrate with non-charmed applications. Also known
    as an integrator charm.

`sackd`
    Slurm Auth and Credential Kiosk daemon. Typically used to provide cluster login nodes.

    Resources: 🌐[Slurm Workload Manager - sackd](https://slurm.schedmd.com/sackd.html), 🌐[sackd charm](https://charmhub.io/sackd)

Slurm
    A free and open source workload manager consisting of multiple co-operating software components,
    each responsible for a piece of cluster functionality.

    Resources: 🌐[Slurm Workload Manager - Documentation](https://slurm.schedmd.com/documentation.html)

`slurmctld`
    Slurm central management/controller daemon. Schedules jobs and monitors other components.

    Resources: 🌐[Slurm Workload Manager - slurmctld](https://slurm.schedmd.com/slurmctld.html), 🌐[slurmctld charm](https://charmhub.io/slurmctld)

`slurmd`
    Slurm compute node daemon. Executes jobs scheduled by the controller.

    Resources: 🌐[Slurm Workload Manager - slurmd](https://slurm.schedmd.com/slurmd.html), 🌐[slurmd charm](https://charmhub.io/slurmd)

`slurmdbd`
    Slurm accounting database daemon. Provides an interface between Slurm and a database for holding
    historic job statistics.

    Resources: 🌐[Slurm Workload Manager - slurmdbd](https://slurm.schedmd.com/slurmdbd.html), 🌐[slurmdbd charm](https://charmhub.io/slurmdbd)

`slurmrestd`
    REST API interface for Slurm.

    Resources: 🌐[Slurm Workload Manager - slurmrestd](https://slurm.schedmd.com/slurmrestd.html), 🌐[slurmrestd charm](https://charmhub.io/slurmrestd)

`slurmutils`
    Python library for facilitating edits to Slurm configuration files.

    Resources: 🌐[slurmutils GitHub](https://github.com/charmed-hpc/slurmutils)

System Security Services Daemon (`sssd`)
    A daemon that manages the retrieval and caching of user credentials and attributes from remote
    identity providers.

    Refers to both the software and the corresponding charm.

    Resources: 🌐[SSSD - System Security Services Daemon - sssd.io](https://sssd.io), 🌐[sssd charm](https://charmhub.io/sssd)

Walltime
    The maximum duration of a job declared in the job script. Serves as a limit after which the
    workload manager will forcibly end the job.

Workload manager
    Software responsible for accepting user jobs, placing them in a queue, and deciding where and
    when they will run on a cluster - the process known as: job scheduling. Optimizes utilization
    of a cluster by matching job requirements (CPU core count, walltime) to available hardware
    while enforcing site-specific usage policies. Slurm is a workload manager.
```

