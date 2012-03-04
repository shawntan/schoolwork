:-lib(suspend).
solve(N,Blanks,Grid):-
	constraints(N,Blanks,TileCount,Grid,VarList),
	write(Grid),nl,
	write(VarList),nl,
	search(TileCount,VarList).

constraints(N,Missing,TileCount,Grid,VarList):-
	dim(Grid,[N,N]),
	length(Missing,M),
	CellCount is (N*N)-M,
	T is CellCount/2,
	integer(T,TileCount),
	length(VarList,CellCount),
	(
		multifor([I,J],1,N),param(Grid,Missing,N,VarList),fromto(VarList,InVars,OutVars,[]),param(VarList) do
		(
			(member((I-J),Missing) ->
				OutVars = InVars,
				subscript(Grid,[I,J],0);
				(
					subscript(Grid,[I,J],C),
					InVars = [C|OutVars],
					(C $= L or C $= R or C $= U or C $= D),
					(I>1 -> subscript(Grid,[I-1,J],L);L is -1),
					(I<N -> subscript(Grid,[I+1,J],R);R is -2),
					(J>1 -> subscript(Grid,[I,J-1],U);U is -3),
					(J<N -> subscript(Grid,[I,J+1],D);D is -4),
					L $\= R,L $\= U,L $\= D,
					R $\= U,R $\= D,
					U $\= D
				)
			)
		)
	),
	distinct(TileCount,VarList).

search(TileCount,VarList) :-
	(
		foreach(V,VarList),param(TileCount) do
		(
			not(ground(V)) ->
				select_val(1,TileCount,V);
				true
		)
	).

select_val(1,N,Col) :-
	(
		fromto(fail,C,(C;(Col=I)),Q),for(I,1,N),param(Col) do true
	),Q.

memberlist([],_).
memberlist([H|T],L) :- suspend(member(H,L)), memberlist(T,L).

sorted([]).
sorted([_]).
sorted([H1,H2|T]) :- H1 $< H2, sorted([H2|T]).

distinct(K,L) :-
	length(M,K),
	sorted(M), % could be replaced by all_distinct(M), leads to more solutions.
	memberlist(M,L),
	memberlist(L,M).

%:-constraints(3,[2-2],G,V),
%	nl,nl,
%	write(G),
%	subscript(G,[2,1],1),nl,
%	write(G),
%	nl,nl.

