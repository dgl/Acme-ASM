package Acme::ASM;
use strict;
use warnings;
use Attribute::Handlers;
use B ();

use Acme::ASM::Ops;
use Acme::ASM::PrintHandle;
use Acme::ASM::Register;
use Acme::ASM::Util qw(poke);

use constant DEBUG => $ENV{ACME_DEBUG};

our $VERSION = "0.0";

our @output;

sub import {
  my($class) = @_;

  # Impose strictness on caller
  strict->import;
  warnings->import;

  # But not ourselves
  no strict 'refs';

  push @{caller() . "::ISA"}, __PACKAGE__;

  Acme::ASM::Ops->import(1);
  Acme::ASM::Register->import(1);
}

sub x86 :ATTR(CODE) {
  my($ref) = $_[2];

  local @output;
  local *STDOUT;
  tie *STDOUT, "Acme::ASM::PrintHandle";

  pushl $ebp;

  warn "About to run $ref\n" if DEBUG;
  $ref->();

  # Get the actual CV
  my $cv = B::svref_2object($ref);
  my $start = $cv->START;

  # Find the leavesub (which we hijack later, seems easier than constructing one...)
  my $end = $start->next;
  while($end->name ne 'leavesub') {
    $end = $end->next;
  }

  # Ensure there's a ret
  mov $eax, 0+$$end;
  leave;
  ret;

  my $codeaddr = make_output(@output);

  # Now for the überevil: Overwrite op at the start of the sub
  my $ppaddr = $$start + 2 * length pack "L!";
  warn sprintf "Replacing %x [%x+%x] with %x\n",
    $ppaddr, $$start, (length pack "L!"), $codeaddr if DEBUG;
  poke($ppaddr, pack "L!", $codeaddr);
  <> if DEBUG; # Pause when debugging
}

sub make_output {
  my(@output) = @_;
  my $code = join "", @output;
  Internals::SvREFCNT($code, 10); # Leaky, on purpose

  if(DEBUG) {
    warn "# Size: ", length $code, "\n";
    open my $fh, "|-", "hexdump", "-C" or die $!;
    print $fh $code;
  }

  unpack "L!", pack "p", $code;
}

1&&"Kaboom"

__END__

=head1 NAME

Acme::ASM - Pure Perl x86 assembly

=head1 SYNOPSIS

  use Acme::ASM;

  sub foo :x86 {
    mov $eax, 2;
    print $eax;
  }

=head1 DESCRIPTION

B<This is an L<Acme> module. That means you I<really> don't want to use it, no
really, don't even think about it.> L<In case that's not
clear|http://en.wikipedia.org/wiki/File:Acme2.jpg>.

=cut
