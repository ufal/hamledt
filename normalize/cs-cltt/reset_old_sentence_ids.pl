#!/usr/bin/env perl
# Replaces CLTT 2.0 sentence ids with CLTT 1.0 sentence ids. This is not just
# about backwards compatibility; the old ids were better. They had descriptive
# document id and they identified both the paragraph and the sentence, not just
# the sentence within the document.
# Copyright © 2023 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

# Read the mapping between the old and the new ids.
my %mapping;
open(MAPPING, 'sent_id_mapping_cltt10_to_cltt20.txt') or die("Cannot read 'sent_id_mapping_cltt10_to_cltt20.txt': $!");
while(<MAPPING>)
{
    chomp;
    my ($oldid, $newid) = split(/\t/, $_);
    $mapping{$newid} = $oldid;
}
close(MAPPING);

# Read STDIN, change the ids on the fly and write to STDOUT.
while(<>)
{
    chomp;
    if(m/^\#\s*sent_id\s*=\s*(.+)$/)
    {
        my $newid = $1;
        if(!exists($mapping{$newid}))
        {
            die("Cannot map sentence id '$newid' to an id from CLTT 1.0");
        }
        $_ = "\# sent_id = $mapping{$newid}";
    }
    print("$_\n");
}
