#!/usr/bin/env perl

use Mojolicious::Lite;

my $config = plugin 'Config';

get '/' => 'bootstrap';

app->start();
