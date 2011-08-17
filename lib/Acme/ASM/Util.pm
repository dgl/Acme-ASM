package Acme::ASM::Util;
use strict;
use warnings;
use base "Exporter";

use DynaLoader ();
use Encode qw(encode_utf8);
#use OS::ABI::Constants;

our @EXPORT_OK = qw(poke dlsym pv);

=for todo

Rather than syscall(SYS_read, ...) consider:
 < rurban> riba: see http://www.perlmonks.org/?node_id=379428 and
                 http://groups.google.com/group/alt.hackers/msg/8ce9ba2e5554e8e6?pli=1 for pp poke
 <+dipsy> [ Synthetic strings dereference arbitrary pointers ]
 < riba> rurban: holy shit

=cut

sub poke {
  my($address, $data) = @_;
  pipe(my $r_fh, my $w_fh);

  # Write the data to the writing FD of the pipe
  syswrite($w_fh, $data);

  # Read the data into the memory address we want it at (i.e. a memory write!)
  syscall(
    #OS::ABI::Constants::constants->{syscall}->{SYS_read},
    3, # OSX
    fileno $r_fh, $address, length $data);
}

sub dlsym {
  my($symbol) = @_;
  for my $lib(@DynaLoader::dl_librefs) {
    my $sym = DynaLoader::dl_find_symbol($lib, $symbol);
    return $sym if $sym;
  }
  DynaLoader::dl_find_symbol(DynaLoader::dl_load_file("", 0), $symbol);
}

sub pv {
  unpack "L!", pack "p", shift;
}

1;
