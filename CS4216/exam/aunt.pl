% prime(Primes) :-
% 	Primes = [2, 3, 5, 7, 11, 13, 17, 
% 	          19, 23, 29, 31, 37, 41, 
% 	          43, 47, 53, 59, 61, 67, 
% 	          71, 73, 79].

% % List should be [X-[Primes], Y-[Primes]]
% search(List) :-
% 	(foreach(Var-Domain,List) do member(Var,Domain)).

% solve :-
% 	prime(Ages),
% 	search([B1-Ages,B2-Ages,B3-Ages,B1H-Ages,B2H-Ages,B3H-Ages]),
% 	B3-B1 < 10,
% 	B1H =:= B1-30,
% 	B2H =:= B2-30,
% 	B3H =:= B3-30,
% 	B1 < B2, B2 < B3,
% 	write('B1='), writeln(B1), 
%    	write('B2='), writeln(B2), 
%    	write('B3='), writeln(B3).

:- lib(ic).

prime(Primes) :-
	Primes = [2, 3, 5, 7, 11, 13, 17, 
	          19, 23, 29, 31, 37, 41, 
	          43, 47, 53, 59, 61, 67, 
	          71, 73, 79].


solve :-
	B3-B1 #< 10,
	B1H #= B1-30,
	B2H #= B2-30,
	B3H #= B3-30,
	B1N #= B1 + V,
	B2N #= B2 + V,
	B3N #= B3 + V,
	V #>= 1,
	B1N :: 1..79,
	B2N :: 1..79,
	B3N :: 1..79,
	prime(Primes),
	member(B1,Primes),
	member(B2,Primes),
	member(B3,Primes),
	member(B1H,Primes),
	member(B2H,Primes),
	member(B3H,Primes),
	member(B1N,Primes),
	member(B2N,Primes),
	member(B3N,Primes),
	alldifferent([B1,B2,B3]),
	labeling([B1,B2,B3]),
	write('B1='), writeln(B1), 
   	write('B2='), writeln(B2), 
   	write('B3='), writeln(B3),
	write('B1N='),writeln(B1N).

:- solve.
:- halt.
