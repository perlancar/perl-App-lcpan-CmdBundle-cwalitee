package App::lcpan::Cmd::dists_with_changes_cwalitee;

# AUTHORITY
# DATE
# DIST
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::ger;

require App::lcpan;
use Cwalitee::Common;
use Hash::Subset qw(hash_subset);

our %SPEC;

my %dists_args = %{$App::lcpan::SPEC{dists}{args}};
my %calc_args = Cwalitee::Common::args_calc('CPAN::Changes::');

$SPEC{handle_cmd} = {
    v => 1.1,
    summary => "Like 'dists' subcommand, but also return CPAN Changes cwalitees in detail (-l) mode",
    args => {
        %dists_args,
        %calc_args,
    },
};
sub handle_cmd {
    require App::lcpan::Cmd::changes;
    require CPAN::Changes::Cwalitee;
    require File::Temp;

    my %args = @_;

    #my $state = App::lcpan::_init(\%args, 'ro');
    #my $dbh = $state->{dbh};

    my $res = App::lcpan::dists(hash_subset(\%args, \%dists_args));
    return $res unless $res->[0] == 200;
    return $res unless $args{detail};

    for my $row (@{$res->[2]}) {
        my $chres = App::lcpan::Cmd::changes::handle_cmd(module_or_dist_or_script => $row->{dist});
        unless ($chres->[0] == 200) {
            log_warn "Can't find Changes for distribution '$row->{dist}': $chres->[0] - $chres->[1]";
            next;
        }

        my ($fh, $filename) = File::Temp::tempfile();
        print $fh $res->[2];
        close $fh;

        my $cwres = CPAN::Changes::Cwalitee::calc_cpan_changes_cwalitee(
            path => $filename,
            hash_subset(\%args, \%calc_args),
        );
        unless ($cwres->[0] == 200) {
            log_warn "Can't calc cwalitee for distribution '$row->{dist}': $cwres->[0] - $cwres->[1]";
            next;
        }
        $row->{cwalitee} = $cwres->[3]{'func.score'};
    }

    $res;
}

1;
# ABSTRACT:
