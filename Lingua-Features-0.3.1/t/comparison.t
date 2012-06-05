#!/usr/bin/perl
# $Id: comparison.t,v 1.2 2006/08/22 14:10:14 rousse Exp $

use Lingua::Features;
use Test::More tests => 8;
use strict;

my $struc1 = Lingua::Features::Structure->from_string('cat@noun type@proper gender@masc num@sing');
my $struc2 = Lingua::Features::Structure->from_string('cat@noun type@proper');
my $struc3 = Lingua::Features::Structure->from_string('cat@noun type@proper gender@fem num@pl');
my $struc4 = Lingua::Features::Structure->from_string('cat@noun type@common gender@fem num@pl');

ok(
    $struc2->is_subset($struc1),
    'cat@noun type@proper subset of cat@noun type@proper gender@masc num@sing'
);

ok(
    ! $struc1->is_subset($struc2),
    'cat@noun type@proper gender@masc num@sing not subset of cat@noun type@proper'
);

ok(
    $struc2->is_compatible($struc1),
    'cat@noun type@proper compatible with cat@noun type@proper gender@masc num@sing'
);

ok(
    $struc1->is_compatible($struc2),
    'cat@noun type@proper gender@masc num@sing compatible with cat@noun type@proper'
);

is(
    Lingua::Features::Structure->union($struc1, $struc3)->to_string(),
    'cat@noun type@proper gender@fem|masc',
    'union'
);

is(
    Lingua::Features::Structure->intersection($struc1, $struc3)->to_string(),
    'cat@noun type@proper',
    'intersection'
);

is(
    Lingua::Features::Structure->union($struc1, $struc4)->to_string(),
    'cat@noun type@common|proper gender@fem|masc',
    'union'
);

is(
    Lingua::Features::Structure->intersection($struc1, $struc4)->to_string(),
    'cat@noun',
    'intersection'
);
