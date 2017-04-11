#!/usr/bin/perl

use utf8;
use 5.016;

use Test::More;
plan tests => 13;

use lib qw(../lib);
use Math::Bacovia qw(Fraction Log Exp Product Difference);

is(1 - Difference(3, 4), Difference(5, 3));
is(-(1 - Difference(3, 4)), Difference(3, 5));

is(Difference(3, 4)->inv, Fraction(1, Difference(3, 4)));
is(Fraction(3, 4)->neg, Difference(0, Fraction(3, 4)));
is(Difference(1, 2)/Difference(3, 4), Fraction(Difference(1, 2), Difference(3, 4)));

is(Fraction(3, 4)-5, Fraction(-17, 4));
is(5-Fraction(3, 4), Difference(5, Fraction(3, 4)));

is(Fraction(Fraction(3,2), Fraction(4,12))-5, Fraction(Fraction(-4, 24), Fraction(4, 12)));
is(5-Fraction(Fraction(3,2), Fraction(4,12)), Difference(5, Fraction(Fraction(3, 2), Fraction(4, 12))));

is(5-Fraction(Log(3), Exp(4)), Difference(5, Fraction(Log(3), Exp(4))));
is(Fraction(Log(3), Exp(4))-5, Fraction(Difference(Log(3), Product(Exp(4), 5)), Exp(4)));

is(Exp(12)-Fraction(3,4), Difference(Exp(12), Fraction(3, 4)));
is(Fraction(3,4)-Exp(12), Difference(Fraction(3, 4), Exp(12)));
