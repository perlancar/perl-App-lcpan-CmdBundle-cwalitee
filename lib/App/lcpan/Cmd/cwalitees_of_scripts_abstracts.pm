package App::lcpan::Cmd::cwalitees_of_scripts_abstracts;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::ger;

require App::lcpan;
use Cwalitee::Common;
use Hash::Subset qw(hash_subset);

our %SPEC;

my %calc_args = Cwalitee::Common::args_calc('Module::Abstract::');

$SPEC{handle_cmd} = {
    v => 1.1,
    summary => "Calculate the cwalitees of scripts' Abstracts",
    description => <<'_',

_
    args => {
        %App::lcpan::common_args,
        %App::lcpan::scripts_args,
        %calc_args,
    },
};
sub handle_cmd {
    require App::lcpan::Cmd::changes;
    require Module::Abstract::Cwalitee;

    my %args = @_;

    my $state = App::lcpan::_init(\%args, 'ro');
    my $dbh = $state->{dbh};

    my @rows;
    for my $script (@{ $args{scripts} }) {
        my ($file_id, $abstract) = $dbh->selectrow_array(
            "SELECT file_id, abstract FROM script WHERE name=?", {}, $script);
        $file_id or do {
            log_warn "No such script '$script'";
            next;
        };

        my $cres = Module::Abstract::Cwalitee::calc_module_abstract_cwalitee(
            abstract => $abstract,
            hash_subset(\%args, \%calc_args),
        );
        unless ($cres->[0] == 200) {
            log_warn "Can't calc cwalitee for $script: $cres->[0] - $cres->[1]";
            next;
        }

        push @rows, {
            script => $script,
            abstract => $abstract,
            result => $cres->[2][-1]{result},
        };
    }

    [200, "OK", \@rows];
}

1;
# ABSTRACT:
