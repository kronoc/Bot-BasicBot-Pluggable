package Bot::BasicBot::Pluggable::Module::Infobot;
use Bot::BasicBot::Pluggable::Module::Base;
use base qw(Bot::BasicBot::Pluggable::Module::Base);

=head1 NAME

Bot::BasicBot::Pluggable::Module::Infobot

=head1 SYNOPSIS

Does infobot things - basically remmebers and returns factoids. Will ask
another infobot about factoids that it doesn't know about, if you want.

=head1 IRC USAGE

Assume the bot is called 'eric'. Then you'd use the infobot as follows.

  me: eric, water is wet.
  eric: Ok, water is wet.
  me: water?
  eric: water is wet.
  me: eric, water is also blue.
  eric: ok, water is also blue.
  me: eric, water?
  eric: water is wet or blue.
  
etc, etc.

a response that begins <reply> will have the '<noun> is' stripped, so

  me: eric, what happen is <reply>somebody set us up the bomb
  eric: ok, what happen is <reply>somebody set us up the bomb.
  me: what happen?
  eric: somebody set us up the bomb

just don't do that in #london.pm.

Likewise, a response that begins <action> will be emoted as a response,
instead of said. Putting '|' characters in the reply indicates different
possible answers, and the bot will pick one at random.

  me: eric, dice is one|two|three|four|five|six
  eric: ok, dice is one|two|three|four|five|six
  me: eric, dice?
  eric: two.
  me: eric, dice?
  eric: four.
  
Finally, you can read RSS feeds:

  me: eric, jerakeen.org is <rss="http://jerakeen.org/index.rdf">
  eric: ok, jerakeen.org is...
  
ok, you get the idea.

You can also tell the bot to learn a factoid from another bot, as follows:

  me: eric, learn fact from dispy
  eric: learnt 'fact is very boring' from dipsy.
  me: fact?
  eric: fact is very boring
  
=head1 VARS

=over 4

=item ask

Set this to the nick of an infobot and your bot will ask them about factoids
that we don't know about, and forward them on (with attribution).

=back

=cut



use DBI;

my $do_rss;
use XML::RSS;
use LWP::Simple;

sub init {
    my $self = shift;

    $self->{store}{vars}{ask} = '' unless defined($self->{store}{vars}{ask});
    $self->{infobot} = {};

    # the Infobot module requires a mysql database
    my $dsn = "DBI:mysql:database=$self->{store}{vars}{db_name}";
    my $user = $self->{store}{vars}{db_user};
    my $pass = $self->{store}{vars}{db_pass};

    $self->{DB} = DBI->connect($dsn, $user, $pass)
        or warn "Can't connect to database";

}

sub said {
    my ($self, $mess, $pri) = @_;

    my $body = $mess->{body};
    $body =~ s/\s+$//;
    $body =~ s/^\s+//;
    
    if ($body =~ s/^:INFOBOT:REPLY (\S+) (.*)$// and $pri == 0) {
        my $return = $2;
        my $infobot_data = $self->{infobot}{$1};
        print STDERR "infobot reply from $mess->{who} about $1\n";
        print STDERR "  original question asked by $infobot_data->{who}\n";
        print STDERR "Unknown infobot ID $1!!\n" unless $infobot_data;
        my ($object, $db, $factoid) = ($return =~ /^(.*) =(\w+)=> (.*)$/);

        if ($infobot_data->{learn}) {
            $self->set_factoid($mess->{who}, $object, $db, $factoid);
            $factoid = "Learnt about $object from $mess->{who}";
            
        } else {

            my @possibles = split(/\|/, $factoid);
            $factoid = $possibles[int(rand(scalar(@possibles)))];
    
            $factoid =~ s/<rss\s*=\s*\"?([^>\"]+)\"?>/$self->parseRSS($1)/ieg;

            print STDERR "factoid is '$factoid'\n";
            if ($factoid =~ s/^<action>\s*//i) {
                $self->{Bot}->emote({who=>$infobot_data->{who}, channel=>$infobot_data->{channel}, body=>"$factoid (via $mess->{who})"});
                return 1;
            }

           $factoid = "$object $db $factoid" unless ($factoid =~ s/^<reply>\s*//i);

            return unless $factoid;
            $factoid .= " (via $mess->{who})";
        }
        
        my $shorter;
        while ($factoid) {
            $shorter .= substr($factoid, 0, 300, "");
        }

        $self->{Bot}->say(channel => $infobot_data->{channel},
                          who     => $infobot_data->{who},
                          body    => "$_"
                         ) for (split(/\n/, $shorter));
        return 1;
    }

    if ($body =~ s/\?$// and $pri == 3) {
        my $literal = 1 if ($body =~ s/^literal\s+//i);

        my $list = $self->get_factoid($body, $mess);
        my $reply;
        my $is_are;
        for my $row (@$list) {
            $reply .= " =or= " if $reply;
            $reply .= $row->{description};
            $is_are = $row->{is_are};
        }
        if (!$reply) {
            return undef unless $mess->{address};
            return "No clue. Sorry.";
        }

        return "$body =is= $reply" if $literal;

        my @possibles = split(/\|/, $reply);
        $reply = $possibles[int(rand(scalar(@possibles)))];

        $reply =~ s/<rss\s*=\s*\"?([^>\"]+)\"?>/$self->parseRSS($1)/ieg;

        if ($reply =~ s/^<action>\s*//i) {
            $self->{Bot}->emote({who=>$mess->{who}, channel=>$mess->{channel}, body=>$reply});
            return 1;
        }

        $reply = "$body $is_are $reply" unless ($reply =~ s/^<reply>\s*//i);
        return $reply;
    }

    return unless ($mess->{address} and $pri == 2);

    if ($body =~ /^forget\s+(.*)$/i) {
        my $list = $self->get_factoid($1);
        if ($list) {
            for (@$list) {
                $self->delete_factoid($_->{id});
            }
            return "I forgot about $1";
        } else {
            return "I don't know anything about $1";
        }
    }
    
    print STDERR "infobot checking body is $body\n";
    if ($body =~ /^learn\s+(\S+)\s+from\s+(\S+)$/i) {
        my $list = $self->get_factoid($1);
        if ($list) {
            return "I already know about $1";
        }
        $mess->{learn} = 1;
        $self->get_factoid($1, $mess, $2);
        return "asking $2 about $1..\n";
    }
    
    return undef unless ($body =~ /\s+(is)\s+/i or $body =~ /\s+(are)\s+/i);
    my $is_are = $1;

    my ($object, $description) = split(/\s+$is_are\s+/i, $body, 2);
    $description =~ s/\.\s.*$//;
            
    if ($self->get_factoid($object)) {

        if ($description =~ s/also\s+//i) {
            $self->set_factoid($mess->{who}, $object, $is_are, $description);
            return "ok. $object $is_are also $description";
        } else {
            return "but I already know something about $object";
        }

    } else {
        $self->set_factoid($mess->{who}, $object, $is_are, $description);
        return "ok. $object $is_are $description";
    }

    return undef;
    
}

sub get_factoid {
    my ($self, $object, $mess, $from) = @_;
    print STDERR "get_factoid $object\n";
    return undef unless $self->{DB};
    my $query = $self->{DB}->prepare("SELECT * FROM infobot WHERE object=?");
    $query->execute($object);
    my @rows;
    while (my $row = $query->fetchrow_hashref) {
        push(@rows, $row);
    }
    unless ($rows[0]) {
        if ($self->{store}{vars}{ask} and $mess) {
            my $id = "<" . int(rand(10000)) . ">";
            print STDERR "Asking $self->{store}{vars}{ask} about $object with id $id\n";
            $self->{infobot}{$id} = $mess;
            $self->{Bot}->say(who=>$from || $self->{store}{vars}{ask},
                              channel=>'msg',
                              body=>":INFOBOT:QUERY $id $object"
                             );
        }
        return undef;
    }
    return \@rows;
}

sub set_factoid {
    my ($self, $who, $object, $is_are, $description) = @_;
    my $query = $self->{DB}->prepare("INSERT INTO infobot (create_time, create_who, object, is_are, description) VALUES (?, ?, ?, ?, ?)");
    $query->execute(time, $who, $object, $is_are, $description);
}

sub delete_factoid {
    my ($self, $id) = @_;
    my $query = $self->{DB}->prepare("DELETE FROM infobot WHERE id=?");
    $query->execute($id);
}

sub parseRSS {
    my ($self, $url) = @_;

    my $items;
    eval '
        my $rss = new XML::RSS;
        $rss->parse(get($url));
        $items = $rss->{items};
    ';

    return "<< Error parsing RSS from $url: $@ >>" if $@;
    my $ret;
    foreach my $item (@$items) {
        my $title = $item->{title};
        $title =~ s/\s+/ /;
        $title =~ s/\n//g;
        $title =~ s/\s+$//;
        $title =~ s/^\s+//;
        $ret .= "$item->{'title'}; ";
    }
    return $ret;
}


1;
