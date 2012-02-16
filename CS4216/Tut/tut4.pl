:- lib(suspend).

r(1,A,1) :- member(X,[1,3,5,7,9]),subscript(A,[X],lady).
r(1,A,0) :- member(X,[2,4,6,8]),subscript(A,[X],lady).
r(2,A,1) :- subscript(A,[2],empty).
r(2,A,0) :- subscript(A,[2],X),X\=empty.
r(3,A,1) :- r(5,A,1),r(7,A,1);r(5,A,0),r(7,A,0).
r(3,A,0) :- r(5,A,1),r(7,A,0);r(5,A,0),r(7,A,1).
r(4,A,1) :- r(1,A,0).
r(4,A,0) :- r(1,A,1).
r(5,A,1) :- r(2,A,1),r(4,A,0);r(4,A,1),r(2,A,0).
r(5,A,0) :- r(2,A,1),r(4,A,1);r(4,A,1),r(2,A,1).
r(6,A,1) :- r(3,A,0).
r(6,A,0) :- r(3,A,1).
r(7,A,1) :- subscript(A,[1],X),X \= lady.
r(7,A,0) :- subscript(A,[1],X),X = lady.
r(8,A,1) :- subscript(A,[8],tiger),subscript(A,[9],empty).
r(8,A,0) :- (subscript(A,[8],X);subscript(A,[9],Y)),X\=tiger,Y\=empty.
r(9,A,1) :- subscript(A,[9],tiger),r(6,A,0).
r(9,A,1) :- (subscript(A,[9],X),X\=tiger);r(6,A,1).


helper(A) :-
	(count(I,1,9),param(A) do
		subscript(A,[I],X),
		(
			X = lady,r(I,A,1);
			X = tiger,r(I,A,0);
			X = empty
		)
	),
	(fromto((0,1),(Cin,Iin),(Cout,Iout),(C,9)),param(A) do
		(subscript(A,[Iin],X),
			( X = lady ->
				B = 1;
				B = 0
			),
			Cout is Cin + B,Iout is Iin + 1
		)
	),C=1.


