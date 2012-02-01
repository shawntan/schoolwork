permute([],[]) :- !.
permute(L,[A|P]) :- not var(L),delete(A,L,B),permute(B,P).
permute(A,B) :- var(A), permute(B,A).



add(L1,L2,X) :- add(0,L1,L2,X).
add(0,[],[],[]) :-!.
add(1,[],[],[1]):-!.
add(C,[],L,X) :- add(C,[0],L,X),!.
add(C,L,[],X) :- add(C,[0],L,X),!.
add(C,[A|L1],[B|L2],[Le|X]) :-
	add_digit(A,B,C,Le,C1),add(C1,L1,L2,X).

add_digit(0,0,0,0,0).
add_digit(0,0,1,1,0).
add_digit(0,1,0,1,0).
add_digit(0,1,1,0,1).
add_digit(1,0,0,1,0).
add_digit(1,0,1,0,1).
add_digit(1,1,0,0,1).
add_digit(1,1,1,1,1).

decrement([1],[]) :- !.
decrement([1|L1],[0|L1]) :- !.
decrement([0|L1],[1|Res]) :- decrement(L1,Res).


multiply(M,[1],M) :-!.
multiply(M,N,S) :-	
	decrement(N,N1),
	multiply(M,N1,S1),
	add(S1,M,S).

:-op(700,xfx,is_bin).
is_bin(L,L) :- L = [_|_].
is_bin(X,B1 + B2) :- 
	is_bin(C1,B1),
	is_bin(C2,B2),
	add(C1,C2,X).
is_bin(X,B1 * B2) :-
	is_bin(C1,B1),
	is_bin(C2,B2),
	multiply(C1,C2,X).

