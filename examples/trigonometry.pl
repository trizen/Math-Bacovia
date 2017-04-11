#!/usr/bin/perl

# Trigonometric functions.

use utf8;
use 5.016;

use Test::More;
plan tests => 20;

use lib qw(../lib);
use Math::Bacovia qw(:all);

my $x = Symbol('x', +43);
my $y = Symbol('y', -43);
my $z = Symbol('z', 1.5);
my $k = Symbol('k', -0.5);

say "cosh(log(x)) = ", Log($x)->cosh->simple->pretty;
say "sinh(log(x)) = ", Log($x)->sinh->simple->pretty;
say "tanh(log(x)) = ", Log($x)->tanh->simple->pretty;

is(Log($x)->cosh->simple, Fraction(Sum(1, Power(Symbol("x", 43), 2)), Product(2, Symbol("x", 43))));

is((sin(+$z))->asin->numeric->round(-20), +1.5);
is((sin(-$z))->asin->numeric->round(-20), -1.5);

is((cos(+$z))->acos->numeric->round(-20), +1.5);
is((cos(-$z))->acos->numeric->round(-20), +1.5);

is((+$x)->tanh->atanh->simple->numeric->round(-20), +43);
is((-$x)->tanh->atanh->simple->numeric->round(-20), -43);
is((+$y)->tanh->atanh->simple->numeric->round(-20), -43);

is((+$x)->cosh->acosh->simple->numeric, +43);
is((-$x)->cosh->acosh->simple->numeric, +43);
is((+$y)->cosh->acosh->simple->numeric, +43);

is((+$x)->sinh->asinh->numeric,             +43);
is((-$x)->sinh->asinh->numeric->round(-20), -43);
is((+$y)->sinh->asinh->numeric->round(-20), -43);

is(($k)->sinh->asinh->numeric->round(-20), -0.5);
is(($k)->tanh->atanh->numeric->round(-20), -0.5);
is(($k)->csch->acsch->numeric->round(-20), -0.5);
is(($k)->coth->acoth->numeric->round(-20), -0.5);
is(($k)->cosh->acosh->numeric->round(-20), 0.5);
is(($k)->sech->asech->numeric->round(-20), 0.5);
