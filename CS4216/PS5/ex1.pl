constraints(Circuit,[A|T],Cons) :-
	delete(ground(A),Circuit,Remaining),
	loops(A,Remaining,[A|T],Cons).

loops(Start,Circuit,[H|T],[Con|ConT]) :-
	delete(Comp,Circuit,Remaining),
	Comp =.. [P,H,N,Val],
	comp_cons(P,H,N,Val,Con),
	(N == Start ->
		T=[];
		T=[N|T1],loops(Start,Remaining,[N|T1],ConT)
	).

comp_cons(battery,H,N,Volts,Volts).
comp_cons(resistor,H,N,Ohms,I*Ohms).

