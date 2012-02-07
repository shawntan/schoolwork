lin_eq(Eqns) :-
	normalise(Eqns,NEqns,Vars),
	norm(Vars,NEqns,NNEqns),!,
	gaussian(Vars,NNEqns).


gaussian([_],[Expr]) :- solve_x(Expr).
gaussian([Var|Vars],Eqns):-
	delete(Expr = Val,Eqns,RestEqns), get_coeff(Var,Expr,N),N\=0,!,
	eliminate_all(Var,Vars,Expr=Val,RestEqns,ResEqns),
	gaussian(Vars,ResEqns),
	solve_x(Expr=Val).

solve_x(N*X = Val):-X is Val/N.
solve_x(M + N*X = Val) :-ground(M),M1 is M,X is (Val-M1)/N.

eliminate_all(Var,Vars,Expr1 = Val1,[Expr2 = Val2],[NewExpr = NewVal]) :-
	pairwise(Var,Vars,Expr1,Expr2,NewExpr),
	cancel_terms(Var,Expr1 = Val1,Expr2 = Val2,NewVal).
eliminate_all(Var,Vars,Expr1 = Val1,[Expr2 = Val2|RestEqn],[NewExpr = NewVal|NewRestEqn]) :-
	pairwise(Var,Vars,Expr1,Expr2,NewExpr),
	eliminate_all(Var,Vars,Expr1 = Val1,RestEqn,NewRestEqn),
	cancel_terms(Var,Expr1 = Val1,Expr2 = Val2,NewVal).


pairwise(Var,[V1],Expr1,Expr2,N*V1):-
	cancel_terms(Var,V1,Expr1,Expr2,N).
pairwise(Var,[V1|Vars],Expr1,Expr2,NewExpr+N*V1) :-
	pairwise(Var,Vars,Expr1,Expr2,NewExpr),
	cancel_terms(Var,V1,Expr1,Expr2,N).


cancel_terms(Var,V1,Expr1,Expr2,N) :-
	get_coeff(Var,Expr2,A2),
	get_coeff(V1,Expr2,N2),
	(A2 \= 0 -> 
		(get_coeff(Var,Expr1,A1),
		get_coeff(V1,Expr1,N1),
		Norm1 is N1/A1,
		Norm2 is N2/A2,
		N is Norm2 - Norm1);
		N is N2
	).
	
cancel_terms(Var,Expr1 = Val1,Expr2 = Val2,N) :-
	get_coeff(Var,Expr2,A2),
	(A2 \= 0 ->
		(get_coeff(Var,Expr1,A1),N is Val2/A2 - Val1/A1);
		N is Val2
	).


norm(_,[],[]):-!.
norm(Vars,[Expr = Val|Rest],[NewExpr = Val|NewRest]) :-
	norm(Vars,Rest,NewRest),
	rebuild_eq(Vars,Expr,NewExpr).

rebuild_eq([Var],Expr,N*Var) :- get_coeff(Var,Expr,N).
rebuild_eq([Var|Rest],Expr,NewExpr + N*Var) :-
	get_coeff(Var,Expr,N),
	rebuild_eq(Rest,Expr,NewExpr).
	
get_coeff(Var1,N*Var2,N) :- (Var1 == Var2),!.
get_coeff(Var1,_ + N*Var2,N) :- (Var1 == Var2),!.
get_coeff(Var,Rest + _,N) :- get_coeff(Var,Rest,N),!.
get_coeff(_,_,0).

normalise([],[],[]).
normalise([Expr = N |Rest],[NExpr = N|NRest],Uniqs) :-
	normalise(Rest,NRest,URest),
	normalise_eq(Expr,NExpr,Uniq),
	append(URest,Uniq,Uniqs1),
	sort(Uniqs1,Uniqs).

normalise_eq(Y,N*Y1,[Y1]) :- normalise_coeff(Y,N,Y1).
normalise_eq(Expr - Y,Expr1 + K*Y1,[Y1|L]) :- 	normalise_eq(Expr,Expr1,L),normalise_coeff(Y,N,Y1), K is -N.
normalise_eq(Expr + Y,Expr1 + N*Y1,[Y1|L]) :- 		normalise_eq(Expr,Expr1,L),normalise_coeff(Y,N,Y1).
normalise_coeff(X,1,X) :- var(X).
normalise_coeff(-X,-1,X) :- var(X).
normalise_coeff(X*N,N,X) :- number(N).
normalise_coeff(N*X,N,X) :- number(N).

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

:- lin_eq([
		X + 2*Y + 3*Z = 8,
		  Y  + X   = 3,
		X - 3*Y + 5*Z = 0]),
write(X),nl,
write(Y),nl,
write(Z),nl.
% :- System = 
%	[3*Y = 6,
%	 3*Y + 3*X = 9],
% 	write(System),nl,
%	gaussian(System),
%	write(System),nl,
%	write(X),nl,write(Y),nl. 
