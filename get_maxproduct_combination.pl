#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
use Getopt::Long;
use Data::Dumper;
use feature 'state';

my $debug = 0;

$Data::Dumper::Indent   = 1;
$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Purity   = 1;
$Data::Dumper::Terse    = 1;

my $string = qq{   08 02 22 97 38 15 00 40 00 75 04 05 07 78 52 12 50 77 91 08
                    49 49 99 40 17 81 18 57 60 87 17 40 98 43 69 48 04 56 62 00
                    81 49 31 73 55 79 14 29 93 71 40 67 53 88 30 03 49 13 36 65
                    52 70 95 23 04 60 11 42 69 24 68 56 01 32 56 71 37 02 36 91
                    22 31 16 71 51 67 63 89 41 92 36 54 22 40 40 28 66 33 13 80
                    24 47 32 60 99 03 45 02 44 75 33 53 78 36 84 20 35 17 12 50
                    32 98 81 28 64 23 67 10 26 38 40 67 59 54 70 66 18 38 64 70
                    67 26 20 68 02 62 12 20 95 63 94 39 63 08 40 91 66 49 94 21
                    24 55 58 05 66 73 99 26 97 17 78 78 96 83 14 88 34 89 63 72
                    21 36 23 09 75 00 76 44 20 45 35 14 00 61 33 97 34 31 33 95
                    78 17 53 28 22 75 31 67 15 94 03 80 04 62 16 14 09 53 56 92
                    16 39 05 42 96 35 31 47 55 58 88 24 00 17 54 24 36 29 85 57
                    86 56 00 48 35 71 89 07 05 44 44 37 44 60 21 58 51 54 17 58
                    19 80 81 68 05 94 47 69 28 73 92 13 86 52 17 77 04 89 55 40
                    04 52 08 83 97 35 99 16 07 97 57 32 16 26 26 79 33 27 98 66
                    88 36 68 87 57 62 20 72 03 46 33 67 46 55 12 32 63 93 53 69
                    04 42 16 73 38 25 39 11 24 94 72 18 08 46 29 32 40 62 76 36
                    20 69 36 41 72 30 23 88 34 62 99 69 82 67 59 85 74 04 36 16
                    20 73 35 29 78 31 90 01 74 31 49 71 48 86 81 16 23 57 05 54
                    01 70 54 71 83 51 54 69 16 92 33 48 61 43 52 01 89 19 67 48  };

GetOptions( "debug|debug" => \$debug, );

main($string);

# This is main function that is central control flow.
sub main {

  my $string = shift;
  my @numbers_matrix;
  my %traverse_direction_details = (
    L   => '4 points towards left',
    R   => '4 points towards right',
    U   => '4 points towards upwards',
    D   => '4 points towards downwards',
    LUD => '4 points towrads left upwards diagonaly',
    LDD => '4 points towards left downwards digonaly',
    RUD => '4 points towards right upwards diagonaly',
    RDD => '4 points towards right downwards digonaly',
  );

  # Convert string to matrix, so we can take each co-ordinates as central point and travers left right, rowwise, columnwise and also diagonaly.
  my @rows = split( "\n+", $string );
  foreach my $row (@rows) {
    $row =~ s/^\s+|\s+$//g;
    my @row_array = split /\s+/, $row;
    push @numbers_matrix, \@row_array;
  }

  print_matrix(@numbers_matrix);

  # Call to actual function that get mximum multiplier for 4 adjacent values.
  my ( $cod1, $cod2, $traverse_direction, $max_product ) = get_max_product(@numbers_matrix);

  print
qq{----------------\nMaximum value is - $max_product. \nFor co-ordinate($cod1,$cod2), value $numbers_matrix[$cod1][$cod2] and $traverse_direction_details{$traverse_direction}. \n----------------\n};

}

# Function that calculate maximum product for 4 adjacent values.
sub get_max_product {

  my @matrix                 = @_;
  my $max_product_row_column = 0;
  my $max_product_diagonaly  = 0;
  my ( $matrix_point_rc_cod1, $matrix_point_rc_cod2, $traverse_direction_rc, $matrix_point_diag_cod1, $matrix_point_diag_cod2, $traverse_direction_diag );

  # Loop through matrix treat each point as central co-ordinate
  # and travers left right columnwize, rowwise and digonaly for 4 adjacent co-ordintate points.
  # Get maximum value from a co-oridnate towrads left-right up and down.
  # Get maximum value left-right up and down digonaly.

  for ( my $m = 0 ; $m <= $#matrix ; $m++ ) {
    for ( my $n = 0 ; $n <= $#matrix ; $n++ ) {
      ( $matrix_point_rc_cod1, $matrix_point_rc_cod2, $traverse_direction_rc, $max_product_row_column ) = get_max_product_row_column( $max_product_row_column, $m, $n, @matrix );
      ( $matrix_point_diag_cod1, $matrix_point_diag_cod2, $traverse_direction_diag, $max_product_diagonaly ) = get_max_product_diagonaly( $max_product_diagonaly, $m, $n, @matrix );
    }
    print "\n" if $debug;
  }

  if ( $max_product_row_column > $max_product_diagonaly ) {
    return $matrix_point_rc_cod1, $matrix_point_rc_cod2, $traverse_direction_rc, $max_product_row_column;
  } else {
    return $matrix_point_diag_cod1, $matrix_point_diag_cod2, $traverse_direction_diag, $max_product_diagonaly;
  }
}

# Function that will calculate maximum value left-right, up-down from a co-ordinate point row and column wise.
sub get_max_product_row_column {

  my ( $max_product, $a, $b, @matrix ) = (@_);
  state( $matrix_cod1, $matrix_cod2, $traverse_direction );

  print qq{This is row-column traversal for value $matrix[$a][$b] at co-ordintates $a$b \n} if $debug;

  if ( traverse_for_index($b) ) {
    my ($product_left) = multiplier( $a, $b, 0, -1, \@matrix );
    print qq{Value for left traversing - $product_left \n} if $debug;
    if ( $product_left > $max_product ) {
      $max_product        = $product_left;
      $matrix_cod1       = $a ;
      $matrix_cod2       = $b ;
      $traverse_direction = 'L';
    }

  } else {
    print qq{We do not have enough values to traverse left for - $matrix[$a][$b] \n} if $debug;
  }

  if ( traverse_for_index($b) && set_if_defined( $matrix[$a][ $b + 3 ] ) ) {
    my $product_right = multiplier( $a, $b, 0, 1, \@matrix );
    print qq{Value for right traversing - $product_right \n} if $debug;

    if ( $product_right > $max_product ) {
      $max_product        = $product_right;
      $matrix_cod1       = $a ;
      $matrix_cod2       = $b ;
      $traverse_direction = 'R';
    }
  } else {
    print qq{We do not have enough values to traverse right for - $matrix[$a][$b] \n} if $debug;
  }

  if ( traverse_for_index($a) ) {
    my $product_up = multiplier( $a, $b, -1, 0, \@matrix );
    print qq{Value for upward traversing - $product_up \n} if $debug;
    if ( $product_up > $max_product ) {
      $max_product        = $product_up;
      $matrix_cod1       = $a ;
      $matrix_cod2       = $b ;
      $traverse_direction = 'U';
    }
  } else {
    print qq{We do not have enough values to traverse upwards for - $matrix[$a][$b] \n} if $debug;
  }

  if ( traverse_for_index($a) && set_if_defined( $matrix[ $a + 3 ][$b] ) ) {
    my $product_down = multiplier( $a, $b, 1, 0, \@matrix );
    print qq{Value for down traversing - $product_down \n} if $debug;
    if ( $product_down > $max_product ) {
      $max_product        = $product_down;
      $matrix_cod1       = $a ;
      $matrix_cod2       = $b ;
      $traverse_direction = 'D';
    }
  } else {
    print qq{We do not have enough values for traverse down for - $matrix[$a][$b] \n\n} if $debug;
  }

  return $matrix_cod1, $matrix_cod2, $traverse_direction, $max_product;
}

# Function that will calculate maximum value left-right, up-down from a co-ordinate point digonaly.
sub get_max_product_diagonaly {

  my ( $max_product, $a, $b, @matrix ) = (@_);
  state( $matrix_cod1, $matrix_cod2, $traverse_direction );

  print qq{This is diagonal traverse for value - $matrix[$a][$b], at co-ordintates $a$b \n} if $debug;

  my $matrix_length = scalar( @{ $matrix[1] } );
  if ( traverse_for_index($a) && traverse_for_index($b) ) {
    my $product_left = multiplier( $a, $b, -1, -1, \@matrix );
    print qq{Value for traversing diagonaly left upwards - $product_left \n} if $debug;
    if ( $product_left > $max_product ) {
      $max_product        = $product_left;
      $matrix_cod1       = $a ;
      $matrix_cod2       = $b ;
      $traverse_direction = 'LUD';
    }
    $max_product = ( $product_left > $max_product ) ? $product_left : $max_product;
  } else {
    print qq{We do not have enough values for traverse diagonaly left upwards for - $matrix[$a][$b] . \n} if $debug;
  }

  if ( set_if_defined( $matrix[ $a + 3 ][ $b - 3 ] ) && traverse_for_index($b) ) {
    my $product_left = multiplier( $a, $b, 1, -1, \@matrix );
    print qq{Value for traversing diagonaly left downwards - $product_left \n} if $debug;
    if ( $product_left > $max_product ) {
      $max_product        = $product_left;
      $matrix_cod1       = $a ;
      $matrix_cod2       = $b ;
      $traverse_direction = 'LDD';
    }
  } else {
    print qq{We do not have enough values for traverse diagonaly left downwards for - $matrix[$a][$b] \n} if $debug;
  }

  if ( traverse_for_index($a) && set_if_defined( $matrix[ $a - 3 ][ $b + 3 ] ) ) {
    my $product_right = multiplier( $a, $b, -1, 1, \@matrix );
    print qq{Value for traversing diagonaly to right upwards - $product_right \n} if $debug;
    if ( $product_right > $max_product ) {
      $max_product        = $product_right;
      $matrix_cod1       = $a ;
      $matrix_cod2       = $b ;
      $traverse_direction = 'RUD';
    }
  } else {
    print qq{We do not have enough values for traverse diagonaly right upwards for - $matrix[$a][$b] \n} if $debug;
  }

  if ( set_if_defined( $matrix[ $a + 3 ][ $b + 3 ] ) ) {
    my $product_right = multiplier( $a, $b, 1, 1, \@matrix );
    print qq{Value for traversing diagonaly to right downwards - $product_right \n} if $debug;
    if ( $product_right > $max_product ) {
      $max_product        = $product_right;
      $matrix_cod1       = $a ;
      $matrix_cod2       = $b ;
      $traverse_direction = 'RDD';
    }
  } else {
    print qq{We do not have enough values for traverse diagonaly right downwards, for - $matrix[$a][$b] \n\n} if $debug;
  }

  return $matrix_cod1, $matrix_cod2, $traverse_direction, $max_product;
}

# Check if we have to traverse or not, Example co-ordinates at end.
sub traverse_for_index {

  unless ( scalar @_ == 1 ) {
    print "Require at least 1 index value for co-ordinate to check if we can traverse or not.\n";
    exit 1;
  }

  my $index = shift;
  return ( $index - 1 >= 0 && $index - 2 >= 0 && $index - 3 >= 0 ) ? 1 : 0;

}

# Only set value if co-ordinate is inside boundry. Example treat co-orinate that only have 3 adjacent value as 0(not-considerd).
sub set_if_defined {
  my $value = shift;
  ( defined $value ) ? return $value : return 0;
}

# Simple multiplier for 4 values.
sub multiplier() {

  unless ( scalar @_ == 5 ) {
    print "Require 4 numbers for multiplication.\n";
    exit 1;
  }

  my ( $a, $b, $a_inc_dec, $b_inc_dec, $matrix ) = (@_);
  my @matrix = @{$matrix};

  if ( ( $a_inc_dec == 0 ) && ( $b_inc_dec < 0 ) ) {
    return set_if_defined( $matrix[$a][$b] ) *
      set_if_defined( $matrix[$a][ $b - 1 ] ) *
      set_if_defined( $matrix[$a][ $b - 2 ] ) *
      set_if_defined( $matrix[$a][ $b - 3 ] );
  }

  if ( ( $a_inc_dec < 0 ) && ( $b_inc_dec == 0 ) ) {
    return set_if_defined( $matrix[$a][$b] ) *
      set_if_defined( $matrix[ $a - 1 ][$b] ) *
      set_if_defined( $matrix[ $a - 2 ][$b] ) *
      set_if_defined( $matrix[ $a - 3 ][$b] );
  }

  if ( ( $a_inc_dec == 0 ) && ( $b_inc_dec > 0 ) ) {
    return set_if_defined( $matrix[$a][$b] ) *
      set_if_defined( $matrix[$a][ $b + 1 ] ) *
      set_if_defined( $matrix[$a][ $b + 1 ] ) *
      set_if_defined( $matrix[$a][ $b + 1 ] );
  }

  if ( ( $a_inc_dec < 1 ) && ( $b_inc_dec == 0 ) ) {
    return set_if_defined( $matrix[$a][$b] ) *
      set_if_defined( $matrix[ $a - 1 ][$b] ) *
      set_if_defined( $matrix[ $a - 2 ][$b] ) *
      set_if_defined( $matrix[ $a - 3 ][$b] );
  }

  if ( ( $a_inc_dec > 1 ) && ( $b_inc_dec == 0 ) ) {
    return set_if_defined( $matrix[$a][$b] ) *
      set_if_defined( $matrix[ $a + 1 ][$b] ) *
      set_if_defined( $matrix[ $a + 2 ][$b] ) *
      set_if_defined( $matrix[ $a + 3 ][$b] );
  }

  if ( ( $a_inc_dec < 0 ) && ( $b_inc_dec < 0 ) ) {
    return set_if_defined( $matrix[$a][$b] ) *
      set_if_defined( $matrix[ $a - 1 ][ $b - 1 ] ) *
      set_if_defined( $matrix[ $a - 2 ][ $b - 2 ] ) *
      set_if_defined( $matrix[ $a - 3 ][ $b - 3 ] );
  }

  if ( ( $a_inc_dec > 1 ) && ( $b_inc_dec < 0 ) ) {
    return set_if_defined( $matrix[$a][$b] ) *
      set_if_defined( $matrix[ $a + 1 ][ $b - 1 ] ) *
      set_if_defined( $matrix[ $a + 2 ][ $b - 2 ] ) *
      set_if_defined( $matrix[ $a + 3 ][ $b - 3 ] );
  }

  if ( ( $a_inc_dec < 1 ) && ( $b_inc_dec > 1 ) ) {
    return set_if_defined( $matrix[$a][$b] ) *
      set_if_defined( $matrix[ $a - 1 ][ $b + 1 ] ) *
      set_if_defined( $matrix[ $a - 2 ][ $b + 2 ] ) *
      set_if_defined( $matrix[ $a - 3 ][ $b + 3 ] );
  }

  if ( ( $a_inc_dec > 1 ) && ( $b_inc_dec > 1 ) ) {
    return set_if_defined( $matrix[$a][$b] ) *
      set_if_defined( $matrix[ $a + 1 ][ $b + 1 ] ) *
      set_if_defined( $matrix[ $a + 2 ][ $b + 2 ] ) *
      set_if_defined( $matrix[ $a + 3 ][ $b + 3 ] );
  }
}

# Print Matrix.
sub print_matrix() {

  my @matrix = @_;
  print "The matrix is -\n----------------\n";
  for ( my $m = 0 ; $m <= $#matrix ; $m++ ) {
    for ( my $n = 0 ; $n <= $#matrix ; $n++ ) {
      print "$matrix[$m][$n] ";
    }
    print "\n";
  }
  return 1;

}

__END__

=pod

=head1 USAGE

  Example :
  perl get_maxproduct_combination.pl

  See more detailed overview
  perl get_maxproduct_combination.pl --debug

  Below is a variable that contains a text string. Rewrite the syntax to an appropriate string type for your coding language and parse it as the start of your solution. Then create an application that prints the highest possible product you can get from 4 two digit numbers that are next to each other, either in a row, column or in any of the diagonals (including the anti-diagonals). For example, the numbers marked with red has the product 1788696, but that is not the correct answer.

  string-type txt = "08 02 22 97 38 15 00 40 00 75 04 05 07 78 52 12 50 77 91 08\n"+
                    "49 49 99 40 17 81 18 57 60 87 17 40 98 43 69 48 04 56 62 00\n"+
                    "81 49 31 73 55 79 14 29 93 71 40 67 53 88 30 03 49 13 36 65\n"+
                    "52 70 95 23 04 60 11 42 69 24 68 56 01 32 56 71 37 02 36 91\n"+
                    "22 31 16 71 51 67 63 89 41 92 36 54 22 40 40 28 66 33 13 80\n"+
                    "24 47 32 60 99 03 45 02 44 75 33 53 78 36 84 20 35 17 12 50\n"+
                    "32 98 81 28 64 23 67 10 26 38 40 67 59 54 70 66 18 38 64 70\n"+
                    "67 26 20 68 02 62 12 20 95 63 94 39 63 08 40 91 66 49 94 21\n"+
                    "24 55 58 05 66 73 99 26 97 17 78 78 96 83 14 88 34 89 63 72\n"+
                    "21 36 23 09 75 00 76 44 20 45 35 14 00 61 33 97 34 31 33 95\n"+
                    "78 17 53 28 22 75 31 67 15 94 03 80 04 62 16 14 09 53 56 92\n"+
                    "16 39 05 42 96 35 31 47 55 58 88 24 00 17 54 24 36 29 85 57\n"+
                    "86 56 00 48 35 71 89 07 05 44 44 37 44 60 21 58 51 54 17 58\n"+
                    "19 80 81 68 05 94 47 69 28 73 92 13 86 52 17 77 04 89 55 40\n"+
                    "04 52 08 83 97 35 99 16 07 97 57 32 16 26 26 79 33 27 98 66\n"+
                    "88 36 68 87 57 62 20 72 03 46 33 67 46 55 12 32 63 93 53 69\n"+
                    "04 42 16 73 38 25 39 11 24 94 72 18 08 46 29 32 40 62 76 36\n"+
                    "20 69 36 41 72 30 23 88 34 62 99 69 82 67 59 85 74 04 36 16\n"+
                    "20 73 35 29 78 31 90 01 74 31 49 71 48 86 81 16 23 57 05 54\n"+
                    "01 70 54 71 83 51 54 69 16 92 33 48 61 43 52 01 89 19 67 48";

=cut
