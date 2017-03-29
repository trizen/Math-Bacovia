package Math::Bacovia;

use 5.016;
use strict;
use warnings;

use List::UtilsBy::XS qw();
use Class::Multimethods qw();
use Math::AnyNum qw();

#~ use parent qw(Exporter);

#~ our @EXPORT_OK = qw(
#~ Number
#~ Log
#~ Exp
#~ Power
#~ Product
#~ Fraction
#~ Sum
#~ Symbol
#~ );

use constant {
              MONE => 'Math::AnyNum'->mone,
              ZERO => 'Math::AnyNum'->zero,
              ONE  => 'Math::AnyNum'->one,
             };

use Math::Bacovia::Utils;
use Math::Bacovia::Exp;
use Math::Bacovia::Log;
use Math::Bacovia::Power;
use Math::Bacovia::Fraction;
use Math::Bacovia::Number;
use Math::Bacovia::Sum;
use Math::Bacovia::Product;
use Math::Bacovia::Symbol;

=head1 NAME

Math::Bacovia - Symbolic math library.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

B<Math::Bacovia> is symbolic math library, with support for evaluating expressions numerically.

    use 5.016;
    use Math::Bacovia;

    my $n = Math::Bacovia::Symbol->new(n => 42);

    say cos(-$n);
    say cos(-$n)->simple;
    say cos(-$n)->pretty;
    say cos(-$n)->numeric;
    say cos(-$n)->alternatives;

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=cut

use overload
  '""' => sub { $_[0]->stringify },
  '0+' => sub { $_[0]->numeric },

  '==' => sub { $_[0]->eq($_[1]) },
  '!=' => sub { !($_[0]->eq($_[1])) },

  '++' => sub { $_[0]->add(ONE) },
  '--' => sub { $_[0]->sub(ONE) },

  '+'  => sub { $_[2] ? 'Math::Bacovia::Number'->new($_[1])->add($_[0]) : $_[0]->add($_[1]) },
  '-'  => sub { $_[2] ? 'Math::Bacovia::Number'->new($_[1])->sub($_[0]) : $_[0]->sub($_[1]) },
  '*'  => sub { $_[2] ? 'Math::Bacovia::Number'->new($_[1])->mul($_[0]) : $_[0]->mul($_[1]) },
  '/'  => sub { $_[2] ? 'Math::Bacovia::Number'->new($_[1])->div($_[0]) : $_[0]->div($_[1]) },
  '**' => sub { $_[2] ? 'Math::Bacovia::Number'->new($_[1])->pow($_[0]) : $_[0]->pow($_[1]) },

  #atan2 => sub { Math::AnyNum::atan2($_[2] ? (__PACKAGE__->new($_[1]), $_[0]) : ($_[0]->copy, $_[1])) },

  eq => sub { "$_[0]" eq "$_[1]" },
  ne => sub { "$_[0]" ne "$_[1]" },

  cmp => sub { $_[2] ? "$_[1]" cmp $_[0]->stringify : $_[0]->stringify cmp "$_[1]" },

  neg => \&neg,
  sin => \&sin,
  cos => \&cos,
  exp => \&exp,
  log => \&log,
  int => \&int,

  #abs  => \&abs,
  sqrt => \&sqrt;

#
## Import/export
#

use constant i => 'Math::Bacovia::Number'->new('Math::AnyNum'->i);

my %exported_functions = (
                          Exp      => \&Exp,
                          Log      => \&Log,
                          Product  => \&Product,
                          Sum      => \&Sum,
                          Power    => \&Power,
                          Symbol   => \&Symbol,
                          Number   => \&Number,
                          Fraction => \&Fraction,
                         );

my %exported_constants = (
    i  => \&i,
    pi => sub {
        'Math::Bacovia::Log'->new('Math::Bacovia::Number'->new(MONE)) * -i;
    },
    tau => sub {
        'Math::Bacovia::Log'->new('Math::Bacovia::Number'->new(MONE)) * -(i + i);
    },
    e => sub {
        'Math::Bacovia::Exp'->new('Math::Bacovia::Number'->new(ONE));
    },
);

sub import {
    shift;

    my $caller = caller(0);

    while (@_) {
        my $name = shift(@_);

        no strict 'refs';
        my $caller_sub = $caller . '::' . $name;
        if (exists $exported_functions{$name}) {
            my $sub = $exported_functions{$name};
            *$caller_sub = $exported_functions{$name};
        }
        elsif (exists $exported_constants{$name}) {
            my $value = $exported_constants{$name}->();
            *$caller_sub = sub() { $value };
        }
        else {
            die "unknown import: <<$name>>";
        }
    }

    return;
}

=head1 METHODS

=cut

use Math::AnyNum qw(:constant);

sub Log {
    'Math::Bacovia::Log'->new(@_);
}

sub Exp {
    'Math::Bacovia::Exp'->new(@_);
}

sub Fraction {
    'Math::Bacovia::Fraction'->new(@_);
}

sub Power {
    'Math::Bacovia::Power'->new(@_);
}

sub Sum {
    'Math::Bacovia::Sum'->new(@_);
}

sub Product {
    'Math::Bacovia::Product'->new(@_);
}

sub Symbol {
    'Math::Bacovia::Symbol'->new(@_);
}

sub Number {
    'Math::Bacovia::Number'->new(@_);
}

#
## BASIC OPERATIONS
#

Class::Multimethods::multimethod add => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;
    'Math::Bacovia::Sum'->new($x, $y);
};

Class::Multimethods::multimethod sub => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;
    'Math::Bacovia::Sum'->new($x, $y->neg);
};

Class::Multimethods::multimethod mul => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;
    'Math::Bacovia::Product'->new($x, $y);
};

Class::Multimethods::multimethod div => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;
    'Math::Bacovia::Fraction'->new($x, $y);
};

Class::Multimethods::multimethod pow => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;
    'Math::Bacovia::Power'->new($x, $y);
};

Class::Multimethods::multimethod add => (__PACKAGE__, '*') => sub {
    my ($x, $y) = @_;
    $x + 'Math::Bacovia::Number'->new($y);
};

Class::Multimethods::multimethod sub => (__PACKAGE__, '*') => sub {
    my ($x, $y) = @_;
    $x - 'Math::Bacovia::Number'->new($y);
};

Class::Multimethods::multimethod mul => (__PACKAGE__, '*') => sub {
    my ($x, $y) = @_;
    $x * 'Math::Bacovia::Number'->new($y);
};

Class::Multimethods::multimethod div => (__PACKAGE__, '*') => sub {
    my ($x, $y) = @_;
    $x / 'Math::Bacovia::Number'->new($y);
};

Class::Multimethods::multimethod pow => (__PACKAGE__, '*') => sub {
    my ($x, $y) = @_;
    $x**('Math::Bacovia::Number'->new($y));
};

Class::Multimethods::multimethod add => ('*', __PACKAGE__) => sub {
    my ($x, $y) = @_;
    'Math::Bacovia::Number'->new($x) + $y;
};

Class::Multimethods::multimethod sub => ('*', __PACKAGE__) => sub {
    my ($x, $y) = @_;
    'Math::Bacovia::Number'->new($x) - $y;
};

Class::Multimethods::multimethod mul => ('*', __PACKAGE__) => sub {
    my ($x, $y) = @_;
    'Math::Bacovia::Number'->new($x) * $y;
};

Class::Multimethods::multimethod div => ('*', __PACKAGE__) => sub {
    my ($x, $y) = @_;
    'Math::Bacovia::Number'->new($x) / $y;
};

Class::Multimethods::multimethod pow => ('*', __PACKAGE__) => sub {
    my ($x, $y) = @_;
    ('Math::Bacovia::Number'->new($x))**$y;
};

sub int {
    my ($x) = @_;
    CORE::int($x->numeric);
}

sub sqrt {
    my ($x) = @_;
    $x**(1 / 2);
}

sub log {
    my ($x) = @_;
    'Math::Bacovia::Log'->new($x);
}

sub exp {
    my ($x) = @_;
    'Math::Bacovia::Exp'->new($x);
}

sub neg {
    my ($x) = @_;
    'Math::Bacovia::Product'->new(-1, $x);
}

sub inv {
    my ($x) = @_;
    'Math::Bacovia::Fraction'->new(1, $x);
}

#
## TRIGONOMETRIC FUNCTIONS
#

=head2 sin

Sinus of a symbolic expression.

=cut

sub sin {
    my ($x) = @_;
    'Math::Bacovia::Fraction'->new('Math::Bacovia::Exp'->new(i * $x) - 'Math::Bacovia::Exp'->new(-i * $x), 2 * i);
}

# asin(x) = -i log(i x + &sqrt(1 - x^2))
sub asin {
    my ($x) = @_;
    -i * 'Math::Bacovia::Log'->new(i * $x + &sqrt(1 - $x**2));
}

# sinh(x) = (exp(2x) - 1) / (2*exp(x))
sub sinh {
    my ($x) = @_;
    'Math::Bacovia::Fraction'->new(('Math::Bacovia::Exp'->new(2 * $x) - 1), (2 * 'Math::Bacovia::Exp'->new($x)));
}

# asinh(x) = log(&sqrt(x^2 + 1) + x)
sub asinh {
    my ($x) = @_;
    'Math::Bacovia::Log'->new(&sqrt($x**2 + 1) + $x);
}

# cos(x) = (exp(-i*x) + exp(i*x)) / 2
sub cos {
    my ($x) = @_;
    'Math::Bacovia::Fraction'->new('Math::Bacovia::Exp'->new(-i * $x) + 'Math::Bacovia::Exp'->new(i * $x), 2);
}

# acos(x) = π/2 + i log(i x + &sqrt(1 - x^2))
sub acos {
    my ($x) = @_;
    'Math::Bacovia::Log'->new(i) * -i + i * 'Math::Bacovia::Log'->new(i * $x + &sqrt(1 - $x**2));
}

# cosh(x) = (exp(2x) + 1) / (2*exp(x))
sub cosh {
    my ($x) = @_;
    'Math::Bacovia::Fraction'->new(('Math::Bacovia::Exp'->new(2 * $x) + 1), (2 * 'Math::Bacovia::Exp'->new($x)));
}

# acosh(x) = log(&sqrt(x^2 - 1) + x)
sub acosh {
    my ($x) = @_;
    'Math::Bacovia::Log'->new($x + &sqrt($x - 1) * &sqrt($x + 1));
}

# tan(x) = -i + (2*i)/(1 + exp(2*i*x))
sub tan {
    my ($x) = @_;
    -i + 'Math::Bacovia::Fraction'->new(2 * i, 1 + 'Math::Bacovia::Exp'->new(2 * i * $x));
}

# atan(x) = -i log((1 + i x)/&sqrt(1 + x^2))
sub atan {
    my ($x) = @_;
    -i * 'Math::Bacovia::Log'->new('Math::Bacovia::Fraction'->new(1 + i * $x, &sqrt(1 + $x**2)));
}

# tanh(x) = (exp(2x) - 1) / (exp(2x) + 1)
sub tanh {
    my ($x) = @_;
    'Math::Bacovia::Fraction'->new(('Math::Bacovia::Exp'->new(2 * $x) - 1), ('Math::Bacovia::Exp'->new(2 * $x) + 1));
}

# atanh(x) = log(&sqrt(1 + x)/&sqrt(1 - x))
sub atanh {
    my ($x) = @_;
    'Math::Bacovia::Log'->new(&sqrt(1 + $x) / &sqrt(1 - $x));
}

# cot(x) = i + (2*i)/(-1 + exp(2*i*x))
sub cot {
    my ($x) = @_;
    i + 'Math::Bacovia::Fraction'->new(2 * i, -1 + 'Math::Bacovia::Exp'->new(2 * i * $x));
}

# acot(x) = i*(log((-i + x)/x) - log((i + x)/x))/2
sub acot {
    my ($x) = @_;
    'Math::Bacovia::Fraction'->new(
                                   i * (
                                        'Math::Bacovia::Log'->new('Math::Bacovia::Fraction'->new(-i + $x, $x)) -
                                          'Math::Bacovia::Log'->new('Math::Bacovia::Fraction'->new(i + $x, $x))
                                       ),
                                   2
                                  );
}

# coth(x) = (exp(2x) + 1) / (exp(2x) - 1)
sub coth {
    my ($x) = @_;
    'Math::Bacovia::Fraction'->new(('Math::Bacovia::Exp'->new(2 * $x) + 1), ('Math::Bacovia::Exp'->new(2 * $x) - 1));
}

# acoth(x) = (-log((-1 + x)/x) + log((1 + x)/x))/2
sub acoth {
    my ($x) = @_;
    'Math::Bacovia::Fraction'->new(
                                   'Math::Bacovia::Log'->new(
                                        'Math::Bacovia::Fraction'->new($x + 1, $x) / 'Math::Bacovia::Fraction'->new($x - 1, $x)
                                   ),
                                   2
                                  )

      #'Math::Bacovia::Log'->new(&sqrt('Math::Bacovia::Fraction'->new($x + 1, $x - 1)))
}

# sec(x) = 2/(exp(-i*x) + exp(i*x))
sub sec {
    my ($x) = @_;
    'Math::Bacovia::Fraction'->new(2, 'Math::Bacovia::Exp'->new(-i * $x) + 'Math::Bacovia::Exp'->new(i * $x));
}

# asec(x) = π/2 + i log(i/x + &sqrt(1 - 1/x^2))
sub asec {
    my ($x) = @_;
    my $inv = $x->inv;
    'Math::Bacovia::Log'->new(i) * -i + i * 'Math::Bacovia::Log'->new(i * $inv + &sqrt(1 - $inv**2));
}

# sech(x) = (2*exp(x)) / (exp(2x) + 1)
sub sech {
    my ($x) = @_;
    'Math::Bacovia::Fraction'->new((2 * 'Math::Bacovia::Exp'->new($x)), ('Math::Bacovia::Exp'->new(2 * $x) + 1));
}

# asech(x) = log(1/x + &sqrt(-1 + 1/x) &sqrt(1 + 1/x))
sub asech {
    my ($x) = @_;
    my $inv = $x->inv;
    'Math::Bacovia::Log'->new($inv + &sqrt($inv - 1) * &sqrt($inv + 1));
}

# csc(x) = -(2*i)/(exp(-i*x) - exp(i*x))
sub csc {
    my ($x) = @_;
    'Math::Bacovia::Fraction'->new(-2 * i, 'Math::Bacovia::Exp'->new(-i * $x) - 'Math::Bacovia::Exp'->new(i * $x));
}

# acsc(x) = -i log(i/x + &sqrt(1 - 1/x^2))
sub acsc {
    my ($x) = @_;
    -i * 'Math::Bacovia::Log'->new('Math::Bacovia::Fraction'->new(i, $x) + &sqrt(1 - (($x**2)->inv)));
}

# csch(x) = (2*exp(x)) / (exp(2x) - 1)
sub csch {
    my ($x) = @_;
    'Math::Bacovia::Fraction'->new((2 * 'Math::Bacovia::Exp'->new($x)), ('Math::Bacovia::Exp'->new(2 * $x) - 1));
}

# acsch(x) = log(1/x + &sqrt(1 + 1/x^2))
sub acsch {
    my ($x) = @_;
    'Math::Bacovia::Log'->new($x->inv + &sqrt(1 + (($x**2)->inv)));
}

#
## SIMPLIFICATION
#

sub simple {
    my ($x) = @_;
    (
     List::UtilsBy::XS::min_by {
         length($_->pretty)
     }
     ($x->alternatives)
    )[0];
}

sub alternatives {
    ($_[0]);
}

=head1 AUTHOR

Daniel Șuteu, C<< <trizenx at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to L<https://github.com/trizen/Math-Bacovia>.
I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Math::Bacovia


You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Math-Bacovia>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Math-Bacovia>

=item * Search CPAN

L<http://search.cpan.org/dist/Math-Bacovia/>

=item * GitHub

L<https://github.com/trizen/Math-Bacovia>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2017 Daniel Șuteu.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

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


=cut

1;    # End of Math::Bacovia
