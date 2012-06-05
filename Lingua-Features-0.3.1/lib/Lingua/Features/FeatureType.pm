# $Id: FeatureType.pm,v 1.7 2006/08/22 14:15:37 rousse Exp $
package Lingua::Features::FeatureType;

=head1 NAME

Lingua::Features::FeatureType - FeatureType object for Lingua::Features

=cut

use Carp;
use strict;
use warnings;

# static members

my %types;

Lingua::Features::FeatureType->_new(
    id     => 'det',
    values => {
        art  => 'article',
        dem  => 'demonstrative',
        ind  => 'indefinite',
        poss => 'possessive',
        int  => 'interrogative',
        excl => 'exclusive',
        part => 'partitive',
        card => 'cardinal',
    }
);

Lingua::Features::FeatureType->_new(
    id     => 'adj',
    values => {
        qual => 'qualitative',
        ord  => 'ordinal',
        ind  => 'indefi',
        poss => 'possessive',
        card => 'cardinal',
        int  => 'interrogative',
    }
);

Lingua::Features::FeatureType->_new(
    id     => 'noun',
    values => {
        common => 'common',
        proper => 'proper',
        dist   => 'distinguished',
        ord    => 'ordinal'
    }
);

Lingua::Features::FeatureType->_new(
    id     => 'pron',
    values => {
        pers => 'personal',
        dem  => 'demonstrative',
        ind  => 'indefini',
        poss => 'possessive',
        int  => 'interrogative',
        rel  => 'relative',
        cli  => 'clitique',
        refl => 'reflexive'
    }
);

Lingua::Features::FeatureType->_new(
    id     => 'verb',
    values => {
        avoir => 'avoir',
        etre  => 'etre',
        main  => 'main',
    }
);

Lingua::Features::FeatureType->_new(
    id     => 'mode',
    values => {
        ind  => 'indicative',
        subj => 'subjonctive',
        imp  => 'imperative',
        cond => 'conditionnal',
        inf  => 'infinitive',
        part => 'participe',
    }
);

Lingua::Features::FeatureType->_new(
    id     => 'tense',
    values => {
        pres => 'present',
        imp  => 'imparfait',
        fut  => 'future',
        past => 'past',
    }
);

Lingua::Features::FeatureType->_new(
    id     => 'pers',
    values => {
        1 => '1',
        2 => '2',
        3 => '3',
    }
);

Lingua::Features::FeatureType->_new(
    id     => 'gender',
    values => {
        masc => 'masculin',
        fem  => 'feminin',
    }
);

Lingua::Features::FeatureType->_new(
    id     => 'degree',
    values => {
        comp => 'comp',
        pos  => 'pos',
    }
);

Lingua::Features::FeatureType->_new(
    id     => 'num',
    values => {
        pl   => 'plural',
        sing => 'singular',
    }
);

Lingua::Features::FeatureType->_new(
    id     => 'case',
    values => {
        acc => 'accusative',
        dat => 'dative',
        gen => 'genitive',
        nom => 'nominative',
        obl => 'oblique',
        ref => 'reflexive',
        loc => 'locative'
    }
);

Lingua::Features::FeatureType->_new(
    id     => 'restr',
    values => {
        moinshum => 'moinshum',
        plushum  => 'plushum',
    }
);

Lingua::Features::FeatureType->_new(
    id     => 'wh',
    values => {
        plus  => 'plus',
        minus => 'minus',
        rel   => 'rel',
    }
);

Lingua::Features::FeatureType->_new(
    id     => 'bool',
    values => {
        plus  => 'plus',
        minus => 'minus',
    }
);

Lingua::Features::FeatureType->_new(
    id     => 'def',
    values => {
        def => 'defini',
        ind => 'indefini',
    }
);

Lingua::Features::FeatureType->_new(
    id     => 'pos',
    values => {
        pos  => 'pos',
        comp => 'comp',
    }
);

Lingua::Features::FeatureType->_new(
    id     => 'res',
    values => {
        unit => 'unit',
        exp  => 'expression',
        for  => 'foreign',
    }
);

Lingua::Features::FeatureType->_new(
    id     => 'sem',
    values => {
        pl  => 'place',
        inh => 'inhabitant',
        ent => 'entity',
    }
);

=head1 static methods

=head2 Lingua::Features::FeatureType->types()

Returns all defined feature types.

=cut

sub types {
    my ($class) = @_;
    return values %types;
}

=head2 Lingua::Features::FeatureType->type(I<$id>)

Returns feature type I<$id>.

=cut

sub type {
    my ($class, $id) = @_;
    return $types{$id};
}

sub _new {
    my ($class, %args) = @_;

    my $self = bless {
        _id       => $args{id},
    }, $class;

    $self->{_values} = $args{values};

    $types{$self->{_id}} = $self;

    return $self;
}

=head1 Accessors

=head2 $type->id()

Returns the feature type id.

=cut

sub id {
    my ($self) = @_;
    return unless ref $self;
    return $self->{_id};
}

=head2 $type->values()

Returns the feature type values an array.

=cut

sub values {
    my ($self) = @_;
    return unless ref $self;

    return keys %{$self->{_values}};
}

=head2 $type->value_name(I<$id>)

Returns name of value I<$id>.

=cut

sub value_name {
    my ($self, $id) = @_;
    return unless ref $self;
    return unless $id;

    return $self->{_values}->{$id};
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004-2006, INRIA.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 AUTHOR

Guillaume Rousse <grousse@cpan.org>

=cut

1;
