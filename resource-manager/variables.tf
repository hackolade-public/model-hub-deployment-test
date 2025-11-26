/*
 * Copyright © 2016-2025 by IntegrIT S.A. dba Hackolade.  All rights reserved.
 *
 * The copyright to the computer software herein is the property of IntegrIT S.A.
 * The software may be used and/or copied only with the written permission of
 * IntegrIT S.A. or in accordance with the terms and conditions stipulated in
 * the agreement/contract under which the software has been supplied.
 */
variable compartment_ocid {}
variable tenancy_ocid {}
variable region {}
variable oci_username {
  description = "Username of an OCI user that is going to be used to push docker images into OCI registry"
}

variable hub_db_name {
  description = "Name of the database that will be created. The name must contain only letters and numbers, starting with a letter. 30 characters max. Spaces are not allowed"
  validation {
    condition     = length(var.hub_db_name) <= 30
    error_message = "The hub_db_name value must be less than 30 characters."
  }
  validation {
    condition     = length(regexall("[^a-zA-Z0-9]+", var.hub_db_name)) == 0
    error_message = "The hub_db_name value must contain only letters and numbers, starting with a letter."
  }
}
variable hub_db_admin_password {
  sensitive = true
  description = "Password for the admin user of the database"
}
variable hub_db_schema_username {
  description = "Name of the database schema/user that will be created. This schema will be used to store all your models"
}
variable hub_db_schema_password {
  sensitive = true
  description = "Password for the user described by hub_db_schema_username"
}
variable hub_db_ecpu_count {
  default = 0
  type = number
  description = "ECPU count for the database. If 0, then a free tier database will be created. Minimum starts at 2"
}
variable hub_db_storage {
  default = 20
  type = number
  description = "Specify the storage size in GB you wish to make available to your database. Minimum starts at 20"
}
variable hub_domain_name {
  description = "DNS of the HUB portal"
}
