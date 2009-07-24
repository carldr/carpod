//
//  main.c
//  carpod
//
//  Created by Carl Drinkwater on 24/07/2009.
//  Copyright 2009 Carl Drinkwater. All rights reserved.
//

#include <stdio.h>
#include "carpod.h"

int main(int argc, const char * argv[]) {
	if ( argc != 2 ) {
		printf( "You need to supply a last.fm username (and only a last.fm username) as an argument.\n" );
		return 1;
	}
	
	return run( argv[1] );
}
