open Common

type t =
  { time : float
  ; calls : int
  }

let the_table = Hashtbl.create 100

let zero () =
  { time = 0.
  ; calls = 0
  }

let call name f =
  let start_time = Sys.time () in
  let result = with_debug name f in
  let end_time = Sys.time () in
  let { time; calls } = Hashtbl.find_or_add the_table name ~default:zero in
  let t =
    { time = time +. (end_time -. start_time)
    ; calls = calls + 1
    }
  in
  Hashtbl.replace the_table name t;
  result

let print () =
  Hashtbl.iter the_table ~f:(fun name t ->
    let {time; calls} = t in
    Printf.eprintf "%s called %d times, total %f seconds\n"
      name calls time)
