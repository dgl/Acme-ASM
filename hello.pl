#!/usr/bin/perl
use Acme::ASM;
use Acme::ASM::Util qw(pv);

sub foo :x86 {
  my $string = "Hello world";
  mov $eax, pv($string);
  print $eax;
}

foo();
