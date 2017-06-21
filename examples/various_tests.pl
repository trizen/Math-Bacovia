#!/usr/bin/perl

use 5.014;
use lib qw(../lib);
use Math::Bacovia qw(:all);

use Test::More;

plan tests => 4;

my $n = Symbol('n');

is((Power($n, 3)*Power($n, 4))->simple->pretty, 'n^7');
is((Power($n, 3)/Power($n, 4))->simple->pretty, 'n^-1');
is((Power($n, 3)*Power(42, 4))->simple->pretty, '(n^3 * 42^4)');
is((Power($n, 3)/Power(42, 4))->simple->pretty, '(n^3/42^4)');
