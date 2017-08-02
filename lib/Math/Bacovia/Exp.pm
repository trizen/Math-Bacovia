package Math::Bacovia::Exp;

use 5.014;
use warnings;

use Class::Multimethods qw();
use parent qw(Math::Bacovia);

sub new {
    my ($class, $value) = @_;
    Math::Bacovia::Utils::check_type(\$value);
    bless {value => $value}, $class;
}

sub inside {
    $_[0]->{value};
}

#
## Operations
#

Class::Multimethods::multimethod mul => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new($x->{value} + $y->{value});
};

Class::Multimethods::multimethod div => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new($x->{value} - $y->{value});
};

Class::Multimethods::multimethod pow => (__PACKAGE__, 'Math::Bacovia') => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new($x->{value} * $y);
};

sub inv {
    my ($x) = @_;
    $x->{_inv} //= __PACKAGE__->new($x->{value}->neg);
}

#
## Equality
#

Class::Multimethods::multimethod eq => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;
    $x->{value} == $y->{value};
};

Class::Multimethods::multimethod eq => (__PACKAGE__, '*') => sub {
    !1;
};

#
## Transformations
#

sub numeric {
    my ($x) = @_;
    $x->{_num} //= CORE::exp($x->{value}->numeric);
}

sub pretty {
    my ($x) = @_;
    $x->{_pretty} //= "exp(" . $x->{value}->pretty() . ")";
}

sub stringify {
    my ($x) = @_;
    $x->{_str} //= "Exp(" . $x->{value}->stringify() . ")";
}

#
## Alternatives
#
sub alternatives {
    my ($self, %opt) = @_;

    $self->{_alt} //= do {

        my @alt;
        foreach my $o ($self->{value}->alternatives(%opt)) {

            push @alt, __PACKAGE__->new($o);

            if (ref($o) eq 'Math::Bacovia::Product' and @{$o->{values}} == 2) {
                my ($x, $y) = @{$o->{values}};
                if (ref($x) eq 'Math::Bacovia::Log') {
                    push @alt, 'Math::Bacovia::Power'->new($x->{value}, $y);
                }
                elsif (ref($y) eq 'Math::Bacovia::Log') {
                    push @alt, 'Math::Bacovia::Power'->new($y->{value}, $x);
                }
            }
            elsif (ref($o) eq 'Math::Bacovia::Log') {
                push @alt, $o->{value};
            }
        }

        [List::UtilsBy::XS::uniq_by { $_->stringify } @alt];
    };

    @{$self->{_alt}};
}

1;
