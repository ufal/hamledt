for each of "your" treebanks:

1) find the data (/net/data/CoNLL/, web???), make sure
that the license allows us to use it

2) if the treebank is not already available in the ufal network,
download the treebank and store it into /net/data/...

3) use the template in this directory for creating
a new directory, in which the normalization will be implemented,
e.g.

svn cp template/ en

4) store all important information about the treebank in ??/README

5) implement data format conversion (by a reader block) from the treebank file
format into the treex format (rule to_treex in Makefile)

6) implement tree conversion (by one or more blocks) from the treebank
annotation scheme into the PDT style
