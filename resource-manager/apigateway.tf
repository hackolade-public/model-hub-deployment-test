/*
 * Copyright © 2016-2025 by IntegrIT S.A. dba Hackolade.  All rights reserved.
 *
 * The copyright to the computer software herein is the property of IntegrIT S.A.
 * The software may be used and/or copied only with the written permission of
 * IntegrIT S.A. or in accordance with the terms and conditions stipulated in
 * the agreement/contract under which the software has been supplied.
 */

locals {
  audience = replace(oci_identity_domain.modelhub_domain.url, ":443", "")
  jwks_uri = format("%s/admin/v1/SigningCert/jwk", oci_identity_domain.modelhub_domain.url)
  issuer = "https://identity.oraclecloud.com/"
}

resource oci_apigateway_gateway model-hub-gateway {
  compartment_id = var.compartment_ocid
  display_name  = "model-hub-gateway"
  endpoint_type = "PUBLIC"
  freeform_tags = {}
  network_security_group_ids = []
  response_cache_details {
    type = "NONE"
  }
  subnet_id = oci_core_subnet.public-subnet-model-hub-VCN.id
}

resource oci_apigateway_deployment model-hub-api {
  compartment_id = var.compartment_ocid
  display_name = "model-hub-api"
  freeform_tags = {}
  gateway_id  = oci_apigateway_gateway.model-hub-gateway.id
  path_prefix = "/gateway/public"
  specification {
    logging_policies {
      execution_log {
        log_level = "INFO"
      }
    }
    request_policies {
      mutual_tls {
        allowed_sans = []
        is_verified_certificate_required = "false"
      }
      rate_limiting {
        rate_in_requests_per_second = 50
        rate_key = "CLIENT_IP"
      }
    }
    routes {
      backend {
        function_id = oci_functions_function.sync.id
        type = "ORACLE_FUNCTIONS_BACKEND"
      }
      logging_policies {
        execution_log {
          log_level = ""
        }
      }
      methods = [
        "POST",
      ]
      path = "/sync"
      request_policies {}
      response_policies {}
    }
    routes {
      backend {
        body = jsonencode({
          oci = {
            identityServer = oci_identity_domain.modelhub_domain.url
            clientId = oci_identity_domains_app.modelhub_portal_authentication.name
          }
        })

        headers {
          name = "Content-Type"
          value = "application/json"
        }
        status = 200

        type = "STOCK_RESPONSE_BACKEND"
      }
      logging_policies {
        execution_log {
          log_level = ""
        }
      }
      methods = [
        "GET",
      ]
      path = "/info"
      request_policies {}
      response_policies {}
    }
  }
}

resource oci_apigateway_deployment model-hub-functions {
  compartment_id = var.compartment_ocid
  display_name = "model-hub-functions"
  freeform_tags = {}
  gateway_id  = oci_apigateway_gateway.model-hub-gateway.id
  path_prefix = "/gateway/devops"
  specification {
    logging_policies {
      execution_log {
        log_level = "INFO"
      }
    }
    request_policies {
      mutual_tls {
        allowed_sans = []
        is_verified_certificate_required = "false"
      }
      rate_limiting {
        rate_in_requests_per_second = 50
        rate_key = "CLIENT_IP"
      }
      authentication {
        type = "JWT_AUTHENTICATION"
        audiences = [local.audience]
        is_anonymous_access_allowed = false
        issuers = [local.issuer]
        public_keys {
            type = "REMOTE_JWKS"
            max_cache_duration_in_hours = 1
            uri = local.jwks_uri
        }
        token_auth_scheme = "Bearer"
        token_header = "Authorization"
      }
    }
    routes {
      backend {
        function_id = oci_functions_function.update-oci-functions.id
        type = "ORACLE_FUNCTIONS_BACKEND"
      }
      logging_policies {
        execution_log {
          log_level = ""
        }
      }
      methods = [
        "POST",
      ]
      path = "/update-oci-functions"
      request_policies {
        authorization {
          allowed_scope = ["urn:opc:idm:t.namedappadmin"]
          type = "ANY_OF"
        }
      }
      response_policies {}
    }
    routes {
      backend {
        function_id = oci_functions_function.database-migration.id
        type = "ORACLE_FUNCTIONS_BACKEND"
      }
      logging_policies {
        execution_log {
          log_level = ""
        }
      }
      methods = [
        "POST",
      ]
      path = "/run-db-migrations"
      request_policies {}
      response_policies {}
    }
  }
}

resource oci_apigateway_deployment model-hub-admin-api {
  compartment_id = var.compartment_ocid
  display_name = "model-hub-admin-api"
  freeform_tags = {}
  gateway_id  = oci_apigateway_gateway.model-hub-gateway.id
  path_prefix = "/gateway/admin"
  specification {
    logging_policies {
      execution_log {
        log_level = "INFO"
      }
    }
    request_policies {
      mutual_tls {
        allowed_sans = []
        is_verified_certificate_required = "false"
      }
      rate_limiting {
        rate_in_requests_per_second = 50
        rate_key = "CLIENT_IP"
      }
      authentication {
        type = "JWT_AUTHENTICATION"
        audiences = [local.audience]
        is_anonymous_access_allowed = false
        issuers = [local.issuer]
        public_keys {
            type = "REMOTE_JWKS"
            max_cache_duration_in_hours = 1
            uri = local.jwks_uri
        }
        token_auth_scheme = "Bearer"
        token_header = "Authorization"
      }
    }
    routes {
      backend {
        function_id = oci_functions_function.vault-management.id
        type = "ORACLE_FUNCTIONS_BACKEND"
      }
      logging_policies {
        execution_log {
          log_level = ""
        }
      }
      methods = [
        "POST",
      ]
      path = "/manage-secrets"
      request_policies {
        authorization {
          allowed_scope = ["urn:opc:idm:t.namedappadmin"]
          type = "ANY_OF"
        }
      }
      response_policies {}
    }
    routes {
      backend {
        function_id = oci_functions_function.git-providers-api.id
        type = "ORACLE_FUNCTIONS_BACKEND"
      }
      logging_policies {
        execution_log {
          log_level = ""
        }
      }
      methods = [
        "POST",
      ]
      path = "/git-providers"
      request_policies {
        authorization {
          allowed_scope = ["urn:opc:idm:t.namedappadmin"]
          type = "ANY_OF"
        }
      }
      response_policies {}
    }
    routes {
      backend {
        function_id = oci_functions_function.sync-all.id
        type = "ORACLE_FUNCTIONS_BACKEND"
      }
      logging_policies {
        execution_log {
          log_level = ""
        }
      }
      methods = [
        "POST",
      ]
      path = "/sync-all"
      request_policies {
        authorization {
          allowed_scope = ["urn:opc:idm:t.namedappadmin"]
          type = "ANY_OF"
        }
      }
      response_policies {}
    }
  }
}

output "ApiGatewayEndpoint" {
  value = format("https://%s",oci_apigateway_gateway.model-hub-gateway.hostname)
}

