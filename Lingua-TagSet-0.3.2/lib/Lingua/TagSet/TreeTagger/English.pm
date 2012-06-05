# $Id: TreeTagger.pm,v 1.6 2006/08/22 14:21:55 rousse Exp $
package Lingua::TagSet::TreeTagger::English;

=head1 NAME

Lingua::TagSet::TreeTagger::English - TreeTagger English tagset for Lingua::TagSet

=cut

use base qw/Lingua::TagSet/;
use strict;

our @id_maps = (
	## Adjectives
    {
        features => { cat => 'adj' },
        tokens   => [ 'JJ' ],
    },
    {
        features => { cat => 'adj', degree => 'comp' },
        tokens   => [ 'JJR' ],
    },
    {
        features => { cat => 'adj', degree => 'sup' },
        tokens   => [ 'JJS' ],
    },
    
    ## Adverbs
    {
        features => { cat => 'adv' }, #ok
        tokens   => [ 'RB' ],
    },
    {
        features => { cat => 'adv', degree => 'comp' },
        tokens   => [ 'RBR' ],
    },
    {
        features => { cat => 'adv', degree => 'sup' },
        tokens   => [ 'RBS' ],
    },

	# Determiner
    {
        features => { cat => 'det' },
        tokens   => [ 'DT' ],
    },
    {
        features => { cat => 'det' },
        tokens   => [ 'PDT' ], # predeterminer
    },

	# Existential
    {
        features => { cat => 'exist' },
        tokens   => [ 'EX' ],
    },
	
	# Interjection
    {
        features => { cat => 'interj' },
        tokens   => [ 'UH' ],
    },
    
    # Conjunctions, prepositions
    {
        features => { cat => 'conj', type => 'co' },
        tokens   => [ 'CC' ],
    },
    {
        features => { cat => [ 'prep', 'conj' ] },
        tokens   => [ 'IN' ],
    },
    {
        features => { cat => 'conj', type => 'sub' },
        tokens   => [ 'IN/that' ],
    },
    
    # Nouns
    {
        features => { cat => 'noun', type => 'common', num => 'sing' },
        tokens   => [ 'NN' ],
    },
    {
        features => { cat => 'noun', type => 'common', num => 'pl' },
        tokens   => [ 'NNS' ],
    },
    {
        features => { cat => 'noun', type => 'proper', num => 'sing' },
        tokens   => [ 'NP' ],
    },
    {
        features => { cat => 'noun', type => 'proper', num => 'pl' },
        tokens   => [ 'NPS' ],
    },
    
    # Numbers
    {
        features => { cat => [ 'noun', 'adj', 'det' ] },
        tokens   => [ 'CD' ],
    },
    
    # Pronouns
    {
    	features => { cat => 'pron', type => 'poss' },
    	tokens   => [ 'POS' ], # 's ending
    },
    {
        features => { cat => 'pron', type => 'pers' },
        tokens   => [ 'PP' ],
    },
    {
    	features => { cat => 'pron', type => 'poss' },
    	tokens => [ 'PP$' ],
    },
    
    # Particles
    {
        features => { cat => 'part' },
        tokens   => [ 'RP' ],
    },
    
	# Sentence marker
    {
        features => { cat => 'pp' },
        tokens   => [ 'SENT' ],
    },
    
    # Symbols
    {
        features => { cat => 'x' },
        tokens   => [ 'SYM' ],
    },
    
    # To - treat as preposition for now
    {
    	features => { cat => 'prep' },
    	tokens   => [ 'TO' ],
    },
    
    # Verbs
    {
        features => { cat => 'verb' },
        tokens   => [ 'VV' ],
    },
    {
        features => { cat => 'verb', tense => 'past' },
        tokens   => [ 'VVD' ],
    },
    {
        features => { cat => 'verb', tense => 'pres', mode => 'gnd' },
        tokens   => [ 'VVG' ],
    },
    {
        features => { cat => 'verb', tense => 'past', mode => 'part' },
        tokens   => [ 'VVN' ],
    },
    {
        features => { cat => 'verb', tense => 'pres', num => 'sing', pers => [ 1, 2 ] },
        tokens   => [ 'VVP' ],
    },
    {
        features => { cat => 'verb', tense => 'pres', num => 'sing', pers => '3' },
        tokens   => [ 'VVZ' ],
    },
    {
        features => { cat => 'verb', type => 'etre' },
        tokens   => [ 'VB' ],
    },
    {
        features => { cat => 'verb', tense => 'past', type => 'etre' },
        tokens   => [ 'VBD' ],
    },
    {
        features => { cat => 'verb', tense => 'pres', mode => 'gnd', type => 'etre' },
        tokens   => [ 'VBG' ],
    },
    {
        features => { cat => 'verb', tense => 'past', mode => 'part', type => 'etre' },
        tokens   => [ 'VBN' ],
    },
    {
        features => { cat => 'verb', tense => 'pres', num => 'sing', pers => [ 1, 2 ], type => 'etre' },
        tokens   => [ 'VBP' ],
    },
    {
        features => { cat => 'verb', tense => 'pres', num => 'sing', pers => '3', type => 'etre' },
        tokens   => [ 'VBZ' ],
    },
    {
        features => { cat => 'verb', type => 'avoir' },
        tokens   => [ 'VH' ],
    },
    {
        features => { cat => 'verb', tense => 'past', type => 'avoir' },
        tokens   => [ 'VHD' ],
    },
    {
        features => { cat => 'verb', tense => 'pres', mode => 'gnd', type => 'avoir' },
        tokens   => [ 'VHG' ],
    },
    {
        features => { cat => 'verb', tense => 'past', mode => 'part', type => 'avoir' },
        tokens   => [ 'VHN' ],
    },
    {
        features => { cat => 'verb', tense => 'pres', num => 'sing', pers => [ 1, 2 ], type => 'avoir' },
        tokens   => [ 'VHP' ],
    },
    {
        features => { cat => 'verb', tense => 'pres', num => 'sing', pers => '3', type => 'avoir' },
        tokens   => [ 'VHZ' ],
    },
     {
        features => { cat => 'verb', type => 'modal' },
        tokens   => [ 'MD' ],
    },
   
    # Wh-words
    {
        features => { cat => 'det', type => 'int' }, 
        tokens   => [ 'WDT' ],
    },
    {
        features => { cat => 'pron', type => 'rel' }, 
        tokens   => [ 'WP' ],
    },
    {
        features => { cat => 'pron', type => 'poss' }, 
        tokens   => [ 'WP$' ],
    },
    {
        features => { cat => 'adv' }, 
        tokens   => [ 'WRB' ],
    },
    
);

our %value_maps = {};

__PACKAGE__->_init();

sub tag2structure {
    my ($class, $tag_string) = @_;

    # fail fast
    return unless $tag_string;

    # split tag in tokens
    my @tokens = ( $tag_string );

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
