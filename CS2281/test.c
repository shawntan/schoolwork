#include <stdio.h>
int main() {
	int  a, b, c, d;
	scanf( "%d %d %d %d", &a, &b, &c, &d);
	if( a == b && a == c && a == d ) printf( "NIL\n" );
	else if( a < b  && (a >= c||c == b) && (a >= d||d == b) ) printf( "%d\n", a );
	else if( a < c  && (a >= b||b == c) && (a >= d||d == c) ) printf( "%d\n", a );
	else if( a < d  && (a >= b||b == d) && (a >= c||c == d) ) printf( "%d\n", a );
	else if( b < a  && (b >= c||c == a) && (b >= d||d == a) ) printf( "%d\n", b );
	else if( b < c  && (b >= a||a == c) && (b >= d||d == c) ) printf( "%d\n", b );
	else if( b < d  && (b >= a||a == d) && (b >= c||c == d) ) printf( "%d\n", b );
	else if( c < a  && (c >= b||b == a) && (c >= d||d == a) ) printf( "%d\n", c );
	else if( c < b  && (c >= a||a == b) && (c >= d||d == b) ) printf( "%d\n", c );
	else if( c < d  && (c >= a||a == d) && (c >= b||b == d) ) printf( "%d\n", c );
	else if( d < a  && (d >= b||b == a) && (d >= c||c == a) ) printf( "%d\n", d );
	else if( d < b  && (d >= a||a == b) && (d >= c||c == b) ) printf( "%d\n", d );
	else if( d < c  && (d >= a||a == c) && (d >= b||b == c) ) printf( "%d\n", d );
	return 0;
}
