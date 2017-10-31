package Math::Bacovia::Utils;

use 5.014;
use warnings;

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
    elsif (defined($$ref)) {
        $$ref = 'Math::Bacovia::Number'->new($$ref);
    }
    else {
        require Carp;
        Carp::croak("[ERROR] Undefined value!");
    }
}

1;
