	switch (t->back) {
	default: Uerror("bad return move");
	case  0: goto R999; /* nothing to undo */

		 /* PROC :init: */

	case 3: // STATE 1
		;
		;
		delproc(0, now._nr_pr-1);
		;
		goto R999;

	case 4: // STATE 2
		;
		;
		delproc(0, now._nr_pr-1);
		;
		goto R999;

	case 5: // STATE 3
		;
		p_restor(II);
		;
		;
		goto R999;

		 /* PROC P */

	case 6: // STATE 3
		;
		((P0 *)this)->left = trpt->bup.ovals[1];
		((P0 *)this)->right = trpt->bup.ovals[0];
		;
		ungrab_ints(trpt->bup.ovals, 2);
		goto R999;

	case 7: // STATE 5
		;
		thinking[ Index(((P0 *)this)->i, 2) ] = trpt->bup.ovals[1];
		eating[ Index(((P0 *)this)->i, 2) ] = trpt->bup.ovals[0];
		;
		ungrab_ints(trpt->bup.ovals, 2);
		goto R999;

	case 8: // STATE 9
		;
		hungry[ Index(((P0 *)this)->i, 2) ] = trpt->bup.ovals[1];
		thinking[ Index(((P0 *)this)->i, 2) ] = trpt->bup.ovals[0];
		;
		ungrab_ints(trpt->bup.ovals, 2);
		goto R999;

	case 9: // STATE 13
		;
		now.forks[ Index(((P0 *)this)->left, 5) ] = trpt->bup.oval;
		;
		goto R999;

	case 10: // STATE 16
		;
		now.forks[ Index(((P0 *)this)->right, 5) ] = trpt->bup.oval;
		;
		goto R999;

	case 11: // STATE 19
		;
		now.forks[ Index(((P0 *)this)->right, 5) ] = trpt->bup.oval;
		;
		goto R999;

	case 12: // STATE 22
		;
		now.forks[ Index(((P0 *)this)->left, 5) ] = trpt->bup.oval;
		;
		goto R999;

	case 13: // STATE 27
		;
		eating[ Index(((P0 *)this)->i, 2) ] = trpt->bup.ovals[1];
		hungry[ Index(((P0 *)this)->i, 2) ] = trpt->bup.ovals[0];
		;
		ungrab_ints(trpt->bup.ovals, 2);
		goto R999;

	case 14: // STATE 30
		;
		now.forks[ Index(((P0 *)this)->right, 5) ] = trpt->bup.oval;
		;
		goto R999;

	case 15: // STATE 31
		;
		now.forks[ Index(((P0 *)this)->left, 5) ] = trpt->bup.oval;
		;
		goto R999;
;
		;
			}

