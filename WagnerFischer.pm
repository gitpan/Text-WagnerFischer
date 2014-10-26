package Text::WagnerFischer;

use strict;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION     = '0.01';
@ISA         = qw(Exporter);
@EXPORT      = ();
@EXPORT_OK   = qw(&distance);
%EXPORT_TAGS = ();


sub _min {

	my ($first,$second,$third)=@_;
	my $result=$first;

	$result=$second if ($second < $result);
	$result=$third if ($third < $result);

	return $result
}

sub _weight {

	#the cost function

	my ($x,$y,$refc)=@_;

	if ($x eq $y) {

		return $refc->[0] #cost for letter match

	} elsif (($x eq '-') or ($y eq '-')) {

		return $refc->[1] #cost for insertion/deletion operation

	} else {

		return $refc->[2] #cost for letter mismatch
	}
}

sub distance {

	my ($refc,$s,@t)=@_;

	if (!@t) {

		if (ref($refc) ne "ARRAY") {

			if (ref($s) ne "ARRAY") {

				#array cost missing: using default [0,1,1]

				@t[0]=$s;
				$s=$refc;
				$refc=[0,1,1];

			} else {

	           		require Carp;
        	      		Carp::croak("Text::WagnerFischer: second string is needed");
			}

		} else {

           		require Carp;
       	      		Carp::croak("Text::WagnerFischer: second string is needed");
		}

	} else {

		if (ref($refc) ne "ARRAY") {

			#array cost missing: using default [0,1,1]

			unshift @t,$s;
			$s=$refc;
			$refc=[0,1,1];
		}
	}

	my $n=length($s);
	my @result;

	foreach my $t (@t) {

		my @d;

		my $m=length($t);
		if(!$n) {push @result,$m;last}
		if(!$m) {push @result,$n;last}

		$d[0][0]=0;
		foreach my $i (1 .. $n) {$d[$i][0]=_weight($i,'-',$refc)}
		foreach my $j (1 .. $m) {$d[0][$j]=_weight('-',$j,$refc)}

		foreach my $i (1 .. $n) {
			my $s_i=substr($s,$i-1,1);
			foreach my $j (1 .. $m) {

				my $t_i=substr($t,$j-1,1);

				$d[$i][$j]=_min($d[$i-1][$j]+_weight($s_i,'-',$refc),
						 $d[$i][$j-1]+_weight('-',$t_i,$refc),
						 $d[$i-1][$j-1]+_weight($s_i,$t_i,$refc))
			}
		}

		push @result,$d[$n][$m];
	}

	if (wantarray) {return @result} else {return $result[0]}
}
	
1;

__END__

=head1 NAME

Text::WagnerFischer - An implementation of the Wagner-Fischer edit distance

=head1 SYNOPSIS



    use Text::WagnerFischer qw(distance);

    print distance("foo","four");# prints "2"

    print distance([0,1,2],"foo","four");# prints "3"


    my @words=("four","foo","bar");

    my @distances=distance("foo",@words); 
    print "@distances"; # prints "2 0 3"

    @distances=distance([0,2,1],"foo",@words); 
    print "@distances"; # prints "3 0 3"

 

=head1 DESCRIPTION

This module implements the Wagner-Fischer dynamic programming technique,
used here to calculate the edit distance of two strings.
The edit distance is a measure of the degree of proximity between two strings,
based on "edits": the operations of substitutions, deletions or insertions
needed to transform the string into the other one (and vice versa).
A cost (weight) is needed for every of the operation defined above:

	    / a if x=y (cost for letter match)
 w(x,y) =  |  b if x=- or y=- (cost for insertion/deletion operation)
	    \ c if x!=y (cost for letter mismatch)

These costs are given trough an array reference as first argument of the 
distance subroutine: [a,b,c].
If the costs are not given, a default array cost is used: [0,1,1] that is the
case of the Levenshtein edit distance:

	    / 0 if x=y (cost for letter match)
 w(x,y) =  |  1 if x=- or y=- (cost for insertion/deletion operation)
	    \ 1 if x!=y (cost for letter mismatch)

This particular distance is the exact number of edit needed to transform 
the string into the other one (and vice versa).
When two strings have distance 0, they are the same.


=head1 AUTHOR

Copyright 2002 Dree Mistrut <F<dree@friul.it>>

This package is free software and is provided "as is" without express
or implied warranty. You can redistribute it and/or modify it under 
the same terms as Perl itself.

=cut

