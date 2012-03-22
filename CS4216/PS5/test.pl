gen_dom(D,N,M) :-
	L is M-N+1, length(D,L), ( foreach(E,D),count(I,N,M) do E = I ).

gen(L,D) :-
	foreach(E,L),param(D) do delete(E,D,_).

all_diff(L) :-
	fromto(L,[H|T],T,[]) do \+ member(H,T).

% 1 -> concert
% 2 -> cinema
% 3 -> theatre
% 4 -> exhibition

puzzle(A,B,C,D,E,P,O,S) :-
	gen_dom(DD,1,4), gen([A,B,C,D],DD), gen([E,P,O,S],DD),
	A = 1, B = O, C \= E, P = 2, E = 3,
	all_diff([A,B,C,D]), all_diff([E,P,O,S]).

occ(X,L,R) :- findall(X,member(X,L),Y),length(Y,R).

gen_smart(L,D) :-
	foreach(E,L),fromto(0,Cin,Cout,_),param(D)
	do member(E,D), Cout is Cin+E, Cout =< 10.

solve(L) :-
	length(L1,10),
	gen_dom(D,0,9),
	gen_smart(L1,D),reverse(L1,L),
	( foreach(E,L),count(I,0,9),param(L) do writeln(L),occ(I,L,E) ).
