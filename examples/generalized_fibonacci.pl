#!/usr/bin/perl

# Runtime: 0.190s

use 5.014;
use lib qw(../lib);
use Math::Bacovia qw(:all);
use experimental qw(signatures);

use Test::More;

sub fibonacci ($t, $n) {
    my $a = Power($n**2 + 4, Fraction(1, 2));
    my $b = Fraction($a + Power(Power($a, 2) - 4, Fraction(1, 2)), 2);
    Fraction(Power($b, $t) - Power(-$b, -$t), $a);
}

say my $x = fibonacci(Symbol('n', 12), 1)->simple->pretty;
say my $y = fibonacci(Symbol('n', 12), Symbol('m'))->simple->pretty;

plan tests => 2;

#<<<
is($x, '((((5^(1/2) + (5^1 - 4)^(1/2))/2)^n - (-((5^(1/2) + (5^1 - 4)^(1/2))/2))^(-n))/5^(1/2))');
is($y, '(((((4 + m^2)^(1/2) + ((4 + m^2)^1 - 4)^(1/2))/2)^n - (-(((4 + m^2)^(1/2) + ((4 + m^2)^1 - 4)^(1/2))/2))^(-n))/(4 + m^2)^(1/2))');
#>>>
