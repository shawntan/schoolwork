:-lib(ic).
solve(M,W,Cost) :-
	length(M,N),
	length(W,N),
	alldifferent(W),
	(foreach(I,W),foreach(J,M),foreach(C,Costs) do
		element(I,J,C)
	),
	Cost #= sum(Costs),
	Cost #>= 3,
	W :: 1..N,
	labeling(W).
