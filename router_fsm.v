module router_fsm(clock,resetn,pkt_valid,busy,parity_done,data_in,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state);
input clock,resetn,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2;
input [1:0]data_in;
output busy,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state;
//for fsm we have to define states as parameters
parameter DECODE_ADDRESS=3'b000,
          LOAD_FIRST_DATA=3'b001,
		  WAIT_TILL_EMPTY=3'b010,
		  LOAD_DATA=3'b011,
		  LOAD_PARITY=3'b100,
		  FIFO_FULL_STATE=3'b101,
		  CHECK_PARITY_ERROR=3'b110,
		  LOAD_AFTER_FULL=3'b111;

reg [2:0]next_state,present_state;
reg [1:0]addr;
//link data_in to addr
always@(data_in)
begin  
    addr<=data_in;
end
//present state logic
always@(posedge clock)
begin
    if(!resetn||soft_reset_0 || soft_reset_1 || soft_reset_2)
	begin   
	    present_state<=DECODE_ADDRESS;
	end
	else
	begin 
	    present_state<=next_state;
	end
end
//next state logic i.e, output logic
always@(*)
begin
next_state=present_state;
	case(present_state)
	    DECODE_ADDRESS:begin
                 if((pkt_valid&(data_in[1:0]==2'b00)&fifo_empty_0)|(pkt_valid&(data_in[1:0]==2'b01)&fifo_empty_1)|(pkt_valid&(data_in[1:0]==2'b10)&fifo_empty_2)) begin
					             next_state=LOAD_FIRST_DATA;
                 end                                                                                                                                
					       else if((pkt_valid&(data_in[1:0]==2'b00)&~fifo_empty_0)|(pkt_valid&(data_in[1:0]==2'b01)&~fifo_empty_1)|(pkt_valid&(data_in[1:0]==2'b10)&~fifo_empty_2)) begin
					             next_state=WAIT_TILL_EMPTY;
                 end                                                                                                                                                                     
					     end
		LOAD_FIRST_DATA:begin
		                    next_state=LOAD_DATA;
						end
        WAIT_TILL_EMPTY:begin
                        if(fifo_empty_0&&(addr==0)||fifo_empty_1&&(addr==1)||fifo_empty_2&&(addr==2))	
                            next_state=LOAD_FIRST_DATA;
						else
						    next_state=WAIT_TILL_EMPTY;
						end
		      LOAD_DATA:begin
			            if(!fifo_full&&!pkt_valid)
						    next_state=LOAD_PARITY;
						else if(fifo_full)
						    next_state=FIFO_FULL_STATE;
						end
			LOAD_PARITY:begin
			                next_state=CHECK_PARITY_ERROR;
						end
		FIFO_FULL_STATE:begin
		                if(fifo_full)
						    next_state=FIFO_FULL_STATE;
						else if(!fifo_full)
						    next_state=LOAD_AFTER_FULL;
						end
	 CHECK_PARITY_ERROR:begin
	                    if(fifo_full)
						    next_state=FIFO_FULL_STATE;
						else if(!fifo_full)
						    next_state=DECODE_ADDRESS;
						end
		LOAD_AFTER_FULL:begin
		                if(!parity_done&&low_pkt_valid)
						    next_state=LOAD_PARITY;
						else if(!parity_done&&!low_pkt_valid)
						    next_state=LOAD_DATA;
						else if(parity_done)
						    next_state=DECODE_ADDRESS;
						end
				default:begin
                 next_state=DECODE_ADDRESS;
						end
	endcase
end
//assigning the logics for outputs
assign detect_add= (present_state==DECODE_ADDRESS); 

assign lfd_state=(present_state==LOAD_FIRST_DATA);

assign busy= ((present_state==LOAD_FIRST_DATA)||(present_state==LOAD_PARITY)||(present_state==FIFO_FULL_STATE)||(present_state==LOAD_AFTER_FULL)||(present_state==WAIT_TILL_EMPTY)||(present_state==CHECK_PARITY_ERROR));

assign ld_state= (present_state==LOAD_DATA);

assign write_enb_reg= ((present_state==LOAD_DATA)||(present_state==LOAD_PARITY)||(present_state==LOAD_AFTER_FULL));

assign full_state=(present_state==FIFO_FULL_STATE);

assign laf_state=(present_state==LOAD_AFTER_FULL);

assign rst_int_reg=(present_state==CHECK_PARITY_ERROR);

endmodule

