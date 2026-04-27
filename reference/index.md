(reference)=
# Reference

Technical specifications and data for Charmed HPC, covering configurations, supported values, and cluster components.

## System architecture

- {ref}`reference-underlying-projects-and-dependencies`

## Hardware and networking

- {ref}`GPU resource scheduling in Slurm <gres>`
- {ref}`reference-interconnects`

## Security

Security configurations, recommendations, and reference data for the components of a Charmed HPC cluster.

- {ref}`Slurm hardening <reference-hardening-slurm>`
- {ref}`Cloud hardening <reference-hardening-cloud>`
- {ref}`Juju hardening <reference-hardening-juju>`
- {ref}`Monitoring and auditing <reference-hardening-monitoring>`
- {ref}`Operating system hardening <reference-hardening-os>`

## Monitoring

Dashboards, metrics, and log queries available when COS is integrated with a Charmed HPC cluster.

- {ref}`reference-monitoring-grafana`
- {ref}`reference-monitoring-prometheus`
- {ref}`reference-monitoring-loki`

## Performance

Reference data for evaluating and tuning the performance of a Charmed HPC cluster, including benchmarks and hardware-specific metrics.

- {ref}`Benchmark results on Microsoft Azure <reference-performance>`

## Terminology

- {ref}`reference-glossary`


```{filtered-toctree}
:titlesonly:
:maxdepth: 1
:hidden:

Underlying projects and dependencies <underlying-projects-and-dependencies>
gpus
interconnects
monitoring/index
Performance <performance>
hardening
glossary

```
