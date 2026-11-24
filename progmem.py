import sys, struct

with open('main.bin', 'rb') as f:
    data = f.read()

words = [struct.unpack("<I", data[i:i+4])[0] for i in range(0, len(data), 4)]
cases = "\n".join(f"        11'h{idx:03X}: mem_data <= 32'h{val:08X};" for idx, val in enumerate(words))

verilog = f"""module progmem (
    input wire clk,
    input wire rstn,
    input wire valid,
    output wire ready,
    input wire [31:0] addr,
    output wire [31:0] rdata
);
  wire [10:0] mem_addr = addr[12:2];
  reg [31:0] mem_data;
  reg o_ready;

  always @(posedge clk) begin
    case (mem_addr)
{cases}
      default: mem_data <= 32'h00000000;
    endcase
  end

  always @(posedge clk or negedge rstn) begin
    if (!rstn) o_ready <= 1'b0;
    else o_ready <= valid && addr[20];
  end

  assign ready = o_ready;
  assign rdata = mem_data;
endmodule
"""

with open('progmem.v', 'w') as f:
    f.write(verilog)
print(f"ROM generada: {len(words)} palabras")
