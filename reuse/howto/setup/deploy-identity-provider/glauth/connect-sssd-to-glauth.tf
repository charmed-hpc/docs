terraform {
  required_providers {
    juju = {
      source  = "juju/juju"
      version = "~> 1.0"
    }
  }
}

data "juju_model" "identity" {
  name  = "identity"
  owner = "admin"
}

data "juju_model" "slurm" {
  name  = "slurm"
  owner = "admin"
}

data "juju_application" "glauth_k8s" {
  model_uuid = data.juju_model.identity.uuid
  name       = "glauth-k8s"
}

data "juju_application" "sssd" {
  model_uuid = data.juju_model.slurm.uuid
  name       = "sssd"
}

resource "juju_offer" "ldap" {
  model_uuid       = data.juju_model.identity.uuid
  application_name = data.juju_application.glauth_k8s.name
  endpoints        = ["ldap"]
  name             = "ldap"
}

resource "juju_offer" "send_ldap_certs" {
  model_uuid       = data.juju_model.identity.uuid
  application_name = data.juju_application.glauth_k8s.name
  endpoints        = ["send-ca-certs"]
  name             = "send-ldap-certs"
}

resource "juju_integration" "sssd_to_ldap" {
  model_uuid = data.juju_model.slurm.uuid

  application {
    name = data.juju_application.sssd.name
  }

  application {
    offer_url = juju_offer.ldap.url
  }
}

resource "juju_integration" "sssd_to_send_ldap_certs" {
  model_uuid = data.juju_model.slurm.uuid

  application {
    name = data.juju_application.sssd.name
  }

  application {
    offer_url = juju_offer.send_ldap_certs.url
  }
}
