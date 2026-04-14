(reference)=
# Reference

The reference material in this section provides technical descriptions of how
Charmed HPC operates.

## Cluster components and architecture

The building blocks and structure of a Charmed HPC cluster.

- {ref}`reference-underlying-projects-and-dependencies`
- {ref}`reference-glossary`

## Hardware and networking

Available hardware resources and network infrastructure.

- GPU scheduling: {ref}`GPU resource scheduling in Slurm <gres>`
- Interconnects: {ref}`reference-interconnects`

## Security

Security considerations for your cluster.

- {ref}`reference-hardening`

## Monitoring

Observability and monitoring reference information.

- Dashboards: {ref}`reference-monitoring-grafana`
- Metrics and alerts: {ref}`reference-monitoring-prometheus`
- Logs: {ref}`reference-monitoring-loki`

## Performance

Performance benchmarks and methodology.

- {ref}`reference-performance`


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
