/*
 * Copyright © 2016-2025 by IntegrIT S.A. dba Hackolade.  All rights reserved.
 *
 * The copyright to the computer software herein is the property of IntegrIT S.A.
 * The software may be used and/or copied only with the written permission of
 * IntegrIT S.A. or in accordance with the terms and conditions stipulated in
 * the agreement/contract under which the software has been supplied.
 */

# Wait for the functions and policies to be ready
# OCI policies can take some time to fully propagate
# It's especially needed for functions to have access to the vault and secrets
resource "time_sleep" "wait_for_functions_to_be_ready" {
  triggers = {
    database_migration = oci_functions_function.database-migration.id
    hck_hub_functions_policy =oci_identity_policy.hck-hub-functions.id
    hck_hub_functions_dynamic_group = oci_identity_dynamic_group.hck-hub-functions.id
    kms_vault = oci_kms_vault.Stores-secrets-used-by-the-model-hub.id
  }
  create_duration = "30s"
}

resource "oci_functions_invoke_function" "database-migration" {
  depends_on = [
    terraform_data.create_new_schema,
    time_sleep.wait_for_functions_to_be_ready
  ]

  lifecycle {
    replace_triggered_by = [terraform_data.create_new_schema]
  }

  function_id = oci_functions_function.database-migration.id

  fn_intent = "httprequest"
  fn_invoke_type = "sync"
  base64_encode_content = false
}
