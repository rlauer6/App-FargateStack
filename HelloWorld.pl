#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;

use JSON;

while (1) {
  print {*STDERR} "Hello World!\n";

  print {*STDERR} JSON->new->pretty->encode( \%ENV );

  last
    if $ENV{RUN_ONCE};

  sleep 60;
}

1;
