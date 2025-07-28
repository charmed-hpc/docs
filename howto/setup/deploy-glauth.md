---
relatedlinks: "[GLAuth&#32;website](https://glauth.github.io), [GLAuth&#32;(Charmhub)](https://charmhub.io/glauth-k8s), [GLAuth&#32;charm&#32;repository](https://github.com/canonical/glauth-k8s), [SSSD&#32;website](https://sssd.io), [SSSD&#32;(Charmhub)](https://charmhub.io/sssd), [SSSD&#32;charm&#32;repository](https://github.com/canonical/sssd-operator)"
myst:
  substitutions:
    glauth_plan_name: "glauth/main.tf"
    sssd_plan_name: "sssd/main.tf"
    connect_plan_name: "connect-sssd-to-glauth/main.tf"
---

(howto-setup-deploy-glauth)=
# How to deploy GLAuth and SSSD

This how-to guide shows you how to set up an {{ iam }}
stack for your Charmed HPC cluster by deploying GLAuth as an LDAP server,
and SSSD as the service for enrolling your cluster's machines with GLAuth.
The deployment, management, operations of both GLAuth and SSSD are controlled by
the GLAuth and SSSD charms, respectively.

:::{hint}
If you're unfamiliar with operating GLAuth, see the [GLAuth quick start](https://glauth.github.io/docs/quickstart.html)
guide for a high-level introduction to GLAuth. If you're unfamiliar with
integrating SSSD with an LDAP server, see the [SSSD with LDAP](https://documentation.ubuntu.com/server/how-to/sssd/with-ldap/)
how-to guide for a high-level introduction to integrating SSSD with an LDAP server
such as GLAuth.
:::

## Prerequisites

- An active [Slurm deployment](#howto-setup-deploy-slurm) in your [`charmed-hpc` machine cloud](#howto-initialize-machine-cloud).
- An initialized [`charmed-hpc-k8s` Kubernetes cloud](#howto-initialize-kubernetes-cloud).
- The [Juju CLI client](https://documentation.ubuntu.com/juju/latest/user/howto/manage-juju/) installed on your machine.

## Deploy GLAuth and SSSD

You have two options for deploying GLAuth and SSSD:

1. Using the [Juju CLI client](https://documentation.ubuntu.com/juju/latest/user/reference/juju-cli/).
2. Using the [Juju Terraform client](https://canonical-terraform-provider-juju.readthedocs-hosted.com/en/latest/).

If you want to use Terraform to deploy GLAuth and SSSD, see the
[Manage `terraform-provider-juju`](https://canonical-terraform-provider-juju.readthedocs-hosted.com/en/latest/howto/manage-the-terraform-provider-for-juju/) how-to guide for additional
requirements.

### Deploy GLAuth

:::::{tab-set}

::::{tab-item} CLI
:sync: cli

First, use `juju add-model`{l=shell} to create the `iam` model in your
`charmed-hpc-k8s` Kubernetes cloud:

:::{code-block} shell
juju add-model iam charmed-hpc-k8s
:::

Now, with the `iam` model created, use `juju deploy`{l=shell} to deploy
GLAuth with Postgres as GLAuth's database back-end:

:::{code-block} shell
juju deploy glauth-k8s --channel "edge" \
  --config anonymousdse_enabled=true \
  --trust
juju deploy postgresql-k8s --channel "14/stable" --trust
juju deploy self-signed-certificates
juju deploy traefik-k8s --trust
:::

:::{include} /reuse/admonition/important-glauth-trust.md
:::

Now run the following set of commands to integrate GLAuth and the other
deployed applications together with `juju integrate`{l=shell}:

:::{code-block} shell
juju integrate glauth-k8s postgresql-k8s
juju integrate glauth-k8s self-signed-certificates
juju integrate glauth-k8s:ingress traefik-k8s
:::

:::{include} /reuse/terminal/iam-status.md
:::

::::

::::{tab-item} Terraform
:sync: terraform

First, create the Terraform deployment plan file _{{ glauth_plan_name }}_
using the following set of commands:

:::{code-block} shell
mkdir glauth
touch glauth/main.tf
:::

Now, editing _{{ glauth_plan_name }}_, configure your plan to use the Juju
Terraform provider:

:::{literalinclude} /reuse/terraform/glauth.tf
:caption: {{ glauth_plan_name }}
:language: terraform
:lines: 1-8
:::

Now, using the `juju_model` resource, direct Juju to create the `iam` model
on your `charmed-hpc-k8s` Kubernetes cloud:

:::{literalinclude} /reuse/terraform/glauth.tf
:caption: {{ glauth_plan_name }}
:language: terraform
:lines: 10-16
:::

Now declare the following modules in your deployment plan
to load in GLAuth. These Terraform modules will direct Juju to deploy GLAuth
with Postgres as GLAuth's database back-end:

:::{literalinclude} /reuse/terraform/glauth.tf
:caption: {{ glauth_plan_name }}
:language: terraform
:lines: 18-43
:::

:::{include} /reuse/admonition/important-glauth-trust.md
:::

Now, using the `juju_integration` resource, direct Juju to integrate GLAuth
and the other deployed applications together:

:::{literalinclude} /reuse/terraform/glauth.tf
:caption: {{ glauth_plan_name }}
:language: terraform
:lines: 45-81
:::

With all the `juju_model` and `juju_integration` resources declared, and all
the charm modules loaded, you are now ready to deploy GLAuth using your _{{ glauth_plan_name }}_
deployment plan. You can expand the dropdown below to see the full plan:

:::{dropdown} Full _{{ glauth_plan_name }}_ deployment plan
:::{literalinclude} /reuse/terraform/glauth.tf
:caption: {{ glauth_plan_name }}
:language: terraform
:linenos:
:::
:::

To deploy GLAuth using your deployment plan, run the following `terraform` commands:

:::{code-block} shell
terraform -chdir=glauth init
terraform -chdir=glauth apply -auto-approve
:::

:::{include} /reuse/terminal/iam-status.md
:::

::::

:::::

### Deploy SSSD

:::::{tab-set}

::::{tab-item} CLI
:sync: cli

First, use `juju switch`{l=shell} to switch from the `iam` model in your
`charmed-hpc-k8s` Kubernetes cloud to the `slurm` model in your `charmed-hpc`
machine cloud:

:::{code-block} shell
juju switch slurm
:::

Now use `juju deploy`{l=shell} to deploy SSSD:

:::{code-block} shell
juju deploy sssd --base "ubuntu@24.04" --channel "edge"
:::

Now use `juju integrate`{l=shell} to integrate SSSD with the Slurm services
`sackd` and `slurmd`:

:::{code-block} shell
juju integrate sssd sackd
juju integrate sssd slurmd
:::

:::{include} /reuse/terminal/slurm-status-sssd-no-glauth.md
:::

::::

::::{tab-item} Terraform
:sync: terraform

First, create the Terraform deployment plan file _{{ sssd_plan_name }}_
using the following set of commands:

:::{code-block} shell
mkdir sssd
touch sssd/main.tf
:::

Now, editing _{{ sssd_plan_name }}_, configure your plan to use the Juju
Terraform provider:

:::{literalinclude} /reuse/terraform/sssd.tf
:caption: {{ sssd_plan_name }}
:language: terraform
:lines: 1-8
:::

Now declare the following external data sources in your deployment plan. These
data sources make Terraform aware of your pre-existing `slurm` model,
as well as the `sackd` and `slurmd` applications:

:::{literalinclude} /reuse/terraform/sssd.tf
:caption: {{ sssd_plan_name }}
:language: terraform
:lines: 10-22
:::

Now declare the following module in your deployment plan to load in SSSD.
This Terraform module will direct Juju to deploy SSSD in your `slurm` module:

:::{literalinclude} /reuse/terraform/sssd.tf
:caption: {{ sssd_plan_name }}
:language: terraform
:lines: 24-27
:::

Now, using the `juju_integration` resource, direct Juju to integrate SSSD
with the `sackd` and `slurmd` applications:

:::{literalinclude} /reuse/terraform/sssd.tf
:caption: {{ sssd_plan_name }}
:language: terraform
:lines: 29-51
:::

With the `juju_integration` resources declared, and modules and external data
sources loaded, you are now ready to deploy SSSD using your _{{ sssd_plan_name }}_
deployment plan. You can expand the dropdown below to see the full plan:

:::{dropdown} Full _{{ sssd_plan_name }}_ deployment plan
:::{literalinclude} /reuse/terraform/sssd.tf
:caption: {{ sssd_plan_name }}
:language: terraform
:linenos:
:::
:::

To deploy SSSD using your deployment plan, run the following `terraform` commands:

:::{code-block} shell
terraform -chdir=sssd init
terraform -chdir=sssd apply -auto-approve
:::

:::{include} /reuse/terminal/slurm-status-sssd-no-glauth.md
:::

::::

:::::

### Connect SSSD to GLAuth

:::::{tab-set}

::::{tab-item} CLI
:sync: cli

First, create offers for GLAuth in your `iam` model using `juju offer`{l=shell}:

:::{code-block} shell
juju offer iam.glauth-k8s:ldap ldap
juju offer iam.glauth-k8s:send-ca-cert ldap-certs
:::

After creating the offers in your `iam` model, use `juju consume`{l=shell} to the
consume the offers in your `slurm` model:

:::{code-block} shell
juju consume iam.ldap
juju consume iam.ldap-certs
:::

Now use `juju integrate`{l=shell} to connect SSSD to the GLAuth endpoints:

:::{code-block} shell
juju integrate ldap sssd
juju integrate ldap-certs sssd
:::

:::{include} /reuse/terminal/slurm-status-sssd-with-glauth.md
::::

::::{tab-item} Terraform
:sync: terraform

First, create the Terraform deployment plan file _{{ connect_plan_name }}_
using the following set of commands:

:::{code-block} shell
mkdir connect-sssd-to-glauth
touch connect-sssd-to-glauth/main.tf
:::

Now, editing _{{ connect_plan_name }}_, configure your plan to use the Juju
Terraform provider:

:::{literalinclude} /reuse/terraform/connect-sssd-to-glauth.tf
:caption: {{ connect_plan_name }}
:language: terraform
:lines: 1-8
:::

Now declare the following external data sources in your plan. These
data sources make Terraform aware of your pre-existing `iam` and `slurm` models,
as well as the `glauth-k8s` and `sssd` applications:

:::{literalinclude} /reuse/terraform/connect-sssd-to-glauth.tf
:caption: {{ connect_plan_name }}
:language: terraform
:lines: 10-26
:::

Now, using the `juju_offer` resource, direct Juju to create offers
for GLAuth in the `iam` model:

:::{literalinclude} /reuse/terraform/connect-sssd-to-glauth.tf
:caption: {{ connect_plan_name }}
:language: terraform
:lines: 28-40
:::

After declaring the offers, use the `juju_integration` resource to direct
Juju to consume and integrate SSSD with the GLAuth offers in the `slurm` model:

:::{literalinclude} /reuse/terraform/connect-sssd-to-glauth.tf
:caption: {{ connect_plan_name }}
:language: terraform
:lines: 42-64
:::

With the `juju_offer` and `juju_integration` resources declared, and external
data sources loaded, you are now ready to connect SSSD to GLAuth using
your _{{ connect_plan_name }}_ plan. You can expand the dropdown below to
see the full plan:

:::{dropdown} Full _{{ connect_plan_name }}_ plan
:::{literalinclude} /reuse/terraform/connect-sssd-to-glauth.tf
:caption: {{ connect_plan_name }}
:language: terraform
:linenos:
:::
:::

To use your plan to connect SSSD to GLAuth, run the following `terraform` commands:

:::{code-block} shell
terraform -chdir=connect-sssd-to-glauth init
terraform -chdir=connect-sssd-to-glauth apply -auto-approve
:::

:::{include} /reuse/terminal/slurm-status-sssd-with-glauth.md
:::

::::

:::::

## Next steps

You can now use GLAuth and SSSD as the {{ iam }} stack to manage users
and groups on your Charmed HPC cluster. See the [Access Postgres](https://canonical-charmed-postgresql-k8s.readthedocs-hosted.com/14/tutorial/#access-the-related-database)
tutorial for how to access your deployed Postgres database, and
[GLAuth's documentation](https://glauth.github.io/docs/databases.html) for how to manage users and groups on your
cluster using SQL queries.
