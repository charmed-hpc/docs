terraform {
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 0.17.0"
    }
  }
}

data "juju_model" "iam" {
  name = "iam"
}

data "juju_model" "slurm" {
  name = "slurm"
}

data "juju_application" "glauth-k8s" {
  model = data.juju_model.iam.name
  name = "glauth-k8s"
}

data "juju_application" "sssd" {
  model = data.juju_model.slurm.name
  name = "sssd"
}

resource "juju_offer" "ldap" {
  model            = data.juju_model.iam.name
  application_name = data.juju_application.glauth-k8s.name
  endpoint         = "ldap"
  name             = "ldap"
}

resource "juju_offer" "ldap-certs" {
  model            = data.juju_model.iam.name
  application_name = data.juju_application.glauth-k8s.name
  endpoint         = "send-ca-certs"
  name             = "ldap-certs"
}

resource "juju_integration" "sssd-to-ldap" {
  model = data.juju_model.slurm.name

  application {
    name = data.juju_application.sssd.name
  }

  application {
    offer_url = data.juju_offer.ldap.url
  }
}

resource "juju_integration" "sssd-to-ldap-certs" {
  model = data.juju_model.slurm.name

  application {
    name = data.juju_application.sssd.name
  }

  application {
    offer_url = data.juju_offer.ldap-certs.url
  }
}
