package Classes::IPMI;
our @ISA = qw(Classes::Device);
use strict;

sub init {
  my ($self) = @_;
  if ($self->mode =~ /device::ipmi::sdr/) {
    $self->analyze_and_check_controller_subsystem('Classes::IPMI::Components::SdrSubsystem');
  } else {
    $self->no_such_mode();
  }
}

