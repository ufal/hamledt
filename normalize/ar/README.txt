Prague Arabic Dependency Treebank
This data is larger than PADT 1.0 (and consequently CoNLL 2006 and 2007).
It has not been published elsewhere than in HamleDT. We want to publish PADT 2.0 eventually but there is work that needs to be done on the annotation.
We read directly the native PML data format. Therefore we do not lose the is_member attribute (unlike CoNLL 2007).

ÚFAL holds the copyright => no licensing problems

training size = 2912 sentences, 111669 tokens
test size     =  131 sentences,   5124 tokens

Analytical functions contain a few more values in addition to PDT.
See the README file in /net/data/conll/2007/ar/doc.

----------

Update (March 2014):
HamleDT currently uses the new Arabic data (we are now calling it PADT 1.5, not yet 2.0).
This data have their own problems (1700 syntactically unannotated nodes,
30,000 morphologically undisambiguated tokens) but in general we believe they are better
(and definitely they are larger) than CoNLL 2007.

Missing syntactic annotation should be repaired before we release HamleDT 2.0.
Morphology might be repaired too if Zdeněk manages to run a tagger he developed.

treex -Lar Read::Treex from='!data/treex/000_orig/train/*.treex.gz' Util::Eval atree='my $nrlimit=1; my $a = $.get_address(); my @nodes=$.get_descendants({ordered=>1}); my @nonrs = grep {$_->afun() ne "NR"} @nodes; my $n = scalar(@nodes); my $nnr=$n-scalar(@nonrs); if(scalar(@nonrs)==0) {log_warn("NO NON-NR AFUNS IN TREE\t$nnr/$n\t$a")} elsif($nnr>=$nrlimit) {log_warn("$nrlimit OR MORE NR AFUNS IN TREE\t$nnr/$n\t$a")}' |& tee NR.log

----------

Update (May 2014):
Morphology in PADT will not be fixed in time for HamleDT 2.0. Switching back from PADT r678
(current) to r349 (eleven months ago). R349 had fewer issues with morphology but it had unannotated
sentences with empty afuns (fixed in subsequent revisions by Shadi Saleh). We thus exclude all
sentences in which at least one afun is missing.

Details and test results:

r678 z 24.5.2014 (Danova poslední oprava afunů):
Test / Treebank  TOTAL  ar
LeafAux               1      1
MaxOneSubject       734    734
NoNewNonProj        332    332
NonemptyAttr     235093 235093
NonleafAuxC          13     13
NonleafAuxP           4      4
NounGovernsDet     3399   3399
PredUnderRoot       157    157
PrepIsAuxP         1295   1295
SubjectBelowVerb   3236   3236
TOTAL            244264 244264

r349 z 24.6.2013 (poslední Danova úprava před tím, než se do toho Zdeněk, Ota a Shadi pustili)
Má jiné schéma XML, což bude asi problém. Místo "make treex" se musí zavolat tohle:
treex Read::PADT schema_dir=/net/projects/padt/data/Prague from='!/net/work/people/zeman/tectomt/share/data/resources/hamledt/ar/source/train/*.syntax.pml' Write::Treex path=/net/work/people/zeman/tectomt/share/data/resources/hamledt/ar/treex/000_orig/train clobber=1
Test / Treebank  TOTAL ar
AfunNotNR         1585  1585
MaxOneSubject      726   726
NoNewNonProj       341   341
NonemptyAttr     23470 23470
NonleafAuxC          8     8
NonleafAuxP         12    12
NounGovernsDet    2593  2593
PredUnderRoot       83    83
PrepIsAuxP        1517  1517
SubjectBelowVerb  3090  3090
TOTAL            33425 33425

Rozhodnutí: Do HamleDTa 2.0 zařadíme r349, ale vynecháme věty, které obsahují alespoň jeden nevyplněný afun.
Po vypuštění dotyčných vět vypadají testy takto:
Test / Treebank  TOTAL ar
MaxOneSubject     716   716
NoNewNonProj      340   340
NonleafAuxC         8     8
NonleafAuxP        12    12
NounGovernsDet   2418  2418
PredUnderRoot      73    73
PrepIsAuxP       1244  1244
SubjectBelowVerb 3030  3030
TOTAL            7841  7841
