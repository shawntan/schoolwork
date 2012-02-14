:- dynamic p/1.
:- dynamic q/1.
:- dynamic r/1.
r(X) :- q(X).
q(X) :- p(X).
p(t).

:- dynamic qs/2.
:- dynamic part/4.
:- dynamic app/3.
qs([],[]).
qs([X|Xs],Ys) :-
	part(X,Xs,Littles,Bigs),
	qs(Littles,Ls),
	qs(Bigs,Bs),
	app(Ls,[X|Bs],Ys).
part(_,[],[],[]).
part(X,[Y|Xs],[Y|Ls],Bs) :- X > Y, part(X,Xs,Ls,Bs).
part(X,[Y|Xs],Ls,[Y|Bs]) :- X =< Y, part(X,Xs,Ls,Bs).

app([],Ys,Ys).
app([X|Xs],Ys,[X|Zs]) :- app(Xs,Ys,Zs).



solve(true) :- !.
solve(A) :- arithmetic(A),incval(step_count), !,A.
solve((A,B)) :- !,solve(A), solve(B).
solve(H) :-
	clause(H,Body),
	incval(step_count),
	solve(Body).

arithmetic(_<_).
arithmetic(_>_).
arithmetic(_=<_).
arithmetic(_>=_).
arithmetic(_=:=_).
arithmetic(_=\=_).
