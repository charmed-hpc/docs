# Charmed HPC

Charmed HPC is a versatile high-performance computing platform that facilitates the set up and maintenance of HPC clusters. This is done by autonomizing the deployment, integration, and life-cycle management of essential cluster software that enables users to run modern workloads at scale.

Charmed HPC spins up turnkey clusters on a variety of cloud platforms to support write-once, run-anywhere user workloads. It also provides the necessary integrations for GPUs, high bandwidth networking, and shared storage.

The platform enables organizations to focus on obtaining key insights and making data-driven decisions by providing an HPC platform that solves the complexity of deploying and operating an HPC cluster at scale. It is directly beneficial to operations teams and system administrators looking to take full advantage of their HPC hardware, available storage configurations, and high bandwidth networking while minimizing cluster downtime for routine maintenance.

---

## In this documentation


````{grid} 1 2 3 3



```{grid-item-card} [How-to guides](howto/index)

__Step-by-step guides__ covering key operations and common tasks

- {ref}`Initialize cloud environment <howto-initialize-cloud-environment>`
- {ref}`howto-setup`
- {ref}`howto-manage`
- {ref}`Clean up cloud resources <howto-cleanup-cloud-resources>`

```


```{grid-item-card} [Explanation](explanation/index)

__Discussion and clarification__ of key topics

 - {ref}`cryptography`
 - {ref}`explanation-gpus`
 - {ref}`explanation-interconnects`

```


```{grid-item-card} [Reference](reference/index)

__Technical information__

- {ref}`reference-underlying-projects-and-dependencies`
- {ref}`GPU resource scheduling <gres>`
- {ref}`reference-interconnects`
- {ref}`reference-performance`
- {ref}`reference-monitoring`
<!-- - {ref}`reference-glossary` -->
```

````

---

## Project and community

Charmed HPC is an open-source project of the [Ubuntu High-Performance Computing
community](https://ubuntu.com/community/governance/teams/hpc).
Interested in contributing bug fixes, patches, documentation, or feedback?
Want to join the Ubuntu HPC community? You've come to the right place!

Here's some links to help you get started with joining the community:

* [Read and follow the Ubuntu Code of Conduct](https://ubuntu.com/community/ethos/code-of-conduct)
* [Join the Ubuntu HPC community on Matrix](https://matrix.to/#/#hpc:ubuntu.com)
* [Get the latest news on Discourse](https://discourse.ubuntu.com/c/hpc/151)
* [See our Contributing guide](https://github.com/charmed-hpc/.github/blob/main/CONTRIBUTING.md)
* [Visit the Charmed HPC GitHub Organization for more information or to ask for support](https://github.com/charmed-hpc)

```{filtered-toctree}
:hidden:
:titlesonly:

self
howto/index
explanation/index
reference/index
```
