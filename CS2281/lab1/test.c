#include <stdio.h>
Z(a,b) { return a>=b?a:b;}
Y(a,b) { return a<=b?a:b;}
int N,n,S,A=(1<<31);
int W(int a,int b) {return Z(a,b)==N?(a==b?A:Y(a,b)):Z(a,b);}
main() {
	int  a, b, c, d, e, f;
	scanf( "%d %d %d %d %d %d", &a, &b, &c, &d, &e, &f);
	N = Z(Z(Z(Z(Z(a,b),c),d),e),f);
	n = Y(Y(Y(Y(Y(a,b),c),d),e),f);
	S = W(W(W(W(W(a,b),c),d),e),f);
	S==A?printf("NIL\n"):printf("%d\n",S);
	printf("%u\n",N-n);
}
