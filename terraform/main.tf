# https://developer.hashicorp.com/terraform/tutorials/kubernetes/gke
provider "google" {
  project = var.project_id
  region  = var.region
}

# We need a single zone cluster in order to not blow through free tier quotas in GKE.
data "google_compute_zones" "available" {}


resource "random_id" "name" {
  byte_length = 8
}

resource "google_compute_network" "vpc" {
  name                    = "charlie-cohere-${random_id.name.hex}"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "charlie-cohere-subnet-gke-${random_id.name.hex}"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.88.0.0/24"
}

data "google_container_engine_versions" "gke_version" {
  version_prefix = "1.28."
}

resource "google_container_cluster" "cluster" {
  name     = "charlie-cohere-gke-${random_id.name.hex}"
  location = data.google_compute_zones.available.names[0] # single zone cluster to stay under quota

  # Hack to have a separately managed node pool. This creates a default node
  # pool of size 1 and immediately deletes it.
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#remove_default_node_pool
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  min_master_version = data.google_container_engine_versions.gke_version.release_channel_latest_version["STABLE"]
}

resource "google_container_node_pool" "main_pool" {
  name     = "main-pool"
  location = data.google_compute_zones.available.names[0] # single zone cluster to stay under quota
  cluster  = google_container_cluster.cluster.name

  version    = data.google_container_engine_versions.gke_version.release_channel_latest_version["STABLE"]
  node_count = var.num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      # TODO: use service account with IAM roles
      # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#oauth_scopes
      # this is needed to be able to pull from the artifact registry
      "https://www.googleapis.com/auth/cloud-platform",
    ]


    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${google_container_cluster.cluster.name}"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = "charlie-cohere-test"
  description   = "Container registry for Cohere take-home"
  format        = "DOCKER"
}
