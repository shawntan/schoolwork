:-lib(suspend).
solve(N,Blanks,Result):-
	constraints(Grid),
	search(Grid),
	massage(Grid,Result).

constraints(N,Missing,Grid,VarList):-
	dim(Grid,[N,N]),
	length(Missing,M),
	CellCount is (N*N)-M,
	T is CellCount/2,
	integer(T,TileCount),
	VarList :: [0..TileCount],
	(
		multifor([I,J],1,N),param(Grid,N,Missing),foreach(Var,VarList) do
			(member((I-J),Missing) ->
				subscript(Grid,[I,J],x),Var=0;
				(
					subscript(Grid,[I,J],C),
					Var = C,
					(J > 1 -> subscript(Grid,[I,J-1],Up);	Up		= edge),
					(J < N -> subscript(Grid,[I,J+1],Down);	Down	= edge),
					(I > 1 -> subscript(Grid,[I-1,J],Left);	Left	= edge),
					(I < N -> subscript(Grid,[I+1,J],Right);Right	= edge),
					(
						(C $=  Up and C $\= Left and C $\= Down and C $\= Right) or
						(C $\= Up and C $=  Left and C $\= Down and C $\= Right) or
						(C $\= Up and C $\= Left and C $=  Down and C $\= Right) or
						(C $\= Up and C $\= Left and C $\= Down and C $=  Right)
					)
				)
			)
	).

memberlist([],_).
memberlist([H|T],L) :- member(H,L), memberlist(T,L).

sorted([]).
sorted([_]).
sorted([H1,H2|T]) :- H1 $< H2, sorted([H2|T]).

distinct(K,L) :-
   length(M,K),
   sorted(M), % could be replaced by all_distinct(M), leads to more solutions.
   memberlist(M,L), memberlist(L,M).
