#include <stdio.h>
int main() {
	int  a, b, c, d;
	scanf( "%d %d %d %d", &a, &b, &c, &d);
	if( a == b && a == c && a == d ) printf( "NIL\n" );
	if( a < b  && a >= c && a >= d ) printf( "%d\n", a );
	if( a < c  && a >= b && a >= d ) printf( "%d\n", a );
	if( a < d  && a >= b && a >= c ) printf( "%d\n", a );
	if( b < a  && b >= c && b >= d ) printf( "%d\n", b );
	if( b < c  && b >= a && b >= d ) printf( "%d\n", b );
	if( b < d  && b >= a && b >= c ) printf( "%d\n", b );
	if( c < a  && c >= b && c >= d ) printf( "%d\n", c );
	if( c < b  && c >= a && c >= d ) printf( "%d\n", c );
	if( c < d  && c >= a && c >= b ) printf( "%d\n", c );
	if( d < a  && d >= b && d >= c ) printf( "%d\n", d );
	if( d < b  && d >= a && d >= c ) printf( "%d\n", d );
	if( d < c  && d >= a && d >= b ) printf( "%d\n", d );
	return 0;
}
