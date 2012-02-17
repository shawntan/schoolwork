

all_perms(A) :- 
	Variables = [X,Y,Z],
	Domain = [
		[1,2,3,4,5],
		[4,5,6,7],
		[0,1,2,3,4,5,6]
	],
	Constraints = [
		X < Y,
		Y < Z
	],
	length(Domain,N),length(A,N),
	(
		fromto(	(Variables,Domain,A),
	   			([X|RestV],[D|RestD],[E|RestA]),
				(RestV,RestD,RestA),
			   	([],[],[])	
		) do member(E,D), X is E
	),
	(
		foreach(Con,Constraints) do Con
	),
	.
