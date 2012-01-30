:-lib(ic).

solve_lin(L) :- solve_lin1(L,C,Sum),sum(C) #= Sum,!.

solve_lin1([H=Val],L,Val)	:- solve_eq(H=Val,L). 
solve_lin1([H=Val|T],L1,Sum):- 
	solve_eq(H=Val,L),
	solve_lin1(T,J,S),
	append(L,J,L1),
	Sum is S + Val.

solve_eq(Expr = Val,L) :- breaklist(Expr,L),sum(L) #= Val.

breaklist(A,[A]):- 
	var(A);
	A =.. [*,X,Y],(number(X);number(Y)).
breaklist(A - B,[-B|Res]) :- breaklist(A,Res).
breaklist(A + B,[B|Res]) :- breaklist(A,Res).

:- solve_lin([X*2 + Y = 3, 3*Y - 2*X = 1]),write(X),write(' '),write(Y),write('\n').
%:- solve_lin([X + Y = 3, 3 * Y - X = 1]),write(X),write(' '),write(Y),write('\n').

