#include <stdio.h>
#include <limits.h>
int main() {
	int  a, b, c;
	scanf( "%d %d %d", &a, &b, &c);
	if( a == b && a == c ) printf( "NIL\n" );
	if( a < b  && a >= c ) printf( "%d\n", a );
	if( a < c  && a >= b ) printf( "%d\n", a );
	if( b < a  && b >= c ) printf( "%d\n", b );
	if( b < c  && b >= a ) printf( "%d\n", b );
	if( c < a  && c >= b ) printf( "%d\n", c );
	if( c < b  && c >= a ) printf( "%d\n", c );

	int max, min;
	if( a > b && a > c ) max = a;
	if( b > a && b > c ) max = b;
	if( c > a && c > b ) max = c;
	if( a <= b && a <= c ) min = a;
	if( b <= a && b <= c ) min = b;
	if( c <= a && c <= b ) min = c;
	printf("%u\n",max - min);
	return 0;
}
