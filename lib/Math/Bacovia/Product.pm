package Math::Bacovia::Product;

use 5.014;
use warnings;

use Class::Multimethods;
use parent qw(Math::Bacovia);

sub new {
    my ($class, @values) = @_;
    Math::Bacovia::Utils::check_type(\$_) for @values;
    bless {values => \@values}, $class;
}

sub inside {
    my ($x) = @_;
    (@{$x->{values}});
}

#
## Operations
#

Class::Multimethods::multimethod mul => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new(@{$x->{values}}, @{$y->{values}});
};

Class::Multimethods::multimethod mul => (__PACKAGE__, 'Math::Bacovia') => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new(@{$x->{values}}, $y);
};

Class::Multimethods::multimethod div => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new(@{$x->{values}}, map { $_->inv } @{$y->{values}});
};

Class::Multimethods::multimethod div => (__PACKAGE__, 'Math::Bacovia') => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new(@{$x->{values}}, $y->inv);
};

Class::Multimethods::multimethod pow => (__PACKAGE__, 'Math::Bacovia') => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new(map { $_**$y } @{$x->{values}});
};

sub inv {
    my ($x) = @_;
    $x->{_inv} //= __PACKAGE__->new(map { $_->inv } @{$x->{values}});
}

#
## Transformations
#

sub numeric {
    my ($x) = @_;
    $x->{_num} //= do {
        my $prod = Math::Bacovia::ONE;
        foreach my $value (@{$x->{values}}) {
            $prod *= $value->numeric;
        }
        $prod;
    };
}

sub pretty {
    my ($x) = @_;
    $x->{_pretty} //= do {
        my @pretty = map { $_->pretty } @{$x->{values}};
        @pretty ? ('(' . join(' * ', @pretty) . ')') : '1';
    };
}

sub stringify {
    my ($x) = @_;
    $x->{_str} //= 'Product(' . join(', ', map { $_->stringify } @{$x->{values}}) . ')';
}

#
## Equality
#

Class::Multimethods::multimethod eq => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;

    my @p1 = @{$x->{values}};
    my @p2 = @{$y->{values}};

    (@p1 == @p2) || return !1;

    while (@p1 && @p2) {
        (shift(@p1)->eq(shift(@p2))) || return !1;
    }

    return 1;
};

Class::Multimethods::multimethod eq => (__PACKAGE__, '*') => sub {
    !1;
};

#
## Alternatives
#
sub alternatives {
    my ($x) = @_;

    $x->{_alt} //= do {

        my @alt;

        Math::Bacovia::Utils::cartesian {
            my %table;
            foreach my $v (@_) {
                push @{$table{ref($v)}}, $v;
            }

            my @partial;
            foreach my $group (values(%table)) {
                my $prod = shift(@$group);
                foreach my $v (@{$group}) {
                    $prod *= $v;
                }
                push @partial, $prod;
            }

            if (@partial) {
                @partial = List::UtilsBy::XS::sort_by { ref($_) } @partial;

                my $prod = shift(@partial);
                foreach my $v (@partial) {
                    $prod *= $v;
                }

                push @alt, $prod;
            }
        }
        map { [$_->alternatives] } @{$x->{values}};

        [List::UtilsBy::XS::uniq_by { $_->stringify } @alt];
    };

    @{$x->{_alt}};
}

1;
