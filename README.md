## CryptoBAP: Symbolic Parallel Composition for Verification of Multi-language Protocol Implementations

This repository contains the implementation of our framework. It incorporates a diverse set of features. Here is a brief overview of the repository's contents: 

- **Composition of Symbolic Labeled Transition Systems:**
	- Developing the composition of symbolic labeled transition systems, incorporating it with several deduction combiners to handle diverse scenarios, and showing the correctness of our symbolic comp[...]

- **CSP-Style Parallel Composition:**
	- Enabling the parallel composition of concrete labeled transition systems using a CSP-style approach and proving theories surrounding it (see [link](https://github.com/FMSecure/CryptoBAP/tree/m[...]

- **Refinement:**
	- Linking the analysis of symbolic system semantics to concrete system semantics using an additional theorem, set in [link](https://github.com/FMSecure/CryptoBAP/blob/main/HolBA/src/tools/paral[...]
   
- **Sapic Model:**

	- Formalizing the syntax and semantics of an applied pi-calculus model, [Sapic](https://github.com/FMSecure/CryptoBAP/tree/main/HolBA/src/tools/parallelcomposition/sapic), which encomp[...]
	
- **Composition and Decomposition of Dolev-Yao Libraries:**

	- Establishing theorems for composing and decomposing Dolev-Yao libraries, located in [DYLib](https://github.com/FMSecure/CryptoBAP/tree/main/HolBA/src/tools/parallelcomposition/DYLib)[...]
	
- **Framework Instantiation:**

	- Applying the framework to [BIR](https://github.com/FMSecure/CryptoBAP/tree/main/HolBA/src/theory/bir) (binary intermediate representation of ARMv8 and RISC-V machine code) and Sapic.[...]
	
- **Symbolic Execution:**

	- [PreProcess](https://github.com/FMSecure/CryptoBAP/tree/main/HolBA/src/tools/symbexec/examples/PreProcess) comprises source codes responsible for finding addresses of function calls,[...]

- **Symbolic Execution Tree Translation:**

	- Demonstrating the translation of the symbolic execution tree of the BIR program into the Sapic model and proving this translation is correct, placed in [link](https://github.com/FMSecure/Cryp[...]

- **Verification Examples:**

	- Providing verification examples for ARMv8 machine code of TinySSH and WireGuard. The [examples](https://github.com/FMSecure/CryptoBAP/tree/main/HolBA/src/tools/parallelcomposition/examples)[...]
		
## How to setup and compile


1. Establish the HolBA framework using the guidelines provided in [HolBA-README.md](https://github.com/FMSecure/CryptoBAP/blob/main/HolBA/README.md). No need to clone HolBA separately; [...]

2. To validate our claims, navigate to each directory mentioned above and execute the `Holmake` command. You should observe that each theory file is generated smoothly without any errors or cheats[...]

3. **(optional step)** Generate BIR programs for the analyzed protocol binaries by executing `Holmake` in the [link](https://github.com/FMSecure/CryptoBAP/tree/main/HolBA/src/tools/symbexecbin) [...]

4. Execute the `make src/tools/parallelcomposition/examples/subdirectory/your-chosen-example.sml_run` command for your chosen example when you are in [link](https://github.com/FMSecure/CryptoBAP[...]


## Running example

The running example is ready for the execution and showcase our core functionality with predefined inputs, files, and expected outputs. We will now explain this example to serve as a guide for use[...]

1. Begin by placing the binary implementation file (***xor.da***) for the Example 4 in the [symbexecbin](https://github.com/FMSecure/CryptoBAP/tree/main/HolBA/src/tools/symbexecbin) dir[...]

2. Configure the binary files and code fragments you want to transpile to BIR as inputs in the [link](https://github.com/FMSecure/CryptoBAP/blob/main/HolBA/src/tools/symbexecbin/XORexampleScript[...]
In our running example, we provided the binary file and code fragments as follows:

```
val dafilename = "xor.da";
val symbs_sec_text = [
     "new_key",
     "senc",
     "send",
     "main"
  ];
```

3. Specify the entry and exit addresses of the program-under-verification in the [link](https://github.com/FMSecure/CryptoBAP/tree/main/HolBA/src/tools/parallelcomposition/examples/XOR/Combinati[...]

```
val lbl_tm = ``BL_Address (Imm64 60w)``;

val stop_lbl_tms = [``BL_Address (Imm64 132w)``]; 
```

4. And then, run the following command:

	- `make src/tools/parallelcomposition/examples/XOR/Combination-XOR.sml_run`

5. Subsequently, you can locate the extracted Sapic model in the ***Sapic_Translation.txt*** file within the [link](https://github.com/FMSecure/CryptoBAP/tree/main/HolBA/src/tools/parallelcompos[...]

## Parallels virtual machine

Additionally, we have configured a [Parallels virtual machine](https://drive.google.com/file/d/1pfIMxeycFnpM4OOR26Eyu08p5VcJwVrt/view?usp=sharing) with preinstalled dependencies to faci[...]

## Docker image

Alternatively, we also provide a [Docker image](https://hub.docker.com/r/viktoria2525/holba).

```
