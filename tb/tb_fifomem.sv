//steps for verification for phase 1: 1. skeleton and DUT instantiation. 2. clock generation. 3. stimulus. 4. self checking. 5. waveform dumping. 6. simulation run and check results.

module tb_fifomem; 
  logic wclk, wclken; 
  logic [3:0] waddr, raddr;
  logic [7:0] wdata;
  logic [7:0] rdata;

  // named connection over positional connection.
  fifomem #(.W(8), .N(4)) dut (
    .wclk(wclk),
    .wclken(wclken),
    .waddr(waddr),
    .wdata(wdata),
    .raddr(raddr),
    .rdata(rdata)
  );

// clock generation
initial forever #5 wclk = ~wclk;
 





