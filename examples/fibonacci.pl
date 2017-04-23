#!/usr/bin/perl

#
## Closed-form for Fibonacci numbers.
#

use utf8;
use 5.014;

use Test::More;
plan tests => 10;

use lib qw(../lib);
use Math::Bacovia qw(pi Power Symbol Fraction);

sub fibonacci {
    my ($n) = @_;
    state $S = Power(5, '1/2');
    Fraction(Fraction($S + 1, 2)**$n - (Fraction(2, $S + 1)**$n * cos(pi * $n)), $S);
}

my @fibs = qw(0 1 1 2 3 5 8 13 21 34);

foreach my $n (0 .. 9) {
    is(fibonacci($n)->numeric, shift(@fibs));
}

my $simple = fibonacci(Symbol('n', 12))->simple;

$simple->numeric eq '144'
  or die "Error in simplification!";

say $simple->simple->pretty;
