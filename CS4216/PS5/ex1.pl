
:-lib(eplex).

/*
 * Kirchoff's current rule
 */
preprocess(Circuit,AugCircuit,Points) :-
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
current_cons(Points,AugCircuit,CurrList) :-
	(
		foreach(P,Points),
		fromto([],ConsIn,ConsOut,CurrList),
		param(AugCircuit) do
			point_con(P,AugCircuit,Currs),
			append(ConsIn,[Currs],ConsOut)
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
/*
 *  Kirchoff's voltage rule
 */
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
voltage_cons(AugCircuit,VoltList) :-
	(
		foreach(C,AugCircuit),
		fromto([],ConsIn,ConsOut,VoltList),
		param(AugCircuit) do
			(C = (T,_), T =.. [battery|_] ->
				writeln("hey!"),
				delete(C,AugCircuit,Circuit),
				bagof(Loop,loop(C,Circuit,Loop),Cons),
				append(ConsIn,Cons,ConsOut);
				ConsIn = ConsOut
			)
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
	Circuit = [
		ground(a),
		battery(d,a,3),
		resistor(d,a,10),
		battery(a,b,3),
		resistor(d,c,3),
		resistor(c,b,5)
	],
	preprocess(Circuit,AugCircuit,Points),
	current_cons(Points,AugCircuit,CurrList),
	voltage_cons(AugCircuit,VoltList),
	eplex_solver_setup(min(0)),
	(foreach(C,CurrList) do sum(C) $= 0),
	(foreach(C,VoltList) do sum(C) $= 0),
	eplex_solve(_),
	print_list(AugCircuit).
