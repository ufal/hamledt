Icelandic Parsed Historical Corpus (IcePaHC)

License: GNU LGPL (Lesser General Public License)

Penn-Treebank-style constituency trees.
Includes part-of-speech tags, functional tags and lemmata.
Maybe Nathan could figure out a head-finding algorithm and convert them to dependencies?

The respective files are from various times: the oldest one from the 12th century, the newest from 1850.
So even if Icelandic has not changed too much over centuries,
we probably should not just pick one of the files as test data.
Instead, we should take every 10th sentence or something like that.

total number of sentences = 9124 ("cat *.psd | egrep '^\( ' | wc -l")
training size = ? sentences, ? tokens
test size     = ? sentences, ? tokens

See http://linguist.is/icelandic_treebank/ for annotation guidelines and tag documentation.
