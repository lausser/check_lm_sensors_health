package Classes::Device;
our @ISA = qw(Monitoring::GLPlugin);
use strict;

sub classify {
  my $self = shift;
  if (! $self->opts->sensorscmd) {
    $self->override_opt("sensorscmd", "/usr/bin/sensors");
  }
  if (-f $self->opts->sensorscmd) {
    if (! -x $self->opts->sensorscmd) {
      $self->set_variable("sensorscmd", "cat ".$self->opts->sensorscmd);
    } else {
      $self->set_variable("sensorscmd", $self->opts->sensorscmd." -j");
    }
    $self->rebless('Classes::Linux');
  } else {
    $self->add_unknown("could not find sensors command");
    $self->add_unknown("--".$self->opts->sensorscmd."--");
  }
  return $self;
}


