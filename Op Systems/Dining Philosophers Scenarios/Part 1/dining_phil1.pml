#define NUM_PHIL 1
#define NUM_FORKS 5
bool thinking[NUM_PHIL], hungry[NUM_PHIL], eating[NUM_PHIL] = false;
int forks[NUM_FORKS] = -1;

// LTL for deadlock/livelock/starvation for just 1 philosopher
ltl livelock { [](hungry[0] -> <>eating[0]) };
proctype P(int i)
{
  printf("Philosopher:%d", i);
  int right = i; int left = (i + 1)// % NUM_PHIL;

  Think:
    atomic { eating[i] = false; thinking[i] = true; };
    printf("Philosopher:%d thinking", i);

  Hungry:
    atomic { thinking[i] = false; hungry[i] = true; };
    printf("Philosopher:%d hungry", i);
    if
      ::
        atomic { forks[left] == -1 -> forks[left] = i };
        atomic { forks[right] == -1 -> forks[right] = i };
      ::
        atomic { forks[right] == -1 -> forks[right] = i };
        atomic { forks[left] == -1 -> forks[left] = i };
    fi;

  Eating:
    atomic { hungry[i] = false; eating[i] = true; };
    printf("Philosopher:%d eating", i);

  Done:
    forks[right] = -1; forks[left] = -1;
    printf("Philosopher:%d done", i);
    goto Think;
}

init
{
  run P(0);
  /*run P(1);
  run P(2);
  run P(3);
  run P(4);*/
}
