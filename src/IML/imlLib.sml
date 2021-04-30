structure imlLib =
struct

open HolKernel Parse boolLib bossLib;
open bitstringSyntax stringSyntax;
open listSyntax boolSyntax String;
open List;
val ERR = Feedback.mk_HOL_ERR "imlLib";
     
 
datatype ITerm =
	 N     of int
       | Len   of (bool list)	     
       | Val   of (ITerm);


datatype IExp =
	 Var       of string
       | BS        of (bool list)
       | Ops       of (IExp list)	     
       | Enc_BS    of (bool list)
       | Sub_BS    of (string * int)
       | Concat    of (string * string);	       

datatype IML_Stmt =
	 I_In       of (string list)
       | I_True     of (IExp)
       | I_False    of (unit)
       | I_Out      of (IExp list)
       | I_New      of (string * ITerm)
       | I_Event    of (string);  

fun ITerm_to_string (N t)    = (int_to_string t)
  | ITerm_to_string (Len bs) = ((binstring_of_term o bitstring_of_bitlist) bs)
  | ITerm_to_string (Val t)  = (ITerm_to_string t);

fun IExp_to_string (Var s)           = s
  | IExp_to_string (BS bs)           = ((binstring_of_term o bitstring_of_bitlist) bs)
  | IExp_to_string (Ops es)          = ((List.foldr (fn (x,s) => s ^ ", " ^ (IExp_to_string x)) "" (es)))	   
  | IExp_to_string (Enc_BS bs)       = ((binstring_of_term o bitstring_of_bitlist) bs)
  | IExp_to_string (Sub_BS (s, _))   = s 
  | IExp_to_string (Concat (s1, s2)) = (s1^s2);     

    
fun to_string (I_In [v])        = (print ("in(c, " ^ v ^ ");\n" ))
  | to_string (I_In vs)         = (print ((List.foldr (fn (x,s) => s ^ ", " ^ "in(c, " ^ x ^ ");\n") "" (vs))))
  | to_string (I_True e)        = (print ("if " ^ (IExp_to_string (e)) ^ " then\n"))
  | to_string (I_False ())       = (print ("else "))
  | to_string (I_Out [e])       = (print ("out(c, " ^ (IExp_to_string (e)) ^ ");\n"))
  | to_string (I_Out es)        = (print ("out(c, (" ^ (List.foldr (fn (x,s) => s ^ ", " ^ (IExp_to_string x)) "" (es)) ^ "));\n"))
  | to_string (I_New (v, t))    = (print ("new " ^ v ^ ": " ^ (ITerm_to_string t) ^ ";\n"))
  | to_string (I_Event v) = (print ("event (" ^ v ^ ");\n"));

(*
fun map_children (I_In _) = []
  | map_children (I_Out es) = (List.map (fn x => (x)) (es))
  | map_children (I_New _) = [];


fun iter_children t = (map_children t);


fun exists_children t =
    let
	val results = (map_children t);
    in
	(List.exists (fn x => (true) orelse (false)) (results))
    end;

fun IExp_descend (Var s) = (Var s)
  | IExp_descend (BS bs) = (BS bs)
  | IExp_descend (Ops es) = (Ops es)
  | IExp_descend (Enc_BS bs) = (Enc_BS bs)
  | IExp_descend (Sub_BS (s, l)) = (Sub_BS (s, l))
  | IExp_descend (Concat (s1, s2)) = (Concat (s1, s2));
    
fun descend (I_In vs) = (I_In vs)
  | descend (I_Out es) = (I_Out (List.map (fn x => (x)) (es)))
  | descend (I_New (v, t)) = (I_New (v, t));  

fun subset vs es t = (descend (I_Out (List.map (fn x => (IExp_descend (Sub_BS (vs, es)))) (t))));
    
fun vars s = (map_children (I_Out (List.map (fn x => (Var x)) ([s]))));  

type iml = IML_Stmt list;

fun iml_descend (p : iml) = (List.map (fn x => (descend (x))) (p));

fun iml_iter (p : iml) = (List.map (fn x => (iter_children (x))) (p));     

fun iml_vars (p : iml) (s : string) = (List.map (fn x => (I_Out (vars s))) (p));

fun iml_to_string (p : iml) = (List.map (fn x => (to_string (x))) (p));   

fun iml_subset vs vs' p = (List.map (fn y => (subset vs y p)) (vs'));     
*)

end (* struct *)
