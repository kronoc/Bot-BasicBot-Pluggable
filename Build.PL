
use strict;
use warnings;

use Module::Build 0.3601;

my %module_build_args = (
                       'dist_abstract' => 'extended simple IRC bot for pluggable modules',
                       'script_files' => [
                                           'bin/bot-basicbot-pluggable',
                                           'bin/bot-basicbot-pluggable-cgi',
                                           'bin/bot-basicbot-pluggable-cli',
                                           'bin/bot-basicbot-pluggable-infobot-upgrade',
                                           'bin/storable2dbi.pl'
                                         ],
                       'license' => 'perl',
                       'build_requires' => {
                                             'Test::Perl::Critic' => '0',
                                             'Test::More' => '0',
                                             'FindBin' => '0',
                                             'Test::PerlTidy' => '0',
                                             'Module::Build' => '0.3601'
                                           },
                       'dist_name' => 'Bot-BasicBot-Pluggable',
                       'dist_author' => [
                                          'Mario Domgoergen <mdom@cpan.org>'
                                        ],
                       'module_name' => 'Bot::BasicBot::Pluggable',
                       'requires' => {
                                       'DBM::Deep' => '0',
                                       'File::Spec' => '0',
                                       'Config::Find' => '0',
                                       'Storable' => '0',
                                       'Moose::Util::TypeConstraints' => '0',
                                       'CGI' => '0',
                                       'URI::Title' => '0',
                                       'Test::Builder::Module' => '0',
                                       'Log::Log4perl::Level' => '0',
                                       'Module::Load' => '0',
                                       'Socket' => '0',
                                       'List::MoreUtils' => '0',
                                       'Moose' => '0',
                                       'URI::Find::Simple' => '0',
                                       'DBI' => '0',
                                       'MooseX::SimpleConfig' => '0',
                                       'Module::Pluggable' => '0',
                                       'File::Copy' => '0',
                                       'Try::Tiny' => '0',
                                       'MooseX::Getopt::Dashes' => '0',
                                       'URI' => '0',
                                       'XML::Feed' => '0',
                                       'Data::Dumper' => '0',
                                       'Bot::BasicBot' => '0.60',
                                       'Carp' => '0',
                                       'perl' => '5.8.0',
                                       'LWP::UserAgent' => '0',
                                       'File::Temp' => '0',
                                       'Text::Unidecode' => '0',
                                       'Log::Log4perl' => '0',
                                       'POE' => '0'
                                     },
                       'configure_requires' => {
                                                 'ExtUtils::MakeMaker' => '6.31',
                                                 'Module::Build' => '0.3601'
                                               },
                       'dist_version' => '0.87'
                     );


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
