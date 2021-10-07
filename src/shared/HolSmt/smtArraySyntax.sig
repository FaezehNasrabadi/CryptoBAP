<<<<<<< HEAD
signature smtArraySyntax =
sig
    include Abbrev

<<<<<<< HEAD
    val store_tm    : term
    val select_tm   : term

    val mk_store    : (term * term * term) -> term
    val mk_select   : (term * term) -> term

    val dest_store  : term -> (term * term * term)
    val dest_select : term -> (term * term)

    val is_store    : term -> bool
    val is_select   : term -> bool
=======
    val store_tm         : term
    val select_tm        : term
    val const_array_tm   : term

    val mk_store         : (term * term * term) -> term
    val mk_select        : (term * term) -> term
    val mk_const_array   : (hol_type * term) -> term

    val dest_store       : term -> (term * term * term)
    val dest_select      : term -> (term * term)
    (* val dest_const_array : term -> (hol_type * term) *)

    val is_store         : term -> bool
    val is_select        : term -> bool
    val is_const_array   : term -> bool
>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc

end
||||||| empty tree
=======
signature smtArraySyntax =
sig
    include Abbrev

    val store_tm         : term
    val select_tm        : term
    val const_array_tm   : term

    val mk_store         : (term * term * term) -> term
    val mk_select        : (term * term) -> term
    val mk_const_array   : (hol_type * term) -> term

    val dest_store       : term -> (term * term * term)
    val dest_select      : term -> (term * term)
    (* val dest_const_array : term -> (hol_type * term) *)

    val is_store         : term -> bool
    val is_select        : term -> bool
    val is_const_array   : term -> bool

end
>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc
