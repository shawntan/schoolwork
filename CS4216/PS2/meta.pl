solve(true,_) :- !.
solve((A,B),Callstack) :- !,
	solve(A,Callstack),
	solve(B,Callstack).
solve(H,Callstack) :-!,
	clause(H,Body),
	(strict_member(H,Callstack) ->
		write('Infinite loop detected, execution aborted'),nl;
		solve(Body,[H|Callstack])
	).


arithmetic(_<_).
arithmetic(_>_).
arithmetic(_=<_).
arithmetic(_>=_).
arithmetic(_=:=_).
arithmetic(_=\=_).

strict_member(H,[H1]) :- H==H1.
strict_member(H,[H1|_]) :- H==H1,!.
strict_member(H,[_|T]) :- strict_member(H,T).

:- dynamic p/2.
:- dynamic q/1.
:- dynamic r/1.

p(X,[X]).
p(X,[H|T]) :- p(X,T).


