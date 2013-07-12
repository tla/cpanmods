#!/usr/local/bin/perl -w

=head1 NAME

simat.pl - Build a similarity matrix from real-valued context vectors

=head1 SYNOPSIS

simat.pl [OPTIONS] VECTOR

The input file represents 5 vectors, each with 4 possible features. The 
format of the input file is sparse, so if a feature has no value it is 
not listed.

 cat input

Output => 

 5 4 12
 1 1.5 3 2.5 4 1.0
 2 2.5 3 2.5
 1 1.5 3 2.5 4 1.0
 2 2.5 3 2.5
 2 2.5 3 2.5

Compute the pairwise similarities between all 5 vectors and display them 
in a 5x5 matrix. 

 simat.pl input --format f4.2

Output =>

 5 25
 1 1.00 2 0.57 3 1.00 4 0.57 5 0.57
 1 0.57 2 1.00 3 0.57 4 1.00 5 1.00
 1 1.00 2 0.57 3 1.00 4 0.57 5 0.57
 1 0.57 2 1.00 3 0.57 4 1.00 5 1.00
 1 0.57 2 1.00 3 0.57 4 1.00 5 1.00

Type C<simat.pl> for a quick summary of options

=head1 DESCRIPTION

Constructs a similarity matrix for the given real-valued context 
vectors. A similarity matrix shows the pairwise similarities between all 
the different vectors. Vectors are represented in an N x M matrix, where 
N is the number of vectors and M is the number of features. All NxN 
combinations of vector pairs will be measured for similarity 
and stored in a matrix.

=head1 INPUT

=head2 Required Arguments:

=head3 VECTOR

Should be a file containing sparse/dense vectors as created by programs in
dir Toolkit/vector.

=head4 Sparse Format (default)

When the input vectors are in sparse format, the first line in the VECTOR
file should show 3 space separated numbers -

 N M NNZ

where

 N = Number of rows/vectors
 M = Number of columns
 NNZ = Number of non-zero values

Each line after this line should show a single sparse vector on each line.
A sparse vector is a list of pairs of numbers separated by space such
that the first number in a pair is the index of a non-zero value in the
vector and the second number is a non-zero value itself corresponding to
that index.

Column indices start with 1.

Sample Sparse Format -

 7 8 27
 3 0.727 4 0.921 7 0.734 8 0.841
 6 0.726 7 0.775 8 0.948
 1 0.898 3 0.712 5 0.787 8 0.724
 4 0.797 6 0.649
 1 0.695 2 0.710 3 0.837 4 0.736 7 0.631
 2 0.661 3 0.778 4 0.762 6 0.957
 1 0.915 3 0.639 5 0.989 6 0.637 8 0.649

Explanation :

=over

=item 1. 

First line shows that there are 7 sparse vectors, represented using 
8 features, and total 27 non-zero values.

=item 2. 

Each vector (all lines except the 1st line) is a list of 'INDEX VALUE'
pairs separated by space. 

e.g. line 2 shows that the 1st vector has a non-zero value 0.727 at index 3, 
0.921 at 4, value 0.734 at index 7 and 0.841 at 8.

Only those 'INDEX VALUE' pairs are listed in which value is non-zero.

Column indices start from 1, to be consistent with Cluto's matrix format
standard. 

=back

Note that, the values could be integer and negative.

=head4 Dense Format

If VECTORs are in dense format, switch --dense should be selected.

For N vectors each having M components, the first line of dense VECTOR file 
should show exactly 2 integers N M i.e. number of vectors and number of 
components, separated in space. This should be followed by actual vectors 
each on a separate line. Each dense vector should only list the vector 
component values (and not the corresponding column indices), and should 
show all values including 0s. Thus, all vectors should be equal in length and 
should show M space separated numbers.

Sample Dense Format -

 7 8
 0.000 0.000 0.727 0.921 0.000 0.000 0.734 0.841
 0.000 0.000 0.000 0.000 0.000 0.726 0.775 0.948
 0.898 0.000 0.712 0.000 0.787 0.000 0.000 0.724
 0.000 0.000 0.000 0.797 0.000 0.649 0.000 0.000
 0.695 0.710 0.837 0.736 0.000 0.000 0.631 0.000
 0.000 0.661 0.778 0.762 0.000 0.957 0.000 0.000
 0.915 0.000 0.639 0.000 0.989 0.637 0.000 0.649

Shows same VECTOR file as shown in section Sample Sparse Format, in dense 
format.

VECTOR file could also optionally show the <keyfile> tag on the first line.
If the first line shows the <keyfile> name, then the above VECTOR 
description should start from the 2nd line onwards.

=head2 Optional Arguments:

=head3 --dense

This switch should be selected when the given VECTORs are in dense format. 
This will also create the output similarity matrix in dense format. By 
default, sparse format is assumed and used for both input vectors and 
output similarity matrix.

=head3 --format FORM

Specifies the numeric representation format for output similarity matrix. 

Acceptable FORM value is

fN.M -> each similarity value is represented as a floating point number 
occupying total N byte space with last M bytes showing the fractional part.

Default format used is f16.10.

Since the cosine similarity values computed by simat are always in the range
[0-1], simat supports only floating point format. 

=head3 Other Options :

=head4 --help

Displays this message.

=head4 --version

Displays the version information.

=head1 OUTPUT

=head2 Sparse Format [default]

By default (when --dense is not selected), OUTPUT will be created in sparse 
format. In sparse format, the 1st line will show two space separated numbers,

 N NNZ1 

where
 N = Number of vectors, same as the N in the given VECTOR file
 NNZ1 = Number of non-zero values in the output similarity matrix

Each i'th line after the above line shows the list of 'j COSINE' pairs 
separated by space such that COSINE is the non-zero cosine similarity value
between the i'th and j'th vectors in the given VECTOR file.

Only those pairs are listed in which the COSINE values are non-zeroes.

Sample Sparse Output 

 7 29
 1 1.000 4 0.441 6 0.491 7 0.357
 2 1.000 3 0.308 4 0.322 5 0.212
 2 0.308 3 1.000
 1 0.441 2 0.322 4 1.000 5 0.352 6 0.750 7 0.230
 2 0.212 4 0.352 5 1.000 6 0.651
 1 0.491 4 0.750 5 0.651 6 1.000 7 0.398
 1 0.357 4 0.230 6 0.398 7 1.000

Shows the actual full similarity matrix -

 7
 1.000 0.000 0.000 0.441 0.000 0.491 0.357
 0.000 1.000 0.308 0.322 0.212 0.000 0.000
 0.000 0.308 1.000 0.000 0.000 0.000 0.000
 0.441 0.322 0.000 1.000 0.352 0.750 0.230
 0.000 0.212 0.000 0.352 1.000 0.651 0.000
 0.491 0.000 0.000 0.750 0.651 1.000 0.398
 0.357 0.000 0.000 0.230 0.000 0.398 1.000

Both the matrices show the pair-wise similarities among 7 vectors. 
e.g. Row 1 shows that the cosine similarity among the 1st vector and
the 4th vector is 0.441, between 1st and 6th is 0.491, and the similarity 
between 1st and 7th vectors is 0.357. In sparse format, each line shows
only those values that are non-zeroes.

Note that, the similarity matrix (sparse/dense) always represents a square
symmetric matrix.

=head2 Dense Format

For N input vectors, the first line of the dense output shows a single 
integer number N (the total number of vectors). Thereafter, each i'th line 
shows pair-wise similarities of i'th vector with each of the N vectors. i.e. 
each row contains N columns such that the value at j'th column in i'th row 
shows the pair-wise similarity between i'th and j'th vectors.

Sample Dense Output

 7
 1.000 0.000 0.000 0.441 0.000 0.491 0.357
 0.000 1.000 0.308 0.322 0.212 0.000 0.000
 0.000 0.308 1.000 0.000 0.000 0.000 0.000
 0.441 0.322 0.000 1.000 0.352 0.750 0.230
 0.000 0.212 0.000 0.352 1.000 0.651 0.000
 0.491 0.000 0.000 0.750 0.651 1.000 0.398
 0.357 0.000 0.000 0.230 0.000 0.398 1.000

where each cell shows the similarity between the corresponding pair of 
vectors.

=head1 SYSTEM REQUIREMENTS

simat.pl is dependent on the following CPAN modules :

=over

=item PDL - L<http://search.cpan.org/dist/PDL/>

=item Math::SparseVector - L<http://search.cpan.org/dist/Math-SparseVector/>

=back

=head1 AUTHORS

 Amruta Purandare, University of Pittsburgh

 Ted Pedersen, University of Minnesota, Duluth
 tpederse at d.umn.edu

=head1 COPYRIGHT

Copyright (c) 2002-2008, Amruta Purandare and Ted Pedersen

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program; if not, write to

 The Free Software Foundation, Inc.,
 59 Temple Place - Suite 330,
 Boston, MA  02111-1307, USA.

=cut

###############################################################################

#                               THE CODE STARTS HERE
package Text::SenseClusters::Simat;
use strict;
use warnings;
# loading PDL modules 
use PDL;
use PDL::NiceSlice;
use PDL::Primitive;
use PDL::IO::FastRaw;

# loading Math::SparseVector module
use Math::SparseVector;

###############################################################################

#                       ================================
#                          INITIALIZATION AND INPUT
#                       ================================

sub simat {
	my $input_fh = shift;
	my %opts = (
		dense => undef,
		format => "%16.10f",
		@_ );
	

##############################################################################

#			=======================================
#			     Finding Pair-wise Similarities
#			=======================================

	my $line_num=1;
	my $result = {};
	# open( SIMATOUT, '>', \$output_str ) or die "Could not open variable for writing";
	# reading first line
	$_=<$input_fh>;
	chomp;
	if(/keyfile/)
	{
		# when input starts with <keyfile>
		# output also starts with <keyfile>
		$result->{'keyfile'} = $_;
		# read next line
		$_=<$input_fh>;
		chomp;
		$line_num++;
	}

	my( $rows, $cols, $nnz1 );
	if(defined $opts{dense})
	{
		if(/^\s*(\d+)\s+(\d+)\s*$/)
		{
			$rows=$1;
			$cols=$2;
		}
		else
		{
			print STDERR "ERROR(simat):
		Line $line_num of input should show #nrows #ncols when --dense is ON.\n";
			return;
		}
	}
	else
	{
		if(/^\s*(\d+)\s+(\d+)\s+(\d+)\s*$/)
			{
					$rows=$1;
					$cols=$2;
					$nnz1=$3;
			}
			else
			{
					print STDERR "ERROR(simat):
			Line $line_num of input should show #nrows #ncols #nnz.\n";
					return;
			}
	}

	my( $matrix_file, $cos_file, $map_pdl, $cosine_pdl, $row );
	if(defined $opts{dense})
	{
		# mapping vectors to a temporary file
		$matrix_file="matrix".time().".simat";
		$map_pdl=mapfraw("$matrix_file",{Creat=>1, Dims=>[$cols,$rows], Datatype=>double});

		# reading vectors and storing in mapped piddle
		$row=0;
		while(<$input_fh>)
		{
			s/^\s*//;
			s/\s*$//;
			my @vector_comps=split(/\s+/);
			if(scalar(@vector_comps)!=$cols)
				{
						print STDERR "ERROR(simat):
			Vector $row of input doesn't have $cols components.\n";
						return;
				}
				$map_pdl(:,$row).=pdl @vector_comps;
			$row++;
		}

		if($row!=$rows)
		{
			print STDERR "ERROR(simat):
		Input doesn't contain $rows vectors.\n";
			return;
		}

		# normalizing
		$map_pdl.=$map_pdl->norm;

		# mapping cosine matrix
		$cos_file="cosine".time().".simat";
		$cosine_pdl=mapfraw("$cos_file",{Creat=>1, Dims=>[$rows,$rows], Datatype=>double});

		# taking inner product
		$cosine_pdl.=matmult($map_pdl,$map_pdl->mv(0,1));

		# printing
		$result->{rows} = $rows;
		foreach my $r (0..$cosine_pdl->getdim(1)-1)
		{
			foreach my $c (0..$cosine_pdl->getdim(0)-1)
			{
				$result->{$r}->{$c} = sprintf $opts{format}, $cosine_pdl->at($c,$r);
			}
		}

		unlink "$cos_file";
		unlink "$cos_file.hdr";
		unlink "$matrix_file";
		unlink "$matrix_file.hdr";
	}
	# given vectors in sparse format
	else
	{
		$row=0;
		my $nnz = 0;
		my @sparse_vectors;
		while(<$input_fh>)
		{
			$line_num++;
			$row++;
			chomp;
			s/^\s*//;
			s/\s*$//;
			my $sparsevec=Math::SparseVector->new;
			my @pairs=split;
			foreach(my $i=0; $i<$#pairs; $i=$i+2)
			{
				my $index=$pairs[$i];
				if($index > $cols)
				{
					print STDERR "ERROR(simat):
		Index <$index> at line <$line_num> of input
		exceeds #cols = <$cols> specified in the header line.\n";
					return;
				}
				my $value=$pairs[$i+1];
				if($value==0)
				{
					print STDERR "ERROR(simat):
		Caught value 0 at line <$line_num> of input.\n";
					return;
				}
				$sparsevec->set($index,$value);
				$nnz++;
			}
			push @sparse_vectors,$sparsevec;
		}
		close $input_fh;
		if($row!=$rows)
		{
			print STDERR "ERROR(simat):
		#rows = $rows specified in the header line of input
		does not match the actual #rows = $row found in the file.\n";
			return;
		}
		if($nnz != $nnz1)
		{
			print STDERR "ERROR(simat):
		#nnz = $nnz1 specified in the header line of input
		does not match the actual #nnz = $nnz found in the file.\n";
			return;
		}
		# normalizing all rows
		foreach (@sparse_vectors)
		{
	#		@keys=$_->keys();
	#		if($#keys > -1)
			if(! $_->isnull)
			{
				$_->normalize;
			}
		}

		# finding cosines
		foreach my $i (1..$rows)
		{
			$result->{$i}->{$i}=1;
			foreach my $j ($i+1..$rows)
			{
				my $dp=$sparse_vectors[$i-1]->dot($sparse_vectors[$j-1]);
				$result->{$i}->{$j}=$dp;
				$result->{$j}->{$i}=$dp;
			}
		}
	}
	return $result;
}

1;