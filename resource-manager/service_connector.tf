/*
 * Copyright © 2016-2025 by IntegrIT S.A. dba Hackolade.  All rights reserved.
 *
 * The copyright to the computer software herein is the property of IntegrIT S.A.
 * The software may be used and/or copied only with the written permission of
 * IntegrIT S.A. or in accordance with the terms and conditions stipulated in
 * the agreement/contract under which the software has been supplied.
 */
resource oci_sch_service_connector apply_model_changes_service_connector {
    compartment_id = var.compartment_ocid
    display_name = "Apply model changes"
    source {
        kind = "plugin"
        config_map = "{\"queueId\": \"${oci_queue_queue.gitFileChanges.id}\"}"
        plugin_name = "QueueSource"
    }
    target {
        kind = "functions"
        batch_size_in_num = 1
        batch_time_in_sec = 345
        function_id = oci_functions_function.apply-model-changes.id
    }
}
