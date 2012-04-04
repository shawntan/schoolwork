%:-lib(ic).
%:-lib(ic_sbds).
%
:-lib(fd).
:-lib(fd_global).
:-lib(fd_sbds).
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
	sum(BlackQueens) #>= N-2,
	sum(WhiteQueens) #>= N-2.


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
	flatten_matrix(B,Comb),
	Cost #= N*N - sum(Comb),
	Cost #>= 0,

	Syms = [
		r90(B, N),
		r180(B, N),
		r270(B, N),
		x(B, N),
		y(B, N),
		d1(B, N),
		d2(B, N)
	],
	sbds_initialise(B, 2, Syms, #=, []),
	%minimize(labeling(Comb),Cost),
	%minimize(search(Comb,0,first_fail,indomain_max,complete,[]),Cost),
	%bb_min(search(Comb,0,first_fail,indomain_max,complete,[]),Cost,_),
	%bb_min(search(Comb,0,input_order,sbds_indomain,sbds,[]),Cost,_),
	%eplex_solve(Cost),
	sbds_labeling(Comb).
	%generate_cells(N,L),
	%search(B,L).
%print_grid(N,B,W).

print_grid(N,Black,White) :-
	(
		count(I,1,N),param(White,Black,N) do
			(count(J,1,N),param(I,White,Black) do
				(
					White[I,J] =:= 1-> write('W');
					Black[I,J] =:= 1-> write('B');
					write('_')
				),write(' ')
			),nl
	).

generate_cells(N,L):-
	I :: 1..N, J :: 1..N,
	findall([I,J],(indomain(I),indomain(J)),L).


search(_,[]).
search(B,[H|T]) :-
	subscript(B,H,Cell),
	(ground(Cell) -> true; indomain(Cell)),
	search(B,T).

sbds_labeling(AllVars) :-
        ( foreach(Var, AllVars) do
            sbds_indomain(Var)                       % select value
        ).

% Replacement for indomain/1 which takes SBDS into account.
sbds_indomain(X) :-
	nonvar(X).
sbds_indomain(X) :-
	var(X),
	mindomain(X, LWB),
	sbds_try(X, LWB),
	sbds_indomain(X).


r90(Matrix, N, Index, Value, SymVar, SymValue) :-
	SymVar is Matrix[Value],
	SymValue is N + 1 - Index.

r180(Matrix, N, Index, Value, SymVar, SymValue) :-
	SymVar is Matrix[N + 1 - Index],
	SymValue is N + 1 - Value.

r270(Matrix, N, Index, Value, SymVar, SymValue) :-
	SymVar is Matrix[N + 1 - Value],
	SymValue is Index.

rx(Matrix, N, Index, Value, SymVar, SymValue) :-
	SymVar is Matrix[N + 1 - Index],
	SymValue is Value.

ry(Matrix, N, Index, Value, SymVar, SymValue) :-
	SymVar is Matrix[Index],
	SymValue is N + 1 - Value.

rd1(Matrix, _N, Index, Value, SymVar, SymValue) :-
	SymVar is Matrix[Value],
	SymValue is Index.

rd2(Matrix, N, Index, Value, SymVar, SymValue) :-
	SymVar is Matrix[N + 1 - Value],
	SymValue is N + 1 - Index.
