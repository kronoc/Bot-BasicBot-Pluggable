package App::Bot::BasicBot::Pluggable::Terminal;

use Moose;
use Bot::BasicBot::Pluggable::Terminal;
extends 'App::Bot::BasicBot::Pluggable';

has '+bot_class' => ( default => 'Bot::BasicBot::Pluggable::Terminal' ); 

1;

