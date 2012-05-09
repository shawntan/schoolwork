
s(1,A,0,L) :- subscript(A,[1],f),subscript(A,[2],m),L = f.
s(1,A,1,L) :- L = m.
s(2,A,0,L) :- subscript(A,[1],m),subscript(A,[2],f),
	subscript(A,[3],m),s(3,A,1,L).
s(2,A,1,L) :- subscript(A,[3],f).
s(3,A,0,L) :- subscript(A,[1],m),subscript(A,[2],f),
	s(4,A,1,L).
s(3,A,1,L) :- s(4,A,0,L).
s(4,A,0,L) :- subscript(A,[3],f).
s(4,A,1,L) :- subscript(A,[3],L).

helper(A,L,B) :-
	dim(A,[3]),
	(foreach(D,B),count(C,1,4),param(A,L) do
		(D=0;D=1),s(C,A,D,L)
	).
