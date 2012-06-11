#!/usr/bin/env perl

use strict;
use warnings;
use Treex;
use Treex::Core::Document;

my $main_data_dir = "$ENV{TMT_ROOT}/share/data/resources/hamledt";

foreach my $lang_data_dir (sort glob "$main_data_dir/*") {
    my ($lang_code) = reverse split /\//,$lang_data_dir;
    print $lang_code;
    foreach my $purpose (qw(train test)) {
        my ($sentences,$tokens) = (0,0);
        foreach my $file (glob "$lang_data_dir/treex/000_orig/$purpose/*.treex") {
            my $doc = Treex::Core::Document->new( { filename => $file } );
            foreach my $bundle ($doc->get_bundles) {
                $sentences++;
                $tokens += $bundle->get_zone($lang_code, 'orig')->get_atree->get_descendants;
#            print "$file loaded\n";
            }
        }
        print "\t$sentences\t$tokens";
    }
    print "\n";
}
