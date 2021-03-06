package App::lcpan::Cmd::cwalitee_of_script_abstract;

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
    summary => "Calculate the cwalitee of a script's Abstract",
    description => <<'_',

_
    args => {
        %App::lcpan::common_args,
        %App::lcpan::script_args,
        %calc_args,
    },
};
sub handle_cmd {
    require App::lcpan::Cmd::changes;
    require Module::Abstract::Cwalitee;

    my %args = @_;

    my $state = App::lcpan::_init(\%args, 'ro');
    my $dbh = $state->{dbh};

    my ($file_id, $abstract) = $dbh->selectrow_array(
        "SELECT file_id, abstract FROM script WHERE name=?", {}, $args{script});
    $file_id or return [404, "No such script '$args{script}'"];

    log_info "Abstract is: %s", $abstract;
    Module::Abstract::Cwalitee::calc_module_abstract_cwalitee(
        abstract => $abstract,
        hash_subset(\%args, \%calc_args),
    );
}

1;
# ABSTRACT:
