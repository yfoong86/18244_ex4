/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.

  logic [1:0] data_in, range;
  logic go, finish, error;

  assign uio_oe[3:0] = 4'd0;
  assign uio_oe[6:4] = 3'b111;
  assign uio_oe[7] = 1'b1;

  assign go = uio_in[0];
  assign finish = uio_in[1];
  assign data_in = uio_in[3:2];

  assign uio_out[3:0] = 4'd0; 
  assign uio_out[5:4] = range;
  assign uio_out[6] = error;
  assign uio_out[7] = 1'b0;

  assign uo_out = 8'd50;
 
  RangeFinder #(2) rf0(.clock(clk), .reset(~rst_n), 
                       .data_in, .go, .finish, .range, .error);

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in, range, error, uio_in[7:4], 1'b0};

endmodule

`default_nettype none

module RangeFinder
   #(parameter WIDTH=16)
    (input  logic [WIDTH-1:0] data_in,
     input  logic             clock, reset,
     input  logic             go, finish,
     output logic [WIDTH-1:0] range,
     output logic             error);

   enum logic [1:0] {IDLE, RECEIVING, DONE, ERROR} currState, nextState;

   logic [WIDTH-1:0] max, min, reg_max, reg_min;
   logic [WIDTH-1:0] final_max, final_min; 

   // FSM next currState logic
   always_comb begin
      reg_min = min;
      reg_max = max;
      error = 1'b0;
      case (currState)
         IDLE: begin
            if (go & finish) begin
               nextState = ERROR;
            end
            else if (go) begin
               nextState = RECEIVING;
               reg_max = data_in;
               reg_min = data_in;
            end
            else if (finish) begin
               nextState = ERROR;
            end
            else nextState = IDLE;
         end
         RECEIVING: begin
            if (go & finish)       nextState = ERROR;
            else if (finish) begin
               nextState = DONE;
               if (data_in > max) reg_max = data_in;
               if (data_in < min) reg_min = data_in;
            end
            else begin
               nextState = RECEIVING;
               if (data_in > max) reg_max = data_in;
               if (data_in < min) reg_min = data_in;
            end
         end
         DONE: begin
            if (go & finish)       nextState = ERROR;
            else if (go) begin
               nextState = RECEIVING;
               reg_max = data_in;
               reg_min = data_in;
            end
            else if (finish)       nextState = ERROR;
            else nextState = DONE;
         end
         ERROR: begin
            error = 1'b1;
            if (go & ~finish) begin
               nextState = RECEIVING;
               reg_max = data_in;
               reg_min = data_in;
            end
            else                   nextState = ERROR;
         end
         default: nextState = IDLE;
      endcase
   end

   always_ff @(posedge clock, posedge reset) begin
      if (reset) currState <= IDLE;
      else       currState <= nextState;
   end

   // Max/min registers
   always_ff @(posedge clock, posedge reset) begin
      if (reset) begin
         max <= 'd0;
         min <= 'd0;
      end
      else begin
         max <= reg_max;
         min <= reg_min;
      end
   end

   always_comb begin
      final_max = (data_in > max) ? data_in : max;
      final_min = (data_in < min) ? data_in : min;
      range = final_max - final_min;
   end

endmodule: RangeFinder