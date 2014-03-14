for each of "your" treebanks:

1) find the data (/net/data/CoNLL/, web???), make sure
that the license allows us to use it

2) if the treebank is not already available in the ufal network,
download the treebank and store it into /net/data/...

3) use another directory in this directory for creating
a new directory, in which the normalization will be implemented,
e.g.

svn cp ja/ en

(See also Dan's algorithm below.)

4) store all important information about the treebank in ??/README.txt

5) implement data format conversion (by a reader block) from the treebank file
format into the treex format (rule treex in Makefile)

6) implement tree conversion (by ??/Harmonize or more blocks) from the
treebank annotation scheme into the PDT style



# How to create folders for a new language, say, Finnish:
LANG=fi
cd $TMT_ROOT/treex/devel/hamledt
svn cp ja $LANG
cd $LANG
# Describe the treebank
vi README.txt
# Edit the language code at the first line and the source preparation lines.
vi Makefile
svn commit
#	Finnish.
svn update

make source
make treex
make pdt

