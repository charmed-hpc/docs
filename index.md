# Charmed HPC

Charmed HPC is a platform for managing high-performance computing clusters. It automates the lifecycle of essential cluster software and processes, such as workload management, shared storage, GPU access, and high-bandwidth networking. This allows operations teams and systems administrators to focus on running workloads rather than maintaining infrastructure.
<!-- Charmed HPC is a versatile high-performance computing platform that facilitates the set up and maintenance of HPC clusters. This is done by autonomizing the deployment, integration, and life-cycle management of essential cluster software that enables users to run modern workloads at scale.

Charmed HPC spins up turnkey clusters on a variety of cloud platforms to support write-once, run-anywhere user workloads. It also provides the necessary integrations for GPUs, high bandwidth networking, and shared storage.

The platform enables organizations to focus on obtaining key insights and making data-driven decisions by providing an HPC platform that solves the complexity of deploying and operating an HPC cluster at scale. It is directly beneficial to operations teams and system administrators looking to take full advantage of their HPC hardware, available storage configurations, and high bandwidth networking while minimizing cluster downtime for routine maintenance. -->

---

## In this documentation

- __Learn more about Charmed HPC:__ [Getting Started tutorial](tutorial-getting-started-with-charmed-hpc), [Underlying projects](reference/underlying-projects-and-dependencies.md)
- __Workload management:__ [Deploy Slurm](howto/deploy/deploy-slurm.md), [Manage Slurm](howto/manage/manage-slurm.md), [Clean up Slurm](howto/cleanup/cleanup-slurm.md), [Grafana Dashboards](reference/monitoring/grafana-dashboards.md)
- __Storage and Resources:__ [Deploy shared filesystem](howto/deploy/deploy-shared-filesystem.md), [GPUs](explanation/gpus.md), [GRES](reference/gpus.md), [Interconnects](explanation/interconnects.md)
- __Security and Identity:__ [Deploy identity provider](howto/deploy/deploy-identity-provider.md), [Hardening guidelines](reference/hardening.md), [Cryptography](explanation/cryptography.md)
- __Performance:__ [High availability](explanation/high-availability.md), [Benchmarks](reference/performance.md)

## How this documentation is organized

This documentation uses the [Diátaxis](https://diataxis.fr/) documentation structure.

* The [Tutorial](tutorial-getting-started-with-charmed-hpc) takes you step-by-step through building a small Charmed HPC cluster, submitting batch jobs, and using container images.

* [How-to guides](howto/index) assume you have basic familiarity with Charmed HPC. They cover key operations for [deploy](howto/deploy/index.md), [integration](howto/integrate/index.md), [management](howto/manage/index.md), and [usage](howto/run-workloads/index.md).

* [Reference](reference/index) provides technical information such as [underlying projects and dependencies](reference/underlying-projects-and-dependencies.md), [monitoring](reference/monitoring/index.md), and [performance benchmarks](reference/performance.md).

* [Explanation](explanation/index) includes topic overviews, background and context, and detailed discussions of key concepts.
---

## Project and community

Charmed HPC is an Ubuntu community project. It's an open source project that warmly welcomes community contributions, suggestions, fixes, and constructive feedback.

**Get involved**

* [Support](https://github.com/orgs/charmed-hpc/discussions/categories/support)
* [Online chat](https://matrix.to/#/#hpc:ubuntu.com)
* [Contribute](contributing/index)

<!-- **Releases**

* [Release notes](https://discourse.ubuntu.com/c/hpc/151)
* [Roadmap](https://github.com/orgs/charmed-hpc/projects) -->

**Governance and policies**

* [Code of Conduct](https://ubuntu.com/community/ethos/code-of-conduct)
<!-- * [Commercial support](https://ubuntu.com/pro) -->

Thinking about using Charmed HPC for your next project? [Get in touch!](https://matrix.to/#/#hpc:ubuntu.com)

```{filtered-toctree}
:hidden:
:titlesonly:

Getting started <getting-started>
howto/index
explanation/index
reference/index
contributing/index
```
