/*
 * Copyright © 2016-2025 by IntegrIT S.A. dba Hackolade.  All rights reserved.
 *
 * The copyright to the computer software herein is the property of IntegrIT S.A.
 * The software may be used and/or copied only with the written permission of
 * IntegrIT S.A. or in accordance with the terms and conditions stipulated in
 * the agreement/contract under which the software has been supplied.
 */
resource oci_logging_log_group hckhub_logs {
  compartment_id = var.compartment_ocid
  display_name = "hckhub_logs"
  freeform_tags = {}
}

resource oci_logging_log model_hub_service_connector_logs {
  configuration {
    compartment_id = var.compartment_ocid
    source {
      category = "runlog"
      parameters = {
      }
      resource    = oci_sch_service_connector.apply_model_changes_service_connector.id
      service     = "och"
      source_type = "OCISERVICE"
    }
  }
  display_name = "model_hub_service_connector_logs"
  freeform_tags = {
  }
  is_enabled         = "true"
  log_group_id       = oci_logging_log_group.hckhub_logs.id
  log_type           = "SERVICE"
  retention_duration = "30"
}

resource oci_logging_log model_hub_functions_logs {
  configuration {
    compartment_id = var.compartment_ocid
    source {
      category = "invoke"
      parameters = {}
      resource    = oci_functions_application.model-hub-sync.id
      service     = "functions"
      source_type = "OCISERVICE"
    }
  }
  display_name = "model_hub_functions_logs"
  freeform_tags = {}
  is_enabled         = "true"
  log_group_id       = oci_logging_log_group.hckhub_logs.id
  log_type           = "SERVICE"
  retention_duration = "30"
}

resource oci_logging_log model_hub_api_execution {
  configuration {
    compartment_id = var.compartment_ocid
    source {
      category = "execution"
      parameters = {
      }
      resource    = oci_apigateway_deployment.model-hub-api.id
      service     = "apigateway"
      source_type = "OCISERVICE"
    }
  }
  defined_tags = {}
  display_name = "model_hub_api_execution"
  freeform_tags = {
  }
  is_enabled         = "true"
  log_group_id       = oci_logging_log_group.hckhub_logs.id
  log_type           = "SERVICE"
  retention_duration = "30"
}

resource oci_logging_log model_hub_api_access {
  configuration {
    compartment_id = var.compartment_ocid
    source {
      category = "access"
      parameters = {
      }
      resource    = oci_apigateway_deployment.model-hub-api.id
      service     = "apigateway"
      source_type = "OCISERVICE"
    }
  }
  defined_tags = {}
  display_name = "model_hub_api_access"
  freeform_tags = {
  }
  is_enabled         = "true"
  log_group_id       = oci_logging_log_group.hckhub_logs.id
  log_type           = "SERVICE"
  retention_duration = "30"
}
