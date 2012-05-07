:-lib(ic).
:-lib(branch_and_bound).


/* 1. modeling of the problem */
setup(N,Black,White) :-
	dim(Black,[N,N]),
	dim(White,[N,N]).

/* 2. setting up constraints over both boards */
constraints(N,Black,White) :-
	(
		foreacharg(BR,Black),
		foreacharg(WR,White),
		count(I,1,N),param(N,White,Black) do
			(foreacharg(BC,BR),
				foreacharg(WC,WR),
				count(J,1,N),param(N,I,White,Black) do
				BC :: 0..1,
				WC :: 0..1,
				cell_constraints(N,I,J,White,Black),
				cell_constraints(N,I,J,Black,White)
			)
	),
	QRes is N*N,
	
	
	/* restricting minimum and maximum no. of queens */

	flatten_array(Black,BlackQueens),4*sum(BlackQueens) #=< QRes,
	flatten_array(White,WhiteQueens), 4*sum(WhiteQueens) #=< QRes,
	sum(BlackQueens) #= sum(WhiteQueens),
	(N > 3 ->
		8*sum(BlackQueens) #>= N*N,
		8*sum(WhiteQueens) #>= N*N;
		true
	).

/* 3. setting up horizontal, vertical and diagonal constraints (across both boards) */
cell_constraints(N,I,J,Grid1,Grid2) :-
	subscript(Grid1,[I,J],Cell),
	(count(K,1,N),param(N,Cell,I,J,Grid2) do
		subscript(Grid2,[I,K],OR),
		subscript(Grid2,[K,J],OC),
		%(Cell #= 1 and OR #= 0) or Cell #= 0,
		%(Cell #= 1 and OC #= 0) or Cell #= 0,
		Cell + OR #=<1,
		Cell + OC #=<1,
		DJ is K - J,
		(I + DJ > 0, I + DJ < N+1 -> Cell + Grid2[I + DJ,K] #=< 1;true),
		(I - DJ > 0, I - DJ < N+1 -> Cell + Grid2[I - DJ,K] #=< 1;true)
	).


/* SEARCH */
generate_cells(N,L):-
	I :: 1..N, J :: 1..N,
	findall([I,J],(indomain(I),indomain(J)),L).


:-dynamic seen/2.
search(_,_,[],_) :- !.

/* Main search predicate */
search(N,B,[H|T],Ass):-
	subscript(B,H,Var),
	indomain(Var,max),
	(Var =:= 1 -> sort([H|Ass],Ass1); Ass1=Ass),
	length(Ass1,Len),


	/* check if some rotation of the assignment has been seen */


	(seen(Len,Ass1) ->
		fail;
		search(N,B,T,Ass1),
		assert_sym(N,Ass1)
	).

/*assert all rotations of current state of assignment (ugghh)*/
assert_sym(_,[]) :-!.
assert_sym(N,Ass) :-
	length(Ass,Len),
	assert(seen(Len,Ass)),
	SymPos = [x,y,d1,d2,r1,r2,r3],
	(foreach(F,SymPos),param(N,Ass,Len) do
		(foreach(C,Ass),foreach(D,RotAss),param(N,F) do get_sym(F,N,C,D)),
		sort(RotAss,SRotAss),
		(seen(Len,SRotAss)-> true;assert(seen(Len,SRotAss)))
	).


/*Different rotation predicates*/
get_sym(x,N,[I,J],[I,J1]) :- J1 is N - J + 1.
get_sym(y,N,[I,J],[I1,J]) :- I1 is N - I + 1.
get_sym(d1,_,[I,J],[J,I]).
get_sym(d2,N,[I,J],[I1,J1]) :-
	I1 is N - J + 1,
	J1 is N - I + 1.
get_sym(r1,N,[I,J],[I1,J1]) :-
	I1 is N - J + 1,
	J1 is I.
get_sym(r2,N,[I,J],[I1,J1]) :-
	I1 is N - I + 1,
	J1 is N - J + 1.
get_sym(r3,N,[I,J],[I1,J1]) :-
	I1 is J,
	J1 is N - I + 1.

/*
*  Putting all that crap together.
*/
test(N,B,W) :-
	retractall(seen(_,_)),
	setup(N,B,W),
	constraints(N,B,W),
	flatten_array(B,Blacks),
	flatten_array(W,Whites),
	Cost #= N*N - sum(Blacks) - sum(Whites),
	LB is 2*(N*N/8),
	fix(LB,LowerBound),
	Cost #=< N*N - LowerBound,
	UB is 2*(N*N/4),
	fix(UB,UpperBound),
	Cost #>= N*N - UpperBound,
	writeln(Cost),
	generate_cells(N,L),
	Q #= sum(Blacks),
	%bb_min(
	%findall(_,(
	minimize((
			search(N,B,L,[]),
			labeling(Whites),
			print_grid(N,B,W),
			writeln(Q)
	),Cost).
	%),_).
	%Cost,_),

print_grid(N,Black,White) :-
	(count(I,1,N),param(White,Black,N) do
		(count(J,1,N),param(I,White,Black) do
			subscript(Black,[I,J],G),
			(ground(G) ->
				(
					White[I,J] =:= 1-> write('W');
					Black[I,J] =:= 1-> write('B');
					write('_')
				); write('?')
			),write(' ')
		),nl
	),nl.

:-test(9,B,W).
:-halt.


