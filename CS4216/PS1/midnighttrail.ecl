solve(true, 0) :- !.
solve(A, 1) :- arithmetic(A), !, A.
solve((A, B), N) :- !, solve(A, N1), solve(B, N2),N is N1+N2.
solve(H, N) :- clause(H, Body), solve(Body, M),N is M+1.
arithmetic(_< _).
arithmetic(_=< _).
arithmetic(_=:= _).
arithmetic(_=\= _).
arithmetic(_>= _).
arithmetic(_> _).






