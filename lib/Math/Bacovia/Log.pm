package Math::Bacovia::Log;

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

Class::Multimethods::multimethod add => (__PACKAGE__, __PACKAGE__) => sub {
    __PACKAGE__->new($_[0]->{value} * $_[1]->{value});
};

Class::Multimethods::multimethod sub => (__PACKAGE__, __PACKAGE__) => sub {
    __PACKAGE__->new($_[0]->{value} / $_[1]->{value});
};

sub neg {
    my ($x) = @_;
    $x->{_neg} //= __PACKAGE__->new($x->{value}->inv);
}

#
## Equality
#

Class::Multimethods::multimethod eq => (__PACKAGE__, __PACKAGE__) => sub {
    $_[0]->{value} == $_[1]->{value};
};

Class::Multimethods::multimethod eq => (__PACKAGE__, '*') => sub {
    !1;
};

#
## Transformations
#

sub numeric {
    my ($x) = @_;
    $x->{_num} //= CORE::log($x->{value}->numeric);
}

sub pretty {
    my ($x) = @_;
    $x->{_pretty} //= "log(" . $x->{value}->pretty() . ")";
}

sub stringify {
    my ($x) = @_;
    $x->{_str} //= "Log(" . $x->{value}->stringify() . ")";
}

#
## Alternatives
#
sub alternatives {
    my ($x, %opt) = @_;

    $x->{_alt} //= do {

        my @alt;
        foreach my $x ($x->{value}->alternatives(%opt)) {
            push @alt, __PACKAGE__->new($x);

            if (ref($x) eq 'Math::Bacovia::Exp') {
                push @alt, $x->{value};
            }
        }

        [List::UtilsBy::XS::uniq_by { $_->stringify } @alt];
    };

    @{$x->{_alt}};
}

1;
