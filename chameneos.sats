(* ****** ****** *)

%{#
#include "chameneos.cats"
%} 

(* ****** DEFINES ****** *)

#define num_colors (3)

(* ****** TYPES ****** *)

// protection cirtificates 
absview chameneos_v 
absview inpool_v 
absview memlock_v 

// chameneos color
abst@ype color
assume color = int
datatype color = 
| red of ()
| blue of ()
| yellow of ()

// a clan of chameneos
datatype chameneoses (a:t@ype) = 
  |chameneos_nil (a) of () | chameneos_con (a) of (a, chameneoses a)
// end of chameneoses 
#define cnil chameneos_nil
#define :: chameneos_con
#define ccons chameneos_cons
// chameneoses w/ color
typedef c2  = chameneoses(color)

(* ****** FUNCTIONS ****** *)

(* resource protection functions *)
// conditional wait
fun wait_for_chameneos(): void = "wait_for_chameneos"
fun signal_chameneos(): void = "signal_chameneos"
// mutex
fun monitor_lock_acquire(): (memlock_v | void ) = "monitor_lock_acquire"
fun monitor_lock_release( pf: memlock_v | ): void = "monitor_lock_release"
// read-only access to global data 
fun check_match_count (n:int): int = "check_match_count"
fun print_match_count (): void = "print_match_count"

(* test-related functions *)
fun wait_for_end (n:int): void = "wait_for_end"
fun translate_color2 (c1: color, c2: color) : color = "translate_color2" 
fun color_to_int (c: color) : int = "color_to_int" 
fun int_to_color (i: int) : color = "int_to_color" 
fun setup_shared_data (n: int, run: int): void = "setup_shared_data"

(* enter/exit pool *)
fun enter_pool {n:int} (pf: !chameneos_v |): (inpool_v | int n) = "enter_pool"
fun check_occupancy(pf1: !chameneos_v, pf2: !inpool_v | (*void*)): int = "check_occupancy"
fun reset_pool(): void = "reset_pool"
fun leave_pool (pf: !chameneos_v, pf2: inpool_v | (*void*)): void ="leave_pool"

(* chameneos actions *)
fun chameneos_play {n:int} (pf: chameneos_v | n: int n): void = "chameneos_play"
fun chameneos_a {n:int} (pf1: !chameneos_v, pf2: !inpool_v | n: int n): void = "chameneos_a"
fun chameneos_b {n:int} (pf1: !chameneos_v, pf2: !inpool_v | n: int n): void = "chameneos_b"
fun kill_chameneos (pf:chameneos_v | n:int): void = "kill_chameneos"
// read access to shared data
fun get_shared_color (pf: !chameneos_v, pf1: !inpool_v | (*void*)): int = "get_shared_color"
fun get_shared_id (pf: !chameneos_v, pf1: !inpool_v | (*void*)): int = "get_shared_id"
fun get_chameneos_color (pf: !chameneos_v, pf1: !inpool_v | n: int): int = "get_chameneos_color"
fun do_exchange(pf: !chameneos_v, pf1: !inpool_v |n1: int , n2: int, c:int): void = "do_exchange"
// write access to shared data 
fun set_shared_color  {n:int} (pf: !chameneos_v, pf1: !inpool_v | n: int): void = "set_shared_color"
fun set_shared_id (pf: !chameneos_v, pf1: !inpool_v | n: int): void = "set_shared_id"
fun set_chameneos_color (pf: !chameneos_v, pf1: !inpool_v | n1: int , n2: int): void = "set_chameneos_color"
