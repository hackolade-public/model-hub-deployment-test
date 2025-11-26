/*
 * Copyright © 2016-2025 by IntegrIT S.A. dba Hackolade.  All rights reserved.
 *
 * The copyright to the computer software herein is the property of IntegrIT S.A.
 * The software may be used and/or copied only with the written permission of
 * IntegrIT S.A. or in accordance with the terms and conditions stipulated in
 * the agreement/contract under which the software has been supplied.
 */
resource oci_vault_secret oracle_password_secret {
  compartment_id = var.compartment_ocid
  description = "Password to connect to the Hub database"
  freeform_tags = {
  }
  key_id = oci_kms_key.HubEncryptionKey.id
  metadata = {
  }
  secret_content {
    content_type = "BASE64"
    content = base64encode(var.hub_db_schema_password)
  }
  secret_name = "ORACLE_PASSWORD"
  vault_id    = oci_kms_vault.Stores-secrets-used-by-the-model-hub.id
}

resource oci_vault_secret oci_token {
  compartment_id = var.compartment_ocid
  description = "Token used to push images into OCI container registry"
  freeform_tags = {
  }
  key_id = oci_kms_key.HubEncryptionKey.id
  metadata = {
  }
  secret_content {
    content_type = "BASE64"
    content = base64encode(oci_identity_auth_token.auth_token_registry.token)
  }
  secret_name = "OCI_TOKEN"
  vault_id    = oci_kms_vault.Stores-secrets-used-by-the-model-hub.id
}

resource oci_vault_secret github_configuration_secret {
  compartment_id = var.compartment_ocid
  description    = "Configuration need to sync models from GitHub"
  key_id         = oci_kms_key.HubEncryptionKey.id
  secret_name    = "GITHUB_CONFIGURATION"
  vault_id       = oci_kms_vault.Stores-secrets-used-by-the-model-hub.id

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      secret_content,
    ]
  }

  secret_content {
    content_type = "BASE64"
    content      = base64encode("[]")
  }
}

resource oci_vault_secret gitlab_configuration_secret {
  compartment_id = var.compartment_ocid
  description = "Configuration need to sync models from GitLab"
  key_id = oci_kms_key.HubEncryptionKey.id
  secret_name = "GITLAB_CONFIGURATION"
  vault_id    = oci_kms_vault.Stores-secrets-used-by-the-model-hub.id

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      secret_content,
    ]
  }

  secret_content {
    content_type = "BASE64"
    content      = base64encode("[]")
  }
}

resource oci_vault_secret azuredevops_configuration_secret {
  compartment_id = var.compartment_ocid
  description = "Configuration need to sync models from Azure DevOps"
  key_id = oci_kms_key.HubEncryptionKey.id
  secret_name = "AZUREDEVOPS_CONFIGURATION"
  vault_id    = oci_kms_vault.Stores-secrets-used-by-the-model-hub.id

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      secret_content,
    ]
  }

  secret_content {
    content_type = "BASE64"
    content      = base64encode("[]")
  }
}

resource oci_vault_secret bitbucket_configuration_secret {
  compartment_id = var.compartment_ocid
  description = "Configuration need to sync models from Bitbucket"
  key_id = oci_kms_key.HubEncryptionKey.id
  secret_name = "BITBUCKET_CONFIGURATION"
  vault_id    = oci_kms_vault.Stores-secrets-used-by-the-model-hub.id

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      secret_content,
    ]
  }

  secret_content {
    content_type = "BASE64"
    content      = base64encode("[]")
  }
}
