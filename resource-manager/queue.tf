/*
 * Copyright © 2016-2025 by IntegrIT S.A. dba Hackolade.  All rights reserved.
 *
 * The copyright to the computer software herein is the property of IntegrIT S.A.
 * The software may be used and/or copied only with the written permission of
 * IntegrIT S.A. or in accordance with the terms and conditions stipulated in
 * the agreement/contract under which the software has been supplied.
 */
resource oci_queue_queue gitFileChanges {
  channel_consumption_limit = "100"
  compartment_id            = var.compartment_ocid
  dead_letter_queue_delivery_count = "1"
  display_name = "gitFileChanges"
  freeform_tags = {
  }
  retention_in_seconds  = "86400"
  timeout_in_seconds    = "30"
  visibility_in_seconds = "300"
}

