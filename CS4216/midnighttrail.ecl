part(0,Y,Y).

part(X,Y,Z) :- Z1 is Z - 1, part(X1, Y, Z1), X is X1 + 1.
part(X,Y,Z) :- Z1 is Z - 1, part(X, Y1, Z1), Y is Y1 + 1.

solve_eq(L = Val) :- var(L), L is Val.
solve_eq(L*R = Val) :-
	var(L), L is Val/R;
	var(R), R is Val/L.
solve_eq(L + R = Val) :- part(X,Y,Val), solve_eq(L = X), solve_eq(R = Y).
solve_eq(L - R = Val) :- part(X,Y,Val), solve_eq(L = X), Y1 is -Y, solve_eq(R = Y1).

%solve_lin([Eq]) :- solve_eq(Eq).
%solve_lin([Eq|T]) :- solve_lin(T),solve_eq(Eq).

%int_run(0).
%int_run(A) :- int_run(A1),A is A1 + 1.
%int_run(A) :- int_run(A1),A is A1 - 1.
