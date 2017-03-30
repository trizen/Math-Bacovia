use utf8;
use 5.016;

use lib qw(
  ../lib
  ../../Math-AnyNum/lib
  );

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
