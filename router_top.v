module router_top(clock,resetn,pkt_valid,busy,vld_out_0,vld_out_1,vld_out_2,read_enb_0,read_enb_1,read_enb_2,data_in,err,data_out_0,data_out_1,data_out_2);
input clock,resetn,pkt_valid,read_enb_0,read_enb_1,read_enb_2;
input [7:0]data_in;
output busy,vld_out_0,vld_out_1,vld_out_2,err;
output [7:0] data_out_0,data_out_1,data_out_2;
//internal wires
wire [7:0]dout;
wire [2:0]write_enb;
wire lfd_state,soft_reset_0,soft_reset_1,soft_reset_2,empty_0,empty_1,empty_2,full_0,full_1,full_2,write_enb_reg,fifo_empty_0,fifo_empty_1,fifo_empty_2;

//internal block connections
router_fifo f1(.clock(clock),
               .resetn(resetn),
               .data_in(dout),
               .read_enb(read_enb_0),
               .write_enb(write_enb[0]),
               .data_out(data_out_0),
               .full(full_0),
               .empty(empty_0),
               .lfd_state(lfd_state),
               .soft_reset(soft_reset_0));
               
router_fifo f2(.clock(clock),
               .resetn(resetn),
               .data_in(dout),
               .read_enb(read_enb_1),
               .write_enb(write_enb[1]),
               .data_out(data_out_1),
               .full(full_1),
               .empty(empty_1),
               .lfd_state(lfd_state),
               .soft_reset(soft_reset_1));
               
router_fifo f3(.clock(clock),
               .resetn(resetn),
               .data_in(dout),
               .read_enb(read_enb_2),
               .write_enb(write_enb[2]),
               .data_out(data_out_2),
               .full(full_2),
               .empty(empty_2),
               .lfd_state(lfd_state),
               .soft_reset(soft_reset_2));

router_fsm fsm1(.clock(clock),
                .resetn(resetn),
                .pkt_valid(pkt_valid),
                .busy(busy),
                .parity_done(parity_done),
                .data_in(data_in[1:0]),
                .soft_reset_0(soft_reset_0),
                .soft_reset_1(soft_reset_1),
                .soft_reset_2(soft_reset_2),
                .fifo_full(fifo_full),
                .low_pkt_valid(low_pkt_valid),
                .fifo_empty_0(empty_0),
                .fifo_empty_1(empty_1),
                .fifo_empty_2(empty_2),
                .detect_add(detect_add),
                .ld_state(ld_state),
                .laf_state(laf_state),
                .full_state(full_state),
                .write_enb_reg(write_enb_reg),
                .rst_int_reg(rst_int_reg),
                .lfd_state(lfd_state));

router_sync sync1(.detect_add(detect_add),
                  .data_in(data_in[1:0]),
                  .write_enb_reg(write_enb_reg),
                  .clock(clock),
                  .resetn(resetn),
                  .vld_out_0(vld_out_0),
                  .vld_out_1(vld_out_1),
                  .vld_out_2(vld_out_2),
                  .read_enb_0(read_enb_0),
                  .read_enb_1(read_enb_1),
                  .read_enb_2(read_enb_2),
                  .write_enb(write_enb),
                  .fifo_full(fifo_full),
                  .empty_0(empty_0),
                  .empty_1(empty_1),
                  .empty_2(empty_2),
                  .soft_reset_0(soft_reset_0),
                  .soft_reset_1(soft_reset_1),
                  .soft_reset_2(soft_reset_2),
                  .full_0(full_0),
                  .full_1(full_1),
                  .full_2(full_2));
                  

router_reg reg1(.clock(clock),
                .resetn(resetn),
                .pkt_valid(pkt_valid),
                .data_in(data_in),
                .fifo_full(fifo_full),
                .rst_int_reg(rst_int_reg),
                .ld_state(ld_state),
                .laf_state(laf_state),
                .lfd_state(lfd_state),
                .full_state(full_state),
                .detect_add(detect_add),
                .parity_done(parity_done),
                .low_pkt_valid(low_pkt_valid),
                .err(err),
                .dout(dout));

endmodule