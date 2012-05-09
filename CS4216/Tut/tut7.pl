:- lib(eplex).

solve(Cost):-
	eplex_solver_setup(max(Cost)),
	Nh3+Nh4cl $=< 50,
	3*Nh3 + 4*Nh4cl $=< 180,
	Nh4cl $=< 40,
	Cost $= 40*Nh3 + 50*Nh4cl,
	eplex_solve(Cost).

