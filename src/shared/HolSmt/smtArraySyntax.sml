structure smtArraySyntax :> smtArraySyntax =
struct

  open HolKernel Parse boolLib;  local open smtArrayTheory in end;

  val ERR = Feedback.mk_HOL_ERR "smtArraySyntax"

<<<<<<< HEAD
  val store_tm = prim_mk_const{Name="store", Thy="smtArray"}
  val select_tm = prim_mk_const{Name="select", Thy="smtArray"};
=======
  val store_tm       = prim_mk_const{Name="store", Thy="smtArray"}
  val select_tm      = prim_mk_const{Name="select", Thy="smtArray"};
  val const_array_tm = prim_mk_const{Name="const_array", Thy="smtArray"};
>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc

  fun mk_store (array, index, value) =
    list_mk_comb (
      inst [alpha |-> type_of index,
            beta  |-> type_of value] store_tm,
      [array, index, value]);

  fun mk_select (array, index) =
    let
      val (ty_index, ty_value) = (Type.dom_rng o Term.type_of) array;
    in
      list_mk_comb (
        inst [alpha |-> ty_index,
              beta  |-> ty_value] select_tm,
        [array, index])
    end;

<<<<<<< HEAD
  val dest_store  = dest_triop store_tm  (ERR "dest_store"  "not store");
  val dest_select = dest_binop select_tm (ERR "dest_select" "not select");

  val is_store = can dest_store;
  val is_select = can dest_select;
=======
  fun mk_const_array (domain_ty, value) =
    list_mk_comb (
      inst [alpha |-> type_of value,
            beta  |-> domain_ty] const_array_tm,
      [value]);

  val dest_store       = dest_triop store_tm       (ERR "dest_store"       "not store");
  val dest_select      = dest_binop select_tm      (ERR "dest_select"      "not select");
  (* val dest_const_array = dest_uniop const_array_tm (ERR "dest_const_array" "not const_array"); *)

  val is_store       = can dest_store;
  val is_select      = can dest_select;
  val is_const_array = (*can dest_const_array;*)
                       fn t => is_comb t andalso
                               (identical (fst (dest_comb t)) const_array_tm);
>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc

end (* smtArraySyntax *)

