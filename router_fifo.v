module router_fifo(clock,resetn,data_in,read_enb,write_enb,data_out,full,empty,lfd_state,soft_reset);

input lfd_state;
input [7:0] data_in;
input clock,resetn,read_enb,write_enb,soft_reset;
reg [4:0] rd_addr, wr_addr;
output reg [7:0] data_out;
reg [6:0] count;

output full, empty;
integer i;

reg [8:0] mem[0:15];
reg [7:0] data_out_reg; // Intermediate register for data_out

// write
always@(posedge clock) begin 
    if(~resetn || soft_reset) begin 
        for(i = 0; i <= 15; i = i + 1)
            mem[i] <= 0;
    end else if(write_enb && !full) begin
        if(lfd_state)
            {mem[wr_addr[3:0]][8], mem[wr_addr[3:0]][7:0]} <= {lfd_state, data_in};
        else
            {mem[wr_addr[3:0]][8], mem[wr_addr[3:0]][7:0]} <= {1'b0, data_in};
    end
end

// read
always@(posedge clock) begin 
    if(~resetn) begin 
        data_out_reg <= 0;
        data_out <= 0; // Reset data_out as well
    end else if(soft_reset) begin
        data_out <= 8'dz;
    end else if(read_enb && !empty) begin
        data_out_reg <= mem[rd_addr[3:0]][7:0];
        data_out <= mem[rd_addr[3:0]][7:0]; // Update data_out here
    end else if(count == 0 && data_out_reg != 0) begin
        data_out <= 8'dz;
    end
end

// counter
always@(posedge clock) begin
    if(read_enb && !empty) begin
        if(mem[rd_addr[3:0]][8]) begin
            count <= mem[rd_addr[3:0]][7:2] + 1;
        end else if(count != 0) begin
            count <= count - 1;
        end
    end  
end

// address handling
always@(posedge clock) begin
    if(~resetn || soft_reset) begin
        rd_addr <= 0;
        wr_addr <= 0;
    end else begin
        if(write_enb && !full)
            wr_addr <= wr_addr + 1;
        if(read_enb && !empty)
            rd_addr <= rd_addr + 1;
    end
end

assign empty = (wr_addr==rd_addr)?1'b1:1'b0;
assign full = (wr_addr==5'b10000 && rd_addr==5'b00000)?1'b1:1'b0;

endmodule
