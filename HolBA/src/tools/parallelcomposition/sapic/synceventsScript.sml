open HolKernel Parse boolLib bossLib;

val _ = new_theory "syncevents";

    
(* Synchronize Event *)

val _ = Datatype `sync_event =
    P2A 'v
| A2P 'v
| Crypto ('s # 'v list # 'v)
    | Sync_Fr 'n
                `;
                

val _ = export_theory();
