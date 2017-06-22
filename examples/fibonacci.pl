#!/usr/bin/perl

#
## Closed-form for Fibonacci numbers.
#

use utf8;
use 5.014;

use Test::More;
plan tests => 11;

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

$simple->numeric->round(-30) eq '144'
  or die "Error in simplification!";

my $f = $simple->simple->pretty;
is($f, '((((1 + 5^(1/2))/2)^n - ((((-1)^n + exp((-1 * log(-1) * n)))/2) * (2/(1 + 5^(1/2)))^n))/5^(1/2))');

say $f;
