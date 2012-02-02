#include <stdio.h>
Z(a,b) { return a>=b?a:b;}
Y(a,b) { return a<=b?a:b;}
int N,n,S,A=(1<<31);
int W(int a,int b) {return Z(a,b)==N?(Y(a,b)==N?A:Y(a,b)):Z(a,b);}
main() {
	int  a, b, c, d;
	scanf( "%d %d %d %d", &a, &b, &c, &d);
	N = Z(Z(Z(a,b),c),d);
	n = Y(Y(Y(a,b),c),d);
	S = W(W(W(a,b),c),d);
	S==A?printf("NIL\n"):printf("%d\n",S);	printf("%u\n",N-n);
}
