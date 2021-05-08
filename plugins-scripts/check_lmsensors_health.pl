#! /usr/bin/perl

use strict;

eval {
  if ( ! grep /AUTOLOAD/, keys %Monitoring::GLPlugin::) {
    require Monitoring::GLPlugin;
  }
};
if ($@) {
  printf "UNKNOWN - module Monitoring::GLPlugin was not found. Either build a standalone version of this plugin or set PERL5LIB\n";
  printf "%s\n", $@;
  exit 3;
}

my $plugin = Classes::Device->new(
    shortname => '',
    usage => 'Usage: %s [ -v|--verbose ] [ -t <timeout> ] '.
        '--mode <what-to-do> '.
        '--hostname <remote server>'.
        '  ...]',
    version => '$Revision: #PACKAGE_VERSION# $',
    blurb => 'This plugin runs ipmitool sdr list ',
    url => 'http://labs.consol.de/nagios/check_ipmi_health',
    timeout => 60,
);
$plugin->add_mode(
    internal => 'device::sensors::check',
    spec => 'check-sensors',
    alias => undef,
    help => 'Check the status of lm-sensors',
);
$plugin->add_mode(
    internal => 'device::sensors::list',
    spec => 'list-sensors',
    alias => undef,
    help => 'List available lm-sensors',
);
$plugin->add_default_args();
$plugin->add_arg(
    spec => 'sensorscmd',
    help => '--sensorscmd
   The path to the sensors command',
    required => 0,
);

$plugin->getopts();
$plugin->classify();
$plugin->validate_args();

if (! $plugin->check_messages()) {
  $plugin->init();
  if (! $plugin->check_messages()) {
    $plugin->add_ok($plugin->get_summary())
        if $plugin->get_summary();
    $plugin->add_ok($plugin->get_extendedinfo(" "))
        if $plugin->get_extendedinfo();
  }
} elsif ($plugin->opts->snmpwalk && $plugin->opts->offline) {
  ;
} else {
  $plugin->add_critical('wrong device');
}
my ($code, $message) = $plugin->opts->multiline ?
    $plugin->check_messages(join => "\n", join_all => ', ') :
    $plugin->check_messages(join => ', ', join_all => ', ');
$message .= sprintf "\n%s\n", $plugin->get_info("\n")
    if $plugin->opts->verbose >= 1;
#printf "%s\n", Data::Dumper::Dumper($plugin);

$plugin->nagios_exit($code, $message);


