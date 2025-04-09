open HolKernel Parse boolLib bossLib;
open bagTheory;
open intSyntax stringSyntax;
open bir_immTheory wordsTheory;
open sum_numTheory;
open bitTheory;
open ASCIInumbersTheory;
open string_numTheory;
val _ = new_theory "messages";

    
(* Names *)
    
val _ = Datatype `NameTag_t = FreshName | PubName | NodeName`;    

val NameTag_ss = rewrites (type_rws ``:NameTag_t``);

val _ = Datatype `Name_t = Name NameTag_t string`;

val Name_ss = rewrites (type_rws ``:Name_t``);

val name_from_tag_str_def =
Define`
      name_from_tag_str tag str =
(case tag of
   FreshName => Name FreshName str
 | PubName   => Name PubName str
 | NodeName  => Name NodeName str
)`;

val const_name_from_str_def =
Define`
      const_name_from_str str = Name PubName str
                                     `;

(* Variables*)

val _ = Datatype `Var_t = Var string int`;
                          
val Var_ss = rewrites (type_rws ``:Var_t``);                           

(* Function symbols *)

val _ = Datatype `Privacy_t = Private | Public`;
    
val Privacy_ss = rewrites (type_rws ``:Privacy_t``);    

    
val _ = Datatype `Constructability_t = Constructor | Destructor`;

val Constructability_ss = rewrites (type_rws ``:Constructability_t``);

    
val _ = Parse.type_abbrev("Sig_t", ``:(string # (int # Privacy_t # Constructability_t))``);

(* Terms *)	      

val _ = Datatype `SapicTerm_t =
	      Con   Name_t
	    | TVar  Var_t
	    | FAPP  Sig_t (SapicTerm_t list)`;

val SapicTerm_ss = rewrites (type_rws ``:SapicTerm_t``);

(* helper *)  
val Inside_def =
Define`(Inside a (FAPP n ts) = MEM a ts)`;  

val TExist_def = Define`
                       (TExist t' (FAPP (n,(0,p,c)) ts) <=> F) /\
(TExist t' (FAPP (n,(l,p,c)) []) <=> F) /\
(TExist t' (FAPP (n,(l,p,c)) (t::ts)) <=> ((t' = t) \/ TExist t' (FAPP (n,((l-1),p,c)) ts)))
`; 

val name_subst_def = Define` (name_subst x (Con n) (Name tag str) = if x = (Name tag str) then n else (Name tag str))`;

val var_subst_def = Define` (var_subst x (TVar v) (Var str lbl) = if x = (Var str lbl) then v else (Var str lbl))`;                             
                           
(* set of variables inside a term *)

val fv_def = Define 
             ` (fv (Con _) = {}) /\
(fv (TVar v) = {v}) /\
(fv (FAPP (n,(l,p,c)) (t::ts)) <=> ((fv t) ∪ (fv (FAPP (n,((l-1),p,c)) ts))))`  ;

    
val var_of_term_def = Define 
             `
(var_of_term (TVar v) = SOME v) /\
(var_of_term _ = NONE)`  ;

(* Detect ground term *)

val is_ground_term_def = Define `
                                (is_ground_term t = (fv t = EMPTY))`;

                                        

                                                                        
(* Subset SapicTerm *)

(* Subset names *)   
val sapic_substn_def = Define`
                             (sapic_substn x y (Con n) = if x = n then y else (Con n)) ∧
(sapic_substn x y (TVar v) =(TVar v)) 
  `;


val sapic_substnf_def = Define`
                              (sapic_substnf x y (FAPP n ts) <=> (FAPP n (MAP (sapic_substn x y) ts)))`;

                                             
val sapic_substname_def = Define`
                                (sapic_substname x y t = (case t of
(FAPP n ts) => sapic_substnf x y (FAPP n ts)
| _ =>  sapic_substn x y _                                                            
))
                                `;
                                        
(* Subset variables *)
val sapic_substv_def = Define`
                             (sapic_substv x y (Con n) = (Con n)) ∧
(sapic_substv x y (TVar v) = if x = v then y else (TVar v)) 
  `;


val sapic_substvf_def = Define`
                              (sapic_substvf x y (FAPP n ts) <=> (FAPP n (MAP (sapic_substv x y) ts)))`;

                                             
val sapic_substvar_def = Define`
                                (sapic_substvar x y t = (case t of
(FAPP n ts) => sapic_substvf x y (FAPP n ts)
| _ =>  sapic_substv x y _                                                            
))
                                `;

                                        
    

val _ = export_theory();
