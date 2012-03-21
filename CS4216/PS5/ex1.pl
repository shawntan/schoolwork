
:-lib(eplex).

/*
 * Kirchoff's current rule
 */
current(Circuit,AugCircuit,Points) :-
	(
		foreach(C,Circuit),
		foreach((C,_),AugCircuit),
		fromto([],PIn,POut,PointsDup)
		do
			(C =.. [_,A,B,_] ->
				POut = [A,B|PIn];
				POut = PIn
			)
	),
	sort(PointsDup,Points).
current_cons(Points,AugCircuit) :-
	(
		foreach(P,Points),param(AugCircuit) do
		point_con(P,AugCircuit,Currs),
		sum(Currs) $= 0
	).
point_con(Point,AugCircuit,Currs) :-
	(
		foreach((C,I),AugCircuit),
		fromto([],CurIn,CurOut,Currs),param(Point) do
		((C =.. [_,Point,_,_],Cur = -I ; C =.. [_,_,Point,_],Cur = I) ->
			CurOut = [Cur|CurIn];
			CurOut = CurIn
		)
	).

test(Circuit,AugCircuit,Point):-
	Circuit = [ground(a),battery(a,b,10),resistor(b,a,1),resistor(b,a,1)],
	current(Circuit,AugCircuit,Points),
	current_cons(Points,AugCircuit).

