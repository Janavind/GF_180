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
 * user_project_wrapper
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user project.
 *
 * An example user project is provided in this wrapper.  The
 * example should be removed and replaced with the actual
 * user project.
 *
 *-------------------------------------------------------------
 */

module user_project_wrapper #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vdd,		// User area 5.0V supply
    inout vss,		// User area ground
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

    // Independent clock (on independent integer divider)
    input   user_clock2,

    // User maskable interrupt signals
    output [2:0] user_irq
);

/*--------------------------------------*/
/* User project is instantiated  here   */
/*--------------------------------------*/

//The active signals are assigned to the first bank of Logic Analyzer
	 wire [31: 0] active;
	 assign active = la_data_in[31:0];

	// split remaining 96 logic analizer wires into 3 chunks
	 wire [31: 0] la1_data_in, la1_data_out, la1_oenb;
	 assign la1_data_in = la_data_in[63:32];
	 assign la1_data_out = la_data_out[63:32];
	 assign la1_oenb = la_oenb[63:32];

macro_golden u_macro_golden (

		`ifdef USE_POWER_PINS
			.vdd(vdd),  // User area 1 digital ground
			.vss(vss),  // User area 2 digital ground
		`endif
			.wb_rst_i(wb_rst_i),
			.wbs_stb_i(wbs_stb_i),
			.wbs_cyc_i(wbs_cyc_i),
			.wbs_we_i(wbs_we_i),
			.wbs_sel_i(wbs_sel_i),
			.wbs_dat_i(wbs_dat_i),
			.wbs_adr_i(wbs_adr_i),
			.wbs_ack_o(wbs_ack_o),
			.wbs_dat_o(wbs_dat_o),
			.la_data_in(la_data_in),
			.la_data_out(la_data_out),
			.la_oenb(la_oenb),
			.io_active(active[1]),
			.io_in(io_in[37:0]),
			.io_out(io_out[37:0]),
			.io_oeb(io_oeb[37:0])
			//.user_irq(user_irq),
			//.user_clock2(user_clock2),
			//.analog_io(analog_io)

		);


 macro_decap64 u_macro_decap64 (

                `ifdef USE_POWER_PINS
                        .vdd(vdd),  // User area 1 digital ground
                        .vss(vss),  // User area 2 digital ground
                `endif
                        .wb_rst_i(wb_rst_i),
                        .wbs_stb_i(wbs_stb_i),
                        .wbs_cyc_i(wbs_cyc_i),
                        .wbs_we_i(wbs_we_i),
                        .wbs_sel_i(wbs_sel_i),
                        .wbs_dat_i(wbs_dat_i),
                        .wbs_adr_i(wbs_adr_i),
                        .wbs_ack_o(wbs_ack_o),
                        .wbs_dat_o(wbs_dat_o),
                        .la_data_in(la_data_in),
                        .la_data_out(la_data_out),
                        .la_oenb(la_oenb),
                        .io_active(active[2]),
                        .io_in(io_in[37:0]),
                        .io_out(io_out[37:0]),
                        .io_oeb(io_oeb[37:0])
                        //.user_irq(user_irq),
                        //.user_clock2(user_clock2),
                        //.analog_io(analog_io)

                );
/*
macro_decap8 u_macro_decap8 (

                `ifdef USE_POWER_PINS
                        .vdd(vdd),  // User area 1 digital ground
                        .vss(vss),  // User area 2 digital ground
                `endif
                        .wb_rst_i(wb_rst_i),
                        .wbs_stb_i(wbs_stb_i),
                        .wbs_cyc_i(wbs_cyc_i),
                        .wbs_we_i(wbs_we_i),
                        .wbs_sel_i(wbs_sel_i),
                        .wbs_dat_i(wbs_dat_i),
                        .wbs_adr_i(wbs_adr_i),
                        .wbs_ack_o(wbs_ack_o),
                        .wbs_dat_o(wbs_dat_o),
                        .la_data_in(la_data_in),
                        .la_data_out(la_data_out),
                        .la_oenb(la_oenb),
                        .io_active(active[2]),
                        .io_in(io_in[37:0]),
                        .io_out(io_out[37:0]),
                        .io_oeb(io_oeb[37:0])
                        //.user_irq(user_irq),
                        //.user_clock2(user_clock2),
                        //.analog_io(analog_io)

                );

*/
macro_tap u_macro_tap (

                `ifdef USE_POWER_PINS
                        .vdd(vdd),  // User area 1 digital ground
                        .vss(vss),  // User area 2 digital ground
                `endif
                        .wb_rst_i(wb_rst_i),
                        .wbs_stb_i(wbs_stb_i),
                        .wbs_cyc_i(wbs_cyc_i),
                        .wbs_we_i(wbs_we_i),
                        .wbs_sel_i(wbs_sel_i),
                        .wbs_dat_i(wbs_dat_i),
                        .wbs_adr_i(wbs_adr_i),
                        .wbs_ack_o(wbs_ack_o),
                        .wbs_dat_o(wbs_dat_o),
                        .la_data_in(la_data_in),
                        .la_data_out(la_data_out),
                        .la_oenb(la_oenb),
                        .io_active(active[3]),
                        .io_in(io_in[37:0]),
                        .io_out(io_out[37:0]),
                        .io_oeb(io_oeb[37:0])
                        //.user_irq(user_irq),
                        //.user_clock2(user_clock2),
                        //.analog_io(analog_io)

                );

                 endmodule      // user_project_wrapper 
		 
		 
`default_nettype wire
