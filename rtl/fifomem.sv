# port list: [wclk, wclken, waddr[N-1:0], wdata[W-1:0] in, raddr[N-1:0], rdata[W-1:0]]
# wclk: write clock. we need this in order to tell which clock edge to write data into the FIFO memory.
# wclken: write clock enable. we need this in order to tell WHEN to write on a certain clock edge. 
# waddr: write address. we need this in order to tell WHERE to write data into the FIFO memory.
# wdata: write data. we need this in order to tell WHAT data to write into
# raddr: read address. we need this in order to tell WHERE to read data from the FIFO memory.
# rdata: read data. we need this in order to tell WHAT data to read from

module fifomem #(
    parameter W = 8, // width of the data
    parameter N = 4 // depth of the FIFO memory
)(
    input wire wclk,
    input wire wclken,
    input wire [N-1:0] waddr,
    input wire [W-1:0] wdata,
    input wire [N-1:0] raddr,
    output reg [W-1:0] rdata
);

    // declare the FIFO memory as a 2D array
    reg [W-1:0] fifo_mem [0:(1<<N)-1];

    // write operation
    always @(posedge wclk) begin
        if (wclken) begin
            fifo_mem[waddr] <= wdata;
        end
    end

    // read operation
    always_comb begin
        rdata = fifo_mem[raddr];
    end
endmodule