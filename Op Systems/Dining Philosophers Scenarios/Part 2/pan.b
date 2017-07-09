	switch (t->back) {
	default: Uerror("bad return move");
	case  0: goto R999; /* nothing to undo */

		 /* CLAIM livelock */
;
		;
		;
		;
		;
		;
		;
		;
		
	case 7: // STATE 20
		;
		p_restor(II);
		;
		;
		goto R999;

		 /* PROC :init: */

	case 8: // STATE 1
		;
		;
		delproc(0, now._nr_pr-1);
		;
		goto R999;

	case 9: // STATE 2
		;
		;
		delproc(0, now._nr_pr-1);
		;
		goto R999;

	case 10: // STATE 3
		;
		p_restor(II);
		;
		;
		goto R999;

		 /* PROC P */

	case 11: // STATE 3
		;
		((P0 *)this)->left = trpt->bup.ovals[1];
		((P0 *)this)->right = trpt->bup.ovals[0];
		;
		ungrab_ints(trpt->bup.ovals, 2);
		goto R999;

	case 12: // STATE 5
		;
		thinking[ Index(((P0 *)this)->i, 5) ] = trpt->bup.ovals[1];
		now.eating[ Index(((P0 *)this)->i, 5) ] = trpt->bup.ovals[0];
		;
		ungrab_ints(trpt->bup.ovals, 2);
		goto R999;

	case 13: // STATE 9
		;
		now.hungry[ Index(((P0 *)this)->i, 5) ] = trpt->bup.ovals[1];
		thinking[ Index(((P0 *)this)->i, 5) ] = trpt->bup.ovals[0];
		;
		ungrab_ints(trpt->bup.ovals, 2);
		goto R999;

	case 14: // STATE 13
		;
		now.forks[ Index(((P0 *)this)->left, 5) ] = trpt->bup.oval;
		;
		goto R999;

	case 15: // STATE 16
		;
		now.forks[ Index(((P0 *)this)->right, 5) ] = trpt->bup.oval;
		;
		goto R999;

	case 16: // STATE 19
		;
		now.forks[ Index(((P0 *)this)->right, 5) ] = trpt->bup.oval;
		;
		goto R999;

	case 17: // STATE 22
		;
		now.forks[ Index(((P0 *)this)->left, 5) ] = trpt->bup.oval;
		;
		goto R999;

	case 18: // STATE 27
		;
		now.eating[ Index(((P0 *)this)->i, 5) ] = trpt->bup.ovals[1];
		now.hungry[ Index(((P0 *)this)->i, 5) ] = trpt->bup.ovals[0];
		;
		ungrab_ints(trpt->bup.ovals, 2);
		goto R999;

	case 19: // STATE 30
		;
		now.forks[ Index(((P0 *)this)->right, 5) ] = trpt->bup.oval;
		;
		goto R999;

	case 20: // STATE 31
		;
		now.forks[ Index(((P0 *)this)->left, 5) ] = trpt->bup.oval;
		;
		goto R999;
;
		;
			}

