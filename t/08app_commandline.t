use strict;
use warnings;
use Test::More tests => 9;
use App::Bot::BasicBot::Pluggable;

our @ARGV = (
    qw(
      --server irc
      --port 6666
      --nick botbasic
      --charset latin1
      --store type=Storable
      --module Karma
      --channel foo
      --channel bar
      --list-modules
      --list-stores
      --password foobar
      )
);

my $app = App::Bot::BasicBot::Pluggable->new_with_options();

is( $app->server,  'irc',      'setting server via commandline' );
is( $app->port,    6666,       'setting port via commandline' );
is( $app->nick,    'botbasic', 'setting basicbot via commandline' );
is( $app->charset, 'latin1',   'setting charset via commandline' );
isa_ok( $app->store,  'Bot::BasicBot::Pluggable::Store::Storable', 'store via commandline' );
ok( $app->list_modules, 'setting list_modules via commandline' );
ok( $app->list_stores,  'setting list_stores via commandline' );

is_deeply(
    $app->module,
    [ 'Karma', 'Auth' ],
    'setting modules via commandline and implicit loading of Auth for --password'
);

is_deeply(
    $app->channel,
    [ '#foo', '#bar' ],
    'setting channel via commandline'
);
