use strict;
use Text::WagnerFischer qw(distance);

my $first_distance=distance("foo","four");
print "First distance (default costs): ".$first_distance." should be 2\n";

my $second_distance=distance("foo","foo");
print "Second distance (default costs): ".$second_distance." should be 0\n";

my $third_distance=distance([0,1,2],"foo","four");
print "Third distance (custom costs): ".$third_distance." should be 3\n";

my @words=("four","foo","bar");

my @distances=distance("foo",@words);
print "Distances in array (default costs): [@distances] should be [2 0 3]\n";

@distances=distance([0,2,1],"foo",@words);
print "Distances in array (custom costs): [@distances] should be [3 0 3]\n";
