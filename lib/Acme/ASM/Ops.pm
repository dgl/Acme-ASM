package Acme::ASM::Ops;
use strict;
use warnings;
use Carp;
use Scalar::Util qw(looks_like_number);

use vars qw(@output);
*output = \*Acme::ASM::output;

# Return 32 bits as big-endian split chars
sub b32($) {
  map ord, split //, pack "L", @_;
}

my %ops = (
  mov => sub($$) {
    my($d, $s) = @_;
    my $pre = "";
    
    if(UNIVERSAL::isa($s, "Acme::ASM::Register")
        && UNIVERSAL::isa($d, "Acme::ASM::Register")) {
      # r r
      my $modrm = modrm($s, $d, \$pre);
      0x89, $modrm
    }
    elsif(UNIVERSAL::isa($d, "Acme::ASM::Register")
        && looks_like_number($s)) {
      # r imm
      0xb8 | $d->{b}, b32 $s;
    }
    elsif(UNIVERSAL::isa($d, "Acme::ASM::Register")
        && ref $s eq 'SCALAR') {
      my $v = b32 unpack "L!", pack "p", $s;
      # r imm
      0xb8 | $d->{b}, $v;
    }
    else {
      die "Todo ($d->{n}, $s->{n})";
    }
  },
  # Really push, but that conflicts with Perl's builtin
  pushl => sub {
    my($arg) = @_;
    croak "Need a register" unless !ref $arg || $arg->isa("Acme::ASM::Register");
    0x50 | $arg->{b};
  },
  call => sub {
    my $arg = shift;
    if(UNIVERSAL::isa($arg, "Acme::ASM::Register")) {
      0xff, modrm($arg, undef);
    }
    else {
      croak "Unimplemented"; # TODO: Relative addressing
      0xe8, b32 shift;
    }
  },
  leave => sub {
    0xc9;
  },
  ret => sub {
    0xc3;
  }
);

sub import {
  my($class, $level) = @_;
  $level = 0 unless defined $level;

  no strict 'refs';
  for my $op(keys %ops) {
    *{caller($level) . "::$op"} = sub {
      if(Acme::ASM::DEBUG()) {
        warn "  $op ", join(", ",
          map { ref eq 'Acme::ASM::Register' ? "\$$_->{n}" : $_ } @_), "\n";
      }
      push @output, map chr, $ops{$op}->(@_);
    };
  }
}

# Calculate modrm byte
sub modrm {
  my($d, $s, $pre) = @_;

  my $byte = 0;

  if(UNIVERSAL::isa($s, "Acme::ASM::Register")) {
    $byte |= $s->{b};
    #$$pre |= $s->{rex} ? 0 : 0x44;
  } elsif(ref $s eq 'ARRAY') {
  } else {
  }

  if(UNIVERSAL::isa($d, "Acme::ASM::Register")) {
    $byte |= (13 << 4) | $d->{b};
    #$$pre |= $d->{rex} ? 0 : 0x48;
  } elsif(ref $d eq 'ARRAY') {
  } else {
  }

  return $byte;
}

1&&"PS: Helpful reference here: http://ref.x86asm.net/coder64.html"
