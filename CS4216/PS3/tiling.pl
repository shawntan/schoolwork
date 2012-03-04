:-lib(suspend).
solve(N,Blanks,Grid):-
	constraints(N,Blanks,TileCount,Grid1,VarList),
	search(TileCount,VarList),
	(
		foreacharg(R,Grid1),foreach(RL,Grid) do flatten_array(R,RL)
	).

constraints(N,Missing,TileCount,Grid,VarList):-
	dim(Grid,[N,N]),
	length(Missing,M),
	CellCount is (N*N)-M,
	T is CellCount/2,
	integer(T,TileCount),
	length(VarList,CellCount),
	(
		multifor([I,J],1,N),param(Grid,Missing,N,VarList,TileCount),fromto(VarList,InVars,OutVars,[]),param(VarList) do
		(
			(member((I-J),Missing) ->
				OutVars = InVars,
				subscript(Grid,[I,J],0);
				(
					subscript(Grid,[I,J],C),
					InVars = [C|OutVars],
					C :: 1..TileCount,
					((I>1) -> L = Grid[I-1,J];L is -1),
					((I<N) -> R = Grid[I+1,J];R is -2),
					((J>1) -> U = Grid[I,J-1];U is -3),
					((J<N) -> D = Grid[I,J+1];D is -4),
					L $\= R,L $\= U,L $\= D, %all different
					R $\= U,R $\= D,
					U $\= D,
					(C $= L or C $= R or C $= U or C $= D)
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

sus_member(E,L) :- sus_member(E,L,0).
sus_member(_,[],C):- C.
sus_member(E,[H|T],C):- sus_member(E,T,C or (E $= H)).

memberlist([],_).
memberlist([H|T],L) :- sus_member(H,L), memberlist(T,L).

distinct(K,L) :-
	length(M,K),
	(for(I,1,K),foreach(A,M) do A=I),
	memberlist(M,L),
	memberlist(L,M).

%:-constraints(3,[2-2],G,V),
%	nl,nl,
%	write(G),
%	subscript(G,[2,1],1),nl,
%	write(G),
%	nl,nl.

