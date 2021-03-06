/*
    MUX_MEM seleciona a saída entre:
    - PC
    - ALUout
    - Reg A
    - Reg B
    - 253
    - 254
    - 255

*/

module mux_Mem(
    input wire [2:0] selector,
    input wire [31:0] data_0,
    input wire [31:0] data_1,
    input wire [31:0] reg_A,
    input wire [31:0] reg_B,
    output reg [31:0] data_out
);


    always @(*) begin
        case(selector)
            3'b000 : data_out = data_0;
            3'b001 : data_out = data_1;
            3'b010 : data_out = reg_A;
            3'b011 : data_out = reg_B;
            3'b100 : data_out = 32'd253;
            3'b101 : data_out = 32'd254;
            3'b110 : data_out = 32'd255;
        endcase 
    end
    
    
endmodule
