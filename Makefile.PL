
use strict;
use warnings;

BEGIN { require 5.8.0; }

use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'extended simple IRC bot for pluggable modules',
  'AUTHOR' => 'Mario Domgoergen <mdom@cpan.org>',
  'BUILD_REQUIRES' => {
    'DBD::SQLite' => '0',
    'FindBin' => '0',
    'Module::Build' => '0.3601',
    'Test::More' => '0',
    'YAML::XS' => '0'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.31',
    'Module::Build' => '0.3601'
  },
  'DISTNAME' => 'Bot-BasicBot-Pluggable',
  'EXE_FILES' => [
    'bin/bot-basicbot-pluggable',
    'bin/bot-basicbot-pluggable-cgi',
    'bin/bot-basicbot-pluggable-cli',
    'bin/bot-basicbot-pluggable-infobot-upgrade',
    'bin/storable2dbi.pl'
  ],
  'LICENSE' => 'perl',
  'NAME' => 'Bot::BasicBot::Pluggable',
  'PREREQ_PM' => {
    'Bot::BasicBot' => '0.60',
    'CGI' => '0',
    'Carp' => '0',
    'Config::Find' => '0',
    'DBI' => '0',
    'DBM::Deep' => '0',
    'Data::Dumper' => '0',
    'File::Copy' => '0',
    'File::Spec' => '0',
    'File::Temp' => '0',
    'LWP::UserAgent' => '0',
    'List::MoreUtils' => '0',
    'Log::Log4perl' => '0',
    'Log::Log4perl::Level' => '0',
    'Module::Load' => '0',
    'Module::Pluggable' => '0',
    'Moose' => '0',
    'Moose::Util::TypeConstraints' => '0',
    'MooseX::Getopt::Dashes' => '0',
    'MooseX::SimpleConfig' => '0',
    'POE' => '0',
    'Socket' => '0',
    'Storable' => '0',
    'Text::Unidecode' => '0',
    'Try::Tiny' => '0',
    'URI' => '0',
    'URI::Find::Simple' => '0',
    'URI::Title' => '0',
    'XML::Feed' => '0'
  },
  'VERSION' => '0.89',
  'test' => {
    'TESTS' => 't/*.t'
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



