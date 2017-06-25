#!/usr/bin/perl

use 5.014;
use lib qw(../lib);
use Math::Bacovia qw(:all);

use Test::More;

plan tests => 14;

my $n = Symbol('n');

is((Power($n, 3)*Power($n, 4))->simple->pretty, 'n^7');
is((Power($n, 3)/Power($n, 4))->simple->pretty, 'n^-1');
is((Power($n, 3)*Power(42, 4))->simple->pretty, '(n^3 * 42^4)');
is((Power($n, 3)/Power(42, 4))->simple->pretty, '(n^3/42^4)');

is(Sum(0, 0, 2, 3)->pretty, '(2 + 3)');
is(Sum()->simple->pretty, '0');
is(Sum()->pretty, '(0)');

is(Sum(3, Sum(4, 5), 6)->pretty, '(3 + 6 + 4 + 5)');
is(Sum(Sum(3,4))->pretty, '(3 + 4)');

is(Product()->pretty, '(1)');
is(Product(1, 1, 2, 3)->pretty, '(2 * 3)');
is(Product()->simple->pretty, '1');

is(Product(3, Product(4, 5), 6)->pretty, '(3 * 6 * 4 * 5)');
is(Product(Product(3,4))->pretty, '(3 * 4)');
