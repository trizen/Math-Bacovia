package Math::Bacovia::Symbol;

use 5.016;
use Class::Multimethods;
use parent qw(Math::Bacovia);

sub new {
    my ($class, $name, $value) = @_;

    if (defined($value)) {
        Math::Bacovia::Utils::check_type(\$value);
    }

    bless {
           name  => "$name",
           value => $value,
          }, $class;
}

#
## Equality
#

Class::Multimethods::multimethod eq => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;
    $x->{name} eq $y->{name};
};

Class::Multimethods::multimethod eq => (__PACKAGE__, '*') => sub {
    !1;
};

#
## Transformations
#

sub numeric {
    $_[0]->{value};
}

sub pretty {
    $_[0]->{name};
}

sub stringify {
    my ($x) = @_;
    defined($x->{value})
      ? ("Symbol(\"\Q$x->{name}\E\", " . $x->{value}->stringify() . ")")
      : ("Symbol(\"\E$x->{name}\E\")");
}

1;
