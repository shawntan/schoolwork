all_cells(0,0,[]).
all_cells(0,H,OtherCells) :- H1 is H-1,all_cells(H1,H1,OtherCells),!.
all_cells(L,L,[(L,L)|OtherCells]) :- L1 is L-1,all_cells(L1,L,OtherCells),!.
all_cells(L,W,[(L,W),(W,L)|OtherCells]) :- L1 is L-1,all_cells(L1,W,OtherCells),!.

remove_blanks([],_,[]).
remove_blanks([(X,Y)|Cells],Blanks,NewCells):-
	member(X-Y,Blanks),
	remove_blanks(Cells,Blanks,NewCells),!.
remove_blanks([Cell|Cells],Blanks,[Cell|NewCells]) :-
	remove_blanks(Cells,Blanks,NewCells),!.

generate_cells(N,Blanks,Cells) :-
	all_cells(N,N,AllCells),
	sort(AllCells,SortCells),
	remove_blanks(SortCells,Blanks,Cells).

solve_cells_([],[]).
solve_cells_([(X,Y)|Cells],[((X,Y),((X1,Y1)))|RestTiles]) :-
	(
		(X1 is X,Y1 is Y+1);
		(Y1 is Y,X1 is X+1)
	),
	delete((X1,Y1),Cells,RestCells),
	solve_cells_(RestCells,RestTiles).

solve_cells(N,Blanks,Results) :-
	generate_cells(N,Blanks,Cells),
	solve_cells_(Cells,Results).
massage_soln(N,Cells,Result) :-
	dim(Result,[N,N]),
	(
		fromto(
			(1,Cells),
			(I,[((X,Y),(X1,Y1))|OutCells]),
			(J,OutCells),
			(_,[])
		),param(Result) do 
			subscript(Result,[X,Y],I),
			subscript(Result,[X1,Y1],I),
			J is I + 1
	).
solve(N,Blanks,Result) :-
	solve_cells(N,Blanks,Pairs),
	massage_soln(N,Pairs,Result).
