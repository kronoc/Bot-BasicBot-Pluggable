package Bot::BasicBot::Pluggable::Module::Base;
our $VERSION = '0.04';

=head1 NAME

Bot::BasicBot::Pluggable::Module::Base

=head1 SYNOPSIS

The base module for all Bot::BasicBot::Pluggable modules. Inherit from this
to get all sorts of exciting things.

=head1 IRC INTERFACE

There isn't one - the 'real' modules inherit from this one.

=head1 MODULE INTERFACE

You need to override the 'said' and the 'help' methods. help() should return
the help text for the module.

=head1 BUGS

The {store} isn't any good for /big/ data sets, like the infobot sets. We
need a better solution, probably involving Tie.

=cut


use Storable;
use Data::Dumper;

sub new {
    my $class = shift;
    my %param = @_;
    my $self = \%param;
    bless $self, $class;


    $self->load();
    $self->init();

    return $self;
}

sub init {
}

sub help {
    my ($self, $mess) = @_;
    return "No help for: $self->{Name}";
}

sub save {
    my ($self, $hash, $filename) = @_;
    $filename ||= $self->{Name}.".storable";
    my $save = $hash || $self->{store};
    return unless $save;
    store($save, $filename);
}

sub load {
    my ($self) = @_;
    my $filename = $self->{Name}.".storable";
    return unless (-e $filename);
    $self->{store} = retrieve $filename;
    return $self->{store};
}

sub said {
    my ($self, $mess, $pri) = @_;
    my $body = $mess->{body};

    return unless ($pri == 2); # most common

    my ($command, $param) = split(/\s+/, $body, 2);
    $command = lc($command);

    return;
}

sub connected {
}

1;
