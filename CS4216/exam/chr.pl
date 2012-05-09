:- use_module(library(chr)).
:- chr_constraint subseq/2, append/3, intersect/3.
subseq(X,Y),subseq(Y,Z) ==> subseq(X,Z).
subseq(X,Y) <=> append(_,X,L),append(L,_,Y).
intersect(X,Y,Z) <=> subseq(Z,X),subseq(Z,Y).
append(X,Y,Y) <=> X==[] | true.
append([H|T],Y,[H|Z]) <=> ground(H) | append(T,Y,Z).
append(X,A,Y),append(Y,B,X) <=> (A \= []; B \= []) | fail.
append(X,A,Y),append(B,Y,X) <=> (A \= []; B \= []) | fail.
append(B,A,Y),append(A,B,Y) <=> (A \= []; B \= []; A \= B) | fail.

append(X,Y,L)\append(X,W,L) <=> Y=W.
append(X,Y,L)\append(W,Y,L) <=> X=W.
append(X,Y,L)\append(X,Y,W) <=> L=W.
