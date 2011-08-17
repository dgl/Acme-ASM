package Acme::ASM::Register;
use strict;
use warnings;

use overload 
  q{""} => sub { shift->sv },
  q{+0} => sub { shift->iv },
  fallback => 1;

my %regs = (
  eax => bless({n=>"eax",b=>0}, "Acme::ASM::Register"),
  ebx => bless({n=>"ebx",b=>3}, "Acme::ASM::Register"),
  ecx => bless({n=>"ecx",b=>1}, "Acme::ASM::Register"),
  edx => bless({n=>"edx",b=>2}, "Acme::ASM::Register"),
  ebp => bless({n=>"ebp",b=>5}, "Acme::ASM::Register"),
  esi => bless({n=>"esi",b=>6}, "Acme::ASM::Register"),
  edi => bless({n=>"edi",b=>7}, "Acme::ASM::Register"),

  rax => bless({n=>"rax",b=>0,rex=>1}, "Acme::ASM::Register"),
  rbx => bless({n=>"rbx",b=>3,rex=>1}, "Acme::ASM::Register"),
  rcx => bless({n=>"rcx",b=>1,rex=>1}, "Acme::ASM::Register"),
  rdx => bless({n=>"rdx",b=>2,rex=>1}, "Acme::ASM::Register"),
  rbp => bless({n=>"rbp",b=>5,rex=>1}, "Acme::ASM::Register"),
  rsi => bless({n=>"rsi",b=>6,rex=>1}, "Acme::ASM::Register"),
  rdi => bless({n=>"rdi",b=>7,rex=>1}, "Acme::ASM::Register"),
  r8  => bless({n=>"r8" ,b=>0,rex=>1}, "Acme::ASM::Register"),
  r9  => bless({n=>"r9" ,b=>1,rex=>1}, "Acme::ASM::Register"),
  r10 => bless({n=>"r10",b=>2,rex=>1}, "Acme::ASM::Register"),
  r11 => bless({n=>"r11",b=>3,rex=>1}, "Acme::ASM::Register"),
  r12 => bless({n=>"r12",b=>4,rex=>1}, "Acme::ASM::Register"),
  r13 => bless({n=>"r13",b=>5,rex=>1}, "Acme::ASM::Register"),
  r14 => bless({n=>"r14",b=>6,rex=>1}, "Acme::ASM::Register"),
  r15 => bless({n=>"r15",b=>7,rex=>1}, "Acme::ASM::Register"),
);

sub import {
  my($class, $level) = @_;
  $level = 0 unless defined $level;

  no strict 'refs';
  for my $reg(keys %regs) {
    no warnings 'once';
    *{caller($level) . "::$reg"} = \$regs{$reg};
  }
}

sub sv {
}

sub iv {
}

1;
