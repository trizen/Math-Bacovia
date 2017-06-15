#!/usr/bin/perl

#
## Closed-form for Fibonacci numbers.
#

use utf8;
use 5.014;

use Test::More;
plan tests => 11;

use lib qw(../lib);
use Math::Bacovia qw(Power Symbol Fraction);

my $P = Power(5, '1/2');
my $S = Fraction($P + 1, 2);
my $T = $S->inv;

sub fibonacci {
    my ($n) = @_;
    Fraction(($S**$n - (-$T)**$n), $P);
}

my @fibs = qw(0 1 1 2 3 5 8 13 21 34);

foreach my $n (0 .. 9) {
    is(fibonacci($n)->numeric, shift(@fibs));
}

my $simple = fibonacci(Symbol('n', 12))->simple;

$simple->numeric eq '144'
  or die "Error in simplification!";

my $f = $simple->simple->pretty;
is($f, '((((1 + 5^(1/2))/2)^n - (-(2/(1 + 5^(1/2))))^n)/5^(1/2))');

say $f;
