package Bot::BasicBot::Pluggable::Module::Shout;
use Bot::BasicBot::Pluggable::Module::Base;
use base qw(Bot::BasicBot::Pluggable::Module::Base);


sub init {
    my $self = shift;
}

sub said {
    my ($self, $mess, $pri) = @_;
    my $body = $mess->{body};

    if ($pri == 0) {
        my @words = split(/\s+/, $body);
        my $shouts = 0;
        for (@words) {
            $shouts++ if ($_ eq uc($_));
        }
        push(@{$self->{store}{shouters}{$mess->{who}}}, { time=>time, shouts=>$shouts } );
    }
    

    if ($pri == 2) {
        my ($command, $param) = split(/\s+/, $body, 2);
        $command = lc($command);
        $command =~ s/\?$//;
        if ($command eq "shouters") {
            my @shouters = @{$self->shouters()};
            $#shouters = 5 if $#shouters > 5;
            my @shouters_recent = @{$self->shouters_recent()};
            $#shouters_recent = 5 if $#shouters_recent > 5;
            my $reply = "Top 5 shouters: (average shouts per line)\n";
            $reply .= "Long term: ". join(", ", map { "$_->{Name}: $_->{average}" } @shouters)."\n";
            $reply .= "Short term: ". join(", ", map { "$_->{Name}: $_->{average}" } @shouters_recent);
            return $reply;
        }
    }
}

sub shouters {
    my ($self) = @_;

    my @shouters;

    for my $name (keys(%{$self->{store}{shouters}})) {
        my @numbers = map { $_->{shouts} } @{$self->{store}{shouters}{$name}};
        my $average = 0;
        $average += $_ for @numbers;
        $average /= $#numbers if $#numbers > 0;
        push(@shouters, { name=>$name, average=>substr($average, 0, 4) } );
    }

    @shouters = sort { $b->{average} <=> $a->{average} } @shouters;
    return \@shouters;
}

sub shouters_recent {
    my ($self) = @_;

    my @shouters;

    for my $name (keys(%{$self->{store}{shouters}})) {
        my @numbers = map { $_->{shouts} if (time - $_->{time} < 3600) } @{$self->{store}{shouters}{$name}};
        my $average = 0;
        $average += $_ for @numbers;
        $average /= $#numbers if $#numbers > 0;
        push(@shouters, { name=>$name, average=>substr($average, 0, 4) } );
    }

    @shouters = sort { $b->{average} <=> $a->{average} } @shouters;
    return \@shouters;
}

1;
