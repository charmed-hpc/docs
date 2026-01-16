(howto-setup-deploy-identity-provider)=
# How to deploy an identity provider

An identity provider can be integrated with Charmed HPC to supply your cluster with
user and group information. This guide provides you with different options for how to set up an
IDP stack for your Charmed HPC cluster.

Follow the instructions in the {ref}`identity-external-ldap-server-with-sssd`
section if you have an existing, external LDAP server that you must connect to your
Charmed HPC cluster.

Follow the instructions in the {ref}`identity-glauth-with-sssd` section if you need
or want to deploy a dedicated LDAP server with your Charmed HPC cluster.

(identity-external-ldap-server-with-sssd)=
## External LDAP server with SSSD

This section shows you how to use an external LDAP server as your Charmed HPC cluster's
identity provider, and SSSD as the client for connecting your cluster's login and compute
nodes to the external LDAP server.

The [ldap-integrator](https://charmhub.io/ldap-integrator) charm is used to proxy your
external LDAP server's configuration information to other charmed applications.

### Prerequisites

- An active [Slurm deployment](#howto-setup-deploy-slurm) in your [`charmed-hpc` machine cloud](#howto-initialize-machine-cloud).
- The [Juju CLI client](https://documentation.ubuntu.com/juju/latest/user/howto/manage-juju/) installed on your machine.

### Deploy ldap-integrator and SSSD

You have two options for deploying ldap-integrator and SSSD:

1. Using the [Juju CLI client](https://documentation.ubuntu.com/juju/latest/user/reference/juju-cli/).
2. Using the [Juju Terraform client](https://canonical-terraform-provider-juju.readthedocs-hosted.com/latest/).

If you want to use Terraform to deploy ldap-integrator and SSSD, see the
[Manage `terraform-provider-juju`](https://canonical-terraform-provider-juju.readthedocs-hosted.com/latest/howto/manage-the-terraform-provider-for-juju/) how-to guide for additional
requirements.

#### Deploy ldap-integrator

:::::{tab-set}

::::{tab-item} CLI
:sync: cli

First, use `juju add-model`{l=shell} to create the `identity` model on your
`charmed-hpc` machine cloud:

:::{code-block} shell
juju add-model identity charmed-hpc
:::

Now use `juju add-secret`{l=shell} to create a secret for your external LDAP server's bind password.
In this example, the external LDAP server's bind password is `"test"`:

:::{code-block} shell
secret_uri=$(juju add-secret external_ldap_password password="test")
:::

Now use `juju deploy`{l=shell} with the `--config`{l=shell} flag to deploy
ldap-integrator with your external LDAP server's configuration information. In this
example, the external LDAP server's:

- `base_dn` is `"cn=testing,cn=ubuntu,cn=com"`.
- `bind_dn` is `"cn=admin,dc=test,dc=ubuntu,dc=com"`.
- `bind_password` is `"test"`.
- `starttls` mode is disabled.
- `urls` are `"ldap://10.214.237.229"`.

For further customization, see [the full list of ldap-integrator's available configuration options](https://charmhub.io/ldap-integrator/configurations).

:::{code-block} shell
juju deploy ldap-integrator --channel "edge" \
  --config base_dn="cn=testing,cn=ubuntu,cn=com" \
  --config bind_dn="cn=admin,dc=test,dc=ubuntu,dc=com" \
  --config bind_password="${secret_id}" \
  --config starttls=false \
  --config urls="ldap://10.214.237.229"
:::

Now use `juju grant-secret`{l=shell} to grant the ldap-integrator application
access to your external LDAP server's bind password:

:::{code-block} shell
juju grant-secret external_ldap_password ldap-integrator
:::

:::{include} /reuse/howto/setup/deploy-identity-provider/ldap-integrator/identity-status.md
:::

::::

::::{tab-item} Terraform
:sync: terraform

First, create the Terraform configuration file
_{{ ldap_integrator_plan_name }}_ using `mkdir`{l=shell} and `touch`{l=shell}:

:::{code-block} shell
mkdir ldap-integrator
touch ldap-integrator/main.tf
:::

Now open _{{ ldap_integrator_plan_name }}_ in a text editor and add the Juju Terraform provider
to your configuration:

:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/ldap-integrator/ldap-integrator.tf
:caption: {{ ldap_integrator_plan_name }}
:language: terraform
:lines: 1-8
:::

Now create the `identity` model on your `charmed-hpc` machine cloud:

:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/ldap-integrator/ldap-integrator.tf
:caption: {{ ldap_integrator_plan_name }}
:language: terraform
:lines: 10-15
:::

Now create the `external_ldap_password` secret in the `identity` model. In this example,
the external LDAP server's bind password is `"test"`:

:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/ldap-integrator/ldap-integrator.tf
:caption: {{ ldap_integrator_plan_name }}
:language: terraform
:lines: 17-23
:::

:::{admonition} Securely setting the external LDAP server's bind password in a Juju secret
:class: note

You can use Terraform's [built-in `file` function](https://developer.hashicorp.com/terraform/language/functions/file)
to read in your bind password from a secure file rather provide
it as plain text in the _{{ ldap_integrator_plan_name }}_ plan.
:::

Now deploy ldap-integrator. In this example, the external LDAP server's:

- `base_dn` is `"cn=testing,cn=ubuntu,cn=com"`.
- `bind_dn` is `"cn=admin,dc=test,dc=ubuntu,dc=com"`.
- `bind_password` is `"test"`.
- `starttls` mode is disabled.
- `urls` are `"ldap://10.214.237.229"`.

For further customization, see [the full list of ldap-integrator's available configuration options](https://charmhub.io/ldap-integrator/configurations).

:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/ldap-integrator/ldap-integrator.tf
:caption: {{ ldap_integrator_plan_name }}
:language: terraform
:lines: 25-38
:::

Now grant the ldap-integrator application access to the `external_ldap_password` secret:

:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/ldap-integrator/ldap-integrator.tf
:caption: {{ ldap_integrator_plan_name }}
:language: terraform
:lines: 40-44
:::

Now use the `terraform`{l=shell} command to apply your configuration. You can expand the
dropdown below to see the full _{{ ldap_integrator_plan_name }}_ Terraform configuration file before
applying it:

:::{code-block} shell
terraform -chdir=ldap-integrator init
terraform -chdir=ldap-integrator apply -auto-approve
:::

:::{dropdown} Full _{{ ldap_integrator_plan_name }}_ Terraform configuration file
:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/ldap-integrator/ldap-integrator.tf
:caption: {{ ldap_integrator_plan_name }}
:language: terraform
:linenos:
:::
:::

:::{include} /reuse/howto/setup/deploy-identity-provider/ldap-integrator/identity-status.md
:::

::::

:::::

#### Deploy SSSD

:::::{tab-set}

::::{tab-item} CLI
:sync: cli

:::{include} /reuse/howto/setup/deploy-identity-provider/common/deploy-instructions-cli.md
:::

:::{include} /reuse/howto/setup/deploy-identity-provider/ldap-integrator/deploy-sssd-next-steps.md
:::

::::

::::{tab-item} Terraform
:sync: terraform

:::{include} /reuse/howto/setup/deploy-identity-provider/common/deploy-instructions-tf.md
:::

:::{include} /reuse/howto/setup/deploy-identity-provider/ldap-integrator/deploy-sssd-next-steps.md
:::

::::

:::::

#### Connect SSSD to ldap-integrator

:::::{tab-set}

::::{tab-item} CLI
:sync: cli

First, create an offer from the ldap-integrator application in your `identity` model
with `juju offer`{l=shell}:

:::{code-block} shell
juju offer identity.ldap-integrator:ldap ldap
:::

Now use `juju consume` to consume the offer from your ldap-integrator
application in your `slurm` model:

:::{code-block} shell
juju consume identity.ldap
:::

Now use `juju integrate` to connect SSSD to ldap-integrator:

:::{code-block} shell
juju integrate ldap sssd
:::

:::{include} /reuse/howto/setup/deploy-identity-provider/common/sssd-with-ldap-status.md
:::

:::{include} /reuse/howto/setup/deploy-identity-provider/common/conclusion.md
:::

::::

::::{tab-item} Terraform
:sync: terraform

First, create the Terraform plan _{{ connect_sssd_to_ldap_integrator_plan_name }}_
using `mkdir`{l=shell} and `touch`{l=shell}:

:::{code-block} shell
mkdir connect-sssd-to-ldap-integrator
touch connect-sssd-to-ldap-integrator/main.tf
:::

Now open _{{ connect_sssd_to_ldap_integrator_plan_name }}_ in a text editor and
add the Juju Terraform provider to your configuration:

:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/ldap-integrator/connect-sssd-to-ldap-integrator.tf
:caption: {{ connect_sssd_to_ldap_integrator_plan_name }}
:language: terraform
:lines: 1-8
:::

Now declare data sources for the `identity` and `slurm` models,
and the ldap-integrator and SSSD applications:

:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/ldap-integrator/connect-sssd-to-ldap-integrator.tf
:caption: {{ connect_sssd_to_ldap_integrator_plan_name }}
:language: terraform
:lines: 10-28
:::

Now create an offer from the ldap-integrator application in your `identity` model:

:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/ldap-integrator/connect-sssd-to-ldap-integrator.tf
:caption: {{ connect_sssd_to_ldap_integrator_plan_name }}
:language: terraform
:lines: 30-35
:::

Now connect SSSD to ldap-integrator:

:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/ldap-integrator/connect-sssd-to-ldap-integrator.tf
:caption: {{ connect_sssd_to_ldap_integrator_plan_name }}
:language: terraform
:lines: 37-47
:::

Now use the `terraform`{l=shell} command to apply your configuration. You can expand the dropdown
below to see the full _{{ connect_sssd_to_ldap_integrator_plan_name }}_ Terraform
configuration file before applying it:

:::{code-block} shell
terraform -chdir=connect-sssd-to-ldap-integrator init
terraform -chdir=connect-sssd-to-ldap-integrator apply -auto-approve
:::

:::{dropdown} Full _{{ connect_sssd_to_ldap_integrator_plan_name }}_ Terraform configuration file
:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/ldap-integrator/connect-sssd-to-ldap-integrator.tf
:caption: {{ connect_sssd_to_ldap_integrator_plan_name }}
:language: terraform
:linenos:
:::
:::

:::{include} /reuse/howto/setup/deploy-identity-provider/common/sssd-with-ldap-status.md
:::

:::{include} /reuse/howto/setup/deploy-identity-provider/common/conclusion.md
:::

::::

:::::

#### Optional: Enable TLS encryption between SSSD and the external LDAP server

The [manual-tls-certificates](https://charmhub.io/manual-tls-certificates) charm can
provide your SSSD application with your external LDAP server's TLS certificate.

:::{admonition} Before you begin
:class: note

The instructions in this section assume that your external LDAP server supports TLS and
that you have access to your LDAP server's TLS certificate.
:::

:::::{tab-set}

::::{tab-item} CLI
:sync: cli

First, use `juju deploy`{l=shell} with the `--config`{l=shell} flag to deploy
manual-tls-certificates with your external LDAP server's TLS certificate. In this
example, the LDAP server's TLS certificate is stored in the file _bundle.pem_:

:::{code-block} shell
juju deploy manual-tls-certificates \
  --model identity \
  --config trusted-certificate-bundle="$(cat bundle.pem)"
:::

:::{include} /reuse/howto/setup/deploy-identity-provider/ldap-integrator/bundle-pem-tip.md
:::

Now create an offer from the manual-tls-certificates application in your `identity`
model with `juju offer`{l=shell}:

:::{code-block} shell
juju offer identity.manual-tls-certificates:send-ca-certs send-ldap-certs
:::

Now use `juju consume`{l=shell} to consume the offer from your manual-tls-certificates
application in your `slurm` model:

:::{code-block} shell
juju consume identity.send-ldap-certs
:::

Now use `juju integrate`{l=shell} to connect SSSD to manual-tls-certificates:

:::{code-block} shell
juju integrate sssd send-ldap-certs
:::

Now use `juju config`{l=shell} to update the ldap-integrator application's configuration
to indicate that the external LDAP server supports TLS:

:::{code-block} shell
juju config ldap-integrator starttls=true
:::

:::{include} /reuse/howto/setup/deploy-identity-provider/common/sssd-with-ldap-tls-status.md
:::

::::

::::{tab-item} Terraform
:sync: terraform

First, update the configuration of the ldap-integrator application in the
_{{ ldap_integrator_plan_name }}_ Terraform configuration file to indicate that
the external LDAP server supports TLS:

:::{code-block} terraform
:caption: {{ ldap_integrator_plan_name }}
:emphasize-lines: 9
module "ldap-integrator" {
  source = "git::https://github.com/canonical/ldap-integrator//terraform"
  model_uuid = juju_model.identity.uuid

  config = {
    base_dn = "cn=testing,cn=ubuntu,cn=com"
    bind_dn = "cn=admin,dc=test,dc=ubuntu,dc=com"
    bind_password = juju_secret.external_ldap_password.secret_uri
    starttls = true
    urls = "ldap://10.214.237.229"
  }

  channel = "latest/edge"
}
:::

Now create the Terraform configuration file _{{ manual_tls_certificates_plan_name }}_ using
`mkdir`{l=shell} and `touch`{l=shell}:

:::{code-block} shell
mkdir manual-tls-certificates
touch manual-tls-certificates/main.tf
:::

Now open _{{ manual_tls_certificates_plan_name }}_ in a text editor and add the
Juju Terraform provider to your configuration:

:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/ldap-integrator/manual-tls-certificates.tf
:caption: {{ manual_tls_certificates_plan_name }}
:language: terraform
:lines: 1-8
:::

Now declare data sources for the `identity` and `slurm` models, and the SSSD
application:

:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/ldap-integrator/manual-tls-certificates.tf
:caption: {{ manual_tls_certificates_plan_name }}
:language: terraform
:lines: 10-23
:::

Now deploy manual-tls-certificates in the `identity` model. In this
example, the LDAP server's TLS certificate is stored in the file _bundle.pem_:

:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/ldap-integrator/manual-tls-certificates.tf
:caption: {{ manual_tls_certificates_plan_name }}
:language: terraform
:lines: 25-32
:::

:::{include} /reuse/howto/setup/deploy-identity-provider/ldap-integrator/bundle-pem-tip.md
:::

Now create an offer from the manual-tls-certificates application in your `identity` model:

:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/ldap-integrator/manual-tls-certificates.tf
:caption: {{ manual_tls_certificates_plan_name }}
:language: terraform
:lines: 34-39
:::

Now connect SSSD to manual-tls-certificates:

:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/ldap-integrator/manual-tls-certificates.tf
:caption: {{ manual_tls_certificates_plan_name }}
:language: terraform
:lines: 41-51
:::

Now use the `terraform`{l=shell} command to update the configuration of your
ldap-integrator application:

:::{code-block} shell
terraform -chdir=ldap-integrator init
terraform -chdir=ldap-integrator apply -auto-approve
:::

Use the `terraform`{l=shell} command again to deploy manual-tls-certificates. You can
expand the dropdown below to see the full _{{ manual_tls_certificates_plan_name }}_
Terraform plan before applying it:

:::{dropdown} Full _{{ manual_tls_certificates_plan_name }}_ Terraform configuration file

:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/ldap-integrator/manual-tls-certificates.tf
:caption: {{ manual_tls_certificates_plan_name }}
:language: terraform
:linenos:
:::

:::{code-block} shell
terraform -chdir=manual-tls-certificates init
terraform -chdir=manual-tls-certificates apply -auto-approve
:::

:::{include} /reuse/howto/setup/deploy-identity-provider/common/sssd-with-ldap-tls-status.md
:::

::::

:::::

(identity-glauth-with-sssd)=
## GLAuth with SSSD

This section shows you how to use GLAuth, a lightweight LDAP server, as your Charmed HPC
cluster's identity provider, and SSSD as the client for connecting your cluster's login
and compute nodes to the GLAuth server.

:::{admonition} Unfamiliar with GLAuth?
:class: note

If you're unfamiliar with operating GLAuth, see the [GLAuth quick start](https://glauth.github.io/docs/quickstart.html)
guide for a high-level introduction to GLAuth.
:::

### Prerequisites

- An active [Slurm deployment](#howto-setup-deploy-slurm) in your [`charmed-hpc` machine cloud](#howto-initialize-machine-cloud).
- An initialized [`charmed-hpc-k8s` Kubernetes cloud](#howto-initialize-kubernetes-cloud).
- The [Juju CLI client](https://documentation.ubuntu.com/juju/latest/user/howto/manage-juju/) installed on your machine.

### Deploy GLAuth and SSSD

You have two options for deploying GLAuth and SSSD:

1. Using the [Juju CLI client](https://documentation.ubuntu.com/juju/latest/user/reference/juju-cli/).
2. Using the [Juju Terraform client](https://canonical-terraform-provider-juju.readthedocs-hosted.com/latest/).

If you want to use Terraform to deploy GLAuth and SSSD, see the
[Manage `terraform-provider-juju`](https://canonical-terraform-provider-juju.readthedocs-hosted.com/latest/howto/manage-the-terraform-provider-for-juju/) how-to guide for additional
requirements.

#### Deploy GLAuth

:::::{tab-set}

::::{tab-item} CLI
:sync: cli

First, use `juju add-model`{l=shell} to create the `identity` model in your
`charmed-hpc-k8s` Kubernetes cloud:

:::{code-block} shell
juju add-model identity charmed-hpc-k8s
:::

Now use `juju deploy`{l=shell} to deploy GLAuth with Postgres as
GLAuth's database back-end:

:::{code-block} shell
juju deploy glauth-k8s --channel "edge" \
  --config anonymousdse_enabled=true \
  --trust
juju deploy postgresql-k8s --channel "14/stable" --trust
juju deploy self-signed-certificates
juju deploy traefik-k8s --trust
:::

:::{include} /reuse/howto/setup/deploy-identity-provider/glauth/anonymous-dse-note.md
:::

Now use `juju integrate` to connect GLAuth to Postgres, Traefik, and the
self-signed-certificates applications:

:::{code-block} shell
juju integrate glauth-k8s postgresql-k8s
juju integrate glauth-k8s self-signed-certificates
juju integrate glauth-k8s:ingress traefik-k8s
:::

:::{include} /reuse/howto/setup/deploy-identity-provider/glauth/identity-status.md
:::

::::

::::{tab-item} Terraform
:sync: terraform

First, create the Terraform configuration file _{{ glauth_plan_name }}_
using `mkdir`{l=shell} and `touch`{l=shell}:

:::{code-block} shell
mkdir glauth
touch glauth/main.tf
:::

Now open _{{ glauth_plan_name }}_ in a text editor and add the Juju Terraform provider
to your configuration:

:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/glauth/glauth.tf
:caption: {{ glauth_plan_name }}
:language: terraform
:lines: 1-8
:::

Now create the `identity` model on your `charmed-hpc-k8s` Kubernetes cloud:

:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/glauth/glauth.tf
:caption: {{ glauth_plan_name }}
:language: terraform
:lines: 10-16
:::

Now deploy GLAuth, Postgres, Traefik, and self-signed-certificates:

:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/glauth/glauth.tf
:caption: {{ glauth_plan_name }}
:language: terraform
:lines: 18-43
:::

:::{include} /reuse/howto/setup/deploy-identity-provider/glauth/anonymous-dse-note.md
:::

Now connect GLAuth to Postgres, Traefik, and self-signed-certificates:

:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/glauth/glauth.tf
:caption: {{ glauth_plan_name }}
:language: terraform
:lines: 45-80
:::

Now use the `terraform`{l=shell} command to apply your configuration. You can expand the
dropdown below to see the full _{{ glauth_plan_name }}_ Terraform configuration file before
applying it:

:::{code-block} shell
terraform -chdir=glauth init
terraform -chdir=glauth apply -auto-approve
:::

:::{dropdown} Full _{{ glauth_plan_name }}_ Terraform configuration file
:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/glauth/glauth.tf
:caption: {{ glauth_plan_name }}
:language: terraform
:linenos:
:::
:::

:::{include} /reuse/howto/setup/deploy-identity-provider/glauth/identity-status.md
:::

::::

:::::

#### Deploy SSSD

:::::{tab-set}

::::{tab-item} CLI
:sync: cli

:::{include} /reuse/howto/setup/deploy-identity-provider/common/deploy-instructions-cli.md
:::

:::{include} /reuse/howto/setup/deploy-identity-provider/glauth/deploy-sssd-next-steps.md
:::

::::

::::{tab-item} Terraform
:sync: terraform

:::{include} /reuse/howto/setup/deploy-identity-provider/common/deploy-instructions-tf.md
:::

:::{include} /reuse/howto/setup/deploy-identity-provider/glauth/deploy-sssd-next-steps.md
:::

::::

:::::

#### Connect SSSD to GLAuth

:::::{tab-set}

::::{tab-item} CLI
:sync: cli

First, create offers for GLAuth in your `identity` model using `juju offer`{l=shell}:

:::{code-block} shell
juju offer identity.glauth-k8s:ldap ldap
juju offer identity.glauth-k8s:send-ca-cert send-ldap-certs
:::

Now use `juju consume`{l=shell} to consume offers from your GLAuth application
in your `slurm` model:

:::{code-block} shell
juju consume identity.ldap
juju consume identity.send-ldap-certs
:::

Now use `juju integrate`{l=shell} to connect SSSD to the GLAuth endpoints:

:::{code-block} shell
juju integrate sssd ldap
juju integrate sssd send-ldap-certs
:::

:::{include} /reuse/howto/setup/deploy-identity-provider/common/sssd-with-ldap-tls-status.md
:::

:::{include} /reuse/howto/setup/deploy-identity-provider/common/conclusion.md
:::

::::

::::{tab-item} Terraform
:sync: terraform

First, create the Terraform configuration file _{{ connect_sssd_to_glauth_plan_name }}_
using `mkdir`{l=shell} and `touch`{l=shell}:

:::{code-block} shell
mkdir connect-sssd-to-glauth
touch connect-sssd-to-glauth/main.tf
:::

Now open _{{ connect_sssd_to_glauth_plan_name }}_ in a text editor and add the Juju Terraform provider
to your configuration:

:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/glauth/connect-sssd-to-glauth.tf
:caption: {{ connect_sssd_to_glauth_plan_name }}
:language: terraform
:lines: 1-8
:::

Now declare data sources for the `identity` and `slurm` models, and the GLAuth and SSSD
applications:

:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/glauth/connect-sssd-to-glauth.tf
:caption: {{ connect_sssd_to_glauth_plan_name }}
:language: terraform
:lines: 10-26
:::

Now create offers from the GLAuth application in your `identity` model:

:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/glauth/connect-sssd-to-glauth.tf
:caption: {{ connect_sssd_to_glauth_plan_name }}
:language: terraform
:lines: 28-40
:::

Now connect SSSD to GLAuth:

:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/glauth/connect-sssd-to-glauth.tf
:caption: {{ connect_sssd_to_glauth_plan_name }}
:language: terraform
:lines: 42-64
:::

Now use the `terraform`{l=shell} command to apply your configuration. You can expand the
dropdown below to see the full _{{ connect_sssd_to_glauth_plan_name }}_ Terraform configuration file before
applying it:

:::{code-block} shell
terraform -chdir=connect-sssd-to-glauth init
terraform -chdir=connect-sssd-to-glauth apply -auto-approve
:::

:::{dropdown} Full _{{ connect_sssd_to_glauth_plan_name }}_ Terraform configuration file
:::{literalinclude} /reuse/howto/setup/deploy-identity-provider/glauth/connect-sssd-to-glauth.tf
:caption: {{ connect_sssd_to_glauth_plan_name }}
:language: terraform
:linenos:
:::
:::

:::{include} /reuse/howto/setup/deploy-identity-provider/common/sssd-with-ldap-tls-status.md
:::

:::{include} /reuse/howto/setup/deploy-identity-provider/common/conclusion.md
:::

::::

:::::
