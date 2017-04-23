package Math::Bacovia::Fraction;

use 5.014;
use warnings;

use Class::Multimethods;
use parent qw(Math::Bacovia);

sub new {
    my ($class, $numerator, $denominator) = @_;

    Math::Bacovia::Utils::check_type(\$numerator);

    if (defined($denominator)) {
        Math::Bacovia::Utils::check_type(\$denominator);
    }
    else {
        $denominator = do {
            state $_x = 'Math::Bacovia::Number'->new(Math::Bacovia::ONE);
        };
    }

    bless {
           num => $numerator,
           den => $denominator,
          }, $class;
}

sub inside {
    my ($x) = @_;
    ($x->{num}, $x->{den});
}

#
## Operations
#

Class::Multimethods::multimethod add => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;
#<<<
    __PACKAGE__->new(
        $x->{num} * $y->{den} + $y->{num} * $x->{den},
        $x->{den} * $y->{den}
    );
#>>>
};

Class::Multimethods::multimethod add => (__PACKAGE__, 'Math::Bacovia::Number') => sub {
    my ($x, $y) = @_;
#<<<
    __PACKAGE__->new(
        $x->{num} + $x->{den} * $y,
        $x->{den}
    );
#>>>
};

Class::Multimethods::multimethod add => (__PACKAGE__, 'Math::Bacovia::Difference') => sub {
    my ($x, $y) = @_;
#<<<
    __PACKAGE__->new(
        $x->{num} + $x->{den} * $y,
        $x->{den}
    );
#>>>
};

Class::Multimethods::multimethod sub => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;
#<<<
    __PACKAGE__->new(
        $x->{num} * $y->{den} - $y->{num} * $x->{den},
        $x->{den} * $y->{den}
    );
#>>>
};

Class::Multimethods::multimethod sub => (__PACKAGE__, 'Math::Bacovia::Number') => sub {
    my ($x, $y) = @_;
#<<<
    __PACKAGE__->new(
        $x->{num} - $x->{den} * $y,
        $x->{den}
    );
#>>>
};

Class::Multimethods::multimethod sub => (__PACKAGE__, 'Math::Bacovia::Difference') => sub {
    my ($x, $y) = @_;
#<<<
    __PACKAGE__->new(
        $x->{num} - $x->{den} * $y,
        $x->{den}
    );
#>>>
};

Class::Multimethods::multimethod mul => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new($x->{num} * $y->{num}, $x->{den} * $y->{den});
};

Class::Multimethods::multimethod mul => (__PACKAGE__, 'Math::Bacovia::Number') => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new($x->{num} * $y, $x->{den});
};

Class::Multimethods::multimethod mul => (__PACKAGE__, 'Math::Bacovia::Difference') => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new($x->{num} * $y, $x->{den});
};

Class::Multimethods::multimethod div => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new($x->{num} * $y->{den}, $x->{den} * $y->{num});
};

Class::Multimethods::multimethod div => (__PACKAGE__, 'Math::Bacovia::Number') => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new($x->{num}, $x->{den} * $y);
};

Class::Multimethods::multimethod div => (__PACKAGE__, 'Math::Bacovia::Difference') => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new($x->{num}, $x->{den} * $y);
};

sub inv {
    my ($x) = @_;
    __PACKAGE__->new($x->{den}, $x->{num});
}

#
## Equality
#

Class::Multimethods::multimethod eq => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;

    ($x->{num} == $y->{num})
      && ($x->{den} == $y->{den});
};

Class::Multimethods::multimethod eq => (__PACKAGE__, '*') => sub {
    !1;
};

#
## Transformations
#

sub numeric {
    my ($x) = @_;
    $x->{num}->numeric / $x->{den}->numeric;
}

sub pretty {
    my ($x) = @_;

    my $num = $x->{num}->pretty();
    my $den = $x->{den}->pretty();

    if ($den eq '1') {
        return $num;
    }

    "($num/$den)";
}

sub stringify {
    my ($x) = @_;
    "Fraction(" . $x->{num}->stringify() . ', ' . $x->{den}->stringify() . ")";
}

#
## Alternatives
#

sub alternatives {
    my ($x, %opt) = @_;

    my @a_num = $x->{num}->alternatives(%opt);
    my @a_den = $x->{den}->alternatives(%opt);

    my @alt;
    foreach my $num (@a_num) {
        foreach my $den (@a_den) {

            #push @alt, $num / $den;
            push @alt, __PACKAGE__->new($num, $den);

            if ($den == 1) {
                push @alt, $num;
            }

            if ($num == 1) {
                push @alt, $den->inv;
            }
        }
    }

    List::UtilsBy::XS::uniq_by { $_->stringify } @alt;
}

1;
