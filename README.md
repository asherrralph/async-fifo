# Async FIFO

An asynchronous (dual-clock) FIFO in SystemVerilog, built from the ground up: memory array → pointer/full/empty logic → Gray-code dual-flop CDC synchronization → constrained-random verification. Written as a deep-dive into clock-domain-crossing design, not just to get a FIFO working.

**Status: early / in progress.** This README tracks exactly what's built vs. planned — see [Status](#status) below.

## Why this project

Getting data safely across two independent, unrelated clock domains is one of the core hard problems in digital design — get it wrong and you get metastability-induced data corruption that won't show up until it's in silicon. The async FIFO is the canonical structure for solving this, and building one from scratch (rather than instantiating a vendor IP core) forces working through:

- Why binary pointer comparison breaks across clock domains, and why Gray code fixes it
- How many synchronizer flop stages are actually needed and why
- How to derive full/empty logic correctly from synchronized Gray-coded pointers
- How to verify a design where "correct" depends on relative clock timing, not just data values

## Status

| Component | State |
|---|---|
| `rtl/fifomem.sv` — dual-port memory array (sync write / comb read) | ✅ Implemented |
| `tb/tb_fifomem.sv` — memory testbench (DUT hookup, clock gen) | 🚧 In progress (stimulus, self-checking, waveform dump still TODO) |
| `rtl/wptr_full.sv` — Gray-code write pointer + full detection | ⬜ Planned |
| `rtl/rptr_empty.sv` — Gray-code read pointer + empty detection | ⬜ Planned |
| `rtl/sync_w2r.sv`, `rtl/sync_r2w.sv` — dual-flop pointer synchronizers | ⬜ Planned |
| `rtl/async_fifo.sv` — top-level integration | ⬜ Planned |
| `tb/tb_async_fifo.sv` + scoreboard — directed → constrained-random + coverage | ⬜ Planned |
| SVA protocol/CDC assertions | ⬜ Planned |
| `rtl/axis_fifo_wrapper.sv` — AXI4-Stream wrapper (stretch goal) | ⬜ Planned |
| FPGA synthesis + timing/utilization analysis (stretch goal) | ⬜ Planned |

Files present in the repo with no ✅ above are scaffolding — the module/testbench shell exists (ports declared) but has no logic yet. Nothing here is claimed as done until it's implemented *and* passing its own testbench.

## Architecture (target)

```
        write domain                          read domain
      (wclk, wrst_n)                         (rclk, rrst_n)
   ┌───────────────────┐                  ┌───────────────────┐
   │   wptr_full.sv     │                  │   rptr_empty.sv    │
   │  (Gray write ptr,  │◄──sync_r2w.sv────┤  (Gray read ptr,   │
   │   full detect)     │   (2-flop sync)  │   empty detect)    │
   └─────────┬──────────┘                  └──────────┬─────────┘
             │ waddr                sync_w2r.sv        │ raddr
             │                     (2-flop sync)        │
             ▼                                          ▼
        ┌────────────────────────────────────────────────────┐
        │                   fifomem.sv                        │
        │        (dual-port RAM: sync write, comb read)        │
        └────────────────────────────────────────────────────┘
```

Pointers cross clock domains as Gray code through 2-flop synchronizers (the standard mitigation for metastability on multi-bit CDC signals) — never as raw binary, and never combined into a single synchronizer.

## Repo layout

```
rtl/    synthesizable design modules
tb/     testbenches (one per unit, plus scoreboard for the full FIFO)
sim/    simulation Makefile / xsim scripts
docs/   design-notes / blog-style writeups per concept (CDC, Gray code, verification)
scripts/ lint / helper scripts
```

## Getting started

Simulation targets Xilinx Vivado's `xsim`. The sim flow (`sim/Makefile`) is not wired up yet — until then, modules can be elaborated/run directly from the Vivado GUI or `xvlog`/`xelab`/`xsim` on the command line, e.g.:

```sh
xvlog rtl/fifomem.sv tb/tb_fifomem.sv
xelab tb_fifomem -s tb_fifomem_sim
xsim tb_fifomem_sim -R
```

## Roadmap

1. ~~`fifomem.sv` — memory array~~ ✅
2. `tb_fifomem.sv` — self-checking unit testbench (in progress)
3. Write/read pointer + full/empty logic (`wptr_full.sv`, `rptr_empty.sv`)
4. Dual-flop Gray-code synchronizers (`sync_w2r.sv`, `sync_r2w.sv`)
5. Top-level integration (`async_fifo.sv`) + directed testbench
6. Constrained-random stimulus + functional coverage
7. SVA assertions for protocol and CDC correctness
8. CDC stress testing across clock frequency ratios and reset scenarios
9. Documentation: block diagrams, waveform screenshots, design-decision writeups
10. Stretch: AXI4-Stream wrapper, FPGA synthesis with timing/utilization report

## About

Built by [Asher Ralph](https://github.com/asherrralph), EE student at UIUC, as a self-directed deep dive into digital design/verification ahead of FPGA/ASIC RTL and DV internship applications. Design notes and concept writeups (metastability, Gray code, verification methodology) are being written up in `docs/blog/` alongside the RTL.
