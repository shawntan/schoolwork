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
	(
		multifor([I,J],1,N),param(Grid,N,Missing),foreach(Var,VarList) do
			(member((I-J),Missing) ->
				subscript(Grid,[I,J],0),Var=0;
				(
					subscript(Grid,[I,J],C),
					Var = C,
					(J > 1 -> subscript(Grid,[I,J-1],Up);	Up		= 0),
					(J < N -> subscript(Grid,[I,J+1],Down);	Down	= 0),
					(I > 1 -> subscript(Grid,[I-1,J],Left);	Left	= 0),
					(I < N -> subscript(Grid,[I+1,J],Right);Right	= 0),
					(
						(C $=  Up and C $\= Left and C $\= Down and C $\= Right) or
						(C $\= Up and C $=  Left and C $\= Down and C $\= Right) or
						(C $\= Up and C $\= Left and C $=  Down and C $\= Right) or
						(C $\= Up and C $\= Left and C $\= Down and C $=  Right)
					)
				)
			)
	),
	TC is TileCount+1,
	distinct(TC,VarList).

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
memberlist([H|T],L) :- member(H,L), memberlist(T,L).

sorted([]).
sorted([_]).
sorted([H1,H2|T]) :- H1 $< H2, sorted([H2|T]).

distinct(K,L) :-
   length(M,K),
   sorted(M), % could be replaced by all_distinct(M), leads to more solutions.
   memberlist(M,L), memberlist(L,M).

%:-constraints(3,[2-2],G,V),
%	nl,nl,
%	write(G),
%	subscript(G,[2,1],1),nl,
%	write(G),
%	nl,nl.

