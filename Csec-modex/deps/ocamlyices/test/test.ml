open OUnit2
open Util

let test_version _ = assert_equal  (String.sub (Yices.version ()) 0 2) "1."

let test_context _ =
  let ctx = Yices.mk_context () in
  Yices.del_context ctx

let test_boolean_sat test_ctxt =
  let ctx = bracket_mk_context test_ctxt in
  let a = Yices.mk_bool_var ctx "a"
  and b = Yices.mk_bool_var ctx "b"
  and c = Yices.mk_bool_var ctx "c" in
  let a_implies_b = Yices.mk_implies ctx a b
  and b_implies_c = Yices.mk_implies ctx b c in
  Yices.assert_simple ctx a_implies_b;
  Yices.assert_simple ctx b_implies_c;
  Yices.assert_simple ctx a;
  assert_equal Yices.True (Yices.check ctx)

let test_boolean_sat_model test_ctxt =
  let ctx = bracket_mk_context test_ctxt in
  let a = Yices.mk_bool_var ctx "a"
  and b = Yices.mk_bool_var ctx "b"
  and c = Yices.mk_bool_var ctx "c" in
  let a_implies_b = Yices.mk_implies ctx a b
  and b_implies_c = Yices.mk_implies ctx b c in
  Yices.assert_simple ctx a_implies_b;
  Yices.assert_simple ctx b_implies_c;
  Yices.assert_simple ctx a;
  ignore (Yices.check ctx);
  let model = Yices.get_model ctx in
  let value v = Yices.get_value model (Yices.get_var_decl v) in
  assert_equal ~msg:"Check a" Yices.True (value a);
  assert_equal ~msg:"Check b" Yices.True (value b);
  assert_equal ~msg:"Check c" Yices.True (value c)

let test_boolean_unsat test_ctxt =
  let ctx = bracket_mk_context test_ctxt in
  let a = Yices.mk_bool_var ctx "a"
  and b = Yices.mk_bool_var ctx "b"
  and c = Yices.mk_bool_var ctx "c" in
  let a_implies_b = Yices.mk_implies ctx a b
  and b_implies_c = Yices.mk_implies ctx b c in
  Yices.assert_simple ctx (Yices.mk_not ctx b);
  Yices.assert_simple ctx a_implies_b;
  Yices.assert_simple ctx b_implies_c;
  Yices.assert_simple ctx a;
  assert_equal (Yices.check ctx) Yices.False

let test_boolean_unsat_core test_ctxt =
  let ctx = bracket_mk_context test_ctxt in
  let a = Yices.mk_bool_var ctx "a"
  and b = Yices.mk_bool_var ctx "b"
  and c = Yices.mk_bool_var ctx "c" in
  let a_implies_b = Yices.mk_implies ctx a b
  and b_implies_c = Yices.mk_implies ctx b c in
  let c1 = Yices.assert_retractable ctx (Yices.mk_not ctx b) in
  let c2 = Yices.assert_retractable ctx a_implies_b in
  let _c3 = Yices.assert_retractable ctx b_implies_c in
  let c4 = Yices.assert_retractable ctx a in
  ignore (Yices.check ctx);
  let core = Yices.get_unsat_core ctx in
  let expected = [| c1 ; c2 ; c4 |] in
  Array.sort compare core;
  Array.sort compare expected;
  assert_equal expected core

let test_mk_type test_ctxt ctx : Yices.typ * Yices.typ = (Yices.mk_type ctx "nat", Yices.mk_type ctx "bool")

let test_mk_tuple_type ctx : Yices.typ =
  let t = Yices.mk_type ctx "nat" in Yices.mk_tuple_type ctx [|t;t|]

let test_mk_function_type ctx : Yices.typ =
  let t = Yices.mk_type ctx "nat" in Yices.mk_function_type ctx [|t;t|] t

let test_mk_bitvector_type ctx : Yices.typ = Yices.mk_bitvector_type ctx 128

let test_mk_true ctx : Yices.expr = Yices.mk_true ctx

let test_mk_false ctx : Yices.expr = Yices.mk_false ctx

let test_mk_num ctx : Yices.expr = Yices.mk_num ctx 4549

let test_mk_num_from_string ctx : Yices.expr = Yices.mk_num_from_string ctx "54998626045544784214882"

let test_mk_tuple_literal ctx : Yices.expr=
  Yices.mk_tuple_literal ctx [| Yices.mk_true ctx; Yices.mk_num ctx 1 |]

let tests = "all tests" >::: [
  "version" >:: test_version;
  "context" >:: test_context;
  "boolean sat" >:: test_boolean_sat;
  "boolean sat model" >:: test_boolean_sat_model;
  "boolean unsat" >:: test_boolean_unsat;
  "boolean unsat core" >:: test_boolean_unsat_core;
  "ocaml addition" >::: Specific.tests;

  "types" >::: [
    "mk_type" >:: simple_test test_mk_type;
    "mk_tuple_type" >:: simple_test test_mk_tuple_type;
    "mk_function_type" >:: simple_test test_mk_function_type;
    "mk_bitvector_type" >:: simple_test test_mk_bitvector_type;
  ];

  "expressions" >::: [
    "mk_true" >:: simple_test test_mk_true;
    "mk_false" >:: simple_test test_mk_false;
    "mk_num" >:: simple_test test_mk_num;
    "mk_num_from_string" >:: simple_test test_mk_num_from_string;
    "mk_tuple_literal" >:: simple_test test_mk_tuple_literal;
  ];
]

let () = run_test_tt_main tests
