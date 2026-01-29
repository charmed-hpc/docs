terraform {
  required_providers {
    juju = {
      source  = "juju/juju"
      version = "~> 1.0"
    }
  }
}

resource "juju_model" "identity" {
  name       = "identity"
  credential = "charmed-hpc-k8s"
  cloud {
    name = "charmed-hpc-k8s"
  }
}

module "glauth_k8s" {
  source     = "git::https://github.com/canonical/glauth-k8s-operator//terraform"
  model_name = juju_model.identity.name
  config = {
    anonymousdse_enabled = true
  }
  channel = "latest/edge"
}

module "postgresql_k8s" {
  source          = "git::https://github.com/canonical/postgresql-k8s-operator//terraform"
  juju_model_name = juju_model.identity.name
}

module "self_signed_certificates" {
  source     = "git::https://github.com/canonical/self-signed-certificates-operator//terraform"
  model_uuid = juju_model.identity.uuid
}

module "traefik_k8s" {
  source     = "git::https://github.com/canonical/traefik-k8s-operator//terraform"
  model_uuid = juju_model.identity.uuid
  app_name   = "traefik-k8s"
  channel    = "latest/stable"
}

resource "juju_integration" "glauth_k8s_to_postgresql_k8s" {
  model_uuid = juju_model.identity.uuid

  application {
    name = module.glauth_k8s.app_name
  }

  application {
    name = module.postgresql_k8s.application_name
  }
}

resource "juju_integration" "glauth_k8s_to_self_signed_certificates" {
  model = juju_model.identity.name

  application {
    name = module.glauth_k8s.app_name
  }

  application {
    name = module.self_signed_certificates.app_name
  }
}

resource "juju_integration" "glauth_k8s_to_traefik_k8s" {
  model = juju_model.identity.name

  application {
    name     = module.glauth_k8s.app_name
    endpoint = module.glauth_k8s.requires.ingress
  }

  application {
    name     = module.traefik_k8s.app_name
    endpoint = module.traefik_k8s.endpoints.ingress_per_unit
  }
}
