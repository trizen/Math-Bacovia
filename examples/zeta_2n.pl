#!/usr/bin/perl

# Closed-form for zeta(2n).

use utf8;
use 5.014;

use lib qw(../lib);
use Math::AnyNum;
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
    my $bern = Number(bernoulli(2 * $n));
    my $fac  = Number(Math::AnyNum->new(2 * $n)->factorial);
    (-1)**($n + 1) * $bern * tau**(2 * $n) / ($fac * 2);
}

foreach my $n (1 .. 5) {
    say zeta_2n($n)->simple->pretty;
}
