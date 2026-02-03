(howto-job-email-notifications)=
# Enable job email notifications

This how-to guide demonstrates the steps necessary to enable email notifications of user job status
changes on a Charmed HPC cluster.

## Prerequisites

* A [Slurm Cluster](howto-setup-deploy-slurm) deployed with a `slurmdbd` accounting database.
* A pre-configured SMTP server.

## Deployment

Deploy the [`smtp-integrator` charm](https://charmhub.io/smtp-integrator) configured against the
SMTP server, then integrate with the cluster `slurmctld` controller on the `smtp`
interface:

:::::{tab-set}

::::{tab-item} CLI
:sync: cli

:::{code-block} shell
juju deploy smtp-integrator --config host=smtp.example.com --config port=587
juju integrate slurmctld smtp-integrator:smtp
:::

::::

::::{tab-item} Terraform
:sync: terraform

:::{code-block} terraform
:caption: `main.tf`
module "smtp_integrator" {
  source = "git::https://github.com/canonical/smtp-integrator-operator//terraform"
  model_uuid = juju_model.slurm.uuid
  config = {
    host = "smtp.example.com"
    port = 587
  }
}

resource "juju_integration" "smtp_integrator_to_slurmctld" {
  model_uuid = juju_model.slurm.uuid

  application {
    name     = module.slurmctld.app_name
    endpoint = module.slurmctld.requires.smtp
  }

  application {
    name     = module.smtp_integrator.app_name
    endpoint = module.smtp_integrator.provides.smtp
  }
}
:::

::::

:::::

Refer to the [`smtp-integrator` documentation](https://charmhub.io/smtp-integrator/configurations)
for all configuration options for connecting to an SMTP server.

Once integrated, users can include the [`--mail-type`](https://slurm.schedmd.com/sbatch.html#OPT_mail-type)
and [`--mail-user`](https://slurm.schedmd.com/sbatch.html#OPT_mail-user) SBATCH directives in their
job submissions and receive email notifications.

## Customize signature name

To customize the name that appears in the signature of email notifications sent by Slurm, set the
`slurmctld` configuration value `email-from-name`:

:::::{tab-set}

::::{tab-item} CLI
:sync: cli

:::{code-block} shell
juju config slurmctld email-from-name="The My Cluster Name Admin Team"
:::

::::

::::{tab-item} Terraform
:sync: terraform

:::{code-block} terraform
:caption: `main.tf`
module "slurmctld" {
  source      = "git::https://github.com/charmed-hpc/slurm-charms//charms/slurmctld/terraform"
  model_uuid  = juju_model.slurm.uuid
  config = {
    email-from-name = "The My Cluster Name Admin Team"
  }
}
:::

::::

:::::