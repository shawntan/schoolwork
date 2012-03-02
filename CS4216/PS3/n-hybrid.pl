:-lib(suspend).
queens(QueenStruct,Number) :-
	dim(QueenStruct,[Number]),
	constraints(QueenStruct,Number),
	search(QueenStruct).
constraints(QueenStruct,Number) :-
	( for(I,1,Number),
		param(QueenStruct,Number)
		do
		QueenStruct[I] :: 1..Number,
		( for(J,1,I-1),param(I,QueenStruct) do
			QueenStruct[I] $\= QueenStruct[J]
		),
		(I > 1 ->
			QueenStruct[I] - QueenStruct[I-1] $> 2 or QueenStruct[I] - QueenStruct[I-1] $< -2;
			true
		),
		(I > 2 ->
			QueenStruct[I] - QueenStruct[I-2] $> 1 or QueenStruct[I] - QueenStruct[I-2] $< -1;
			true
		)

	).
search(QueenStruct) :-
	dim(QueenStruct,[N]),
	( foreacharg(Col,QueenStruct),
		param(N)
		do
		select_val(1,N,Col)
	).
select_val(1,N,Col) :-
	(fromto(fail,C,(C;(Col=I)),Q),for(I,1,N),param(Col) do true),Q.

