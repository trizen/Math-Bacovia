package Math::Bacovia::Fraction;

use 5.014;
use warnings;

use Class::Multimethods;
use parent qw(Math::Bacovia);

sub new {
    my ($class, $numerator, $denominator) = @_;

    if (defined($numerator)) {
        Math::Bacovia::Utils::check_type(\$numerator);
    }
    else {
        $numerator = $Math::Bacovia::ZERO;
    }

    if (defined($denominator)) {
        Math::Bacovia::Utils::check_type(\$denominator);
    }
    else {
        $denominator = $Math::Bacovia::ONE;
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
    $x->{_inv} //= __PACKAGE__->new($x->{den}, $x->{num});
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
    $x->{_num} //= $x->{num}->numeric / $x->{den}->numeric;
}

sub pretty {
    my ($x) = @_;

    $x->{_pretty} //= do {
        my $num = $x->{num}->pretty();
        my $den = $x->{den}->pretty();

        if ($den eq '1') {
            $num;
        }
        else {
            "($num/$den)";
        }
    };
}

sub stringify {
    my ($x) = @_;
    $x->{_str} //= "Fraction(" . $x->{num}->stringify() . ', ' . $x->{den}->stringify() . ")";
}

#
## Alternatives
#

sub alternatives {
    my ($x, %opt) = @_;

    $x->{_alt} //= do {
        my @a_num = $x->{num}->alternatives(%opt);
        my @a_den = $x->{den}->alternatives(%opt);

        my @alt;
        foreach my $num (@a_num) {
            foreach my $den (@a_den) {

                if ($den == $Math::Bacovia::ONE) {
                    push @alt, $num;
                }

                if ($num == $den) {
                    push @alt, $Math::Bacovia::ONE;
                }

                push @alt, __PACKAGE__->new($num, $den);

                if ($opt{full}) {
                    push @alt, $num / $den;
                }
                elsif (    ref($num) eq 'Math::Bacovia::Number'
                       and ref($den) eq 'Math::Bacovia::Number') {
                    push @alt, $num / $den;
                }
            }
        }

        [List::UtilsBy::XS::uniq_by { $_->stringify } @alt];
    };

    @{$x->{_alt}};
}

1;
