package Math::Bacovia::Log;

use 5.014;
use warnings;

use Class::Multimethods qw();
use parent qw(Math::Bacovia);

my %cache;

sub new {
    my ($class, $value) = @_;
    Math::Bacovia::Utils::check_type(\$value);
    $cache{$value->stringify} //= bless {value => $value}, $class;
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
    my ($self, %opt) = @_;

    $self->{_alt} //= do {

        my @alt;
        foreach my $o ($self->{value}->alternatives(%opt)) {

            push @alt, __PACKAGE__->new($o);

            if (ref($o) eq 'Math::Bacovia::Exp') {
                push @alt, $o->{value};
            }

            if ($opt{full}) {
                if (ref($o) eq 'Math::Bacovia::Product') {
                    push @alt, 'Math::Bacovia::Sum'->new(map { __PACKAGE__->new($_) } @{$o->{values}});
                }

                if (ref($o) eq 'Math::Bacovia::Fraction') {
                    push @alt, 'Math::Bacovia::Difference'->new(__PACKAGE__->new($o->{num}), __PACKAGE__->new($o->{den}));
                }
            }
        }

        [List::UtilsBy::XS::uniq_by { $_->stringify } @alt];
    };

    @{$self->{_alt}};
}

1;
