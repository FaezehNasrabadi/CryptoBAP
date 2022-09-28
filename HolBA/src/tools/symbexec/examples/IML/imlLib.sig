signature imlLib =
sig
    include Abbrev
    type ITerm;
    type IExp;
    type IML_Stmt;

    val ITerm_to_string     : ITerm -> string
    val IExp_to_string      : IExp -> string
    val to_string           : IML_Stmt -> unit

end
