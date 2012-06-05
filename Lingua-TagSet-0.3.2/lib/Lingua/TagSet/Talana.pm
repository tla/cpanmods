# $Id: Talana.pm,v 1.7 2006/08/22 14:21:55 rousse Exp $
package Lingua::TagSet::Talana;

=head1 NAME

Lingua::TagSet::Talana - Talana tagset for Lingua::TagSet

=cut

use base qw/Lingua::TagSet/;
use strict;

our @id_maps = (
    {
        features => { cat => 'adj' },
        tokens   => [ 'A', undef, undef, undef ],
        submap   => [
            1 => 'type',
            2 => 'gender',
            3 => 'num'
        ]
    },
    {
        features => { cat => 'adv' },
        tokens   => [ 'ADV' ]
    },
    {
        features => { cat => 'pron', type => 'cli' },
        tokens   => [ 'CL', undef, undef, undef, undef ],
        submap   => [
            1 => 'case',
            2 => 'pers',
            3 => 'gender',
            4 => 'num'
        ]
    },
    {
        features => { cat => 'conj', type => 'co' },
        tokens   => [ 'C', 'C' ]
    },
    { 
        features => { cat => 'conj', type => 'sub' },
        tokens   => [ 'C', 'S' ]
    },
    {
        features => { cat => 'det' },
        tokens   => [ 'D', undef, undef, undef ],
        submap   => [
            1 => 'type',
            2 => 'gender',
            3 => 'num'
        ]
    },
    {
        features => { cat => 'det', type => 'art', def => 'def' },
        tokens   => [ 'D', 'def', undef, undef ],
        submap   => [
            2 => 'gender',
            3 => 'num'
        ]
    },
    {
        features => { cat => 'det', type => 'art', def => 'ind' },
        tokens   => [ 'D', 'ind', undef, undef ],
        submap   => [
            2 => 'gender',
            3 => 'num'
        ]
    },
    {
        features => { cat => 'det', type => 'poss' },
        tokens   => [ 'D', 'poss', undef, undef, undef, undef ],
        submap   => [
            2 => 'pers',
            3 => 'gender',
            4 => 'num',
            5 => 'numposs'
        ]
    },
    {
        features => { cat => 'noun' },
        tokens   => [ 'N', undef, undef, undef ],
        submap   => [
            1 => 'type',
            2 => 'gender',
            3 => 'num'
        ]
    },
    {
        features => { cat => 'verb' },
        tokens   => [ 'V', undef, undef, undef, undef ],
        submap   => [
            2 => 'mode',
            2 => 'tense',
            3 => 'pers',
            4 => 'num'
        ]
    },
    {
        features => { cat => 'verb', mode => 'part', tense => 'past' },
        tokens   => [ 'V', undef, 'K', undef, undef ],
        submap   => [
            3 => 'gender',
            4 => 'num'
        ]
    },
    {
        features => { cat => 'verb', mode => 'part', tense => 'pres' },
        tokens   => [ 'V', undef, 'G', undef, undef ],
        submap   => [
            3 => 'gender',
            4 => 'num'
        ]
    },
    {
        features => { cat => 'verb', mode => 'inf' },
        tokens   => [ 'V', undef, 'W' ],
    },
    {
        features => { cat => 'pron' },
        tokens   => [ 'PRO', undef, undef, undef, undef ],
        submap   => [
            1 => 'type',
            2 => 'pers',
            3 => 'gender',
            4 => 'num'
        ]
    },
    {
        features => { cat => 'pron', type => 'poss' },
        tokens   => [ 'PRO', 'poss', undef, undef, undef, undef ],
        submap   => [
            2 => 'pers',
            3 => 'gender',
            4 => 'num',
            5 => 'numposs'
        ]
    },
    {
        features => { cat => 'punct' },
        tokens   => [ 'PONCT' ],
    },
    {
        features => { cat => 'interj' },
        tokens   => [ 'I' ],
    },
    {
        features => { cat => 'prep' },
        tokens   => [ 'P' ],
    },
    {
        features => { cat => 'x' },
        tokens   => [ 'ET' ],
    },
    {
        features => { cat => 'pref' },
        tokens   => [ 'PREF' ],
    },
);

our %value_maps = (
    det => [
        dem  => 'dem',
        ind  => 'ind',
        poss => 'poss',
        int  => 'int',
        excl => 'excl',
        part => 'part',
        def  => 'def',
        card => 'card',
    ],
    adj => [
        qual => 'qual',
        ord  => 'ord',
        ind  => 'ind',
        int  => 'int',
        card => 'card',
    ],
    noun => [ 
        C    => 'common',
        P    => 'proper',
        card => 'ord',
    ],
    pron => [
        dem  => 'dem',
        rel  => 'rel',
        ind  => 'ind',
        poss => 'poss',
        int  => 'int',
    ],
    mode => [ 
        C => 'cond',
        I => 'ind',
        F => 'ind',
        G => 'part',
        J => 'ind',
        K => 'part',
        P => 'ind',
        S => 'subj',
        T => 'subj',
        Y => 'imp',
    ],
    tense => [ 
        C => 'pres',
        I => 'imp',
        F => 'fut',
        G => 'pres',
        J => 'past',
        K => 'past',
        P => 'pres',
        S => 'pres',
        T => 'imp',
        Y => 'pres',
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
        obj  => 'dat',
        obj  => 'gen',
        obj  => 'obl',
        obj  => 'acc',
        refl => 'ref',
        suj  => 'nom',
    ]
);

__PACKAGE__->_init();

sub tag2structure {
    my ($class, $tag_string) = @_;

    # fail fast
    return unless $tag_string;

    # split tag in tokens
    my @tokens = split(/-/, $tag_string, 3);
    $#tokens = 2 if $#tokens < 2;
    push(@tokens, split(//, pop(@tokens))) if $tokens[-1];

    # convert special values
    @tokens = map {
        $_ ? [ $_ ] : $_
    } @tokens;

    my $tag = Lingua::TagSet::Tag->new(@tokens);

    # call generic routine
    return $class->SUPER::tag2structure($tag, no_strict_align => 1);
}

sub structure2tag {
    my ($class, $structure) = @_;

    # call generic routine
    my $tag = $class->SUPER::structure2tag($structure);
    my @tokens = $tag->get_tokens();

    # force minimum length
    $#tokens = 2 if $#tokens < 2;

    # handle special cases
    @tokens = map {
        $_ ?       # known value
            $#$_ ? # multiple values
                join('', @$_) :
                $_->[0]
            : ''
    } @tokens;

    # join tokens in tag
    my $tag_string = join('-', $tokens[0], $tokens[1], join('', @tokens[2 .. $#tokens]));

    return $tag_string;
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004-2006, INRIA.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 AUTHOR

Guillaume Rousse <grousse@cpan.org>

=cut

1;
