# Math-Bacovia

Math::Bacovia is a symbolic math library, with support for numerical evaluation (including support for complex numbers).

# EXAMPLE

```perl
use utf8;
use 5.014;

use Math::Bacovia qw(:all);

my $x = Symbol('x');
my $y = Symbol('y');

say $x+$y;               #=> Sum(Symbol("x"), Symbol("y"))
say $x-$y;               #=> Difference(Symbol("x"), Symbol("y"))
say $x*$y;               #=> Product(Symbol("x"), Symbol("y"))
say $x/$y;               #=> Fraction(Symbol("x"), Symbol("y"))

say $x**$y;              #=> Power(Symbol("x"), Symbol("y"))

say Log($x);             #=> Log(Symbol("x"))
say Log($x)+Log($y);     #=> Log(Product(Symbol("x"), Symbol("y")))

say Exp($x);             #=> Exp(Symbol("x"))
say Exp($x)*Exp($y);     #=> Exp(Sum(Symbol("x"), Symbol("y")))


say "\n=> Sum:";
my $sum = Fraction(0, 1);

for my $n (1..10) {
    $sum += Fraction(1, $n);
}
say $sum;                     #=> Fraction(10628640, 3628800)
say $sum->numeric;            #=> 7381/2520


say "\n=> Product:";
my $prod = Product();

for my $n (1..3) {
    $prod *= Exp(Fraction(1, $n));
}

say $prod->pretty;            #=> (exp(1) * exp(1/2) * exp(1/3))
say $prod->simple->pretty;    #=> exp(11/6)
say $prod->numeric;           #=> 6.25470095193632871640207...


say "\n=> Alternative representations:";
say join ', ', Power(3, 5)->alternatives;   #=> Exp(Product(Log(3), 5)), Power(3, 5)
```


# DESCRIPTION

The types supported by this library are described bellow:

#### # `Symbol(name, value=undef)`

Represents a symbolic value. Optionally, it can have a numeric value.

#### # `Fraction(numerator, denominator)`

Represents a symbolic fraction.

#### # `Difference(minuend, subtrahend)`

Represents a symbolic subtraction.

#### # `Power(base, power)`

Represents a symbolic exponentiation in a symbolic base.

#### # `Log(x)`

Represents the natural logarithm of a symbolic value.

#### # `Exp(x)`

Represents the natural exponentiation of a symbolic value.

#### # `Sum(a, b, c, ...)`

Represents a summation of an arbitrary (finite) number of symbolic values.

#### # `Product(a, b, c, ...)`

Represents a product of an arbitrary (finite) number of symbolic values.

# SPECIAL METHODS

An interesting feature is the support for alternative representations (provided by the method `alternatives()`),
which uses common mathematical identities to create symbolically equivalent expressions from the self-expression.

Bellow we describe the special methods provided by this library:

#### # `alternatives()`

Returns an array with alternative representations from the self-expression.

```perl
say for Exp(Log(3) * 2)->alternatives;
```

Output:

```perl
Exp(Product(Log(3), 2))
Power(3, 2)
9
```

#### # `simple()`

Returns a simplification of the self-expression.

```perl
say Exp(Log(Log(Exp(Exp(Log(Symbol('x')))))))->simple;
```

Output:

```perl
Symbol("x")
```

#### # `pretty()`

Returns a human-readable stringification of the self-expression.

```perl
say Power(3, Log(Fraction(1, 2)))->pretty;
```

Output:
```ruby
3^log(1/2)
```

#### # `numeric()`

Evaluates the self-expression numerically and returns the result as a Number object.

```perl
my $x = Symbol('x');
my $expr = ($x**2 - $x + 41);

for my $n (1..3) {
    local $x->{value} = $n;
    say $expr->numeric;
}
```

Output:
```ruby
41
43
47
```

# DEPENDENCIES

Math::Bacovia requires the following modules:

* [Math::AnyNum](https://github.com/trizen/Math-AnyNum)
* [List::UtilsBy::XS](https://metacpan.org/release/List-UtilsBy-XS)

# INSTALLATION

To install this module, run the following commands:

    perl Build.PL
    ./Build
    ./Build test
    ./Build install

# SUPPORT AND DOCUMENTATION

After installing, you can find documentation for this module with the
perldoc command.

    perldoc Math::Bacovia

You can also look for information at:

    AnnoCPAN, Annotated CPAN documentation
        http://annocpan.org/dist/Math-Bacovia

    CPAN Ratings
        http://cpanratings.perl.org/d/Math-Bacovia

    Search CPAN
        http://search.cpan.org/dist/Math-Bacovia/


# LICENSE AND COPYRIGHT

Copyright (C) 2017 Daniel Șuteu

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

http://www.perlfoundation.org/artistic_license_2_0

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
