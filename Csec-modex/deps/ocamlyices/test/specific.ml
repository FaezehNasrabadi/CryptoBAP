open OUnit2
open Util

let test_mk_and2 test_ctxt =
  let ctx = bracket_mk_context test_ctxt in
  let t = Yices.mk_true ctx and f = Yices.mk_false ctx in
  Yices.push ctx;
  Yices.assert_simple ctx (Yices.mk_and2 ctx t t);
  assert_equal Yices.True (Yices.check ctx);
  Yices.pop ctx;
  Yices.push ctx;
  Yices.assert_simple ctx (Yices.mk_and2 ctx t f);
  assert_equal Yices.False (Yices.check ctx);
  Yices.pop ctx;
  Yices.push ctx;
  Yices.assert_simple ctx (Yices.mk_and2 ctx f t);
  assert_equal Yices.False (Yices.check ctx);
  Yices.pop ctx;
  Yices.push ctx;
  Yices.assert_simple ctx (Yices.mk_and2 ctx f f);
  assert_equal Yices.False (Yices.check ctx)

let test_mk_or2 test_ctxt =
  let ctx = bracket_mk_context test_ctxt in
  let t = Yices.mk_true ctx and f = Yices.mk_false ctx in
  Yices.push ctx;
  Yices.assert_simple ctx (Yices.mk_or2 ctx t t);
  assert_equal Yices.True (Yices.check ctx);
  Yices.pop ctx;
  Yices.push ctx;
  Yices.assert_simple ctx (Yices.mk_or2 ctx t f);
  assert_equal Yices.True (Yices.check ctx);
  Yices.pop ctx;
  Yices.push ctx;
  Yices.assert_simple ctx (Yices.mk_or2 ctx f t);
  assert_equal Yices.True (Yices.check ctx);
  Yices.pop ctx;
  Yices.push ctx;
  Yices.assert_simple ctx (Yices.mk_or2 ctx f f);
  assert_equal Yices.False (Yices.check ctx)

let test_mk_nand2 test_ctxt =
  let ctx = bracket_mk_context test_ctxt in
  let t = Yices.mk_true ctx and f = Yices.mk_false ctx in
  Yices.push ctx;
  Yices.assert_simple ctx (Yices.mk_nand2 ctx t t);
  assert_equal Yices.False (Yices.check ctx);
  Yices.pop ctx;
  Yices.push ctx;
  Yices.assert_simple ctx (Yices.mk_nand2 ctx t f);
  assert_equal Yices.True (Yices.check ctx);
  Yices.pop ctx;
  Yices.push ctx;
  Yices.assert_simple ctx (Yices.mk_nand2 ctx f t);
  assert_equal Yices.True (Yices.check ctx);
  Yices.pop ctx;
  Yices.push ctx;
  Yices.assert_simple ctx (Yices.mk_nand2 ctx f f);
  assert_equal Yices.True (Yices.check ctx)

let test_mk_nand test_ctxt =
  let ctx = bracket_mk_context test_ctxt in
  let t = Yices.mk_true ctx and f = Yices.mk_false ctx in
  Yices.push ctx;
  Yices.assert_simple ctx (Yices.mk_nand ctx [|t;t;t;t|]);
  assert_equal Yices.False (Yices.check ctx);
  Yices.pop ctx;
  Yices.push ctx;
  Yices.assert_simple ctx (Yices.mk_nand ctx [|t;t;f;t;f|]);
  assert_equal Yices.True (Yices.check ctx);
  Yices.pop ctx;
  Yices.push ctx;
  Yices.assert_simple ctx (Yices.mk_nand ctx [|f;t;t;t|]);
  assert_equal Yices.True (Yices.check ctx);
  Yices.pop ctx;
  Yices.push ctx;
  Yices.assert_simple ctx (Yices.mk_nand ctx [|f;f;f;f;f;f|]);
  assert_equal Yices.True (Yices.check ctx)

let test_mk_nor2 test_ctxt =
  let ctx = bracket_mk_context test_ctxt in
  let t = Yices.mk_true ctx and f = Yices.mk_false ctx in
  Yices.push ctx;
  Yices.assert_simple ctx (Yices.mk_nor2 ctx t t);
  assert_equal Yices.False (Yices.check ctx);
  Yices.pop ctx;
  Yices.push ctx;
  Yices.assert_simple ctx (Yices.mk_nor2 ctx t f);
  assert_equal Yices.False (Yices.check ctx);
  Yices.pop ctx;
  Yices.push ctx;
  Yices.assert_simple ctx (Yices.mk_nor2 ctx f t);
  assert_equal Yices.False (Yices.check ctx);
  Yices.pop ctx;
  Yices.push ctx;
  Yices.assert_simple ctx (Yices.mk_nor2 ctx f f);
  assert_equal Yices.True (Yices.check ctx)

let test_mk_nor test_ctxt =
  let ctx = bracket_mk_context test_ctxt in
  let t = Yices.mk_true ctx and f = Yices.mk_false ctx in
  Yices.push ctx;
  Yices.assert_simple ctx (Yices.mk_nor ctx [|t;t;t;t|]);
  assert_equal Yices.False (Yices.check ctx);
  Yices.pop ctx;
  Yices.push ctx;
  Yices.assert_simple ctx (Yices.mk_nor ctx [|t;t;f;t;f|]);
  assert_equal Yices.False (Yices.check ctx);
  Yices.pop ctx;
  Yices.push ctx;
  Yices.assert_simple ctx (Yices.mk_nor ctx [|f;t;t;t|]);
  assert_equal Yices.False (Yices.check ctx);
  Yices.pop ctx;
  Yices.push ctx;
  Yices.assert_simple ctx (Yices.mk_nor ctx [|f;f;f;f;f;f|]);
  assert_equal Yices.True (Yices.check ctx)

let test_mk_sum2 test_ctxt =
  let ctx = bracket_mk_context test_ctxt in
  let n = Yices.mk_num ctx in
  Yices.assert_simple ctx (Yices.mk_eq ctx (n 3) (Yices.mk_sum2 ctx (n 1) (n 2)));
  Yices.assert_simple ctx (Yices.mk_eq ctx (n (-2)) (Yices.mk_sum2 ctx (n 0) (n (-2))));
  assert_equal Yices.True (Yices.check ctx)

let test_mk_sub2 test_ctxt =
  let ctx = bracket_mk_context test_ctxt in
  let n = Yices.mk_num ctx in
  Yices.assert_simple ctx (Yices.mk_eq ctx (n 56) (Yices.mk_sub2 ctx (n 81) (n 25)));
  Yices.assert_simple ctx (Yices.mk_eq ctx (n (-502)) (Yices.mk_sub2 ctx (n (-2)) (n 500)));
  assert_equal Yices.True (Yices.check ctx)

let test_mk_mul2 test_ctxt =
  let ctx = bracket_mk_context test_ctxt in
  let n = Yices.mk_num ctx in
  Yices.assert_simple ctx (Yices.mk_eq ctx (n 952) (Yices.mk_mul2 ctx (n 56) (n 17)));
  Yices.assert_simple ctx (Yices.mk_eq ctx (n 0) (Yices.mk_mul2 ctx (n 0) (n 1548)));
  assert_equal Yices.True (Yices.check ctx);;

(* Empty array tests *)

let test_mk_and_nil test_ctxt =
  let ctx = bracket_mk_context test_ctxt in
  Yices.assert_simple ctx (Yices.mk_and ctx [||]);
  assert_equal Yices.True (Yices.check ctx);;

let test_mk_or_nil test_ctxt =
  let ctx = bracket_mk_context test_ctxt in
  Yices.assert_simple ctx (Yices.mk_or ctx [||]);
  assert_equal Yices.False (Yices.check ctx);;

let test_mk_nand_nil test_ctxt =
  let ctx = bracket_mk_context test_ctxt in
  Yices.assert_simple ctx (Yices.mk_nand ctx [||]);
  assert_equal Yices.False (Yices.check ctx);;

let test_mk_nor_nil test_ctxt =
  let ctx = bracket_mk_context test_ctxt in
  Yices.assert_simple ctx (Yices.mk_nor ctx [||]);
  assert_equal Yices.True (Yices.check ctx);;

let test_mk_sum_nil test_ctxt =
  let ctx = bracket_mk_context test_ctxt in
  let n = Yices.mk_num ctx in
  Yices.assert_simple ctx
    (Yices.mk_eq ctx (n 0) (Yices.mk_sum ctx [||]));
  assert_equal Yices.True (Yices.check ctx);
  Yices.reset ctx;
  Yices.assert_simple ctx
    (Yices.mk_eq ctx (n 6) (Yices.mk_sum ctx [|n 1;n 2;n 3|]));
  assert_equal ~msg:"non-empty array" Yices.True (Yices.check ctx);;

let test_mk_sub_nil test_ctxt =
  let ctx = bracket_mk_context test_ctxt in
  assert_raises (Invalid_argument "mk_sub") (fun () -> Yices.mk_sub ctx [||]);
  let n = Yices.mk_num ctx in
  Yices.assert_simple ctx
    (Yices.mk_eq ctx (n 6) (Yices.mk_sub ctx [|n 12;n 1;n 2;n 3|]));
  assert_equal ~msg:"non-empty array" Yices.True (Yices.check ctx);;

let test_mk_mul_nil test_ctxt =
  let ctx = bracket_mk_context test_ctxt in
  let n = Yices.mk_num ctx in
  Yices.assert_simple ctx
    (Yices.mk_eq ctx (n 1) (Yices.mk_mul ctx [||]));
  assert_equal Yices.True (Yices.check ctx);
  Yices.reset ctx;
  Yices.assert_simple ctx
    (Yices.mk_eq ctx (n 6) (Yices.mk_sub ctx [|n 12;n 1;n 2;n 3|]));
  assert_equal ~msg:"non-empty array" Yices.True (Yices.check ctx);;

let test_mk_bv_constant_nil test_ctxt =
  let ctx = bracket_mk_context test_ctxt in
  ignore (Yices.mk_bv_constant ctx 0 546l) (* should not abort *)

let test_mk_bv_constant_from_int test_ctxt =
  let ctx = bracket_mk_context test_ctxt in
  assert_raises (Invalid_argument "mk_bv_constant_from_int")
    (fun () -> Yices.mk_bv_constant_from_int ctx 0 455);
  let a = Yices.mk_bv_constant_from_int ctx 8 85 in
  let b = Yices.mk_bv_constant ctx 8 85l in
  Yices.assert_simple ctx (Yices.mk_eq ctx a b);
  assert_equal ~msg:"normal" Yices.True (Yices.check ctx);
  Yices.reset ctx;
  let a = Yices.mk_bv_constant_from_int ctx 64 (-1) in
  let b = Yices.mk_bv_constant ctx 64 (-1l) in
  Yices.assert_simple ctx (Yices.mk_eq ctx a b);
  assert_equal ~msg:"sign extension (1)" Yices.True (Yices.check ctx);
  Yices.reset ctx;
  let a = Yices.mk_bv_constant_from_int ctx 64 16 in
  let b = Yices.mk_bv_constant ctx 64 16l in
  Yices.assert_simple ctx (Yices.mk_eq ctx a b);
  assert_equal ~msg:"sign extension (0)" Yices.True (Yices.check ctx);;


let tests = [
    "mk_nand" >:: test_mk_nand;
    "mk_nor" >:: test_mk_nor;
    "binary shortcuts" >::: [
      "mk_and2" >:: test_mk_and2;
      "mk_or2" >:: test_mk_or2;
      "mk_nand2" >:: test_mk_nand2;
      "mk_nor2" >:: test_mk_nor2;
      "mk_sum2" >:: test_mk_sum2;
      "mk_sub2" >:: test_mk_sub2;
      "mk_mul2" >:: test_mk_mul2;
    ];
    "zero-length array" >::: [
      "mk_and" >:: test_mk_and_nil;
      "mk_or" >:: test_mk_or_nil;
      "mk_nand" >:: test_mk_nand_nil;
      "mk_nor" >:: test_mk_nor_nil;
      "mk_sum" >:: test_mk_sum_nil;
      "mk_sub" >:: test_mk_sub_nil;
      "mk_mul" >:: test_mk_mul_nil;
    ];
    "mk_bv_constant_from_int" >:: test_mk_bv_constant_from_int;
    "mk_bv_constant_nil" >:: test_mk_bv_constant_nil;
  ]
