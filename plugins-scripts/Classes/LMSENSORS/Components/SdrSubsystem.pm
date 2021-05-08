package Classes::IPMI::Components::SdrSubsystem;
our @ISA = qw(Monitoring::GLPlugin::Item);
use strict;

sub init {
  my ($self) = @_;
  my @ipmiparams = ();
  push(@ipmiparams, "-H ".$self->opts->hostname);
  if ($self->opts->port) {
    push(@ipmiparams, "-p ".$self->opts->port);
  }
  if ($self->opts->username) {
    push(@ipmiparams, "-U ".$self->opts->password);
  }
  if ($self->opts->password) {
    push(@ipmiparams, "-P '".$self->opts->password."'");
  }
  $self->{sensors} = [];
  open(IPMITOOL, sprintf "%s %s|",
      $Classes::IPMI::ipmitool,
      join(" ", @ipmiparams));
  while(<IPMITOOL>) {
    push(@{$self->{sensors}}, Classes::IPMI::Components::SdrSubsystem::Sensor->new($_));
  }
  close IPMITOOL;
}


package Classes::IPMI::Components::SdrSubsystem::Sensor;
our @ISA = qw(Monitoring::GLPlugin::TableItem);
use strict;

sub finish {
  my ($self, $record) = @_;
  if ($record =~ /^\s*(.*?)\s*|\s*(.*?)\s*|\s*(.*)\s*$/) {
    $self->{name} = $1;
    $self->{value} = $2;
    $self->{status} = $3;
printf "%s\n", Data::Dumper::Dumper($self);
  }
}
sub init {
  my ($self) = @_;
}
