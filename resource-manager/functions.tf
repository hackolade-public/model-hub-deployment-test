/*
 * Copyright © 2016-2025 by IntegrIT S.A. dba Hackolade.  All rights reserved.
 *
 * The copyright to the computer software herein is the property of IntegrIT S.A.
 * The software may be used and/or copied only with the written permission of
 * IntegrIT S.A. or in accordance with the terms and conditions stipulated in
 * the agreement/contract under which the software has been supplied.
 */
resource oci_functions_application model-hub-sync {
  depends_on = [terraform_data.copy_docker_images]
  compartment_id = var.compartment_ocid
  config = {
    "HUB_DOMAIN_NAME"      = var.hub_domain_name
    "JWK_URL"              = format("%s/admin/v1/SigningCert/jwk", oci_identity_domain.modelhub_domain.url)
    "OCI_QUEUE_ID"         = oci_queue_queue.gitFileChanges.id
    "OCI_USERNAME"         = format("%s/%s",data.oci_objectstorage_namespace.object_storage_namespace.namespace,var.oci_username)
    "ORACLE_DB_CONNECTION_NO_PARALLELISM" = lookup(local.database_profiles, "LOW") # sqitch fails when running with parallelism
    "ORACLE_DB_CONNECTION" = lookup(local.database_profiles, "HIGH")
    "ORACLE_USER"          = var.hub_db_schema_username
    "QUEUE_ENDPOINT"       = oci_queue_queue.gitFileChanges.messages_endpoint
  }
  display_name = "model-hub-sync"
  freeform_tags = {
  }
  network_security_group_ids = [
  ]
  shape = "GENERIC_X86"
  subnet_ids = [
    oci_core_subnet.private-subnet-model-hub-VCN.id,
  ]
  syslog_url = ""
  trace_config {
    domain_id  = ""
    is_enabled = "false"
  }
}

resource oci_functions_function apply-model-changes {
  depends_on = [terraform_data.copy_docker_images]
  application_id = oci_functions_application.model-hub-sync.id
  config = {
  }
  display_name = "apply-model-changes"
  freeform_tags = {
  }
  image         = format("%s.ocir.io/%s/%s:develop", lower(data.oci_identity_regions.region.regions[0]["key"]), data.oci_objectstorage_namespace.object_storage_namespace.namespace,oci_artifacts_container_repository.model-hub-sync-apply-model-changes.display_name)
  memory_in_mbs = "512"
  provisioned_concurrency_config {
    strategy = "NONE"
  }
  timeout_in_seconds = "300"
  trace_config {
    is_enabled = "false"
  }
}

resource oci_functions_function vault-management {
  depends_on = [terraform_data.copy_docker_images]
  application_id = oci_functions_application.model-hub-sync.id
  config = {
  }
  display_name = "vault-management"
  freeform_tags = {
  }
  image         = format("%s.ocir.io/%s/%s:develop", lower(data.oci_identity_regions.region.regions[0]["key"]), data.oci_objectstorage_namespace.object_storage_namespace.namespace,oci_artifacts_container_repository.model-hub-sync-vault-management.display_name)
  memory_in_mbs = "256"
  provisioned_concurrency_config {
    strategy = "NONE"
  }
  timeout_in_seconds = "300"
  trace_config {
    is_enabled = "false"
  }
}

resource oci_functions_function database-migration {
  depends_on = [terraform_data.copy_docker_images]
  application_id = oci_functions_application.model-hub-sync.id
  config = {
  }
  display_name = "database-migration"
  freeform_tags = {
  }
  image         = format("%s.ocir.io/%s/%s:develop", lower(data.oci_identity_regions.region.regions[0]["key"]), data.oci_objectstorage_namespace.object_storage_namespace.namespace,oci_artifacts_container_repository.model-hub-sync-database-migration.display_name)
  memory_in_mbs = "128"
  provisioned_concurrency_config {
    strategy = "NONE"
  }
  timeout_in_seconds = "300"
  trace_config {
    is_enabled = "false"
  }
}

resource oci_functions_function sync {
  depends_on = [terraform_data.copy_docker_images]
  application_id = oci_functions_application.model-hub-sync.id
  config = {
  }
  display_name = "sync"
  freeform_tags = {
  }
  image         = format("%s.ocir.io/%s/%s:develop", lower(data.oci_identity_regions.region.regions[0]["key"]), data.oci_objectstorage_namespace.object_storage_namespace.namespace,oci_artifacts_container_repository.model-hub-sync-sync.display_name)
  memory_in_mbs = "128"
  provisioned_concurrency_config {
    strategy = "NONE"
  }
  timeout_in_seconds = "300"
  trace_config {
    is_enabled = "false"
  }
}

resource oci_functions_function sync-all {
  depends_on = [terraform_data.copy_docker_images]
  application_id = oci_functions_application.model-hub-sync.id
  config = {
  }
  display_name = "sync-all"
  freeform_tags = {
  }
  image         = format("%s.ocir.io/%s/%s:develop", lower(data.oci_identity_regions.region.regions[0]["key"]), data.oci_objectstorage_namespace.object_storage_namespace.namespace,oci_artifacts_container_repository.model-hub-sync-sync-all.display_name)
  memory_in_mbs = "128"
  provisioned_concurrency_config {
    strategy = "NONE"
  }
  timeout_in_seconds = "300"
  trace_config {
    is_enabled = "false"
  }
}

resource oci_functions_function git-providers-api {
  depends_on = [terraform_data.copy_docker_images]
  application_id = oci_functions_application.model-hub-sync.id
  config = {
  }
  display_name = "git-providers-api"
  freeform_tags = {
  }
  image         = format("%s.ocir.io/%s/%s:develop", lower(data.oci_identity_regions.region.regions[0]["key"]), data.oci_objectstorage_namespace.object_storage_namespace.namespace,oci_artifacts_container_repository.model-hub-sync-git-providers-api.display_name)
  memory_in_mbs = "128"
  provisioned_concurrency_config {
    strategy = "NONE"
  }
  timeout_in_seconds = "60"
  trace_config {
    is_enabled = "false"
  }
}

resource oci_functions_function update-oci-functions {
  depends_on = [terraform_data.copy_docker_images]
  application_id = oci_functions_application.model-hub-sync.id
  config = {
  }
  display_name = "update-oci-functions"
  freeform_tags = {
  }
  image         = format("%s.ocir.io/%s/%s:develop", lower(data.oci_identity_regions.region.regions[0]["key"]), data.oci_objectstorage_namespace.object_storage_namespace.namespace,oci_artifacts_container_repository.model-hub-sync-update-oci-functions.display_name)
  memory_in_mbs = "128"
  provisioned_concurrency_config {
    strategy = "NONE"
  }
  timeout_in_seconds = "300"
  trace_config {
    is_enabled = "false"
  }
}
