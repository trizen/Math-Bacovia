#!/usr/bin/perl

# Trigonometric functions.

use utf8;
use 5.014;

use Test::More;
plan tests => 98;

use lib qw(../lib);

use Math::AnyNum;
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

is($k->cot->acot->numeric->round(-20), -0.5);
is($k->acot->cot->numeric->round(-20), -0.5);

is($k->sin->asin->numeric->round(-20), -0.5);
is($k->asin->sin->numeric->round(-20), -0.5);

is($k->sec->asec->numeric->round(-20), 0.5);
is($k->asec->sec->numeric->round(-20), -0.5);

foreach my $method (
                    qw(
                    sin sinh asin asinh
                    cos cosh acos acosh
                    tan tanh atan atanh
                    cot coth acot acoth
                    sec sech asec asech
                    csc csch acsc acsch
                    )
  ) {

    my $n = Math::AnyNum->new(5)->rand;

    if (rand(1) < 0.5) {
        $n = -$n;
    }

#<<<
    is(Math::Bacovia::Number->new($n)->$method->numeric->round(-50)->abs,                    $n->$method->round(-50)->abs, "$method($n)");
    is(Math::Bacovia::Number->new($n)->$method->simple->numeric->round(-50)->abs,            $n->$method->round(-50)->abs, "$method($n)");
    is(Math::Bacovia::Number->new($n)->$method->simple(full => 1)->numeric->round(-50)->abs, $n->$method->round(-50)->abs, "$method($n)");
#>>>
}
