structure sapic_to_fileLib =
struct

local

    open HolKernel Parse
    open sapicplusTheory;
    open sapicplusSyntax;
    open messagesTheory;
    open messagesSyntax;
    open optionSyntax;
	 
    val ERR = mk_HOL_ERR "sapic_to_fileLib";
    val wrap_exn = Feedback.wrap_exn "sapic_to_fileLib";
	
in(*local*)

(* print Name

val N = “Name FreshName "49_OTP"”*)
fun name_to_string N =
    let
	val (tag,str) = dest_Name N;
    in
	if (is_FreshName tag)
	then ("~" ^ (stringSyntax.fromHOLstring str))
	else if (is_PubName tag)
	then ("'"  ^ (stringSyntax.fromHOLstring str) ^ "'")
	else if (is_NodeName tag)
	then ("#" ^ (stringSyntax.fromHOLstring str))
	else raise ERR "name_to_string" ("Don't know Sapic Name: " ^ (term_to_string N))
    end;

(* print Var

val V = “Var "1_X" 0”;*)		 
fun var_to_string V =
    let
	val (str,id) = dest_Var V;
    in
	(stringSyntax.fromHOLstring str)
    end;

(* print Term

val trm = “FAPP ("conc",2,Public,Constructor) [TVar (Var "1_OTP" 0);TVar (Var "2_OTP" 0)]”;*)	
fun sapicterm_to_string trm =
    if (is_TVar trm)
    then ((var_to_string o dest_TVar) trm)
    else if (is_Con trm)
    then ((name_to_string  o dest_Con) trm)
    else if (is_FAPP trm)
    then
	let
	    val (fun_sig,fun_vals) = dest_FAPP trm;
	    val (trm_list,_) = listSyntax.dest_list fun_vals;
	    val name = (stringSyntax.fromHOLstring o hd o pairSyntax.strip_pair) fun_sig;
	in
	    (name ^ "(" ^ ((sapicterm_to_string (hd trm_list))^(List.foldr (fn (x,s) => s ^","^ (sapicterm_to_string x)) "" (tl trm_list)) ^ ")"))	   
	end	
    else raise ERR "term_to_string" ("Don't know Sapic Term: " ^ (term_to_string trm))

	       
(* print FactTag

val fctTag = “TermFact”;*)	
fun factTag_to_string fctTag =
    if (is_KUFact fctTag) then "KU"
    else if (is_KDFact fctTag) then "KD"
    else if (is_DedFact fctTag) then "Ded"
    else if (is_InFact fctTag) then "In"
    else if (is_OutFact fctTag) then "Out"
    else if (is_FreshFact fctTag) then  "Fr"
    else if (is_TermFact fctTag) then "Term"
    else raise ERR "factTag_to_string" ("Don't know Sapic Fact: " ^ (term_to_string fctTag))
	       
(* print Fact

val fct = “Fact TermFact [TVar (Var "1_OTP" 0);TVar (Var "2_OTP" 0)]”;*)	
fun fact_to_string fct =
    let
	    val (tag,fct_vals) = dest_Fact fct;
	    val (trm_list,_) = listSyntax.dest_list fct_vals;
    in
	if (is_TermFact tag)
	then ((sapicterm_to_string (hd trm_list))^(List.foldr (fn (x,s) => s ^","^ (sapicterm_to_string x)) "" (tl trm_list)))
	else ((factTag_to_string tag) ^ "(" ^ ((sapicterm_to_string (hd trm_list))^(List.foldr (fn (x,s) => s ^","^ (sapicterm_to_string x)) "" (tl trm_list)) ^ ")"))	     
    end	
   
(* print Action

val act = “ChIn (SOME (TVar (Var "C" 0))) (TVar (Var "OTP" 0))”
val act = “New (Name FreshName "49_otp")”;*)
fun action_to_string act =
    if (is_New act) then "new "^((name_to_string o dest_New) act)
    else if (is_Rep act) then "!"
    else if (is_ChIn act) then
	let
	    val (c,t) = dest_ChIn act;
	in
	    if (is_some c) then "in(" ^ ((sapicterm_to_string o dest_some) c) ^ "," ^ (sapicterm_to_string t) ^ ")"
	    else "in(" ^ (sapicterm_to_string t) ^ ")"
	end
    else if (is_ChOut act) then
	let
	    val (c,t) = dest_ChOut act;
	in
	    if (is_some c) then "out(" ^ ((sapicterm_to_string o dest_some) c) ^ "," ^ (sapicterm_to_string t) ^ ")"
	    else "out(" ^ (sapicterm_to_string t) ^ ")"
	end	    
    else if (is_Insert act)  then "insert " ^ ((sapicterm_to_string o fst o dest_Insert) act) ^ ","  ^ ((sapicterm_to_string o snd o dest_Insert) act)
    else if (is_Delete act)  then "delete " ^ ((sapicterm_to_string o dest_Delete) act)
    else if (is_Lock act)  then "lock "  ^ ((sapicterm_to_string o dest_Lock) act)
    else if (is_Unlock act)  then "unlock " ^ ((sapicterm_to_string o dest_Unlock) act)
    else if (is_Event act)  then "event " ^ ((fact_to_string o dest_Event) act)
    else raise ERR "action_to_string" ("Don't know Sapic Action: " ^ (term_to_string act))
	       
(* print Combinator

val comb = “Lookup (TVar (Var "C" 0)) (Var "OTP" 0)”
val comb = “ProcessCall "tst" [(TVar (Var "C" 0))]”;*)
fun combinator_to_string comb =
if (is_Parallel comb) then "|"
else if (is_NDC comb) then "+"
else if (is_Cond comb) then "if "^ ((sapicterm_to_string o dest_Cond) comb) ^ " then "
else if (is_CondEq comb) then "if "^ ((sapicterm_to_string o fst o dest_CondEq) comb) ^ "="  ^ ((sapicterm_to_string o snd o dest_CondEq) comb) ^ " then "
else if (is_Let comb) then "let "^ ((sapicterm_to_string o fst o dest_Let) comb) ^ "="  ^ ((sapicterm_to_string o snd o dest_Let) comb)^ " in "
else if (is_Lookup comb) then "lookup "^ ((sapicterm_to_string o fst o dest_Lookup) comb) ^ " as "  ^ ((var_to_string o snd o dest_Lookup) comb)^ " in "
else if (is_ProcessCall comb) then
    let
	val (s,vals) = dest_ProcessCall comb;
	val (trm_list,_) = listSyntax.dest_list vals;
    in
    ((stringSyntax.fromHOLstring s) ^ "(" ^ ((sapicterm_to_string (hd trm_list))^(List.foldr (fn (x,s) => s ^","^ (sapicterm_to_string x)) "" (tl trm_list)) ^ ")"))
    end
 else raise ERR "combinator_to_string" ("Don't know Sapic Combinator: " ^ (term_to_string comb))   


(* print Process

val pro = “ProcessNull”
val pro = “ProcessAction (New (Name FreshName "49_otp"))
      (ProcessComb
         (Let (TVar (Var "48_OTP" 0)) (Con (Name FreshName "49_otp")))
         (ProcessComb
            (Let (TVar (Var "66_Conc1" 0))
               (FAPP ("conc1",1,Public,Constructor) [TVar (Var "48_OTP" 0)]))
            (ProcessComb
               (Let (TVar (Var "70_XOR" 0))
                  (FAPP ("exclusive_or",2,Public,Constructor)
                     [TVar (Var "66_Conc1" 0); TVar (Var "69_pad" 0)]))
               (ProcessAction (ChOut NONE (TVar (Var "70_XOR" 0)))
                  ProcessNull) ProcessNull) ProcessNull) ProcessNull)”*)
fun process_to_string pro =
    if (is_ProcessNull pro) then "0"
    else if (is_ProcessComb pro)
    then
	let
	    val (c,pl,pr) = dest_ProcessComb pro;
	in
	    if (is_ProcessCall c)
	    then (combinator_to_string c)
		 else if ((is_Parallel c) orelse (is_NDC c))
		 then "("^(process_to_string pl)^")"^(combinator_to_string c)^"("^(process_to_string pr)^")"
		 else if (is_ProcessNull pr)
		 then (combinator_to_string c)^"\n"^(process_to_string pl)
		 else (combinator_to_string c)^"\n"^(process_to_string pl)^"\nelse "^(process_to_string pr)
	end		
    else if (is_ProcessAction pro)
    then
	let
	    val (a,p) = dest_ProcessAction pro;
	in
	    if (is_Rep a)
	    then (action_to_string a)^" "^(process_to_string p)
	    else if (is_ProcessNull p)
	    then (action_to_string a)
	    else (action_to_string a)^";\n"^(process_to_string p)
	end		    
    else raise ERR "process_to_string" ("Don't know Sapic Process: " ^ (term_to_string pro))


fun refine_process pro =
    if (is_ProcessNull pro) then pro
    else if (is_ProcessComb pro)
    then
	let
	    val (c,pl,pr) = dest_ProcessComb pro;
	    val refined_pl = refine_process pl;
            val refined_pr = refine_process pr;
	in
	    if ((is_ProcessNull refined_pl) andalso (is_ProcessNull refined_pr) andalso ((is_Let c) orelse (is_Lookup c) orelse (is_NDC c)))
	    then ProcessNull_tm
	    else if ((is_NDC c) andalso (is_ProcessNull refined_pr) andalso not(is_ProcessNull refined_pl))
	    then refined_pl
	    else if ((is_NDC c) andalso (is_ProcessNull refined_pl) andalso not(is_ProcessNull refined_pr))
	    then refined_pr
	    else mk_ProcessComb(c, refined_pl, refined_pr)
	end		
    else if (is_ProcessAction pro)
    then
	let
	    val (a,p) = dest_ProcessAction pro;
	    val refined_p = refine_process p;
	in
	    if ((is_ProcessNull refined_p) andalso ((is_New a) orelse (is_ChIn a)))
	    then ProcessNull_tm	 
	    else mk_ProcessAction(a,refined_p)
	end		    
    else raise ERR "refine_process" ("Don't know Sapic Process: " ^ (term_to_string pro))

	       

(* write Sapic into a file *)
fun write_sapic_to_file str =
    let
	val SFile = TextIO.openAppend "Sapic_Translation.txt";
	    
    in
	(TextIO.output (SFile, str); TextIO.flushOut SFile)
    end;	       

    
end(*local*)

end (* struct *)





