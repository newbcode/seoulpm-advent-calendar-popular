#!/usr/bin/env perl

use utf8;
use DBI;
use Encode qw(encode decode);
use DateTime;
use LWP::UserAgent;

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

my @top_tens;
my $cnt = 1;
my $year = '2011';
my %adv_data = adv_cal($year);

foreach my $p ( keys %adv_data ) {
    push @top_tens, $adv_data{$p};
}

@top_tens = sort { $b->[4] <=> $a->[4] } @top_tens;

foreach my $rank_p ( @top_tens ) {
    my ($title, $author, $url) = title_parser($rank_p->[0], $cnt);
    
    my $sth = $DBH->prepare(qq{
            INSERT INTO `advtop` (`author`, `title`, `url`, `likesum`) VALUES (?,?,?,?)
    });

    $sth->execute( $author, $title, $url, $rank_p->[4] );
    last if ($cnt == 8);
    $cnt++;
}

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

sub title_parser {
    my ($url, $rank_num) = @_; 

    my $ua = LWP::UserAgent->new;
    my $resp = $ua->get($url);
    
    my ($title, $author);

    if ($resp->is_success) {
        my $decode_body =  $resp->decoded_content;
        if ( $decode_body =~ /<title>(.+)<\/title>/ ) { 
            $title = "$rank_num. " . "$1"; 
            $title =~ s/\|.*//g;
        }
        if ( $decode_body =~ /<p><a href=".*?">(.*?)<\/a>/ ) { 
            $author = $1; 
        }
        return ($title, $author, $url);
    }
    else {
        die $resp->status_line;
    }
}

get '/' => sub {
    my $self = shift;
    
    my $sth = $DBH->prepare(qq{ SELECT id, author, title, url, likesum, wdate FROM advtop });
    $sth->execute();

    my %articles;
    while ( my @row = $sth->fetchrow_array ) {
        my ( $id, $author, $title, $url, $likesum, $date ) = @row;
        my ( $wdate ) = split / /, $date;
        
        $articles{$id} = {
            author  => $author,
            title   => $title,
            url     => $url,
            likesun => $likesum,
            wdate   => $wdate,
        };
    }
    $self->stash( articles => \%articles );

} => 'index';

get '/rank' =>  'rank';

app->start;
