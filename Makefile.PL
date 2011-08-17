use ExtUtils::MakeMaker;

my %opt;
if(eval { ExtUtils::MakeMaker->VERSION(6.46) }) {
  $opt{META_MERGE} = {
    resources => {
      repository => 'https://github.com/dgl/Acme-ASM'
    }
  }
}

WriteMakefile(
  NAME    => 'Acme::ASM',
  AUTHOR  => 'David Leadbeater <dgl@dgl.cx>',
  VERSION_FROM       => 'lib/Acme/ASM.pm',
  ABSTRACT_FROM      => 'lib/Acme/ASM.pm',
  %opt
);
