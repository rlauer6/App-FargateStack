#!/usr/bin/env perl

use strict;
use warnings;

use Log::Log4perl;
use JSON qw(to_json);
use Readonly;

Readonly::Scalar our $TRUE => 1;

Readonly::Scalar our $LOG4PERL_CONF => <<END_OF_CONF;
log4perl.rootLogger=DEBUG,HelloWorld
log4perl.appender.HelloWorld=Log::Log4perl::Appender::Screen
log4perl.appender.HelloWorld.layout = Log::Log4perl::Layout::JSON
log4perl.appender.HelloWorld.layout.field.message = %m{chomp}
log4perl.appender.HelloWorld.layout.field.category = %c
log4perl.appender.HelloWorld.layout.field.class = %C
log4perl.appender.HelloWorld.layout.field.file = %F{1}
log4perl.appender.HelloWorld.layout.field.sub = %M{1}
log4perl.appender.HelloWorld.layout.include_mdc = 1
END_OF_CONF

our $VERSION = '0.01';

########################################################################
sub init_logger {
########################################################################
  Log::Log4perl->init( \$LOG4PERL_CONF );

  return Log::Log4perl->get_logger;
}

########################################################################
sub main {
########################################################################
  my $logger = init_logger();

  $logger->info('starting process...');

  my $env = to_json( \%ENV );

  if ( $ENV{HAS_EFS_MOUNT} ) {
    my $filename = sprintf '%s/env.json', $ENV{HAS_EFS_MOUNT};

    open my $fh, '>>', $filename
      or die "could not open file $filename";

    print {$fh} $env;

    close $fh;
  }
  else {
    $logger->info('TIP: add an "efs:" section and set HAS_EFS_MOUNT to a mount if you want to test EFS mount points');
  }

  while ($TRUE) {
    $logger->info('Hello World!');

    last
      if $ENV{RUN_ONCE};

    sleep 60;
  }

  exit 0;
}

exit main();

1;
