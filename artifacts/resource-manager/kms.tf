/*
 * Copyright © 2016-2025 by IntegrIT S.A. dba Hackolade.  All rights reserved.
 *
 * The copyright to the computer software herein is the property of IntegrIT S.A.
 * The software may be used and/or copied only with the written permission of
 * IntegrIT S.A. or in accordance with the terms and conditions stipulated in
 * the agreement/contract under which the software has been supplied.
 */
resource oci_kms_vault Stores-secrets-used-by-the-model-hub {
  compartment_id = var.compartment_ocid
  display_name = "Stores secrets used by the hub in the current compartment"
  vault_type = "DEFAULT"
}

# Wait a bit for the kms vault to be ready
# If not, the terraform will fail because the vault are not found
resource "time_sleep" "wait_for_kms_vault_to_be_ready" {
  depends_on = [
    oci_kms_vault.Stores-secrets-used-by-the-model-hub
  ]
  create_duration = "1m"
}

resource oci_kms_key HubEncryptionKey {
  depends_on = [
    time_sleep.wait_for_kms_vault_to_be_ready
  ]
  compartment_id = var.compartment_ocid
  desired_state = "ENABLED"
  display_name  = "HubEncryptionKey"
  is_auto_rotation_enabled = "false"
  key_shape {
    algorithm = "AES"
    curve_id  = ""
    length    = "32"
  }
  management_endpoint = oci_kms_vault.Stores-secrets-used-by-the-model-hub.management_endpoint
  protection_mode     = "HSM"
}

resource oci_kms_key_version HubEncryptionKey_key_version {
  key_id              = oci_kms_key.HubEncryptionKey.id
  management_endpoint = oci_kms_vault.Stores-secrets-used-by-the-model-hub.management_endpoint
}

