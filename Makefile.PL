use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'		=> 'Bot::BasicBot::Pluggable',
    'VERSION_FROM'	=> 'Pluggable.pm', # finds $VERSION
    'PREREQ_PM'		=> {
                              'Bot::BasicBot'=>'0.04',
                           },
    ($] >= 5.005 ?
      (ABSTRACT_FROM => 'Pluggable.pm', # retrieve abstract from module
       AUTHOR     => 'Tom Insam <tom@jerakeen.org>') : ()),
);
