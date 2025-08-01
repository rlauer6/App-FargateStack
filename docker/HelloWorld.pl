#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;

use JSON;

while (1) {
  print {*STDERR} "Hello World!\n";

  open my $fh, '>>', '/mnt/session/env.json'
    or die "could not open file /mnt/session/env.json\n";

  my $env = \%ENV;

  $env->{TIMESTAMP} = scalar localtime;

  my $json = JSON->new->pretty->encode($env);

  print {*STDERR} Dumper( [ env => $json ] );
  print {$fh} $json;

  close $fh;

  last
    if $ENV{RUN_ONCE};

  sleep 60;
}

1;
