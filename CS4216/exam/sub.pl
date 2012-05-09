toset([],[]) :- !.
toset([H|T],[H|S]):-
	(member(H,T) -> delete(H,T,R);R=T),
	toset(R,S).

onion([],L,L) :- !.
onion([H|T],L,[H|Res]) :-
	(member(H,L) -> delete(H,L,R);R=L),
	union(T,R,Res).

intersexion([],_,[]) :- !.
intersexion([H|T],L,[H|Res]) :- member(H,L),intersexion(T,L,Res),!.
intersexion([_|T],L,Res)     :- intersexion(T,L,Res),!.

subsex([],_):-!.
subsex([H|T],L2):-member(H,L2),subsex(T,L2).

difference([],_,[]) :- !.
difference([H|T],L,Res) :- member(H,L),difference(T,L,Res),!.
difference([H|T],L,[H|Res]) :- difference(T,L,Res),!.

prefixmin(L,M) :-
	(foreach(I,L),foreach(J,M),fromto(1.0Inf,MIn,MOut,_)
		do min(MIn,I,MOut),J=MOut
	).

permlist(L,Z) :-
	findall(G,
		(fromto(
			(L,G),
			(LIn,[H|T]),
			(LOut,T),
			([],[])) do
				delete(H,LIn,LOut)
		),Z).

merge_it(L1,L2,X) :-
	length(L1,N1),
	length(L2,N2),
	Len is N1 + N2,
	length(X,Len),
	(fromto((L1,L2,X),
			(IL1,IL2,[H|T]),
			(OL1,OL2,T),
			(_,_,[])) do
		(IL1 = [H1|T1],IL2 = [H2|T2] ->
			(H1 < H2 ->
				H = H1, OL1 = T1, OL2 = [H2|T2];
				H = H2, OL2 = T2, OL1 = [H1|T1]
			);
			(
				(IL1 = [HA|TA],!;IL2 = [HA|TA],!),
				H = HA, OL1 = TA, OL2 = []
			)
		)
	).
