module CPU(

// Res & Clk

    input wire clk,
    input wire reset
);

// ------------------------- Flags da ULA ------------------------------ //
    
    wire Of;
    wire Ng;
    wire Zr;
    wire Eq;
    wire Gt;
    wire Lt;

//-----------------------------------------------------------------------//

// ----------------- Sinais de Controle dos mux's --------------------- //
    
    wire [1:0] RegDst;
    wire [2:0] MentoReg;
    wire [1:0] AluSrcA;
    wire [2:0] AluSrcB;
    wire [2:0] PCSource;
    wire [2:0] IorD;
    wire HiSel;
    wire LoSel;
    wire ShiftSrc;
    wire [1:0] AmountCrtl;
    wire [4:0] M_WRREG_out;
    wire [31:0] mux_to_mem;
    wire [31:0] m_A_out;
    wire [31:0] m_B_out;
    wire [31:0] M_wdata_out;
    wire [31:0] M_ALU_out;
    wire ExtdCtrl;


// --------------------------------------------------------------------- //


// ----------------- Sinais de controle de 1 bit ----------------------- //

    wire PCWrite;
    wire ALU_w;
    wire MEMWrite;
    wire IRWrite;
    wire RegWrite;
    wire AWrite;
    wire BWrite;
    wire EPCWrite;
    wire HiWrite;
    wire LoWrite;
    wire MDRWrite;
    

// ---------------------------------------------------------------------- //


// ------------------ sinais de controle com mais de 1 bit -------------- //
    wire [2:0] ULA_c;
    wire [1:0] LControl;
    wire [2:0] ShiftCtrl;
    wire [1:0] SControl;

// ---------------------------------------------------------------------- //

// IR
    wire [5:0] OPCODE;
    wire [4:0] RS;
    wire [4:0] RT;
    //wire [4:0] RD;
    wire [15:0] IMEDIATO;

    
    wire [31:0] PC_out;
 


//-------------------- Fios que registradores ----------------------------- //
    
    wire [31:0] ULA_result;
    wire [31:0] MemOut;
    wire [31:0] RB_to_A;
    wire [31:0] RB_to_B;
    wire [31:0] A_out;
    wire [31:0] B_out;
    wire [31:0] MEM_in;
    wire [31:0] LSize_out;
    wire [31:0] Hi_out;
    wire [31:0] Lo_out;
    wire [31:0] Shift_out;
    wire [31:0] s_ext_1to32_out;
    wire [31:0] shift_ext_out;
    wire [31:0] signExt_out;
    wire [31:0] shift_2_out;
    wire [31:0] ALU_out;
    wire [31:0] EPCOut;
    wire [31:0] DivHi_Out;
    wire [31:0] MultHi_Out;
    wire [31:0] M_Hi_Out;
    wire [31:0] DivLo_Out;
    wire [31:0] MultLo_Out;
    wire [31:0] M_Lo_Out;
    wire [31:0] sign_extd1_32_out;
    wire [31:0] MDR_out;
    wire [31:0] M_shift_out;
    wire [4:0] M_shamt_out;
    wire [31:0] RegDesloc_out;
    wire [31:0] Shift2_26_ext_32_pc_out;
    wire [15:0] M_ext_out;
    wire [31:0] S_out;
    wire [31:0] Shift_16_ext_32_out;
    



    

    Registrador          PC_(
        clk,
        reset,
        PCWrite,
        M_ALU_out,
        PC_out
    );

    mux_Mem            Mux_M_(
        IorD,
        PC_out,
        ALU_out,
        A_out,
        B_out,
        mux_to_mem
    );

    Memoria            Mem_(
        mux_to_mem,
        clk,
        MEMWrite,
        S_out,
        MemOut
    );


    Instr_Reg          IR_(
        clk,
        reset,
        IRWrite,
        MemOut,
        OPCODE,
        RS,
        RT,
        IMEDIATO
    );
   
    mux_wreg       M_WRREG_(
        RegDst,
        RT,
        IMEDIATO,
        M_WRREG_out // ver quais desses precisa instanciar la em cima
    );

    mux_writeData      M_WDATA_(
        MentoReg,
        ALU_out,
        LSize_out,
        Hi_out,
        Lo_out,
        RegDesloc_out,
        sign_extd1_32_out, //obs
        Shift_16_ext_32_out,
        M_wdata_out
    );

    Banco_reg        REG_BASE_(
        clk,
        reset,
        RegWrite,
        RS,
        RT,
        M_WRREG_out,    // checar quais tem que ser instanciados la em cima
        M_wdata_out,
        RB_to_A,
        RB_to_B
    );

    Registrador      A_(
        clk,
        reset,
        AWrite,      // checar o que deve ser instanciado 
        RB_to_A,
        A_out
    );

    Registrador      B_(
        clk,
        reset,
        BWrite,      // checar o que deve ser instanciado 
        RB_to_B,
        B_out
    );

    
    mux_A            M_A(
        AluSrcA,
        PC_out,
        A_out,
        MDR_out,
        m_A_out
    );

    shift_16_ext_32 Shift_16_ext_32_(
        IMEDIATO,
        Shift_16_ext_32_out
    );

    sign_extd         Sign_ext_(
        M_ext_out,
        signExt_out
    );
    
    
    shift_lf_2        Shift_2(
        signExt_out,
        shift_2_out
    );

    shift2_26_to_28_pc Shift2_26_ext_32_pc_(
        RS,
        RT,
        IMEDIATO,
        PC_out[31:28],
        Shift2_26_ext_32_pc_out
    );
    
    mux_B             M_B(
        AluSrcB,
        B_out,
        signExt_out,
        shift_2_out,
        MemOut,
        m_B_out
    );

    mux_shift M_shift(
        ShiftSrc,
        A_out,
        B_out,
        M_shift_out
    );
    
    mux_shamt M_shamt(
        AmountCrtl,
        B_out,
        IMEDIATO,
        MDR_out,
        M_shamt_out
    );

    RegDesloc Reg_Desloc_(
        clk,
        reset,
        ShiftCtrl,
        M_shamt_out,
        M_shift_out,
        RegDesloc_out
    );

    Registrador MDR_(
        clk,
        reset,
        MDRWrite,
        MemOut,
        MDR_out
    );
    
    LSize LSize_(
        LControl,
        MDR_out,
        LSize_out
    );

    ula32           ULA_LA(
        m_A_out,
        m_B_out,
        ULA_c,
        ULA_result,
        Of, // overflow
        Ng, // negativo
        Zr, // zero
        Eq,
        Gt,
        Lt
    );

    
    Registrador     REG_ALUOut(
        clk,
        reset,
        ALU_w,
        ULA_result,
        ALU_out
    );

    
    mux_ALUOut     M_ALUOut(
        PCSource,
        ULA_result,
        ALU_out,
        Shift2_26_ext_32_pc_out,
        EPCOut,
        signExt_out,
        mux_to_mem,
        M_ALU_out
    );
    
    Registrador EPC_(
        clk,
        reset,
        EPCWrite,
        ULA_result,
        EPCOut
    );
    
    mux_hi M_Hi(
        HiSel,
        DivHi_Out,
        MultHi_Out,
        M_Hi_Out
    );

    Registrador Hi_(
        clk,
        reset,
        HiWrite,
        M_Hi_Out,
        Hi_out
    );

    mux_lo M_Lo(
        LoSel,
        DivLo_Out,
        MultLo_Out,
        M_Lo_Out
    );

    Registrador Lo(
        clk,
        reset,
        LoWrite,
        M_Lo_Out,
        Lo_out
    );

    sign_extd1_to_32 sign_extd1_32(
        Lt,
        sign_extd1_32_out
    );

    mux_ext M_ext(
        ExtdCtrl,
        IMEDIATO,
        MDR_out[15:0],
        M_ext_out
    );

    SSize SSize_(
        SControl,
        MemOut,
        B_out,
        S_out
    );



    Unidade_Controle       UNI_CTRL(
        clk,
        reset,
        Of,
        Ng,
        Zr,
        Eq,
        Gt,
        Lt,
        OPCODE,
        IMEDIATO,
        PCWrite,
        IorD,
        MEMWrite,
        IRWrite,
        RegDst,
        MentoReg,
        RegWrite,
        AWrite,
        BWrite,
        AluSrcA,
        AluSrcB,
        ULA_c,
        ALU_w,
        PCSource,
        EPCWrite,
        HiSel,
        HiWrite,
        LoSel,
        LoWrite,
        MDRWrite,
        LControl,
        ShiftSrc,
        AmountCrtl,
        ShiftCtrl,
        ExtdCtrl,
        SControl
    );

endmodule
