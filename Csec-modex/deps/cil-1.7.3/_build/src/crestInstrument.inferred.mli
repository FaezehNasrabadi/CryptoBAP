module E = Errormsg
val opaqueWrappers : Common.StrSet.t ref
val idCount : int ref
val isSome : 'a option -> bool
val concatMap : ('a -> 'b list) -> 'a list -> 'b list
val getNewId : unit -> int
val noAddr : Cil.exp
val shouldSkipFunction : Cil.varinfo -> bool
val prependToBlock : Cil.instr list -> Cil.block -> unit
val idType : Cil.typ
val bidType : Cil.typ
val fidType : Cil.typ
val valType : Cil.typ
val chrType : Cil.typ
val addrType : Cil.typ
val sizeType : Cil.typ
val boolType : Cil.typ
val opType : Cil.typ
val strType : Cil.typ
val funPtrType : Cil.typ
val checkHasAddress : 'a * Cil.offset -> unit
val funReturnType : Cil.typ -> Cil.typ
val isVoidFunType : Cil.typ -> bool
val isVarargFunType : Cil.typ -> bool
val opaque : Cil.varinfo -> Cil.varinfo
val needsOpaqueWrapper : Cil.varinfo -> bool
module Type :
  sig
    type t = { argument_types : Cil.typ list; result_type : Cil.typ; }
    val showSigned : bool -> string
    val showIntType : Cil.typ -> string
    val toString : t -> string
  end
module Sym :
  sig
    type arity = int
    type t =
        UnOp of Cil.unop * Type.t
      | BinOp of Cil.binop * Type.t
      | Fun of string * arity
      | CastToInt of Type.t
      | CastToPtr of Type.t
      | CastToOther of Type.t
      | PtrLen
    val unaryOpCode : Cil.unop -> string
    val binaryOpCode : Cil.binop -> string
    val repeat : int -> 'a -> 'a list
    val toString : t -> string
  end
class crestInstrumentVisitor :
  Cil.file ->
  object
    method queueInstr : Cil.instr list -> unit
    method unqueueInstr : unit -> Cil.instr list
    method vattr : Cil.attribute -> Cil.attribute list Cil.visitAction
    method vattrparam : Cil.attrparam -> Cil.attrparam Cil.visitAction
    method vblock : Cil.block -> Cil.block Cil.visitAction
    method vexpr : Cil.exp -> Cil.exp Cil.visitAction
    method vfunc : Cil.fundec -> Cil.fundec Cil.visitAction
    method vglob : Cil.global -> Cil.global list Cil.visitAction
    method vinit :
      Cil.varinfo -> Cil.offset -> Cil.init -> Cil.init Cil.visitAction
    method vinitoffs : Cil.offset -> Cil.offset Cil.visitAction
    method vinst : Cil.instr -> Cil.instr list Cil.visitAction
    method vlval : Cil.lval -> Cil.lval Cil.visitAction
    method voffs : Cil.offset -> Cil.offset Cil.visitAction
    method vstmt : Cil.stmt -> Cil.stmt Cil.visitAction
    method vtype : Cil.typ -> Cil.typ Cil.visitAction
    method vvdec : Cil.varinfo -> Cil.varinfo Cil.visitAction
    method vvrbl : Cil.varinfo -> Cil.varinfo Cil.visitAction
  end
class opaqueReplaceVisitorClass :
  object
    method queueInstr : Cil.instr list -> unit
    method unqueueInstr : unit -> Cil.instr list
    method vattr : Cil.attribute -> Cil.attribute list Cil.visitAction
    method vattrparam : Cil.attrparam -> Cil.attrparam Cil.visitAction
    method vblock : Cil.block -> Cil.block Cil.visitAction
    method vexpr : Cil.exp -> Cil.exp Cil.visitAction
    method vfunc : Cil.fundec -> Cil.fundec Cil.visitAction
    method vglob : Cil.global -> Cil.global list Cil.visitAction
    method vinit :
      Cil.varinfo -> Cil.offset -> Cil.init -> Cil.init Cil.visitAction
    method vinitoffs : Cil.offset -> Cil.offset Cil.visitAction
    method vinst : Cil.instr -> Cil.instr list Cil.visitAction
    method vlval : Cil.lval -> Cil.lval Cil.visitAction
    method voffs : Cil.offset -> Cil.offset Cil.visitAction
    method vstmt : Cil.stmt -> Cil.stmt Cil.visitAction
    method vtype : Cil.typ -> Cil.typ Cil.visitAction
    method vvdec : Cil.varinfo -> Cil.varinfo Cil.visitAction
    method vvrbl : Cil.varinfo -> Cil.varinfo Cil.visitAction
  end
val addCrestInitializer : Cil.file -> unit
val feature : Cil.featureDescr
