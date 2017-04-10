#!/usr/bin/perl

#
## Closed-form for Fibonacci numbers.
#

use utf8;
use 5.016;

use Test::More;
plan tests => 10;

use lib qw(../lib);
use Math::Bacovia qw(Power Symbol Fraction);

my $S = Fraction(Power(5, '1/2') + 1, 2);
my $T = Fraction(Power(5, '1/2') - 1, 2);

sub fibonacci {
    my ($n) = @_;
    Fraction(($S**$n - (-$T)**$n), Power(5, '1/2'));
}

my @fibs = qw(0 1 1 2 3 5 8 13 21 34);

foreach my $n (0 .. 9) {
    is(fibonacci($n)->numeric, shift(@fibs));
}

my $simple = fibonacci(Symbol('n', 12))->simple;

$simple->numeric eq '144'
  or die "Error in simplification!";

say $simple->simple->pretty;
