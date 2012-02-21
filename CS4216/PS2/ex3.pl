propagate(Cons,Doms,{NewDomains}):-
	arrayify(Cons,Constraints),
	arrayify(Doms,VarsDomains),
	var_dom(VarsDomains,Variables,Domains),
	domains(Variables,Domains,Constraints,NewDs),
	(
		fromto(	(Variables,NewDs,NewDomains),
				([V|RestVar],[D|RestDom],(V:D,RestDomains)),
				(RestVar,RestDom,RestDomains),
				([VLast],[DomLast],VLast:DomLast)) do true
	),!.

domains(Variables,Domains,Constraints,Ranges) :-
	findall(A,all_solns(Variables,Domains,Constraints,A),Solutions),
	(
		fromto(	(Solutions,Ranges),
				(Solns,[Range|RestRans]),
				(RestSolns,RestRans),
				([[]|_],[])
		) do minmax(Solns,Range),cutcolumn(Solns,RestSolns)
	).

all_solns(Variables,Domains,Constraints,A) :- 
	length(Domains,N),length(A,N),
	(
		fromto(	(Variables,Domains,A),
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

arrayify({G},Res) :-!, arrayify(G,Res).
arrayify((X,Y),[X|Rest]) :-!, arrayify(Y,Rest).
arrayify(Y,[Y]).

consec(N,N,[N]).
consec(N,M,[N|Rest]) :- N<M,N1 is N+1,consec(N1,M,Rest),!.

var_dom([],[],[]).
var_dom([Var:Start..End|Tail],[Var|VarRest],[Dom|DomRest]) :-
	consec(Start,End,Dom),
	var_dom(Tail,VarRest,DomRest).
