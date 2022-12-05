// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */
`define USE_LA  1
`define USE_IO  1
module macro_golden #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vdd,	// User area 1 1.8V supply
    inout vss,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [63:0] la_data_in,
    output [63:0] la_data_out,
    input  [63:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq,
    input io_active
);

reg [3:0] A0, B0, A1, B1;			//Inputs
	reg [1:0] ALU_Sel1, ALU_Sel2;			//Select Signals
	wire [3:0] ALU_Out1,ALU_Out2; 			// ALU 4-bit Output
	wire CarryOut1,CarryOut2; 			// Carry Out Flag
	wire [3:0] x;					//Compares ALU outputs
	wire y;						//Compares Carry Outputs
	wire clk;
	wire [31:0] la1_data_out;
	assign la1_data_out = la_data_out[63:32];
	wire [31:0]                 buf_la1_data_out;		//Tri-stated
	wire [`MPRJ_IO_PADS-1:0]    buf_io_out;			//Tri-stated
	wire [`MPRJ_IO_PADS-1:0]    buf_io_oeb;			//Tri-stated
   	assign io_oeb = {`MPRJ_IO_PADS{1'b0}};

 `ifdef FORMAL
	 `ifdef USE_LA
	 assign la1_data_out = io_active ? buf_la1_data_out  : 32'b0;	// formal verification
 	 `endif
	 `ifdef USE_IO
	 assign io_oeb       = io_active ? buf_io_oeb       : {`MPRJ_IO_PADS{1'b0}}; 	//If active, the outputs are enabled at io_oeb
	 assign io_out       = io_active ? buf_io_out       : {`MPRJ_IO_PADS{1'b0}};	//If active, the outputs are passed to io_out
         `endif
	 `include "properties.v"			//Checks for the tri-state buffer

 `else
	 `ifdef USE_LA
	 assign la1_data_out = io_active ? buf_la1_data_out  : 32'bz;
         `endif
	 `ifdef USE_IO
         assign io_oeb       = io_active ? buf_io_oeb       : {`MPRJ_IO_PADS{1'b0}};
	 assign io_out       = io_active ? buf_io_out       : {`MPRJ_IO_PADS{1'b0}};
 	 `endif
	 //$display("outputs and active is",io_out,active);
 `endif

  assign buf_io_oeb = {`MPRJ_IO_PADS{1'b0}}; //enabled

 //ALU_XOR instantiated

 alu_xor_4 u_alu_xor_4(
`ifdef USE_POWER_PINS
 .vdd(vdd),
 .vss(vss),
`endif
	.clk(wb_clk_i),
	.A0(io_in[21:18]),
	.B0(io_in[25:22]),
	.A1(io_in[29:26]),
	.B1(io_in[33:30]),
	.ALU_Sel1(io_in[35:34]),
	.ALU_Sel2(io_in[37:36]),
	.ALU_Out1(buf_io_out[17:14]),
	.ALU_Out2(buf_io_out[13:10]),
	.CarryOut1(buf_io_out[5]),
	.CarryOut2(buf_io_out[4]),
	.x(buf_io_out[9:6]),
	.y(buf_io_out[0])
);
 endmodule	// user_project_wrapper

 `default_nettype wire
