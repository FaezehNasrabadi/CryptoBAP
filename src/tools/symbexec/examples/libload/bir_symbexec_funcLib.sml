structure bir_symbexec_funcLib =
struct

local
    
    open bir_symbexec_stateLib;
    open bir_symbexec_coreLib;
    open bir_block_collectionLib;
    open bir_envSyntax;
    open bir_expSyntax;
    open Redblackmap;
  val ERR      = Feedback.mk_HOL_ERR "bir_symbexec_funcLib"
in
(*
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
open bir_symbexec_oracleLib;

val prog = ``BirProgram
	   [
	    <|bb_label :=
                  BL_Address_HC (Imm64 4203840w)
                    "A9B97BFD (stp x29, x30, [sp,#-112]!)";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64))));
                   BStmt_Assert
                     (BExp_unchanged_mem_interval_distinct Bit64 0
                        4294967295
                        (BExp_BinExp BIExp_Minus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 112w))) 16);
                   BStmt_Assign (BVar "tmp_SP_EL0" (BType_Imm Bit64))
                     (BExp_BinExp BIExp_Minus
                        (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                        (BExp_Const (Imm64 112w)));
                   BStmt_Assign (BVar "MEM" (BType_Mem Bit64 Bit8))
                     (BExp_Store
                        (BExp_Store
                           (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                           (BExp_BinExp BIExp_Minus
                              (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                              (BExp_Const (Imm64 112w))) BEnd_LittleEndian
                           (BExp_Den (BVar "R29" (BType_Imm Bit64))))
                        (BExp_BinExp BIExp_Minus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 104w))) BEnd_LittleEndian
                        (BExp_Den (BVar "R30" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "SP_EL0" (BType_Imm Bit64))
                     (BExp_Den (BVar "tmp_SP_EL0" (BType_Imm Bit64)))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203844w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203844w) "910003FD (mov x29, sp)";
                bb_statements :=
                  [BStmt_Assign (BVar "R29" (BType_Imm Bit64))
                     (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203848w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203848w)
                    "F90017A0 (str x0, [x29,#40])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R29" (BType_Imm Bit64))));
                   BStmt_Assert
                     (BExp_unchanged_mem_interval_distinct Bit64 0
                        4294967295
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 40w))) 8);
                   BStmt_Assign (BVar "MEM" (BType_Mem Bit64 Bit8))
                     (BExp_Store
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 40w))) BEnd_LittleEndian
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203852w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203852w)
                    "F90013A1 (str x1, [x29,#32])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R29" (BType_Imm Bit64))));
                   BStmt_Assert
                     (BExp_unchanged_mem_interval_distinct Bit64 0
                        4294967295
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 32w))) 8);
                   BStmt_Assign (BVar "MEM" (BType_Mem Bit64 Bit8))
                     (BExp_Store
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 32w))) BEnd_LittleEndian
                        (BExp_Den (BVar "R1" (BType_Imm Bit64))))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203856w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203856w)
                    "F9000FA2 (str x2, [x29,#24])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R29" (BType_Imm Bit64))));
                   BStmt_Assert
                     (BExp_unchanged_mem_interval_distinct Bit64 0
                        4294967295
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 24w))) 8);
                   BStmt_Assign (BVar "MEM" (BType_Mem Bit64 Bit8))
                     (BExp_Store
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 24w))) BEnd_LittleEndian
                        (BExp_Den (BVar "R2" (BType_Imm Bit64))))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203860w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203860w)
                    "F9000BA3 (str x3, [x29,#16])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R29" (BType_Imm Bit64))));
                   BStmt_Assert
                     (BExp_unchanged_mem_interval_distinct Bit64 0
                        4294967295
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 16w))) 8);
                   BStmt_Assign (BVar "MEM" (BType_Mem Bit64 Bit8))
                     (BExp_Store
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 16w))) BEnd_LittleEndian
                        (BExp_Den (BVar "R3" (BType_Imm Bit64))))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203864w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203864w)
                    "B0001C40 (adrp x0, 78b000 <__FRAME_END__+0xfa58>)";
                bb_statements :=
                  [BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Const (Imm64 7909376w))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203868w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203868w)
                    "91394000 (add x0, x0, #0xe50)";
                bb_statements :=
                  [BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_BinExp BIExp_Plus
                        (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                        (BExp_Const (Imm64 3664w)))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203872w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203872w) "F9400001 (ldr x1, [x0])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R1" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                        BEnd_LittleEndian Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203876w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203876w)
                    "F90037A1 (str x1, [x29,#104])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R29" (BType_Imm Bit64))));
                   BStmt_Assert
                     (BExp_unchanged_mem_interval_distinct Bit64 0
                        4294967295
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 104w))) 8);
                   BStmt_Assign (BVar "MEM" (BType_Mem Bit64 Bit8))
                     (BExp_Store
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 104w))) BEnd_LittleEndian
                        (BExp_Den (BVar "R1" (BType_Imm Bit64))))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203880w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203880w)
                    "D2800001 (mov x1, #0x0                    // #0)";
                bb_statements :=
                  [BStmt_Assign (BVar "R1" (BType_Imm Bit64))
                     (BExp_Const (Imm64 0w))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203884w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203884w)
                    "F94013A0 (ldr x0, [x29,#32])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R29" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 32w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203888w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203888w)
                    "F10FA01F (cmp x0, #0x3e8)";
                bb_statements :=
                  [BStmt_Assign (BVar "ProcState_C" BType_Bool)
                     (BExp_nzcv_SUB_C
                        (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                        (BExp_Const (Imm64 1000w)));
                   BStmt_Assign (BVar "ProcState_N" BType_Bool)
                     (BExp_nzcv_SUB_N Bit64
                        (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                        (BExp_Const (Imm64 1000w)));
                   BStmt_Assign (BVar "ProcState_V" BType_Bool)
                     (BExp_nzcv_SUB_V Bit64
                        (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                        (BExp_Const (Imm64 1000w)));
                   BStmt_Assign (BVar "ProcState_Z" BType_Bool)
                     (BExp_nzcv_SUB_Z
                        (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                        (BExp_Const (Imm64 1000w)))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203892w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203892w)
                    "54000089 (b.ls 402584 <client+0x44>)";
                bb_statements := [];
                bb_last_statement :=
                  BStmt_CJmp
                    (BExp_BinExp BIExp_And
                       (BExp_Den (BVar "ProcState_C" BType_Bool))
                       (BExp_UnaryExp BIExp_Not
                          (BExp_Den (BVar "ProcState_Z" BType_Bool))))
                    (BLE_Label (BL_Address (Imm64 4203896w)))
                    (BLE_Label (BL_Address (Imm64 4203908w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203896w)
                    "B00015A0 (adrp x0, 6b7000 <_nl_unload_domain+0x38>)";
                bb_statements :=
                  [BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Const (Imm64 7041024w))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203900w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203900w)
                    "913C8000 (add x0, x0, #0xf20)";
                bb_statements :=
                  [BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_BinExp BIExp_Plus
                        (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                        (BExp_Const (Imm64 3872w)))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203904w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203904w)
                    "9400018B (bl 402bac <fail>)";
                bb_statements :=
                  [BStmt_Assign (BVar "R30" (BType_Imm Bit64))
                     (BExp_Const (Imm64 4203908w))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4205484w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203908w)
                    "F9400BA0 (ldr x0, [x29,#16])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R29" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 16w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203912w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203912w)
                    "F10FA01F (cmp x0, #0x3e8)";
                bb_statements :=
                  [BStmt_Assign (BVar "ProcState_C" BType_Bool)
                     (BExp_nzcv_SUB_C
                        (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                        (BExp_Const (Imm64 1000w)));
                   BStmt_Assign (BVar "ProcState_N" BType_Bool)
                     (BExp_nzcv_SUB_N Bit64
                        (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                        (BExp_Const (Imm64 1000w)));
                   BStmt_Assign (BVar "ProcState_V" BType_Bool)
                     (BExp_nzcv_SUB_V Bit64
                        (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                        (BExp_Const (Imm64 1000w)));
                   BStmt_Assign (BVar "ProcState_Z" BType_Bool)
                     (BExp_nzcv_SUB_Z
                        (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                        (BExp_Const (Imm64 1000w)))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203916w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203916w)
                    "54000089 (b.ls 402584 <client+0x44>)";
                bb_statements := [];
                bb_last_statement :=
                  BStmt_CJmp
                    (BExp_BinExp BIExp_And
                       (BExp_Den (BVar "ProcState_C" BType_Bool))
                       (BExp_UnaryExp BIExp_Not
                          (BExp_Den (BVar "ProcState_Z" BType_Bool))))
                    (BLE_Label (BL_Address (Imm64 4203920w)))
                    (BLE_Label (BL_Address (Imm64 4203932w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203920w)
                    "B00015A0 (adrp x0, 6b7000 <_nl_unload_domain+0x38>)";
                bb_statements :=
                  [BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Const (Imm64 7041024w))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203924w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203924w)
                    "913D0000 (add x0, x0, #0xf40)";
                bb_statements :=
                  [BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_BinExp BIExp_Plus
                        (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                        (BExp_Const (Imm64 3904w)))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203928w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203928w)
                    "94000185 (bl 402bac <fail>)";
                bb_statements :=
                  [BStmt_Assign (BVar "R30" (BType_Imm Bit64))
                     (BExp_Const (Imm64 4203932w))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4205484w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203932w)
                    "F94013A0 (ldr x0, [x29,#32])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R29" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 32w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203936w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203936w)
                    "91002400 (add x0, x0, #0x9)";
                bb_statements :=
                  [BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_BinExp BIExp_Plus
                        (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                        (BExp_Const (Imm64 9w)))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203940w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203940w)
                    "F90023A0 (str x0, [x29,#64])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R29" (BType_Imm Bit64))));
                   BStmt_Assert
                     (BExp_unchanged_mem_interval_distinct Bit64 0
                        4294967295
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 64w))) 8);
                   BStmt_Assign (BVar "MEM" (BType_Mem Bit64 Bit8))
                     (BExp_Store
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 64w))) BEnd_LittleEndian
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203944w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203944w)
                    "F94023A0 (ldr x0, [x29,#64])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R29" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 64w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203948w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203948w)
                    "91005000 (add x0, x0, #0x14)";
                bb_statements :=
                  [BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_BinExp BIExp_Plus
                        (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                        (BExp_Const (Imm64 20w)))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203952w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203952w)
                    "F9001FA0 (str x0, [x29,#56])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R29" (BType_Imm Bit64))));
                   BStmt_Assert
                     (BExp_unchanged_mem_interval_distinct Bit64 0
                        4294967295
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 56w))) 8);
                   BStmt_Assign (BVar "MEM" (BType_Mem Bit64 Bit8))
                     (BExp_Store
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 56w))) BEnd_LittleEndian
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203956w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203956w)
                    "F9401FA0 (ldr x0, [x29,#56])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R29" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 56w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203960w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203960w)
                    "94098DB2 (bl 665c80 <__libc_malloc>)";
                bb_statements :=
                  [BStmt_Assign (BVar "R30" (BType_Imm Bit64))
                     (BExp_Const (Imm64 4203964w))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 6708352w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203964w)
                    "F90027A0 (str x0, [x29,#72])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R29" (BType_Imm Bit64))));
                   BStmt_Assert
                     (BExp_unchanged_mem_interval_distinct Bit64 0
                        4294967295
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 72w))) 8);
                   BStmt_Assign (BVar "MEM" (BType_Mem Bit64 Bit8))
                     (BExp_Store
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 72w))) BEnd_LittleEndian
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203968w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203968w)
                    "F94027A0 (ldr x0, [x29,#72])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R29" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 72w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203972w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203972w)
                    "F9002BA0 (str x0, [x29,#80])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R29" (BType_Imm Bit64))));
                   BStmt_Assert
                     (BExp_unchanged_mem_interval_distinct Bit64 0
                        4294967295
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 80w))) 8);
                   BStmt_Assign (BVar "MEM" (BType_Mem Bit64 Bit8))
                     (BExp_Store
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 80w))) BEnd_LittleEndian
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203976w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203976w)
                    "F9402BA0 (ldr x0, [x29,#80])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R29" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 80w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203980w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203980w)
                    "F94013A1 (ldr x1, [x29,#32])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R29" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R1" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 32w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203984w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203984w) "F9000001 (str x1, [x0])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))));
                   BStmt_Assert
                     (BExp_unchanged_mem_interval_distinct Bit64 0
                        4294967295 (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                        8);
                   BStmt_Assign (BVar "MEM" (BType_Mem Bit64 Bit8))
                     (BExp_Store
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                        BEnd_LittleEndian
                        (BExp_Den (BVar "R1" (BType_Imm Bit64))))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203988w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203988w)
                    "F9402BA0 (ldr x0, [x29,#80])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R29" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 80w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203992w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203992w)
                    "91002000 (add x0, x0, #0x8)";
                bb_statements :=
                  [BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_BinExp BIExp_Plus
                        (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                        (BExp_Const (Imm64 8w)))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203996w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4203996w)
                    "F9002BA0 (str x0, [x29,#80])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R29" (BType_Imm Bit64))));
                   BStmt_Assert
                     (BExp_unchanged_mem_interval_distinct Bit64 0
                        4294967295
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 80w))) 8);
                   BStmt_Assign (BVar "MEM" (BType_Mem Bit64 Bit8))
                     (BExp_Store
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 80w))) BEnd_LittleEndian
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4204000w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4204000w)
                    "F9402BA0 (ldr x0, [x29,#80])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R29" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 80w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4204004w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4204004w)
                    "F9002FA0 (str x0, [x29,#88])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R29" (BType_Imm Bit64))));
                   BStmt_Assert
                     (BExp_unchanged_mem_interval_distinct Bit64 0
                        4294967295
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 88w))) 8);
                   BStmt_Assign (BVar "MEM" (BType_Mem Bit64 Bit8))
                     (BExp_Store
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 88w))) BEnd_LittleEndian
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4204008w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4204008w)
                    "F9402BA0 (ldr x0, [x29,#80])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R29" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 80w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4204012w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4204012w)
                    "91000401 (add x1, x0, #0x1)";
                bb_statements :=
                  [BStmt_Assign (BVar "R1" (BType_Imm Bit64))
                     (BExp_BinExp BIExp_Plus
                        (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                        (BExp_Const (Imm64 1w)))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4204016w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4204016w)
                    "F9002BA1 (str x1, [x29,#80])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R29" (BType_Imm Bit64))));
                   BStmt_Assert
                     (BExp_unchanged_mem_interval_distinct Bit64 0
                        4294967295
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 80w))) 8);
                   BStmt_Assign (BVar "MEM" (BType_Mem Bit64 Bit8))
                     (BExp_Store
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 80w))) BEnd_LittleEndian
                        (BExp_Den (BVar "R1" (BType_Imm Bit64))))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4204020w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4204020w)
                    "52800021 (mov w1, #0x1                    // #1)";
                bb_statements :=
                  [BStmt_Assign (BVar "R1" (BType_Imm Bit64))
                     (BExp_Const (Imm64 1w))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4204024w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4204024w) "39000001 (strb w1, [x0])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_unchanged_mem_interval_distinct Bit64 0
                        4294967295 (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                        1);
                   BStmt_Assign (BVar "MEM" (BType_Mem Bit64 Bit8))
                     (BExp_Store
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_Den (BVar "R0" (BType_Imm Bit64)))
                        BEnd_LittleEndian
                        (BExp_Cast BIExp_LowCast
                           (BExp_Den (BVar "R1" (BType_Imm Bit64))) Bit8))];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4204028w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4204028w)
                    "F94013A2 (ldr x2, [x29,#32])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R29" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R2" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 32w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4204032w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4204032w)
                    "F94017A1 (ldr x1, [x29,#40])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R29" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R1" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 40w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4204036w)))|>;
              <|bb_label :=
                  BL_Address_HC (Imm64 4204036w)
                    "F9402BA0 (ldr x0, [x29,#80])";
                bb_statements :=
                  [BStmt_Assert
                     (BExp_Aligned Bit64 3
                        (BExp_Den (BVar "R29" (BType_Imm Bit64))));
                   BStmt_Assign (BVar "R0" (BType_Imm Bit64))
                     (BExp_Load
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "R29" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 80w))) BEnd_LittleEndian
                        Bit64)];
                bb_last_statement :=
                BStmt_Jmp (BLE_Label (BL_Address (Imm64 4204040w)))|>;
	   ]``;

val bl_dict  = bir_block_collectionLib.gen_block_dict prog;
val prog_lbl_tms = bir_block_collectionLib.get_block_dict_keys bl_dict;
val prog_vars = bir_exec_typingLib.gen_vars_of_prog prog;
val n_dict = bir_cfgLib.cfg_build_node_dict bl_dict prog_lbl_tms;

val lbl_tm = ``BL_Address (Imm64 4203840w)``;

val stop_lbl_tms = [``BL_Address (Imm64 4204040w)``];
    
val syst = init_state lbl_tm prog_vars;

val pred_conjs = [``bir_exp_true``];
    
val syst = state_add_preds "init_pred" pred_conjs syst;

val cfb = false;    
val systs = bir_symbexec_stepLib.symb_exec_to_stop (abpfun cfb) n_dict bl_dict [syst] stop_lbl_tms [];

val b = listItems(SYST_get_env syst);
      listItems(SYST_get_pred (hd systs));
      val b = listItems(SYST_get_vals (List.nth (systs, 20)));

val syst = ((hd o rev) systs);
val payload_len = (“BVar "140_R2" (BType_Imm Bit64)”,
     SymbValBE
      (“BExp_Load (BExp_Den (BVar "137_MEM" (BType_Mem Bit64 Bit8)))
          (BExp_BinExp BIExp_Plus
             (BExp_Den (BVar "5_tmp_SP_EL0" (BType_Imm Bit64)))
             (BExp_Const (Imm64 32w))) BEnd_LittleEndian Bit64”,
       <Redblackset(38)>));

val assret = (“BVar "144_assert_true_cnd" BType_Bool”,
     SymbValBE
      (“BExp_BinPred BIExp_Equal
          (BExp_BinExp BIExp_And
             (BExp_Den (BVar "5_tmp_SP_EL0" (BType_Imm Bit64)))
             (BExp_Const (Imm64 7w))) (BExp_Const (Imm64 0w))”,
       <Redblackset(2)>));

val payload = (“BVar "143_R1" (BType_Imm Bit64)”,
     SymbValBE
      (“BExp_Load (BExp_Den (BVar "137_MEM" (BType_Mem Bit64 Bit8)))
          (BExp_BinExp BIExp_Plus
             (BExp_Den (BVar "5_tmp_SP_EL0" (BType_Imm Bit64)))
             (BExp_Const (Imm64 40w))) BEnd_LittleEndian Bit64”,
       <Redblackset(38)>));

val p = (“BVar "146_R0" (BType_Imm Bit64)”,
     SymbValBE
      (“BExp_Load (BExp_Den (BVar "137_MEM" (BType_Mem Bit64 Bit8)))
          (BExp_BinExp BIExp_Plus
             (BExp_Den (BVar "5_tmp_SP_EL0" (BType_Imm Bit64)))
             (BExp_Const (Imm64 80w))) BEnd_LittleEndian Bit64”,
       <Redblackset(38)>));

if is_BExp_Store exp then
        let
          val (expm, expad, endi, expv) = (dest_BExp_Store) exp;
          val endistr = endi_to_string endi;
        in
          (ef expm)@(ef expad)@(ef expv)
        end

val ef = bir_exp_nonstandards
(mk_BExp_Store (expm_rw, expad_rw, endi, expv_rw))
val (expm, expad, endi, sz) = (dest_BExp_Load) exp;
*)

val _ = Parse.type_abbrev("hmac", ``:bir_var_t list -> bir_exp_t``);

val _ = Parse.type_abbrev("enc", ``:bir_var_t list -> bir_var_t -> bir_exp_t``);

val _ = Parse.type_abbrev("dec", ``:bir_var_t list -> bir_exp_t``);

(* read int from file *)
fun readint_inputs filename =
    let
	val fullfilename = Path.mkAbsolute{path = filename,
                                        relativeTo = FileSys.getDir()};

        val ins = TextIO.openIn fullfilename;
	val _ = TextIO.inputN(ins,52);

    fun loop ins =

        case TextIO.scanStream(IntInf.scan StringCvt.DEC) ins of

    SOME int => int :: loop ins

    | NONE => []

          in
 loop ins before TextIO.closeIn ins

    end;
    
fun Fr var =
    let
	 val (bv_str, _) = bir_envSyntax.dest_BVar_string var;
	 val bv =  bir_envSyntax.mk_BVar_string (bv_str, bir_valuesSyntax.BType_Bool_tm);
    in
	bv
    end;

fun rev_Fr bv =
    let
	 val (bv_str, _) = bir_envSyntax.dest_BVar_string bv;
	 val var =  bir_envSyntax.mk_BVar_string (bv_str, “BType_Imm Bit64”);
    in
	var
    end;
		
fun encrypt inputs iv =
    let
	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
			(enc
			     (inputs)
			     (iv))``;

    in
	dest_BStmt_Assign stmt
    end;

fun decrypt inputs =
    let
	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
			(dec
			     (inputs))``;

    in
	dest_BStmt_Assign stmt
    end;

fun HMac inputs =
    let
	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
			(hmac
			     (inputs))``;

    in
	dest_BStmt_Assign stmt
    end;
fun symbval_bexp symbv =
    let
	val bexp =
	    case symbv of
		SymbValBE (exp,_) => exp
              | SymbValInterval ((exp1,exp2), _) => exp1 (* we need to fix it later*)
              | SymbValMem (exp, _, _, _) => exp (* we need to fix it later*)
	      | _ => raise ERR "symbval_bexp" "cannot handle symbolic value type";
    in
	bexp
    end;

fun update_symbval new_symbval Fr_bv syst =
    let
	val symbv' = SymbValBE (new_symbval,symbvalbe_dep_empty);
	val syst = insert_symbval Fr_bv symbv' syst;

    in
	syst
    end;
  
fun store_link bl_stmts syst =
    let
	val s_tm = (fst o listSyntax.dest_list) bl_stmts;
	val s_tm_0 = List.nth (s_tm, 0);
	val (bv, be) = dest_BStmt_Assign s_tm_0; (* extract bir expression *)
	val Fr_bv = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("R30", “BType_Imm Bit64”)); (* generate a fresh iv *)
	val syst =  update_envvar bv Fr_bv syst; (* update environment *)
	val syst = update_symbval be Fr_bv syst; (* update symbolic value *)
    in
	syst
    end;

fun update_pc syst =
    let
	val bv = ``BVar "R30" (BType_Imm Bit64)``;

	val symbv = get_state_symbv "symbv not found" bv syst;
  
	val be = symbval_bexp symbv; (* extract bir expression *) 

	val tgt = (mk_BL_Address o bir_expSyntax.dest_BExp_Const) be; (* make next address *)
	    
	val syst = SYST_update_pc tgt syst;(* update symb_state  with new pc *)

    in
	syst
    end;

fun update_path bv syst =
    let
	 val Fr_bv = Fr bv;
	 val syst = SYST_update_pred ((Fr_bv)::(SYST_get_pred syst)) syst;
    in
	syst
    end;

fun state_add_path bv_str pred syst =
    let
      val bv = bir_envSyntax.mk_BVar_string (bv_str, bir_valuesSyntax.BType_Bool_tm);
      val bv_fresh = get_bvar_fresh bv;
    in
      (SYST_update_pred ((bv_fresh)::(SYST_get_pred syst)) o
       update_symbval pred bv_fresh
      ) syst
    end;
    
fun update_lib_syst be Fr_bv syst =
    let
	
	val bv0 = ``BVar "R0" (BType_Imm Bit64)``;
		  
	val syst =  update_envvar bv0 Fr_bv syst; (* update environment *)  
	
	val syst = update_symbval be Fr_bv syst; (* update symbolic value *)
	
	val syst = state_add_path "T" be syst; (* update path condition *)

    in
	syst
    end;
    
fun compute_inputs n syst =
    let
	val Rn = ("R" ^ (IntInf.toString n));

	val be = bir_envSyntax.mk_BVar_string (Rn, ``BType_Imm Bit64``);
	    
	val be_r = (symbval_bexp o get_state_symbv " vals not found " be) syst;

	val n = n-1;
	val inputs = if (n < 0)
		     then []
		     else
			 be_r :: compute_inputs n syst;
    in
	inputs

    end;

fun add_knowledge bv syst =
    let
	val symbv = get_state_symbv "symbv not found" bv syst;
	    
	val be = symbval_bexp symbv;

	val syst = state_add_path "K" be syst;
    in
       syst
    end;
    
fun add_knowledges_to_adv n syst =
    let
	val Rn = ("R" ^ (IntInf.toString n));
	val be = mk_BVar_string (Rn, ``BType_Imm Bit64``);
	    
	val syst = add_knowledge be syst;

	val n = n-1;
	val syst = if (n < 0)
		     then syst
		     else
			 add_knowledges_to_adv n syst;
    in
	syst

    end;  

fun Adv av syst =
    let
	val n = List.nth (readint_inputs "Adversary-number of inputs", 0);

	val syst =  add_knowledges_to_adv (n-1) syst;

	val syst =  update_envvar ``BVar "R0" (BType_Imm Bit64)`` av syst; (* update environment *) 

	val Fn_av = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("a", “BType_Imm Bit64”)); (* generate a fresh name *)

	val syst = update_symbval Fn_av av syst; (* update symbolic value *)

	val syst = update_path av syst; (* update path condition *)	    
    in
	syst
    end;
        
fun new_key syst =
    let

	val vn = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Key", “BType_Imm Bit64”)); (* generate a fresh variable *)	    	
	
	val syst = update_path vn syst; (* update path condition *)

	val Fn_vn = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("k", “BType_Imm Bit64”)); (* generate a fresh name *)
	    
	val syst = update_lib_syst Fn_vn vn syst; (* update syst *)
	    
    in
	syst
    end;   

fun Encryption syst =
    let
	
	val n = List.nth (readint_inputs "Library-number of inputs", 0);
	val inputs = compute_inputs (n-2) syst; (* get values *)
	    
	val iv = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("iv", “BType_Imm Bit64”)); (* generate a fresh iv *)
	
	val syst = update_path iv syst; (* update path condition *)  

	val (C_bv, C_be) = encrypt inputs iv; (* encrypt with iv *)

	val Fr_Enc = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Enc", “BType_Imm Bit64”)); (* generate a fresh variable *)

	val stmt = ``BStmt_Assign (Fr_Enc) (C_bv)``; (* assign value of R0 to the fresh variable *)
	
	val syst = update_lib_syst C_be Fr_Enc syst; (* update syst *)
	
    in
	syst
    end;
 
fun Decryption syst =
    let
	
	val n = List.nth (readint_inputs "Library-number of inputs", 0);
	val inputs = compute_inputs (n-1) syst; (* get values *)

	val (M_bv, M_be) = decrypt inputs; (* decrypt with iv *)

	val Fr_Dec = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Dec", “BType_Imm Bit64”)); (* generate a fresh variable *)

	val stmt = ``BStmt_Assign (Fr_Dec) (M_bv)``; (* assign value of R0 to the fresh variable *)
	    
	val syst = update_lib_syst M_be Fr_Dec syst; (* update syst *)
	    		    
    in
	syst
    end;

fun HMAC syst =
    let
	val n = List.nth (readint_inputs "Library-number of inputs", 0);

	val syst = new_key syst;
	    
	val inputs = compute_inputs (n-1) syst; (* get values *)
	
	val (M_bv, M_be) = HMac inputs; (* decrypt with iv *)

	val Fr_Hmac = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("HMAC", “BType_Imm Bit64”)); (* generate a fresh variable *)

	val stmt = ``BStmt_Assign (Fr_Hmac) (M_bv)``; (* assign value of R0 to the fresh variable *)
	    
	val syst = update_lib_syst M_be Fr_Hmac syst; (* update syst *)
	    		    
    in
	syst
    end;


fun check_length syst =
    let
	val be_r2 = (symbval_bexp o get_state_symbv " New_memcpy::vals not found " “BVar "R0" (BType_Imm Bit64)”) syst;

	val (expm, expad, endi, sz) = (dest_BExp_Load) be_r2;

	val assert_cnd = mk_BExp_BinPred (``BIExp_NotEqual``, expad,``BExp_Const (Imm64 0w)``);

	val systs1 = ((I) o state_add_path "assert_true_cnd" assert_cnd) syst;
	val systs2 = ((SYST_update_status BST_AssumptionViolated_tm) o state_add_path "assert_false_cnd" (bslSyntax.bnot assert_cnd)) syst;
    in
        [systs1]@[systs2]
    end;



fun copy_to_mem syst =
    let
	
	val bv_mem = find_bv_val ("New_memcpy::bv in env not found") (SYST_get_env syst) “BVar "MEM" (BType_Mem Bit64 Bit8)”;
		    
	val bv_r1 = find_bv_val ("New_memcpy::bv in env not found") (SYST_get_env syst) “BVar "R1" (BType_Imm Bit64)”;

	val be_r0 = (symbval_bexp o get_state_symbv " New_memcpy::vals not found " “BVar "R0" (BType_Imm Bit64)”) syst;

	val (expm, expad, endi, sz) = (dest_BExp_Load) be_r0;
	    
	val be = (mk_BExp_Store (mk_BExp_Den(bv_mem), expad, endi, mk_BExp_Den(bv_r1)));

	val Fr_mem = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("MEM", “BType_Mem Bit64 Bit8”));

	val syst =  update_envvar “BVar "MEM" (BType_Mem Bit64 Bit8)” Fr_mem syst; (* update environment *)  
	
	val syst = update_symbval be Fr_mem syst; (* update symbolic value *)
    in
	syst
    end;


fun New_memcpy syst =
    let
	val systs = check_length syst;

	val systs = (List.map (fn x => copy_to_mem x) systs);
    in
	systs
    end;
    
    
end(*local*)

end (* struct *)

