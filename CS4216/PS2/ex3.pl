domains(Ranges) :- 
	findall(A,all_solns(A),Solutions),
	(
		fromto(	(Solutions,Ranges),
				(Solns,[Range|RestRans]),
				(RestSolns,RestRans),
				([[]|_],[])
		) do minmax(Solns,Range),cutcolumn(Solns,RestSolns)
	).

all_solns(A) :- 
	Variables = [X,Y,Z],
	Domain = [
		[1,2,3,4,5],
		[4,5,6,7],
		[0,1,2,3,4,5,6]
	],
	Constraints = [
		X < Y,
		Y < Z,
		X + Y =:= Z
	],
	length(Domain,N),length(A,N),
	(
		fromto(	(Variables,Domain,A),
	   			([X|RestV],[D|RestD],[E|RestA]),
				(RestV,RestD,RestA),
			   	([],[],[])	
		) do member(E,D), X is E
	),(
		foreach(Con,Constraints) do Con
	).


minmax(List,(Min..Max)) :-
	findall(A,member([A|_],List),D),
	min(D,Min),
	max(D,Max).

cutcolumn(List,Result) :-
	fromto(	(List,Result),
			([[_|RestVals]|RestList],[RestVals|RestResult]),
			(RestList,RestResult),
			([],[])) do true.

