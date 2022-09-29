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

**[HolBA/src/tools/symbexec/examples/binaries/balrob/](https://github.com/FaezehNasrabadi/CryptoBAP/tree/main/HolBA/src/tools/symbexec/examples/binaries/balrob)** : A directory contains the source code of the protocols we analysed: simple mac, simple xor, RPC, RPC-enc, NSL and TinySSH at ARMv8 binary code.<br/>
**[HolBA/src/tools/symbexec/examples/PreProcess/](https://github.com/FaezehNasrabadi/CryptoBAP/tree/main/HolBA/src/tools/symbexec/examples/PreProcess)** : A directory consists of the source codes for preprocessing the BIR program before executing by our symbolic execution.<br/>
**[HolBA/src/tools/symbexec/examples/IML/](https://github.com/FaezehNasrabadi/CryptoBAP/tree/main/HolBA/src/tools/symbexec/examples/IML)** : A directory includes the intermediate model language (IML) syntax implemented on top of the theorem prover HOL4.<br/>
**[HolBA/src/tools/symbexec/examples/libload/](https://github.com/FaezehNasrabadi/CryptoBAP/tree/main/HolBA/src/tools/symbexec/examples/libload)** : A directory contains the source codes of our crypto-aware symbolic execution.<br/>
**[HolBA/src/tools/symbexec/examples/Tests/](https://github.com/FaezehNasrabadi/CryptoBAP/tree/main/HolBA/src/tools/symbexec/examples/Tests)** : A directory includes the IML output and the input files for each of our use-cases, such as :<br/>
- The function names used in the protocol implementation<br/> 
- The names of cryptographic functions used in the protocol implementation<br/> 
- The name of functions used for network communications in the protocol implementation and we anoint them adversary function names<br/>
- The number of entries for cryptographic functions used in the protocol implementation<br/>
- The number of entries for adversary functions used in the protocol implementation<br/>
- The name of events we release during the execution of the protocol<br/>

**[Csec-modex/src/symtrace/](https://github.com/FaezehNasrabadi/CryptoBAP/tree/main/Csec-modex/src/symtrace)** :  A directory contains the source code of the Csec-modex verification toolchain, which we modified to start the analysis from IML.<br/>
**[Csec-modex/mk/](https://github.com/FaezehNasrabadi/CryptoBAP/tree/main/Csec-modex/mk)** :   A directory includes the make files of the Csec-modex verification toolchain, which we modified to start from IML.<br/>
**[Csec-modex/tests/](https://github.com/FaezehNasrabadi/CryptoBAP/tree/main/Csec-modex/tests)** : A directory includes subdirectories that start the analysis of our use cases from IML input files. These subdirectories contain CryptoVerif and ProVerif template files which include :<br/>
- The cryptographic assumptions used by the protocol implementation<br/>
- The process which generates shared cryptographic material and breeds the protocol participants<br/>
- Queries for the property that the protocol implementation attempt to satisfy<br/>

How to setup and compile
========================
## HolBA
1) Set up HolBA framework using [HolBA/README.md](https://github.com/FaezehNasrabadi/CryptoBAP/blob/main/HolBA/README.md)
2) Specify which binary file and which blocks inside it you want to transpile into the binary intermediate representation (BIR) in [HolBA/src/tools/symbexec/examples/binaries/balrob/binariesBalrobDefsLib.sml](https://github.com/FaezehNasrabadi/CryptoBAP/blob/main/HolBA/src/tools/symbexec/examples/binaries/balrob/binariesBalrobDefsLib.sml)
3) In order to generate a BIR program of your specified binary file execute the following lines :
	- source env.sh when you are in [HolBA/](https://github.com/FaezehNasrabadi/CryptoBAP/tree/main/HolBA) directory
	- Holmake when you are in [HolBA/src/tools/symbexec/examples/](https://github.com/FaezehNasrabadi/CryptoBAP/tree/main/HolBA/src/tools/symbexec/examples)

You can find the BIR program stored in binariesTheory.sig file in [HolBA/src/tools/symbexec/examples/binaries/balrob/](https://github.com/FaezehNasrabadi/CryptoBAP/tree/main/HolBA/src/tools/symbexec/examples/binaries/balrob) directory

4) Now you can go to [HolBA/](https://github.com/FaezehNasrabadi/CryptoBAP/tree/main/HolBA) directory and verify your desired use-case with the following command :
	- make src/tools/symbexec/examples/Tests/subdirectory/your-desired-use-case.sml_run

5) You can find the IML result in IML_Translation.txt file in subdirectory of the [HolBA/src/tools/symbexec/examples/Tests/](https://github.com/FaezehNasrabadi/CryptoBAP/tree/main/HolBA/src/tools/symbexec/examples/Tests) directory
