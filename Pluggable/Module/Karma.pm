package Bot::BasicBot::Pluggable::Module::Karma;
use Bot::BasicBot::Pluggable::Module::Base;
use base qw(Bot::BasicBot::Pluggable::Module::Base);
our $VERSION = '0.05';

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

sub said {
    my ($self, $mess, $pri) = @_;
    my $body = $mess->{body};

    my ($command, $param) = split(/\s+/, $body, 2);
    $command = lc($command);
    $param =~ s/\?*\s*$// if $param;
    
    if ($command eq "karma" and $pri == 2 and $param) {
        return "$param has karma of ".$self->get_karma($param);
    } elsif ($command eq "explain" and $pri == 2 and $param) {
        $param =~ s/^karma\s+//i;
        my ($karma, $good, $bad) = $self->get_karma($param);
        $self->trim_list($good, 3);
        $self->trim_list($bad, 3);

        my $reply = "";
        $reply .= "positive: ".(join(", ", @$good) || "nothing").". ";
        $reply .= "negative: ".(join(", ", @$bad) || "nothing").". ";
        $reply .= "overall: ".$self->get_karma($param);

        return $reply;
    }

    if ($pri == 0) {
        if (($body =~ /(\w+)\+\+\s*#?\s*/) or ($body =~ /\(([\w\s]+)\)\+\+\s*#?\s*/)) {
            print STDERR "$1++\n";
            $self->add_karma($1, 1, $', $mess->{who});
        } elsif (($body =~ /(\w+)\-\-/) or ($body =~ /\(([\w\s]+)\)\-\-/)) {
            print STDERR "$1--\n";
            $self->add_karma($1, 0, $', $mess->{who});
        }    
    }
}

sub trim_list {
    my ($self, $list, $count) = @_;
    
    if (scalar(@$list) > $count) {
        @$list = splice(@$list, 0, -1*$count);
    }

}

sub get_karma {
    my ($self, $object) = @_;
    my @changes = @{$self->{store}{karma}{$object}};

    my @good;
    my @bad;
    my $karma = 0;

    for my $row (@changes) {
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
    my $row = { reason=>$reason, who=>$who, timestamp=>time, positive=>$good };
    push @{$self->{store}{karma}{$object}}, $row;
    $self->save();
    return;
}
    
1;