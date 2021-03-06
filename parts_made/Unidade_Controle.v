module Unidade_Controle(
    input wire                  clk,
    input wire                  reset,
// Flags
    input wire                  Of,
    input wire                  Ng,
    input wire                  Zr,
    input wire                  Eq,
    input wire                  Gt,
    input wire                  Lt,
// Meaningful Part of the Instruction
    input wire [5:0]    OPCODE,
    input wire [15:0]   IMEDIATO,
// Controllers with 1 bit
    output reg       PCWrite,
    output reg [2:0] IorD,
    output reg       MEMWrite,
    output reg       IRWrite,
    output reg [1:0] RegDst,
    output reg [2:0] MemtoReg,
    output reg       RegWrite,
    output reg       AWrite,
    output reg       BWrite,
    output reg [1:0] AluSrcA,
    output reg [2:0] AluSrcB,
    output reg [2:0] ULA_c,
    output reg       ALU_w,
    output reg [2:0] PCSource,
    output reg EPCWrite,
    output reg HiSel,
    output reg HiWrite,
    output reg LoSel,
    output reg LoWrite,
    output reg MDRWrite,
    output reg [1:0] LControl,
    output reg ShiftSrc,
    output reg [1:0] AmountCrtl,
    output reg [2:0] ShiftCtrl,
    output reg ExtdCtrl,
    output reg [1:0] SControl
    // output reg reset_out
);
    
    //reg variáveis internas
    reg [4:0] CONTADOR;
    reg [5:0] ESTADO;

    //Principais ESTADO de Máquina
    parameter fetch             = 6'b000001;
    parameter decoder           = 6'b000010;
    parameter Overflow          = 6'b000011;
    parameter OPCode404         = 6'b000100;
    parameter Div0              = 6'b000101;
    //-------------- Formato R ----------------//
    parameter ESTADO_ADD         = 6'b000110;  // ok
    parameter ESTADO_AND         = 6'b000111;  // ok
    parameter ESTADO_DIV         = 6'b001000;  // implementar bloco
    parameter ESTADO_MULT        = 6'b001001;  // implementar bloco
    parameter ESTADO_JR          = 6'b001010;  // ok
    parameter ESTADO_MFHI        = 6'b001011;  // implementar
    parameter ESTADO_MFLO        = 6'b001100;  // implementar
    parameter ESTADO_SLL         = 6'b001101;  // ok
    parameter ESTADO_SLLV        = 6'b001110;  // ok
    parameter ESTADO_SLT         = 6'b001111;  // ok 
    parameter ESTADO_SRA         = 6'b010000;  // ok
    parameter ESTADO_SRAV        = 6'b010001;  // ok
    parameter ESTADO_SRL         = 6'b010010;  // ok
    parameter ESTADO_SUB         = 6'b010011;  // ok
    parameter ESTADO_BREAK       = 6'b010100;  // ok
    parameter ESTADO_RTE         = 6'b010101;  // ok 
    parameter ESTADO_ADDM        = 6'b010110;  // ok 
    //----------------------------------------//

    //--------------- Formato I -------------------//
    parameter ESTADO_ADDI        =       6'b010111; // ok (ver o overflow)
    parameter ESTADO_ADDIU       =       6'b011000; // ok
    parameter ESTADO_BEQ         =       6'b011001; // ok
    parameter ESTADO_BNE         =       6'b011010; // ok
    parameter ESTADO_BLE         =       6'b011011; // ok
    parameter ESTADO_BGT         =       6'b011100; // ok
    parameter ESTADO_SLLM        =       6'b011101; // ok
    parameter ESTADO_LB          =       6'b011110; // ok
    parameter ESTADO_LH          =       6'b011111; // ok
    parameter ESTADO_LUI         =       6'b100000; // ok
    parameter ESTADO_LW          =       6'b100001; // ok
    parameter ESTADO_SB          =       6'b100010; // ok
    parameter ESTADO_SH          =       6'b100011; // ok
    parameter ESTADO_SLTI        =       6'b100100; // ok
    parameter ESTADO_SW          =       6'b100101; // ok
    parameter ESTADO_RESET       =       6'b111111; // ok
    //--------------------------------------------//

    // ----------------- formato J -----------------//
    parameter ESTADO_J           =       6'b100110; // ok
    parameter ESTADO_JAL         =       6'b100111; // ok
    // ---------------------------------------------//
    

    // ------ OPCODE DA INSTRUÇÃO R, DADA NA ESPECIFICAÇÃO 0x0----//
    parameter OPCODE_TYPE_R      =       6'b000000; // 0x0
    //------------------------------------------------------------//   
    // CAMPO FUNCT PARA AS DIFERENCIAÇÃO NAS INSTRUÇÕES (R's), DE ACORDO COM O VALOR HEXADECIMAL DADO NA ESPECIFICAÇÃO
    parameter FUNCT_ADD         =       6'b100000; // 0x20
    parameter FUNCT_AND         =       6'b100100; // 0x24
    parameter FUNCT_DIV         =       6'b011010; // 0x1a
    parameter FUNCT_MULT        =       6'b011000; // 0x18
    parameter FUNCT_JR          =       6'b001000; // 0x8
    parameter FUNCT_MFHI        =       6'b010000; // 0x10
    parameter FUNCT_MFLO        =       6'b010010; // 0x12
    parameter FUNCT_SLL         =       6'b000000; // 0x0
    parameter FUNCT_SLLV        =       6'b000100; // 0x4
    parameter FUNCT_SLT         =       6'b101010; // 0x2a
    parameter FUNCT_SRA         =       6'b000011; // 0x3
    parameter FUNCT_SRAV        =       6'b000111; // 0x7
    parameter FUNCT_SRL         =       6'b000010; // 0x2 
    parameter FUNCT_SUB         =       6'b100010; // 0x22
    parameter FUNCT_BREAK       =       6'b001101; // 0xd
    parameter FUNCT_RTE         =       6'b010011; // 0x13
    parameter FUNCT_ADDM        =       6'b000101; // 0x5
    //------------------------------------------------------------------------------------------------------------------
    
    // ---------- OPCODE DAS INSTRUÇÕES FORMATO I (DADO NA ESPECIFICAÇÃO)-----------------//
    parameter OPCODE_ADDI           =       6'b001000; // 0x8
    parameter OPCODE_ADDIU          =       6'b001001; // 0x9
    parameter OPCODE_BEQ            =       6'b000100; // 0x4
    parameter OPCODE_BNE            =       6'b000101; // 0x5
    parameter OPCODE_BLE            =       6'b000110; // 0x6
    parameter OPCODE_BGT            =       6'b000111; // 0x7
    parameter OPCODE_SLLM           =       6'b000001; // 0x1
    parameter OPCODE_LB             =       6'b100000; // 0x20
    parameter OPCODE_LH             =       6'b100001; // 0x21
    parameter OPCODE_LUI            =       6'b001111; // 0xf
    parameter OPCODE_LW             =       6'b100011; // 0x23
    parameter OPCODE_SB             =       6'b101000; // 0x28
    parameter OPCODE_SH             =       6'b101001; // 0x29
    parameter OPCODE_SLTI           =       6'b001010; // 0xa
    parameter OPCODE_SW             =       6'b101011; // 0x2b
    // ------------------------------------------------------------------------------------//

    // ----- OPCODE DAS INSTRUÇÕES FORMATO J (DADO NA ESPECIFICAÇÃO) ----------------//
    parameter OPCODE_J              =       6'b000010; // 0x2
    parameter OPCODE_JAL            =       6'b000011; // 0x3
    //----------------------------------------------------------------------------------//
    
    /*
        PCWrite = 1'b0;
        RegWrite = 1'b0;
        MEMWrite = 1'b0;
        IRWrite = 1'b0;
        AWrite = 1'b0;
        BWrite = 1'b0;
        ALU_w = 1'b0;
        EPCWrite = 1'b0;
        HiWrite = 1'b0;
        LoWrite = 1'b0;
        MDRWrite = 1'b0;
        LControl = 2'b00;
    
    */
        
    
    
    initial begin
        ESTADO = ESTADO_RESET;
    end


    always @(posedge clk) begin
        if (reset == 1'b1) begin
            // if (ESTADO != ESTADO_RESET) begin
                
                // up --------
                RegDst = 2'b01;      // *
                MemtoReg = 3'b111;     // *
                RegWrite = 1'b1;     // *
                //-------------
                PCWrite = 1'b0;
                MEMWrite = 1'b0;
                IRWrite = 1'b0;
                AWrite = 1'b0;
                BWrite = 1'b0;
                ALU_w = 1'b0;
                EPCWrite = 1'b0;
                HiWrite = 1'b0;
                LoWrite = 1'b0;
                MDRWrite = 1'b0;
                LControl = 2'b00;

                CONTADOR = 5'b00000;
                ESTADO = fetch;

        end else begin
            case (ESTADO)
                fetch: begin
                    if (CONTADOR == 5'b00000 || CONTADOR == 5'b00001 || CONTADOR == 5'b00010) begin
                        ESTADO = fetch;
                        
                        PCWrite = 1'b0;
                        IorD = 3'b000;   // <-
                        MEMWrite = 1'b0;  // <-
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        AluSrcA = 2'b00; // <-
                        AluSrcB = 3'b001;  // <-
                        ULA_c = 3'b001;   // <-
                        ALU_w = 1'b1;
                        PCSource = 3'b000;  // <-
                        MDRWrite = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = CONTADOR + 5'b00001;
                    end else begin
                        ESTADO = decoder;
                        
                        PCSource = 3'b000;  // <-
                        PCWrite = 1'b1;   // <-
                        MEMWrite = 1'b0;
                        IRWrite = 1'b1;   // <-
                        RegWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;
                        // 

                        CONTADOR = 5'b00000;
                    end
                end
                decoder: begin
                    if (CONTADOR == 5'b00000) begin
                        // Resetando todos os sinais:
                        PCWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        AWrite = 1'b0;  
                        BWrite = 1'b0;
                        AluSrcA = 2'b00;  // <-
                        AluSrcB = 3'b011; // <-
                        ExtdCtrl = 1'b0; // <-
                        ULA_c = 3'b001;   // <-
                        ALU_w = 1'b1; // <-
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;
                        // 

                        CONTADOR = CONTADOR + 5'b00001;
                    end else if (CONTADOR == 5'b00001) begin
                       
                        PCWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        AWrite = 1'b1;  // <-
                        BWrite = 1'b1; // <-
                        ALU_w = 1'b0; 
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;  
                        LControl = 2'b00;                      // 
                    
                        CONTADOR = 5'b00000;
                    
                        case (OPCODE)
                            OPCODE_TYPE_R: begin
                    
                                case(IMEDIATO[5:0]) // PEGA OS 6 BITS PARA IDENTIFICAR O CAMPO FUNCT DA INSTRUCT R

                                    FUNCT_ADD: begin
                                        ESTADO = ESTADO_ADD;
                                    end
                                    FUNCT_AND: begin
                                        ESTADO = ESTADO_AND;
                                    end
                                    FUNCT_DIV: begin
                                        ESTADO = ESTADO_DIV;
                                    end
                                    FUNCT_MULT: begin
                                        ESTADO = ESTADO_MULT;
                                    end

                                    FUNCT_JR: begin
                                        ESTADO = ESTADO_JR;
                                    end

                                    FUNCT_MFHI: begin
                                        ESTADO = ESTADO_MFHI;
                                    end

                                    FUNCT_MFLO: begin
                                        ESTADO = ESTADO_MFLO;
                                    end

                                    FUNCT_SLL: begin
                                        ESTADO = ESTADO_SLL;
                                    end
                                    
                                    FUNCT_SLLV: begin
                                        ESTADO = ESTADO_SLLV;
                                    end

                                    FUNCT_SLT: begin
                                        ESTADO = ESTADO_SLT;
                                    end

                                    FUNCT_SRA: begin
                                        ESTADO = ESTADO_SRA;
                                    end

                                    FUNCT_SRAV: begin
                                        ESTADO = ESTADO_SRAV;
                                    end

                                    FUNCT_SRL: begin
                                        ESTADO = ESTADO_SRL;
                                    end

                                    FUNCT_SUB: begin
                                        ESTADO = ESTADO_SUB;
                                    end

                                    FUNCT_BREAK: begin
                                        ESTADO = ESTADO_BREAK;
                                    end

                                    FUNCT_RTE: begin
                                        ESTADO = ESTADO_RTE;
                                    end

                                    FUNCT_ADDM: begin
                                        ESTADO = ESTADO_ADDM;
                                    end
                                    // RESET: begin
                                    //     ESTADO = ESTADO_RESET;
                                    // end
                                endcase
                            end
                            OPCODE_ADDI: begin
                                ESTADO = ESTADO_ADDI;
                            end

                            OPCODE_ADDIU: begin
                                ESTADO = ESTADO_ADDIU;
                            end

                            OPCODE_BEQ: begin
                                ESTADO = ESTADO_BEQ;
                            end

                            OPCODE_BNE: begin
                                ESTADO = ESTADO_BNE;
                            end

                            OPCODE_BLE: begin
                                ESTADO = ESTADO_BLE;
                            end

                            OPCODE_BGT: begin
                                ESTADO = ESTADO_BGT;
                            end

                            OPCODE_SLLM: begin
                                ESTADO = ESTADO_SLLM;
                            end

                            OPCODE_LB: begin
                                ESTADO = ESTADO_LB;
                            end

                            OPCODE_LH: begin
                                ESTADO = ESTADO_LH;
                            end

                            OPCODE_LUI: begin
                                ESTADO = ESTADO_LUI;
                            end

                            OPCODE_LW: begin
                                ESTADO = ESTADO_LW;
                            end

                            OPCODE_SB: begin
                                ESTADO = ESTADO_SB;
                            end

                            OPCODE_SH: begin
                                ESTADO = ESTADO_SH;
                            end

                            OPCODE_SLTI: begin
                                ESTADO = ESTADO_SLTI;
                            end

                            OPCODE_SW: begin
                                ESTADO = ESTADO_SW;
                            end

                            OPCODE_J: begin
                                ESTADO = ESTADO_J;
                            end

                            OPCODE_JAL: begin
                                ESTADO = ESTADO_JAL;
                            end
                            default : begin
                                ESTADO = OPCode404;
                            end
                        endcase
                    end
                end
                ESTADO_ADD: begin
                    if (CONTADOR == 5'b00000) begin
                        // Colocando Estado Futuro
                        ESTADO = ESTADO_ADD;
                        
                        PCWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        AluSrcA = 2'b01; // <-
                        AluSrcB = 3'b000; // <-
                        ULA_c = 3'b001; // <-
                        ALU_w = 1'b1;  // <-
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;
                        // 

                        CONTADOR = CONTADOR + 5'b00001;
                    end

                    //DOIS CICLOS PARA ESCREVER NO BANCO DE REGISTRADORES
                    else if (CONTADOR == 5'b00001) begin
                        // Colocando Estado Futuro
                        ESTADO = fetch;
                        PCWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        RegDst = 2'b11;   // <-
                        MemtoReg = 3'b000;  // <-
                        RegWrite = 1'b1;   // <-
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;
                        // 

                        CONTADOR = 5'b00000;
                    end
                end
                ESTADO_AND: begin
                    if(CONTADOR == 5'b000000)begin
                        AluSrcA = 2'b01; // <--
                        AluSrcB = 3'b000; //<-
                        ULA_c   = 3'b011; // <-
                        ALU_w = 1'b1; // <-

                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;
                        // 
                        
                        ESTADO = ESTADO_AND;
                        CONTADOR = CONTADOR + 5'b00001;

                    end else begin
                        ESTADO = fetch;
                        PCWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        RegDst = 2'b11;   // <-
                        MemtoReg = 3'b000;  // <-
                        RegWrite = 1'b1;   // <-
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;
                        // 
                        CONTADOR = 5'b00000;
                    end
                end
                ESTADO_ADDI: begin
                    if(CONTADOR == 5'b000000)begin
                        AluSrcA = 2'b01; // <--
                        ExtdCtrl = 1'b0; // <-
                        AluSrcB = 3'b010; //<-
                        ULA_c   = 3'b001; // <-
                        ALU_w = 1'b1; // <-


                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;
                        // 
                        
                        ESTADO = ESTADO_ADDI;
                        CONTADOR = CONTADOR + 5'b00001;

                    end else begin
                        if(Of == 1'b0) begin
                            ESTADO = fetch;
                            PCWrite = 1'b0;
                            MEMWrite = 1'b0;
                            IRWrite = 1'b0;
                            RegDst = 2'b00;   // <-
                            MemtoReg = 3'b000;  // <-
                            RegWrite = 1'b1;   // <-
                            AWrite = 1'b0;
                            BWrite = 1'b0;
                            ALU_w = 1'b0;
                            EPCWrite = 1'b0;
                            HiWrite = 1'b0;
                            LoWrite = 1'b0;
                            MDRWrite = 1'b0;
                            LControl = 2'b00;
            
                        // 
                        end else begin
                            ESTADO = Overflow;
                        end

                        CONTADOR = 5'b00000;
                    end
                end
                
                ESTADO_ADDIU: begin
                    if(CONTADOR == 5'b000000)begin
                        AluSrcA = 2'b01; // <--
                        ExtdCtrl = 1'b0; // <-
                        AluSrcB = 3'b010; //<-
                        ULA_c   = 3'b001; // <-
                        ALU_w = 1'b1; // <-

                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;
                        // 
                        
                        ESTADO = ESTADO_ADDIU;
                        CONTADOR = CONTADOR + 5'b00001;

                    end else begin
                    
                        ESTADO = fetch;
                        PCWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        RegDst = 2'b00;   // <-
                        MemtoReg = 3'b000;  // <-
                        RegWrite = 1'b1;   // <-
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = 5'b00000;
                    end
                end
                ESTADO_JR: begin
                    ESTADO = fetch;
                    AluSrcA = 2'b1; // <--
                    AluSrcB = 3'b000; //<-
                    ULA_c   = 3'b000; // <-
                    PCSource = 3'b000; // <-
                    PCWrite = 1'b1; // <-
                    RegWrite = 1'b0;
                    MEMWrite = 1'b0;
                    IRWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ALU_w = 1'b0;
                    EPCWrite = 1'b0;
                    HiWrite = 1'b0;
                    LoWrite = 1'b0;
                    MDRWrite = 1'b0;
                    LControl = 2'b00;                    
                    
                    CONTADOR = 5'b00000;
                end

                ESTADO_MFHI: begin
                    ESTADO = fetch;
                    PCWrite = 1'b0;
                    MEMWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegDst = 2'b11;   // <-
                    MemtoReg = 3'b010;  // <-
                    RegWrite = 1'b1;   // <-
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ALU_w = 1'b0;
                    EPCWrite = 1'b0;
                    HiWrite = 1'b0;
                    LoWrite = 1'b0;
                    MDRWrite = 1'b0;
                    LControl = 2'b00;
                    

                    CONTADOR = 5'b00000;
                end
                ESTADO_MFLO: begin
                    ESTADO = fetch;
                    PCWrite = 1'b0;
                    MEMWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegDst = 2'b11;   // <-
                    MemtoReg = 3'b011;  // <-
                    RegWrite = 1'b1;   // <-
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ALU_w = 1'b0;
                    EPCWrite = 1'b0;
                    HiWrite = 1'b0;
                    LoWrite = 1'b0;
                    MDRWrite = 1'b0;
                    
                    LControl = 2'b00;
                    CONTADOR = 5'b00000;
                end
                ESTADO_SUB: begin
                    if (CONTADOR == 5'b00000) begin
                        // Colocando Estado Futuro
                        ESTADO = ESTADO_SUB;
                        
                        PCWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        AluSrcA = 2'b01; // <-
                        AluSrcB = 3'b000; // <-
                        ULA_c = 3'b010; // <-  010 == subtracao
                        ALU_w = 1'b1;  // <-
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;
                        // 

                        CONTADOR = CONTADOR + 5'b00001;
                    end

                    //DOIS CICLOS PARA ESCREVER NO BANCO DE REGISTRADORES
                    else if (CONTADOR == 5'b00001) begin
                        // Colocando Estado Futuro
                        ESTADO = fetch;
                        PCWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        RegDst = 2'b11;   // <-
                        MemtoReg = 3'b000;  // <-
                        RegWrite = 1'b1;   // <-
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;
                        // 

                        CONTADOR = 5'b00000;
                    end
                end
                ESTADO_BEQ: begin // CHECAR OS SINAIS QUE LEVANTAM, PERGUNTAR AO MONITOR
                    if (CONTADOR == 5'b00000) begin
                        ESTADO = ESTADO_BEQ;
                        AluSrcA = 2'b01; // <--
                        AluSrcB = 3'b000; //<-
                        ULA_c   = 3'b111; // <-
                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;
                    
                        CONTADOR = CONTADOR  + 5'b00001;
                    end else if(CONTADOR == 5'b00001) begin
                        if(Eq == 1'b1) begin
                            PCSource = 3'b001; // <-
                            PCWrite = 1'b1; // <-
                        end

                        ESTADO = fetch;
                        CONTADOR = 5'b00000;
                    end
                end
                ESTADO_BNE: begin
                    if (CONTADOR == 5'b00000) begin
                        ESTADO = ESTADO_BNE;
                        AluSrcA = 2'b01; // <-
                        AluSrcB = 3'b000; //<-
                        ULA_c   = 3'b111; // <-
                        PCWrite = 1'b0; // <-
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;
                    
                        CONTADOR = CONTADOR  + 5'b00001;
                    end else if(CONTADOR == 5'b00001) begin
                        if(Eq == 1'b0) begin
                            PCSource = 3'b001; // <-
                            PCWrite = 1'b1; // <-
                        end

                        ESTADO = fetch;
                        CONTADOR = 5'b00000;
                    end
                end
                ESTADO_BLE: begin
                    if (CONTADOR == 5'b00000) begin
                        ESTADO = ESTADO_BLE;
                        AluSrcA = 2'b01; // <--
                        AluSrcB = 3'b000; //<-
                        ULA_c   = 3'b111; // <-
                        PCWrite = 1'b0; // <-
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;
                    
                        CONTADOR = CONTADOR  + 5'b00001;
                    end else if(CONTADOR == 5'b00001) begin
                        if(Eq == 1'b1 || Lt == 1'b1) begin
                            PCSource = 3'b001; // <-
                            PCWrite = 1'b1; // <-
                        end

                        ESTADO = fetch;
                        CONTADOR = 5'b00000;
                    end
                end
                ESTADO_BGT : begin
                    if (CONTADOR == 5'b00000) begin
                        ESTADO = ESTADO_BGT;
                        AluSrcA = 2'b01;      // <--
                        AluSrcB = 3'b000;     //<-
                        ULA_c   = 3'b111;    // <-
                        PCWrite = 1'b0;      // <-
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;
                    
                        CONTADOR = CONTADOR  + 5'b00001;
                    end else if(CONTADOR == 5'b00001) begin
                        if(Gt == 1'b1) begin
                            PCSource = 3'b001; // <-
                            PCWrite = 1'b1; // <-
                        end

                        ESTADO = fetch;
                        CONTADOR = 5'b00000;
                    end
                end
                ESTADO_J: begin   // CHECAR O SHIFT
                    if (CONTADOR == 5'b00000) begin
                        PCSource = 3'b010; // <-
                        PCWrite = 1'b1;      // <-
                        
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        ESTADO = fetch;
                        CONTADOR = 5'b00000;
                    end
                end
                ESTADO_JAL: begin   // OBS: P+4
                    if (CONTADOR == 5'b00000) begin
                        AluSrcA = 2'b00; // <-
                        AluSrcB = 3'b000; // <-
                        ULA_c = 3'b000; // <-
                        PCWrite = 1'b0; 
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b1; // <-
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;
                        
                        ESTADO = ESTADO_JAL;
                        CONTADOR = CONTADOR + 5'b00001;
                    end else begin
                        PCSource = 3'b010; // <-
                        PCWrite = 1'b1;      // <-
                        RegDst = 2'b10;   // <-
                        MemtoReg = 3'b000;  // <-
                        RegWrite = 1'b1; // <-
                        
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0; 
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        ESTADO = fetch;
                        CONTADOR = 5'b00000;
                    end
                end
                ESTADO_RTE: begin
                    if (CONTADOR == 5'b00000) begin           
                        // so ativo o pcwrite e a saida do mux                                   
                        PCWrite = 1'b1; // <- 
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;  
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0; // <- estou tirando do epc, n escrevendo
                        PCSource = 3'b011; // <- saida 3 do mux que vai pra PC 
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        ESTADO = fetch;  // so tem 1 ciclo 
                        CONTADOR = 5'b00000;
                    end
                end
                ESTADO_BREAK: begin
                    if (CONTADOR == 5'b00000) begin
                            AluSrcA = 2'b00; // <-
                            AluSrcB = 3'b001; // <-
                            ULA_c = 3'b010; // <-
                            ALU_w = 1'b1; // <-
                    
                            MDRWrite = 1'b0;
                            PCWrite = 1'b0; 
                            RegWrite = 1'b0;
                            MEMWrite = 1'b0;
                            IRWrite = 1'b0;
                            AWrite = 1'b0;
                            BWrite = 1'b0;
                            EPCWrite = 1'b0;
                            HiWrite = 1'b0;
                            LoWrite = 1'b0;
                            LControl = 2'b00;
                            
                            ESTADO = ESTADO_BREAK;
                            CONTADOR = CONTADOR + 5'b00001;
                    end else begin
                            PCSource = 3'b001;  // <-
                            PCWrite = 1'b1; // <-
                            RegWrite = 1'b0;
                            MEMWrite = 1'b0;
                            IRWrite = 1'b0;
                            AWrite = 1'b0;
                            BWrite = 1'b0;
                            ALU_w = 1'b0;
                            EPCWrite = 1'b0;
                            HiWrite = 1'b0;
                            LoWrite = 1'b0;
                            MDRWrite = 1'b0;
                            LControl = 2'b00;

                            ESTADO = fetch;
                            CONTADOR =  5'b00000;
                    end
                end
                ESTADO_SLT: begin
                    if (CONTADOR == 5'b00000) begin
                        AluSrcA = 2'b01; // <-
                        AluSrcB = 3'b000; // <-
                        ULA_c = 3'b111;  // <-
                        ALU_w = 1'b0; 
                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = CONTADOR + 5'b00001;
                        ESTADO = ESTADO_SLT;
                    end else begin
                        ALU_w = 1'b0; 
                        MemtoReg = 3'b101; // <-
                        RegDst = 2'b11; // <-
                        
                        MDRWrite = 1'b0;
                        PCWrite = 1'b0;
                        RegWrite = 1'b1; // <-
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = 5'b00001;
                        ESTADO = fetch;
                    end

                end
                ESTADO_ADDM: begin
                    if (CONTADOR == 5'b00000 || CONTADOR == 5'b00001 || CONTADOR == 5'b00010) begin
                        IorD = 3'b010; // <-

                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0; // <-
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = CONTADOR + 5'b00001;
                        ESTADO = ESTADO_ADDM; 
                    end else if (CONTADOR == 5'b00011) begin
                        
                        
                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b10;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b1; // <-
                        LControl = 2'b00;

                        CONTADOR = CONTADOR + 5'b00001;
                        ESTADO = ESTADO_ADDM; 
                    end else if (CONTADOR == 5'b000100 || CONTADOR == 5'b00101 || CONTADOR == 5'b00110) begin
                        IorD = 3'b011; // <-

                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0; // <-
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = CONTADOR + 5'b00001;
                        ESTADO = ESTADO_ADDM; 
                    
                    
                    end else if(CONTADOR == 5'b00111) begin
                        AluSrcA = 2'b10; // <-
                        AluSrcB = 3'b100; // <-
                        ULA_c = 3'b001; // <-

                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b1; // <-
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0; 
                        LControl = 2'b00;
                        
                        CONTADOR = CONTADOR + 5'b00001;
                        ESTADO = ESTADO_ADDM; 
                    end else begin
                        
                        PCWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        RegDst = 2'b11;   // <-
                        MemtoReg = 3'b000;  // <-
                        RegWrite = 1'b1;   // <-
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;
                        // 
                        ESTADO = fetch;
                        CONTADOR = 5'b00000;
                    end
                end
                ESTADO_SLL: begin
                    if(CONTADOR == 5'b00000) begin
                        AmountCrtl = 2'b01; //<-
                        ShiftSrc = 1'b1; // <-
                        ShiftCtrl = 3'b001; // <-

                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = CONTADOR + 5'b00001;
                        ESTADO = ESTADO_SLL;
                    end else if(CONTADOR == 5'b00001)begin
                        //AmountCrtl = 2'b01; //<-
                        //ShiftSrc = 1'b1; // <-
                        ShiftCtrl = 3'b010; // <-

                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = CONTADOR + 5'b00001;
                        ESTADO = ESTADO_SLL;
                        
                    end else begin
                        RegDst = 2'b11; // <-
                        MemtoReg = 3'b100; // <-

                        ShiftCtrl = 3'b000; // <-
                        PCWrite = 1'b0;
                        RegWrite = 1'b1; // <-
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = 5'b00000;
                        ESTADO = fetch;
                    end   
                        
                end
                ESTADO_SRA: begin
                    if(CONTADOR == 5'b00000) begin
                        AmountCrtl = 2'b01; //<-
                        ShiftSrc = 1'b1; // <-
                        ShiftCtrl = 3'b001; // <-

                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = CONTADOR + 5'b00001;
                        ESTADO = ESTADO_SRA;
                    end else if(CONTADOR == 5'b00001)begin
                        //AmountCrtl = 2'b01; //<-
                        //ShiftSrc = 1'b1; // <-
                        ShiftCtrl = 3'b100; // <-

                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = CONTADOR + 5'b00001;
                        ESTADO = ESTADO_SRA;
                        
                    end else begin
                        RegDst = 2'b11; // <-
                        MemtoReg = 3'b100; // <-

                        ShiftCtrl = 3'b000; // <-
                        PCWrite = 1'b0;
                        RegWrite = 1'b1; // <-
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = 5'b00000;
                        ESTADO = fetch;
                    end   
                end
                ESTADO_SRL: begin
                    if(CONTADOR == 5'b00000) begin
                        AmountCrtl = 2'b01; //<-
                        ShiftSrc = 1'b1; // <-
                        ShiftCtrl = 3'b001; // <-

                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = CONTADOR + 5'b00001;
                        ESTADO = ESTADO_SRL;
                    end else if(CONTADOR == 5'b00001)begin
                        //AmountCrtl = 2'b01; //<-
                        //ShiftSrc = 1'b1; // <-
                        ShiftCtrl = 3'b011; // <-

                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = CONTADOR + 5'b00001;
                        ESTADO = ESTADO_SRL;
                        
                    end else begin
                        RegDst = 2'b11; // <-
                        MemtoReg = 3'b100; // <-

                        ShiftCtrl = 3'b000; // <-
                        PCWrite = 1'b0;
                        RegWrite = 1'b1; // <-
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = 5'b00000;
                        ESTADO = fetch;
                    end   
                end
                ESTADO_SLLV: begin
                    if(CONTADOR == 5'b00000) begin
                        AmountCrtl = 2'b00; //<-
                        ShiftSrc = 1'b0; // <-
                        ShiftCtrl = 3'b001; // <-

                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = CONTADOR + 5'b00001;
                        ESTADO = ESTADO_SLLV;
                    end else if(CONTADOR == 5'b00001)begin
                        //AmountCrtl = 2'b01; //<-
                        //ShiftSrc = 1'b1; // <-
                        ShiftCtrl = 3'b010; // <-

                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = CONTADOR + 5'b00001;
                        ESTADO = ESTADO_SLLV;
                        
                    end else begin
                        RegDst = 2'b11; // <-
                        MemtoReg = 3'b100; // <-

                        ShiftCtrl = 3'b000; // <-
                        PCWrite = 1'b0;
                        RegWrite = 1'b1; // <-
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = 5'b00000;
                        ESTADO = fetch;
                    end   
                end
                ESTADO_SRAV: begin
                    if(CONTADOR == 5'b00000) begin
                        AmountCrtl = 2'b00; //<-
                        ShiftSrc = 1'b0; // <-
                        ShiftCtrl = 3'b001; // <-

                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = CONTADOR + 5'b00001;
                        ESTADO = ESTADO_SRAV;
                    end else if(CONTADOR == 5'b00001)begin
                        //AmountCrtl = 2'b01; //<-
                        //ShiftSrc = 1'b1; // <-
                        ShiftCtrl = 3'b100; // <-

                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = CONTADOR + 5'b00001;
                        ESTADO = ESTADO_SRAV;
                        
                    end else begin
                        RegDst = 2'b11; // <-
                        MemtoReg = 3'b100; // <-

                        ShiftCtrl = 3'b000; // <-
                        PCWrite = 1'b0;
                        RegWrite = 1'b1; // <-
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = 5'b00000;
                        ESTADO = fetch;
                    end   
                end
                ESTADO_SLLM: begin
                    if(CONTADOR == 5'b00000) begin
                        AluSrcA = 2'b01; // <- 
                        ExtdCtrl = 1'b0; // <- 
                        AluSrcB = 3'b010; // <- 
                        ULA_c = 3'b001; // <- 

                        
                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b1; // <-
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        ESTADO = ESTADO_SLLM;
                        CONTADOR = CONTADOR + 5'b00001;
                    end else if (CONTADOR == 5'b00001 || CONTADOR == 5'b00010 || CONTADOR == 5'b00011) begin
                        IorD = 3'b001; // <-

                        
                        PCWrite = 1'b0;
                        RegWrite = 1'b0; // <-
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;
                        
                        ESTADO = ESTADO_SLLM;
                        CONTADOR = CONTADOR + 5'b00001;
                    end else if (CONTADOR == 5'b00100) begin
                        // AmountCrtl = 2'b10; // <-  
                        // ShiftSrc = 1'b1; // <- 
                        // ShiftCtrl = 3'b010; // <- 
                        
                        PCWrite = 1'b0;
                        RegWrite = 1'b0; 
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b1; // <-
                        LControl = 2'b00;

                        ESTADO = ESTADO_SLLM;
                        CONTADOR = CONTADOR + 5'b00001;

                    // end else if (CONTADOR == 5'b00101)begin
                    //     // AmountCrtl = 2'b10; // <-  
                    //     // ShiftSrc = 1'b1; // <- 
                        
                        
                    //     PCWrite = 1'b0;
                    //     RegWrite = 1'b0; 
                    //     MEMWrite = 1'b0;
                    //     IRWrite = 1'b0;
                    //     AWrite = 1'b0;
                    //     BWrite = 1'b0;
                    //     ALU_w = 1'b0;
                    //     EPCWrite = 1'b0;
                    //     HiWrite = 1'b0;
                    //     LoWrite = 1'b0;
                    //     MDRWrite = 1'b0; // <-
                    //     LControl = 2'b00;

                    //     ESTADO = ESTADO_SLLM;
                    //     CONTADOR = CONTADOR + 5'b00001;
                    end else if (CONTADOR == 5'b00101 || CONTADOR == 5'b00110 || CONTADOR == 5'b00111) begin
                        
                        // AmountCrtl = 2'b10; // <-  
                        // ShiftSrc = 1'b1; // <- 
                        // ShiftCtrl = 3'b010; // <- 
                        
                        PCWrite = 1'b0;
                        RegWrite = 1'b0; 
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0; // <-
                        LControl = 2'b00;

                        ESTADO = ESTADO_SLLM;
                        CONTADOR = CONTADOR + 5'b00001;
                    end else if (CONTADOR == 5'b01000) begin
                        ShiftCtrl = 3'b001; // <- 
                        AmountCrtl = 2'b10; // <-  
                        ShiftSrc = 1'b1; // <- 
                        // ShiftCtrl = 3'b010; // <- 
                        
                        PCWrite = 1'b0;
                        RegWrite = 1'b0; 
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0; // <-
                        LControl = 2'b00;

                        ESTADO = ESTADO_SLLM;
                        CONTADOR = CONTADOR + 5'b00001;
                    end else if (CONTADOR ==   5'b01001) begin
                        ShiftCtrl = 3'b010; // <- 
                        
                        
                        PCWrite = 1'b0;
                        RegWrite = 1'b0; // <- 
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;
                        ESTADO = ESTADO_SLLM;
                        CONTADOR = CONTADOR + 5'b00001;
                    end else begin
                        MemtoReg = 3'b100; // <- 
                        RegDst = 2'b00; // <-
                        PCWrite = 1'b0;
                        RegWrite = 1'b1; // <- 
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;
                        ESTADO = fetch;
                        CONTADOR = 5'b00000; 
                    end

                end
                ESTADO_LUI: begin
                    MemtoReg = 3'b110; // <-
                    RegDst = 2'b00; // <-


                    PCWrite = 1'b0;
                    RegWrite = 1'b1; // <-
                    MEMWrite = 1'b0;
                    IRWrite = 1'b0;
                    AWrite = 1'b0;
                    BWrite = 1'b0;
                    ALU_w = 1'b0;
                    EPCWrite = 1'b0;
                    HiWrite = 1'b0;
                    LoWrite = 1'b0;
                    MDRWrite = 1'b0;
                    LControl = 2'b00;

                    CONTADOR = 5'b00000;
                    ESTADO = fetch;
                end

                ESTADO_LB : begin
                    if (CONTADOR == 5'b00000) begin
                        ESTADO = ESTADO_LB;
                        AluSrcA = 1'b1;   // <-
                        AluSrcB = 3'b010; // <-
                        ExtdCtrl = 1'b0;
                        ULA_c = 3'b001;   // <-
                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b1; // <-
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;
                    
                        CONTADOR = CONTADOR  + 5'b00001;
                    end 
                    else if(CONTADOR == 5'b00001 || CONTADOR == 5'b00010 || CONTADOR == 5'b00011) begin
                        MEMWrite = 1'b0; // <-
                        IorD = 3'b001; // <-
                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;
                        
                        ESTADO = ESTADO_LB;
                        CONTADOR = CONTADOR  + 5'b00001;
                    end
                    else if(CONTADOR == 5'b00100) begin
                        // RegDst = 2'b00; // <-
                        // RegWrite = 1'b1; // <-
                        // MemtoReg = 3'b001; // <-
                        // LControl = 2'b10; // <-
                        PCWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b1; // <-

                        ESTADO = ESTADO_LB;
                        CONTADOR = CONTADOR + 5'b00001;
                    end else begin
                        RegDst = 2'b00; // <-
                        RegWrite = 1'b1; // <-
                        MemtoReg = 3'b001; // <-
                        LControl = 2'b10; // <-
                        PCWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0; // <-
                        ESTADO = fetch;
                        CONTADOR = 5'b00000;
                    end
                end
                ESTADO_LH : begin
                    if (CONTADOR == 5'b00000) begin
                        ESTADO = ESTADO_LH;
                        AluSrcA = 1'b1; // <-
                        AluSrcB = 3'b010; // <-
                        ExtdCtrl = 1'b0;
                        ULA_c = 3'b001; // <-
                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b1; // <-
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        ESTADO = ESTADO_LH;
                        CONTADOR = CONTADOR  + 5'b00001;
                    end 
                    else if(CONTADOR == 5'b00001 || CONTADOR == 5'b00010 || CONTADOR == 5'b00011) begin
                        MEMWrite = 1'b0; // <-
                        IorD = 3'b001; // <-
                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = CONTADOR  + 5'b00001;
                    end
                    else if(CONTADOR == 5'b00100) begin
                        // RegDst = 2'b00; // <-
                        RegWrite = 1'b0; // <-
                        // MemtoReg = 3'b001; // <-
                        // LControl = 2'b01; // <-
                        PCWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b1; // <-

                        ESTADO = ESTADO_LH;
                        CONTADOR = CONTADOR + 5'b00001;
                    end else begin
                        RegDst = 2'b00; // <-
                        MemtoReg = 3'b001; // <-
                        LControl = 2'b01; // <-
                        RegWrite = 1'b1; // <-
                        PCWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0; // <-
                        
                        ESTADO = fetch;
                        CONTADOR = 5'b00000;
                    end
                end

                ESTADO_LW : begin
                    if (CONTADOR == 5'b00000) begin
                        ESTADO = ESTADO_LW;
                        AluSrcA = 1'b1; // <-
                        AluSrcB = 3'b010; // <-
                        ExtdCtrl = 1'b0;
                        ULA_c = 3'b001; // <-
                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b1;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;
                    
                        CONTADOR = CONTADOR  + 5'b00001;
                    end 
                    else if(CONTADOR == 5'b00001 || CONTADOR == 5'b00010 || CONTADOR == 5'b00011) begin
                        MEMWrite = 1'b0; // <-
                        IorD = 3'b001; // <-
                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0; // <-
                        LControl = 2'b00;

                        ESTADO = ESTADO_LW;
                        CONTADOR = CONTADOR  + 5'b00001;
                    end
                    else if(CONTADOR == 5'b00100) begin
                        
                        RegWrite = 1'b0; // <-
                    
                        // LControl = 2'b00; // <-
                        PCWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b1; // <-

                        ESTADO = ESTADO_LW;
                        CONTADOR = CONTADOR + 5'b00001;
                    end else begin
                        RegDst = 2'b00; // <-
                        MemtoReg = 3'b001; // <-
                        LControl = 2'b00; // <-
                        RegWrite = 1'b1;
                        PCWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0; // <-

                        ESTADO = fetch;
                        CONTADOR = 5'b00000;
                    end
                end
                

                ESTADO_SB : begin
                    if (CONTADOR == 5'b00000) begin

                        ESTADO = ESTADO_SB;

                        AluSrcA = 2'b01; // <-
                        AluSrcB = 3'b010; // <-
                        ExtdCtrl = 1'b0;  // <-
                        ULA_c = 3'b001; // <-

                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b1; // <-
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = CONTADOR + 5'b00001;
                        
                    end
                    else if (CONTADOR == 5'b00001 || CONTADOR == 5'b00010 || CONTADOR == 5'b00011) begin
                        MEMWrite = 1'b0; // <-
                        IorD = 3'b001; // <-

                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = CONTADOR + 5'b00001;
                        ESTADO = ESTADO_SB;
                    end
                    
                    else if (CONTADOR == 5'b00100) begin

                        MEMWrite = 1'b1; // <-
                        SControl = 2'b01; // < -

                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = 5'b00000;
                        ESTADO = fetch;

                    end

                end

                ESTADO_SH : begin
                    if (CONTADOR == 5'b00000) begin

                        ESTADO = ESTADO_SH;

                        AluSrcA = 2'b01; // <-
                        AluSrcB = 3'b010; // <-
                        ExtdCtrl = 1'b0; // <-
                        ULA_c = 3'b001; // <-

                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b1; // <-
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = CONTADOR + 5'b00001;
                        
                    end
                    else if (CONTADOR == 5'b00001 || CONTADOR == 5'b00010 || CONTADOR == 5'b00011) begin
                        MEMWrite = 1'b0; // <-
                        IorD = 3'b001; // <-

                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        ESTADO = ESTADO_SH;
                        CONTADOR = CONTADOR + 5'b00001;

                    end
                    
                    else if (CONTADOR == 5'b00100) begin

                        MEMWrite = 1'b1; // <-
                        SControl = 2'b00; // <-

                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = 5'b00000;
                        ESTADO = fetch;

                    end

                end


                ESTADO_SW : begin
                    if (CONTADOR == 5'b00000) begin

                        ESTADO = ESTADO_SW;

                        AluSrcA = 2'b01; // <-
                        AluSrcB = 3'b010; // <-
                        ExtdCtrl = 1'b0; // <-
                        ULA_c = 3'b001; // <-

                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b1; // <-
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = CONTADOR + 5'b00001;
                        
                    end
                    else if (CONTADOR == 5'b00001 || CONTADOR == 5'b00010 || CONTADOR == 5'b00011) begin
                        MEMWrite = 1'b0; // <-
                        IorD = 3'b001; // <-

                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;
                        
                        ESTADO = ESTADO_SW;
                        CONTADOR = CONTADOR + 5'b00001;

                    end
                    
                    else if (CONTADOR == 5'b00100) begin

                        MEMWrite = 1'b1; // <-
                        SControl = 2'b10; //  <-

                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = 5'b00000;
                        ESTADO = fetch;

                    end

                end
                ESTADO_SLTI: begin
                    if(CONTADOR == 5'b00000) begin
                        ExtdCtrl = 1'b0; // <-
                        AluSrcA = 2'b01;
                        AluSrcB = 3'b010;
                        ULA_c = 3'b111;


                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = CONTADOR + 5'b00001;
                        ESTADO = ESTADO_SLTI;

                    end else begin
                        
                        RegDst = 2'b00;
                        MemtoReg = 3'b101;
                        
                        PCWrite = 1'b0;
                        RegWrite = 1'b1; // -> ***
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = 5'b00000;
                        ESTADO = fetch;
                    end
                end
                Overflow: begin
                    if (CONTADOR == 5'b00000 || CONTADOR == 5'b00001 || CONTADOR == 5'b00010) begin
                        AluSrcA = 2'b00; // <-
                        AluSrcB = 3'b01; // <-
                        ULA_c = 3'b010; // <-
                        IorD = 3'b101;// <-
                        
                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0; // <-
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = CONTADOR + 5'b00001;
                        ESTADO = Overflow;
                    end else if(CONTADOR == 5'b00011) begin
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0; 
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b1; // <-
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b1; // <-
                        LControl = 2'b00;

                        ESTADO = Overflow;
                        CONTADOR = CONTADOR + 5'b00001;
                    end else begin
                        ExtdCtrl = 1'b1; //<-
                        PCSource = 3'b100; // <=

                        PCWrite = 1'b1; // <=
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;
                    end
                end

                OPCode404 :  begin
                    if (CONTADOR == 5'b00000 || CONTADOR == 5'b00001 || CONTADOR == 5'b00010) begin
                        AluSrcA = 2'b00; // <-
                        AluSrcB = 3'b01; // <-
                        ULA_c = 3'b010; // <-
                        IorD = 3'b100;// <-
                        
                        PCWrite = 1'b0;
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0; // <-
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        CONTADOR = CONTADOR + 5'b00001;
                        ESTADO = OPCode404;
                    end else if(CONTADOR == 5'b00011) begin
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0; 
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b1; // <-
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b1; // <-
                        LControl = 2'b00;

                        ESTADO = OPCode404;
                        CONTADOR = CONTADOR + 5'b00001;
                    end else begin
                        ExtdCtrl = 1'b1; //<-
                        PCSource = 3'b100; // <-

                        PCWrite = 1'b1; // <=
                        RegWrite = 1'b0;
                        MEMWrite = 1'b0;
                        IRWrite = 1'b0;
                        AWrite = 1'b0;
                        BWrite = 1'b0;
                        ALU_w = 1'b0;
                        EPCWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        MDRWrite = 1'b0;
                        LControl = 2'b00;

                        ESTADO = fetch;
                        CONTADOR = 5'b00000;
                    end
                end 
            endcase
        end
    end
endmodule
