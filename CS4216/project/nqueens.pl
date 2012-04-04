% 
% Non-dominating queens problem:
%
%	Place N queens on an NxN board such that the minimal number
%	of squares is under attack. The queens may attack each other.
%
% Using SBDS to break all symmetries.
%
% Author: Joachim Schimpf, IC-Parc
% Requires: ECLiPSe>=5.8
%

:- lib(ic).
:- lib(branch_and_bound).
:- lib(ic_sbds).

sbds_indomain(Var) :-
	nonvar(Var).
sbds_indomain(Var) :-
	var(Var),
	mindomain(Var, LWB),
	sbds_try(Var, LWB),
	sbds_indomain(Var).


ndq(N, Board, Attacked, NAttacks) :-
	dim(Board, [N,N]),		% Bool: field [I,J] is occupied
	flatten_matrix(Board, Fields),
	Fields :: 0..1,
	sum(Fields) #= N,

	dim(Attacked, [N,N]),		% Bool: field [I,J] is under attack
	flatten_matrix(Attacked, Attacks),
	Attacks :: 0..1,
	NAttacks #= sum(Attacks),
	( multifor([I,J],1,N), param(Board,Attacked,N) do
	    findall(K-L,
		(between(1,N,1,K), between(1,N,1,L), attacks(K,L,I,J)),
		AttackPos),
	    ( foreach(K-L,AttackPos), param(Board,Attacked,I,J) do
		Attacked[I,J] #>= Board[K,L]
	    )
	),

	sbds_initialise(Board, 2,
	    [r90(Board, N), r180(Board, N), r270(Board, N),
	     rx(Board, N), ry(Board, N), rd1(Board, N), rd2(Board, N)],
	    #=, []),
	bb_min(
	    search(Fields, 0, input_order, sbds_indomain, sbds, []),
	    NAttacks, _).


    attacks(K,L,I,J) :-			% field [K,L] attacks [I,J]
	( K =:= I -> true
	; L =:= J -> true
	; K-L =:= I-J -> true
	; K+L =:= I+J
	).

    flatten_matrix(M, Xs) :-
	dim(M, Dims),
	( multifor(Index,1,Dims), foreach(X,Xs), param(M) do
	    subscript(M, Index, X)
	).


% The following is copied from the lib(ic_sbds) reference manual

r90(Matrix, N, [X,Y], Value, SymVar, SymValue) :-
    SymVar is Matrix[Y, N + 1 - X],
    SymValue is Value.

r180(Matrix, N, [X,Y], Value, SymVar, SymValue) :-
    SymVar is Matrix[N + 1 - X, N + 1 - Y],
    SymValue is Value.

r270(Matrix, N, [X,Y], Value, SymVar, SymValue) :-
    SymVar is Matrix[N + 1 - Y, X],
    SymValue is Value.

rx(Matrix, N, [X,Y], Value, SymVar, SymValue) :-
    SymVar is Matrix[N + 1 - X, Y],
    SymValue is Value.

ry(Matrix, N, [X,Y], Value, SymVar, SymValue) :-
    SymVar is Matrix[X, N + 1 - Y],
    SymValue is Value.

rd1(Matrix, _N, [X,Y], Value, SymVar, SymValue) :-
    SymVar is Matrix[Y, X],
    SymValue is Value.

rd2(Matrix, N, [X,Y], Value, SymVar, SymValue) :-
    SymVar is Matrix[N + 1 - Y, N + 1 - X],
    SymValue is Value.

