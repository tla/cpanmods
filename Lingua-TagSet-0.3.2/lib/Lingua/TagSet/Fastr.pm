# $Id: TreeTagger.pm,v 1.4 2004/06/11 11:36:57 rousse Exp $
package Lingua::TagSet::Fastr;

=head1 NAME

Lingua::TagSet::Fastr - Fastr tagset for Lingua::TagSet

=cut

use base qw/Lingua::TagSet/;
use strict;

my @fields = qw/cat ten/;

our @id_maps = (
    {
        features => { cat => 'abr' },
        tokens   => [ 'N' ],
    },
    {
        features => { cat => 'adj' },
        tokens   => [ 'A' ],
    },
    {
        features => { cat => 'adj', type => [ 'card', 'ord' ] },
        tokens   => [ 'NUM' ],
    },
    {
        features => { cat => 'adv' },
        tokens   => [ 'ADV' ]
    },
    {
        features => { cat => 'det' },
        tokens   => [ 'ART' ],
    },
    {
        features => { cat => 'interj' },
        tokens   => [ 'N' ],
    },
    {
        features => { cat => 'cc' },
        tokens   => [ 'C' ],
    },
    {
        features => { cat => 'cs' },
        tokens   => [ 'CSUB' ],
    },
    {
        features => { cat => 'noun' },
        tokens   => [ 'N' ],
    },
    {
        features => { cat => 'pron' },
        tokens   => [ 'PRON' ],
    },
    {
        features => { cat => 'ponct' },
        tokens   => [ 'PUNC' ],
    },
    {
        features => { cat => 'pp' },
        tokens   => [ 'Pf' ],
    },
    {
        features => { cat => 'prep' },
        tokens   => [ 'PREP' ],
    },
    {
        features => { cat => 'verb' },
        tokens   => [ 'V', undef ],
        submap   => [ 
            1 => 'mode',
            1 => 'tense'
        ]
    },
);

our %value_maps = (
    mode => [ 
        active            => 'ind',
        active            => 'cond',
        active            => 'subj',
        infinitive        => 'inf',
        pastParticiple    => 'part',
        presentParticiple => 'part'
    ],
    tense => [
        pastParticiple    => 'past',
        presentParticiple => 'pres'
    ],
);

__PACKAGE__->_init();

sub tag2structure {
    my ($class, $tag_string) = @_;

    # fail fast
    return unless $tag_string;

    # split tag in tokens
    my @tokens = split(' ', $tag_string);

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
    my $tag_string = join(
        ' ',
        @tokens
    );

    return $tag_string;
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004-2006, INRIA.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 AUTHOR

Guillaume Rousse <grousse@cpan.org>

=cut

1;
