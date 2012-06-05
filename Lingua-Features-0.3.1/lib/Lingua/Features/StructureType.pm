# $Id: StructureType.pm,v 1.7 2006/08/22 14:15:37 rousse Exp $
package Lingua::Features::StructureType;

=head1 NAME

Lingua::Features::StructureType - StructureType object for Lingua::Features

=cut

use Tie::IxHash;
use Lingua::Features::FeatureType;
use Carp;
use strict;
use warnings;

# static members

my %types;

Lingua::Features::StructureType->_new(
    id => 'abr'
);

Lingua::Features::StructureType->_new(
    id       => 'adj',
    features => [ 
        type   => 'adj',
        degree => 'degree',
        gender => 'gender',
        num    => 'num'
    ]
);

Lingua::Features::StructureType->_new(
    id => 'adv',
);

Lingua::Features::StructureType->_new(
    id   => 'advneg',
    base => 'adv'
);

Lingua::Features::StructureType->_new(
    id => 'x'
);

Lingua::Features::StructureType->_new(
    id => 'cl'
);

Lingua::Features::StructureType->_new(
    id   => 'cla',
    base => 'cl'
);

Lingua::Features::StructureType->_new(
    id   => 'cln',
    base => 'cl'
);

Lingua::Features::StructureType->_new(
    id   => 'clng',
    base => 'cl'
);

Lingua::Features::StructureType->_new(
    id       => 'det',
    features => [
        type    => 'det',
        pers    => 'pers',
        gender  => 'gender',
        num     => 'num', 
        numposs => 'num',
        def     => 'def'
    ]
);

Lingua::Features::StructureType->_new(
    id       => 'noun',
    features => [
        type   => 'noun',
        gender => 'gender',
        num    => 'num', 
        sem    => 'sem', 
    ]
);

Lingua::Features::StructureType->_new(
    id       => 'pron',
    features => [
        type    => 'pron',
        pers    => 'pers',
        gender  => 'gender',
        num     => 'num',
        case    => 'case',
        numposs => 'num'
    ]
);

Lingua::Features::StructureType->_new(
    id => 'ponct'
);

Lingua::Features::StructureType->_new(
    id => 'pp'
);

Lingua::Features::StructureType->_new(
    id => 'prep'
);

Lingua::Features::StructureType->_new(
    id => 'pref'
);

Lingua::Features::StructureType->_new(
    id => 's'
);

Lingua::Features::StructureType->_new(
    id       => 'verb',
    features => [
        type   => 'verb',
        mode   => 'mode',
        tense  => 'tense',
        pers   => 'pers',
        num    => 'num',
        gender => 'gender'
    ]
);

Lingua::Features::StructureType->_new(
    id => 'vm'
);

Lingua::Features::StructureType->_new(
    id => 'cc'
);

Lingua::Features::StructureType->_new(
    id => 'cs'
);

Lingua::Features::StructureType->_new(
    id => 'interj'
);

# static methods

=head1 static methods

=head2 Lingua::Features::StructureType->types()

Returns all defined structure types.

=cut

sub types {
    my ($class) = @_;
    return values %types;
}

=head2 Lingua::Features::StructureType->type(I<$id>)

Returns structure type I<$id>.

=cut

sub type {
    my ($class, $id) = @_;

    return $types{$id};
}

sub _new {
    my ($class, %args) = @_;

    my $self = bless {
        _id => $args{id},
    }, $class;

    if ($args{base}) {
        $self->{_base} = $types{$args{base}};
    }

    if ($args{features}) {
        $self->{_features} = {};
        tie %{$self->{_features}}, 'Tie::IxHash';

        while (@{$args{features}}) {
            my $id   = shift @{$args{features}};
            my $type = shift @{$args{features}};
            $self->{_features}->{$id} = Lingua::Features::FeatureType->type($type);
        }
    }

    $types{$self->{_id}} = $self;

    return $self;
}

=head1 Accessors

=head2 $type->id()

Returns the structure type id.

=cut

sub id {
    my ($self) = @_;
    return unless ref $self;
    return $self->{_id};
}

=head2 $type->base()

Returns the structure type base as a C<Lingua::Features::StructureType> object.

=cut

sub base {
    my ($self) = @_;
    return unless ref $self;
    return $self->{_base};
}

=head2 $type->features()

Returns the structure type features as an hash of feature types indexed by feature ids.

=cut

sub features {
    my ($self) = @_;
    return unless ref $self;

    my @features;

    push(@features, $self->{_base}->features()) if $self->{_base};

    push(@features, keys %{$self->{_features}}) if $self->{_features};

    return @features;
}

=head2 $type->feature_type(I<$id>)

Returns type of feature I<$id>.

=cut

sub feature_type {
    my ($self, $id) = @_;
    return unless ref $self;
    return unless $id && $self->{_features};

    return $self->{_features}->{$id};
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004-2006, INRIA.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 AUTHOR

Guillaume Rousse <grousse@cpan.org>

=cut

1;
