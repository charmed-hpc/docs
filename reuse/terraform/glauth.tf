terraform {
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 0.17.0"
    }
  }
}

resource "juju_model" "iam" {
  name       = "iam"
  credential = "charmed-hpc-k8s"
  cloud {
    name = "charmed-hpc-k8s"
  }
}

module "glauth-k8s" {
  source     = "git::https://github.com/canonical/glauth-k8s-operator//terraform"
  model_name = juju_model.iam.name
  config = {
    anonymousdse_enabled = true
  }
  channel = "latest/edge"
}

module "postgresql-k8s" {
  source          = "git::https://github.com/canonical/postgresql-k8s-operator//terraform"
  juju_model_name = juju_model.iam.name
}

module "self-signed-certificates" {
  source  = "git::https://github.com/canonical/self-signed-certificates-operator//terraform"
  model   = juju_model.iam.name
  channel = "latest/stable"
  base    = "ubuntu@22.04"
}

module "traefik-k8s" {
  source     = "git::https://github.com/canonical/traefik-k8s-operator//terraform"
  model_name = juju_model.iam.name
  app_name   = "traefik-k8s"
}

resource "juju_integration" "glauth-k8s-to-postgresql-k8s" {
  model = juju_model.iam.name

  application {
    name = module.glauth-k8s.app_name
  }

  application {
    name = module.postgresql-k8s.application_name
  }
}

resource "juju_integration" "glauth-k8s-to-self-signed-certificates" {
  model = juju_model.iam.name

  application {
    name = module.glauth-k8s.app_name
  }

  application {
    name = module.self-signed-certificates.app_name
  }
}

resource "juju_integration" "glauth-k8s-to-traefik-k8s" {
  model = juju_model.iam.name

  application {
    name     = module.glauth-k8s.app_name
    endpoint = module.glauth-k8s.requires.ingress
  }

  application {
    name     = module.traefik-k8s.app_name
    endpoint = module.traefik-k8s.endpoints.ingress_per_unit
  }
}
