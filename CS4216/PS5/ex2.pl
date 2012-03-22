:-lib(ic).
solve(B,L,Prod) :-
	dim(L,[B]),
	%length(L,B),
	length(Prod,B),
	flatten_array(L,ListL),
	Last is B-1,
	ListL :: 0..Last,
	writeln(L),
	(
		foreacharg(A,L),count(I,0,Last),foreach(A*I,Prod),
		param(Last,L) do
			Count = L[A],
			(A $> 0 or Count $=< 0)
	),
	sum(ListL) #= B,
	sum(Prod) #= B,
	labeling(L).
