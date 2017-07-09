#define rand	pan_rand
#define pthread_equal(a,b)	((a)==(b))
#if defined(HAS_CODE) && defined(VERBOSE)
	#ifdef BFS_PAR
		bfs_printf("Pr: %d Tr: %d\n", II, t->forw);
	#else
		cpu_printf("Pr: %d Tr: %d\n", II, t->forw);
	#endif
#endif
	switch (t->forw) {
	default: Uerror("bad forward move");
	case 0:	/* if without executable clauses */
		continue;
	case 1: /* generic 'goto' or 'skip' */
		IfNotBlocked
		_m = 3; goto P999;
	case 2: /* generic 'else' */
		IfNotBlocked
		if (trpt->o_pm&1) continue;
		_m = 3; goto P999;

		 /* PROC :init: */
	case 3: // STATE 1 - dining_phil3.pml:41 - [(run P(0))] (0:0:0 - 1)
		IfNotBlocked
		reached[1][1] = 1;
		if (!(addproc(II, 1, 0, 0)))
			continue;
		_m = 3; goto P999; /* 0 */
	case 4: // STATE 2 - dining_phil3.pml:42 - [(run P(1))] (0:0:0 - 1)
		IfNotBlocked
		reached[1][2] = 1;
		if (!(addproc(II, 1, 0, 1)))
			continue;
		_m = 3; goto P999; /* 0 */
	case 5: // STATE 3 - dining_phil3.pml:46 - [-end-] (0:0:0 - 1)
		IfNotBlocked
		reached[1][3] = 1;
		if (!delproc(1, II)) continue;
		_m = 3; goto P999; /* 0 */

		 /* PROC P */
	case 6: // STATE 1 - dining_phil3.pml:10 - [printf('Philosopher:%d',i)] (0:6:2 - 1)
		IfNotBlocked
		reached[0][1] = 1;
		Printf("Philosopher:%d", ((P0 *)this)->i);
		/* merge: right = i(6, 2, 6) */
		reached[0][2] = 1;
		(trpt+1)->bup.ovals = grab_ints(2);
		(trpt+1)->bup.ovals[0] = ((P0 *)this)->right;
		((P0 *)this)->right = ((P0 *)this)->i;
#ifdef VAR_RANGES
		logval("P:right", ((P0 *)this)->right);
#endif
		;
		/* merge: left = (i+1)(6, 3, 6) */
		reached[0][3] = 1;
		(trpt+1)->bup.ovals[1] = ((P0 *)this)->left;
		((P0 *)this)->left = (((P0 *)this)->i+1);
#ifdef VAR_RANGES
		logval("P:left", ((P0 *)this)->left);
#endif
		;
		_m = 3; goto P999; /* 2 */
	case 7: // STATE 4 - dining_phil3.pml:14 - [eating[i] = 0] (0:10:2 - 1)
		IfNotBlocked
		reached[0][4] = 1;
		(trpt+1)->bup.ovals = grab_ints(2);
		(trpt+1)->bup.ovals[0] = ((int)eating[ Index(((P0 *)this)->i, 2) ]);
		eating[ Index(((P0 *)this)->i, 2) ] = 0;
#ifdef VAR_RANGES
		logval("eating[P:i]", ((int)eating[ Index(((P0 *)this)->i, 2) ]));
#endif
		;
		/* merge: thinking[i] = 1(10, 5, 10) */
		reached[0][5] = 1;
		(trpt+1)->bup.ovals[1] = ((int)thinking[ Index(((P0 *)this)->i, 2) ]);
		thinking[ Index(((P0 *)this)->i, 2) ] = 1;
#ifdef VAR_RANGES
		logval("thinking[P:i]", ((int)thinking[ Index(((P0 *)this)->i, 2) ]));
#endif
		;
		/* merge: printf('Philosopher:%d thinking',i)(10, 7, 10) */
		reached[0][7] = 1;
		Printf("Philosopher:%d thinking", ((P0 *)this)->i);
		_m = 3; goto P999; /* 2 */
	case 8: // STATE 8 - dining_phil3.pml:18 - [thinking[i] = 0] (0:24:2 - 1)
		IfNotBlocked
		reached[0][8] = 1;
		(trpt+1)->bup.ovals = grab_ints(2);
		(trpt+1)->bup.ovals[0] = ((int)thinking[ Index(((P0 *)this)->i, 2) ]);
		thinking[ Index(((P0 *)this)->i, 2) ] = 0;
#ifdef VAR_RANGES
		logval("thinking[P:i]", ((int)thinking[ Index(((P0 *)this)->i, 2) ]));
#endif
		;
		/* merge: hungry[i] = 1(24, 9, 24) */
		reached[0][9] = 1;
		(trpt+1)->bup.ovals[1] = ((int)hungry[ Index(((P0 *)this)->i, 2) ]);
		hungry[ Index(((P0 *)this)->i, 2) ] = 1;
#ifdef VAR_RANGES
		logval("hungry[P:i]", ((int)hungry[ Index(((P0 *)this)->i, 2) ]));
#endif
		;
		/* merge: printf('Philosopher:%d hungry',i)(24, 11, 24) */
		reached[0][11] = 1;
		Printf("Philosopher:%d hungry", ((P0 *)this)->i);
		_m = 3; goto P999; /* 2 */
	case 9: // STATE 12 - dining_phil3.pml:22 - [((forks[left]==-(1)))] (17:0:1 - 1)
		IfNotBlocked
		reached[0][12] = 1;
		if (!((now.forks[ Index(((P0 *)this)->left, 5) ]== -(1))))
			continue;
		/* merge: forks[left] = i(0, 13, 17) */
		reached[0][13] = 1;
		(trpt+1)->bup.oval = now.forks[ Index(((P0 *)this)->left, 5) ];
		now.forks[ Index(((P0 *)this)->left, 5) ] = ((P0 *)this)->i;
#ifdef VAR_RANGES
		logval("forks[P:left]", now.forks[ Index(((P0 *)this)->left, 5) ]);
#endif
		;
		_m = 3; goto P999; /* 1 */
	case 10: // STATE 15 - dining_phil3.pml:23 - [((forks[right]==-(1)))] (28:0:1 - 1)
		IfNotBlocked
		reached[0][15] = 1;
		if (!((now.forks[ Index(((P0 *)this)->right, 5) ]== -(1))))
			continue;
		/* merge: forks[right] = i(0, 16, 28) */
		reached[0][16] = 1;
		(trpt+1)->bup.oval = now.forks[ Index(((P0 *)this)->right, 5) ];
		now.forks[ Index(((P0 *)this)->right, 5) ] = ((P0 *)this)->i;
#ifdef VAR_RANGES
		logval("forks[P:right]", now.forks[ Index(((P0 *)this)->right, 5) ]);
#endif
		;
		/* merge: .(goto)(0, 25, 28) */
		reached[0][25] = 1;
		;
		_m = 3; goto P999; /* 2 */
	case 11: // STATE 18 - dining_phil3.pml:25 - [((forks[right]==-(1)))] (23:0:1 - 1)
		IfNotBlocked
		reached[0][18] = 1;
		if (!((now.forks[ Index(((P0 *)this)->right, 5) ]== -(1))))
			continue;
		/* merge: forks[right] = i(0, 19, 23) */
		reached[0][19] = 1;
		(trpt+1)->bup.oval = now.forks[ Index(((P0 *)this)->right, 5) ];
		now.forks[ Index(((P0 *)this)->right, 5) ] = ((P0 *)this)->i;
#ifdef VAR_RANGES
		logval("forks[P:right]", now.forks[ Index(((P0 *)this)->right, 5) ]);
#endif
		;
		_m = 3; goto P999; /* 1 */
	case 12: // STATE 21 - dining_phil3.pml:26 - [((forks[left]==-(1)))] (28:0:1 - 1)
		IfNotBlocked
		reached[0][21] = 1;
		if (!((now.forks[ Index(((P0 *)this)->left, 5) ]== -(1))))
			continue;
		/* merge: forks[left] = i(0, 22, 28) */
		reached[0][22] = 1;
		(trpt+1)->bup.oval = now.forks[ Index(((P0 *)this)->left, 5) ];
		now.forks[ Index(((P0 *)this)->left, 5) ] = ((P0 *)this)->i;
#ifdef VAR_RANGES
		logval("forks[P:left]", now.forks[ Index(((P0 *)this)->left, 5) ]);
#endif
		;
		/* merge: .(goto)(0, 25, 28) */
		reached[0][25] = 1;
		;
		_m = 3; goto P999; /* 2 */
	case 13: // STATE 26 - dining_phil3.pml:30 - [hungry[i] = 0] (0:30:2 - 1)
		IfNotBlocked
		reached[0][26] = 1;
		(trpt+1)->bup.ovals = grab_ints(2);
		(trpt+1)->bup.ovals[0] = ((int)hungry[ Index(((P0 *)this)->i, 2) ]);
		hungry[ Index(((P0 *)this)->i, 2) ] = 0;
#ifdef VAR_RANGES
		logval("hungry[P:i]", ((int)hungry[ Index(((P0 *)this)->i, 2) ]));
#endif
		;
		/* merge: eating[i] = 1(30, 27, 30) */
		reached[0][27] = 1;
		(trpt+1)->bup.ovals[1] = ((int)eating[ Index(((P0 *)this)->i, 2) ]);
		eating[ Index(((P0 *)this)->i, 2) ] = 1;
#ifdef VAR_RANGES
		logval("eating[P:i]", ((int)eating[ Index(((P0 *)this)->i, 2) ]));
#endif
		;
		/* merge: printf('Philosopher:%d eating',i)(30, 29, 30) */
		reached[0][29] = 1;
		Printf("Philosopher:%d eating", ((P0 *)this)->i);
		_m = 3; goto P999; /* 2 */
	case 14: // STATE 30 - dining_phil3.pml:34 - [forks[right] = -(1)] (0:0:1 - 1)
		IfNotBlocked
		reached[0][30] = 1;
		(trpt+1)->bup.oval = now.forks[ Index(((P0 *)this)->right, 5) ];
		now.forks[ Index(((P0 *)this)->right, 5) ] =  -(1);
#ifdef VAR_RANGES
		logval("forks[P:right]", now.forks[ Index(((P0 *)this)->right, 5) ]);
#endif
		;
		_m = 3; goto P999; /* 0 */
	case 15: // STATE 31 - dining_phil3.pml:34 - [forks[left] = -(1)] (0:0:1 - 1)
		IfNotBlocked
		reached[0][31] = 1;
		(trpt+1)->bup.oval = now.forks[ Index(((P0 *)this)->left, 5) ];
		now.forks[ Index(((P0 *)this)->left, 5) ] =  -(1);
#ifdef VAR_RANGES
		logval("forks[P:left]", now.forks[ Index(((P0 *)this)->left, 5) ]);
#endif
		;
		_m = 3; goto P999; /* 0 */
	case 16: // STATE 32 - dining_phil3.pml:35 - [printf('Philosopher:%d done',i)] (0:0:0 - 1)
		IfNotBlocked
		reached[0][32] = 1;
		Printf("Philosopher:%d done", ((P0 *)this)->i);
		_m = 3; goto P999; /* 0 */
	case  _T5:	/* np_ */
		if (!((!(trpt->o_pm&4) && !(trpt->tau&128))))
			continue;
		/* else fall through */
	case  _T2:	/* true */
		_m = 3; goto P999;
#undef rand
	}

