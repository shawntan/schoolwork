
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

loop((C,I),RestCircuit,[Val|Loop]) :-
	C =.. [battery,A,B,Val],
	(
		fromto(
			(B,  RestCircuit,Loop		),
			(P1, InCirc,	[H|OutLoop]	),
			(P2, OutCirc,	OutLoop		),
			(A,  _,			[]			)
		) do
		delete((Seg,I),InCirc,OutCirc),
		((
			Seg =.. [C,P1,P2,V],
			comp_volt(C,V,I,H)
		);(
			Seg =.. [C,P2,P1,V],
			comp_volt(C,V,I,H1),
			H = -H1
		))
	).

comp_volt(resistor,Val,I,-I*Val).
comp_volt(battery,Val,_,Val).

battery_cons(Bat,AugCircuit) :-
	delete(Bat,AugCircuit,Circuit),
	bagof(Loop,loop(Bat,Circuit,Loop),Cons),
	(
		foreach(C,Cons) do
		sum(C) $= 0
	).

test_looper(Circuit,Cons,I1,I2,I3,I4,I5) :-
	Circuit = [
		(resistor(c,b,2),I1),
		(resistor(c,d,2),I2),
		(resistor(d,a,2),I3),
		(resistor(d,a,2),I4),
		(resistor(d,a,3),I5)
	],
	bagof(Loop,loop((battery(a,b,1),II),Circuit,Loop),Cons),
	(
		foreach(C,Cons) do
		sum(C) $= 0
	).

test(Circuit,AugCircuit,Point):-
	Circuit = [ground(a),battery(a,b,10),resistor(b,a,1),resistor(b,a,1)],
	current(Circuit,AugCircuit,Points),
	current_cons(Points,AugCircuit).

