`resetall
`timescale 1ns / 1ps
`default_nettype none


module spi_sram (
    input  wire clk,
    input  wire clk2,
    input  wire rst,
    input  wire en,
    input  wire en2,

    input  wire cs_n,

    input  wire mosi,
    output wire miso
);

typedef enum integer {
    IDLE,          // detect cs_n cmd bit 7, setup counter
    CMD1,          // cmd bits 6:1
    CMD2,          // cmd bits 0, setup addr and counter
    ADDR1,         // addr bits 23:1
    ADDR2,         // addr bit 0, mem read, setup counter
    READ_DUMMY,
    READ1,         // load dout, incr addr, data bit 0 (2nd pass)
    READ2,         // data bit 7:2
    READ3,         // data bit 1, setup counter
    WRITE1,
    WRITE2,
    WRITE3,
    DONE,
    ERR,
    DELAY
} State_Type;

State_Type state = IDLE;

State_Type next_state;

logic counter_reset;
logic [4:0]counter_reset_val;

logic din_shift;

logic addr_reset;
logic addr_shift;
logic addr_load_lsb;
logic addr_incr;
logic addr_early;

logic dout_load;
logic dout_shift;

logic mem_en;
logic mem_wr;


always_comb begin
    next_state = state;
  
    counter_reset = 0;
    counter_reset_val = (7-2);

    addr_reset = 0;
    addr_shift = 0;
    addr_load_lsb = 0;
    addr_incr  = 0;
    addr_early = 0;
    
    mem_en = 0;
    mem_wr = 0;
    
    din_shift = 0;
    
    dout_load = 0;
    dout_shift = 0;
    
    unique case(state)   
        default: begin // IDLE
            counter_reset = 1;
            counter_reset_val = (6-2); 

            din_shift = 1;

            if (!cs_n)
                next_state = CMD1;
        end
    
        CMD1: begin
            din_shift = 1;

            if (cs_n)
                next_state = DONE;
            else if (counter_done)
                next_state = CMD2;
        end

        CMD2: begin
            counter_reset = 1;
            counter_reset_val = (23-2);
            
            din_shift = 1;

            if (cs_n)
                next_state = DONE;
            else
                next_state = ADDR1;
        end        
    
        ADDR1: begin
            addr_shift = 1;

            if (cs_n)
                next_state = DONE;
            else if (counter_done) begin
                next_state = ADDR2;
            end
        end
        
        ADDR2: begin
            counter_reset = 1;
            counter_reset_val = (7-2);
            
            addr_early = 1;
            addr_load_lsb = 1;
            
            mem_en = 1;

            if (cs_n)
                next_state = DONE;
            else begin
                if (din[6:0] == 7'h03)
                    next_state = READ1;
                else if (din[6:0] == 7'h02)
                    next_state = WRITE1;
            end
        end   

        READ1: begin           
            dout_load = 1;
            addr_incr = 1;

            if (cs_n)
                next_state = DONE;
            else
                next_state = READ2;
        end
        
        READ2: begin
            dout_shift = 1;

            if (cs_n)
                next_state = DONE;
            else if (counter_done)
                next_state = READ3;
        end
        
        READ3: begin
            counter_reset = 1;
            counter_reset_val = (7-2);
            
            dout_shift = 1;

            mem_en = 1;
            
            if (cs_n)
                next_state = DONE;
            else
                next_state = READ1;
        end        
        
        WRITE1: begin
            din_shift = 1;

            if (cs_n)
                next_state = DONE;
            else if (counter_done)
                next_state = WRITE2;
        end
        
        WRITE2: begin
            counter_reset = 1;
            counter_reset_val = (7-2);
            
            din_shift = 1;

            if (cs_n)
                next_state = DONE;
            else
                next_state = WRITE3;
        end
        
        WRITE3: begin          
            din_shift = 1;
            
            addr_incr = 1;

            mem_en = 1;
            mem_wr = 1;

            if (cs_n)
                next_state = DONE;
            else
                next_state = WRITE1;
        end
        
        DONE: begin
            counter_reset = 1;
            counter_reset_val = (2-2);
            if (!cs_n)
                next_state = ERR;
            else
                next_state = DELAY;
        end
        
        DELAY: begin
            if (!cs_n)
                next_state = ERR;
            else if (counter_done)
                next_state = IDLE;
        end
        
        ERR: begin
            if (cs_n)
                next_state = DONE;
        end

    endcase
end


// state register
always_ff @(posedge clk) begin
    if (rst)
        state <= IDLE;
    else if (en)
        state <= next_state;
end

reg counter_done;
reg [4:0]counter;
always_ff @(posedge clk) begin
    if (counter_reset)
        { counter_done, counter } <= { 1'b0, counter_reset_val };
    else if (en)
        { counter_done, counter } <= counter - 1;
end

reg [7:0]din;
always_ff @(posedge clk) begin
    if (en && din_shift)
        din <= { din, mosi };
end

reg [23:0]addr;
always_ff @(posedge clk) begin
    if (en && addr_incr)
        addr <= addr + 1;
    else if (en) begin
        if (addr_shift)
            addr[23:1] <= { addr[23:1], mosi };
        if (addr_load_lsb)
            addr[0] <= mosi;
    end
end

reg [7:0]dout;
always_ff @(posedge clk2) begin
    if (dout_load)
        dout <= mem_out;
    else if (en2 && dout_shift)
        dout <= { dout, 1'b0 };
end

wire [15:0]mem_addr = { addr[23:1], addr_early ? mosi : addr[0] };

reg [7:0]mem[64*1024];
reg [7:0]mem_out;
always_ff @(posedge clk) begin
    if (mem_en) begin
        if (mem_wr)
            mem[mem_addr] <= din;
        mem_out <= mem[mem_addr];
    end
end

assign miso = dout[7];

endmodule
`resetall
