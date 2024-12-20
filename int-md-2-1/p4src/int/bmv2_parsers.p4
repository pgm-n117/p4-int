/*************************************************************************
*********************** I N G R E S S  P A R S E R  **********************
*************************************************************************/

parser MyIngressParser(packet_in packet,
                        out headers hdr,
                        inout local_metadata_t local_metadata,
                        inout standard_metadata_t standard_metadata) {

    state start {
        transition select(standard_metadata.ingress_port) {
            CPU_PORT: parse_packet_out;
            default: parse_ethernet;
        }
    }

    state parse_packet_out {
        packet.extract(hdr.packet_out);
        transition parse_ethernet;
    }

    state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.ether_type) {
            TYPE_IPV4: parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        transition select(hdr.ipv4.protocol) {
            IP_PROTO_UDP: parse_udp;
            IP_PROTO_TCP: parse_tcp;
            default: accept;
        }
    }

    state parse_udp {
        packet.extract(hdr.udp);
        local_metadata.l4_src_port = hdr.udp.src_port;
        local_metadata.l4_dst_port = hdr.udp.dst_port;
        transition select(hdr.ipv4.dscp) {
            DSCP_INT &&& DSCP_MASK: parse_shim;
            default:  accept;
        }
    }

    state parse_tcp {
        packet.extract(hdr.tcp);
        local_metadata.l4_src_port = hdr.tcp.src_port;
        local_metadata.l4_dst_port = hdr.tcp.dst_port;
        transition select(hdr.ipv4.dscp) {
            DSCP_INT &&& DSCP_MASK: parse_shim;
            default:  accept;
        }
    }

    state parse_shim {
        packet.extract(hdr.intl4_shim);
        transition parse_int_hdr;
    }

    state parse_int_hdr {
        packet.extract(hdr.int_header);
        transition parse_int_data;
    }

    state parse_int_data {
        transition accept;
    }
}



/*************************************************************************
****************  E G R E S S   D E P A R S E R   ************************
*************************************************************************/

control MyEgressDeparser(packet_out packet, 
                         in headers hdr) {
    
    //Checksum() ipv4Checksum;
    
    apply {

        //hdr.ipv4.hdr_checksum = ipv4Checksum.update(
        //     {
        //        hdr.ipv4.version,
        //        hdr.ipv4.ihl,
        //        hdr.ipv4.dscp,
        //        hdr.ipv4.ecn,
        //        hdr.ipv4.len,
        //        hdr.ipv4.identification,
        //        hdr.ipv4.flags,
        //        hdr.ipv4.frag_offset,
        //        hdr.ipv4.ttl,
        //        hdr.ipv4.protocol,
        //        hdr.ipv4.src_addr,
        //        hdr.ipv4.dst_addr
        //     }
        // );

        //TODO: REPORT HEADERS 
        //packet.emit(hdr.report_ethernet);
        //packet.emit(hdr.report_ipv4);
        //packet.emit(hdr.report_udp);
        //packet.emit(hdr.report_group_header);
        packet.emit(hdr.packet_in);
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
        packet.emit(hdr.udp);
        packet.emit(hdr.tcp);

        //TODO: INT HEADERS 
        //packet.emit(hdr.intl4_shim);
        //packet.emit(hdr.int_header);
        //packet.emit(hdr.int_switch_id);
        //packet.emit(hdr.int_level1_port_ids);
        //packet.emit(hdr.int_hop_latency);
        //packet.emit(hdr.int_q_occupancy);
        //packet.emit(hdr.int_ingress_tstamp);
        //packet.emit(hdr.int_egress_tstamp);
        //packet.emit(hdr.int_level2_port_ids);
        //packet.emit(hdr.int_egress_tx_util);

        //packet.emit(hdr.int_data);
        
    }
}