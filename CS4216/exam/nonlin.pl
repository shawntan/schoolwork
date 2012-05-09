:- lib(eplex).
:- lib(branch_and_bound).

cons(X, Y) :-[X,Y] :: 0_1..10_1, X+Y $>= 6.

return_solution :-
	eplex_get(vars, Vars),
	eplex_get(typed_solution, Vals),
	Vars = Vals.

nlsearch(X, Y, SX, SY) :-
	eplex_var_get(X, solution, ValX),
	eplex_var_get(SX, solution, ValSX),
	eplex_var_get(Y, solution, ValY),
	eplex_var_get(SY, solution, ValSY),
	abs(ValX*ValX-ValSX) =< 1_10000000000000,
	abs(ValY*ValY-ValSY) =< 1_10000000000000,!,
	return_solution.

nlsearch(X, Y, SX, SY) :-
	make_choice(X),
	make_choice(Y),
	add_linear_cons(X, SX),
	add_linear_cons(Y, SY),
	nlsearch(X, Y, SX, SY).

make_choice(X) :-
	eplex_var_get_bounds(X, Xmin, Xmax),
	Val is (Xmin+Xmax)/2_1,
	writeln('Choice'=Val),
	( X $>= Val ; X $=< Val ).

add_linear_cons(X, SX) :-
	eplex_var_get_bounds(X, Min, Max),
	SMin is Min*Min,
	SMax is Max*Max,
	SX $>= SMin,
	SX $=< SMax%,
		%X*Min $=< SX,
		%X*Max $>= SX
		.

nonlin(X, Y, Cost) :-
	Cost :: 0.0..inf, %1
	eplex_solver_setup(min(Cost),Cost,[],[bounds, new_constraint]), %2
	cons(X, Y), %3
	add_linear_cons(X, SX), %4
	add_linear_cons(Y, SY), %4
	Cost $= SX+SY, %5
	minimize(nlsearch(X, Y, SX, SY), Cost), %6
	return_solution, %7
	eplex_cleanup. %8
