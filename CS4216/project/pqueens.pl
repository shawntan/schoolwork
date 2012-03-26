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
	QRes is floor(N*N)/4,
	flatten_array(Black,BlackQueens),sum(BlackQueens) $=< QRes,
	flatten_array(White,WhiteQueens), sum(WhiteQueens) $=< QRes,
	sum(BlackQueens) #= sum(WhiteQueens),
	sum(BlackQueens) #>= 1,
	sum(WhiteQueens) #>= 1.


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
	constraints(N,B,W),
	flatten_array([](B,W),Comb),
	Cost #= N*N - sum(Comb),
	Cost #>= 0,
	%minimize(labeling(Comb),Cost),
	minimize(search(Comb,0,first_fail,indomain_max,complete,[]),Cost),
	print_grid(N,B,W).

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
