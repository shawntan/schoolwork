schedule(ProblemDescription,End,Joblist):-
	(fromto(
		(ProblemDescription,[]),
		(InTask,Scheduled),
		(OutTask,OutScheduled),
		([],Joblist)
	) do (
		delete(task(Name,Deps),InTask,OutTask),
		(foreach(Dep,Deps),param(Scheduled) do member(Dep,Scheduled)),
		append(Scheduled,[Name],OutScheduled)
	)).

