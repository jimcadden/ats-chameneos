absview chameneos_v (int)
absview memlock_v () // accessing shared memory
absview inpool_v (int) // semaphore(2)
absview first_v () // semaphore(1)

abst@ype color
assume color = int // temp to appease typechecker

(* ****** ****** *)

(*
extern
fun identify_chameneos ()
 : (chameneos_v ch | (*void*)) = "identify_chameneos"
*)

(* ****** ****** *)

(*
extern
fun remove_chameneos
 {ch:int}
 (pf: chameneos_v ch) : () = "remove_chameneos"
*)

(* ****** ****** *)

extern
fun try_enter_pool
 {ch:int}
 (pf: !chameneos_v ch | (*void*))
 : [b:bool] (option_v (inpool_v ch, b) | bool b) (* = "try_enter_pool" *)

(* ****** ****** *)

extern
fun enter_pool
 {ch:int}
 (pf: !chameneos_v ch | (*void*)): (inpool_v (ch) | void)

(* ****** ****** *)

(*
implement
enter_pool
 (pf | (*void*)) = let
 val (pfopt | ans) = try_enter_pool (pf | (*void*))
in
 if ans then let
   prval Some_v (pf) = pfopt in (pf | ())
 end else let // ans = false
   prval None_v () = pfopt in enter_pool (pf | (*void*))
 end (* end of [if] *)
end // end of [enter_pool]
*)

(* ****** ****** *)
////
extern
fun exit_pool
 {ch:int}
 (pf1: !chameneos_v ch , pf2: inpool_v ch | (*void*)): void = "exit_pool"

(* ****** ****** *)

extern
fun first_in_pool
 {ch:int}
 (pf: !chameneos_v ch, pf2: !inpool_v() | (*void*)): (first_v () | void) =
 "first_in_pool"

(* ****** ****** *)

extern
fun first_out_pool
 {ch:int}
 (pf1: !chameneos_v ch , pf2: !inpool_v (), pf3: first_v() | (*void*)): void =
 "first_out_pool"

(* ****** ****** *)

extern
fun inpool_wait // conditional wait within pool (i.e, chameneos A waiting for chameneos B)
 {ch:int}
 (pf1: !chameneos_v ch , pf2: !inpool_v () | (*void*)):<> void = "memlock_wait"

(* ****** ****** *)

extern
fun memlock_get_color
 (pf1: !memlock_v () , pf2: !inpool_v () | (*void*)):<> color = "memlock_get_color"

(* ****** ****** *)

extern
fun memlock_set_color
 (pf1: !memlock_v () , pf2: !inpool_v () | c: color):<> void = "memlock_set_color"

(* ****** ****** *)

extern
fun memlock_get_id
 (pf1: !memlock_v () , pf2: !inpool_v () | (*void*)):<> int = "memlock_get_id"

(* ****** ****** *)

extern
fun memlock_set_id
 (pf1: !memlock_v () , pf2: !inpool_v () | n: int):<> void = "memlock_set_id"

(* ****** ****** *)

extern
fun acquire_memlock {ch:int}
 (pf1: !chameneos_v ch , pf2: !inpool_v () | n: int): (memlock_v () | void)
 = "acquire_memlock"

(* ****** ****** *)

extern
fun release_memlock
 {ch:int}
 (pf1: !chameneos_v ch, pf2: memlock_v () , pf3: !inpool_v () | n: int): void
 = "release_memlock"

(* ****** ****** *)

(* end of [chameneos_fork.dats] *)




////
absview chameneos_v ()
absview memlock_v () // accessing shared memory
absview inpool_v () // semaphore(2)
absview first_v () // semaphore(1)

abst@ype color
assume color = int // temp to appease typechecker

(* ****** ****** *)

extern
fun identify_chameneos () : (chameneos_v ch | (*void*)) = "identify_chameneos"

(* ****** ****** *)

extern
fun remove_chameneos 
  {ch:int}
  (pf: chameneos_v ch) : () = "identify_chameneos"

(* ****** ****** *)

extern
fun enter_pool
  {ch:int}
  (pf: !chameneos_v ch | (*void*)): (inpool_v () | (*void*)) = "enter_pool"

(* ****** ****** *)

extern
fun exit_pool
  {ch:int}
  (pf1: !chameneos_v ch , pf2: inpool_v () | (*void*)): void = "exit_pool"

(* ****** ****** *)

extern
fun first_in_pool
  {ch:int}
  (pf: !chameneos_v ch, pf2: !inpool_v() | (*void*)): (first_v () | void) =
  "first_in_pool"

(* ****** ****** *)

extern
fun first_out_pool
  {ch:int}
  (pf1: !chameneos_v ch , pf2: !inpool_v (), pf3: first_v() | (*void*)): void =
  "first_out_pool"

(* ****** ****** *)

extern
fun inpool_wait // conditional wait within pool (i.e, chameneos A waiting for chameneos B)
  {ch:int}
  (pf1: !chameneos_v ch , pf2: !inpool_v () | (*void*)):<> void = "memlock_wait"

(* ****** ****** *)

extern
fun memlock_get_color 
  (pf1: !memlock_v () , pf2: !inpool_v () | (*void*)):<> color = "memlock_get_color"

(* ****** ****** *)

extern 
fun memlock_set_color 
  (pf1: !memlock_v () , pf2: !inpool_v () | c: color):<> void = "memlock_set_color"

(* ****** ****** *)

extern
fun memlock_get_id
  (pf1: !memlock_v () , pf2: !inpool_v () | (*void*)):<> int = "memlock_get_id"

(* ****** ****** *)

extern
fun memlock_set_id 
  (pf1: !memlock_v () , pf2: !inpool_v () | n: int):<> void = "memlock_set_id"

(* ****** ****** *)

extern
fun acquire_memlock 
  {ch:int}
  (pf1: !chameneos_v ch , pf2: !inpool_v () | n: int): (memlock_v () | void)
  = "acquire_memlock"

(* ****** ****** *)

extern
fun release_memlock
  {ch:int}
  (pf1: !chameneos_v ch, pf2: memlock_v () , pf3: !inpool_v () | n: int): void
  = "release_memlock"

(* ****** ****** *)

(* end of [chameneos_fork.dats] *)

