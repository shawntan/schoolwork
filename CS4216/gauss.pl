gaussian([],_).
gaussian(Vars,RestEqn):-
	gaussian_pass(Vars,RestEqn),
	solve_eqs(RestEqn).

gaussian_pass([],[]).
gaussian_pass([Var],[N*Var = Val]) :- Var is Val/N,!.
gaussian_pass([Var|RestVar],Eqns) :-
	delete(Eqn,Eqns,RestEqns),
	write([Var,Eqn]),nl,
	eliminate_all(Var,RestVar,Eqn,RestEqns,Result),
	gaussian_pass(RestVar,Result).


eliminate_all(_,_,_,[],[]).
eliminate_all(Var,RestVar,Expr1=Val1,[Expr2=Val2|Rest],[Expr2El=ValEl|Result]) :-
	eliminate(Var,RestVar,Expr1,Expr2,Expr2El),
	eliminate_all(Var,RestVar,Expr1=Val1,Rest,Result),
	get_coeff(Var,Expr1,A),
	get_coeff(Var,Expr2,B),
	ValEl is Val2/B - Val1/A.
eliminate_all(Var,RestVar,Eqn,[CantEqn|Rest],[CantEqn|Result]) :-
	eliminate_all(Var,RestVar,Eqn,Rest,Result).
eliminate(_,[],_,_,0).
eliminate(Var,[Var1|Rest],Expr1,Expr2,NewExpr) :-
	eliminate(Var,Rest,Expr1,Expr2,Rest1),
	get_coeff(Var,Expr1,A),
	(get_coeff(Var1,Expr1,B);B is 0),
	get_coeff(Var,Expr2,C),
	(get_coeff(Var1,Expr2,D); D is 0),
	N is  D/C-B/A,
	(Rest1 == 0 -> NewExpr = N*Var1;NewExpr = Rest1 + N*Var1).	

solve_eqs([]).
solve_eqs([Eqn|Rest]) :-
	solve_eqs(Rest),
	solve_eq(Eqn,N*X = M),
	(ground(X);X is M/N).
solve_eq(Expr + N*X = Val,Expr = NewVal) :- 
	ground(X),
	NewVal is Val-(N*X),!.
solve_eq(A=B, A=B).

get_coeff(Var1,N*Var2,N) :- (Var1 == Var2),!.
get_coeff(Var1,_ + N*Var2,N) :- (Var1 == Var2),!.
get_coeff(Var,Rest + _,N) :- get_coeff(Var,Rest,N).

normalise([],[],[]).
normalise([Expr = N |Rest],[NExpr = N|NRest],Uniqs) :-
	normalise(Rest,NRest,URest),
	normalise_eq(Expr,NExpr,Uniq),
	append(URest,Uniq,Uniqs1),
	sort(Uniqs1,Uniqs).



normalise_eq(Expr - Y,Expr1 + (-N*Y1),[Y1|L]) :- 	normalise_eq(Expr,Expr1,L),normalise_coeff(Y,N,Y1).
normalise_eq(Expr + Y,Expr1 + N*Y1,[Y1|L]) :- 		normalise_eq(Expr,Expr1,L),normalise_coeff(Y,N,Y1).
normalise_eq(Y,N*Y1,[Y1]) :- normalise_coeff(Y,N,Y1).
normalise_coeff(X*N,N,X) :- number(N).
normalise_coeff(N*X,N,X) :- number(N).
normalise_coeff(X,1,X).

%:-eliminate(X,[Y,Z],1*X + 2*Y + 2*Z, 2*X + 4*Y + 2*Z,G),nl,write(G),nl.
%:-eliminate_all(X,[Y,Z],1*X + 2*Y + 2*Z = 5, [2*X + 4*Y + 2*Z=2],G),nl,write(G),nl.

%:-System = 
%	[(-2)*X + 3*Y = 8,
%	 3*X + (-1)*Y = -5],
% gaussian_pass([X,Y],System),
% write(System),
% clean_eqs(System,System1),
% nl,
% write(System1),nl.


 :- System = 
	[3*Y = 6,
	 3*X + 3*Y = 9],
 	write(System),nl,
	gaussian([X,Y],System),
	write(System),nl,
	write(X),nl,write(Y),nl. 
