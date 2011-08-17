package Acme::ASM::PrintHandle;
# ABSTRACT: Crack influenced print capturing
use strict;
use warnings;
use base "Tie::StdHandle";
use Acme::ASM::Call qw(ccall);
use Acme::ASM::Ops;
use Acme::ASM::Register;
use Acme::ASM::Util qw(dlsym pv);

# TODO: Use printf rather than puts so a newline isn't added

sub PRINT {
  my($self, @list) = @_;
  for(@list) {
    if(UNIVERSAL::isa($_, "Acme::ASM::Register")) {
      pushl $_;
      mov $eax, dlsym "puts";
      call $eax;
    }
    else {
      ccall("puts", unpack "L!", pack "p", $_);
    }
  }
}

sub PRINTF {
  my($self, @list) = @_;
  $self->PRINT(sprintf $list[0], @list[1 .. $#list]);
}

1;
