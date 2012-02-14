:- lib(hash). % query "help hash." to find contents of library
:- local op(948,fx,print).
:- local op(1099,xf,;).
:- local op(950,fxx,if).
:- local op(951,fxx,while).
:- local op(949,xfx,else).

% Expression evaluator
eval(X,SymTab,Result) :- atom(X), !, hash_get(SymTab,X,Result).
eval(X,_,X) :- number(X), !.
eval(X+Y,SymTab,Result) :- !,
  eval(X,SymTab,Rx), eval(Y,SymTab,Ry), Result is Rx+Ry.
eval(X-Y,SymTab,Result) :- !,
  eval(X,SymTab,Rx), eval(Y,SymTab,Ry), Result is Rx-Ry.
eval(X*Y,SymTab,Result) :- !,
  eval(X,SymTab,Rx), eval(Y,SymTab,Ry), Result is Rx*Ry.
eval(X/Y,SymTab,Result) :- !,
  eval(X,SymTab,Rx), eval(Y,SymTab,Ry), Result is Rx/Ry.
eval(X==Y,SymTab,Rx==Ry) :- !,eval(X,SymTab,Rx), eval(Y,SymTab,Ry).
eval(X>Y,SymTab,Rx>Ry) :-   !,eval(X,SymTab,Rx), eval(Y,SymTab,Ry).
eval(X<Y,SymTab,Rx<Ry) :-   !,eval(X,SymTab,Rx), eval(Y,SymTab,Ry).
eval(X=<Y,SymTab,Rx=<Ry) :- !,eval(X,SymTab,Rx), eval(Y,SymTab,Ry).
eval(X>=Y,SymTab,Rx>=Ry) :- !,eval(X,SymTab,Rx), eval(Y,SymTab,Ry).

% Execution engine
execp((X = E), SymTab) :- !, 
  atom(X), eval(E,SymTab,Result), hash_set(SymTab,X,Result).
execp((print X), SymTab) :- !, 
  (  atom(X), not hash_contains(SymTab,X) 
  -> write(X) 
  ;  eval(X,SymTab,Result), write(Result) ).
execp( nl, _ ) :- !, nl.
execp( (if Cond Conseq else Alternative), SymTab ) :- !, 
  eval(Cond,SymTab,B),
  (   B \= 0 
  ->  execp(Conseq,SymTab) 
  ;   execp(Alternative,SymTab) ).
execp( (if Cond Conseq ), SymTab ) :- !, 
  eval(Cond,SymTab,B), 
  (   B \= 0 
  ->  execp(Conseq,SymTab) 
  ;   true ).

execp( (while Cond Conseq ), SymTab ) :- !, 
  eval(Cond,SymTab,B), 
  (   B \= 0 
  ->  execp(Conseq,SymTab),execp((while Cond Conseq), SymTab)
  ;   true ).

execp( ( Stmt1 ; Stmt2 ), SymTab ) :- !, 
  execp(Stmt1,SymTab), execp(Stmt2,SymTab).
execp( { Stmt ; }, SymTab ) :- !, execp(Stmt,SymTab).
execp( { Stmt }, SymTab ) :- !, execp(Stmt,SymTab).
execp( (Stmt ;), SymTab ) :- execp(Stmt,SymTab).


% Sample query for interpreter
%    will print "z=3\ndone\n"
:- Program = (
	x = 10;
	while (x) {
		print x;
		nl;
		x = x - 1;
	}
%     x = 10 ;
%     y = -10 ;
%     if (x * y) {
%       z = 2 ;
%       z = z + 1 ;
%     } else {
%       z = 100 ;
%       z = z + x ;
%     } ;
%     print 'z=' ;
%     print z  ;
%     nl ;
%     print done ;
%     nl ;
   ), hash_create(SymTab), execp(Program,SymTab).
