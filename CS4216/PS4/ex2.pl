:-lib(suspend).
%layout(Tree,L,M,LaidTree) :-
traverse(Leaf,Depth,L,_,NewLeaf,X,Y,_) :-
	atom(Leaf),
	Y is Depth*L,
	NewLeaf =.. [Leaf,X,Y].
traverse(Tree,Depth,L,M,NewTree,X,Y,Width) :-
	Tree =.. [Node|Params],
	length(Params,ParamLen),
	length(NewParams,ParamLen),
	length(XCoords,ParamLen),
	Depth1 is Depth + 1,
	(
		foreach(Sub,Params),
		foreach(NewPar,NewParams),
		foreach(X,XCoords),
		param(L,M,Depth1,Width) do
			traverse(Sub,Depth1,L,M,NewPar,X,Y,Width)
	),
	XCoords = [FirstChildX|_],
	append(_,[LastChildX],XCoords),
	X $= FirstChildX + (LastChildX - FirstChildX)/2,
	x_constraints(XCoords,M,Width),
	Y is Depth*L,
	append(NewParams,[X,Y],NewParams1),
	NewTree =.. [Node|NewParams1].

x_constraints([H|T],M,Width) :-
	H $>= 0,
	(
		fromto(
			(H,T),
			(V1,[V2|RestVars]),
			(V2,RestVars),
			(Last,[])
		),param(M) do
			V2 $>= V1 + M
	),
	Last $=< Width.
