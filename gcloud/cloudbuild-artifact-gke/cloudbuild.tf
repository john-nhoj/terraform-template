resource "google_cloudbuild_trigger" "build-trigger" {
  name        = "${var.repository_name}-prod"
  description = "Cloud build hook that deploys the service for production"
  trigger_template {
    branch_name = "deploy-prod"
    repo_name   = var.repository_name
  }

  build {
    step {
      name = "gcr.io/cloud-builders/npm"
      args = [
        "install"
      ]
    }

    step {
      name = "gcr.io/cloud-builders/npm"
      args = [
        "run",
        "test"
      ]
    }

    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "build",
        "-t",
        "gcr.io/$PROJECT_ID/${var.repository_name}:$COMMIT_SHA",
        ".",
      ]
    }

    step {
      id         = "repo-name-replacement"
      name       = "gcr.io/cloud-builders/gcloud"
      entrypoint = "/bin/sh"
      args = ["-c",
        "sed -i 's/CLUSTER_NAME/${var.repository_name}/g' ./kubernetes/deployment.yml",
      ]
    }

    step {
      id         = "project-id-replacement"
      name       = "gcr.io/cloud-builders/gcloud"
      entrypoint = "/bin/sh"
      args = ["-c",
        "sed -i 's/PROJECT_ID/$PROJECT_ID/g' ./kubernetes/deployment.yml",
      ]
    }
    step {
      id         = "commit-sha-replacement"
      name       = "gcr.io/cloud-builders/gcloud"
      entrypoint = "/bin/sh"
      args = ["-c",
        "sed -i 's/COMMIT_SHA/$COMMIT_SHA/g' ./kubernetes/deployment.yml",
      ]
      wait_for = ["project-id-replacement"]
    }

    step {
      name = "gcr.io/cloud-builders/kubectl"
      args = [
        "apply",
        "-f",
        "./kubernetes/deployment.yml"
      ]
      env = [
        "CLOUDSDK_COMPUTE_REGION=${var.region}",
        "CLOUDSDK_CONTAINER_CLUSTER=${var.cluster_name}"
      ]
      wait_for = [
        "repo-name-replacement",
        "project-id-replacement",
        "commit-sha-replacement",
      ]
    }

    artifacts {
      images = ["gcr.io/$PROJECT_ID/${var.repository_name}:$COMMIT_SHA"]
    }
  }
}
