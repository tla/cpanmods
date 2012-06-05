# $Id: Acabit.pm,v 1.4 2006/08/22 14:21:55 rousse Exp $
package Lingua::TagSet::Acabit;

=head1 NAME

Lingua::TagSet::Acabit - Acabit tagset for Lingua::TagSet

=cut

use base qw/Lingua::TagSet/;
use strict;

our @id_maps = (
    {
        features => { cat => 'adj' },
        tokens   => [ 'ADJ', undef, undef ],
        submap   => [
            1 => 'gender',
            2 => 'num'
        ]
    },
    {
        features => { cat => [ 'adv', 'advneg' ] },
        tokens   => [ 'ADV' ]
    },
    {
        features => { cat => [ 'noun', 'adj', 'det' ] },
        tokens   => [ 'CAR' ],
    },
    {
        features => { cat => 'conj', type => 'co' },
        tokens   => [ 'COO' ],
    },
    {
        features => { cat => 'det' },
        tokens   => [ [ 'DTN', 'DTC' ], undef, undef ],
        submap   => [
            1 => 'gender',
            2 => 'num'
        ]
    },
    {
        features => { cat => 'interj' },
        tokens   => [ 'INJ' ],
    },
    {
        features => { cat => 'punct' },
        tokens   => [ [ '?', '!', '.', ';', ':' ] ],
    },
    {
        features => { cat => 'prep' },
        tokens   => [ 'PREP' ],
    },
    {
        features => { cat => 'pron', type => 'cli' },
        tokens   => [ 'PRV', undef, undef, undef, undef ],
        submap   => [
            1 => 'pers',
            2 => 'gender',
            3 => 'num', 
            4 => 'case'
        ]
    },
    {
        features => { cat => 'pron' },
        tokens   => [ 'PRO', undef, undef, undef, undef ],
        submap   => [
            1 => 'pers',
            2 => 'gender',
            3 => 'num', 
            4 => 'case'
        ]
    },
    {
        features => { cat => 'pron', type => 'rel' },
        tokens   => [ 'REL', undef, undef ],
        submap   => [
            1 => 'gender',
            2 => 'num'
        ]
    },
    {
        features => { cat => 'conj', type => 'sub' },
        tokens   => [ 'SUB' ],
    },
    {
        features => { cat => 'noun', type => 'common' },
        tokens   => [ 'SBC', undef, undef ],
        submap   => [
            1 => 'gender',
            2 => 'num'
        ]
    },
    {
        features => { cat => 'noun', type => 'proper' },
        tokens   => [ 'SBP' ],
    },
    {
        features => { cat => 'verb', mode => 'inf' },
        tokens   => [ 'VNCFF' ],
    },
    {
        features => { cat => 'verb', mode => 'part', tense => 'pres' },
        tokens   => [ 'VNCNT' ],
    },
    {
        features => { cat => 'verb', mode => 'part', tense => 'past' },
        tokens   => [ [ 'VPAR', 'ADJ1PAR', 'ADJ2PAR', 'EPAR' ] , undef, undef ],
        submap   => [
            1 => 'gender',
            2 => 'num'
        ]
    },
    {
        features => { cat => 'verb' },
        tokens   => [ 'VCJ', undef, undef, undef ],
        submap   => [
            1 => 'pers',
            2 => 'num',
            3 => 'tense',
            4 => 'mode'
        ]
    },
    {
        features => { cat => 'x' },
        tokens   => [ [ 'SYM', 'FGW' ] ],
    },
    {
        features => { cat => 'abr' },
        tokens   => [ 'ABR' ],
    },
);

our %value_maps = (
    gender => [
        m => 'masc',
        f => 'fem',
    ],
    num => [
        p => 'pl',
        s => 'sing',
    ],
    pers => [
        '1p' => '1',
        '2p' => '2',
        '3p' => '3',
    ],
    mode => [ 
        ind   => 'ind',
        subj  => 'subj',
        imper => 'imp',
        cond  => 'cond',
    ],
    tense => [
        impft => 'imp',
        pst   => 'pres',
        ps    => 'past',
    ],
    case => [
        a => 'acc',
        d => 'dat',
        n => 'nom',
        o => 'obl',
    ],
);

__PACKAGE__->_init();

sub tag2structure {
    my ($class, $tag_string) = @_;

    # fail fast
    return unless $tag_string;

    # split tag in parts
    my @tokens = split(/:/, $tag_string);

    # convert special values
    @tokens = map {
        $_ ne '_' ?
        $_ =~ /{(.*)}/ ?
        [ split(/\|/, $1) ] :
        [ $_ ]
        : undef
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
        '{' . join('|', @$_) . '}' :
        $_->[0]
        : '_'
    } @tokens;

    # join tokens in tag
    my $tag_string = join(':', @tokens);

    return $tag_string;
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004-2006, INRIA.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 AUTHOR

Guillaume Rousse <grousse@cpan.org>

=cut

1;
