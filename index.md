# Charmed HPC

Charmed HPC is a versatile high-performance computing platform that facilitates the set up and maintenance of HPC clusters. This is done by autonomizing the deployment, integration, and life-cycle management of essential cluster software that enables users to run modern workloads at scale.

Charmed HPC spins up turnkey clusters on a variety of cloud platforms to support write-once, run-anywhere user workloads. It also provides the necessary integrations for GPUs, high bandwidth networking, and shared storage.

The platform enables organizations to focus on obtaining key insights and making data-driven decisions by providing an HPC platform that solves the complexity of deploying and operating an HPC cluster at scale. It is directly beneficial to operations teams and system administrators looking to take full advantage of their HPC hardware, available storage configurations, and high bandwidth networking while minimizing cluster downtime for routine maintenance.

---

## In this documentation

- __Learn more about Charmed HPC:__ [Getting Started tutorial](tutorial-getting-started-with-charmed-hpc), [Underlying projects](reference/underlying-projects-and-dependencies.md)
- __Workload management:__ [Deploy Slurm](howto/setup/deploy-slurm.md), [Manage Slurm](howto/manage/manage-slurm.md), [Clean up Slurm](howto/cleanup/cleanup-slurm.md), [Grafana Dashboards](reference/monitoring/grafana.md) 
- __Storage and Resources:__ [Deploy shared filesystem](howto/setup/deploy-shared-filesystem.md), [GPUs](explanation/gpus.md), [GRES](reference/gpus.md), [Interconnects](explanation/interconnects.md)
- __Security and Identity:__ [Deploy identity provider](howto/setup/deploy-identity-provider.md), [Hardening guidelines](reference/hardening.md), [Cryptography](explanation/cryptography.md)
- __Performance:__ [High availability](explanation/high-availability.md), [Benchmarks](reference/performance.md)

## How this documentation is organised

This documentation uses the [Diátaxis](https://diataxis.fr/) documentation structure.

* The [Tutorial](tutorial-getting-started-with-charmed-hpc) takes you step-by-step through building a small Charmed HPC cluster, submitting batch jobs, and using container images.

* [How-to guides](howto/index) assume you have basic familiarity with Charmed HPC. They cover key operations for [setup](howto/setup/index.md), [integration](howto/integrate/index.md), [management](howto/manage/index.md), and [usage](howto/use/index.md).

* [Reference](reference/index) provides technical information such as [underlying projects and dependencies](reference/underlying-projects-and-dependencies.md), [monitoring](reference/monitoring/index.md), and [performance benchmarks](reference/performance.md).


---

## Project and community

Charmed HPC is an open source project of the [Ubuntu High-Performance Computing
community](https://ubuntu.com/community/governance/teams/hpc).
Interested in contributing bug fixes, patches, documentation, or feedback?
Want to join the Ubuntu HPC community? You've come to the right place!

Here's some links to help you get started with joining the community:

* [Read and follow the Ubuntu Code of Conduct](https://ubuntu.com/community/ethos/code-of-conduct)
* [Join the Ubuntu HPC community on Matrix](https://matrix.to/#/#hpc:ubuntu.com)
* [Get the latest news on Discourse](https://discourse.ubuntu.com/c/hpc/151)
* [Visit the Charmed HPC GitHub Organization](https://github.com/charmed-hpc)
* [Ask and answer support questions on GitHub](https://github.com/orgs/charmed-hpc/discussions/categories/support)

```{filtered-toctree}
:hidden:
:titlesonly:

Getting started <getting-started>
howto/index
explanation/index
reference/index
contributing/index
```
