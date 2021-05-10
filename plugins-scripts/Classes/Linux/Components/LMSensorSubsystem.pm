package Classes::Linux::Components::LMSensorSubsystem;
our @ISA = qw(Monitoring::GLPlugin::Item);
use strict;
use JSON;

sub init {
  my ($self) = @_;
  $self->{sensors} = [];
  open(SENSORS, sprintf "%s 2>&1|", $self->get_variable("sensorscmd"));
  $self->{sensorsoutput} = do { local $/; <SENSORS> };
  close SENSORS;
  if ($self->{sensorsoutput} =~ /No sensors found/m) {
    $self->add_unknown("No sensors found");
  } else {
    eval {
      my $json = JSON->new->allow_nonref;
      $self->{sensorsjson} = $json->decode($self->{sensorsoutput});
    };
    if ($@) {
      $self->add_unknown("invalid output from sensors command");
    } else {
      foreach my $adaptername (keys %{$self->{sensorsjson}}) {
	my $adapter = $self->{sensorsjson}->{$adaptername};
        foreach my $sensorname (keys %{$adapter}) {
	  my $sensor = $self->{sensorsjson}->{$adaptername}->{$sensorname};
          next if ref($sensor) ne "HASH";
	  $sensor->{name} = $sensorname;
	  $sensor->{adapter} = $adaptername;
	  $sensor->{adapterdesc} =
	      exists $adapter->{Adapter} ?  $adapter->{Adapter} : $adaptername;
          push(@{$self->{sensors}}, Classes::Linux::Components::LMSensorSubsystem::Sensor->new(%{$sensor}));
        }
      }
    }
  }
  delete $self->{sensorsoutput};
  delete $self->{sensorsjson};
  @{$self->{sensors}} = grep {
    ref($_) ne "Classes::Linux::Components::LMSensorSubsystem::Sensor";
  } @{$self->{sensors}};

}

sub check {
  my ($self) = @_;
  if (! $self->check_messages()) {
    $self->SUPER::check();
  }
}


package Classes::Linux::Components::LMSensorSubsystem::Sensor;
our @ISA = qw(Monitoring::GLPlugin::TableItem);
use strict;

sub internal_name {
  my ($self) = @_;
  my $class = ref($self);
  $class =~ s/^.*:://;
  $self->{adapter} =~ s/\s+//g;
  $self->{name} =~ s/\s+/_/g;
  if ($self->{name} =~ /^.*?(\d+)/) {
    return sprintf "%s%s_%s", uc $class, uc $self->{adapter}, $1;
  } else {
    return sprintf "%s%s", uc $class, uc $self->{adapter};
  }
}


sub finish {
  my ($self) = @_;
  if (grep /temp.*_input/, keys %{$self}) {
    bless $self, "Classes::Linux::Components::LMSensorSubsystem::TempSensor";
    $self->finish();
  }
}

sub xinit {
  my ($self) = @_;
}


package Classes::Linux::Components::LMSensorSubsystem::TempSensor;
our @ISA = qw(Classes::Linux::Components::LMSensorSubsystem::Sensor);
use strict;

sub finish {
  my ($self) = @_;
  foreach my $key (grep /^temp.*_(\w+)/, keys %{$self}) {
    $key =~ /^temp.*?_(\w+)/;
    foreach (qw(input crit crit_alarm crit_hyst max max_alarm max_hyst
        min min_alarm min_hyst)) {
      $self->{$_} = $self->{$key} if ($1 eq $_);
    }
  }
  foreach (grep /^temp.*_(\w+)/, keys %{$self}) {
    delete $self->{$_};
  }
}

sub check {
  my ($self) = @_;
  my $label = $self->full_name();
  $self->add_info(sprintf "%s has %.2fC", $label, $self->{input});
  if ($self->{crit}) {
    $self->set_thresholds(metric => $label,
         warning => $self->{crit},
         critical => $self->{crit},
    );
  }
  $self->add_message($self->check_thresholds(metric => $label,
      value => $self->{input}
  ));
  $self->add_perfdata(label => $label,
      value => $self->{input}
  );
}

sub full_name {
  my ($self) = @_;
  my $full;
  if ($self->{name} =~ /temp/) {
    $full = sprintf "%s_%s", $self->{adapter}, $self->{name};
  } else {
    $full = sprintf "%s_%s_temp", $self->{adapter}, $self->{name};
  }
  $full =~ s/\s+/_/g;
  return $full;
}








