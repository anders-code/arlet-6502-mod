`timescale 1ns/1ps
`default_nettype none

module v6502_verilator(
    input  wire clk,
    input  wire rst,
    input  wire irq,
    input  wire nmi,
    output wire rdy,
    output wire [7:0]tc
);

reg [1:0]rdyr;
always_ff @(posedge clk) begin
    if (rst || rdyr == 2'b0)
        rdyr <= 2'b01;
    else
        rdyr <= { rdyr, 1'b0 };
end
assign rdy = rdyr[0];

wire [15:0]addr;
wire  [7:0]din;
wire  [7:0]dout;
wire       we;
cpu cpu_inst (
    .clk,
    .reset (rst),
    .AB    (addr),
    .DI    (din),
    .DO    (dout),
    .WE    (we),
    .IRQ   (irq),
    .NMI   (nmi),
    .RDY   (rdy)
);

reg [7:0]mem[64*1024];
reg [7:0]memout;
reg [7:0]memout2;
always_ff @(posedge clk) begin
    if (rdy) begin
        if (we)
            mem[addr] <= dout;
        memout <= mem[addr];
    end
    memout2 <= mem[addr];
end

assign din = rdy ? memout : 8'haa;

assign tc = mem[16'h0200];

initial begin
    string file = "";
    $value$plusargs("IMAGE_FILE=%s", file);
    $readmemh(file, mem);
end

endmodule
