use utf8;
use 5.016;

use lib qw(
  ../lib
  ../../Math-AnyNum/lib
  );

use Math::Bacovia qw(
    Log
    Exp
    Power
    Symbol
    Product
    Fraction
);

use Math::BigNum qw(:constant);

say for Power(5, 1/2)->alternatives;
say for Exp(Log(3) * 2)->alternatives;
