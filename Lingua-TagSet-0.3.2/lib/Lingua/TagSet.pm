# $Id: TagSet.pm,v 1.13 2006/09/01 09:32:59 rousse Exp $
package Lingua::TagSet;

=head1 NAME

Lingua::TagSet - Natural language tagset conversion

=head1 VERSION

Version 0.3.2

=head1 DESCRIPTION

This module allows to convert values between different tagsets used in natural
language processing, using Lingua::Features as a pivot format

=head1 SYNOPSIS

    use Lingua::TagSet::Multext;

    # tagset to features conversions
    my $struct = Lingua::TagSet::Multext->tag2structure($multext);
    my $string = Lingua::TagSet::Multext->tag2string($multext);

    # features to tagset conversions
    my $multext = Lingua::TagSet::Multext->string2tag($string);
    my $multext = Lingua::TagSet::Multext->structure2tag($structure);

=cut

use Memoize;
use Lingua::Features::Structure;
use Lingua::TagSet::Tag;
use strict;
use warnings;

our $VERSION = '0.3.2';

my (%tag2string, %string2tag);
memoize 'tag2string', SCALAR_CACHE => [ HASH => \%tag2string ];
memoize 'string2tag', SCALAR_CACHE => [ HASH => \%string2tag ];

my %tokens_trees;
my %features_trees;
my %tokens_tables;
my %features_tables;

sub _init {
    my ($class) = @_;

    no strict 'refs';

    my $tokens_tree    = {};
    my $features_tree  = {};
    my $tokens_table   = {};
    my $features_table = {};

    foreach my $map (@{$class . '::id_maps'}) {

        # token to feature: tree of tokens valued by mappings
        my $token_leaf;
        $token_leaf->{features} = $map->{features};
        $token_leaf->{submap}   = { _index(@{$map->{submap}}) } if $map->{submap};
        $token_leaf->{specific} = ref $map->{tokens}->[0] ne 'ARRAY';
        my $tag        = Lingua::TagSet::Tag->new(@{$map->{tokens}});
        my @token_list = _get_tokens_list($tag);
        _build_tree($tokens_tree, \@token_list, 0, $token_leaf);

        # feature to token: tree of features valued by mappings
        my $feature_leaf;
        $feature_leaf->{tokens} = $map->{tokens};
        $feature_leaf->{submap} = { _index(reverse @{$map->{submap}}) } if $map->{submap};
        $feature_leaf->{specific} = ref $map->{features}->{cat} ne 'ARRAY';
        my $structure = Lingua::Features::Structure->new(%{$map->{features}});
        my @feature_list = _get_features_list($structure);
        _build_tree($features_tree, \@feature_list, 0, $feature_leaf);
    }

    while (my ($type, $map) = each %{$class . '::value_maps'}) {
        # token to feature: feature values indexed by token value
        $tokens_table->{$type} = { _index(@{$map}) };
        # feature to token: token values indexed by feature value
        $features_table->{$type} = { _index(reverse @{$map}) };
    }

    $tokens_trees{$class}    = $tokens_tree;
    $features_trees{$class}  = $features_tree;
    $tokens_tables{$class}   = $tokens_table;
    $features_tables{$class} = $features_table;
}

sub _index {
    my (@list) = @_;
    my %hash;
    while (@list) {
        my $key   = shift @list;
        my $value = shift @list;
        push(@{$hash{$key}}, $value); 
    }
    return %hash;
}

sub _get_features_list {
    my ($structure) = @_;
    my $i;
    my @list = grep { $i++ % 2 } $structure->get_features();
    pop @list while ! defined $list[-1];
    return @list;
}

sub _get_tokens_list {
    my ($tag) = @_;
    my @list = $tag->get_tokens();
    pop @list while ! defined $list[-1];
    return @list;
}

=head2 Lingua::TagSet->tag2structure()

Convert a tag to a features structure.

=cut

sub tag2structure {
    my ($class, $tag, %args) = @_;

    return unless $tag;

    # get converter data
    my $tree  = $tokens_trees{$class};
    my $table = $tokens_tables{$class};

    # find matching maps
    my @tokens  = _get_tokens_list($tag);
    my @id_maps = _parse_tree($tree, \@tokens, 0);
    return unless @id_maps;

    # select most relevant one
    my $id_map = $id_maps[0];

    # create base structure
    my $structure = Lingua::Features::Structure->new(%{$id_map->{features}});

    # compute other features
    my $submap = $id_map->{submap};
    if ($submap) {
        foreach my $token_id (sort keys %{$submap}) {
            my $token_values = $tag->get_token($token_id);
            next unless $token_values; # unknown value

            my $feature_ids = $submap->{$token_id};
            foreach my $feature_id (@{$feature_ids}) {
                my $type = $structure->get_type()->{$feature_id};
                die "no feature $feature_id" unless $type;

                my $type_id   = $type->id();
                my $value_map = $table->{$type_id};
                die "no value map for type $type_id" unless $value_map;

                my @feature_values;
                foreach my $token_value (@{$token_values}) {
                    push(@feature_values, @{$value_map->{$token_value}}) if $value_map->{$token_value};

                }

                if (@feature_values) {
                    $structure->set_feature($feature_id, \@feature_values);
                } else {
                    if ($args{no_strict_align}) {
                        # some tagset skip unknown values
                        $tag->insert_token($token_id, undef);
                    } else {
                        # unknown value
                        $structure->set_feature($feature_id, undef);
                    }
                }
            }
        }
    }

    return $structure;
}

=head2 Lingua::TagSet->structure2tag()

Convert a features structure to a tag.

=cut

sub structure2tag {
    my ($class, $structure, %args) = @_;

    return unless $structure;

    # get converter data
    my $tree  = $features_trees{$class};
    my $table = $features_tables{$class};

    # find matching maps
    my @features = _get_features_list($structure);
    my @id_maps = _parse_tree($tree, \@features, 0);
    return Lingua::TagSet::Tag->new() unless @id_maps;

    # select most relevant one
    my $id_map = _select_alternative_maps(
        \@id_maps,
        [
        sub { return $_->{specific} }, # prefer specific maps
        sub { return $_->{submap} }    # prefer exhaustive maps
        ]
    );

    # create base tag
    my $tag = Lingua::TagSet::Tag->new(@{$id_map->{tokens}});

    # compute other tokens
    my $submap = $id_map->{submap};
    if ($submap) {
        foreach my $feature_id (%{$submap}) {
            my $feature_values = $structure->get_feature($feature_id);
            next unless $feature_values; # unknown value

            my $type = $structure->get_type()->{$feature_id};
            die "no feature $feature_id" unless $type;

            my $type_id   = $type->id();
            my $value_map = $table->{$type_id};
            die "no value map for type $type_id" unless $value_map;

            my $token_ids = $submap->{$feature_id};
            foreach my $token_id (@{$token_ids}) {
                my @token_values;
                foreach my $feature_value (@{$feature_values}) {
                    push(@token_values, @{$value_map->{$feature_value}}) if $value_map->{$feature_value};
                }

                # take care of multiple-mapped features
                my $current_values = $tag->get_token($token_id);
                if ($current_values) {
                    # keep only intersection of two sets
                    my (%union, %intersection);
                    foreach my $value (@token_values, @{$current_values}) {
                        $union{$value}++ && $intersection{$value}++;
                    }
                    @token_values = keys %intersection;
                }

                if (@token_values) {
                    $tag->set_token($token_id, \@token_values);
                } else {
                    $tag->set_token($token_id, undef);
                }
            }
        }
    }

    return $tag;
}

sub _build_tree {
    my ($node, $list, $index, $leaf) = @_;

    # extract values for current position
    my $values = $list->[$index] || [ '_any' ];

    # construct a branch for each value
    foreach my $value (@{$values}) {
        # add a new node
        $node->{$value} = {} unless $node->{$value};

        if ($index != $#$list) {
            # build tree further
            _build_tree($node->{$value}, $list, ++$index, $leaf);
        } else {
            # add leaves
            if ($node->{$value}->{_map}) {
                push (@{$node->{$value}->{_map}}, $leaf);
            } else {
                $node->{$value}->{_map} = [ $leaf ]
            }
        }
    }
}

sub _parse_tree {
    my ($node, $list, $index) = @_;

    # extract values for current position
    my $values = $list->[$index];

    my @results;

    # browse each potential specific branch if values are known
    if ($values) {
        foreach my $value (@{$values}) {
            if ($node->{$value}) {
                push(@results, _parse_tree($node->{$value}, $list, ++$index));
            }
        }
    }

    # browse generic branch if present
    if ($node->{_any}) {
        push(@results, _parse_tree($node->{_any}, $list, ++$index));
    }

    # return current maps if no other results found sofar
    unless (@results) {
        @results = @{$node->{_map}} if $node->{_map};
    }

    # otherwise return current result
    return @results;
}

sub _select_alternative_maps {
    my ($maps, $functions) = @_;

    # return unique solution
    return $maps->[0] if $#$maps == 0;

    my $function = shift @$functions;

    # keep filtering while criterias available
    if ($function) {
        my @filtered_maps = grep { $function->($_) } @$maps;
        return @filtered_maps ?
        _select_alternative_maps(\@filtered_maps, $functions) :
        _select_alternative_maps($maps, $functions) ;
    }

    # otherwise merge remaining mappings
    my $max = 0;
    for my $map (@$maps) {
        $max = $#{$map->{tokens}} if $#{$map->{tokens}} > $max;
    }

    my @tokens;
    for (my $i = 0; $i <= $max; $i++) {
        foreach my $map (@$maps) {
            my $item = $map->{tokens}->[$i];
            if ($item) {
                if (ref $item eq 'ARRAY') {
                    push(@{$tokens[$i]}, @{$item});
                } else {
                    push(@{$tokens[$i]}, $item);
                }
            }
        }
    }

    return {
        tokens => \@tokens
    }
}

=head2 Lingua::TagSet->tag2string()

Convert a tag into a string representation of a features structure.
The result is cached.

=cut

sub tag2string {
    my ($class, $tag_string) = @_;
    return unless $tag_string;
    my $structure = $class->tag2structure($tag_string);
    return $structure ? $structure->to_string(): '';
}

=head2 Lingua::TagSet->string2tag()

Convert a string representation of a features structure into a tag.
The result is cached.

=cut

sub string2tag {
    my ($class, $structure_string) = @_;
    return unless $structure_string;
    my $structure = Lingua::Features::Structure->from_string($structure_string);
    my $tag_string = $class->structure2tag($structure);
    return $tag_string ? $tag_string : '';
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004-2006, INRIA.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 AUTHOR

Guillaume Rousse <grousse@cpan.org>

=cut

1;
