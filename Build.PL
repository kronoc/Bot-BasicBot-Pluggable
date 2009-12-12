#!/usr/bin/perl
use warnings;
use strict;

use Module::Build;

Module::Build->new(
    module_name => 'Bot::BasicBot::Pluggable',
    license     => 'perl',
    requires    => {
        'Log::Log4perl'        => 0,
        'Bot::BasicBot'        => '0.60',
        'Config::Find'         => 0,
        'Getopt::Long'         => 0,
        'List::MoreUtils'      => 0,
        'LWP::UserAgent'       => 0,
        'Module::Pluggable'    => 0,
        'Moose'                => 0,
        'MooseX::Getopt'       => 0,
        'MooseX::SimpleConfig' => 0,
        'perl'                 => '5.8.0',
        'Test::More'           => '0.01',
        'Text::Unidecode'      => 0,
        'URI::Find::Simple'    => 0,
        'URI::Title'           => '0.1',
        'Try::Tiny'            => 0,
    },
    recommends => {
        'XML::Feed'   => 0,
        'DBD::SQLite' => 0,
        'DBI'         => 0,
        'DBM::Deep'   => 0,
    },
    script_files       => [ 'bin/bot-basicbot-pluggable', ],
    create_makefile_pl => 'passthrough',
    create_readme      => 1,
    meta_merge         => {
        resources =>
          { repository => 'http://github.com/mdom/bot-basicbot-pluggable', },
    }
)->create_build_script;

