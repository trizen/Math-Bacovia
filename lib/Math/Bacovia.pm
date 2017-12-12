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

our $VERSION = '0.01';

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

  atan2 => \&atan2,

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

# sin(x) = (exp(x * i) - exp(-i * x))/(2*i)
sub sin {
    my ($x) = @_;
    $x->{_sin} //=
      'Math::Bacovia::Fraction'->new('Math::Bacovia::Exp'->new(i * $x) - 'Math::Bacovia::Exp'->new(-i * $x), $TWO * i);
}

# asin(x) = -i * log(i x + sqrt(1 - x^2))
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

# asinh(x) = log(sqrt(x^2 + 1) + x)
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

#<<<
    $x->{_cosh} //= 'Math::Bacovia::Fraction'->new(('Math::Bacovia::Exp'->new($TWO * $x) + $ONE), ($TWO * 'Math::Bacovia::Exp'->new($x)));
#>>>
}

# acosh(x) = log(x + sqrt(x - 1) * sqrt(x + 1))
sub acosh {
    my ($x) = @_;
    $x->{_acosh} //= 'Math::Bacovia::Log'->new($x + &sqrt($x + $MONE) * &sqrt($x + $ONE));
}

# tan(x) = -i + (2*i)/(1 + exp(2*i*x))
sub tan {
    my ($x) = @_;
    $x->{_tan} //= -i + 'Math::Bacovia::Fraction'->new($TWO * i, $ONE + 'Math::Bacovia::Exp'->new($TWO * i * $x));
}

# atan(x) = i/2 * (log(1 - i*x) - log(1 + i*x))
sub atan {
    my ($x) = @_;

#<<<
    $x->{_atan} //= i * 'Math::Bacovia::Fraction'->new('Math::Bacovia::Log'->new($ONE - i * $x) - 'Math::Bacovia::Log'->new($ONE + i * $x), $TWO);
#>>>
}

# atan2(x, y) = atan(x / y)
sub atan2 {
    my ($x, $y) = @_;
    $x->{_atan2} //= 'Math::Bacovia::Fraction'->new($x, $y)->atan;
}

# tanh(x) = (exp(2x) - 1) / (exp(2x) + 1)
sub tanh {
    my ($x) = @_;
    $x->{_tanh} //= 'Math::Bacovia::Fraction'->new(('Math::Bacovia::Exp'->new($TWO * $x) + $MONE),
                                                   ('Math::Bacovia::Exp'->new($TWO * $x) + $ONE));
}

# atanh(x) = (log(1 + x) - log(1 - x)) / 2
sub atanh {
    my ($x) = @_;
    $x->{_atanh} //=
      'Math::Bacovia::Fraction'->new('Math::Bacovia::Log'->new($ONE + $x) - 'Math::Bacovia::Log'->new($ONE - $x), $TWO);
}

# cot(x) = i + (2*i)/(-1 + exp(2*i*x))
sub cot {
    my ($x) = @_;
    $x->{_cot} //= i + 'Math::Bacovia::Fraction'->new($TWO * i, $MONE + 'Math::Bacovia::Exp'->new($TWO * i * $x));
}

# acot(x) = i * (log(i*x) - log(-(i*x)) + log(-1 - i*x) - log(-1 + i*x)) / 2
sub acot {
    my ($x) = @_;
    $x->{_acot} //= 'Math::Bacovia::Fraction'->new(
                                                   i * (
                                                        (
                                                         'Math::Bacovia::Log'->new(i * $x) -
                                                           'Math::Bacovia::Log'->new(-(i * $x)) +
                                                           'Math::Bacovia::Log'->new($MONE - i * $x) -
                                                           'Math::Bacovia::Log'->new($MONE + i * $x)
                                                        )
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

# acoth(x) = (log(-1 - x) - log(-1 + x) - log(-x) + log(x)) / 2
sub acoth {
    my ($x) = @_;
    $x->{_acoth} //= 'Math::Bacovia::Fraction'->new(
                                                    'Math::Bacovia::Log'->new($MONE - $x) -
                                                      'Math::Bacovia::Log'->new($MONE + $x) -
                                                      'Math::Bacovia::Log'->new(-$x) +
                                                      'Math::Bacovia::Log'->new($x),
                                                    $TWO
                                                   );
}

# sec(x) = 2/(exp(-i*x) + exp(i*x))
sub sec {
    my ($x) = @_;
    $x->{_sec} //=
      'Math::Bacovia::Fraction'->new($TWO, 'Math::Bacovia::Exp'->new(-i * $x) + 'Math::Bacovia::Exp'->new(i * $x));
}

# asec(x) = π/2 + i log(i/x + sqrt(1 - 1/x^2))
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

# asech(x) = log(1/x + sqrt(-1 + 1/x) * sqrt(1 + 1/x))
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

# acsc(x) = -i * log(i/x + sqrt(1 - 1/x^2))
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

# acsch(x) = log(1/x + sqrt(1 + 1/x^2))
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

1;    # End of Math::Bacovia
