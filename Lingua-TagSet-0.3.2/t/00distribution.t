#!/usr/bin/perl
# $Id: 00distribution.t,v 1.2 2005/05/09 13:59:36 rousse Exp $

use Test::More;

BEGIN {
    eval {
	require Test::Distribution;
    };
    if($@) {
	plan skip_all => 'Test::Distribution not installed';
    } else {
	import Test::Distribution
	    not          => 'versions',
	    podcoveropts => {
		trustme => [ qr/^(structure2tag|tag2structure)$/ ]
	    };
    }
}
