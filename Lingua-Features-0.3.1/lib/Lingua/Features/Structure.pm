# $Id: Structure.pm,v 1.17 2006/08/22 14:15:37 rousse Exp $
package Lingua::Features::Structure;

=head1 NAME

Lingua::Features::Structure - Structure object for Lingua::Features

=cut

use Tie::IxHash;
use XML::Generator;
use List::Compare;
use Lingua::Features::StructureType;
use Lingua::Features::FeatureType;
use Carp;
use strict;
use warnings;

my $feature_delimiter = ' ';
my $id_delimiter      = '@';
my $value_delimiter   = '|';

=head1 Constructor

=head2 new(I<%features>)

Creates and returns a new C<Lingua::Features::Structure> object.

=cut

sub new {
    my ($class, %features) = @_;

    croak "no category given" unless $features{cat};
    $features{cat} = [ $features{cat} ] unless ref $features{cat} eq 'ARRAY';

    my %type;
    tie %type, 'Tie::IxHash';

    my %seen;
    my @cat = 
    sort
    grep { Lingua::Features::StructureType->type($_) } # allowed cat
    grep { ! $seen{$_}++ }                             # unique
    @{$features{cat}};
    croak "no valid type given, aborting" unless @cat;
    @cat = sort @cat;

    foreach my $cat (@cat) {
        my $type = Lingua::Features::StructureType->type($cat);
        foreach my $feature ($type->features()) {
            $type{$feature} = $type->feature_type($feature);
        }
    }

    my $self = bless {
        _cat      => \@cat,
        _type     => \%type,
        _features => {}
    }, $class;

    $self->set_features(%features) if %features;

    return $self;
}

=head2 from_string(I<$string>)

Creates and returns a new C<Lingua::Features::Structure> object from a string representation.

=cut

sub from_string {
    my ($class, $string) = @_;

    my %features;
    foreach my $feature (split(/\Q$feature_delimiter\E/, $string)) {
        my ($id, $values) = split(/\Q$id_delimiter\E/, $feature);
        $features{$id} = [ split(/\Q$value_delimiter\E/, $values) ];
    }

    return $class->new(%features);
}

=head1 Accessors

=head2 $structure->get_type()

Returns the type of this feature as a hash of types indexed by id.

=cut

sub get_type {
    my ($self) = @_;
    return unless ref $self;
    return $self->{_type};
}

=head2 $structure->get_features()

Returns the features composing the structure.

=cut

sub get_features {
    my ($self) = @_;
    return unless ref $self;

    # sort by type order
    return
    cat => $self->{_cat},
    map {
        $_ => $self->{_features}->{$_}
    } keys %{$self->{_type}};
}

=head2 $structure->set_features(I<%features>)

Sets the features composing the structure.

=cut

sub set_features {
    my ($self, %features) = @_;
    return unless ref $self;

    # initialize storage
    $self->{_features} = {};

    # set features
    foreach my $id (keys %features) {
        $self->set_feature($id, $features{$id});
    }
}

=head2 $structure->get_feature(I<$id>)

Returns one of the features composing the structure.

=cut

sub get_feature {
    my ($self, $id) = @_;
    return unless ref $self;
    return unless $id;

    if ($id eq 'cat') {
        return $self->{_cat};
    } else {
        return $self->{_features}->{$id};
    }
}

=head2 $structure->set_feature(I<$id>, I<$value>)

Sets one of the features composing the structure.

=cut

sub set_feature {
    my ($self, $id, $values) = @_;
    return unless ref $self;
    return unless $id;
    return if $id eq 'cat';

    my $type = $self->{_type}->{$id};
    if ($type) {
        if ($values) {
            $values = [ $values ] unless ref $values eq 'ARRAY';

            my %seen;
            my @values = 
            sort
            grep { $type->value_name($_) } # allowed in type
            grep { ! $seen{$_}++ }         # unique
            @{$values};

            if (@values) {
                # having all values from type is the same as no values
                my $lc = List::Compare->new( {
                        lists    => [ \@values, [ $type->values() ]],
                        unsorted => 1,
                    } );
                @values = () if $lc->is_LequivalentR();
            }

            if (@values) {
                $self->{_features}->{$id} = \@values;
            } else {
                $self->{_features}->{$id} = undef;
            }
        }
    } else {
        carp "No such feature $id in this structure";
    }
}

=head1 Other methods

=head2 $structure->to_string()

Dumps the structure in string format.

=cut

sub to_string {
    my ($self) = @_;

    my @in = $self->get_features();
    my @out;

    while (@in) {
        my $id     = shift @in;
        my $values = shift @in;
        next unless $values;
        push(@out, $id . $id_delimiter . join($value_delimiter, @{$values}))
    };

    return join($feature_delimiter, @out);
}

=head2 $structure->to_xml()

Dumps the structure in XML format.

=cut

sub to_xml {
    my ($self) = @_;

    my $xml = XML::Generator->new(pretty => 2);
    my @in = $self->get_features();
    my @out;

    while (@in) {
        my $name   = shift @in;
        my $values = shift @in;
        next unless $values;
        my @values = map { _value_to_xml($xml, $_) } @{$values};
        push(@out, $xml->f(
            { name => $name },
            @values > 1 ?  $xml->vAlt(@values) : $values[0]
        ));
    }

    return $xml->fs(@out);
}

sub _value_to_xml {
    my ($xml, $value) = @_;
    return $xml->binary({value => 'true'}) if $value eq '+';
    return $xml->binary({value => 'false'}) if $value eq '-';
    return $xml->symbol({value => $value});
}

=head2 $structure->is_subset(I<$other_structure>)

Return true if current structure is a subset of I<$other_structure>.

=cut

sub is_subset {
    my ($self, $other) = @_;

    return unless $self && $other;

    my %self_features  = $self->get_features();
    my %other_features = $other->get_features();

    foreach my $feature (keys %self_features) {
        # feature doesn't exist in other structure
        return 0 unless exists $other_features{$feature};

        # no values for this feature
        next unless $self_features{$feature};

        # no values in other structure feature
        return 0 unless $other_features{$feature};

        my $lc = List::Compare->new( {
                lists    => [
                    $self_features{$feature},
                    $other_features{$feature}
                ],
                unsorted => 1,
            } );

        return 0 unless $lc->is_LsubsetR();
    }

    return 1;
}

=head2 $structure->is_compatible(I<$other_structure>)

Return true if either of current structure and I<$other_structure> is a subset of the other.

=cut

sub is_compatible {
    my ($self, $other) = @_;

    return unless $self && $other;

    return $self->is_subset($other) || $other->is_subset($self);
}

=head2 $structure->has_same_type(I<$other_structure>)

Return true if current structure and I<$other_structure> share the same type, based on cat and type features.

=cut

sub has_same_type {
    my ($self, $other) = @_;

    return unless $self && $other;

    my %self_features  = $self->get_features();
    my %other_features = $other->get_features();

    foreach my $feature (qw/cat type/) {
        my $lc = List::Compare->new( {
                lists    => [
                    $self_features{$feature} ? $self_features{$feature} : [],
                    $other_features{$feature} ? $other_features{$feature} : []
                ],
                unsorted => 1,
            } );
        return 0 unless $lc->is_LequivalentR();
    }

    return 1;
}

=head2 union(I<$structure1>, I<$structure2>)

Return a new structure resulting of the union of I<$structure1> and
I<$structure2>.

=cut

sub union {
    my ($class, $struct1, $struct2) = @_;

    my %features;
    my %features1 = $struct1->get_features();
    my %features2 = $struct2->get_features();

    my $lc_f = List::Compare->new({
            lists => [
                [ keys %features1 ],
                [ keys %features2 ]
            ],
            unsorted => 1,
        });

    foreach my $feature ($lc_f->get_union()) {
        my $lc_v = List::Compare->new({
                lists => [
                    $features1{$feature} || [],
                    $features2{$feature} || []
                ],
                unsorted => 1,
            });
        $features{$feature} = [ $lc_v->get_union() ];
    }

    return $class->new(%features);
}

=head2 intersection(I<$structure1>, I<$structure2>)

Return a new structure resulting of the intersection of I<$structure1> and
I<$structure2>.

=cut

sub intersection {
    my ($class, $struct1, $struct2) = @_;

    my %features;
    my %features1 = $struct1->get_features();
    my %features2 = $struct2->get_features();

    my $lc_f = List::Compare->new({
            lists => [
                [ keys %features1 ],
                [ keys %features2 ]
            ],
            unsorted => 1,
        });

    foreach my $feature ($lc_f->get_intersection()) {
        my $lc_v = List::Compare->new({
                lists => [
                    $features1{$feature} || [],
                    $features2{$feature} || []
                ],
                unsorted => 1,
            });
        $features{$feature} = [ $lc_v->get_intersection() ];
    }

    return $class->new(%features);
}


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004-2006, INRIA.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 AUTHOR

Guillaume Rousse <grousse@cpan.org>

=cut

1;
