#!/usr/bin/perl
use strict;
use warnings;

use open qw( :std :utf8 );
use List::Util 'shuffle';

{
    local $/ = "\n\n";
    my @paragraphs = shuffle <>;
    print @paragraphs;
}
