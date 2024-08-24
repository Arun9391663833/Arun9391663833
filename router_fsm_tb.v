module router_fsm_tb();
reg clock,resetn,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full;
reg low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2;
reg [1:0]data_in;

wire busy,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state;
//instantiation
router_fsm dut(clock,resetn,pkt_valid,busy,parity_done,data_in,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state);

//clock generation
initial begin
	clock=0;
	forever #5 clock=!clock;
end

//task for reset
task reset_t;
begin
	@(negedge clock)
		resetn=0;
	@(negedge clock)
		resetn=1;
end
endtask

//task for path_1
task path_1;
begin
	@(negedge clock);
	pkt_valid=1;
	data_in=2'b00;
	fifo_empty_0=1;
	repeat(2)@(negedge clock);
	fifo_full=0;
	pkt_valid=0;
	repeat(2)@(negedge clock);
end
endtask 

//task for path_2
task path_2;
begin
	@(negedge clock);
	pkt_valid=1;
	data_in=2'b01;
	fifo_empty_1=1;
	repeat(2)@(negedge clock);
	fifo_full=1;
	@(negedge clock)
	fifo_full=0;
	@(negedge clock)
	parity_done=0;
	low_pkt_valid=1;
	repeat(2)@(negedge clock);
	fifo_full=0;
end
endtask

//task for path_3
task path_3;
begin
	@(negedge clock)
		pkt_valid=1;
		data_in=2'b10;
		fifo_empty_2=1;
	repeat(2)@(negedge clock);
		fifo_full=1;
	@(negedge clock)
		fifo_full=0;
	@(negedge clock)
		parity_done=0;
		low_pkt_valid=0;
	@(negedge clock)
		fifo_full=0;
		pkt_valid=0;
	repeat(2)@(negedge clock)
		fifo_full=1;
	@(negedge clock)
		fifo_full=0;
	@(negedge clock)
		parity_done=1;	
end
endtask

//task for path_4
task path_4;
begin
	@(negedge clock)
		pkt_valid=1;
		data_in=2'b10;
		fifo_empty_2=1;
	repeat(2)@(negedge clock);
		fifo_full=1;
	@(negedge clock)
		fifo_full=0;
	@(negedge clock)
		parity_done=0;
		low_pkt_valid=0;
	@(negedge clock)
		fifo_full=0;
		pkt_valid=0;
	repeat(2)@(negedge clock);
		fifo_full=0;	
end
endtask

initial begin
    resetn = 0;
    pkt_valid = 0;
    parity_done = 0;
    soft_reset_0 = 0;
    soft_reset_1 = 0;
    soft_reset_2 = 0;
    fifo_full = 0;
    low_pkt_valid = 0;
    fifo_empty_0 = 1;
    fifo_empty_1 = 1;
    fifo_empty_2 = 1;
	reset_t;
	path_1;
	path_3;
	path_2;
	path_4;
end

endmodule
