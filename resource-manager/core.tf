/*
 * Copyright © 2016-2025 by IntegrIT S.A. dba Hackolade.  All rights reserved.
 *
 * The copyright to the computer software herein is the property of IntegrIT S.A.
 * The software may be used and/or copied only with the written permission of
 * IntegrIT S.A. or in accordance with the terms and conditions stipulated in
 * the agreement/contract under which the software has been supplied.
 */
data "oci_identity_regions" "region" {
  filter {
    name   = "name"
    values = [var.region]
  }
}

resource oci_core_vcn model-hub-VCN {
  cidr_blocks = [
    "10.0.0.0/16",
  ]
  compartment_id = var.compartment_ocid
  display_name = "model hub VCN"
  dns_label    = "modelhubvcn"
  ipv6private_cidr_blocks = []
  security_attributes = {}
}

resource oci_core_nat_gateway NAT-gateway-model-hub-VCN {
  block_traffic  = "false"
  compartment_id = var.compartment_ocid
  display_name = "NAT gateway-model hub VCN"
  vcn_id = oci_core_vcn.model-hub-VCN.id
}

resource oci_core_default_dhcp_options Default-DHCP-Options-for-model-hub-VCN {
  compartment_id = var.compartment_ocid
  display_name     = "Default DHCP Options for model hub VCN"
  domain_name_type = "CUSTOM_DOMAIN"
  manage_default_resource_id = oci_core_vcn.model-hub-VCN.default_dhcp_options_id
  options {
    custom_dns_servers = [
    ]
    server_type = "VcnLocalPlusInternet"
    type        = "DomainNameServer"
  }
  options {
    search_domain_names = [
      "modelhubvcn.oraclevcn.com",
    ]
    type = "SearchDomain"
  }
}

resource oci_core_internet_gateway Internet-gateway-model-hub-VCN {
  compartment_id = var.compartment_ocid
  display_name = "Internet gateway-model hub VCN"
  enabled      = "true"
  vcn_id = oci_core_vcn.model-hub-VCN.id
}

resource oci_core_subnet private-subnet-model-hub-VCN {
  cidr_block     = "10.0.1.0/24"
  compartment_id = var.compartment_ocid
  dhcp_options_id = oci_core_default_dhcp_options.Default-DHCP-Options-for-model-hub-VCN.id
  display_name    = "private subnet-model hub VCN"
  dns_label       = "sub10102010521"
  ipv6cidr_blocks = []
  prohibit_internet_ingress  = "true"
  prohibit_public_ip_on_vnic = "true"
  route_table_id             = oci_core_route_table.route-table-for-private-subnet-model-hub-VCN.id
  security_list_ids = [
    oci_core_security_list.security-list-for-private-subnet-model-hub-VCN.id,
  ]
  vcn_id = oci_core_vcn.model-hub-VCN.id
}

resource oci_core_subnet public-subnet-model-hub-VCN {
  cidr_block     = "10.0.0.0/24"
  compartment_id = var.compartment_ocid
  dhcp_options_id = oci_core_default_dhcp_options.Default-DHCP-Options-for-model-hub-VCN.id
  display_name    = "public subnet-model hub VCN"
  dns_label       = "sub10102010520"
  ipv6cidr_blocks = []
  prohibit_internet_ingress  = "false"
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = oci_core_vcn.model-hub-VCN.default_route_table_id
  security_list_ids = [
    oci_core_vcn.model-hub-VCN.default_security_list_id,
  ]
  vcn_id = oci_core_vcn.model-hub-VCN.id
}

resource oci_core_route_table route-table-for-private-subnet-model-hub-VCN {
  compartment_id = var.compartment_ocid
  display_name = "route table for private subnet-model hub VCN"
  vcn_id = oci_core_vcn.model-hub-VCN.id
  route_rules {
    destination = lookup(data.oci_core_services.all_oci_services[0].services[0], "cidr_block")
    destination_type = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.Service-gateway-model-hub-VCN.id
  }
  route_rules {
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.NAT-gateway-model-hub-VCN.id
  }
}

resource oci_core_default_route_table default-route-table-for-model-hub-VCN {
  compartment_id = var.compartment_ocid
  display_name = "default route table for model hub VCN"
  manage_default_resource_id = oci_core_vcn.model-hub-VCN.default_route_table_id
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.Internet-gateway-model-hub-VCN.id
  }
}

resource oci_core_security_list security-list-for-private-subnet-model-hub-VCN {
  compartment_id = var.compartment_ocid
  display_name = "security list for private subnet-model hub VCN"
  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol  = "6"
    tcp_options {
      max = "443"
      min = "443"
    }
    description = "HTTPS"
    stateless = "false"
  }
  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol  = "6"
    tcp_options {
      max = "1522"
      min = "1521"
    }
    description = "For Oracle database"
    stateless = "false"
  }
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "22"
      min = "22"
    }
  }
  ingress_security_rules {
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  ingress_security_rules {
    icmp_options {
      code = "-1"
      type = "3"
    }
    protocol    = "1"
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  vcn_id = oci_core_vcn.model-hub-VCN.id
}

resource oci_core_default_security_list Default-Security-List-for-model-hub-VCN {
  compartment_id = var.compartment_ocid
  display_name = "Default Security List for model hub VCN"
  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol  = "all"
    stateless = "false"
  }
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "22"
      min = "22"
    }
  }
  ingress_security_rules {
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  ingress_security_rules {
    icmp_options {
      code = "-1"
      type = "3"
    }
    protocol    = "1"
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Access to 443 for API gateway"
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "443"
      min = "443"
    }
  }
  manage_default_resource_id = oci_core_vcn.model-hub-VCN.default_security_list_id
}

data "oci_core_services" "all_oci_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
  count = 1
}

resource oci_core_service_gateway Service-gateway-model-hub-VCN {
  compartment_id = var.compartment_ocid
  display_name = "Service gateway-model hub VCN"
  services {
    service_id = lookup(data.oci_core_services.all_oci_services[0].services[0], "id")
  }
  vcn_id = oci_core_vcn.model-hub-VCN.id
}
