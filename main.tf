provider "kubernetes" {
  config_context = "minikube"
}

resource "kubernetes_namespace" "opsbar-namespace" {
  metadata {
    name = "foo"
  }
}

resource "kubernetes_deployment" "opsbar-deployment" {
  metadata {
    name = "opsbar"
    namespace = "foo"
  }

  spec {
    selector {
      match_labels = {
        app = "opsbar"
      }
    }
    template {
      metadata {
        labels = {
          app = "opsbar"
        }
      }

      spec {
        service_account_name = "${kubernetes_service_account.opsbar.metadata.0.name}"
        container {
          image = "jackyou2020/test-devops:latest"
          image_pull_policy = "IfNotPresent"
          name  = "opsbar"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service_account" "opsbar" {
  metadata {
    name      = "opsbar"
    namespace = "foo"
  }
  secret {
    name = "${kubernetes_secret.opsbar-secret.metadata.0.name}"
  }
}

resource "kubernetes_secret" "opsbar-secret" {
  metadata {
    name = "opsbar"
  }
}

resource "kubernetes_cluster_role" "opsbar-role" {
  metadata {
    name = "opsbar"
  }

  rule {
    api_groups = ["extensions", "apps"]
    resources  = ["deployments"]
    verbs      = ["create", "delete", "get", "list", "watch", "patch", "update"]
  }
  rule {
    api_groups = [""]
    resources  = ["services"]
    verbs      = ["create", "delete", "get", "list", "watch", "patch", "update"]
  }
  rule {
    api_groups = [""]
    resources  = ["pod"]
    verbs      = ["create", "delete", "get", "list", "watch", "patch", "update"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/exec"]
    verbs      = ["create", "delete", "get", "list", "watch", "patch", "update"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get"]
  }
}


resource "kubernetes_cluster_role_binding" "opsbar_role_binding" {
  metadata {
    name = "opsbar"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${kubernetes_cluster_role.opsbar-role.metadata.0.name}"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.opsbar.metadata.0.name}"
    namespace = "foo"
  }
}

resource "kubernetes_service" "opsbar-svc" {
  metadata {
    name      = "opsbar"
    namespace = "foo"
  }
  spec {
    selector = {
      app = "opsbar"
    }
    port {
      port        = 8080
      target_port = 80
    }

    type = "NodePort"
  }
}

