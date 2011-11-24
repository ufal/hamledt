#!/usr/bin/env perl
# Repairs encoding of the Estonian treebank.
# Copyright © 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

while(<>)
{
    # The treebank is encoded in UTF-8.
    # However, it contains wrong characters, perhaps because of previous conversions from other encodings.
    # The following occurs in the file piialaused.xml:
    # ð (\x{F0}) should be š (\x{161})
    # Examples: šatään, maršruut, dušš
    s/\x{F0}/\x{161}/g;
    print;
}
