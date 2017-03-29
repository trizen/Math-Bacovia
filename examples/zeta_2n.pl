#!/usr/bin/perl

# Closed-form for zeta(2n).

use utf8;
use 5.016;

use lib qw(
  ../lib
  ../../Math-AnyNum/lib
  );

use Math::AnyNum;
use ntheory qw(bernfrac);
use Math::Bacovia qw(tau Number Fraction);

sub bernoulli {
    my ($n) = @_;

    return 0 if $n > 1 && $n % 2;    # Bn = 0 for all odd n > 1

    my @A;
    for my $m (0 .. $n) {
        $A[$m] = Math::AnyNum->new_q(1, ($m + 1));

        for (my $j = $m ; $j > 0 ; $j--) {
            $A[$j - 1] = $j * ($A[$j - 1] - $A[$j]);
        }
    }

    return $A[0];                    # which is Bn
}

sub zeta_2n {
    my ($n)  = @_;
    my $bern = Fraction(bernfrac(2 * $n));
    my $fac  = Number(Math::AnyNum->new(2 * $n)->factorial);
    (-1)**($n + 1) * $bern * tau**(2 * $n) / ($fac * 2);
}

foreach my $n (1 .. 5) {
    say zeta_2n($n)->simple->pretty;
}

__END__
var expressions = [
    '((1 / 4) * (-4) * (1/6) * log(-1)^2)',
    '((1 / 48) * (16) * (1/30) * log(-1)^4)',
    '((1 / 1440) * (-64) * (1/42) * log(-1)^6)',
    '((1 / 80640) * (256) * (1/30) * log(-1)^8)',
    '((1 / 7257600) * (-1024) * (5/66) * log(-1)^10)',
]

assert_eq(gather {
    for n in (1..5) {
        var z = zeta_2n(n).simple.pretty
        say "zeta(#{2*n}) = #{z}"
        take(z)
    }
}, expressions)

say "** Test passed!"
