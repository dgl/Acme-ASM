package Acme::ASM::Call;
use strict;
use warnings;
use Acme::ASM::Register;
use Acme::ASM::Ops;
use Acme::ASM::Util qw(dlsym);

use base "Exporter";
our @EXPORT_OK = qw(ccall);

# TODO: Need to handle type conversion and all that stuff

sub ccall {
  my($symbol, @args) = @_;

  for my $arg(@args) {
    mov $eax, $arg;
    pushl $eax;
  }

  mov $eax, dlsym $symbol;
  call $eax;
}

1;
