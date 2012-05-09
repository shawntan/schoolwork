:- lib(ic).
:- lib(branch_and_bound).

solve(X,Y) :- 
	[X,Y]:: -100..100,
	X+Y #= 10,
	Cost #= -1*X,
	minimize(labeling([X,Y]),Cost).
