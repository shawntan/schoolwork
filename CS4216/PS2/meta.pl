:- dynamic p/1.
:- dynamic q/1.
:- dynamic r/1.

p(X) :- q(X).
q(X) :- r(X).
r(X) :- true.

solve(true,_) :- !.
solve((A,B),Callstack) :- !,
	solve(A,Callstack),
	solve(B,Callstack).
solve(H,Callstack) :-!,
	clause(H,Body),
	(member(H,Callstack) ->
		write('Infinite loop detected, execution aborted'),nl;
		solve(Body,[H|Callstack])
	).
