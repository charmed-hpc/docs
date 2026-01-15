First, create the Terraform configuration file _{{ sssd_plan_name }}_
using `mkdir`{l=shell} and `touch`{l=shell}:

:::{code-block} shell
mkdir sssd
touch sssd/main.tf
:::

Now open _{{ sssd_plan_name }}_ in a text editor and add the Juju Terraform provider
to your configuration:

:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/common/sssd.tf
:caption: {{ sssd_plan_name }}
:language: terraform
:lines: 1-8
:::

Now declare data sources for the `slurm` model, and your sackd and slurmd applications:

:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/common/sssd.tf
:caption: {{ sssd_plan_name }}
:language: terraform
:lines: 10-23
:::

Now deploy SSSD:

:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/common/sssd.tf
:caption: {{ sssd_plan_name }}
:language: terraform
:lines: 24-28
:::

Now connect SSSD to the sackd and slurmd applications in your `slurm` model:

:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/common/sssd.tf
:caption: {{ sssd_plan_name }}
:language: terraform
:lines: 29-52
:::

Now use the `terraform`{l=shell} command to apply your configuration. You can expand the
dropdown below to see the full _{{ sssd_plan_name }}_ Terraform configuration file before
applying it:

:::{code-block} shell
terraform -chdir=sssd init
terraform -chdir=sssd apply -auto-approve
:::

:::{dropdown} Full _{{ sssd_plan_name }}_ Terraform configuration file
:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/common/sssd.tf
:caption: {{ sssd_plan_name }}
:language: terraform
:linenos:
:::
:::

:::{include} /reuse/howto/setup/deploy-identity-provider/common/sssd-no-ldap-status.md
:::
