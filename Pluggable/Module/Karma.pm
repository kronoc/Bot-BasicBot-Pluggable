package Bot::BasicBot::Pluggable::Module::Karma;
use Bot::BasicBot::Pluggable::Module::Base;
use base qw(Bot::BasicBot::Pluggable::Module::Base);

=head1 NAME

Bot::BasicBot::Pluggable::Module::Karma

=head1 SYNOPSIS

Tracks Karma for various concepts

=head1 IRC USAGE

Commands:

=over 4

=item <thing>++ # <comment>

Increases the kerma for <thing>

=item <thing>-- # <comment>

Decreases the karma for <thing>

=item karma <thing>

Replies with the karma rating for <thing>

=item explain karma <thing>

Lists the good and bad things said about <thing>

=back

=cut

sub init {
    my $self = shift;

    # the Blog module requires a mysql database
    my $dsn = "DBI:mysql:database=$self->{store}{vars}{db_name}";
    my $user = $self->{store}{vars}{db_user};
    my $pass = $self->{store}{vars}{db_pass};

    $self->{DB} = DBI->connect($dsn, $user, $pass)
        or warn "Can't connect to database";

}

sub said {
    my ($self, $mess, $pri) = @_;
    my $body = $mess->{body};

    return unless $self->{DB};

    my ($command, $param) = split(/\s+/, $body, 2);
    $command = lc($command);
    $param =~ s/\?$// if $param;
    
    if ($command eq "karma" and $pri == 2 and $param) {
        return "$param has karma ".$self->get_karma($param);
    } elsif ($command eq "explain" and $pri == 2 and $param) {
        $param =~ s/^karma\s+//i;
        my ($karma, $good, $bad) = $self->get_karma($param);
        my $reply = "$param has karma ".$self->get_karma($param).". ";
        $reply .= "good: ".(join(", ", @$good) || "nothing").". ";
        $reply .= "bad: ".(join(", ", @$bad) || "nothing").".";
        return $reply;
    }

    if ($pri == 0 and (($body =~ /(\w+)\+\+/) or ($body =~ /\(([\w\s]+)\)\+\+/))) {
        print STDERR "$1++\n";
        $self->add_karma($1, 1, $', $mess->{who});
    } elsif (($body =~ /(\w+)\-\-/) or ($body =~ /\(([\w\s]+)\)\-\-/)) {
        print STDERR "$1--\n";
        $self->add_karma($1, 0, $', $mess->{who});
    }    
}

sub get_karma {
    my ($self, $object) = @_;
    my $query = $self->{DB}->prepare("SELECT * FROM karma WHERE object=?");
    $query->execute($object);
    my $karma = 0;
    my @good;
    my @bad;
    while (my $row = $query->fetchrow_hashref) {
        if ($row->{positive}) {
            $karma++;
            push(@good, $row->{reason}) if $row->{reason};
        } else {
            $karma--;
            push(@bad, $row->{reason}) if $row->{reason};
        }
    }

    if (wantarray()) {
        return ($karma, \@good, \@bad);
    } else {
        return $karma;
    }
}
        
sub add_karma {
    my ($self, $object, $good, $reason, $who) = @_;
    $reason =~ s/^\s*#\s*//;
    my $query = $self->{DB}->prepare("INSERT INTO karma (create_time, create_who, object, positive, reason) VALUES (?, ?, ?, ?, ?);");
    $query->execute(time, $who, $object, $good, $reason);
    return;
}
    
1;
