# $Id: TreeTagger.pm,v 1.6 2006/08/22 14:21:55 rousse Exp $
package Lingua::TagSet::TreeTagger;

=head1 NAME

Lingua::TagSet::TreeTagger - TreeTagger tagset for Lingua::TagSet

=cut

use base qw/Lingua::TagSet/;
use strict;

our @id_maps = (
    {
        features => { cat => 'abr' },
        tokens   => [ 'ABR' ],
    },
    {
        features => { cat => 'adj' },
        tokens   => [ 'ADJ' ],
    },
    {
        features => { cat => 'adv' },
        tokens   => [ 'ADV' ]
    },
    {
        features => { cat => 'det', type => 'poss' },
        tokens   => [ 'DET', 'POS' ],
    },
    {
        features => { cat => 'det' },
        tokens   => [ 'DET', 'ART' ],
    },
    {
        features => { cat => 'interj' },
        tokens   => [ 'INT' ],
    },
    {
        features => { cat => [ 'cc', 'cs' ] },
        tokens   => [ 'KON' ],
    },
    {
        features => { cat => 'noun', type => 'common' },
        tokens   => [ 'NOM' ],
    },
    {
        features => { cat => 'noun', type => 'proper' },
        tokens   => [ 'NAM' ],
    },
    {
        features => { cat => [ 'noun', 'adj', 'det' ] },
        tokens   => [ 'NUM' ],
    },
    {
        features => { cat => 'pron' },
        tokens   => [ 'PRO', undef ],
        submap   => [
            1 => 'type'
        ]
    },
    {
        features => { cat => 'ponct' },
        tokens   => [ 'PUN' ],
    },
    {
        features => { cat => 'prep' },
        tokens   => [ 'PRP' ],
    },
    {
        features => { cat => 'pp' },
        tokens   => [ 'SENT' ],
    },
    {
        features => { cat => 'x' },
        tokens   => [ 'SYM' ],
    },
    {
        features => { cat => 'verb' },
        tokens   => [ 'VER', undef ],
        submap   => [ 
            1 => 'mode',
            1 => 'tense'
        ]
    },
);

our %value_maps = (
    det => [
        POS => 'poss',
    ],
    pron => [
        DEM => 'dem',
        REL => 'rel',
        IND => 'ind',
        POS => 'poss',
        PER => 'pers',
    ],
    mode => [ 
        cond => 'cond',
        futu => 'ind',
        impe => 'imp',
        impf => 'ind',
        infi => 'inf',
        pper => 'part',
        ppre => 'part',
        pres => 'ind',
        simp => 'ind',
        subi => 'subj',
        subp => 'subj',
    ],
    tense => [
        cond => 'pres',
        futu => 'fut',
        impe => 'pres',
        impf => 'imp',
        infi => 'pres',
        pper => 'past',
        ppre => 'pres',
        pres => 'pres',
        simp => 'past',
        subi => 'imp',
        subp => 'pres',
    ],
);

__PACKAGE__->_init();

sub tag2structure {
    my ($class, $tag_string) = @_;

    # fail fast
    return unless $tag_string;

    # split tag in tokens
    my @tokens = split(/:/, $tag_string, 2);

    # convert special values
    @tokens = map {
        $_ ? [ $_ ] : undef
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
                join('|', @$_) :
                $_->[0]
            : ''
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
