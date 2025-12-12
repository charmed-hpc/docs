(reference-glossary)=
# Glossary

```{glossary}

Amazon Web Services (AWS)
    A cloud platform provided by Amazon that can be used to host Charmed HPC.

    Resources:
    - [AWS website](https://aws.amazon.com/)

Apptainer
    HPC-focused container runtime. Formerly Singularity.

    Refers to both the software and the corresponding charm.

    Resources:
    - [Apptainer - Portable, Reproducible Containers](https://apptainer.org/)
    - [Charmhub | apptainer](https://charmhub.io/apptainer)

Canonical Observability Stack (COS)
    Suite of charms providing open-source monitoring and logging tools.

    Resources:
    - [Canonical observability documentation](https://documentation.ubuntu.com/observability)

Ceph
    Distributed storage system that provides object, block, and file storage.

CephFS
    POSIX-compliant file system interface that runs on top of a Ceph storage cluster.

Charm
    Python software for automating the lifecycle of applications. Also known as a charmed operator.
    Managed with Juju. Two kinds of charm exist:

    1. **Machine charms:** charms made to deploy on a bare-metal server, virtual machine, or system
    container
    2. **Kubernetes charms:** charms built to deploy on Kubernetes.

Cluster
    A collection of distinct computers, known as nodes, networked together to act as a single, more
    powerful system.

`filesystem-client`
    A charm that requests and mounts exported filesystems on virtual machines.

    Resources:
    - [Charmhub | filesystem-client](https://charmhub.io/filesystem-client)

Graphics Processing Unit (GPU)
    A specialized processor that is designed to accelerate image processing and graphics rendering
    for output to a display device.

High-Performance Computing (HPC)
    The practice of aggregating computing power using clusters and parallel processing to complete
    tasks faster than standard computing.

InfluxDB
    An open-source, distributed, time series database.

    Refers to both the software and the corresponding charm.

    Resources:
    - [InfluxData site](https://www.influxdata.com/)
    - [Charmhub | influxdb](https://charmhub.io/influxdb)

Integration
    An exchange of data between two charms that allows for interoperability. Formerly known as a
    relation.

    Resources:
    - [Juju integrations explained](https://canonical.com/juju/integrations)

Job
    A user-submitted workload managed by the cluster workload manager. Consists of a script
    containing the executable commands to run an application and declarations of the resources
    required for that application, such as CPU core count and walltime.

Juju
    A charmed operator tool that helps deploy, integrate and manage applications across multiple
    environments.

    Resources:
    - [Juju Documentation](https://documentation.ubuntu.com/juju/latest/)

Microsoft Azure
    A cloud platform provided by Microsoft that can be used to host Charmed HPC.

    Resources:
    - [Microsoft Azure website](https://azure.microsoft.com/)

Proxy charm
    An intermediary charm that enables charms to integrate with non-charmed applications. Also known
    as an integrator charm.

`sackd`
    Slurm Auth and Credential Kiosk daemon. Typically used to provide cluster login nodes.

    Refers to both the software component of Slurm and the corresponding charm.

    Resources:
    - [Slurm Workload Manager - sackd](https://slurm.schedmd.com/sackd.html)
    - [Charmhub | sackd](https://charmhub.io/sackd)

Slurm
    A free and open source workload manager consisting of multiple co-operating software components,
    each responsible for a piece of cluster functionality.

    Resources:
      - [Slurm Workload Manager - Documentation](https://slurm.schedmd.com/documentation.html)

`slurmctld`
    Slurm central management/controller daemon. Schedules jobs and monitors other components.

    Refers to both the software component of Slurm and the corresponding charm.

    Resources:
    - [Slurm Workload Manager - slurmctld](https://slurm.schedmd.com/slurmctld.html)
    - [Charmhub | slurmctld](https://charmhub.io/slurmctld)

`slurmd`
    Slurm compute node daemon. Executes jobs scheduled by the controller.

    Refers to both the software component of Slurm and the corresponding charm.

    Resources:
    - [Slurm Workload Manager - slurmd](https://slurm.schedmd.com/slurmd.html)
    - [Charmhub | slurmd](https://charmhub.io/slurmd)

`slurmdbd`
    Slurm accounting database daemon. Provides an interface between Slurm and a database for holding
    historic job statistics.

    Refers to both the software component of Slurm and the corresponding charm.

    Resources:
    - [Slurm Workload Manager - slurmdbd](https://slurm.schedmd.com/slurmdbd.html)
    - [Charmhub | slurmdbd](https://charmhub.io/slurmdbd)

`slurmrestd`
    REST API interface for Slurm.

    Refers to both the software component of Slurm and the corresponding charm.

    Resources:
    - [Slurm Workload Manager - slurmrestd](https://slurm.schedmd.com/slurmrestd.html)
    - [Charmhub | slurmrestd](https://charmhub.io/slurmrestd)

`slurmutils`
    Python library for facilitating edits to Slurm configuration files.

    Resources:
    - [slurmutils GitHub](https://github.com/charmed-hpc/slurmutils)

System Security Services Daemon (`sssd`)
    A daemon that manages the retrieval and caching of user credentials and attributes from remote
    identity providers.

    Refers to both the software and the corresponding charm.

    Resources:
    - [SSSD - System Security Services Daemon - sssd.io](https://sssd.io)
    - [Charmhub | sssd](https://charmhub.io/sssd)

Walltime
    The maximum duration of a job declared in the job script. Serves as a limit after which the
    workload manager will forcibly end the job.

Workload manager
    Software responsible for accepting user jobs, placing them in a queue, and deciding where and
    when they will run on a cluster - the process known as: job scheduling. Optimizes utilization
    of a cluster by matching job requirements (CPU core count, walltime) to available hardware
    while enforcing site-specific usage policies. Slurm is a workload manager.
```

