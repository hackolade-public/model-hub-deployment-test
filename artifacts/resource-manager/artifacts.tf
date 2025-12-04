/*
 * Copyright © 2016-2025 by IntegrIT S.A. dba Hackolade.  All rights reserved.
 *
 * The copyright to the computer software herein is the property of IntegrIT S.A.
 * The software may be used and/or copied only with the written permission of
 * IntegrIT S.A. or in accordance with the terms and conditions stipulated in
 * the agreement/contract under which the software has been supplied.
 */

locals {
  repository_name_prefix = lower(data.oci_identity_compartment.modelhub_compartment.name)
}

resource oci_artifacts_container_configuration container_configuration {
  compartment_id                      = var.compartment_ocid
  is_repository_created_on_first_push = "false"
}

resource oci_artifacts_container_repository model-hub-sync-apply-model-changes {
  compartment_id = var.compartment_ocid
  display_name = "${local.repository_name_prefix}/apply-model-changes"
  freeform_tags = {}
  is_immutable = "false"
  is_public    = "false"
}

resource oci_artifacts_container_repository model-hub-sync-database-migration {
  compartment_id = var.compartment_ocid
  display_name = "${local.repository_name_prefix}/database-migration"
  freeform_tags = {}
  is_immutable = "false"
  is_public    = "false"
}

resource oci_artifacts_container_repository model-hub-sync-sync {
  compartment_id = var.compartment_ocid
  display_name = "${local.repository_name_prefix}/sync"
  freeform_tags = {}
  is_immutable = "false"
  is_public    = "false"
}

resource oci_artifacts_container_repository model-hub-sync-sync-all {
  compartment_id = var.compartment_ocid
  display_name = "${local.repository_name_prefix}/sync-all"
  freeform_tags = {}
  is_immutable = "false"
  is_public    = "false"
}

resource oci_artifacts_container_repository model-hub-sync-update-oci-functions {
  compartment_id = var.compartment_ocid
  display_name = "${local.repository_name_prefix}/update-oci-functions"
  freeform_tags = {}
  is_immutable = "false"
  is_public    = "false"
}

resource oci_artifacts_container_repository model-hub-sync-vault-management {
  compartment_id = var.compartment_ocid
  display_name = "${local.repository_name_prefix}/vault-management"
  freeform_tags = {}
  is_immutable = "false"
  is_public    = "false"
}

resource oci_artifacts_container_repository model-hub-sync-git-providers-api {
  compartment_id = var.compartment_ocid
  display_name = "${local.repository_name_prefix}/git-providers-api"
  freeform_tags = {}
  is_immutable = "false"
  is_public    = "false"
}

# Wait a bit for the container repositories to be ready
# If not, the terraform will fail because the container repositories are not found
resource "time_sleep" "wait_for_artifacts_to_be_ready" {
  depends_on = [
    oci_artifacts_container_repository.model-hub-sync-apply-model-changes,
    oci_artifacts_container_repository.model-hub-sync-database-migration,
    oci_artifacts_container_repository.model-hub-sync-git-providers-api,
    oci_artifacts_container_repository.model-hub-sync-sync-all,
    oci_artifacts_container_repository.model-hub-sync-sync,
    oci_artifacts_container_repository.model-hub-sync-update-oci-functions,
    oci_artifacts_container_repository.model-hub-sync-vault-management,
    oci_identity_auth_token.auth_token_registry
  ]
  create_duration = "150s"
}

resource "terraform_data" "copy_docker_images" {
  depends_on = [time_sleep.wait_for_artifacts_to_be_ready]
  triggers_replace = [
    oci_artifacts_container_repository.model-hub-sync-apply-model-changes.id,
    oci_artifacts_container_repository.model-hub-sync-database-migration.id,
    oci_artifacts_container_repository.model-hub-sync-git-providers-api.id,
    oci_artifacts_container_repository.model-hub-sync-sync-all.id,
    oci_artifacts_container_repository.model-hub-sync-sync.id,
    oci_artifacts_container_repository.model-hub-sync-update-oci-functions.id,
    oci_artifacts_container_repository.model-hub-sync-vault-management.id,
  ]

  provisioner "local-exec" {
    on_failure = fail
    environment = {
      OCI_TOKEN = oci_identity_auth_token.auth_token_registry.token
      OCI_USERNAME = format("%s/%s",data.oci_objectstorage_namespace.object_storage_namespace.namespace,var.oci_username)
      COMPARTMENT_NAME = local.repository_name_prefix
      REGION = data.oci_identity_regions.region.regions[0]["key"]
      NAMESPACE = data.oci_objectstorage_namespace.object_storage_namespace.namespace
      HUB_DOMAIN_NAME = var.hub_domain_name
    }

    command = "podman run --rm -e OCI_TOKEN -e COMPARTMENT_NAME -e NAMESPACE -e REGION -e OCI_USERNAME -e HUB_DOMAIN_NAME hackoladepublic.azurecr.io/model-hub-sync/copy-docker-images:production"
  }
}
