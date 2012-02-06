gaussian([],[]).
gaussian([Var],[0 + N*Var = Val]) :- Var is Val/N,!.
gaussian([Var|RestVar],[Eqn|RestEqn]) :-
	write('Eliminating '),write(Var),nl,
	eliminate_all(Var,RestVar,Eqn,RestEqn,Result),
	write(Result),nl,
	gaussian(RestVar,Result).

eliminate_all(_,_,_,[],[]).
eliminate_all(Var,RestVar,Expr1=Val1,[Expr2=Val2|Rest],[Expr2El=ValEl|Result]) :-
	eliminate_all(Var,RestVar,Expr1,Rest,Result),
	eliminate(Var,RestVar,Expr1,Expr2,Expr2El),
	get_coeff(Var,Expr1,A),
	get_coeff(Var,Expr2,B),
	ValEl is Val2/B - Val1/A.

eliminate(_,[],_,_,0).
eliminate(Var,[Var1|Rest],Expr1,Expr2,Rest1 + N*Var1) :-
	eliminate(Var,Rest,Expr1,Expr2,Rest1),
	get_coeff(Var,Expr1,A),
	get_coeff(Var1,Expr1,B),
	get_coeff(Var,Expr2,C),
	get_coeff(Var1,Expr2,D),
	N is  D/C-B/A.	


clean(Expr = Val, Expr1 = Val1) :-
	clean_expr(Expr,Expr1,Val2),
	Val1 is Val - Val2.


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
normalise_eq(Y,0+N*Y1,[Y1]) :- normalise_coeff(Y,N,Y1).
normalise_coeff(X*N,N,X) :- number(N).
normalise_coeff(N*X,N,X) :- number(N).
normalise_coeff(X,1,X).

:-eliminate(X,[Y,Z],1*X + 2*Y + 2*Z, 2*X + 4*Y + 2*Z,G),nl,write(G),nl.
:-eliminate_all(X,[Y,Z],1*X + 2*Y + 2*Z = 5, [2*X + 4*Y + 2*Z=2],G),nl,write(G),nl.
