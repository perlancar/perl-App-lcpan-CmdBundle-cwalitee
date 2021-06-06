package App::lcpan::Cmd::mods_with_abstract_cwalitee;

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

my %mods_args = %{$App::lcpan::SPEC{modules}{args}};
my %calc_args = Cwalitee::Common::args_calc('Module::Abstract::');

$SPEC{handle_cmd} = {
    v => 1.1,
    summary => "Like mods subcommand, but also return module abstract cwalitees in detail (-l) mode",
    args => {
        %mods_args,
        %calc_args,
    },
};
sub handle_cmd {
    require Module::Abstract::Cwalitee;

    my %args = @_;

    #my $state = App::lcpan::_init(\%args, 'ro');
    #my $dbh = $state->{dbh};

    my $res = App::lcpan::modules(hash_subset(\%args, \%mods_args));
    return $res unless $res->[0] == 200;
    return $res unless $args{detail};

    for my $row (@{$res->[2]}) {
        my $cres = Module::Abstract::Cwalitee::calc_module_abstract_cwalitee(
            abstract => $row->{abstract},
            module => $row->{module},
            hash_subset(\%args, \%calc_args),
        );
        unless ($cres->[0] == 200) {
            log_warn "Can't calc cwalitee for module '$row->{module}: $cres->[0] - $cres->[1]";
            next;
        }
        $row->{cwalitee} = $cres->[3]{'func.score'};
    }

    $res;
}

1;
# ABSTRACT:
