

all_perms(A) :- 
	Domain = [
		[1,2,3,4,5],
		[4,5,6,7],
		[0,1,2,3,4,5,6]
	],
	length(Domain,N),length(A,N),
	(
		fromto(	(Domain,A),
	   			([D|RestD],[E|RestA]),
				(RestD,RestA),
			   	([],[])	
		) do member(E,D)
	).
