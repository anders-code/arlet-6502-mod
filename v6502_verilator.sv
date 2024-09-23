`timescale 1ns/1ps
`default_nettype none

module v6502_verilator(
    input  wire clk,
    input  wire rst,
    input  wire irq,
    input  wire nmi
);

reg [1:0]rdy;
always_ff @(posedge clk) begin
    if (rst || rdy == 2'b0)
        rdy <= 2'b01;
    else
        rdy <= { rdy, 1'b0 };
end

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
    .RDY   (rdy[0])
);

reg [7:0]mem[64*1024];
reg [7:0]memout;
reg [7:0]memout2;
always_ff @(posedge clk) begin
    if (we)
        mem[addr] <= dout;
    if (rdy[0])
    memout <= mem[addr];
    memout2 <= mem[addr];
end

assign din = rdy[0] ? memout : 8'haa;

initial begin
    string file = "";
    $value$plusargs("IMAGE_FILE=%s", file);
    $readmemh(file, mem);
end

endmodule
