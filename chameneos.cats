#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <semaphore.h>
#include <string.h>
#include <limits.h>
#include <sched.h>
#include <unistd.h>

static sem_t pool_entry;
static sem_t first_entry;
static pthread_mutex_t mutex0;
static pthread_cond_t condwait; 

// chameneos-specific info
typedef struct {
  pthread_t id;
  int color;
  int matches;
  int self_test;
}chameneos_s;
static chameneos_s *cgroup = NULL;
// Info shared between chameneoses
// access of shared should always be w/ a locked thread
typedef struct {
  int color; 
  int id; 
} shared;
static shared *cshared = NULL;

static ats_int_type shared_color = 0 ;
static ats_int_type sum_matches = 0; 
static ats_int_type num_matches = 0; 

/* remove pool_v*/ 
static inline 
ats_void_type leave_pool(ats_void_type) {return; };


/*shared data structure */
static inline 
ats_void_type 
setup_shared_data( ats_int_type n1, ats_int_type n2){
  
  pthread_cond_init(&condwait, NULL);
  pthread_mutex_init(&mutex0, NULL);
  
  sem_init(&pool_entry, 0, 2);
  sem_init(&first_entry, 0, 1);
   
  cgroup = malloc( sizeof(chameneos_s)*n1);
  cshared = malloc(sizeof(shared));
  sum_matches = 0;
  num_matches = n2; 
  return;
}


/* FIXME: This function take from the C implementation on the SHOOTOUT website*/
static inline
char const* spell_number(int n)
{
    static char                 buf [128];
    static char const*          numbers [] = {
        " zero", " one", " two",   " three", " four",
        " five", " six", " seven", " eight", " nine"};

    size_t                      tokens [32];
    size_t                      token_count;
    char const*                 tok;
    char*                       pos;

    token_count = 0;
    do
    {
        tokens[token_count] = n % 10;
        token_count += 1;
        n /= 10;
    }
    while (n);

    pos = buf;
    while (token_count)
    {
        token_count -= 1;
        tok = numbers[tokens[token_count]];
        while (tok[0])
            pos++[0] = tok++[0];
    }
    pos[0] = 0;
    return buf;
}

static inline
ats_int_type check_match_count (ats_int_type n) {
  if (sum_matches >= 2*num_matches) return 1;
  else return 0;
}

static inline
ats_void_type print_match_count () {
  printf("%s\n", spell_number(sum_matches));
}

static inline
ats_void_type kill_chameneos(ats_int_type n) {
  printf("%d %s\n", cgroup[n].matches, spell_number(cgroup[n].self_test));
  return ;
}

static inline
ats_int_type get_shared_color () { return  cshared->color ; }

static inline
ats_void_type set_shared_color (ats_int_type n) { cshared->color = n ; return ; }

static inline
ats_int_type get_shared_id () { return cshared->id ; }

static inline
ats_void_type set_shared_id (ats_int_type n) { cshared->id = n ; return ; }

static inline
ats_int_type get_chameneos_color (ats_int_type n) { return cgroup[n].color ; }

static inline
ats_void_type set_chameneos_color (ats_int_type n, ats_int_type c) { cgroup[n].color = c ; return ; }

static inline
ats_void_type monitor_lock_acquire () { pthread_mutex_lock (&mutex0) ; return ; }

static inline
ats_void_type monitor_lock_release () { pthread_mutex_unlock (&mutex0) ; return ; }

/* chameneos enters the pool to 'play' with another chameneoses */
static inline
ats_int_type enter_pool() { return sem_trywait(&pool_entry); }

/* chameneos checks if another chameneos is in the pool */
static inline
ats_int_type check_occupancy() { pthread_mutex_lock (&mutex0) ; return sem_trywait(&first_entry); }

/* */
static inline
ats_void_type wait_for_chameneos() { pthread_cond_wait(&condwait, &mutex0); return; }

static inline
ats_void_type do_exchange (ats_int_type n1, ats_int_type n2, ats_int_type c) { 
  //if (sum_matches >= 2*num_matches) return; // this should never happen, but just in case
  sum_matches++;
  cgroup[n1].color = c ; 
  cgroup[n1].matches++ ; 
  if(n1==n2) cgroup[n1].self_test++ ; 
  return ; 
} 

/* */
static inline
ats_void_type
signal_chameneos() {
  pthread_mutex_unlock (&mutex0) ; pthread_cond_signal(&condwait);
  return;
}

/* allow two more chameneos to enter pool*/
static inline
ats_void_type reset_pool() {
  sem_post(&first_entry);
  sem_post(&pool_entry);
  sem_post(&pool_entry);
  pthread_mutex_unlock (&mutex0) ;
  return;
}

static inline
ats_void_type
wait_for_end (ats_int_type n) {
  int i;
  for (i=0; i < n; i++)
    pthread_join (cgroup[i].id, NULL);
  //
  printf("%s\n", spell_number(sum_matches));
  return ;
} // end

