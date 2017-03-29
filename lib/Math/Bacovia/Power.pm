package Math::Bacovia::Power;

use 5.016;
use Class::Multimethods;
use parent qw(Math::Bacovia);

sub new {
    my ($class, $base, $power) = @_;

    Math::Bacovia::Utils::check_type(\$base);

    if (defined($power)) {
        Math::Bacovia::Utils::check_type(\$power);
    }
    else {
        $power = 'Math::Bacovia::Number'->new(Math::Bacovia::ONE);
    }

    bless {
           base  => $base,
           power => $power,
          }, $class;
}

sub inside {
    my ($x) = @_;
    ($x->{base}, $x->{power});
}

#
## Operations
#

Class::Multimethods::multimethod pow => (__PACKAGE__, 'Math::Bacovia') => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new($x->{base}, $x->{power} * $y);
};

sub inv {
    my ($x) = @_;
    __PACKAGE__->new($x->{base}, $x->{power}->neg);
}

#
## Equality
#

Class::Multimethods::multimethod eq => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;
    ($x->{base} == $y->{base})
      && ($x->{power} == $y->{power});
};

Class::Multimethods::multimethod eq => (__PACKAGE__, '*') => sub {
    !1;
};

#
## Transformations
#

sub numeric {
    my ($x) = @_;
    ($x->{base}->numeric)**($x->{power}->numeric);
}

sub pretty {
    my ($x) = @_;

    my $base = $x->{base}->pretty();
    my $pow  = $x->{power}->pretty();

    if (substr($base, 0, 1) eq '-'
        or ref($x->{base}) eq __PACKAGE__) {
        "($base)^$pow";
    }
    else {
        "$base^$pow";
    }
}

sub stringify {
    my ($x) = @_;
    "Power(" . $x->{base}->stringify() . ', ' . $x->{power}->stringify() . ")";
}

#
## Alternatives
#
sub alternatives {
    my ($self) = @_;

    my @a1 = $self->{base}->alternatives;
    my @a2 = $self->{power}->alternatives;

    my @alt;

    foreach my $x (@a1) {
        foreach my $y (@a2) {

            push @alt, 'Math::Bacovia::Exp'->new('Math::Bacovia::Log'->new($x) * $y);
            push @alt, $x**$y;

            # Identity: 1^x = 1
            if ($x == 1) {
                push @alt, $x;
            }

            # Identity: x^1 = x
            if ($y == 1) {
                push @alt, $x;
            }

            # Identity: (a/b)^x = a^x / b^x
            if (ref($x) eq 'Math::Bacovia::Fraction') {
                push @alt, $x->{num}**$y / $x->{den}**$y;
            }

            # Identity: x^2 = x*x
            #~ if (b == 2) {
            #~ take(a * a)
            #~ }

            # Identity: x^log(y) = y^log(x)
            if (ref($y) eq 'Math::Bacovia::Log') {
                push @alt, $y->{value}**('Math::Bacovia::Log'->new($x));
            }

            # Identity: exp(x)^log(y) = y^x
            if (    ref($x) eq 'Math::Bacovia::Exp'
                and ref($y) eq 'Math::Bacovia::Exp') {
                push @alt, ($y->{value}**$x->{value});
            }

            # Identity: exp(x)^y = exp(y*x)
            if (ref($x) eq 'Math::Bacovia::Exp') {
                push @alt, 'Math::Bacovia::Exp'->new($x->{value} * $y);
            }
        }
    }

    List::UtilsBy::XS::uniq_by { $_->stringify } @alt;
}

1;
