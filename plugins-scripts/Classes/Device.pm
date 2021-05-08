package Classes::Device;
our @ISA = qw(Monitoring::GLPlugin);
use strict;

sub classify {
  my $self = shift;
  if (! ($self->opts->hostname)) {
    $self->add_unknown('please specify a hostname');
  } else {
    if (! -x "/usr/bin/ipmitool") {
      $self->add_unknown("could not find ipmitool command");
    } else {
      $self->{ipmitool} = "/usr/bin/ipmitool";
    }
    if (! $self->check_messages()) {
      if ($self->opts->verbose && $self->opts->verbose) {
        #
      }
      $self->rebless('Classes::IPMI');
      $Classes::IPMI::ipmitool = $self->{ipmitool};
    }
  }
  return $self;
}


