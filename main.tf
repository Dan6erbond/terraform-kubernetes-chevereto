terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.13.1"
    }
  }
}

locals {
  match_labels = merge({
    "app.kubernetes.io/name"     = "chevereto"
    "app.kubernetes.io/instance" = "chevereto"
  }, var.match_labels)
  labels = merge(local.match_labels, var.labels)
}

resource "kubernetes_persistent_volume_claim" "chevereto" {
  metadata {
    name      = "chevereto-images"
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.storage_size
      }
    }
    storage_class_name = var.storage_class_name
  }
}

resource "kubernetes_deployment" "chevereto" {
  metadata {
    name      = "chevereto"
    namespace = var.namespace
    labels    = local.labels
  }
  spec {
    replicas = 1
    selector {
      match_labels = local.labels
    }
    template {
      metadata {
        labels = local.labels
        annotations = {
          "ravianand.me/config-hash" = sha1(jsonencode(merge(
            kubernetes_config_map.chevereto.data,
            kubernetes_secret.chevereto.data
          )))
        }
      }
      spec {
        container {
          image = var.image_registry == "" ? "${var.image_repository}:${var.image_tag}" : "${var.image_registry}/${var.image_repository}:${var.image_tag}"
          name  = var.container_name
          env_from {
            config_map_ref {
              name = kubernetes_config_map.chevereto.metadata.0.name
            }
          }
          env {
            name = "CHEVERETO_DB_PASS"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.chevereto.metadata.0.name
                key  = "mariadb-password"
              }
            }
          }
          env {
            name = "CHEVERETO_ASSET_STORAGE_SECRET"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.chevereto.metadata.0.name
                key  = "s3-secret-key"
              }
            }
          }
          port {
            name           = "http"
            container_port = 80
          }
          volume_mount {
            name       = "images"
            mount_path = "/var/www/html/images"
          }
        }
        volume {
          name = "images"
          persistent_volume_claim {
            claim_name = "chevereto-images"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "chevereto" {
  metadata {
    name      = var.service_name
    namespace = var.namespace
    labels    = local.labels
  }
  spec {
    type     = var.service_type
    selector = local.match_labels
    port {
      name        = "http"
      port        = 80
      target_port = "http"
    }
  }
}

resource "kubernetes_cron_job_v1" "chevereto" {
  metadata {
    name      = "chevereto-cron"
    namespace = var.namespace
  }
  spec {
    schedule = "* * * * *"
    job_template {
      metadata {
        labels = local.labels
        annotations = {
          "ravianand.me/config-hash" = sha1(jsonencode(merge(
            kubernetes_config_map.chevereto.data,
            kubernetes_secret.chevereto.data
          )))
        }
      }
      spec {
        template {
          metadata {
            labels = local.labels
          }
          spec {
            security_context {
              run_as_user = 33
            }
            container {
              image   = var.image_registry == "" ? "${var.image_repository}:${var.image_tag}" : "${var.image_registry}/${var.image_repository}:${var.image_tag}"
              name    = "chevereto-cron"
              command = ["app/bin/legacy", "-C", "cron"]
              env_from {
                config_map_ref {
                  name = kubernetes_config_map.chevereto.metadata.0.name
                }
              }
              env {
                name = "CHEVERETO_DB_PASS"
                value_from {
                  secret_key_ref {
                    name = kubernetes_secret.chevereto.metadata.0.name
                    key  = "mariadb-password"
                  }
                }
              }
              env {
                name = "CHEVERETO_ASSET_STORAGE_SECRET"
                value_from {
                  secret_key_ref {
                    name = kubernetes_secret.chevereto.metadata.0.name
                    key  = "s3-secret-key"
                  }
                }
              }
              volume_mount {
                name       = "images"
                mount_path = "/var/www/html/images"
              }
            }
            volume {
              name = "images"
              persistent_volume_claim {
                claim_name = "chevereto-images"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_secret" "chevereto" {
  metadata {
    name      = "chevereto"
    namespace = var.namespace
  }
  data = {
    "mariadb-password" = var.mariadb_password
    "s3-secret-key"    = var.s3_secret_key
  }
}

resource "kubernetes_config_map" "chevereto" {
  metadata {
    name      = "chevereto"
    namespace = var.namespace
  }
  data = {
    "CHEVERETO_DB_HOST"              = var.mariadb_host
    "CHEVERETO_DB_USER"              = var.mariadb_user
    "CHEVERETO_DB_PORT"              = var.mariadb_port
    "CHEVERETO_DB_NAME"              = var.mariadb_database
    "CHEVERETO_HOSTNAME"             = var.host
    "CHEVERETO_HOSTNAME_PATH"        = var.host_path
    "CHEVERETO_HTTPS"                = var.https ? 1 : 0
    "CHEVERETO_ASSET_STORAGE_TYPE"   = var.enable_s3 ? "s3" : "local"
    "CHEVERETO_ASSET_STORAGE_BUCKET" = var.s3_bucket
    "CHEVERETO_ASSET_STORAGE_REGION" = var.s3_region
    "CHEVERETO_ASSET_STORAGE_SERVER" = var.s3_host
    "CHEVERETO_ASSET_STORAGE_URL"    = var.s3_url
    "CHEVERETO_ASSET_STORAGE_KEY"    = var.s3_access_key
  }
}
