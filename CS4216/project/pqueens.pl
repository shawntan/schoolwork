:-lib(ic).
:-lib(branch_and_bound).

setup(N,Black,White) :-
	dim(Black,[N,N]),
	dim(White,[N,N]).

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
	flatten_array(Black,BlackQueens),4*sum(BlackQueens) #=< QRes,
	flatten_array(White,WhiteQueens), 4*sum(WhiteQueens) #=< QRes,
	sum(BlackQueens) #= sum(WhiteQueens),
	8*sum(BlackQueens) #>= N*N,
	8*sum(WhiteQueens) #>= N*N.


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




test(N,B,W) :-
	setup(N,B,W),
	%eplex_solver_setup(min(0)),
	constraints(N,B,W),
	flatten_array(B,Blacks),
	flatten_array(W,Whites),
	Cost #= N*N - sum(Blacks) - sum(Whites),
	Cost #>= 0,
	%minimize(labeling(Comb),Cost),
	%minimize(search(Comb,0,first_fail,indomain_max,complete,[]),Cost),
	%bb_min(search(Comb,0,first_fail,indomain_max,complete,[]),Cost,_),
	%bb_min(search(Comb,0,input_order,sbds_indomain,sbds,[]),Cost,_),
	%eplex_solve(Cost),
	generate_cells(N,L),
	bb_min(
		(
			search(N,B,L,[]),
			retractall(seen(_)),
			labeling(Whites)
		),
	Cost,_),
	print_grid(N,B,W).

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
	).

generate_cells(N,L):-
	I :: 1..N, J :: 1..N,
	findall([I,J],(indomain(I),indomain(J)),L).


:-dynamic seen/1.
search(_,_,[],_) :- !.
search(N,B,[H|T],Ass):-
	subscript(B,H,Var),
	indomain(Var,max),
	(Var =:= 1 -> sort([H|Ass],Ass1) ; Ass1=Ass),
	(seen(Ass1) ->
		fail;
		search(N,B,T,Ass1),
		assert_sym(N,Ass1)
	).

%	search(_,[],_).
%	search(B,Coords,Pos) :-
%		writeln(Pos),
%		(foreach(C,Coords),param(B,Pos,Coords) do
%			subscript(B,C,Val),
%			(ground(Val),Val =:= 1 -> Pos1 = [C|Pos]; Pos1 = Pos),
%			(var(Val) ->
%				(
%					(indomain(Val),
%					delete(C,Coords,Coords1),
%					search(B,Coords1,Pos1));
%					true
%				);
%				true
%			)
%		).

%assert all rotations of current state of assignment
assert_sym(_,[]) :- !.
assert_sym(N,Ass) :-
	assert(seen(Ass)),
	SymPos = [x,y,d1,d2,r1,r2,r3],
	(foreach(F,SymPos),param(N,Ass) do
		(foreach(C,Ass),foreach(D,RotAss),param(N,F) do get_sym(F,N,C,D)),
		sort(RotAss,SRotAss),
		assert(seen(SRotAss))
	).

remove_sym(N,H,T,Result) :-
	get_sym(_,N,H,R),
	delete(R,T,Result).

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
