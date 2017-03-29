use utf8;
use 5.016;

use lib qw(
  ../lib
  ../../Math-AnyNum/lib
  );

use Math::Bacovia qw(:all);

say 1 + Fraction(3, 4);
say 1 - Fraction(3, 4);

__END__
use Math::BigNum qw(:constant);




say for Power(5, 1/2)->alternatives;
say for Exp(Log(3) * 2)->alternatives;

say ref(i);
say +(i**2);

my $x = Symbol('x', 43);
say $x->tanh->numeric;
#say ${$x->tanh->numeric};

__END__
say ((+$x)->tanh->atanh -> numeric);
