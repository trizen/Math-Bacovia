package Math::Bacovia::Sum;

use 5.016;
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

Class::Multimethods::multimethod add => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new(@{$x->{values}}, @{$y->{values}});
};

Class::Multimethods::multimethod add => (__PACKAGE__, 'Math::Bacovia') => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new(@{$x->{values}}, $y);
};

Class::Multimethods::multimethod sub => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new(@{$x->{values}}, map { $_->neg } @{$y->{values}});
};

Class::Multimethods::multimethod sub => (__PACKAGE__, 'Math::Bacovia') => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new(@{$x->{values}}, $y->neg);
};

Class::Multimethods::multimethod mul => (__PACKAGE__, 'Math::Bacovia') => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new(map { $_->mul($y) } @{$x->{values}});
};

Class::Multimethods::multimethod div => (__PACKAGE__, 'Math::Bacovia') => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new(map { $_->div($y) } @{$x->{values}});
};

sub neg {
    my ($x) = @_;
    __PACKAGE__->new(map { $_->neg } @{$x->{values}});
}

#
## Transformations
#

sub numeric {
    my ($x) = @_;
    my $sum = Math::Bacovia::ZERO;
    foreach my $value (@{$x->{values}}) {
        $sum += $value->numeric;
    }
    $sum;
}

sub pretty {
    my ($x) = @_;
    my @pretty = map { $_->pretty } @{$x->{values}};
    @pretty ? ('(' . join(' + ', @pretty) . ')') : '0';
}

sub stringify {
    my ($x) = @_;
    'Sum(' . join(', ', map { $_->stringify } @{$x->{values}}) . ')';
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

    my @alt;

    Math::Bacovia::Utils::cartesian {
        my %table;
        foreach my $v (@_) {
            push @{$table{ref($v)}}, $v;
        }

        my @partial;
        foreach my $group (values(%table)) {
            my $sum = shift(@$group);
            foreach my $v (@{$group}) {
                $sum += $v;
            }
            push @partial, $sum;
        }

        if (@partial) {
            @partial = List::UtilsBy::XS::sort_by { ref($_) } @partial;

            my $sum = shift(@partial);
            foreach my $v (@partial) {
                $sum += $v;
            }

            push @alt, $sum;
        }
    }
    map { [$_->alternatives] } @{$x->{values}};

    List::UtilsBy::XS::uniq_by { $_->stringify } @alt;
}

1;
