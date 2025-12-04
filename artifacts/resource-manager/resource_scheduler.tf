/*
 * Copyright © 2016-2025 by IntegrIT S.A. dba Hackolade.  All rights reserved.
 *
 * The copyright to the computer software herein is the property of IntegrIT S.A.
 * The software may be used and/or copied only with the written permission of
 * IntegrIT S.A. or in accordance with the terms and conditions stipulated in
 * the agreement/contract under which the software has been supplied.
 */
resource oci_resource_scheduler_schedule update-oci-functions {
  action         = "START_RESOURCE"
  compartment_id = var.compartment_ocid
  defined_tags = {}
  description  = "Updates docker images for OCI functions and run db migrations"
  display_name = "${data.oci_identity_compartment.modelhub_compartment.name}-update-oci-functions"
  freeform_tags = {
  }
  recurrence_details = "FREQ=HOURLY;INTERVAL=1"
  recurrence_type    = "ICAL"
  resources {
    id = oci_functions_function.update-oci-functions.id
    metadata = {}
  }
  resources {
    id = oci_functions_function.database-migration.id
    metadata = {}
  }
  state = "ACTIVE"
  time_starts = timeadd(timestamp(), "10m")
}
