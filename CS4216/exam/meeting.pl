:- lib(ic).

after(event(_,AS,AE),event(_,BS,BE)) :- AE $=< BS.
meets(event(_,AS,AE),event(_,BS,BE)) :- AE $= BS.
overlaps(event(_,AS,AE),event(_,BS,BE)) :- AS$=<BS,BS$=<AE.
starts(event(_,AS,AE),event(_,BS,BE)) :- AS$=BS,AE$=<BE.
during(event(_,AS,AE),event(_,BS,BE)) :- BS$=<AS,AE$=<BE.
finishes(event(_,AS,AE),event(_,BS,BE)) :- BS$=<AS,AE$=BE.
equals(event(_,AS,AE),event(_,BS,BE)) :- BS$=AS,AE$=BE.

meeting(L) :-
	J = event(jones,JS,JE),JE $> JS,
	W = event(white,WS,WE),WE $> WS,
	S = event(smith,SS,SE),SE $> SS,
	B = event(brown,BS,BE),BE $> BS,
	M = event(meeting,0,ME), ME $> 0,
	L = [J,W,S,B,M],
	constraints(J,W,S,B,M).

constraints(J,W,S,B,M):-
	starts(J,M),
	finishes(B,M),
	after(J,S),
	overlaps(B,W),
	overlaps(S,B).


