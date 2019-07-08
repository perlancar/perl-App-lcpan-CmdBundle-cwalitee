package App::lcpan::Cmd::cwalitee_of_release_changes;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::ger;

use Perinci::Object;

require App::lcpan;

our %SPEC;

$SPEC{handle_cmd} = {
    v => 1.1,
    summary => "Calculate the cwalitee of a release's Changes file",
    description => <<'_',

_
    args => {
        %App::lcpan::common_args,
        #%App::lcpan::dist_or_release_args,
        %App::lcpan::mod_or_dist_or_script_args,
    },
};
sub handle_cmd {
    require App::lcpan::Cmd::changes;
    require CPAN::Changes::Cwalitee;
    require File::Temp;

    my %args = @_;

    my $state = App::lcpan::_init(\%args, 'ro');
    my $dbh = $state->{dbh};

    my $mod_or_dist_or_script = $args{module_or_dist_or_script};
    $mod_or_dist_or_script =~ s!/!::!g; # XXX this should be done by coercer
    # XXX changes doesn't yet accept release name

    my $res = App::lcpan::Cmd::changes::handle_cmd(%args);
    return $res unless $res->[0] == 200;

    my ($fh, $filename) = File::Temp::tempfile();
    print $fh $res->[2];
    close $fh;

    CPAN::Changes::Cwalitee::calc_cpan_changes_cwalitee(
        path => $filename,
    );
}

1;
# ABSTRACT:
