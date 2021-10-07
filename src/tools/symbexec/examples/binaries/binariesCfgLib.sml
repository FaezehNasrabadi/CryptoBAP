structure binariesCfgLib =
struct
local

  open binariesLib;
  open binariesDefsLib;

  open bir_cfgLib;
  open bir_cfg_m0Lib;

  open bir_block_collectionLib;

in (* local *)



(*

(*
val cfg_targets_to_lbl_tms = cfg_targets_to_lbl_tms;
*)

fun find_node n_dict lbl_tm =
  valOf (lookup_block_dict n_dict lbl_tm)
  handle Option => raise ERR "find_node" ("couldn't find node " ^ (term_to_string lbl_tm));


fun get_fun_cfg_walk_succ (n: cfg_node) =
  let
    val lbl_tm    = #CFGN_lbl_tm n;
    val descr_o   = #CFGN_hc_descr n;
    val n_type    = #CFGN_type n;
    val n_targets = #CFGN_targets n;
    val debug_on = false;

    val descr = case descr_o of
                   SOME x => x
                 | NONE => raise ERR "get_fun_cfg_walk_succ"
                                     ("need node description text from lifter: " ^ (term_to_string lbl_tm));

    val _ = if not debug_on then () else
            print ("node: " ^ (term_to_string lbl_tm) ^ "\n" ^
                   " - " ^ descr ^ "\n");
  in
    case n_type of
        CFGNT_Halt      => []
      | CFGNT_Jump      => n_targets
      | CFGNT_CondJump  => n_targets
      | CFGNT_Basic     => n_targets
      | CFGNT_Call cs   => (* this accounts for a walk that
                              doesn't follow call edges *)
                           cs
      | CFGNT_Return    => [] (* this terminates returns *)
  end;


fun build_fun_cfg_nodes _  acc []                     = acc
  | build_fun_cfg_nodes n_dict acc (lbl_tm::lbl_tm_l) =
      let
        val n         = find_node n_dict lbl_tm;
        val n_type    = #CFGN_type n;
        val n_targets = #CFGN_targets n;

        val _ = if not (cfg_node_type_eq (n_type, CFGNT_Halt)) andalso
                   not (List.null n_targets) then () else
                (print "indirection ::: in ";
                 print (prog_lbl_to_mem_rel_symbol lbl_tm);
                 print "\t"; print (valOf (#CFGN_hc_descr n) handle Option => "NONE");
                 print "\t"; print_term lbl_tm);

        val new_nodes = lbl_tm::acc;

        val next_tm_l      =
              List.filter (fn x => not ((List.exists (fn y => identical x y) (new_nodes@lbl_tm_l))))
                          (get_fun_cfg_walk_succ n);
        val new_lbl_tm_l   = next_tm_l@lbl_tm_l;
      in
        build_fun_cfg_nodes n_dict new_nodes new_lbl_tm_l
      end;


fun lbl_tm_to_rel_symbol lbl_tm =
  (valOf o mem_find_rel_symbol_by_addr_ o dest_lbl_tm) lbl_tm;

fun node_to_rel_symbol (n:cfg_node) =
  lbl_tm_to_rel_symbol (#CFGN_lbl_tm n);

fun build_fun_cfg bl_dict n_dict name =
  let
    val entry_lbl_tm = mem_symbol_to_prog_lbl name;
    val cfg_comp_lbls = build_fun_cfg_nodes n_dict [] [entry_lbl_tm];
    val _ = print ("walked " ^ (Int.toString (length cfg_comp_lbls)) ^
                   " nodes (" ^ name ^ ")\n");
    (* validate that all collected nodes belong to the function *)
    val ns_names   = List.map (lbl_tm_to_rel_symbol) cfg_comp_lbls
      handle Option => raise ERR "build_fun_cfg" "cannot find label for node address";
    val allAreName = List.foldr (fn (n,b) => b andalso (
           n = name
      )) true ns_names;
  in
    {
      CFGG_name       = name,
      CFGG_entries    = [entry_lbl_tm],
      CFGG_exits      = [], (* this is not right *)
      CFGG_nodes      = cfg_comp_lbls,
      CFGG_node_dict  = n_dict,
      CFGG_block_dict = bl_dict
    } : cfg_graph
  end;


(*


end (* local *)
end (* struct *)
||||||| empty tree
