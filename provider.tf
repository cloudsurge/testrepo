locals {

  terraform_team   = "someteam"
  global_component = var.component != "" ? var.component : "unknown"
  default_tags = {
    source-code                  = "https://github.com/cloudsurge/testrepo"
    business-unit                = "somewhere"
    owner                        = local.terraform_team
    Component                    = local.global_component
    Environment                  = var.environment
    "team:component:environment" = "${local.terraform_team}:${local.global_component}:${var.environment}"
    Team                         = local.terraform_team
  }

  default_expanded_asg_tags = flatten([
    for key, value in local.default_tags : [
      {
        key                 = key
        value               = value
        propagate_at_launch = "true"
      }
    ]
  ])

}

provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = local.default_tags
  }
}

terraform {

  required_version = "~> 1.12.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.76.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "2.3.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.1.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.1.1"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.2.2"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.5"
    }
  }
}
