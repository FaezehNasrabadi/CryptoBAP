signature messagesSyntax =
sig
   include Abbrev

   (***************)
   (* SapicTerm_t *)
   (***************)

   (* The type itself *)
   val NameTag_t_ty    : hol_type
   val Name_t_ty       : hol_type
   val Var_t_ty        : hol_type
   val Privacy_t_ty    : hol_type
   val Constructability_t_ty : hol_type
   val SapicTerm_t_ty  : hol_type

   val FreshName_tm    : term
   val PubName_tm      : term
   val NodeName_tm     : term
   val Name_tm         : term
   val Var_tm          : term
   val Private_tm      : term
   val Public_tm       : term
   val Constructor_tm  : term
   val Destructor_tm   : term
   val Con_tm          : term
   val TVar_tm         : term
   val FAPP_tm         : term
       
   val is_FreshName    : term -> bool
   val is_PubName      : term -> bool
   val is_NodeName     : term -> bool
   val is_Name     : term -> bool
   val is_Var          : term -> bool
   val is_Private      : term -> bool
   val is_Public       : term -> bool
   val is_Constructor  : term -> bool
   val is_Destructor   : term -> bool
   val is_Con          : term -> bool
   val is_TVar         : term -> bool
   val is_FAPP         : term -> bool
       
   val mk_Name         : term * term -> term
   val mk_Var          : term * term  -> term
   val mk_Con          : term -> term
   val mk_TVar         : term -> term
   val mk_FAPP         : term * term -> term

   val dest_Name       : term -> term * term
   val dest_Var        : term -> term * term
   val dest_Con        : term -> term
   val dest_TVar       : term -> term
   val dest_FAPP       : term -> term * term
   

end
