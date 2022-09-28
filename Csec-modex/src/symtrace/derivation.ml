open Common

open Sym
open Type
open Exp

module S = Solver

open Printf

let wrap =
  { Exp.Wrap.
    wrap_after = 80
  ; wrap_to = 80
  ; sep = "\\\\ \n & \\;\\; "
  }

module E = struct
  include Exp
  let latex = latex ~wrap
end

module Visible = struct

  (* This is a hack to account for split_arithmetic_defined. *)
  let equal_conj e e' =
    match e, e' with
    | Sym (Defined, [e]), Sym (Defined, [e']) ->
      Option.is_some (E.phys_equal e e')
    | e, e' -> e == e'

  let cleanup_conj_list ?(remove = []) es =
    List.concat_map es ~f:E.flatten_conj
    |> List.filter_out ~f:(fun e ->
      List.mem ~equal:equal_conj e ~set:remove)
    |> List.dedup

  let cleanup_conj (type a) ?(remove = []) (e : a exp) : a exp =
    match e with
    | Sym (Logical (Logical.And _), es) ->
      begin
        match cleanup_conj_list ~remove es with
        | [] -> E.true_fact
        | es -> E.conj es
      end
    | e -> e

  let obvious_conjuncts (type a) (e : a exp) : fact list =
    let is_obvious = function
      | Sym (Defined, [e]) when E.is_constant e -> true
      | e -> E.is_constant_integer_fact e && S.is_true e
    in
  (* If we remove defined(2 + 1) then we don't want to see defined(2) and defined(1) in
     future. *)
    let rec split_arithmetic_defined = function
      | (Sym (Defined, [Sym (Int_op _, es)])) as e ->
        let es = List.map es ~f:E.is_defined in
        e :: List.concat_map es ~f:split_arithmetic_defined
      | e -> [e]
    in
    match e with
    | Sym (Logical (Logical.And _), es) ->
      List.filter es ~f:is_obvious
      |> List.concat_map ~f:split_arithmetic_defined
    | _ -> []


  module Rewrite = struct
    type 'a t =
      { conds : int list
      ; right : 'a exp }

    let conds t = t.conds
    let right t = t.right

    let obvious_conjuncts t =
      obvious_conjuncts t.right

    let cleanup ~remove t =
      { right = cleanup_conj ~remove t.right
      ; conds = t.conds
      }

    let to_string t =
      let conds =
        List.map t.conds ~f:string_of_int
        |> List.dedup
        |> function
          | [] -> ""
          | conds -> Printf.sprintf "(%s)" (String.concat ~sep:"," conds)
      in
      Printf.sprintf "%s ~> %s" conds (E.to_string t.right)

    let latex t =
      let conds =
        List.map t.conds ~f:string_of_int
        |> List.dedup
        |> function
          | [] -> ""
          | conds -> Printf.sprintf "(%s)" (String.concat ~sep:"," conds)
      in
      Printf.sprintf "%s \\rightsquigarrow {} & %s" conds (E.latex t.right)
  end

  module Sequence = struct
    type 'a t =
      { id : int
      ; root : 'a exp
      (* In correct order. *)
      ; rewrites : 'a Rewrite.t list
      }

    let root t = t.root
    let id t = t.id
    let rewrites t = t.rewrites

    let last t =
      match List.rev t.rewrites with
      | [] -> t.root
      | r :: _ -> Rewrite.right r

    let to_string ?(label = "") t =
      let id = Printf.sprintf "%d%s:" (E.id t.root) label in
      let root = E.to_string t.root in
      let rewrites = List.map t.rewrites ~f:Rewrite.to_string in
      String.concat ~sep:"\n" (id :: root :: rewrites)

    let latex t =
      let first = E.latex t.root in
      let rewrites = List.map t.rewrites ~f:Rewrite.latex in
      Printf.sprintf "\\mathbf{%d}  \\mathrel{\\hphantom{\\rightsquigarrow}} & %s"
        (E.id t.root)
        (String.concat ~sep:"\\\\\n" (first :: rewrites))

    let cleanup { id; root; rewrites } =
      let rec cleanup ~remove = function
        | [] -> []
        | r :: rs ->
          let r = Rewrite.cleanup ~remove r in
          let remove = Rewrite.obvious_conjuncts r @ remove in
          r :: cleanup ~remove rs
      in
      let rec remove_dupes = function
        | r :: r' :: rs when Rewrite.right r = Rewrite.right r' ->
          remove_dupes (r :: rs)
        | r :: rs ->
          r :: remove_dupes rs
        | [] -> []
      in
      let root = cleanup_conj ~remove:[] root in
      let remove = obvious_conjuncts root in
      let rewrites = cleanup ~remove rewrites |> remove_dupes in
      { id; root; rewrites }

    let conds t =
      List.concat_map t.rewrites ~f:Rewrite.conds
  end

  type 'a t =
    { roots : 'a   Sequence.t list
    ; conds : bool Sequence.t list
    }

  let rec prune t =
    let used_conds =
      List.concat_map t.roots ~f:Sequence.conds
      @ List.concat_map t.conds ~f:Sequence.conds
    in
    let conds = List.filter t.conds ~f:(fun cond ->
      List.mem (Sequence.id cond) ~set:used_conds)
    in
    let t' = { t with conds } in
    if t' = t then t' else prune t'

  let cleanup { roots; conds } =
    { roots = List.map roots ~f:Sequence.cleanup
    ; conds = List.map conds ~f:Sequence.cleanup
    }
    |> prune

  let to_string t =
    let t = cleanup t in
    let roots = List.map ~f:Sequence.to_string t.roots in
    let conds = List.map ~f:Sequence.to_string t.conds in
    String.concat ~sep:"\n" (roots @ conds)

  let latex t =
    let t = cleanup t in
    let roots = List.map ~f:Sequence.latex t.roots in
    let conds = List.map ~f:Sequence.latex t.conds in
    String.concat ~sep:"\\\\[\\medskipamount]\n" (roots @ conds)

  module Summary = struct
    type t =
      { assume : (fact list * fact list) list
      ; prove : fact list
      }

    let to_string t =
      let rec a_to_string i = function
        | [] -> []
        | (cond, assume) :: ass ->
          [ Printf.sprintf "cond %d: %s" i (E.list_to_string ~newline:true cond)
          ; Printf.sprintf "assumption %d: %s" i (E.list_to_string ~newline:true assume)
          ]
          @ a_to_string (i + 1) ass
      in
      String.concat ~sep:"\n\n"
        (a_to_string 0 t.assume
         @ [ Printf.sprintf "prove: %s" (E.list_to_string ~newline:true t.prove) ])

    let latex t =
      let of_conj_list es =
        E.latex (cleanup_conj (E.conj es))
      in
      let assume =
        List.mapi t.assume ~f:(fun i (cond, assumption) ->
          let cond = sprintf "\\phi_%d = {} & %s" i (of_conj_list cond) in
          let assumption = sprintf "\\psi_%d = {} & %s" i (of_conj_list assumption) in
          sprintf "%s\\\\\n%s" cond assumption)
      in
      let prove = sprintf "\\psi = {} & %s" (of_conj_list t.prove) in
      String.concat ~sep:"\\\\[\\medskipamount]\n" (assume @ [prove])
  end

  let sequence_of t e =
    let seqs = t.roots @ t.conds in
    List.find_exn seqs ~f:(fun seq -> Sequence.root seq = e)

  let result t e =
    Sequence.last (sequence_of t e)

  let collect_conds t e =
    let rec collect_one id =
      let seq = List.find_exn t.conds ~f:(fun seq -> Sequence.id seq = id) in
      Sequence.last seq :: List.concat_map (Sequence.conds seq) ~f:collect_one
    in
    let rec collect ~assume = function
      | [] -> []
      | r :: rs ->
        let conds =
          Rewrite.conds r
          |> List.concat_map ~f:collect_one
          |> List.concat_map ~f:E.flatten_conj
        in
        DEBUG "assume: %s" (E.list_to_string assume);
        DEBUG "conds: %s" (E.list_to_string conds);
        let conds = List.diff conds assume in
        let assume = E.flatten_conj (Rewrite.right r) @ assume in
        conds @ collect ~assume rs
    in
    collect (Sequence.rewrites (sequence_of t e)) ~assume:(E.flatten_conj e)

  let summary t ~assume ~prove =
    let collect_assume assume =
      let conds = collect_conds t assume |> cleanup_conj_list in
      let assume = result t assume |> E.flatten_conj |> cleanup_conj_list in
      conds, assume
    in
    push_debug "summary";
    let assume = List.map assume ~f:collect_assume in
    let prove_conds = List.concat_map prove ~f:(collect_conds t) in
    let prove = List.map ~f:(result t) prove in
    let prove = cleanup_conj_list (prove_conds @ prove) in
    let t = { Summary. assume; prove } in
    pop_debug "summary";
    t
end

(* So far all our 'a are actually bool since we only look at is_true derivations. *)
module Rewrite = struct
  type ('a, 'b) t =
    { root : 'a exp
    ; left : 'b exp
    ; right : 'b exp
    ; conds  : fact list
    }

  let root t = t.root
  let left t = t.left
  let right t = t.right
  let conds t = t.conds

  let kinds t = (E.kind t.root, E.kind t.left)

  let apply (type a) (type b) (t : (a, b) t) (e : a exp) : (a, a) t option =
    let matched = ref false in
    let rec subst : type c. c exp -> c exp = fun e ->
      if !matched then e
      else match E.phys_equal e t.left with
      | Some (Type_equal.Equal : (c, b) Type_equal.t) ->
        matched := true;
        t.right
      | None -> (descend {descend = subst} e)
    in
    let e' = subst e in
    if not !matched then None
    else Some { left = e; right = e'; conds = t.conds; root = t.root }

  let to_visible t =
    let conds =
      List.map t.conds ~f:E.id
      |> List.sort ~cmp:compare
      |> List.dedup
    in
    { Visible.Rewrite. conds; right = t.right }

  let dump t =
    let conds =
      List.map t.conds ~f:E.to_string
      |> List.dedup
      |> String.concat ~sep:","
    in
    Printf.sprintf "[%s] |- %s ~> %s" conds (E.to_string t.left) (E.to_string t.right)
end

module Sequence = struct
  type 'a t =
    { root : 'a exp
    (* In reverse order. *)
    ; rewrites : ('a, 'a) Rewrite.t list
    }

  let root t = t.root

  let of_exp e =
    { root = e
    ; rewrites = []
    }

  let of_rewrite r =
    { root = Rewrite.left r
    ; rewrites = [r]
    }

  let last t =
    match t.rewrites with
    | r :: _ -> Rewrite.right r
    | [] -> t.root

  let add (type a) (type b) (type c) (t : a t) (rewrite : (b, c) Rewrite.t) : a t option =
    let last = last t in
    match E.phys_equal (root t) (Rewrite.root rewrite) with
    | None -> None
    | Some (Type_equal.Equal : (a, b) Type_equal.t) ->
      match Rewrite.apply rewrite last with
      | None -> assert false
      | Some r ->  Some { t with rewrites = r :: t.rewrites }

  let to_visible t =
    let id = E.id t.root in
    let rewrites = List.map t.rewrites ~f:Rewrite.to_visible |> List.rev in
    { Visible.Sequence. id; root = t.root; rewrites }

  let conds t =
    List.concat_map t.rewrites ~f:Rewrite.conds

  let gt t1 t2 =
    List.mem t2.root ~set:(conds t1)

  let dump t =
    String.concat ~sep:"\n" (E.to_string t.root :: List.map t.rewrites ~f:Rewrite.dump)
end

type 'a t =
  { roots : 'a   Sequence.t list
  ; conds : bool Sequence.t list
  }

let kind t =
  match t.roots with
  | r :: _ ->
    E.kind (Sequence.root r)
  | [] ->
    assert false

let create es =
  { roots = List.map es ~f:Sequence.of_exp
  ; conds = []
  }

let dump t =
  String.concat ~sep:"\n"
    (List.map t.roots ~f:Sequence.dump
     @ List.map t.conds ~f:Sequence.dump)

(* Dedup conds, and explicate conds that don't have a derivation. *)
let normalize_conds t =
  let mentioned =
    List.map ~f:Sequence.conds t.roots @ List.map ~f:Sequence.conds t.conds
    |> List.concat
  in
  let explicit = List.map t.conds ~f:Sequence.root in
  let loose_conds =
    List.diff mentioned explicit
    |> List.map ~f:Sequence.of_exp
    |> List.dedup
  in
  let conds =
    List.dedup t.conds
    |> List.filter ~f:(fun cond ->
      List.mem (Sequence.root cond) ~set:mentioned)
  in
  { t with conds = loose_conds @ conds  }

exception Not_added

let add (type a) (type b) (type c) (t : a t) (rewrite : (b, c) Rewrite.t) : a t =
  let rec add seqs =
    match seqs with
    | [] -> raise Not_added
    | seq :: seqs ->
      match Option.try_with (fun () -> Sequence.add seq rewrite) with
      | Some (Some seq) -> seq :: seqs
      | Some None -> seq :: add seqs
      | None ->
        DEBUG "cannot add %s to sequence:\n%s\nIn derivation \n%s\n"
          (Rewrite.dump rewrite)
          (Sequence.dump seq)
          (dump t);
        assert false
  in
  let { roots; conds } = t in
  match Result.try_with (fun () -> add roots) with
  | Ok roots -> { roots; conds }
  | Error Not_added ->
    begin match Result.try_with (fun () -> add conds) with
    | Ok conds -> { roots; conds }
    | Error Not_added ->
      begin match Rewrite.kinds rewrite with
      | Kind.Bool, Kind.Bool ->
        { roots
        ; conds = conds @ [Sequence.of_rewrite (rewrite : (bool, bool) Rewrite.t)] }
      | _ ->
        warn "Ignoring rewrite of %s" (E.to_string (Rewrite.left rewrite));
        Printf.eprintf "Current derivation: \n%s\n" (dump t);
        assert false
      end
    | Error e -> raise e
    end
  | Error e -> raise e

let add t rewrite =
  normalize_conds (add t rewrite)

let to_visible t =
  E.reset_ids ();
  (* This relies on the fact that the order of t.conds roughly corresponds to the order of
     appearance. *)
  let conds = List.topsort Sequence.gt t.conds |> List.rev in
  (* Assign ids in order of conditions. *)
  List.iter t.roots ~f:(fun seq ->
    ignore (E.id (Sequence.root seq)));
  List.iter conds ~f:(fun seq ->
    ignore (E.id (Sequence.root seq)));
  let roots = List.map t.roots ~f:Sequence.to_visible in
  let conds = List.map conds ~f:Sequence.to_visible in
  { Visible. roots; conds }

let to_string t =
  Visible.to_string (to_visible t)

let latex t =
  Visible.latex (to_visible t)

let summary t ~assume ~prove =
  Visible.Summary.latex (Visible.summary (to_visible t) ~assume ~prove)

let derivation ~assume ~prove =
  let assume = List.map assume ~f:E.unfold in
  let prove = List.map prove ~f:E.unfold in
  let t = ref (create (assume @ prove)) in
  let trace ~root ~left ~right ~conds =
    push_debug "trace";
    DEBUG "Adding %s |- %s ~> %s\n"
      (E.list_to_string conds) (E.to_string left) (E.to_string right);
    let rewrite = { Rewrite. root; left; right; conds } in
    t := add !t rewrite;
    DEBUG "Result: \n%s\n" (dump !t);
    pop_debug "trace";
  in
  S.enable_tracing { S.trace };
  Printf.printf "checking implication: \n  %s\n  =>\n  %s\n"
    (E.list_to_string assume) (E.list_to_string prove);
  let result = S.implies assume prove in
  Printf.printf "implication result: %b" result;
  S.disable_tracing ();
  !t

let setup_debug () =
  set_debug (fun labels ->
    let at_most_n_under n l =
      match List.find_index ((=) l) labels with
      | None -> false
      | Some i -> i <= n
    in
    at_most_n_under 1 "dummy"
    (* || at_most_n_under 0 "summary" *)
    (* || at_most_n_under 0 "trace" *)
    (* || at_most_n_under 1 "execute" *)
    (* || at_most_n_under 0 "deep_simplify" *)
    (* || at_most_n_under 3 "rewrite" *)
    || false)

let reset () =
  (* Resetting the cache is necessary because we reset ids in to_string. *)
  S.reset_cache ();
  S.reset_facts ()

let main () =
  setup_debug ();

  (*
  reset ();
  let nonce = Var ("nonce", Kind.Bitstring) in
  let bs e = BS (e, Int_type.create `Unsigned 4) in
  let t1 = derivation
    (E.implication
       [eq_int [Len nonce; Int 20L ]]
       [eq_int [Len nonce; Int 20L ]])
  in
  Printf.printf "\n===============================\n";
  Printf.printf "%s\n\n%!" (to_string t1);

  reset ();
  let t2 = derivation
    (E.implication
       [eq_int [Len nonce; Int 20L ]]
       [eq_bitstring [bs (Len nonce); bs (Int 20L)]])
  in
  Printf.printf "\n===============================\n";
  Printf.printf "%s\n\n%!" (to_string t2);
  *)

  (*
    The small substring example
  *)
  reset ();
  let x1 = E.var_s "x_1" in
  let x2 = E.var_s "x_2" in
  let e =
    E.eq_int
      [ Len (Range (Concat [x1; x2], Int 5L, Len x2))
      ; Len x2
      ]
  in
  let assume = [] in
  let prove = [e] in
  let t = derivation ~assume ~prove in
  Printf.printf "\n===============================\n";
  Printf.printf "%s\n\n%!" (latex t);
  Printf.printf "\nSummary:\n";
  Printf.printf "%s\n\n%!" (summary t ~assume ~prove);

  (*
    The chaining rule example.
  *)
  reset ();
  let x = E.var_s "x" in
  let utype = Int_type.create `Unsigned 8 in
  let e =
    Sym (Int_cmp Cmp.Ge, [Val (x, utype); E.int 200])
  in
  let assume = [e] in
  let prove = [] in
  let t = derivation ~assume ~prove in
  Printf.printf "\n===============================\n";
  Printf.printf "%s\n\n%!" (latex t);
  Printf.printf "\nSummary:\n";
  Printf.printf "%s\n\n%!" (summary t ~assume ~prove);


  (*
    The big substring example
  *)

  reset ();
  let x = E.var_s "x" in
  let utype = Int_type.create `Unsigned 1 in
  let stype = Int_type.create `Signed 1 in
  let x_len = Range (x, E.int 1, E.int 1) in

  let offset =
    E.sum
      [ E.int 1
      ; E.int 1
      ; Val (x_len, utype)
      ]
  in
  let prove =
    E.eq_bitstring
      [ Range (x, offset, E.minus (Len x) offset)
      ; E.string "secret"
      ]
  in

  let cast_su x = Sym (Op (Op.Cast_to_int, ([Bs_int stype], Bs_int utype)), [x]) in
  let cast_us x = Sym (Op (Op.Cast_to_int, ([Bs_int utype], Bs_int stype)), [x]) in
  let nine_s = BS (E.int 2, stype) in
  let nine_u = BS (E.int 2, utype) in
  let plus itype x y =
    Sym (Op (Op.Op_arith (Arith.Plus 2), ([Bs_int itype; Bs_int itype], Bs_int itype)),
         [x; y])
  in
  let minus itype x y =
    Sym (Op (Op.Op_arith Arith.Minus, ([Bs_int itype; Bs_int itype], Bs_int itype)),
         [x; y])
  in
  let ge = Op (Op.Op_cmp Cmp.Ge, ([Bs_int utype; Bs_int utype], Bs_int utype)) in
  let cond1 =
    Sym
      (Truth_of_bs,
       [Sym (ge, [BS (Len x, utype); BS (E.int 200, utype)])]
      )
  in
  let le = Op (Op.Op_cmp Cmp.Le, ([Bs_int utype; Bs_int utype], Bs_int utype)) in
  let cond2 =
    Sym
      (Truth_of_bs,
       [Sym (le, [x_len; BS (E.int 100, utype)])]
      )
  in
  let cond3 =
    E.eq_bitstring
      [Range
          (x,
           Val
             (cast_su
                (plus stype nine_s (cast_us x_len)),
              utype),
           Val
             (minus utype
                (BS (Len x, utype))
                (plus utype nine_u x_len),
              utype))
      ; E.string "secret"
      ]
  in
  let assume = [cond1; cond2; cond3] in
  let prove = [prove] in
  let t = derivation ~assume ~prove in
  Printf.printf "\n===============================\n";
  Printf.printf "%s\n\n%!" (latex t);
  Printf.printf "\nSummary:\n";
  Printf.printf "%s\n\n%!" (summary t ~assume ~prove);
;;

main ()

