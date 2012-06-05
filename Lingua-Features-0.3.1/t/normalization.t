#!/usr/bin/perl
# $Id: normalization.t,v 1.2 2006/08/22 14:09:23 rousse Exp $

use Lingua::Features;
use Test::More tests => 7;
use strict;

my $string1 = 'cat@noun type@proper gender@masc num@sing';
my $string2 = 'cat@noun type@proper';
my $string3 = 'cat@pron case@acc|dat|gen|obl';

is(
        Lingua::Features::Structure->new(
	    cat    => 'noun',
	    type   => 'proper',
	    gender => 'masc',
	    num    => 'sing'
	)->to_string(),
        $string1,
        "basic creation"
);

is(
        Lingua::Features::Structure->new(
	    type   => 'proper',
	    gender => 'masc',
	    num    => 'sing',
	    cat    => 'noun'
	)->to_string(),
        $string1,
        "features ordering"
);

is(
        Lingua::Features::Structure->new(
	    cat    => [ 'noun' ],
	    type   => [ 'proper' ],
	    gender => [ 'masc' ],
	    num    => [ 'sing' ]
	)->to_string(),
        $string1,
        "values list"
);

is(
        Lingua::Features::Structure->new(
	    cat    => [ 'noun', 'noun' ],
	    type   => [ 'proper', 'proper'  ],
	    gender => [ 'masc', 'masc' ],
	    num    => [ 'sing', 'sing' ]
	)->to_string(),
        $string1,
        "multiple identical values"
);

is(
        Lingua::Features::Structure->new(
	    cat    => [ 'noun', 'foo' ],
	    type   => [ 'bar', 'proper'  ],
	    gender => [ 'masc', 'foo' ],
	    num    => [ 'bar', 'sing' ]
	)->to_string(),
        $string1,
        "unauthorized values"
);

is(
        Lingua::Features::Structure->new(
	    cat    => 'noun',
	    type   => 'proper',
	    gender => [ 'masc', 'fem' ],
	    num    => [  'sing', 'pl' ]
	)->to_string(),
        $string2,
        "all type values"
);

is(
        Lingua::Features::Structure->new(
	    cat  => 'pron',
	    case => [ 'gen', 'acc', 'obl', 'dat' ]
	)->to_string(),
        $string3,
        "values ordering"
);
