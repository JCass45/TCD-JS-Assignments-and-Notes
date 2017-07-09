int n;
int pc;

ltl p4 {<>[](n == 4)}
ltl p3 {!<>[](n ==3)}

proctype p()
{
	int temp;
    int i;
	for(i : 1 .. 2)
	{
        temp = n;
        temp = temp + 1;
        n = temp;
	}
    printf("Process p is complete with n: %d\n", n);
    pc++
}

proctype q()
{
    int i;
    for(i : 1 .. 2)
    {
        n = n + 1;
    }
    printf("Process q is complete with n: %d\n", n);
    pc++
}

init
{
    run p();
    run q();
    
    pc == 2; // Guard statement
    printf("The result of the program is n: %d\n", n);
    //assert(n == 4);
}