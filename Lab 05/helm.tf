resource "helm_release" "weaviate" {
  chart       = "weaviate"
  name        = "weaviate"
  repository  = "https://weaviate.github.io/weaviate-helm"
  description = "A Helm chart for Weaviate"
  values      = [file("${path.module}/values.yaml")]
}

resource "kubernetes_storage_class_v1" "ebs-storage" {
  metadata {
    name = "ebs-storage"
  }
  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
}

resource "kubernetes_persistent_volume_v1" "weaviate-data" {
  metadata {
    name = "weaviate-data"
  }
  spec {
    capacity = {
      storage = "4Gi"
    }
    access_modes                     = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
    volume_mode                      = "Filesystem"
    storage_class_name               = "ebs-storage"
    persistent_volume_source {
      csi {
        driver        = "ebs.csi.aws.com"
        volume_handle = aws_ebs_volume.weaviate-data.id
      }
    }
  }
}
