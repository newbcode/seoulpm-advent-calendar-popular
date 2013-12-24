#!/usr/bin/env perl

use utf8;
use DBI;
use Encode qw(encode decode);
use DateTime;
use LWP::UserAgent;
use Data::Printer;
use Mojo::UserAgent;

use Mojolicious::Lite;

# Documentation browser under "/perldoc"
plugin 'PODRenderer';

my $config = plugin 'Config';

my $DBH = DBI->connect (
    'dbi:mysql:Advpop',
    "$ENV{ADV_DB_ID}",
    "$ENV{ADV_DB_PW}",
    {
        RaiseError        => 1,
        AutoCommit        => 1,
        mysql_enable_utf8 => 1,
    },
);

my $sth = $DBH->prepare(qq{ SELECT id, author, title, url, abst, likesum, wdate FROM adv_2010 });
$sth->execute();
my @row = $sth->fetchrow_array;

if ( @row ){
    print "No Data\n";
}
else {
    my @top_tens;
    my $cnt = 1;
    my @years = qw/2010 2011 2012 2013/;
    
    foreach my $year_p ( @years ) {
        my %adv_data = adv_cal($year_p);

        foreach my $p ( keys %adv_data ) {
            push @top_tens, $adv_data{$p};
        }

        @top_tens = sort { $b->[4] <=> $a->[4] } @top_tens;
        my $table = "adv_$year_p";

        foreach my $rank_p ( @top_tens ) {
            my ($title, $author, $url, $desc) = web_parser($rank_p->[0], $year_p);
            
            my $sth = $DBH->prepare(qq{ INSERT INTO `$table` (`author`, `title`, `url`, `abst`, `likesum`, `year`) VALUES (?,?,?,?,?,?) });

            $sth->execute( $author, $title, $url, $desc, $rank_p->[4], $year_p );
            $cnt++;
            last if ($cnt == 25);
        }
    @top_tens = ();
    }
}

get '/' => sub {
    my $self = shift;
    
    my $sth = $DBH->prepare(qq{ SELECT id, author, title, url, likesum, wdate FROM adv_2013 });
    $sth->execute();

    my %articles;
    while ( my @row = $sth->fetchrow_array ) {
        my ( $id, $author, $title, $url, $likesum, $year, $wdate ) = @row;
        #my ( $wdate ) = split / /, $date;
        
        $articles{$id} = {
            author  => $author,
            title   => $title,
            url     => $url,
            likesun => $likesum,
            year    => $year,
            wdate   => $wdate,
        };
    }
    $self->stash( articles => \%articles );

} => 'index_2013';

get '/advpop_2010' => sub {
    my $self = shift;
    
    my $sth = $DBH->prepare(qq{ SELECT id, author, title, url, likesum, wdate FROM adv_2010 });
    $sth->execute();

    my %articles;
    while ( my @row = $sth->fetchrow_array ) {
        my ( $id, $author, $title, $url, $likesum, $year, $wdate ) = @row;
        #my ( $wdate ) = split / /, $date;
        
        $articles{$id} = {
            author  => $author,
            title   => $title,
            url     => $url,
            likesun => $likesum,
            year    => $year,
            wdate   => $wdate,
        };
    }
    $self->stash( articles => \%articles );

} => 'index_2010';

get '/advpop_2011' => sub {
    my $self = shift;
    
    my $sth = $DBH->prepare(qq{ SELECT id, author, title, url, likesum, wdate FROM adv_2011 });
    $sth->execute();

    my %articles;
    while ( my @row = $sth->fetchrow_array ) {
        my ( $id, $author, $title, $url, $likesum, $year, $wdate ) = @row;
        #my ( $wdate ) = split / /, $date;
        
        $articles{$id} = {
            author  => $author,
            title   => $title,
            url     => $url,
            likesun => $likesum,
            year    => $year,
            wdate   => $wdate,
        };
    }
    $self->stash( articles => \%articles );

} => 'index_2011';

get '/advpop_2012' => sub {
    my $self = shift;
    
    my $sth = $DBH->prepare(qq{ SELECT id, author, title, url, likesum, wdate FROM adv_2012 });
    $sth->execute();

    my %articles;
    while ( my @row = $sth->fetchrow_array ) {
        my ( $id, $author, $title, $url, $likesum, $year, $wdate ) = @row;
        #my ( $wdate ) = split / /, $date;
        
        $articles{$id} = {
            author  => $author,
            title   => $title,
            url     => $url,
            likesun => $likesum,
            year    => $year,
            wdate   => $wdate,
        };
    }
    $self->stash( articles => \%articles );

} => 'index_2012';

get '/advpop_2013' => sub {
    my $self = shift;
    
    my $sth = $DBH->prepare(qq{ SELECT id, author, title, url, likesum, wdate FROM adv_2013 });
    $sth->execute();

    my %articles;
    while ( my @row = $sth->fetchrow_array ) {
        my ( $id, $author, $title, $url, $likesum, $year, $wdate ) = @row;
        #my ( $wdate ) = split / /, $date;
        
        $articles{$id} = {
            author  => $author,
            title   => $title,
            url     => $url,
            likesun => $likesum,
            year    => $year,
            wdate   => $wdate,
        };
    }
    $self->stash( articles => \%articles );

} => 'index_2013';

get '/rank_2010' => sub {
    my $self = shift;
    
    my $sth = $DBH->prepare(qq{ SELECT id, author, title, url, likesum, year, wdate FROM adv_2010 });
    $sth->execute();

    my %articles;
    while ( my @row = $sth->fetchrow_array ) {
        my ( $id, $author, $title, $url, $likesum, $year, $date ) = @row;
        my ( $wdate ) = split / /, $date;
        
        $articles{$id} = {
            author  => $author,
            title   => $title,
            url     => $url,
            likesum => $likesum,
            year    => $year,
            wdate   => $wdate,
        };
    }
    $self->stash( articles => \%articles );

} => 'rank';

get '/rank_2011' => sub {
    my $self = shift;
    
    my $sth = $DBH->prepare(qq{ SELECT id, author, title, url, likesum, year, wdate FROM adv_2011 });
    $sth->execute();

    my %articles;
    while ( my @row = $sth->fetchrow_array ) {
        my ( $id, $author, $title, $url, $likesum, $year, $date ) = @row;
        my ( $wdate ) = split / /, $date;
        
        $articles{$id} = {
            author  => $author,
            title   => $title,
            url     => $url,
            likesum => $likesum,
            year    => $year,
            wdate   => $wdate,
        };
    }
    $self->stash( articles => \%articles );

} => 'rank';

get '/rank_2012' => sub {
    my $self = shift;
    
    my $sth = $DBH->prepare(qq{ SELECT id, author, title, url, likesum, year, wdate FROM adv_2012 });
    $sth->execute();

    my %articles;
    while ( my @row = $sth->fetchrow_array ) {
        my ( $id, $author, $title, $url, $likesum, $year, $date ) = @row;
        my ( $wdate ) = split / /, $date;
        
        $articles{$id} = {
            author  => $author,
            title   => $title,
            url     => $url,
            likesum => $likesum,
            year    => $year,
            wdate   => $wdate,
        };
    }
    $self->stash( articles => \%articles );

} => 'rank';

get '/rank_2013' => sub {
    my $self = shift;
    
    my $sth = $DBH->prepare(qq{ SELECT id, author, title, url, likesum, year, wdate FROM adv_2013 });
    $sth->execute();

    my %articles;
    while ( my @row = $sth->fetchrow_array ) {
        my ( $id, $author, $title, $url, $likesum, $year, $date ) = @row;
        my ( $wdate ) = split / /, $date;
        
        $articles{$id} = {
            author  => $author,
            title   => $title,
            url     => $url,
            likesum => $likesum,
            year    => $year,
            wdate   => $wdate,
        };
    }
    $self->stash( articles => \%articles );

} => 'rank';

get '/summary' => sub {
    my $self = shift;
    
    my $sth = $DBH->prepare(qq{ SELECT id, author, title, url, abst, likesum, year, wdate FROM adv_2013 });
    $sth->execute();

    my %articles;
    while ( my @row = $sth->fetchrow_array ) {
        my ( $id, $author, $title, $url, $abst, $likesum, $year, $date ) = @row;
        my ( $wdate ) = split / /, $date;
        
        $articles{$id} = {
            author  => $author,
            title   => $title,
            url     => $url,
            abst    => $abst,
            likesum => $likesum,
            year    => $year,
            wdate   => $wdate,
        };
    }
    $self->stash( articles => \%articles );

} => 'summary';


app->start;

sub adv_cal {
    my $year = shift;
    my $ua = LWP::UserAgent->new;

    my $fb_api_url ='http://api.facebook.com/restserver.php?method=links.getStats&urls=';
    my $url_year = "http://advent.perl.kr/$year/$year-12-";
    my $start_num = 1;
    my ($url_gen, $adv_info, @urls);

    while ( $start_num <= 24 ) {
        if ( $start_num < 10 ) {
            $url_gen = "$fb_api_url$url_year"."0"."$start_num"."\.html";
            push @urls, $url_gen;
        }
        else {
            $url_gen = "$fb_api_url$url_year$start_num"."\.html";
            push @urls, $url_gen;
        }
        $start_num++;
    }

    my %adv_infos;
    foreach my $url (@urls) {
        my ( $argv_url, $share, $like, $comment, $total, $rank);
        my $response = $ua->get($url);

        if ($response->is_success) {

            my $likes =  $response->decoded_content;

            if ( $likes =~ /<url>(.+)<\/url>/ ) { $argv_url = $1; }
            if ( $likes =~ /<share_count>(\d+)<\/share_count>/ ) { $share = $1; }
            if ( $likes =~ /<like_count>(\d+)<\/like_count>/ ) { $like = $1; }
            if ( $likes =~ /<comment_count>(\d+)<\/comment_count>/ ) { $comment = $1; }
            if ( $likes =~ /<total_count>(\d+)<\/total_count>/ ) { $total = $1; }

            # %adv_infos 익명해쉬 생성후 배열 레퍼런스를 사용하여 \@array 형태로 자료 구조를 만든다.
            push @{ $adv_infos{$argv_url} ||= [] }, ($argv_url, $share, $like, $comment, $total);
        }
        else {
            die $response->status_line;
        }
    }
    return %adv_infos;
}

sub web_parser {
    my ($url, $year) = @_; 
    my $dom;

    if ( $year =~ /2010/ ) { $dom = Mojo::UserAgent->new->get($url)->res->dom->at('#doc'); }
    if ( $year =~ /2011/ ) { $dom = Mojo::UserAgent->new->get($url)->res->dom->at('#cont-wrap'); }
    if ( $year =~ /2012/ ) { $dom = Mojo::UserAgent->new->get($url)->res->dom->at('#cont'); }
    if ( $year =~ /2013/ ) { $dom = Mojo::UserAgent->new->get($url)->res->dom->at('#cont'); }

    my $author = get_author($dom);
    my $title  = get_title($dom);
    my $desc   = get_desc($dom);
    my @toc    = get_toc($dom);
    my $toc    = @{[ join "\n    ", @toc ]};
    
    return ($title, $author, $url, $desc);
}

sub get_author { shift->at('h2')->next->all_text }
sub get_title  { shift->at('h1')->all_text }
 
sub get_toc {
    my $dom = shift;
 
    my @toc;
    $dom->find('h2')->each(sub {
        return if $_->all_text eq '저자';
        push @toc, $_->all_text;
    });
 
    return @toc;
} 
sub get_desc {
    my $dom = shift;
 
    my @desc;
    for ( my $e = $dom->find('h2')->[1]->next; $e; $e = $e->next ) {
        last if $e->type eq 'h2';
        push @desc, $e->all_text;
    }
 
    return join( "\n\n", @desc ); 
}
