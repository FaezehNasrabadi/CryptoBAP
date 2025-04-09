structure sbir_treeLib =
struct
local
    open HolKernel Parse;
    open HolBACoreSimps;
    open HolBASimps;
    open boolSyntax;
    open pred_setTheory;
    open simpLib;
    open bossLib;
    open bir_symbexec_stateLib;
    open Option;
    open List;

  val ERR      = Feedback.mk_HOL_ERR "sbir_treeLib"
  val wrap_exn = Feedback.wrap_exn   "sbir_treeLib"
in

fun is_true b = ((lift_bool “:bool” b) ~~ T)
		
fun is_false b = ((lift_bool “:bool” b) ~~ F)

fun is_true_list [] = true
  | is_true_list (h::t) =
    if (is_true h)
    then (is_true_list t)
    else false		 
		
fun allHeadsEqual ([]: term list list) = false
  | allHeadsEqual (lst: term list list) =
  if ((not o null o hd) lst)
  then
      let
	  val hdOfFirstList = hd lst
	  val result = ((List.map (fn ls => if (is_true (identical (hd hdOfFirstList) (hd ls))) then true else raise ERR "" "") lst) handle _ => [false]);
      in
	  if (is_false (hd result))
	  then false
	  else true
      end
  else false;
 

(* Define a datatype for trees *)
datatype 'a tree = Leaf | Node of 'a * 'a tree | Branch of 'a * 'a tree * 'a tree;

(* Helper function to check if all lists in a list are empty *)
fun all_empty lsts = List.all null lsts

(* Helper function to check if a list is not empty *)
fun not_empty ls = not (null ls)

fun prtion (lst: term list list) = case lst of
				       ([]: term list list) => ([], [])
				     | ([[]]: term list list) => ([], [])
				     | ((h::_): term list list) => 
				       let
					   val head_val = ((hd h):term) 
				       in
					   List.partition (fn (ls: term list) => (identical (hd ls) head_val)) lst
				       end
				       
(* Main function to convert predicate lists to tree *)
fun predlist_to_tree ([[]]: term list list) = Leaf
  | predlist_to_tree ([]: term list list) = Leaf
  | predlist_to_tree (lsts: term list list) =    
    if all_empty lsts then Leaf
    else
	let
           
            val (empty, notempty) = List.partition null lsts

	    val (head_eq, head_noteq) = prtion notempty;
	in    
	    if null head_noteq then
		Node (hd (hd head_eq), predlist_to_tree (List.map tl head_eq))
	    else
		
		    Branch (
		    
		    hd (hd head_noteq),
		  
		    (predlist_to_tree (List.map (fn ls => (tl ls)) head_noteq))handle _ => raise ERR "predlist_to_tree" ("cannot do it "^(String.concat(List.map (fn ls => ("|n"^((int_to_string o List.length) ls))) head_eq))),
		  
		    (predlist_to_tree (List.map (fn ls => (tl ls)) head_eq))handle _ => raise ERR "predlist_to_tree" ("cannot do it "^(String.concat(List.map (fn ls => ("|n"^((int_to_string o List.length) ls))) head_noteq)))
		    )
	end 

	 


(*Find bir expression*)
fun find_be_val vals_list bv =
    let
	val find_val = List.find (fn (a,_) => Term.term_eq a bv) vals_list;
	val (bv_str, _) = bir_envSyntax.dest_BVar_string bv;
	val fr = get_bvar_fresh (bir_envSyntax.mk_BVar_string (bv_str, “BType_Bool”)); 
	val symbv = ((snd o Option.valOf) find_val) handle _ => SymbValBE (fr, Redblackset.empty Term.compare) ;
	val exp =
	    case symbv of
		SymbValBE (x, _) => x
              | _ => raise ERR "find_be_val" "cannot handle symbolic value type";
    in
	exp
    end;


(* Define a datatype for trees with values *)
datatype 'a valtree = VLeaf | VNode of ('a * 'a) * 'a valtree | VBranch of ('a * 'a) * 'a valtree * 'a valtree;

	 
fun tree_with_value tr sort_vals =
    case tr of
	Leaf => VLeaf
      | Node (bv, subtr) => VNode ((bv,(find_be_val sort_vals bv)), (tree_with_value subtr sort_vals))
      | Branch (bv, subtr1, subtr2) => VBranch ((bv,(find_be_val sort_vals bv)), (tree_with_value subtr1 sort_vals), (tree_with_value subtr2 sort_vals))


fun hd_of_tree tr =
    case tr of
	VLeaf => NONE
      | VNode ((bv,be), subtr) => SOME (bv,be)
      | VBranch ((bv,be), subtr1, subtr2) => SOME (bv,be)


fun areIdentical bv x =
    if (bir_expSyntax.is_BExp_Den x andalso bir_expSyntax.is_BExp_Den bv) orelse (bir_envSyntax.is_BVar x andalso bir_envSyntax.is_BVar bv) orelse (bir_envSyntax.is_bir_var_name x andalso bir_envSyntax.is_bir_var_name bv) then
        identical x bv
	 else if stringSyntax.is_string bv then
        identical x (bir_envSyntax.mk_BVar (bv, “BType_Imm Bit64”))
    else if stringSyntax.is_string x then
        identical (bir_envSyntax.mk_BVar (x, “BType_Imm Bit64”)) bv
    else
        raise ERR "areIdentical " ((term_to_string bv) ^ " compare to " ^ (term_to_string x))

	      
fun trmunion(xs: term list, ys: term list) = foldl (fn (x, acc) => if List.exists (fn y => (identical x y)) acc then acc else x::acc) ys xs
					     
fun liveVars tr = 
    case tr of
	VLeaf => ((Redblackset.empty Term.compare): term Redblackset.set)
      | VNode ((bv,be), subtr) =>
	let
            val subtrLive = ((liveVars subtr): term Redblackset.set);
            val exprLive =  if (bir_envSyntax.is_BVar be)
			    then [be]
			    else ((bir_exp_helperLib.get_birexp_vars be)handle _ =>
									       let
										   val (name,trms) = strip_comb be;
									       in
										   trms
									       end
									       
				 );
	    val strLive = List.map (fn x => (fst o bir_envSyntax.dest_BVar) x) exprLive;
	    val combinedLive = Redblackset.addList(subtrLive,strLive);
        in
            (combinedLive: term Redblackset.set)
        end
      | VBranch ((bv,be), subtr1, subtr2) =>
	let
            val leftLive = liveVars subtr1;
            val rightLive = liveVars subtr2;
	    val combinedLive = Redblackset.union(leftLive,rightLive);
        in
            (combinedLive: term Redblackset.set)
        end
	
	
fun purge_tree tr =
    case tr of
	VLeaf => VLeaf
      | VNode ((bv,be), subtr) =>
	if (isSome (hd_of_tree subtr)) then
	    if ((identical ((fst o valOf o hd_of_tree) subtr) bv) andalso (identical ((snd o valOf o hd_of_tree) subtr) be))
	    then (purge_tree subtr)
	    else VNode ((bv,be), (purge_tree subtr))
	else VNode ((bv,be), (purge_tree subtr))
      | VBranch ((bv,be), subtr1, subtr2) =>
	if (identical be “BExp_Const (Imm1 1w)”)
	then (purge_tree subtr1)
	else if (identical be “BExp_Const (Imm1 0w)”)
	then (purge_tree subtr2)
	else VBranch ((bv,be), (purge_tree subtr1), (purge_tree subtr2))
	     


end (* local *)

end (* struct *)
