#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use JSON;

my $env = \%ENV;

while (1) {
  print {*STDERR} "Hello World!\n";

  $env->{TIMESTAMP} = scalar localtime;

  my $json = JSON->new->pretty->encode($env);

  print {*STDERR} Dumper( [ env => $json ] );

  if ( $ENV{HAS_EFS_MOUNT} ) {
    open my $fh, '>>', sprintf '%s/env.json', $ENV{HAS_EFS_MOUNT}
      or die "could not open file /mnt/session/env.json\n";

    print {$fh} $json;

    close $fh;
  }
  else {
    print {*STDERR}
      "add and an efs: section and set HAS_EFS_MOUNT to the mount point if you want to text EFS mount points.\n";
  }

  last
    if $ENV{RUN_ONCE};

  sleep 60;
}

1;
