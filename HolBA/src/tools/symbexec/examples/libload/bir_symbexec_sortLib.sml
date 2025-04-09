structure bir_symbexec_sortLib =
struct

local
    open HolKernel Parse boolLib pairLib hol88Lib numLib reduceLib tautLib
		   pairTheory numTheory prim_recTheory arithmeticTheory
		   realTheory Ho_Rewrite jrhUtils Canon_Port AC numSyntax Arbint;

    open List;
    open bir_envSyntax;
    open bir_immSyntax;
    open bir_expSyntax;
    open bir_exp_immSyntax;
    open Int;
open bir_programSyntax;    

    val ERR = Feedback.mk_HOL_ERR "bir_symbexec_sortLib"

in


fun sint_of_term_m tm =
    let open Arbnum bir_envSyntax  bir_immSyntax bir_expSyntax  bir_exp_immSyntax; in
  tm |> dest_BL_Address |> dest_Imm64 |> wordsSyntax.dest_word_literal |> Arbnum.toInt
  handle  Overflow => raise ERR "sint_of_term"
                       ("integer " ^ term_to_string tm ^ " too large")
       | Feedback.HOL_ERR _ => raise ERR "sint_of_term"
                       ("could not convert ``" ^ term_to_string tm ^
                        "`` to an integer")
  end;
    
fun swap_m(A,i,j) = 
    let
        val t = Array.sub(A,i)
    in
        Array.update(A,i,Array.sub(A,j));
        Array.update(A,j,t)
    end;

fun firstAfter_m(A,i,f) =
    if f(Array.sub(A,i)) then i else firstAfter_m(A,i+1,f);

fun lastBefore_m(A,j,f) =
    if f(Array.sub(A,j)) then j else lastBefore_m(A,j-1,f);

fun partition1_m(A,lo,hi)=
    let 
        fun partition'(A,lo,hi,pivot) = 
            let 
                val i = firstAfter_m(A,lo,fn k => (sint_of_term_m)k >= pivot);
                val j = lastBefore_m(A,hi,fn k => (sint_of_term_m)k <= pivot);
            in
                if i >= j then 
                    j
                else
                (
                    swap_m(A,i,j);
                    partition'(A,i+1,j-1,pivot)
                 )
             end
   in
      partition'(A,lo,hi,(sint_of_term_m)(Array.sub(A,lo)))
    end;

fun quicksort_m(A,lo,hi) = 
    if hi <= lo then
        ()
    else
        let
            val p = partition1_m(A,lo,hi)
        in
            (
                quicksort_m(A,lo,p);
                quicksort_m(A,p+1,hi)
             )
        end;

fun qsort_m A = quicksort_m(A,0,Array.length A - 1);

fun arrayToList_m arr = Array.foldr (op ::) [] arr;

(* sort of list of preds based on its length*)

fun partition1_l(A,lo,hi)=
    let 
        fun partition'(A,lo,hi,pivot) = 
            let 
                val i = firstAfter_m(A,lo,fn k => (List.length)k >= pivot);
                val j = lastBefore_m(A,hi,fn k => (List.length)k <= pivot);
            in
                if i >= j then 
                    j
                else
                (
                    swap_m(A,i,j);
                    partition'(A,i+1,j-1,pivot)
                 )
             end
   in
      partition'(A,lo,hi,(List.length)(Array.sub(A,lo)))
    end;

fun quicksort_l(A,lo,hi) = 
    if hi <= lo then
        ()
    else
        let
            val p = partition1_l(A,lo,hi)
        in
            (
                quicksort_l(A,lo,p);
                quicksort_l(A,p+1,hi)
             )
        end;

fun qsort_l A = quicksort_l(A,0,Array.length A - 1);

fun arrayToList_l arr = Array.foldr (op ::) [] arr;

    (* val pred = [["b","c"],["a"]]  *)
fun sort_pred_lists pred =
    let

	val A = Array.fromList pred;

	val _ = qsort_l A;

	val sort_pred = arrayToList_l A;
  
    in
	sort_pred
    end;
    
(*sort pred*)

fun sint_of_bv_m tm =
    let open Arbnum Int Option in
  tm |> fst |> bir_envSyntax.dest_BVar_string |> fst |> explode |> bir_auxiliaryLib.list_split_pred #"_" |> fst |> implode |> Int.fromString |> valOf
  handle Overflow => raise ERR "sint_of_bv"
                       ("integer " ^ term_to_string (fst tm) ^ " too large")
       | HOL_ERR _ => raise ERR "sint_of_bv"
                       ("could not convert ``" ^ term_to_string (fst tm) ^
                        "`` to an integer")
			    end;
    
fun swap_b(A,i,j) = 
    let
        val t = Array.sub(A,i)
    in
        Array.update(A,i,Array.sub(A,j));
        Array.update(A,j,t)
    end;

fun firstAfter_b(A,i,f) =
    if f(Array.sub(A,i)) then i else firstAfter_b(A,i+1,f);

fun lastBefore_b(A,j,f) =
    if f(Array.sub(A,j)) then j else lastBefore_b(A,j-1,f);

fun partition1_b(A,lo,hi)=
    let 
        fun partition'(A,lo,hi,pivot) = 
            let 
                val i = firstAfter_b(A,lo,fn k => (sint_of_bv_m)k >= pivot);
                val j = lastBefore_b(A,hi,fn k => (sint_of_bv_m)k <= pivot);
            in
                if i >= j then 
                    j
                else
                (
                    swap_b(A,i,j);
                    partition'(A,i+1,j-1,pivot)
                 )
             end
   in
      partition'(A,lo,hi,(sint_of_bv_m)(Array.sub(A,lo)))
    end;

fun quicksort_b(A,lo,hi) = 
    if hi <= lo then
        ()
    else
        let
            val p = partition1_b(A,lo,hi)
        in
            (
                quicksort_b(A,lo,p);
                quicksort_b(A,p+1,hi)
             )
        end;

fun qsort_b A = quicksort_b(A,0,Array.length A - 1);

fun arrayToList_b arr = Array.foldr (op ::) [] arr;
    
fun refine_symb_val_list symbv =
    let

	val A = Array.fromList symbv;

	val _ = qsort_b A;

	val sort_symbv = arrayToList_b A;
  
    in
	sort_symbv
    end;
        
    
(* Define a function to print a single list *)
fun printList [] = ()
  | printList (x::xs) =
    (print (((fst o bir_envSyntax.dest_BVar_string) x) ^ ","); printList xs);

(* Define a function to print a list of lists *)
fun printTermList [] = ()
  | printTermList (lst::rest) =
    (printList lst; print "\n"; printTermList rest);
  
(* Function to remove duplicates while keeping the first occurrence *)
fun removeDuplicates lst =
    let
        fun helper([], _, acc) = List.rev acc
          | helper(x::xs, seen, acc) =
                if List.exists (fn y => (((fst o bir_envSyntax.dest_BVar_string) x) = ((fst o bir_envSyntax.dest_BVar_string) y))) seen then
                    helper(xs, seen, acc)
                else
                    helper(xs, x::seen, x::acc)
    in
        helper(lst, [], [])
    end;
    
end(*local*)

end (* struct *) 
