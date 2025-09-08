#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use English qw(no_match_vars);

use Test::More;
use App::FargateStack::Builder::Autoscaling;
use Test::Output;

my $mock = bless {}, 'Mock';

{
  no strict 'refs';  ## no critic

  *{'Mock::log_die'} = sub {
    my ( $self, $fmt, @args ) = @_;

    print {*STDERR} sprintf "$fmt\n", @args;
    exit 1;
  };
  *{'Mock::_cron'} = \&App::FargateStack::Builder::Autoscaling::_cron;
}

my $schedule = {
  start_time   => '00:18',
  end_time     => '00:02',
  days         => 'MON-FRI',
  min_capacity => '2/1',
  max_capacity => '3/2',
};

########################################################################
subtest 'day names' => sub {
########################################################################
  my $cron = $mock->_cron($schedule);

  ok( $cron && $cron->{ScaleOut}->{Schedule} eq 'cron(00 18 ? * MON-FRI *)', 'day names' )
    or diag( Dumper( [ cron => $cron ] ) );

};

########################################################################
subtest 'day numbers' => sub {
########################################################################
  $schedule->{days} = '2-6';

  my $cron = $mock->_cron($schedule);

  ok( $cron && $cron->{ScaleOut}->{Schedule} eq 'cron(00 18 ? * MON-FRI *)', 'day names' )
    or diag( Dumper( [ cron => $cron ] ) );
};

########################################################################
subtest 'one day' => sub {
########################################################################
  $schedule->{days} = '6';

  my $cron = $mock->_cron($schedule);

  ok( $cron && $cron->{ScaleOut}->{Schedule} eq 'cron(00 18 ? * FRI *)', 'day names' )
    or diag( Dumper( [ cron => $cron ] ) );
};

done_testing;
1;
