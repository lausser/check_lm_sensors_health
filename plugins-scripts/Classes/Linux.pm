package Classes::Linux;
our @ISA = qw(Classes::Device);
use strict;

sub init {
  my ($self) = @_;
  if ($self->mode =~ /device::sensor/) {
    $self->analyze_and_check_lmsensor_subsystem('Classes::Linux::Components::LMSensorSubsystem');
  } else {
    $self->no_such_mode();
  }
}

