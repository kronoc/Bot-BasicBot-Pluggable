package Bot::BasicBot::Pluggable::Module::Base;
our $VERSION = '0.05';

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

# Sets a local variable
sub set {
    my ($self, $name, $val) = @_;
    $self->{store}{vars}{$name} = $val;
    $self->save();
    return $self->{store}{vars}{$name};
}

# Gets a local variable
sub get {
    my ($self, $name) = @_;
    return $self->{store}{vars}{$name};
}

# unsets a local variable
sub unset {
    my ($self, $name) = @_;
    delete $self->{store}{vars}{$name};
    $self->save();
}

# Saves to local bot store to a Storable file. You don't really need
# to worry about this unless you're putting object in the store.
sub save {
    my ($self, $hash, $filename) = @_;
    $filename ||= $self->{Name}.".storable";
    my $save = $hash || $self->{store};
    return unless $save;
    store($save, $filename);
}

# load the Storable file and put into the store.
sub load {
    my ($self) = @_;
    my $filename = $self->{Name}.".storable";
    return unless (-e $filename);
    $self->{store} = retrieve $filename;
    return $self->{store};
}

# Called when the bot hears something. Probably something you want
# to override.
sub said {
    my ($self, $mess, $pri) = @_;
    my $body = $mess->{body};

    return unless ($pri == 2); # most common

    my ($command, $param) = split(/\s+/, $body, 2);
    $command = lc($command);

    return;
}

# Called when we connect to the server. you might want to override this.
sub connected {
}

# Called once we're created, and load() has been run. Useful for
# object creation, etc.
sub init {
}

# Called when a user asks for help on a topic. Should return some
# useful help text.
sub help {
    my ($self, $mess) = @_;
    return "No help for: $self->{Name}. This is a bug.";
}


1;
