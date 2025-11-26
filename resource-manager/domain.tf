/*
 * Copyright © 2016-2025 by IntegrIT S.A. dba Hackolade.  All rights reserved.
 *
 * The copyright to the computer software herein is the property of IntegrIT S.A.
 * The software may be used and/or copied only with the written permission of
 * IntegrIT S.A. or in accordance with the terms and conditions stipulated in
 * the agreement/contract under which the software has been supplied.
 */
resource "oci_identity_domain" "modelhub_domain" {
  compartment_id = var.compartment_ocid
  description = "Domain to regroup uses that can access the hub API"
  display_name = data.oci_identity_compartment.modelhub_compartment.name
  home_region = var.region
  license_type = "free"

  is_hidden_on_login = true
}

resource "oci_identity_domains_setting" "modelhub_domain_setting" {
  csr_access = "none"
  idcs_endpoint = oci_identity_domain.modelhub_domain.url
  schemas = ["urn:ietf:params:scim:schemas:oracle:idcs:Settings"]
  setting_id = "Settings"

  signing_cert_public_access = true
}

resource "oci_identity_domains_app" "modelhub_portal_authentication" {
  based_on_template {
      value = "CustomBrowserMobileTemplateId"
      well_known_id = "CustomBrowserMobileTemplateId"
  }
  display_name = "modelhub-portal-authentication"
  idcs_endpoint = oci_identity_domain.modelhub_domain.url
  schemas = [
    "urn:ietf:params:scim:schemas:oracle:idcs:App",
    "urn:ietf:params:scim:schemas:oracle:idcs:extension:OCITags"
  ]

  login_page_url = ""
  access_token_expiry = 3600
  active = true
  all_url_schemes_allowed = true
  allow_access_control = true
  allow_offline = true
  allowed_grants = ["authorization_code"]
  attribute_sets = ["all"]
  audience = "hub/"
  bypass_consent = true
  description = "Application used to authenticate users to the HUB"
  is_oauth_client = true
  is_oauth_resource = true
  redirect_uris = [
    format("https://%s/hub", var.hub_domain_name)
  ]
  refresh_token_expiry = 604800
  show_in_my_apps = false
}

output "IdentityEndpoint" {
  value = oci_identity_domain.modelhub_domain.url
}
output "IdentityClientId" {
  value = oci_identity_domains_app.modelhub_portal_authentication.name
}
