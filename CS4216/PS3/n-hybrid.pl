:-lib(suspend).
queers(QueerStruct,Number) :-
	dim(QueerStruct,[Number]),
	constraints(QueerStruct,Number),
	search(QueerStruct).
constraints(QueerStruct,Number) :-
	( for(I,1,Number),
		param(QueerStruct,Number)
		do
		QueerStruct[I] :: 1..Number,
		( for(J,1,I-1),param(I,QueerStruct) do
			QueerStruct[I] $\= QueerStruct[J]
		),
		(I > 1 ->
			QueerStruct[I] - QueerStruct[I-1] $> 2 or QueerStruct[I] - QueerStruct[I-1] $< -2;
			true
		),
		(I > 2 ->
			QueerStruct[I] - QueerStruct[I-2] $> 1 or QueerStruct[I] - QueerStruct[I-2] $< -1;
			true
		)

	).
search(QueerStruct) :-
	dim(QueerStruct,[N]),
	( foreacharg(Col,QueerStruct),
		param(N)
		do
		select_val(1,N,Col)
	).
select_val(1,N,Col) :-
	(
		fromto(
			fail,
			C,
			(C;(Col=I)),
			Q
		),
			for(I,1,N),param(Col) do
		   	true
	),Q.

