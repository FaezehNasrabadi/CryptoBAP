open HolKernel Parse

open binariesLib;
open binariesTheory;
open binariesCfgLib;
open binariesMemLib;
open bir_symbexec_stateLib;
open bir_symbexec_coreLib;
open bir_symbexec_stepLib;
open bir_symbexec_sumLib;
open bir_countw_simplificationLib;
open bir_block_collectionLib;
open bir_programSyntax;
open bir_valuesSyntax;
open bir_immSyntax;
open bir_exec_typingLib;
open commonBalrobScriptLib;
open binariesDefsLib;
open bir_cfgLib;
open bir_cfg_m0Lib;
open bir_symbexec_driverLib;
open Redblackmap;

val prog = ``BirProgram
    [
     <|bb_label := 
                  BL_Address_HC (Imm64 636w)
                    "A9AE7BFD (stp x29, x30, [sp, #-288]!)";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assert
                     (BExp_unchanged_mem_interval_distinct Bit64 0 32768
                        (BExp_BinExp BIExp_Minus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 288w))) 16);
                   BStmt_Assign (BVar "tmp_SP_EL0" (BType_Imm Bit64))
                     (BExp_BinExp BIExp_Minus
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                        (BExp_Const (Imm64 288w)));
                   BStmt_Assign (BVar "MEM" (BType_Mem Bit64 Bit8))
                     (BExp_Store
                        (BExp_Store
                           (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                           (BExp_BinExp BIExp_Minus
                              (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                              (BExp_Const (Imm64 288w))) BEnd_LittleEndian
                           (BExp_Den (BVar "R29" (BType_Imm Bit64))))
                        (BExp_BinExp BIExp_Minus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 280w))) BEnd_LittleEndian
                        (BExp_Den (BVar "R30" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "SP_EL0" (BType_Imm Bit64))
                     (BExp_Den (BVar "tmp_SP_EL0" (BType_Imm Bit64)))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 640w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 640w) "910003FD (mov x29, sp)";
                bb_statements :=
                  [BStmt_Assign (BVar "R29" (BType_Imm Bit64))
                     (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 644w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 644w) "F9000FE0 (str x0, [sp, #24])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assert
                     (BExp_unchanged_mem_interval_distinct Bit64 0 32768
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 24w))) 8);
                   BStmt_Assign (BVar "MEM" (BType_Mem Bit64 Bit8))
                     (BExp_Store
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 24w))) BEnd_LittleEndian
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 648w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 648w) "F9000BE1 (str x1, [sp, #16])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assert
                     (BExp_unchanged_mem_interval_distinct Bit64 0 32768
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 16w))) 8);
                   BStmt_Assign (BVar "MEM" (BType_Mem Bit64 Bit8))
                     (BExp_Store
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 16w))) BEnd_LittleEndian
                        (BExp_Den (BVar "R1" (BType_Imm Bit64))))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 652w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 652w) "F9400FE0 (ldr x0, [sp, #24])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 24w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 656w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 656w) "F100001F (cmp x0, #0x0)";
                bb_statements :=
                  [BStmt_Assign (BVar "ProcState_C" BType_Bool)
                     bir_exp_true;
                   BStmt_Assign (BVar "ProcState_N" BType_Bool)
                     (BExp_MSB Bit64
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "ProcState_V" BType_Bool)
                     bir_exp_false;
                   BStmt_Assign (BVar "ProcState_Z" BType_Bool)
                     (BExp_BinPred BIExp_Equal
                        (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                        (BExp_Const (Imm64 0w)))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 660w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 660w)
                    "540000A0 (b.eq 188 <PKCS11_initialize+0xe8>  // b.none)";
                bb_statements := [];
                bb_last_statement :=
                  BStmt_CJmp (BExp_Den (BVar "ProcState_Z" BType_Bool))
                    (BLE_Label (BL_Address (Imm64 680w)))
                    (BLE_Label (BL_Address (Imm64 664w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 664w) "F9400FE0 (ldr x0, [sp, #24])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 24w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 668w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 668w) "39400000 (ldrb w0, [x0])";
                bb_statements :=
                  [BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Cast BIExp_UnsignedCast
                        (BExp_Load
                           (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                           (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                           BEnd_LittleEndian Bit8) Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 672w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 672w) "7100001F (cmp w0, #0x0)";
                bb_statements :=
                  [BStmt_Assign (BVar "ProcState_C" BType_Bool)
                     bir_exp_true;
                   BStmt_Assign (BVar "ProcState_N" BType_Bool)
                     (BExp_MSB Bit32
                        (BExp_Cast BIExp_LowCast
                           (BExp_Den (BVar "R0" (BType_Imm Bit64))) Bit32));
                   BStmt_Assign (BVar "ProcState_V" BType_Bool)
                     bir_exp_false;
                   BStmt_Assign (BVar "ProcState_Z" BType_Bool)
                     (BExp_BinPred BIExp_Equal
                        (BExp_Cast BIExp_LowCast
                           (BExp_Den (BVar "R0" (BType_Imm Bit64))) Bit32)
                        (BExp_Const (Imm32 0w)))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 676w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 676w)
                    "54000061 (b.ne f0 <PKCS11_initialize+0x50>  // b.any)";
                bb_statements := [];
                bb_last_statement :=
                  BStmt_CJmp (BExp_Den (BVar "ProcState_Z" BType_Bool))
                    (BLE_Label (BL_Address (Imm64 680w)))
                    (BLE_Label (BL_Address (Imm64 688w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 680w)
                    "D2803200 (mov x0, #0x190                  // #400)";
                bb_statements :=
                  [BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Const (Imm64 400w))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 684w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 684w)
                    "14000037 (b 388 <PKCS11_wrap_key+0x10c>)";
                bb_statements := [];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 904w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 688w) "F9400BE0 (ldr x0, [sp, #16])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 16w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 692w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 692w) "F9400000 (ldr x0, [x0])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                        BEnd_LittleEndian Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 696w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 696w) "AA0003E1 (mov x1, x0)";
                bb_statements :=
                  [BStmt_Assign (BVar "R1" (BType_Imm Bit64))
                     (BExp_Den (BVar "R0" (BType_Imm Bit64)))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 700w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 700w) "F9400FE0 (ldr x0, [sp, #24])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 24w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 704w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 704w) "94000000 (bl 0 <puts>)";
                bb_statements :=
                  [BStmt_Assign (BVar "R30" (BType_Imm Bit64))
                     (BExp_Const (Imm64 708w))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 708w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 708w)
                    "F9008FE0 (str x0, [sp, #280])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assert
                     (BExp_unchanged_mem_interval_distinct Bit64 0 32768
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 280w))) 8);
                   BStmt_Assign (BVar "MEM" (BType_Mem Bit64 Bit8))
                     (BExp_Store
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 280w))) BEnd_LittleEndian
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 712w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 712w) "F9400BE0 (ldr x0, [sp, #16])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 16w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 716w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 716w) "F9400400 (ldr x0, [x0, #8])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 8w))) BEnd_LittleEndian Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 720w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 720w) "AA0003E1 (mov x1, x0)";
                bb_statements :=
                  [BStmt_Assign (BVar "R1" (BType_Imm Bit64))
                     (BExp_Den (BVar "R0" (BType_Imm Bit64)))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 724w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 724w) "F9400FE0 (ldr x0, [sp, #24])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 24w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 728w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 728w) "94000000 (bl 0 <puts>)";
                bb_statements :=
                  [BStmt_Assign (BVar "R30" (BType_Imm Bit64))
                     (BExp_Const (Imm64 732w))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 732w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 732w)
                    "F9008BE0 (str x0, [sp, #272])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assert
                     (BExp_unchanged_mem_interval_distinct Bit64 0 32768
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 272w))) 8);
                   BStmt_Assign (BVar "MEM" (BType_Mem Bit64 Bit8))
                     (BExp_Store
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 272w))) BEnd_LittleEndian
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 736w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 736w)
                    "F9408FE0 (ldr x0, [sp, #280])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 280w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 740w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 740w) "F100001F (cmp x0, #0x0)";
                bb_statements :=
                  [BStmt_Assign (BVar "ProcState_C" BType_Bool)
                     bir_exp_true;
                   BStmt_Assign (BVar "ProcState_N" BType_Bool)
                     (BExp_MSB Bit64
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "ProcState_V" BType_Bool)
                     bir_exp_false;
                   BStmt_Assign (BVar "ProcState_Z" BType_Bool)
                     (BExp_BinPred BIExp_Equal
                        (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                        (BExp_Const (Imm64 0w)))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 744w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 744w)
                    "54000080 (b.eq 2f8 <PKCS11_wrap_key+0x7c>  // b.none)";
                bb_statements := [];
                bb_last_statement :=
                  BStmt_CJmp (BExp_Den (BVar "ProcState_Z" BType_Bool))
                    (BLE_Label (BL_Address (Imm64 760w)))
                    (BLE_Label (BL_Address (Imm64 748w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 748w)
                    "F9408BE0 (ldr x0, [sp, #272])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 272w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 752w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 752w) "F100001F (cmp x0, #0x0)";
                bb_statements :=
                  [BStmt_Assign (BVar "ProcState_C" BType_Bool)
                     bir_exp_true;
                   BStmt_Assign (BVar "ProcState_N" BType_Bool)
                     (BExp_MSB Bit64
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "ProcState_V" BType_Bool)
                     bir_exp_false;
                   BStmt_Assign (BVar "ProcState_Z" BType_Bool)
                     (BExp_BinPred BIExp_Equal
                        (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                        (BExp_Const (Imm64 0w)))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 756w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 756w)
                    "540000A1 (b.ne 210 <PKCS11_generate_key+0x5c>  // b.any)";
                bb_statements := [];
                bb_last_statement :=
                  BStmt_CJmp (BExp_Den (BVar "ProcState_Z" BType_Bool))
                    (BLE_Label (BL_Address (Imm64 760w)))
                    (BLE_Label (BL_Address (Imm64 776w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 760w)
                    "D28000E0 (mov x0, #0x7                    // #7)";
                bb_statements :=
                  [BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Const (Imm64 7w))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 764w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 764w)
                    "F90087E0 (str x0, [sp, #264])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assert
                     (BExp_unchanged_mem_interval_distinct Bit64 0 32768
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 264w))) 8);
                   BStmt_Assign (BVar "MEM" (BType_Mem Bit64 Bit8))
                     (BExp_Store
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 264w))) BEnd_LittleEndian
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 768w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 768w)
                    "F94087E0 (ldr x0, [sp, #264])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 264w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 772w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 772w)
                    "14000021 (b 388 <PKCS11_wrap_key+0x10c>)";
                bb_statements := [];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 904w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 776w)
                    "F9408FE0 (ldr x0, [sp, #280])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 280w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 780w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 780w) "F9400400 (ldr x0, [x0, #8])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 8w))) BEnd_LittleEndian Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 784w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 784w) "F100001F (cmp x0, #0x0)";
                bb_statements :=
                  [BStmt_Assign (BVar "ProcState_C" BType_Bool)
                     bir_exp_true;
                   BStmt_Assign (BVar "ProcState_N" BType_Bool)
                     (BExp_MSB Bit64
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "ProcState_V" BType_Bool)
                     bir_exp_false;
                   BStmt_Assign (BVar "ProcState_Z" BType_Bool)
                     (BExp_BinPred BIExp_Equal
                        (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                        (BExp_Const (Imm64 0w)))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 788w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 788w)
                    "540000A0 (b.eq 188 <PKCS11_initialize+0xe8>  // b.none)";
                bb_statements := [];
                bb_last_statement :=
                  BStmt_CJmp (BExp_Den (BVar "ProcState_Z" BType_Bool))
                    (BLE_Label (BL_Address (Imm64 808w)))
                    (BLE_Label (BL_Address (Imm64 792w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 792w)
                    "D2802260 (mov x0, #0x113                  // #275)";
                bb_statements :=
                  [BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Const (Imm64 275w))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 796w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 796w)
                    "F90087E0 (str x0, [sp, #264])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assert
                     (BExp_unchanged_mem_interval_distinct Bit64 0 32768
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 264w))) 8);
                   BStmt_Assign (BVar "MEM" (BType_Mem Bit64 Bit8))
                     (BExp_Store
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 264w))) BEnd_LittleEndian
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 800w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 800w)
                    "F94087E0 (ldr x0, [sp, #264])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 264w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 804w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 804w)
                    "14000019 (b 388 <PKCS11_wrap_key+0x10c>)";
                bb_statements := [];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 904w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 808w)
                    "F9408FE0 (ldr x0, [sp, #280])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 280w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 812w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 812w) "F9400800 (ldr x0, [x0, #16])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 16w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 816w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 816w)
                    "F90083E0 (str x0, [sp, #256])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assert
                     (BExp_unchanged_mem_interval_distinct Bit64 0 32768
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 256w))) 8);
                   BStmt_Assign (BVar "MEM" (BType_Mem Bit64 Bit8))
                     (BExp_Store
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 256w))) BEnd_LittleEndian
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 820w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 820w)
                    "F9408BE0 (ldr x0, [sp, #272])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 272w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 824w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 824w) "F9400800 (ldr x0, [x0, #16])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 16w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 828w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 828w)
                    "F9007FE0 (str x0, [sp, #248])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assert
                     (BExp_unchanged_mem_interval_distinct Bit64 0 32768
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 248w))) 8);
                   BStmt_Assign (BVar "MEM" (BType_Mem Bit64 Bit8))
                     (BExp_Store
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 248w))) BEnd_LittleEndian
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 832w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 832w)
                    "F9407FE0 (ldr x0, [sp, #248])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 248w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 836w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 836w) "A9400400 (ldp x0, x1, [x0])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "tmp_R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                        BEnd_LittleEndian Bit64);
                   BStmt_Assign (BVar "R1" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 8w))) BEnd_LittleEndian Bit64);
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Den (BVar "tmp_R0" (BType_Imm Bit64)))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 840w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 840w)
                    "A90E87E0 (stp x0, x1, [sp, #232])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assert
                     (BExp_unchanged_mem_interval_distinct Bit64 0 32768
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 232w))) 16);
                   BStmt_Assign (BVar "MEM" (BType_Mem Bit64 Bit8))
                     (BExp_Store
                        (BExp_Store
                           (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                           (BExp_BinExp BIExp_Plus
                              (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                              (BExp_Const (Imm64 232w))) BEnd_LittleEndian
                           (BExp_Den (BVar "R0" (BType_Imm Bit64))))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 240w))) BEnd_LittleEndian
                        (BExp_Den (BVar "R1" (BType_Imm Bit64))))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 844w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 844w) "9100A3E0 (add x0, sp, #0x28)";
                bb_statements :=
                  [BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_BinExp BIExp_Plus
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                        (BExp_Const (Imm64 40w)))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 848w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 848w)
                    "F94083E1 (ldr x1, [sp, #256])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R1" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 256w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 852w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 852w) "94000000 (bl 0 <puts>)";
                bb_statements :=
                  [BStmt_Assign (BVar "R30" (BType_Imm Bit64))
                     (BExp_Const (Imm64 856w))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 1002w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 856w) "9103A3E1 (add x1, sp, #0xe8)";
                bb_statements :=
                  [BStmt_Assign (BVar "R1" (BType_Imm Bit64))
                     (BExp_BinExp BIExp_Plus
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                        (BExp_Const (Imm64 232w)))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 860w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 860w) "9100A3E0 (add x0, sp, #0x28)";
                bb_statements :=
                  [BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_BinExp BIExp_Plus
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                        (BExp_Const (Imm64 40w)))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 864w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 864w) "94000000 (bl 0 <puts>)";
                bb_statements :=
                  [BStmt_Assign (BVar "R30" (BType_Imm Bit64))
                     (BExp_Const (Imm64 868w))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 1202w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 868w) "F9400BE0 (ldr x0, [sp, #16])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 16w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 872w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 872w) "F9400802 (ldr x2, [x0, #16])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R2" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 16w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 876w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 876w)
                    "A94E87E0 (ldp x0, x1, [sp, #232])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 232w))) BEnd_LittleEndian
                        Bit64);
                   BStmt_Assign (BVar "R1" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 240w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 880w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 880w) "A9000440 (stp x0, x1, [x2])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R2" (BType_Imm Bit64))));
                   BStmt_Assert
                     (BExp_unchanged_mem_interval_distinct Bit64 0 32768
                        (BExp_Den (BVar "R2" (BType_Imm Bit64))) 16);
                   BStmt_Assign (BVar "MEM" (BType_Mem Bit64 Bit8))
                     (BExp_Store
                        (BExp_Store
                           (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                           (BExp_Den (BVar "R2" (BType_Imm Bit64)))
                           BEnd_LittleEndian
                           (BExp_Den (BVar "R0" (BType_Imm Bit64))))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R2" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 8w))) BEnd_LittleEndian
                        (BExp_Den (BVar "R1" (BType_Imm Bit64))))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 884w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 884w) "F9400BE0 (ldr x0, [sp, #16])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 16w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 888w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 888w) "F9400C00 (ldr x0, [x0, #24])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 24w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 892w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 892w)
                    "D2800201 (mov x1, #0x10                   // #16)";
                bb_statements :=
                  [BStmt_Assign (BVar "R1" (BType_Imm Bit64))
                     (BExp_Const (Imm64 16w))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 896w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 896w) "F9000001 (str x1, [x0])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))));
                   BStmt_Assert
                     (BExp_unchanged_mem_interval_distinct Bit64 0 32768
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))) 8);
                   BStmt_Assign (BVar "MEM" (BType_Mem Bit64 Bit8))
                     (BExp_Store
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                        BEnd_LittleEndian
                        (BExp_Den (BVar "R1" (BType_Imm Bit64))))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 900w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 900w)
                    "D2800000 (mov x0, #0x0                    // #0)";
                bb_statements :=
                  [BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Const (Imm64 0w))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 904w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 904w)
                    "A8D27BFD (ldp x29, x30, [sp], #288)";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R29" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                        BEnd_LittleEndian Bit64);
                   BStmt_Assign (BVar "R30" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 8w))) BEnd_LittleEndian Bit64);
                   BStmt_Assign (BVar "SP_EL0" (BType_Imm Bit64))
                     (BExp_BinExp BIExp_Plus
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                        (BExp_Const (Imm64 288w)))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 908w)))|>;
              <|bb_label := BL_Address_HC (Imm64 908w) "D65F03C0 (ret)";
                bb_statements := [];
                bb_last_statement :=
                  BStmt_Jmp
                    (BLE_Exp (BExp_Den (BVar "R30" (BType_Imm Bit64))))|>;
              ]``;


val bl_dict  = bir_block_collectionLib.gen_block_dict prog;
val prog_lbl_tms = bir_block_collectionLib.get_block_dict_keys bl_dict;
val prog_vars = bir_exec_typingLib.gen_vars_of_prog prog;
val n_dict = bir_cfgLib.cfg_build_node_dict bl_dict prog_lbl_tms;

val lbl_tm = ``BL_Address (Imm64 636w)``;

val stop_lbl_tms = [``BL_Address (Imm64 908w)``];
    
val syst = init_state lbl_tm (``BVar "R7" (BType_Imm Bit64)``::prog_vars);

val pred_conjs = [``bir_exp_true``];
    
val syst = state_add_preds "init_pred" pred_conjs syst;

val _ = print "initial state created.\n\n";

val cfb = false;    
val systs = symb_exec_to_stop (commonBalrobScriptLib.abpfun cfb) n_dict bl_dict [syst] stop_lbl_tms systs;
val _ = print "finished exploration of all paths.\n";
val _ = print ("number of paths found: " ^ (Int.toString (length systs)));
val _ = print "\n\n";
 (* listItems(SYST_get_env (hd systs));
    listItems(SYST_get_vals (hd systs));
    listItems(SYST_get_env ((hd o tl) systs));
    listItems(SYST_get_vals ((hd o tl) systs));*)
    
val (systs_noassertfailed, systs_assertfailed) =
  List.partition (fn syst => not (identical (SYST_get_status syst) BST_AssertionViolated_tm)) systs;
val _ = print ("number of \"no assert failed\" paths found: " ^ (Int.toString (length systs_noassertfailed)));
val _ = print "\n\n";

