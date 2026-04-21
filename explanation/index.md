(explanation)=
# Explanation

Background context and design discussion for key topics.

## Cluster architecture

The design decisions behind the architecture, including high availability and email notifications for job status.

- {ref}`explanation-high-availability`
- {ref}`explanation-job-email-notifications`

## Cryptography, authentication, and security

The mechanisms used to secure communication between cluster components and authenticate users and services.

- {ref}`sack`
- {ref}`jwt`
- {ref}`explanation-key-rotation`

## Hardware

The role of specialised hardware in a cluster, including GPU acceleration, high-speed interconnects, and the provisioning steps that happen at deployment time.

- {ref}`explanation-gpus`
- {ref}`explanation-interconnects`
- {ref}`explanation-rebooting`

```{toctree}
:titlesonly:
:maxdepth: 1
:hidden:

Cryptography and Authentication <cryptography>
Email notifications for jobs <job-email-notifications>
GPUs <gpus>
High Availability <high-availability>
Interconnects <interconnects>
Instance auto-reboots <reboot-timing.md>
Key rotation <key-rotation>
```
