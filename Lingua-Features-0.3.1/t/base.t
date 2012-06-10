#!/usr/bin/perl
# $Id: base.t,v 1.4 2006/08/22 14:10:55 rousse Exp $

use Lingua::Features;
use Test::More tests => 4;
use strict;

isa_ok(
    Lingua::Features::FeatureType->type('noun'),
    'Lingua::Features::FeatureType'
);

isa_ok(
    Lingua::Features::StructureType->type('noun'),
    'Lingua::Features::StructureType'
);

ok(
    eq_array(
	[ Lingua::Features::StructureType->type('noun')->features() ],
	[ qw/type gender num sem case degree/ ]
    ),
    'features list'
);

ok(
    eq_set(
	[ Lingua::Features::FeatureType->type('noun')->values() ],
	[ qw/ord proper dist common/ ]
    ),
    'values set'
);
