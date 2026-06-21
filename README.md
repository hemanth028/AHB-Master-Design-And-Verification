# AMBA AHB Master Controller — Verilog HDL

![Language](https://img.shields.io/badge/Language-Verilog%20%2F%20SystemVerilog-blue?style=flat-square)
![Protocol](https://img.shields.io/badge/Protocol-AMBA%20AHB-orange?style=flat-square)
![Status](https://img.shields.io/badge/Simulation-Passing-brightgreen?style=flat-square)
![Verification](https://img.shields.io/badge/Verification-Custom%20SV%20Testbench-purple?style=flat-square)
![Domain](https://img.shields.io/badge/Domain-RTL%20Design%20%7C%20SoC%20%7C%20FPGA-teal?style=flat-square)

---

## Overview

This project presents a fully functional, configurable **AMBA AHB (Advanced High-performance Bus) Master Controller** designed in **Verilog HDL** and verified using a custom **SystemVerilog**-based verification environment.

The design targets SoC and FPGA prototyping use cases where a compliant AHB master is required to initiate and manage data transfers over the AHB bus. The implementation follows AMBA AHB protocol concepts, supporting both read and write operations with single and burst transfer modes — including incrementing and wrapping burst types.

The project was developed following a **verification-driven development** methodology, where the testbench was built alongside the RTL to catch protocol violations and corner cases.

---

## Features

### AHB Master FSM
The master is driven by a finite state machine that manages the full AHB transfer lifecycle:

| State     | Description                                                   |
|-----------|---------------------------------------------------------------|
| `IDLE`    | Bus is inactive; master holds HTRANS = IDLE                   |
| `NONSEQ`  | First beat of a burst or a single transfer                    |
| `SEQ`     | Subsequent beats in a burst transfer                          |
| `BUSY`    | Master temporarily unable to transfer; bus held               |
| `ERROR`   | HRESP error detected; transfer aborted                        |

### Address Generation Unit
- Aligned address generation based on transfer size (`HSIZE`)
- **Incrementing burst** address generation (INCR4 / INCR8 / INCR16)
- **Wrapping burst** address generation (WRAP4 / WRAP8 / WRAP16) with correct wrap boundary calculation

### Burst Controller
Manages burst sequencing and completion detection with beat counting for all supported burst types:

| Burst Type | Beats | Address Mode |
|------------|-------|--------------|
| `SINGLE`   | 1     | —            |
| `INCR4`    | 4     | Incrementing |
| `INCR8`    | 8     | Incrementing |
| `INCR16`   | 16    | Incrementing |
| `WRAP4`    | 4     | Wrapping     |
| `WRAP8`    | 8     | Wrapping     |
| `WRAP16`   | 16    | Wrapping     |

### Data Path
- **Write data pipelining**: HWDATA is registered one cycle after address phase, consistent with AHB protocol timing
- **Read data capture**: HRDATA sampled on the rising edge of HCLK when HREADY is asserted

---

## Architecture

The design is split into three decoupled, modular RTL blocks coordinated by a top-level master wrapper:

```
┌─────────────────────────────────────────────────────┐
│                  AHB Master Top                     │
│                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────┐   │
│  │  Master FSM  │  │ Address Gen  │  │  Burst   │   │
│  │              │◄─┤     Unit     │◄─┤Controller│   │
│  │ IDLE→NONSEQ  │  │              │  │          │   │
│  │ →SEQ→BUSY    │  │ Aligned Addr │  │ Beat Cnt │   │
│  │ →ERROR       │  │ INCR / WRAP  │  │ Compl.   │   │
│  └──────┬───────┘  └──────────────┘  └──────────┘   │
│         │                                           │
│  ┌──────▼───────────────────────────────────────┐   │
│  │               Data Path                      │   │
│  │   Write Pipeline (1-cycle delay)             │   │
│  │   Read Capture (HREADY gated)                │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
              │                     ▲
              ▼                     │
           AHB Bus / Slave (DUT / BFM)
```

**Key design decisions:**
- The FSM, Address Generator, and Burst Controller are deliberately kept as separate modules to allow independent reuse, testing, and future extension.
- Write data is pipelined by one clock cycle to match the AHB address/data phase separation defined by the protocol.
- Burst parameters are fully parameterized, making it straightforward to extend or restrict supported burst types.

---

## Protocol Signals

| Signal    | Direction | Width  | Description                                    |
|-----------|-----------|--------|------------------------------------------------|
| `HCLK`    | Input     | 1      | AHB system clock                               |
| `HRESETn` | Input     | 1      | Active-low synchronous reset                   |
| `HADDR`   | Output    | 32     | Transfer address                               |
| `HWDATA`  | Output    | 32     | Write data (pipelined one cycle after address) |
| `HRDATA`  | Input     | 32     | Read data from slave                           |
| `HTRANS`  | Output    | 2      | Transfer type (IDLE / BUSY / NONSEQ / SEQ)     |
| `HWRITE`  | Output    | 1      | Transfer direction (1 = write, 0 = read)       |
| `HREADY`  | Input     | 1      | Slave ready signal                             |
| `HRESP`   | Input     | 1      | Slave response (OKAY / ERROR)                  |
| `HBURST`  | Output    | 3      | Burst type                                     |
| `HSIZE`   | Output    | 3      | Transfer size (byte / halfword / word)         |
| `HGRANT`  | Input     | 1      | Bus grant from arbiter                         |

---
### Verification Coverage

| Test Scenario                    | Status  |
|----------------------------------|---------|
| Single write transaction         | ✅ Pass |
| Single read transaction          | ✅ Pass |
| INCR4 burst                      | ✅ Pass |
| INCR8 burst                      | ✅ Pass |
| INCR16 burst                     | ✅ Pass |
| WRAP4 burst                      | ✅ Pass |
| WRAP8 burst                      | ✅ Pass |
| WRAP16 burst                     | ✅ Pass |
| Burst completion detection       | ✅ Pass |
| Address sequencing (INCR)        | ✅ Pass |
| Address wrapping (WRAP boundary) | ✅ Pass |
| Write-data pipeline timing       | ✅ Pass |
| HREADY wait-state insertion      | ✅ Pass |(with fixed values  of hready in bfm)
| HRESP ERROR handling             | ✅ Pass |


