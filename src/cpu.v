`include decode.v

module cpu (
    input wire clk,
    input wire reset,

    // read memory
    output wire [31:0] read_address,
    input reg [31:0] read_data,
    input reg read_bussy,

    // write memory
    output wire [31:0] write_address,
    output wire [31:0] write_data,
    output wire write_enable,
    input reg write_bussy
);

  reg [31:0] pc;
  reg [31:0] next_pc;
  reg [31:0] jump;
  reg [1:0] state;
  always_ff @(posedge clk) begin
    if (reset) begin
      pc <= 32'b0;
      state <= FETCH;
      for (int i = 0; i < 32; i++) begin
        registers[i] <= 32'b0;
      end
    end else begin
      case (state)
        FETCH: begin
          state <= WAIT_FETCH;
          pc <= next_pc;
          // setpc ? jump : pc + 4;
        end
        WAIT_FETCH: begin
          state <= read_bussy ? WAIT_FETCH : EXEC;
          machine_code <= read_data;
        end
        EXEC: begin
          case (opcode)
            OPCODE_STORE, OPCODE_LOAD: state <= WAIT_DATA;
            default: state <= FETCH;
          endcase
        end
        WAIT_DATA: state <= (read_bussy | write_bussy) ? WAIT_DATA : FETCH;
        default:   state <= FETCH;
      endcase
    end
  end

  // control unit
  reg [31:0] machine_code;  // input
  reg [5:0] alu_control;
  wire [31:0] immdiate;
  wire [6:0] opcode;
  wire [4:0] r1_address;
  wire [4:0] r2_address;
  wire [4:0] rd_address;
  wire [1:0] alu_out_goto;
  wire [1:0] register_write_from;
  wire write_mem_enable;
  wire write_reg_enable;
  wire set_pc;
  control_unit(
      /* input */
      .machine_code(machine_code),
      /* output */
      .alu_control(alu_control),
      .immdiate(immdiate),
      .opcode(opcode),
      .r1_address(r1_address),
      .r2_address(r2_address),
      .rd_address(rd_address),
      .alu_out_goto(alu_out_goto),
      .register_write_from(register_write_from),
      .write_mem_enable(write_mem_enable),
      .write_reg_enable(write_reg_enable),
      .set_pc(set_pc)
  );

  // register
  reg [31:0] registers[32];
  // ALU
  // Write logic
  reg [31:0] rs1;
  reg [31:0] rs2;
  reg [31:0] rd;
  always @(posedge clk) begin
    rs1 <= registers[r1_address];
    rs2 <= registers[r2_address];
    if (write_reg_enable) begin
      registers[rd_address] <= rd;
    end
  end

endmodule
