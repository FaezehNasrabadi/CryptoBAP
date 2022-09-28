(* Copyright (c) 2008, Jacob Burnim (jburnim@cs.berkeley.edu)
 * Copyright (c) 2010-2011, Mihhail Aizatulin (avatar@hot.ee)
 *
 * See LICENSE file for copyright notice.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See LICENSE
 * for details.
 *)

(*
  Changes by Misha (OUTDATED):

    - Store and Load now also supply the sizeof() the stored/loaded variable

    - HandleReturn and ClearFrame (renamed from ClearStack) now get the number
      of function parameters, so that calling a function works even when the stack is not empty.

    - Return now gets a bool indicating whether the returned value is symbolic (false if void).

    - Call now also supplies the name and the address of the function.

    - A new function Invoke() is inserted right before a call and given the called function address.
*)

open Cil
open Formatcil

module E = Errormsg

open List

open Common

open Printf

(*************************************************)
(** {1 State} *)
(*************************************************)

let opaqueWrappers : StrSet.t ref = ref StrSet.empty

let idCount = ref 0

(*************************************************)
(** {1 General Purpose} *)
(*************************************************)

let isSome o =
  match o with
    | Some _ -> true
    | None   -> false

let concatMap f ls =
  let rec doIt res ls =
    match ls with
      | [] -> List.rev res
      | (x::xs) -> doIt (List.rev_append (f x) res) xs
  in
    doIt [] ls


(*************************************************)
(** {1 Helpers} *)
(*************************************************)

let getNewId () = ((idCount := !idCount + 1); !idCount)

let noAddr = zero

let shouldSkipFunction f = hasAttribute "crest_skip" f.vattr

let prependToBlock (is : instr list) (b : block) =
  b.bstmts <- mkStmt (Instr is) :: b.bstmts

(* These definitions must match those in "libcrest/crest.h". *)
let idType   = intType
let bidType  = intType
let fidType  = uintType
let valType  = TInt (ILongLong, [])
let chrType  = TInt (IChar, [])
let addrType = TInt (IULong, [])
let sizeType = !typeOfSizeOf
let boolType = TInt (IUChar, [])
let opType   = intType  (* enum *)
let strType  = charConstPtrType
(* A generic function pointer *)
let funPtrType = cType "void (*)()" []


let checkHasAddress (_, off) =
  let rec containsBitField off =
    match off with
      | NoOffset         -> false
      | Field (fi, off) -> (isSome fi.fbitfield) || (containsBitField off)
      | Index (_, off)  -> containsBitField off
  in
    if not (containsBitField off) then ()
    else
      E.error "bitfields not supported"

let funReturnType : typ -> typ = function
	| TFun (t, _, _, _) -> t
	| _ -> failwith "funReturnType: not a function"

let isVoidFunType : typ -> bool = function
	| TFun (TVoid _, _, _, _) -> true
	| _ -> false

let isVarargFunType : typ -> bool = function
	| TFun (_, _, true, _) -> true
	| _ -> false

let opaque : varinfo -> varinfo = fun v ->
  if isVarargFunType v.vtype then v else
  (*
    The reason to make it static is that we insert a definition when encountering a declaration,
    because some definitions might not actually be crestified.

    This can lead to a warning that the opaque wrapper is unused (which is only given for static functions),
    so I turn it off at compilation. Maybe try asking CIL to remove unused definitions.
  *)
  { v with vname = "__crest_" ^ v.vname ^ "_opaque"; vstorage = Static }

let needsOpaqueWrapper : varinfo -> bool = fun v ->
  (*
  ignore (Pretty.printf "needsOpaqueWrapper? %a\n" d_lval (Var v, NoOffset));
  ignore (Pretty.printf "isOpaque: %B\n" (isOpaque v));
  ignore (Pretty.printf "isFunctionType: %B\n" (isFunctionType v.vtype));
  ignore (Pretty.printf "isProxied: %B\n" (isProxied v));
  *)
  (*
    The only time we expect to see a naked proxied function is inside the proxy itself,
    in which case it is correct to provide an opaque wrapper for it.

    The only problem is that this way we provide unused wrappers in all the other files.
  *)
  isOpaque v && isFunctionType v.vtype (* && not (isProxied v) *)
  (* the opaque wrapper now reacts specially to these: *)
  (* && not (isVarargFunType v.vtype) *)

(*************************************************)
(** {1 Ops} *)
(*************************************************)

module Type = struct
  type t = {
    argument_types: typ list;
    result_type: typ }

  let showSigned = function
    | false -> "u"
    | true -> "s"

  let showIntType = function
    | TInt (ikind, _) ->
      sprintf "[%s,%d]" (showSigned (isSigned ikind)) (bytesSizeOfInt ikind)
    | TPtr _ -> "ptr"
      (* FIXME: the name will be parsed incorrectly if it contains underscores. *)
    | t ->
      Pretty.sprint 500 (d_typsig () (typeSig t))
      (* E.s (error "unexpected type of operator argument or result: %a\n" d_type t) *)

  let toString {argument_types; result_type } =
    let ts = List.map showIntType argument_types in
    let t = showIntType result_type in
    sprintf "%s -> %s" (String.concat " * " ts) t
end


module Sym = struct
  type arity = int

  type t =
    | UnOp of unop * Type.t
    | BinOp of binop * Type.t
    | Fun of string * arity
    | CastToInt of Type.t
    | CastToPtr of Type.t
    | CastToOther of Type.t
    | PtrLen

  let unaryOpCode = function
    | Neg -> "neg"  | BNot -> "~"  |  LNot -> "!"

  let binaryOpCode = function
      | PlusA   -> "+"   | MinusA  ->  "-"   | Mult  -> "*"    | Div   -> "/"
      | Mod     -> "%"   | BAnd    ->  "&"   | BOr   -> "BOR"  | BXor  -> "XOR"
      | Shiftlt -> "<<"  | Shiftrt ->  ">>"  | LAnd  -> "&&"   | LOr   -> "LOR"

      | Eq -> "=="
      | Ne ->  "!="
      | Gt -> ">"
      | Le -> "<="
      | Lt -> "<"
      | Ge ->  ">="

      | PlusPI  -> "PlusPI"
      | IndexPI -> "PlusPI" (* sic *)
      | MinusPI -> "MinusPI"
      | MinusPP -> "MinusPP"

  let rec repeat n x =
    if n = 0 then []
    else x :: repeat (n - 1) x

  let toString = function
    | UnOp (op, t) -> sprintf "(%s: %s)" (unaryOpCode op) (Type.toString t)
    | BinOp (op, t) -> sprintf "(%s: %s)" (binaryOpCode op) (Type.toString t)
    | CastToInt t -> sprintf "(CastToInt: %s)" (Type.toString t)
    | CastToPtr t -> sprintf "(CastToPtr: %s)" (Type.toString t)
    | CastToOther t -> sprintf "(CastToOther: %s)" (Type.toString t)
    | PtrLen -> "ptrLen/0"
    | Fun (f, n) ->
      if n = 0 then sprintf "(%s : bitstring)" f
      else sprintf "(%s : %s -> bitstring)" f (String.concat " * " (repeat n "bitstring"))
end

(*************************************************)
(** {1 Visitors} *)
(*************************************************)

class crestInstrumentVisitor f =
  (*
   * Get handles to the instrumentation functions.
   *
   * NOTE: If the file we are instrumenting includes "crest.h", this
   * code will grab the varinfo's from the included declarations.
   * Otherwise, it will create declarations for these functions.
   *)
  (* let bidArg  = ("bid",  bidType,  []) in *)
  (* let fidArg  = ("fid",  fidType,  []) in *)
  (* let idArg  = ("id",  idType,  []) in *)
  let valArg  = ("val",  valType,  []) in
  (* let numArg  = ("num",  valType,  []) in *)
  (* let addrArg = ("addr", addrType, []) in *)
  (* let sizeArg = ("size", sizeType, []) in *)
  let opArg   = ("op",   strType,   []) in
  let boolArg = ("b",    boolType, []) in
  let nameArg = ("name", strType,  []) in
  let strArg  = ("strVal", strType,  []) in
  let chrArg  = ("chrVal", chrType,  []) in
  let funPtrArg = ("funPtr", funPtrType, []) in

  let mkInstFunc name args =
    let ty = TFun (voidType, Some args, false, []) in
    let func = findOrCreateFunc f ("__Crest" ^ name) ty in
      func.vstorage <- Extern ;
      func.vattr <- [Attr ("crest_skip", [])] ;
      func
  in

  let initFunc : varinfo -> varinfo = fun v ->
    let f = makeGlobalVar ("__crest_" ^ v.vname ^ "_init") (cType "void ()()" []) in
    {f with vstorage = v.vstorage}
  in

  let invokeFunc      = mkInstFunc "Invoke" [funPtrArg] in
  (* let loadFunc         = mkInstFunc "Load"  [addrArg; sizeArg; valArg] in *)
  (* let storeFunc        = mkInstFunc "Store" [addrArg; sizeArg] in *)
  (* let clearFrameFunc   = mkInstFunc "ClearFrame" [numArg] in *)
  let clearFunc        = mkInstFunc "Clear" [valArg] in
  (* let apply1Func       = mkInstFunc "Apply1" [opArg; valArg] in
  let apply2Func       = mkInstFunc "Apply2" [opArg; valArg] in *)
  let applyFunc        = mkInstFunc "Apply" [opArg] in
  let muteFunc         = mkInstFunc "Mute" [] in
  let unmuteFunc       = mkInstFunc "Unmute" [] in
  let nondetFunc       = mkInstFunc "Nondet" [] in
  let branchFunc       = mkInstFunc "Branch" [boolArg] in
  let callFunc         = mkInstFunc "Call" [nameArg; funPtrArg; valArg] in
  let callOpaqueFunc   = mkInstFunc "CallOpaque" [nameArg; funPtrArg; valArg] in
  let returnFunc       = mkInstFunc "Return" [boolArg] in
  (* let handleReturnFunc = mkInstFunc "HandleReturn" [valArg; numArg] in *)
  let storeFunc        = mkInstFunc "Store" [] in
  let loadIntFunc      = mkInstFunc "LoadInt" [valArg] in
  let bsFunc           = mkInstFunc "BS" [boolArg; valArg] in
  let loadMemFunc      = mkInstFunc "LoadMem" [] in
  let loadCStringFunc  = mkInstFunc "LoadCString" [strArg] in
  (* let loadStringFunc   = mkInstFunc "LoadString" [strArg] in *)
  let loadCharFunc     = mkInstFunc "LoadChar" [chrArg] in
  let loadTypeSizeFunc = mkInstFunc "LoadTypeSize" [strArg] in
  (* let setLenFunc       = mkInstFunc "SetLen" [] in *)
  let setPtrStepFunc   = mkInstFunc "SetPtrStep" [] in
  let loadStackPtrFunc = mkInstFunc "LoadStackPtr" [nameArg] in
  let fieldOffsetFunc  = mkInstFunc "FieldOffset" [strArg] in
  let indexOffsetFunc  = mkInstFunc "IndexOffset" [strArg] in
  let locationFunc     = mkInstFunc "Location" [strArg] in
  let doneFunc         = mkInstFunc "Done" [] in
  let truthFunc        = mkInstFunc "Truth" [] in
  let assumeDefinedFunc = mkInstFunc "AssumeDefined" [] in

  (*
   * Functions to create calls to the above instrumentation functions.
   *)
  let mkInstCall func args =
    let args' = args in
      Call (None, Lval (var func), args', locUnknown)
  in

  (* let toAddress e = CastE (addrType, e) in *)

  (* let addressOf e = toAddress (mkAddrOrStartOf e) in *)

  let toValue e =
      if isPointerType (typeOf e) then
        CastE (valType, CastE (addrType, e))
      else
        CastE (valType, e)
  in

  (* let sizeOf addr =
    match isInteger addr with
      | None    -> SizeOfE (Lval (mkMem addr NoOffset));
      | Some 0L -> integer 0
      | _       -> failwith "sizeOf: unexpected argument"
  in *)

  let mkFunAddr : varinfo -> exp = fun f ->
    mkCast (mkAddrOf (Var f, NoOffset)) funPtrType
  in

  (*
  let mkBool b =
    if b then integer 1 else integer 0
  in

  let isSignedConst = function
    | Const (CInt64 (_, kind, _)) when isSigned kind -> true
    | _ -> false
  in
  *)

  (* let mkInvoke f               = mkInstCall invokeFunc [mkFunAddr f] in *)
  (* let mkLoad addr value        = mkInstCall loadFunc [toAddr addr; sizeOf addr; toValue value] in *)
  (* let mkStore addr             = mkInstCall storeFunc [toAddr addr; sizeOf addr] in *)
  (* let mkClearFrame num         = mkInstCall clearFrameFunc [integer num] in *)
  let mkClear num              = mkInstCall clearFunc [integer num] in
  (* let mkApply1 op value        = mkInstCall apply1Func [mkString op; toValue value] in
  let mkApply2 op value        = mkInstCall apply2Func [mkString op; toValue value] in *)
  let mkApply f                = mkInstCall applyFunc [mkString (Sym.toString f)] in
  let mkMute ()                = mkInstCall muteFunc [] in
  let mkUnmute ()              = mkInstCall unmuteFunc [] in
  let mkNondet ()              = mkInstCall nondetFunc [] in
  let mkBranch b               = mkInstCall branchFunc [integer b] in
  let mkCall f nargs           = mkInstCall callFunc
                                 [mkString f.vname; mkFunAddr f; integer nargs] in
  let mkCallOpaque f nargs     = mkInstCall callOpaqueFunc
                                 [mkString f.vname; mkFunAddr f; integer nargs] in
  (* FIXME: isSym is obsolete where everything is symbolic - but still need a void indication? *)
  let mkReturn isVoid          = mkInstCall returnFunc [integer isVoid] in
  (* let mkHandleReturn value num = mkInstCall handleReturnFunc [toValue value; integer num] in *)
  let mkStore ()               = mkInstCall storeFunc [] in
  let mkLoadInt value          = mkInstCall loadIntFunc [toValue value] in
  let mkBS is_signed width     = if is_signed
                                 then mkInstCall bsFunc [integer 1; integer width]
                                 else mkInstCall bsFunc [integer 0; integer width]
                                 in
  let mkLoadMem ()             = mkInstCall loadMemFunc [] in
  let mkLoadCString s          = mkInstCall loadCStringFunc [mkString s] in
  (* let mkLoadString s           = mkInstCall loadStringFunc [mkString s] in *)
  let mkLoadChar c             = mkInstCall loadCharFunc [Const (CChr c)] in
  let mkLoadTypeSize s         = mkInstCall loadTypeSizeFunc [mkString s] in
  (* let mkSetLen ()              = mkInstCall setLenFunc [] in *)
  let mkSetPtrStep ()          = mkInstCall setPtrStepFunc [] in
  let mkLoadStackPtr name      = mkInstCall loadStackPtrFunc [mkString name] in
  let mkFieldOffset f          = mkInstCall fieldOffsetFunc [mkString (f.fname)] in
  let mkIndexOffset t          = mkInstCall indexOffsetFunc [mkString (Type.showIntType t)] in
  let mkLocation l             = mkInstCall locationFunc [mkString (Pretty.sprint 100 (d_loc () l))] in
  let mkInit v                 = mkInstCall invokeFunc [mkFunAddr (initFunc v)] in
  let mkDone ()                = mkInstCall doneFunc [] in
  let mkTruth ()               = mkInstCall truthFunc [] in
  let mkAssumeDefined ()       = mkInstCall assumeDefinedFunc [] in

  let mkRef v = mkLoadStackPtr (mkUniqueName v) in

  (* FIXME: CIL only knows about machine-dependent integer kinds? Yep, so keep thinking. *)
  (** This one doesn't set length of sizeOf, but it can be done extra if needed *)
  let rec instrumentSizeOf : typ -> instr list = function
    | TPtr _ -> [mkApply Sym.PtrLen]
    | t ->
      match sizeOf t with
      | Const (CInt64 _) as c -> [mkLoadInt c]
      | SizeOf t'             -> [mkLoadTypeSize (Pretty.sprint 100 (d_typsig () (typeSig t)))]
      | _                     -> E.s (error "instrumentSizeOf: unexpected sizeOf result")

  (** FIXME: not sound, switch to the symbolic version. *)
  (* let rec instrumentSizeOf : typ -> instr list = function t -> [mkLoadInt (SizeOf t)] *)


  (**
	  Takes the pointer type, not the base type.
	  Silently does nothing if not a pointer.
   *)
  and setPtrStep t = (instrumentSizeOf t) @ [mkSetPtrStep ()]

  and instrumentConst : constant -> instr list = function
    | CInt64 (_, ikind, _) as c ->
     [mkLoadInt (Const c); mkBS (isSigned ikind) (bytesSizeOfInt ikind)]
    | CStr   s      -> [mkLoadCString s]
    | CChr   c      -> [mkLoadChar c]
    | CWStr  _      -> E.s (error "instrumentConst: wide character strings not supported")
    | CReal  _      -> E.s (error "instrumentConst: reals not supported")
    | CEnum  _      -> E.s (error "instrumentConst: enums temporarily not supported")

  and instrumentLvalNoInit (host, offset) =

    let instrumentHost : lhost -> instr list = function
      | Var v -> [mkRef v]
      | Mem e -> instrumentExpr e
    in

    let rec instrumentOffset : typ -> offset -> instr list = fun t o ->

      let extendType : typ -> offset -> typ = fun t -> function
	| NoOffset -> t
	| Field (f, _) -> typeOffset t (Field (f, NoOffset))
	| Index (e, _) -> typeOffset t (Index (e, NoOffset))
      in

      let t' = extendType t o in
      setPtrStep t @
	match o with
	| NoOffset      -> []
	| Field (f, o') -> [mkFieldOffset f] @ (instrumentOffset t' o')
	| Index (e, o') -> (instrumentExpr e) @ [mkIndexOffset (typeOf e)] @ (instrumentOffset t' o')

    in
    (instrumentHost host) @ (instrumentOffset (typeOfLval (host, NoOffset)) offset)

  and initHost : lhost -> instr list = function
    | Var v when v.vglob && not (isFunctionType v.vtype) ->
      if isOpaque v && isPointerType v.vtype
      then begin
	[mkLoadStackPtr v.vname]
        @ setPtrStep v.vtype
        @ (instrumentLvalNoInit (Var v, NoOffset))
        @ [mkStore ()]
      end
      else [mkInit v]
    | _ -> []

  and initLval (host, offset) = initHost host

  and instrumentCast : typ -> typ -> instr list = fun t_from t_to ->
    let t_from = unrollType t_from in
    let t_to = unrollType t_to in
    let t = { Type.argument_types = [t_from]; result_type = t_to } in
    match t_from, t_to with
        (* Pointers are cast to ints for comparisons:
           if ((unsigned long )hint != (unsigned long )((void * )0))  *)
      | TInt _, TInt _  | TPtr _, TInt _ ->
        [mkApply (Sym.CastToInt t)]
      | _, TPtr _ -> [mkApply (Sym.CastToPtr t)]
        (*
          clState.end = CLIENT;
            translates to
          clState.end = (enum protEnd )0;
        *)
      | _, t_to   -> [mkApply (Sym.CastToOther t)]
      (*
      | _, _ -> E.s (error "instrumentCast: unexpected typecast: %a %a" d_type t_from d_type t_to)
      *)

  (*
   * Instrument an expression.
   *)
  and instrumentExpr e =
    match e with
      | Const c ->
          instrumentConst c

      | Lval lv ->
        checkHasAddress lv;
        initLval lv @ instrumentLvalNoInit lv @ [mkLoadMem ()]

      | SizeOf t ->
          instrumentSizeOf t @ [mkBS (isSigned !kindOfSizeOf) (bytesSizeOfInt !kindOfSizeOf)]

      | SizeOfE e ->
          instrumentSizeOf (typeOf e) @ [mkBS (isSigned !kindOfSizeOf) (bytesSizeOfInt !kindOfSizeOf)]

      | SizeOfStr s ->
          [mkLoadInt (integer (String.length s))] @ [mkBS (isSigned !kindOfSizeOf) (bytesSizeOfInt !kindOfSizeOf)]

      | UnOp (op, e, t) ->
        let argument_types = [unrollType (typeOf e)] in
        let result_type = unrollType t in
        let sym = Sym.UnOp (op, {Type. argument_types; result_type}) in
        (instrumentExpr e) @ [mkApply sym; mkDone ()]

      | BinOp (op, e1, e2, t) ->
        (* CIL doesn't do this cast for us.
           For now we assume that IULong is the right type. *)
        let e2 =
          match op with
          | IndexPI | PlusPI -> mkCast ~e:e2 ~newt:(TInt (IULong, []))
          | _ -> e2
        in
        let argument_types = [unrollType (typeOf e1); unrollType (typeOf e2)] in
        let result_type = unrollType t in
        let sym = Sym.BinOp (op, {Type. argument_types; result_type}) in
        (instrumentExpr e1) @ (instrumentExpr e2) @ [mkApply sym; mkDone ()]

      | CastE (t, e) ->
        (* Unroll to see through typedefs *)
        begin match unrollType t with
          | TPtr (t', _) when isZero e -> [mkLoadStackPtr "nullPtr"] @ (setPtrStep t')
          | TPtr (t', _) -> instrumentExpr e @ instrumentCast (typeOf e) t @ (setPtrStep t') @ [mkDone ()]
          | _ ->            instrumentExpr e @ instrumentCast (typeOf e) t @ [mkDone ()]

          (* else if isPointerType t && not (isPointerType (typeOf e)) then
            E.s (error "instrumentExpr: cast to pointer of non-zero expression") *)
        end

      | AddrOf lv ->
        initLval lv @ instrumentLvalNoInit lv

      | StartOf lv ->
        let lv = addOffsetLval (Index (zero, NoOffset)) lv in
        initLval lv @ instrumentLvalNoInit lv

      | AlignOf _
      | AlignOfE _
      | Question _
      | AddrOfLabel _ ->
        E.s (error "unsupported expression: %a" d_exp e)

  and instrumentAssignment ?(do_init = true) lv e =
    (if do_init then initLval lv else [])
    @ instrumentExpr e
    @ instrumentLvalNoInit lv
    @ [mkStore ()]

  and instrumentInit : varinfo -> init -> instr list = fun v init ->
    let rec instr : lval -> init -> instr list = fun lv -> function
      | SingleInit e ->
        instrumentAssignment ~do_init:false lv e
      | CompoundInit (_, inits) ->
        concat (map (function (o, i) -> instr (addOffsetLval o lv) i) inits)
    in
    instr (Var v, NoOffset) init

  and instrumentResult : typ -> string -> exp list -> instr list = fun t fname args ->
    match t with
    | TVoid _ -> [mkClear (length args)]
    | TPtr (t, _) -> [mkClear (length args); mkLoadStackPtr (fname ^ "()"); mkNondet ()] @ (setPtrStep t)
    | _ -> [mkApply (Sym.Fun (fname ^ "()", length args)); mkNondet ()]
  in

  (*
    A function wrapper.

    The reason we can't just intercept at the call site is that this could be called
    through a pointer.  *)
  let opaqueWrapper : varinfo -> global list = fun v ->

    (* in calls to vararg funs we don't put parameters on stack *)
    if isVarargFunType v.vtype then []
    else if StrSet.mem v.vname !opaqueWrappers then []
    else
      begin
	opaqueWrappers := StrSet.add v.vname !opaqueWrappers;

	let nameFormal : varinfo -> varinfo = fun v ->
	  if v.vname = "" then v.vname <- "__crest_tmp" ^ (string_of_int (getNewId ()));
	  v
	in

	let v' = opaque v in
	let f = emptyFunction "" in
	f.svar <- v';
	setFunctionTypeMakeFormals f (typeOfLval (Var v', NoOffset));
	setFormals f (map nameFormal f.sformals);

	let returnType = funReturnType v'.vtype in
	let args = map (fun v -> Lval (Var v, NoOffset)) f.sformals in

	let (call, returnInstrumentation, returnInstruction) =
	  if isVoidType returnType then
	    (Call (None, Lval (Var v, NoOffset), args, locUnknown),
             [mkReturn 1],
             [])
	  else
	    let ret = makeLocalVar f "__crest_ret" returnType in
	    (Call (Some (Var ret, NoOffset), Lval (Var v, NoOffset), args, locUnknown),
             [mkReturn 1],
	     [Return (Some (Lval (Var ret, NoOffset)), locUnknown)])
	in

	let opaqueResult = instrumentResult returnType v.vname args in
	let body =
          [Instr ([mkCallOpaque v (List.length f.sformals)]
                  @ opaqueResult
                  @ [mkMute (); call; mkUnmute ()]
                  @ returnInstrumentation)]
          @ returnInstruction
        in

	f.sbody.bstmts <- map mkStmt body;
	[GFun (f, locUnknown)]
      end
  in

object (self)
  inherit nopCilVisitor

  (*
   * Instrument a statement (branch or function return).
   *)
  method vstmt(s) =
    match s.skind with
      | If (e, b1, b2, l) ->
        self#queueInstr [mkLocation l];
        self#queueInstr (instrumentExpr e) ;
        self#queueInstr [mkTruth ()] ;
        prependToBlock [mkBranch 1] b1 ;
        prependToBlock [mkBranch 0] b2 ;
        DoChildren

      | Return (Some e, l) ->
          self#queueInstr [mkLocation l];
          self#queueInstr (instrumentExpr e) ;
          self#queueInstr [mkReturn 0];
          (*
            (*
              OLD: This is for the case we are doing custom return - some overhead, but can be simplified in the static tool
              NEW: The code for the custom return should deal with setting the length. This will eliminate calling SetLen on
                a value twice.
            *)
          self#queueInstr (setLen (typeOf e));
          *)
          SkipChildren

      | Return (None, l) ->
          self#queueInstr [mkLocation l];
          self#queueInstr [mkReturn 1] ;
          SkipChildren

      | _ -> DoChildren

  (*
   * Instrument assignment and call statements.
   *)
  method vinst(i) =
    match i with
    | Set (lv, e, l) ->
      self#queueInstr [mkLocation l];
      checkHasAddress lv;
      self#queueInstr (instrumentAssignment lv e);
      SkipChildren

    (* Don't instrument calls to instrumentation functions themselves. *)
    | Call (_, Lval (Var f, NoOffset), _, _) when shouldSkipFunction f ->
      SkipChildren

    | Call (ret, Lval f, args, l) ->

      let t = typeOfLval f in
      let call =
        if isVarargFunType t
        then
          [mkMute(); i; mkUnmute ()]
          @ instrumentResult (funReturnType t) "vararg_result" args
        else [i]
      in

      let init_ret, assign_ret =
        match ret with
	| Some lv ->
	  checkHasAddress lv;
	  initLval lv, (instrumentLvalNoInit lv @ [mkStore ()])
	| _ ->
	  if isVoidFunType t then [], [] else [], [mkClear 1]
      in
      ChangeTo ([mkLocation l]
                @ init_ret
                @ concatMap instrumentExpr args
                @ call
                @ assign_ret)

      (* FIXME: for functions called through pointers make sure they are not symbolic *)
    | _ -> DoChildren


  (*
   * Instrument function entry.
   *)
  method vfunc (f: fundec) =
    (* ignore (Pretty.printf "entering function %a\n" d_lval (Var f.svar, NoOffset)); *)
    if shouldSkipFunction f.svar then
      SkipChildren
    else
      let instParam v =
        let lv = (Var v, NoOffset) in
        initLval lv @ instrumentLvalNoInit lv @ [mkStore ()]
      in
      let (_, _, isVarArgs, _) = splitFunctionType f.svar.vtype in
        if (not isVarArgs) then
          iter (flip prependToBlock f.sbody) (List.map instParam f.sformals)
        else
          E.s (error "varargs not supported, each vararg function must be declared opaque, f: %s\n" f.svar.vname);
        prependToBlock [mkCall f.svar (List.length f.sformals)] f.sbody;
        DoChildren

  method vglob = function
  | GVar (v, {init = i}, loc) as g ->

    assert (v.vstorage <> Extern);

    (*
      ignore (Pretty.printf "crestifying global %a\n" (printGlobal plainCilPrinter) g);
    *)

    markCrestified v;
    let f = emptyFunction ("__crest_" ^ v.vname ^ "_init") in
    let initialised =
      makeGlobalVar ("__crest_" ^ v.vname ^ "_initialised") boolType
    in
    let doInit =
      if isOpaque v
      then FI ([mkApply (Sym.Fun (v.vname, 0));
                mkAssumeDefined ()]
               @ (instrumentLvalNoInit (Var v, NoOffset))
               @ [mkStore ()])
      else match i with
      | (Some init) -> FI (instrumentInit v init)
      | None        -> FI []
    in
    let body =
      [mkStmtOneInstr (mkCall f.svar (List.length f.sformals))]
      @
        cStmts
        "if(!initialised) {initialised = 1; {%I:doInit}}"
        (fun n t -> makeTempVar f ~name:n t)
        loc
        [ ("initialised", Fv initialised); ("doInit", doInit) ]
      @
        [mkStmtOneInstr (mkReturn 1)]
    in
    f.sbody.bstmts <- body;

      (* Sometimes a global is defined in a header without extern, like in
         rergress.h in cryptokix.  I don't really know how that is valid C.
         This usually correlated with giving the global no declaration and no
         initialisation, so we choose to make the function static to prevent
         multiple definition errors. *)
    if i = None && not (isOpaque v)
    then begin
        (*
	  f.svar.vstorage <- Static;
	  initialised.vstorage <- Static;
        *)
      E.s (error "globals without initialisers must be declared opaque: %a\n" d_global g);
    end;

    ChangeTo [g;
              GVar (initialised, {init = Some (SingleInit (integer 0))}, loc);
              GFun (f, loc)]

  | GFun (f, loc) as g ->
      (* ignore (Pretty.printf "visiting function definition %a\n" (printGlobal defaultCilPrinter) g); *)
      (* FIXME: why are functions for which we introduce an opaque wrapper considered crestified? *)
      (* FIXME: looks like the svar here is never static? *)
    markCrestified f.svar;
    if needsOpaqueWrapper f.svar then
      begin
        (* ignore (Pretty.printf "the function needs an opaque wrapper\n"); *)
        (* opaqueDefNames := f.svar.vname :: !opaqueDefNames; *)
        ChangeTo ([g] @ opaqueWrapper f.svar)
      end
    else
      begin
        (* ignore (Pretty.printf "the function doesn't need an opaque wrapper\n"); *)
        DoChildren
      end

  | GVarDecl (v, loc) as g when needsOpaqueWrapper v ->
      (* ignore (Pretty.printf "visiting function declaration %a\n" (printGlobal defaultCilPrinter) g); *)
      (* The reason we put a definition here is that some opaque functions might be defined in non-crestified code. *)
    ChangeTo ([g] @ opaqueWrapper v)

  | GVarDecl (v, loc) as g when not (isOpaque v) && not (isFunctionType v.vtype) ->
    let f = initFunc v in
    ChangeTo [g; GVarDecl (f, loc)]

  | _ -> DoChildren

end

class opaqueReplaceVisitorClass = object
  inherit nopCilVisitor

  method vvrbl : varinfo -> varinfo visitAction = function
      (*
        This replaces calls to all opaque f() by calls to __crest_f_opaque(),
        the definition of which is created by opaqueWrapper.
      *)
    | v when needsOpaqueWrapper v -> ChangeTo (opaque v)
    | _ -> SkipChildren

end

let addCrestInitializer f =
  let crestInitTy = TFun (voidType, Some [], false, []) in
  let crestInitFunc = findOrCreateFunc f "__CrestInit" crestInitTy in
  let globalInit = getGlobInit f in
  if not f.globinitcalled then
    f.globinit <- None
  else
  begin
    crestInitFunc.vstorage <- Extern ;
    crestInitFunc.vattr <- [Attr ("crest_skip", [])] ;
    prependToBlock [Call (None, Lval (var crestInitFunc), [], locUnknown)]
                   globalInit.sbody
  end

open Machdep

let feature : featureDescr =
  { fd_name = "CrestInstrument";
    fd_enabled = ref false;
    fd_description = "instrument a program for symbolic execution";
    fd_extraopt = [
      ("--root",
       Arg.String setRootPath,
       " The root folder of the compilation.");
      ("--csec-config", Arg.String (fun s -> Mark.config := s),
       " The csec instrumentation configuration file.");
    ];
    fd_post_check = true;
    fd_doit =
      function (f: file) ->
        setSrcPath f;
        if not (Mark.shouldSkip f)
        then begin
	  Mark.markGlobals f;
	    (* Simplify the code:
	     *  - simplifying expressions with complex memory references
	     *  - converting loops and switches into goto's and if's (* FIXME: do I like this? *)
	     *  - transforming functions to have exactly one return *)
          Simplemem.feature.fd_doit f ;
	    (* iterGlobals f prepareGlobalForCFG ; *)
          Oneret.feature.fd_doit f ;
	    (* Finally instrument the program. *)
	  visitCilFile (new opaqueReplaceVisitorClass) f;
	  let instVisitor = new crestInstrumentVisitor f in
	  visitCilFile (instVisitor :> cilVisitor) f;
	    (* Add a function to initialize the instrumentation library. *)
	  addCrestInitializer f ;
	  writeInfo f
        end
  }

