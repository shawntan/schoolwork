solve( true, ConstrIn, ConstrOut ) 	:- !,solveconstr(ConstrIn,ConstrOut).
solve( A, ConstrIn, ConstrOut ) :-
	arithmetic(A,B),!,
	solveconstr([B|ConstrIn],ConstrOut).
solve( (A,B), ConstrIn, ConstrOut ) :- !,
	solve(A,ConstrIn,C1),
	solveconstr(C1,C2),
	solve(B,C2,C3),
	solveconstr(C3,ConstrOut).
solve( H, ConstrIn, ConstrOut ) :-
	clause(H,Body),
	solve(Body,ConstrIn,ConstrAux),
	solveconstr(ConstrAux,ConstrOut).

solveconstr(L,L) :- solveconstraux(L,L),!.
solveconstr(In,Out) :-
	solveconstraux(In,Aux),solveconstr(Aux,Out).

arithmetic( (sepia_kernel : (X =:= Y)), X =:= Y ) :- !.
arithmetic( (sepia_kernel : (X < Y)), X < Y ) :- !.
arithmetic( (sepia_kernel : (X =< Y)), X =< Y ) :- !.
arithmetic( (sepia_kernel : (X > Y)), X > Y ) :- !.
arithmetic( (sepia_kernel : (X >= Y)), X >= Y ) :- !.
arithmetic( (sepia_kernel : -(X,Y,Z)), -(X,Y,Z) ) :- !.
arithmetic( (sepia_kernel : +(X,Y,Z)), +(X,Y,Z) ) :- !.
arithmetic( (sepia_kernel : *(X,Y,Z)), *(X,Y,Z) ) :- !.

iseval((X=:=Y)) :-  ground(Y),!, X is Y.
iseval((X=:=Y)) :-  ground(X),!, Y is X.
iseval(-(X,Y,Z)) :- ground(X-Y), !, Z is X-Y.
iseval(-(X,Y,Z)) :- ground(X-Z), !, Y is X-Z.
iseval(-(X,Y,Z)) :- ground(Y+Z), !, X is Y+Z.
iseval(+(X,Y,Z)) :- ground(X+Y), !, Z is X+Y.
iseval(+(X,Y,Z)) :- ground(Z-X), !, Y is Z-X.
iseval(+(X,Y,Z)) :- ground(Z-Y), !, X is Z-Y.
iseval(*(X,Y,Z)) :- ground(X*Y), !, Z is X*Y.
iseval(*(X,Y,Z)) :- ground(Z//Y), !, X is Z//Y.
iseval(*(X,Y,Z)) :- ground(Z//X), !, Y is Z//X.

solveconstraux([],[]).
solveconstraux([C|T],L) :-
	iseval(C),!,solveconstraux(T,L).
solveconstraux([C|T],L) :-
	iseval(C),!,C, solveconstraux(T,L).
solveconstraux([C|T],[C|L]) :- solveconstraux(T,L).

:-dynamic fact/2.
fact(1,1).
fact(X,R) :- X > 1, X1 =:= X-1, R =:= R1*X,fact(X1,R1).

:-dynamic p/1.
p(t) :- body.



:- solve(fact(5,R),[],_).
%:- solve(fact(N,120,[],_)).


%:- solve_lin([X*2 + Y = 3, 3*Y - 2*X = 1]),write(X),write(' '),write(Y),write('\n').
%:- solve_lin([X + Y = 3, 3 * Y - X = 1]),write(X),write(' '),write(Y),write('\n').
