module router_sync(detect_add,data_in,write_enb_reg,clock,resetn,vld_out_0,vld_out_1,vld_out_2,read_enb_0,read_enb_1,read_enb_2,write_enb,fifo_full,empty_0,empty_1,empty_2,soft_reset_0,soft_reset_1,soft_reset_2,full_0,full_1,full_2);
input detect_add,write_enb_reg,clock,resetn,read_enb_0,read_enb_1,read_enb_2,empty_0,empty_1,empty_2,full_0,full_1,full_2;
input [1:0]data_in;
output vld_out_0,vld_out_1,vld_out_2;
output reg [2:0]write_enb;
output reg fifo_full;

reg [1:0]temp;//additional internal variable to detect the address to which fifo the packet has to go
reg [5:0]counter0,counter1,counter2;
output reg soft_reset_0;
output reg soft_reset_1;
output reg soft_reset_2;

always@(temp or full_0 or full_1 or full_2)
begin
    case(temp)
       2'b00: fifo_full = full_0;
       2'b01: fifo_full = full_1;
       2'b10: fifo_full = full_2;
       default: fifo_full = 0;
	endcase
end

always@(posedge clock)
begin
    if(!resetn)
	    temp <= 2'b00;
	else if(detect_add)
	    temp <= data_in;
	else
	    temp <= temp;
end

always@(posedge clock)
begin
    if(!resetn)
        write_enb <= 3'b000;
    else if (write_enb_reg) begin
        case(temp)
            2'b00: write_enb <= 3'b001;
            2'b01: write_enb <= 3'b010;
            2'b10: write_enb <= 3'b100;
            default: write_enb <= 3'b000;
        endcase
    end 
    else begin
        write_enb <= 3'b000;
    end
end

assign vld_out_0 = ~empty_0;
assign vld_out_1 = ~empty_1;
assign vld_out_2 = ~empty_2;

wire flag0, flag1, flag2;
assign flag0 = (counter0 == 5'd30);
assign flag1 = (counter1 == 5'd30);
assign flag2 = (counter2 == 5'd30);

always@(posedge clock)
begin
    if (!resetn) begin
        counter0 <= 5'b00001;
        soft_reset_0 <= 0;
    end else if (!read_enb_0 && vld_out_0) begin
        if (flag0) begin
            soft_reset_0 <= 1;
            counter0 <= 5'b00001;
        end else begin
            counter0 <= counter0 + 1;
            soft_reset_0 <= 0;
        end
    end
end

always@(posedge clock)
begin
    if (!resetn) begin
        counter1 <= 5'b00001;
        soft_reset_1 <= 0;
    end else if (!read_enb_1 && vld_out_1) begin
        if (flag1) begin
            soft_reset_1 <= 1;
            counter1 <= 5'b00001;
        end else begin
            counter1 <= counter1 + 1;
            soft_reset_1 <= 0;
        end
    end
end

always@(posedge clock)
begin
    if (!resetn) begin
        counter2 <= 5'b00001;
        soft_reset_2 <= 0;
    end else if (!read_enb_2 && vld_out_2) begin
        if (flag2) begin
            soft_reset_2 <= 1;
            counter2 <= 5'b00001;
        end else begin
            counter2 <= counter2 + 1;
            soft_reset_2 <= 0;
        end
    end
end

endmodule
