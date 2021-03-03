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
        "gcr.io/$PROJECT_ID/$REPO_NAME:$COMMIT_SHA",
        ".",
      ]
    }

    artifacts {
      images = ["gcr.io/$PROJECT_ID/$REPO_NAME:$COMMIT_SHA"]
    }

    # step {
    #   name = "gcr.io/cloud-builder/gke-deploy"
    #   args = [
    #     "run", 
    #     "--image=${var.gcr_region}.gcr.io/$PROJECT_ID/$REPO_NAME:$SHORT_SHA", 
    #     "--location", "${var.location}", 
    #     "--cluster", "${var.cluster_name}", 
    #     "--expose", "80"
    #   ]
    # }
  }
}
