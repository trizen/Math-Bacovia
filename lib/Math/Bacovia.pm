package Math::Bacovia;

use 5.014;
use strict;
use warnings;

use List::UtilsBy::XS qw();
use Class::Multimethods qw();
use Math::AnyNum qw();

use constant {
              MONE => 'Math::AnyNum'->mone,
              ZERO => 'Math::AnyNum'->zero,
              ONE  => 'Math::AnyNum'->one,
             };

our %HIERARCHY = (
                  'Math::Bacovia::Number'     => 0,
                  'Math::Bacovia::Difference' => 1,
                  'Math::Bacovia::Fraction'   => 2,
                  'Math::Bacovia::Power'      => 3,
                  'Math::Bacovia::Log'        => 4,
                  'Math::Bacovia::Exp'        => 5,
                  'Math::Bacovia::Sum'        => 6,
                  'Math::Bacovia::Product'    => 7,
                  'Math::Bacovia::Symbol'     => 8,
                 );

use Math::Bacovia::Utils;
use Math::Bacovia::Exp;
use Math::Bacovia::Log;
use Math::Bacovia::Power;
use Math::Bacovia::Fraction;
use Math::Bacovia::Difference;
use Math::Bacovia::Number;
use Math::Bacovia::Sum;
use Math::Bacovia::Product;
use Math::Bacovia::Symbol;

=encoding utf8

=head1 NAME

Math::Bacovia - Symbolic math library.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

B<Math::Bacovia> is symbolic math library, with support for evaluating expressions numerically.

    use 5.014;
    use Math::Bacovia qw(Symbol);

    my $n = Symbol(n => 42);

    say cos(-$n);
    say cos(-$n)->simple;
    say cos(-$n)->pretty;
    say cos(-$n)->numeric;
    say cos(-$n)->alternatives;

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=cut

our $MONE = 'Math::Bacovia::Number'->new(MONE);
our $ZERO = 'Math::Bacovia::Number'->new(ZERO);
our $ONE  = 'Math::Bacovia::Number'->new(ONE);
our $TWO  = 'Math::Bacovia::Number'->new(ONE + ONE);
our $HALF = 'Math::Bacovia::Number'->new(ONE / (ONE + ONE));

use overload
  '""' => sub { $_[0]->stringify },
  '0+' => sub { $_[0]->numeric },

  '==' => sub {
    my ($x, $y) = @_;

    Math::Bacovia::Utils::check_type(\$y);

    $x->eq($y);
  },

  '!=' => sub {
    my ($x, $y) = @_;

    Math::Bacovia::Utils::check_type(\$y);

    !($x->eq($y));
  },

  '++' => sub { $_[0]->add($ONE) },
  '--' => sub { $_[0]->sub($ONE) },

  '+' => sub {
    my ($x, $y, $s) = @_;

    Math::Bacovia::Utils::check_type(\$x);
    Math::Bacovia::Utils::check_type(\$y);

    $s ? $y->add($x) : $x->add($y);
  },
  '-' => sub {
    my ($x, $y, $s) = @_;

    Math::Bacovia::Utils::check_type(\$x);
    Math::Bacovia::Utils::check_type(\$y);

    $s ? $y->sub($x) : $x->sub($y);
  },
  '*' => sub {
    my ($x, $y, $s) = @_;

    Math::Bacovia::Utils::check_type(\$x);
    Math::Bacovia::Utils::check_type(\$y);

    $s ? $y->mul($x) : $x->mul($y);
  },
  '/' => sub {
    my ($x, $y, $s) = @_;

    Math::Bacovia::Utils::check_type(\$x);
    Math::Bacovia::Utils::check_type(\$y);

    $s ? $y->div($x) : $x->div($y);
  },
  '**' => sub {
    my ($x, $y, $s) = @_;

    Math::Bacovia::Utils::check_type(\$x);
    Math::Bacovia::Utils::check_type(\$y);

    $s ? $y->pow($x) : $x->pow($y);
  },

  eq => sub { "$_[0]" eq "$_[1]" },
  ne => sub { "$_[0]" ne "$_[1]" },

  cmp => sub { $_[2] ? "$_[1]" cmp $_[0]->stringify : $_[0]->stringify cmp "$_[1]" },
  neg => sub { $_[0]->neg },

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

sub i() {
    state $x = 'Math::Bacovia::Number'->new('Math::AnyNum'->i);
}

my %exported_functions = (
                          Exp        => \&_exp,
                          Log        => \&_log,
                          Product    => \&_product,
                          Sum        => \&_sum,
                          Power      => \&_power,
                          Symbol     => \&_symbol,
                          Number     => \&_number,
                          Fraction   => \&_fraction,
                          Difference => \&_difference,
                         );

my %exported_constants = (
    i  => \&i,
    pi => sub {
        'Math::Bacovia::Log'->new($MONE) * -i;
    },
    tau => sub {
        'Math::Bacovia::Log'->new($MONE) * -(i + i);
    },
    e => sub {
        'Math::Bacovia::Exp'->new($ONE);
    },
);

sub import {
    shift;

    my $caller = caller(0);

    while (@_) {
        my $name = shift(@_);

        if ($name eq ':all') {
            push @_, keys(%exported_functions), keys(%exported_constants);
            next;
        }

        no strict 'refs';
        my $caller_sub = $caller . '::' . $name;
        if (exists($exported_functions{$name})) {
            my $sub = $exported_functions{$name};
            *$caller_sub = $exported_functions{$name};
        }
        elsif (exists($exported_constants{$name})) {
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

sub _log {
    'Math::Bacovia::Log'->new(@_);
}

sub _exp {
    'Math::Bacovia::Exp'->new(@_);
}

sub _fraction {
    'Math::Bacovia::Fraction'->new(@_);
}

sub _difference {
    'Math::Bacovia::Difference'->new(@_);
}

sub _power {
    'Math::Bacovia::Power'->new(@_);
}

sub _sum {
    'Math::Bacovia::Sum'->new(@_);
}

sub _product {
    'Math::Bacovia::Product'->new(@_);
}

sub _symbol {
    'Math::Bacovia::Symbol'->new(@_);
}

sub _number {
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
    'Math::Bacovia::Difference'->new($x, $y);
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
    $x->{_int} //= CORE::int($x->numeric);
}

sub sqrt {
    my ($x) = @_;
    $x->{_sqrt} //= $x**$HALF;
}

sub log {
    my ($x) = @_;
    $x->{_log} //= 'Math::Bacovia::Log'->new($x);
}

sub exp {
    my ($x) = @_;
    $x->{_exp} //= 'Math::Bacovia::Exp'->new($x);
}

sub neg {
    my ($x) = @_;
    $x->{_neg} //= 'Math::Bacovia::Difference'->new($ZERO, $x);
}

sub inv {
    my ($x) = @_;
    $x->{_inv} //= 'Math::Bacovia::Fraction'->new($ONE, $x);
}

#
## TRIGONOMETRIC FUNCTIONS
#

=head2 sin

Sinus of a symbolic expression.

=cut

sub sin {
    my ($x) = @_;
    $x->{_sin} //=
      'Math::Bacovia::Fraction'->new('Math::Bacovia::Exp'->new(i * $x) - 'Math::Bacovia::Exp'->new(-i * $x), $TWO * i);
}

# asin(x) = -i log(i x + &sqrt(1 - x^2))
sub asin {
    my ($x) = @_;
    $x->{_asin} //= -i * 'Math::Bacovia::Log'->new(i * $x + &sqrt($ONE - $x**$TWO));
}

# sinh(x) = (exp(2x) - 1) / (2*exp(x))
sub sinh {
    my ($x) = @_;
    $x->{_sinh} //=
      'Math::Bacovia::Fraction'->new(('Math::Bacovia::Exp'->new($TWO * $x) + $MONE), ($TWO * 'Math::Bacovia::Exp'->new($x)));
}

# asinh(x) = log(&sqrt(x^2 + 1) + x)
sub asinh {
    my ($x) = @_;
    $x->{_asinh} //= 'Math::Bacovia::Log'->new(&sqrt($x**$TWO + $ONE) + $x);
}

# cos(x) = (exp(-i*x) + exp(i*x)) / 2
sub cos {
    my ($x) = @_;
    $x->{_cos} //=
      'Math::Bacovia::Fraction'->new('Math::Bacovia::Exp'->new(-i * $x) + 'Math::Bacovia::Exp'->new(i * $x), $TWO);
}

# acos(x) = π/2 + i log(i x + &sqrt(1 - x^2))
sub acos {
    my ($x) = @_;
    $x->{_acos} //= 'Math::Bacovia::Log'->new(i) * -i + i * 'Math::Bacovia::Log'->new(i * $x + &sqrt($ONE - $x**$TWO));
}

# cosh(x) = (exp(2x) + 1) / (2*exp(x))
sub cosh {
    my ($x) = @_;
    $x->{_cosh} //=
      'Math::Bacovia::Fraction'->new(('Math::Bacovia::Exp'->new($TWO * $x) + $ONE), ($TWO * 'Math::Bacovia::Exp'->new($x)));
}

# acosh(x) = log(&sqrt(x^2 - 1) + x)
sub acosh {
    my ($x) = @_;
    $x->{_acosh} //= 'Math::Bacovia::Log'->new($x + &sqrt($x + $MONE) * &sqrt($x + $ONE));
}

# tan(x) = -i + (2*i)/(1 + exp(2*i*x))
sub tan {
    my ($x) = @_;
    $x->{_tan} //= -i + 'Math::Bacovia::Fraction'->new($TWO * i, $ONE + 'Math::Bacovia::Exp'->new($TWO * i * $x));
}

# atan(x) = -i log((1 + i x)/&sqrt(1 + x^2))
sub atan {
    my ($x) = @_;
    $x->{_atan} //= -i * 'Math::Bacovia::Log'->new('Math::Bacovia::Fraction'->new($ONE + i * $x, &sqrt($ONE + $x**$TWO)));
}

# tanh(x) = (exp(2x) - 1) / (exp(2x) + 1)
sub tanh {
    my ($x) = @_;
    $x->{_tanh} //= 'Math::Bacovia::Fraction'->new(('Math::Bacovia::Exp'->new($TWO * $x) + $MONE),
                                                   ('Math::Bacovia::Exp'->new($TWO * $x) + $ONE));
}

# atanh(x) = log(&sqrt(1 + x)/&sqrt(1 - x))
sub atanh {
    my ($x) = @_;
    $x->{_atanh} //= 'Math::Bacovia::Log'->new(&sqrt($ONE + $x) / &sqrt($ONE - $x));
}

# cot(x) = i + (2*i)/(-1 + exp(2*i*x))
sub cot {
    my ($x) = @_;
    $x->{_cot} //= i + 'Math::Bacovia::Fraction'->new($TWO * i, $MONE + 'Math::Bacovia::Exp'->new($TWO * i * $x));
}

# acot(x) = i*(log((-i + x)/x) - log((i + x)/x))/2
sub acot {
    my ($x) = @_;
    $x->{_acot} //= 'Math::Bacovia::Fraction'->new(
                                                   i * (
                                                        'Math::Bacovia::Log'->new('Math::Bacovia::Fraction'->new(-i + $x, $x))
                                                          - 'Math::Bacovia::Log'
                                                          ->new('Math::Bacovia::Fraction'->new(i + $x, $x))
                                                       ),
                                                   $TWO
                                                  );
}

# coth(x) = (exp(2x) + 1) / (exp(2x) - 1)
sub coth {
    my ($x) = @_;
    $x->{_coth} //= 'Math::Bacovia::Fraction'->new(('Math::Bacovia::Exp'->new($TWO * $x) + $ONE),
                                                   ('Math::Bacovia::Exp'->new($TWO * $x) + $MONE));
}

# acoth(x) = (-log((-1 + x)/x) + log((1 + x)/x))/2
sub acoth {
    my ($x) = @_;
    $x->{_acoth} //= 'Math::Bacovia::Fraction'->new(
                                                    'Math::Bacovia::Log'->new(
                                                                              'Math::Bacovia::Fraction'->new($x + $ONE, $x) /
                                                                                'Math::Bacovia::Fraction'->new($x + $MONE, $x)
                                                                             ),
                                                    $TWO
                                                   );

    #'Math::Bacovia::Log'->new(&sqrt('Math::Bacovia::Fraction'->new($x + 1, $x - 1)))
}

# sec(x) = 2/(exp(-i*x) + exp(i*x))
sub sec {
    my ($x) = @_;
    $x->{_sec} //=
      'Math::Bacovia::Fraction'->new($TWO, 'Math::Bacovia::Exp'->new(-i * $x) + 'Math::Bacovia::Exp'->new(i * $x));
}

# asec(x) = π/2 + i log(i/x + &sqrt(1 - 1/x^2))
sub asec {
    my ($x) = @_;
    my $inv = $x->inv;
    $x->{_asec} //= 'Math::Bacovia::Log'->new(i) * -i + i * 'Math::Bacovia::Log'->new(i * $inv + &sqrt($ONE - $inv**$TWO));
}

# sech(x) = (2*exp(x)) / (exp(2x) + 1)
sub sech {
    my ($x) = @_;
    $x->{_sech} //=
      'Math::Bacovia::Fraction'->new(($TWO * 'Math::Bacovia::Exp'->new($x)), ('Math::Bacovia::Exp'->new($TWO * $x) + $ONE));
}

# asech(x) = log(1/x + &sqrt(-1 + 1/x) &sqrt(1 + 1/x))
sub asech {
    my ($x) = @_;
    my $inv = $x->inv;
    $x->{_asech} //= 'Math::Bacovia::Log'->new($inv + &sqrt($inv + $MONE) * &sqrt($inv + $ONE));
}

# csc(x) = -(2*i)/(exp(-i*x) - exp(i*x))
sub csc {
    my ($x) = @_;
    $x->{_csc} //=
      'Math::Bacovia::Fraction'->new(-$TWO * i, 'Math::Bacovia::Exp'->new(-i * $x) - 'Math::Bacovia::Exp'->new(i * $x));
}

# acsc(x) = -i log(i/x + &sqrt(1 - 1/x^2))
sub acsc {
    my ($x) = @_;
    $x->{_acsc} //= -i * 'Math::Bacovia::Log'->new('Math::Bacovia::Fraction'->new(i, $x) + &sqrt($ONE - (($x**$TWO)->inv)));
}

# csch(x) = (2*exp(x)) / (exp(2x) - 1)
sub csch {
    my ($x) = @_;
    $x->{_csch} //=
      'Math::Bacovia::Fraction'->new(($TWO * 'Math::Bacovia::Exp'->new($x)), ('Math::Bacovia::Exp'->new($TWO * $x) - $ONE));
}

# acsch(x) = log(1/x + &sqrt(1 + 1/x^2))
sub acsch {
    my ($x) = @_;
    $x->{_acsch} //= 'Math::Bacovia::Log'->new($x->inv + &sqrt($ONE + (($x**$TWO)->inv)));
}

sub simple {
    my ($x, %opt) = @_;
    $x->{_simple} //= ((List::UtilsBy::XS::min_by { length($_->pretty) } ($x->alternatives(%opt)))[0]);
}

sub expand {
    my ($x, %opt) = @_;
    $x->{_expand} //= ((List::UtilsBy::XS::max_by { length($_->pretty) } ($x->alternatives(%opt)))[0]);
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
