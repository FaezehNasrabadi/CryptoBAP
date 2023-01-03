structure imlLib =
struct

local
    open HolKernel Parse boolLib bossLib;
    open bitstringSyntax stringSyntax;
    open listSyntax boolSyntax;
    open String;
    open List;
    open TextIO;
    val ERR = Feedback.mk_HOL_ERR "imlLib";
in 

(* IML terms *)
datatype ITerm =
	 N     of int
       | Len   of (bool list)	     
       | Val   of (ITerm);


(* IML expressions *)
datatype IExp =
	 Var       of string
       | BS        of (bool list)
       | Ops       of (IExp list)	     
       | Enc_BS    of (bool list)
       | Sub_BS    of (string * int)
       | Concat    of (IExp * IExp);	       

(* IML statements *)
datatype IML_Stmt =
	 I_In       of (string list)
       | I_True     of (IExp)
       | I_False    of (unit)
       | I_Out      of (IExp list)
       | I_New      of (string * ITerm)
       | I_Event    of (string)
       | I_Rep      of (string)
       | I_Let      of (string * IExp);  

fun ITerm_to_string (N t)    = (int_to_string t)
  | ITerm_to_string (Len bs) = ((binstring_of_term o bitstring_of_bitlist) bs)
  | ITerm_to_string (Val t)  = (ITerm_to_string t);

fun IExp_to_string (Var s)           = s
  | IExp_to_string (BS bs)           = ((binstring_of_term o bitstring_of_bitlist) bs)
  | IExp_to_string (Ops es)          = ((IExp_to_string (hd es))^(List.foldr (fn (x,s) => s ^"("^ (IExp_to_string x) ^ ")") "(" (tl es)) ^ ")")	   
  | IExp_to_string (Enc_BS bs)       = ((binstring_of_term o bitstring_of_bitlist) bs)
  | IExp_to_string (Sub_BS (s, _))   = s 
  | IExp_to_string (Concat (s1, s2)) = ((IExp_to_string s1)^(IExp_to_string s2));     

fun to_string (I_In [v])        = "in c, " ^ v ^ " \n"
  | to_string (I_In vs)         = (List.foldr (fn (x,s) => s ^ ", " ^ "in c, " ^ x ^ " \n") "" (vs))
  | to_string (I_True e)        = "if " ^ (IExp_to_string (e)) ^ " then\n"
  | to_string (I_False ())      = "else\n"
  | to_string (I_Out [e])       = "out c, " ^ (IExp_to_string (e)) ^ " \n"
  | to_string (I_Out es)        = "out c, " ^ ((IExp_to_string (hd es))^(List.foldr (fn (x,s) => s ^"("^ (IExp_to_string x) ^ ")") "(" (tl es)) ^ ")") ^ " \n"
  | to_string (I_New (v, t))    = "new " ^ v ^ " fixed_" ^ (ITerm_to_string t) ^ " \n"
  | to_string (I_Event v)       = "event " ^ v ^ " \n"
  | to_string (I_Rep v)         = "!" ^ v ^ "(\n"
  | to_string (I_Let (v, e))    = "let " ^ v ^ " = " ^ (IExp_to_string e) ^ " in\n";

(* write IML into a file *)
fun IML_to_file str =
    let
	val IFile = TextIO.openAppend "IML_Translation.txt";
	    
    in
	(TextIO.output (IFile, str); TextIO.flushOut IFile)
    end;

end (* local *)
end (* struct *)
