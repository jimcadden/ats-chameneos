(*
 Briefly say what concurrency technique is used in the program header comment:
 Semaphone counters are used for entry into the meeting place, while a mutex lock
 protects the shared data.
*)

staload "libc/SATS/stdio.sats"
staload "libc/sys/SATS/types.sats"
staload "libc/SATS/unistd.sats"
staload "prelude/DATS/list.dats"
staload UN = "prelude/SATS/unsafe.sats"
//
staload "chameneos.sats"

(* ****** ****** *)

implement 
color_to_int (c) = case c of 
| blue () => 0
| red () => 1
| yellow () => 2

(* ****** ****** *)

implement 
int_to_color (i) = 
  if (i = 1) then red () else
  if (i = 0) then blue () else yellow ()

(* ****** ****** *)

implement 
translate_color2 (c1, c2) = 
  case c1 of 
  | red () => ( case c2 of 
     | red ()     => red() 
     | blue ()    => yellow()
     | yellow ()  => blue()
  ) // end of c1 => red()
  | blue () => ( case c2 of 
     | red ()     => yellow ()
     | blue ()    => blue () 
     | yellow ()  => red () 
  ) // end of c1 => blue()
  | yellow () => ( case c2 of 
     | red ()     => blue()
     | blue ()    => red()
     | yellow ()  => yellow()
  ) // end of c1 => yellow()

(* ****** ****** *)

/* action of chameneos that entered pool first*/
implement
chameneos_a {n} (pf1, pf2 | n) = let
  val () = set_shared_color(pf1, pf2 | get_chameneos_color(pf1, pf2 | n))
  val () = set_shared_id(pf1, pf2 | n)
  val () = wait_for_chameneos() // block until signaled by secound chameneos
  val nc = translate_color2(int_to_color(get_chameneos_color(pf1, pf2 | n)),
  int_to_color(get_shared_color(pf1, pf2 |))) 
  val n2= get_shared_id(pf1, pf2 | ) 
  val () = do_exchange(pf1, pf2 | n, n2, color_to_int(nc)) 
  val () = set_chameneos_color(pf1, pf2 | n,color_to_int(nc)) 
  val () = reset_pool()
in
end

(* ****** ****** *)

/* action of chameneos that entered pool secound */
implement
chameneos_b {n} (pf1, pf2 | n) = let
  val oc = get_chameneos_color(pf1, pf2 | n)
  val nc = translate_color2(int_to_color(oc),
  int_to_color(get_shared_color(pf1, pf2 |))) 
  val n2= get_shared_id(pf1, pf2 | ) 
  val () = do_exchange(pf1, pf2 | n, n2, color_to_int(nc)) 
  val () = set_chameneos_color(pf1, pf2 | n,color_to_int(nc)) 
  val () = set_shared_color(pf1, pf2 | oc)
  val () = set_shared_id(pf1, pf2 | n)
  val () = signal_chameneos() // once done, wake up other chameneos
in
end

(* ****** ****** *)

implement
chameneos_play {n} (pf | n) = let
fun loop ( pf: chameneos_v | n: int n) : void = let
  // checks to prevent chameneos from locking when we've hit our max meetup
  val (poolf | pooln) = enter_pool(pf | )
  val () = if ( pooln = 0) then
    /*TODO: move check_match_count into the a/b functions */
    ( if  (check_match_count(n) = 0) then // this maybe unnessessary 
          ( 
              // check if there already is a chameneos in the pool
              if (check_occupancy(pf, poolf|) = 0) 
                then chameneos_a(pf, poolf | n) 
                else chameneos_b(pf, poolf| n)
          )
    )
  
  val () = leave_pool(pf, poolf | )
  in
    if (check_match_count(n) = 0) 
      then loop (pf | n)  
      else kill_chameneos(pf | n)
  end (* end of [loop] *)
in
  loop (pf | n)
end // end of [do_phil]
//

(* ****** ****** *)

extern fun start_chameneos (n:int, c:int):  void = "start_chameneos"
%{$
ats_void_type
start_chameneos ( ats_int_type n, ats_int_type c ) {
  // TODO: optimize the pthread stack 
  // threadstack *p_threadstack ;
  // p_threadstack = &threadstackarr[0] ;
  //  pthread_attr_setstack (&thread_attr, p_threadstack, sizeof(threadstack)) ;
  int affinity;
  pthread_attr_t thread_attr ;
  cpu_set_t mask;
  long num_cores = sysconf(_SC_NPROCESSORS_ONLN);
  pthread_attr_init (&thread_attr) ;
  cgroup[n].color = c;
  //
  affinity = n % num_cores;
  CPU_ZERO( &mask );
  CPU_SET( affinity, &mask );
  //
  pthread_attr_setaffinity_np(&thread_attr, sizeof(cpu_set_t), &mask);
  pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_JOINABLE);
  pthread_create(&cgroup[n].id , &thread_attr, (void* (*)(void*))chameneos_play, (void*)(intptr_t)(n)) ;
 // fprintf (stderr, "initialization is done: n = %i\n", n) ;
  return;
} // end of [initialization]
%}

(* ****** ****** *)

dynload "chameneos_sync.dats"

(* ****** ****** *)

fun run_test(n:int, c:c2, len:int) : void = let
  val() = setup_shared_data(len, n)
  fun loop(i:int, c:c2) : void = case+ c of
    | chameneos_nil() => () // println!("Chamenoes loaded")
    | chameneos_con(x, y) => let
        val col = color_to_int(x)
        val () = start_chameneos(i,col)
    in
      loop(i+1, y)
    end
  //
in
  loop(0, c)
end

(* ****** ****** *)

implement main (argc, argv) = let
  (* Subfunctions *)
  fun print_color (c:color) : void = case c of 
  | red () => print!("red")
  | blue () =>print!("blue")
  | yellow () =>print!("yellow")
  //
  fun print_chameneoses (a1: c2) : void = 
  case+ a1 of 
    | chameneos_nil() => println!()
    | chameneos_con(x, y) => let
        val () = print_color(x)
        val () = print!(" ")
  in
        print_chameneoses(y)
  end
  //
  fun print_color_map() : void = let
    fun loop1(i:int) : void = let
      fun loop2(i:int, j:int) : void = let
        val () = print_color(int_to_color(i))
        val () = print!(" + ")
        val () = print_color(int_to_color(j))
        val () = print!(" -> ")
        val () = print_color(translate_color2(int_to_color(i),int_to_color(j)))
        val () = println!()
      in
        if (j < num_colors - 1) then loop2( i, j+1) 
      end
      val () = loop2(i, 0)
    in
      if (i < num_colors -1 ) then loop1(i+1)
    end
  in
    loop1(0)
  end
  // 
  fun group_length(a1:c2) : int = case+ a1 of
    | chameneos_con (_,y) => 1 + group_length(y) | chameneos_nil() => 0
  
  (* Run tests *)
  // get N (num meet-ups) from command line
  val () = assert (argc >= 2)
  val n = int1_of_string (argv.[1])
  val () = assert (n >= 0)
  // define test sets
  val group1 = (blue() :: red() :: yellow() :: cnil () )
  val group2 = (blue() :: red() :: yellow() :: red() :: yellow() :: blue() :: red() :: yellow() :: red() :: blue() :: cnil() )
  val() = print_color_map()
  val() = println!("")
  // run test #1
  val() = print_chameneoses(group1)
  val() = run_test(n, group1, group_length(group1))
  val() = wait_for_end(group_length(group1))
  val() = println!("")
  // run test #2
  val() = print_chameneoses(group2)
  val() = run_test(n, group2, group_length(group2))
  val() = wait_for_end(group_length(group2))
in
  (*void*)
end // end of [main]

(* ****** ****** *)
////
