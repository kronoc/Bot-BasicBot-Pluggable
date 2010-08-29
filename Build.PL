
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  'build_requires' => {
    'FindBin' => '0',
    'Module::Build' => '0.3601',
    'Test::More' => '0'
  },
  'configure_requires' => {
    'ExtUtils::MakeMaker' => '6.31',
    'Module::Build' => '0.3601'
  },
  'dist_abstract' => 'extended simple IRC bot for pluggable modules',
  'dist_author' => [
    'Mario Domgoergen <mdom@cpan.org>'
  ],
  'dist_name' => 'Bot-BasicBot-Pluggable',
  'dist_version' => '0.88',
  'license' => 'perl',
  'module_name' => 'Bot::BasicBot::Pluggable',
  'recommends' => {},
  'recursive_test_files' => 1,
  'requires' => {
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
    'XML::Feed' => '0',
    'perl' => '5.8.0'
  },
  'script_files' => [
    'bin/bot-basicbot-pluggable',
    'bin/bot-basicbot-pluggable-cgi',
    'bin/bot-basicbot-pluggable-cli',
    'bin/bot-basicbot-pluggable-infobot-upgrade',
    'bin/storable2dbi.pl'
  ]
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
