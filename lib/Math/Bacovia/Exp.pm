package Math::Bacovia::Exp;

use 5.016;
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
    __PACKAGE__->new($x->{value}->neg);
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
    CORE::exp($_[0]->{value}->numeric);
}

sub pretty {
    "exp(" . $_[0]->{value}->pretty() . ")";
}

sub stringify {
    "Exp(" . $_[0]->{value}->stringify() . ")";
}

#
## Alternatives
#
sub alternatives {
    my ($self, %opt) = @_;

    my @a;

    foreach my $a ($self->{value}->alternatives(%opt)) {
        push @a, __PACKAGE__->new($a);

        if (ref($a) eq 'Math::Bacovia::Product' and @{$a->{values}} == 2) {
            my ($x, $y) = @{$a->{values}};
            if (ref($x) eq 'Math::Bacovia::Log') {
                push @a, 'Math::Bacovia::Power'->new($x->{value}, $y)->alternatives(%opt);
            }
            elsif (ref($y) eq 'Math::Bacovia::Log') {
                push @a, 'Math::Bacovia::Power'->new($y->{value}, $x)->alternatives(%opt);
            }
        }
        elsif (ref($a) eq 'Math::Bacovia::Log') {
            push @a, $a->{value};
        }
    }

    List::UtilsBy::XS::uniq_by { $_->stringify } @a;
}

1;
