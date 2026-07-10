## CryptoBAP: Symbolic Parallel Composition for Verification of Multi-language Protocol Implementations

This repository contains the implementation of our framework. It incorporates a diverse set of features. Here is a brief overview of the repository's contents: 

- **Composition of Symbolic Labeled Transition Systems:**
	- Developing the composition of symbolic labeled transition systems, incorporating it with several deduction combiners to handle diverse scenarios, and showing the correctness of our symbolic composition. Refer to [deduction](HolBA/src/tools/parallelcomposition/deduction) for the composition w.r.t. symbolic labeled transition's deduction relations, [combinededuction](HolBA/src/tools/parallelcomposition/combinededuction) for the composition involving several combined deduction relations in addition to symbolic labeled transition's deduction relations, and [generaldeduction](HolBA/src/tools/parallelcomposition/generaldeduction) for the composition containing a general combined deduction relation extra to symbolic labeled transition's deduction relations.

- **CSP-Style Parallel Composition:**
	- Enabling the parallel composition of concrete labeled transition systems using a CSP-style approach and proving theories surrounding it (see [concrete](HolBA/src/tools/parallelcomposition/concrete)).

- **Refinement:**
	- Linking the analysis of symbolic system semantics to concrete system semantics using an additional theorem, set in [refinement](HolBA/src/tools/parallelcomposition/refinement).
   
- **Sapic Model:**

	- Formalizing the syntax and semantics of an applied pi-calculus model, [Sapic](HolBA/src/tools/parallelcomposition/sapic), which encompasses both the syntax and semantics of Dolev-Yao attacker and library models.	
	
- **Composition and Decomposition of Dolev-Yao Libraries:**

	- Establishing theorems for composing and decomposing Dolev-Yao libraries, located in [DYLib](HolBA/src/tools/parallelcomposition/DYLib). 
	
- **Framework Instantiation:**

	- Applying the framework to [BIR](HolBA/src/theory/bir) (binary intermediate representation of ARMv8 and RISC-V machine code) and Sapic. In the [instantiations](HolBA/src/tools/parallelcomposition/instantiations) folder, we demonstrate how the paper’s theorems combine to achieve an end-to-end correctness result. We have assigned specific files with descriptive names to their mechanized proofs in HOL4 for each trace equivalence and trace inclusion step we have proven.
	
- **Symbolic Execution:**

	- [PreProcess](HolBA/src/tools/symbexec/examples/PreProcess) comprises source codes responsible for finding addresses of function calls, entry and exit points for loops of the BIR program before symbolic execution. [libload](HolBA/src/tools/symbexec/examples/libload) encompasses the source codes of our symbolic execution, and [symbexecbin](HolBA/src/tools/symbexecbin) includes the binary of the analyzed protocols and files needed to generate their BIR programs. 

- **Symbolic Execution Tree Translation:**

	- Demonstrating the translation of the symbolic execution tree of the BIR program into the Sapic model and proving this translation is correct, placed in [translateTosapic](HolBA/src/tools/parallelcomposition/translateTosapic).

- **Verification Examples:**

	- Providing verification examples for ARMv8 machine code of TinySSH and WireGuard. The [examples](HolBA/src/tools/parallelcomposition/examples) include necessary files for extracting the Sapic model of each protocol party along with the results from executing the extracted model with Sapic toolchain.
		
## How to setup and compile


1. Establish the HolBA framework using the guidelines provided in [HolBA-README.md](HolBA/README.md). No need to clone HolBA separately; we have provided a version compatible with our framework in our repository.

2. To validate our claims, navigate to each directory mentioned above and execute the `Holmake` command. You should observe that each theory file is generated smoothly without any errors or cheats.

3. **(optional step)** Generate BIR programs for the analyzed protocol binaries by executing `Holmake` in the [symbexecbin](HolBA/src/tools/symbexecbin) directory (the BIR programs are stored in ***\*Theory.sig*** files in this directory), or they will be created automatically the first time you run an example.

4. Execute the `make src/tools/parallelcomposition/examples/subdirectory/your-chosen-example.sml_run` command for your chosen example when you are in [HolBA](HolBA) directory. The extracted model will be stored in the ***Sapic_Translation.txt*** file in the corresponding example subdirectory. Make sure to specify the cryptographic primitives's assumptions and security properties in the extracted model before verifying it with the Sapic toolchain. For detailed guidance on this process and to view the results we obtained from the Sapic toolchain backends, refer to [Sapic-Results](HolBA/src/tools/parallelcomposition/examples/Sapic-Results).


## Running example

The running example is ready for the execution and showcase our core functionality with predefined inputs, files, and expected outputs. We will now explain this example to serve as a guide for users who wish to establish their own examples based on the provided foundation. For this purpose, we contemplate the implementation of Example 4 as outlined in our paper.

1. Begin by placing the binary implementation file (***xor.da***) for the Example 4 in the [symbexecbin](HolBA/src/tools/symbexecbin) directory.

2. Configure the binary files and code fragments you want to transpile to BIR as inputs in the [script file](HolBA/src/tools/symbexecbin/XORexampleScript.sml)dedicated to the simple XOR example. If you want to lift the entire binary file to a BIR program, skip specifying code fragments and use `read_disassembly_file_regions` function instead of `read_disassembly_file_regions_filter` function.
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

3. Specify the entry and exit addresses of the program-under-verification in the [Combination-XOR](HolBA/src/tools/parallelcomposition/examples/XOR/Combination-XOR.sml) file, as outlined below:

```
val lbl_tm = ``BL_Address (Imm64 60w)``;

val stop_lbl_tms = [``BL_Address (Imm64 132w)``]; 
```

4. And then, run the following command:

	- `make src/tools/parallelcomposition/examples/XOR/Combination-XOR.sml_run`

5. Subsequently, you can locate the extracted Sapic model in the ***Sapic_Translation.txt*** file within the [XOR](HolBA/src/tools/parallelcomposition/examples/XOR) directory.

## Parallels virtual machine

Additionally, we have configured a <a href="https://drive.google.com/file/d/1pfIMxeycFnpM4OOR26Eyu08p5VcJwVrt/view?usp=sharing">Parallels virtual machine</a> with preinstalled dependencies to facilitate the exploration of our framework. The virtual machine's password is ***symbparlcomp***, and our framework is located in the **/home/SymbolicParallelComposition** directory.

## Docker image

Alternatively, we also provide a <a href="https://hub.docker.com/r/viktoria2525/holba">Docker image</a>.
