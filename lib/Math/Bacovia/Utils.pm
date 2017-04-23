package Math::Bacovia::Utils;

use 5.014;
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
    my ($callback, @arrs) = @_;

    my ($more, @lengths);

    foreach my $arr (@arrs) {
        my $end = $#{$arr};

        if ($end >= 0) {
            $more ||= 1;
        }
        else {
            $more = 0;
            last;
        }

        push @lengths, $end;
    }

    my @temp;
    my @indices = (0) x @arrs;

    while ($more) {
        @temp = @indices;

        for (my $i = $#indices ; $i >= 0 ; --$i) {
            if ($indices[$i] == $lengths[$i]) {
                $indices[$i] = 0;
                $more = 0 if $i == 0;
            }
            else {
                ++$indices[$i];
                last;
            }
        }

        $callback->(map { $_->[CORE::shift(@temp)] } @arrs);
    }
}

1;
