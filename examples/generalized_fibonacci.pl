#!/usr/bin/perl

# Runtime: 0.226s

use 5.014;
use lib qw(../lib);
use Math::Bacovia qw(:all);
use experimental qw(signatures);

sub fibonacci($t, $n) {
    my $a = Power($n**2 + 4, Fraction(1, 2));
    my $b = Fraction($a + Power(Power($a, 2) - 4, Fraction(1, 2)), 2);
    Fraction(Power($b, $t) - Power(-$b, -$t), $a);
}

say fibonacci(Symbol('n', 12), 1)->simple->pretty;
say fibonacci(Symbol('n', 12), Symbol('m'))->pretty;

__END__
((((5^(1/2) + (5^1 - 4)^(1/2))/2)^n - (-((5^(1/2) + (5^1 - 4)^(1/2))/2))^(-n))/5^(1/2))
(((((m^2 + 4)^(1/2) + (((m^2 + 4)^(1/2))^2 - 4)^(1/2))/2)^n - (-(((m^2 + 4)^(1/2) + (((m^2 + 4)^(1/2))^2 - 4)^(1/2))/2))^(-n))/(m^2 + 4)^(1/2))
