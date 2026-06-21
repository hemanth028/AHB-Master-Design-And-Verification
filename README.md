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

The project was developed following a **verification-driven development** methodology, where the testbench was built alongside the RTL to catch protocol violations and corner cases early.

---

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Protocol Signals](#protocol-signals)
- [Repository Structure](#repository-structure)
- [Verification Environment](#verification-environment)
- [Simulation Results](#simulation-results)
- [Applications](#applications)
- [Future Improvements](#future-improvements)
- [Skills Demonstrated](#skills-demonstrated)

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
│                  AHB Master Top                      │
│                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────┐  │
│  │  Master FSM  │  │ Address Gen  │  │  Burst   │  │
│  │              │◄─┤     Unit     │◄─┤Controller│  │
│  │ IDLE→NONSEQ  │  │              │  │          │  │
│  │ →SEQ→BUSY    │  │ Aligned Addr │  │ Beat Cnt │  │
│  │ →ERROR       │  │ INCR / WRAP  │  │ Compl.   │  │
│  └──────┬───────┘  └──────────────┘  └──────────┘  │
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

## Repository Structure

```
amba-ahb-master/
│
├── rtl/                          # Synthesizable RTL source files
│   ├── ahb_master_top.v          # Top-level master wrapper
│   ├── ahb_master_fsm.v          # AHB Master FSM (IDLE/NONSEQ/SEQ/BUSY/ERROR)
│   ├── ahb_address_gen.v         # Address Generation Unit (aligned, INCR, WRAP)
│   ├── ahb_burst_ctrl.v          # Burst Controller (beat counting, completion)
│   └── ahb_data_path.v           # Data path (write pipeline, read capture)
│
├── tb/                           # Simulation testbench files
│   ├── ahb_master_tb.sv          # Top-level testbench
│   ├── ahb_bfm.sv                # Bus Functional Model (AHB slave BFM)
│   └── ahb_tb_pkg.sv             # Package: parameters, types, utilities
│
├── verification/                 # Verification environment components
│   ├── ahb_transaction.sv        # Transaction class (randomized stimulus object)
│   ├── ahb_generator.sv          # Generator (drives random/directed sequences)
│   ├── ahb_monitor.sv            # Monitor (observes bus and captures transactions)
│   ├── ahb_scoreboard.sv         # Scoreboard (functional checking, comparison)
│   └── ahb_env.sv                # Environment wrapper (connects all components)
│
└── docs/                         # Documentation and supporting material
    ├── architecture.md           # Detailed architecture notes
    ├── waveforms/                 # Annotated waveform screenshots
    └── ahb_protocol_notes.md     # Protocol reference and design notes
```

---

## Verification Environment

A custom **SystemVerilog** verification environment was built to functionally verify the AHB Master RTL. The environment follows a layered, component-based architecture with mailbox-based inter-component communication.

### Components

| Component           | Role                                                                         |
|---------------------|------------------------------------------------------------------------------|
| **Transaction**     | Object class representing a single AHB transfer with randomized fields       |
| **Generator**       | Produces directed and randomized transaction sequences; drives the mailbox   |
| **BFM (Bus Functional Model)** | Drives AHB slave-side signals; emulates a responsive AHB slave  |
| **Monitor**         | Passively observes bus signals; captures and packages observed transactions  |
| **Scoreboard**      | Compares expected vs. observed transactions; flags mismatches                |
| **Mailbox**         | SV mailbox channels connecting Generator → BFM and Monitor → Scoreboard     |

### Verification Coverage

| Test Scenario                    | Status  |
|----------------------------------|---------|
| Single write transaction         | ✅ Pass |
| Single read transaction          | ✅ Pass |
| INCR4 burst (write)              | ✅ Pass |
| INCR8 burst (read)               | ✅ Pass |
| INCR16 burst                     | ✅ Pass |
| WRAP4 burst                      | ✅ Pass |
| WRAP8 burst                      | ✅ Pass |
| WRAP16 burst                     | ✅ Pass |
| Burst completion detection       | ✅ Pass |
| Address sequencing (INCR)        | ✅ Pass |
| Address wrapping (WRAP boundary) | ✅ Pass |
| Write-data pipeline timing       | ✅ Pass |
| HREADY wait-state insertion      | ✅ Pass |
| HRESP ERROR handling             | ✅ Pass |

> Randomized stimulus was used alongside directed tests to improve scenario coverage. Protocol timing was validated using waveform analysis at each stage of development.

---

## Simulation Results

Simulation was performed using a SystemVerilog-compatible simulator. All test cases passed functional checking through the scoreboard.

**Highlights:**
- All burst types (INCR and WRAP, lengths 4/8/16) simulated and verified end-to-end.
- Write data pipeline confirmed to be exactly one cycle behind the address phase per AHB specification.
- Wrapping burst address generation verified to correctly roll over at computed wrap boundaries.
- Wait-state handling (HREADY de-assertion) correctly stalls address and data phases without corrupting transfer.
- HRESP ERROR response correctly triggers FSM transition to ERROR state and halts the transfer sequence.

> Waveform screenshots and annotated timing diagrams are available under `docs/waveforms/`.

---

## Applications

AHB Masters are fundamental IP blocks found in virtually every digital SoC and embedded system:

- **Microcontrollers** — CPU cores use AHB masters to access on-chip memory and peripherals over the internal bus fabric.
- **System-on-Chip (SoC) Design** — Multiple masters (CPU, DMA, accelerators) share the AHB bus; each requires a compliant AHB master interface.
- **RISC-V Based Systems** — Open-source RISC-V cores such as PicoRV32 and Ibex interface to AHB fabrics; this master can serve as an interfacing or reference block.
- **FPGA Prototyping Platforms** — Used to prototype SoC bus interactions on Xilinx/Intel FPGAs before tape-out.
- **Embedded Systems** — Arm Cortex-M series processors, widely used in embedded products, natively use AHB as their primary bus protocol.

---

## Future Improvements

The current implementation focuses on the master interface. Planned extensions include:

- [ ] **Multi-master arbitration** — Implement an AHB arbiter and integrate `HGRANT`/`HBUSREQ` handshaking for multi-master environments
- [ ] **AHB Interconnect / Bus Matrix** — Full crossbar supporting simultaneous master-slave transfers
- [ ] **AHB Subordinate (Slave) Implementation** — Pair the master with a configurable AHB slave for end-to-end closed-loop simulation
- [ ] **UVM-based Verification Environment** — Migrate the custom SV testbench to a full UVM methodology with agents, sequences, and sequencers
- [ ] **Functional Coverage** — Add SystemVerilog covergroups and coverpoints to measure verification completeness
- [ ] **Assertions (SVA)** — Bind SystemVerilog Assertions to the DUT for protocol-level formal checking
- [ ] **AHB-to-APB Bridge** — Extend the system with an AHB-to-APB bridge to interface low-speed peripherals

---

## Skills Demonstrated

This project was developed as part of a hands-on VLSI / Digital Design portfolio, demonstrating the following competencies:

| Skill Area                     | Details                                                                               |
|--------------------------------|---------------------------------------------------------------------------------------|
| **Verilog / SystemVerilog**    | RTL design in Verilog; verification environment in SystemVerilog                      |
| **AMBA AHB Protocol**          | Deep understanding of AHB transfer types, burst modes, handshaking, and timing        |
| **RTL Design**                 | Modular, parameterized design with clean FSM, datapath, and control separation        |
| **Verification Methodology**   | Custom layered SV testbench; transaction-level modeling; scoreboard-based checking    |
| **FPGA / SoC Design Concepts** | Target-aware design suitable for both FPGA prototyping and ASIC implementation flows  |
| **Digital Design Debugging**   | Waveform-based timing analysis; FSM state tracing; pipeline behavior validation       |

---

## License

This project is intended for educational and portfolio purposes.

---

*Designed and verified as part of an RTL / SoC design portfolio. Contributions, suggestions, and issue reports are welcome.*
