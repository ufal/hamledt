Prague Arabic Dependency Treebank
as prepared for the CoNLL 2007 shared task

ÚFAL holds the copyright => no licensing problems

training size = 2912 sentences, 111669 tokens
test size     =  131 sentences,   5124 tokens

Analytical functions contain a few more values in addition to PDT.
See the README file in /net/data/conll/2007/ar/doc.

Problem: the is_member attribute is lost.
We are currently (May 2013) preparing new Arabic data from PADT 2.0 (unreleased).
The data is more than twice larger than CoNLL 2007.
It should also be better annotated.
We will read directly the native PML data format, so no attributes should be lost this time.

Update (March 2014):
HamleDT currently uses the new Arabic data (we are now calling it PADT 1.5, not yet 2.0).
This data have their own problems (1700 syntactically unannotated nodes,
30,000 morphologically undisambiguated tokens) but in general we believe they are better
(and definitely they are larger) than CoNLL 2007.

Missing syntactic annotation should be repaired before we release HamleDT 2.0.
Morphology might be repaired too if Zdeněk manages to run a tagger he developed.
