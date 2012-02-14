:- dynamic qs/2.

qs([],[]).
qs([X|Xs],Ys) :-
	part(X,Xs,Littles,Bigs),
	qs(Littles,Ls),
	qs(Bigs,Bs),
	app(Ls,[X|Bs],Ys).
part(_,[],[],[]).
part(X,[Y|Xs],[Y|Ls],Bs) :- X > Y, part(X,Xs,Ls,Bs).
part(X,[Y|Xs],Ls,[Y|Bs]) :- X =< Y, part(X,Xs,Ls,Bs).

solve( true, 0 ) :- !.
solve( (A,B), N ) :- !,solve(A,N1), solve(B,N2), N is N1 + N2.
solve( H, N ) :- clause(H,Body),solve(Body,M), N is M+1.


