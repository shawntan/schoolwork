power(0,[]) :- !.
power(N,[1|T]) :- M is N-1,power(M,T).
power(N,[0|T]) :- M is N-1,power(M,T).

