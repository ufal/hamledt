for each of "your" treebanks:

1) find the data (/net/data/CoNLL/, web???), make sure
that the license allows us to use it

2) if the treebank is not already available in the ufal network,
download the treebank and store it into /net/data/...

3) use the template in this directory for creating
a new directory, in which the normalization will be implemented,
e.g.

svn cp template/ en

(See also Dan's algorithm below.)

4) store all important information about the treebank in ??/README

5) implement data format conversion (by a reader block) from the treebank file
format into the treex format (rule to_treex in Makefile)

6) implement tree conversion (by one or more blocks) from the treebank
annotation scheme into the PDT style



# How to create folders for a new language, say, Finnish:
LANG=fi
cd $TMT_ROOT/treex/devel/hamledt
svn cp template $LANG
cd $LANG
# Describe the treebank (you can first copy the README.txt file from another language).
cp ../ar/README.txt .
vi README.txt
# Edit the language code at the first line and the source preparation lines.
vi Makefile
make prepare_dirs
make prepare_source
chmod g+w data/. data/*
dir data/source
svn propedit svn:ignore .
#	data
cd ..
svn commit
#	Finnish.
svn update
