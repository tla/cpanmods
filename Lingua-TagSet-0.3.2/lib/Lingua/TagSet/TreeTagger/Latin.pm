# $Id: TreeTagger.pm,v 1.6 2006/08/22 14:21:55 rousse Exp $
package Lingua::TagSet::TreeTagger::Latin;

=head1 NAME

Lingua::TagSet::TreeTagger::Latin - TreeTagger Latin tagset for Lingua::TagSet

=cut

use base qw/Lingua::TagSet/;
use strict;

our @id_maps = (
    {
        features => { cat => 'adj', degree => 'comp' },
        tokens   => [ 'ADJ', 'COM' ],
    },
    {
        features => { cat => 'adj', degree => 'sup' },
        tokens   => [ 'ADJ', 'SUP' ],
    },
    {
        features => { cat => 'adj', type => [ 'ord', 'card' ] },
        tokens   => [ 'ADJ', 'NUM' ],
    },
    {
        features => { cat => 'adj' },
        tokens   => [ 'ADJ', undef ],
        submap   => [
        	1 => 'case'
        ]
    },
    {
        features => { cat => 'adv' },
        tokens   => [ 'ADV' ]
    },
    {
        features => { cat => 'conj', type => 'co' },
        tokens   => [ 'CC' ],
    },
    {
        features => { cat => 'conj', type => 'sub' },
        tokens   => [ 'CS' ],
    },
    {
        features => { cat => 'det' },
        tokens   => [ 'DET' ],
    },
    {
    	features => { cat => 'pron', type => 'dem' },
    	tokens => [ 'DIMOS']
    },
    {
    	features => { cat => 'verb', type => 'etre' },
    	tokens => [ 'ESSE' ],
    	submap => [
    		1 => 'mode'
    	]
    },
    {
    	features => { cat => 'fw' },
    	tokens => [ 'FW' ]
    },
    {
        features => { cat => 'interj' },
        tokens   => [ 'INT' ],
    },
    {
        features => { cat => 'noun', type => 'common' },
        tokens   => [ 'N', undef ],
        submap   => [
        	1 => 'case'
        ]
    },
    # NPR?
    {
        features => { cat => 'noun', type => 'proper' },
        tokens   => [ 'NPR' ],
    },
    {
        features => { cat => [ 'pron', 'adj', 'det' ], type => 'poss' }, #ok
        tokens   => [ 'POSS' ],
    },
    {
        features => { cat => 'prep' }, #OK
        tokens   => [ 'PREP' ],
    },
    {
        features => { cat => 'pron' }, #ok
        tokens   => [ 'PRON' ],
    },
    {
        features => { cat => 'punct' }, #OK
        tokens   => [ 'PUN' ],
    },
    {
    	features => { cat => [ 'pron', 'det' ], type => 'rel' },
    	tokens => [ 'REL' ],
    },
    {
        features => { cat => 'pp' }, #OK
        tokens   => [ 'SENT' ],
    },
    {
        features => { cat => 'verb' },
        tokens   => [ 'V', undef ],
        submap   => [ 
            1 => 'mode',
            2 => 'case', # for participles & supine
        ]
    },
);

our %value_maps = (
    mode => [ 
    	GER => 'gnd',
        IMP => 'imp',
        IND => 'ind',
        INF => 'inf',
        PTC => 'part',
        SUB => 'subj',
        SUP => 'sup'
    ],
    case => [
    	nom => 'nom',
    	acc => 'acc',
    	gen => 'gen',
    	dat => 'dat',
    	abl => 'abl',
    	loc => 'loc',
    	voc => 'voc'
    ]
);

__PACKAGE__->_init();

sub tag2structure {
    my ($class, $tag_string) = @_;

    # fail fast
    return unless $tag_string;

    # split tag in tokens
    my @tokens = split(/:/, $tag_string);

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
