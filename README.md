# CryptoBAP

This is an implementation of our CryptoBAP toolchain.
This implementation includes 
- The crypto-aware symbolic execution engine on top of the proof-producing platform named HolBA
- The extension of HolBA with the syntax of intermediate model language (IML)
- The translation of the symbolic tree into the IML
- The modification of the Csec-modex toolchain for getting IML files as inputs


Folders and organization
========================

Our toolchain includes the following:

<h5>HolBA/src/tools/symbexec/examples/binaries/balrob/</h5>
A directory contains the source code of the protocols we analysed: simple mac, simple xor, RPC, RPC-enc, NSL, CSur, TinySSH and WireGuard at ARMv8 binary code.<br/>
<h5>HolBA/src/tools/symbexec/examples/PreProcess/</h5>
A directory consists of the source codes for preprocessing the BIR program before executing by our symbolic execution, e.g., finding addresses of function calls, entry and exit to/from loops.<br/>
<h5>HolBA/src/tools/symbexec/examples/IML/</h5>
A directory includes the intermediate model language (IML) syntax implemented on top of the theorem prover HOL4.<br/>
<h5>HolBA/src/tools/symbexec/examples/libload/</h5>
A directory contains the source codes of our crypto-aware symbolic execution.<br/>
<h5>HolBA/src/tools/symbexec/examples/Tests/</h5>
A directory includes extracted IML models and the input files for each of our use-cases, such as :<br/>
<ul>
<li> The function names used in the protocol implementation</li>
<li> The names of cryptographic functions used in the protocol implementation</li>
<li> The name of functions used for network communications in the protocol implementation and we anoint them adversary function names</li>
<li> The number of entries for cryptographic functions used in the protocol implementation</li>
<li> The number of entries for adversary functions used in the protocol implementation</li>
<li> The name of events we release during the execution of the protocol</li>
</ul>
<h5>Csec-modex/src/symtrace/</h5>
A directory contains the source code of the Csec-modex verification toolchain, which we modified to start the analysis from IML.<br/>
<h5>Csec-modex/mk/</h5>
A directory includes the make files of the Csec-modex verification toolchain, which we modified to start from IML.<br/>
<h5>Csec-modex/tests/</h5>
A directory includes subdirectories that start the analysis of our use cases from IML input files. These subdirectories contain CryptoVerif and ProVerif template files which include :<br/>
<ul>
<li> The cryptographic assumptions used by the protocol implementation</li>
<li> The process which generates shared cryptographic material and breeds the protocol participants</li>
<li> Queries for the property that the protocol implementation attempt to satisfy</li>
</ul>

How to setup and compile
========================
## HolBA
1. Set up HolBA framework using ***HolBA/README.md***<br/>
2. Specify which binary file and which blocks inside it you want to transpile into the binary intermediate representation (BIR) in ***HolBA/src/tools/symbexec/examples/binaries/balrob/binariesBalrobDefsLib.sm***<br/>
3. In order to generate a BIR program of your specified binary file execute the following lines :<br/>
    - `source env.sh` when you are in ***HolBA/*** directory<br/>
    - `Holmake` when you are in ***HolBA/src/tools/symbexec/examples/***<br/>

You can find the BIR program stored in ***binariesTheory.sig*** file in ***HolBA/src/tools/symbexec/examples/binaries/balrob/*** directory<br/>

4. Now you can go to ***HolBA/*** directory and verify your desired use-case with the following command :<br/>
    - `make src/tools/symbexec/examples/Tests/subdirectory/your-desired-use-case.sml_run`

5. You can find the IML result in ***IML_Translation.txt*** file in subdirectory of the ***HolBA/src/tools/symbexec/examples/Tests/*** directory<br/>


## Csec-modex
1. Set up Csec-modex verification toolchain using ***Csec-modex/README.markdown***<br/>
2. Place your derived IML file in the related subdirectory in ***Csec-modex/tests/***<br/>
3. Run verification via the following command : <br/>
     - `make -f Makefile.csec` when you are in the related subdirectory in ***Csec-modex/tests/***<br/>

Running example
==============
Consider a client-side of the implementation of simple XOR as described in [1].<br/>

The ***client_xor.da***, ***client_xor.da.plus***, and ***client_xor.mem*** are the implementation of client-side of simple XOR at ARMv8 binary in ***HolBA/src/tools/symbexec/examples/binaries/balrob/*** directory.<br/>

We configure these files as input files at ARMv8 binary in ***HolBA/src/tools/symbexec/examples/binaries/balrob/binariesBalrobDefsLib.sml*** file as follows:<br/>

```
val configs              = [ ("client", 
                           ("client_xor.da", "balrob/client_xor.da.plus", "balrob/client_xor.mem"),
                           "client_THM",
                           ((Arbnum.fromInt 0x00000000, Arbnum.fromInt 0xffffffff),
                            (Arbnum.fromInt 0x10000000, Arbnum.fromInt (0x00000018 + 0x30d)),
                            (Arbnum.fromInt 0x10001000, Arbnum.fromInt 0x00000ff0))
			     ) ];
```

And we specify blocks inside these files we want to transpile to BIR like :<br/>

```
val symbs_sec_text = [
    "__libc_malloc",
    "memcpy",
    "otp",
    "xor",
    "socket_connect",
    "send",
    "RAND_bytes",
    "client",
    "main"
];
```

The BIR program is stored in ***binariesTheory.sig*** file in ***HolBA/src/tools/symbexec/examples/binaries/balrob/*** directory and it contains BIR blocks like as follow : <br/>

```
		...
		bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4203720w)))|>;
 <|bb_label :=
                  BL_Address_HC (Imm64 4203720w)
                    "9400014B (bl 4029f4 <xor>)";
                  bb_statements :=
                  [BStmt_Assign (BVar "R30" (BType_Imm Bit64))
                     (BExp_Const (Imm64 4203724w))];
                  bb_last_statement :=
                  BStmt_Jmp (BLE_Label (BL_Address (Imm64 4205044w)))|>;
<|bb_label :=
                  BL_Address_HC (Imm64 4203724w)
                    "F94017A0 (ldr x0, [x29,#40])";
                    ...
```                  

We set the entry and exit points of the derived BIR program in ***HolBA/src/tools/symbexec/examples/Tests/XOR/Combination-XOR.sml*** as follows : <br/>

```
val lbl_tm = ``BL_Address (Imm64 4203632w)``;

val stop_lbl_tms = [``BL_Address (Imm64 4203756w)``];
```

And we run the following command when we are in ***HolBA/*** directory : <br/>
- `make src/tools/symbexec/examples/Tests/XOR/Combination-XOR.sml_run` <br/>

The result of translating our symbolic execution tree into IML is as follows :<br/>

```
new OTP_48 fixed_64 
let Conc1_66 = conc1(OTP_48) in
let XOR_70 = exclusive_or(Conc1_66,pad) in
out c, XOR_70 
```


## References
<a id="1">[1]</a> 
Aizatulin, Mihhail, Andrew D. Gordon, and Jan Jürjens. "Computational verification of C protocol implementations by symbolic execution." Proceedings of the 2012 ACM conference on Computer and communications security. 2012.