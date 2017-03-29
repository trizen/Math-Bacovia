package Math::Bacovia::Utils;

use 5.016;
use warnings;

no warnings 'recursion';
use parent qw(Math::Bacovia);

sub check_type($) {
    my ($ref) = @_;

    if (my $r = ref($$ref)) {
        if ($r eq 'Math::AnyNum') {
            $$ref = 'Math::Bacovia::Number'->new($$ref);
        }
        elsif (UNIVERSAL::isa($r, 'Math::Bacovia')) {
            ## ok
        }
        else {
            $$ref = 'Math::Bacovia::Number'->new($$ref);
        }
    }
    else {
        $$ref = 'Math::Bacovia::Number'->new($$ref);
    }
}

sub cartesian(&@) {
    my ($callback, @C) = @_;

    my (@c, @r);

    sub {
        if (@c < @C) {
            for my $item (@{$C[@c]}) {
                CORE::push(@c, $item);
                __SUB__->();
                CORE::pop(@c);
            }
        }
        else {
            $callback->(@c);
        }
      }
      ->();
}

1;
