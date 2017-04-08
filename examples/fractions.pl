#!/usr/bin/perl

#
## Closed-form for Fibonacci numbers.
#

use utf8;
use 5.016;

use Test::More;
plan tests => 12;

use lib qw(../lib);
use Math::Bacovia qw(Fraction);

is(1 + Fraction(3, 4), Fraction(7,  4));
is(1 - Fraction(3, 4), Fraction(1,  4));
is(3 * Fraction(3, 4), Fraction(9,  4));
is(7 / Fraction(3, 4), Fraction(28, 3));

is(Fraction(3, 4) + 1, Fraction(7, 4));
is(-Fraction(3, 4) + 1, Fraction(1, 4));
is(Fraction(3, 4) * 3, Fraction(9, 4));
is(1 / Fraction(3, 4) * 7, Fraction(28, 3));

is(Fraction(5,  7) + Fraction(2, 3), Fraction(29, 21));
is(Fraction(13, 7) - Fraction(2, 3), Fraction(25, 21));
is(Fraction(3,  5) * Fraction(7, 3), Fraction(21, 15));
is(Fraction(3,  5) / Fraction(7, 3), Fraction(9,  35));
