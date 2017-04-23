use utf8;
use 5.014;

use lib qw(../lib);
use ntheory qw(factorial);
use Math::Bacovia qw(:all);

#my $n = Symbol('n');
my $n = Number(100);

for my $f (((1 + 1 / $n)**$n)->alternatives) {
    say $f->pretty;
}

my $sum = Sum();
foreach my $n (0 .. 5) {
    $sum += Fraction(1, factorial($n));
    say $sum;
}
say $sum->pretty;

say exp(pi * i)->numeric;

my $prod = Product();
my $x    = Symbol('x');
foreach my $n (1 .. 3) {
    $prod *= 1 - (Power($x, 2) / (Power($n, 2) * Power(pi, 2)));
    say $prod->pretty;
}

say Difference(0,  12)->simple->pretty;
say Difference(12, 0)->simple->pretty;

say Fraction(10, 5)->simple->pretty;

say Product(3, 4)->neg * 12;
say +(Product(3, 4)->neg * 12)->pretty;
