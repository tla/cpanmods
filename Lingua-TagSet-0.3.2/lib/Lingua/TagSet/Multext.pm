# $Id: Multext.pm,v 1.7 2006/08/22 14:21:55 rousse Exp $
package Lingua::TagSet::Multext;

=head1 NAME

Lingua::TagSet::Multext - Multext tagset for Lingua::TagSet

=cut

use base qw/Lingua::TagSet/;
use strict;
use warnings;

our @id_maps = (
    {
        features => { cat => 'noun' },
        tokens   => [ 'X' ]
    },
    {
        features => { cat => 'noun' },
        tokens   => [ 'N', undef, undef, undef, undef, undef ],
        submap   => [
            1 => 'type',
            2 => 'gender',
            3 => 'num',
            5 => 'sem'
        ]
    },
    {
        features => { cat => 'verb' },
        tokens   => [ 'V', undef, undef, undef, undef, undef, undef, undef ],
        submap   => [ 
            1 => 'type',
            2 => 'mode',
            3 => 'tense',
            4 => 'pers',
            5 => 'num',
            6 => 'gender'
        ]
    },
    {
        features => { cat => [ 'det', 'adj', 'pron' ] },
        tokens   => [ 'M', 'c', undef, undef, undef ],
        submap   => [
            2 => 'gender',
            3 => 'num'
        ]
    },
    {
        features => { cat => 'adj' },
        tokens   => [ 'A', undef, undef, undef, undef, undef ],
        submap   => [
            1 => 'type',
            2 => 'degree',
            3 => 'gender',
            4 => 'num'
        ]
    },
    {
        features => { cat => 'det' },
        tokens   => [ 'D', undef, undef, undef, undef, undef, undef, undef, undef ],
        submap   => [
            1 => 'type',
            2 => 'pers',
            3 => 'gender',
            4 => 'num',
            6 => 'numposs',
            7 => 'def'
        ]
    },
    {
        features => { cat => 'pron' },
        tokens   => [ 'P', undef, undef, undef, undef, undef, undef ],
        submap   => [ 
            1 => 'type',
            2 => 'pers',
            3 => 'gender',
            4 => 'num',
            5 => 'case',
            6 => 'numposs'
        ]
    },
    {
        features => { cat => 'advneg' },
        tokens   => [ 'R', undef, [ 'n', 'd' ] ],
    },
    {
        features => { cat => 'adv' },
        tokens   => [ 'R' ],
    },
    {
        features => { cat => 'prep' },
        tokens   => [ 'S', 'p' ]
    },
    {
        features => { cat => 'cc' },
        tokens   => [ 'C', 'c' ]
    },
    { 
        features => { cat => 'cs' },
        tokens   => [ 'C', 's' ]
    },
    { 
        features => { cat => 'interj' },
        tokens   => [ 'I' ],
    },
    {
        features => { cat => 'ponct' },
        tokens   => [ 'F' ],
    },
);

our %value_maps = (
    det => [
        a => 'art',
        d => 'dem',
        i => 'ind',
        s => 'poss',
        t => 'int',
        t => 'excl'
    ],
    adj  => [ 
        f => 'qual',
        o => 'ord',
        i => 'ind',
        s => 'poss'
    ],
    noun => [ 
        f => 'qual',
        o => 'ord',
        i => 'ind',
        c => 'common',
        p => 'proper',
        d => 'dist'
    ],
    pron => [
        p => 'pers',
        d => 'dem',
        r => 'rel',
        x => 'cli',
        i => 'ind',
        s => 'poss',
        t => 'int'
    ],
    verb => [
        a => 'avoir',
        e => 'etre',
        m => 'main'
    ],
    mode => [ 
        i => 'ind',
        s => 'subj',
        m => 'imp',
        c => 'cond',
        n => 'inf',
        p => 'part',
    ],
    tense => [ 
        p => 'pres',
        i => 'imp',
        f => 'fut',
        s => 'past',
    ],
    pers => [
        1 => '1',
        2 => '2',
        3 => '3',
    ],
    gender => [
        m => 'masc',
        f => 'fem',
    ],
    num => [
        p => 'pl',
        s => 'sing',
    ],
    case => [ 
        j => 'acc',
        j => 'dat',
        n => 'nom',
        o => 'obl',
    ],
    degree => [
        p => 'pos',
        c => 'comp',
    ],
    res => [
        u => 'unit',
        e => 'exp',
        f => 'foreign',
    ],
    sem => [
        c => 'pl',
        h => 'inh',
        s => 'ent',
    ],
    def => [
        d => 'def',
        i => 'ind',
    ]
);

__PACKAGE__->_init();

sub tag2structure {
    my ($class, $tag_string) = @_;

    # fail fast
    return unless $tag_string;

    # split tag in tokens
#    my @tokens = split(//, $tag_string);
    my @tokens = ($tag_string =~ /(.(?:\|.)*)/og);

    # convert special values
    @tokens = map {
        $_ eq '-' ? undef 
        : [ split('|',$_) ]
    } @tokens;

    my $tag = Lingua::TagSet::Tag->new(@tokens);

    # call generic routine
    return $class->SUPER::tag2structure($tag);
}

sub structure2tag {
    my ($class, $structure) = @_;

    # call generic routine
    my $tag    = $class->SUPER::structure2tag($structure);
    my @tokens = $tag->get_tokens();

    # convert special values
    @tokens = map {
        $_ ?       # known value
            $#$_ ? # multiple values
                '[' . join('', @$_) . ']' :
                $_->[0]
            : '-'
    } @tokens;

    # join tokens in tag
    my $tag_string = join('', @tokens);

    return $tag_string;
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004-2006, INRIA.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 AUTHOR

Guillaume Rousse <grousse@cpan.org>

=cut

1;
