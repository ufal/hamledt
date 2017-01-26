Index Thomisticus Treebank converted to a CoNLL-like format, to be used as input for Universal Dependencies release 1.3.
Provided by Marco Passarotti, 2016-05-04.
See the documentation in http://itreebank.marginalia.it/.

Original comment by Marco Passarotti (2015-06-30):
The IT-TB is divided into two main sections. One is the in-line annotation of a work of Thomas Aquinas ("Summa contra Gentiles", SCG).
The other includes the concordances of the lemma "forma" in three works of Thomas, among which is also the SCG. Thus, there are some
sentences that occur in both the sections (namely, those sentences of the part of the SCG annotated so far that feature at least one
occurrence of "forma"). (Note by Dan: Summa contra Gentiles contains 4 books altogether. But the fourth book is regarded special and
I do not know whether it is going to become part of the treebank.)

In the attached folder, you will find three conll files:
1) IT-TB_30-06-2015.conll: the entire IT-TB (with duplicated sentences)
2) IT-TB_SCG-1-2-3_30-06-2015.conll: in-line annotation of the SCG (entire first two books; part of the third)
3) IT-TB_forma-concordances_no-doubles-SCG_30-06-2015.conll: the concordances of "forma" without the duplicated sentences of the SCG

So, if you do not want to have duplicated sentences in the treebank, you just have to merge files n. (2) and n. (3).
If you want the IT-TB with duplicated sentences, use the file n. (1).
Given that, among the several uses of  HamleDT 3.0, there might be also NLP tasks (like training parsers), I think that the best is
to provide users with the IT-TB with no duplicates, i.e. with the data resulting from merging (2) and (3).

Comment on new files (2016-05-04):
There is an extra column at the end, tagging so-called "semantic type" of the lemma. We are especially interested in words with "NP"
in that column (NP means "Nomen Proprium"): these are the proper names. The tagging of NPs was done by father Busa himself in the IT
corpus. Note that the lemmas "deus" (God) and "angelus" (Angel) are assigned NP. Lemmas like "magister" (master) and "commentator"
(commentator) are assigned NP because they refer to specific persons.

The treebank is still growing and the data currently available is larger than a year ago.
Moreover, annotation of sentences that had been annotated a year ago may have changed as Marco and Wim Berkelmans found and fixed errors.
We have several overlapping files that enable us to take into consideration our previous train/dev/test data split:

1) IT-TB_SCG-1-2-3_30-06-2015.conll: same file as last year, only there is the additional column with semantic types. No annotation erros fixed.
   11799 sentences, 179441 tokens
2) IT-TB_forma-concordances_no-doubles-SCG_05-06-2015.conll: despite different name ("05-06" instead of "30-06") this also differs only in the extra column.
   3496 sentences, 80243 tokens
3) IT-TB_SCG3_new_addings-04-05-2016.conll: newly annotated sentences of SCG book 3.
   If they are added, at the same time we must remove from 2) ("forma") the sentences that are covered here and that thus become duplicate.
   Marco says that these are those included between line 58613 and 61399 of the "IT-TB_forma-concordances_no-doubles-SCG_05-06-2015.conll".
   2095 sentences, 34756 tokens
4) IT-TB_03-05-2016_lbis.conll: the entire treebank in its current extent, duplicates removed.
   The boundary between the "forma" part and the SCG part in that file is at line 80463.
   This means that the SCG part starts at line 80463 (and it ends at the last line of the file).
   The "forma" part goes from line 1 to line 80462.
   Unfortunately this file contains three sentences with errors in node numbering:
   cat IT-TB_03-05-2016_lbis.conll | head -284840 | tail -12
   cat IT-TB_03-05-2016_lbis.conll | head -292215 | tail -26
   cat IT-TB_03-05-2016_lbis.conll | head -306068 | tail -18
   For the moment I fixed these errors manually and renamed the file IT-TB_03-05-2016_lbis-manual-fix-dz.conll.
   17258 sentences, 291295 tokens
Let's split the file from 4) into the two parts, "scg" and "forma":
5) cat IT-TB_03-05-2016_lbis-manual-fix-dz.conll | tail -228091 > IT-TB_03-05-2016_lbis-scg.conll
   (wc -l IT-TB_03-05-2016_lbis.conll gives 308553)
   13894 sentences, 214197 tokens
6) cat IT-TB_03-05-2016_lbis-manual-fix-dz.conll | head -80462 > IT-TB_03-05-2016_lbis-forma.conll
   3364 sentences, 77098 tokens

DATA SPLIT

Dan: I think that we have to change the way how we split the data to train/dev/test part, even though it means that we
exceptionally violate the UD policy that a sentence that was once released as train/dev/test should not be moved to
a different section in the future releases. There are two concerns:
1. The "forma" part is quite specific because every sentence contains the word "forma". The rest ("scg") may also
   contain "forma" but these are natural occurrences. We do not want to train on "scg" and test on "forma". That is why
   in HamleDT 3.0 and UD 1.2 we took mixed parts of both "scg" and "forma" in all three datasets (train/dev/test).
2. However, as the treebank grows, the "scg" part grows and "forma" shrinks because we remove from "forma" duplicate
   sentences, newly covered by "scg". (However, "forma" will not completely disappear because it also contains
   sentences from other works than Summa contra Gentiles.) That could mean that a sentence is silently moved from
   test ("forma") to train ("scg") between releases.
Hence I propose the following, effective since UD 1.3:
*  Sentences from the "forma" part are only in training data, not in dev or test.
   (So we are exceptionally moving some of them from dev/test 1.2 to train 1.3.)
*  New dev/test is taken from the beginning of "scg", which is hopefully stable forever.
   We will take slightly larger portions than before, namely 500 + 500 sentences.
   (But part of train 1.2 is becoming dev/test 1.3 and vice versa.)
*  Newly annotated portions of "scg" will be added to train.
   At the same time, sentences from "forma" that newly become duplicates will be removed.
   (That is, the sentence is still part of train, but with different position and sentence id.)
*  All sentences now get a treebank-wide unique id that identifies the original file ("scg" or "forma") and their
   position in the file. They will keep the id regardless whether they end up in train, dev or test section.
   This should help us in future solve issues related to data splitting.

We should define sentence ids that would survive reading CoNLL in Treex and splitting the treebank to multiple files.
We can add the ids as a special feature of every node. Then, after reading it in Treex, we must erase the feature and make it Bundle id.
Later on, the CoNLL files will have to be read in Treex Read::CoNLLX with the parameter sid_within_feat=1 so the feature is recognized as bundle id.

OLD DATA SPLIT WAS THIS:
#cat IT-TB_SCG-1-2-3_30-06-2015.conll | preprocess.pl scg > ittb-scg-sids.conll
#cat IT-TB_forma-concordances_no-doubles-SCG_05-06-2015.conll | preprocess.pl forma > ittb-forma-sids.conll
#split_conll.pl < ittb-scg-sids.conll --head 11500 traindev2.conll test2.conll
#split_conll.pl < traindev2.conll --head 11200 train2.conll dev2.conll
#split_conll.pl < ittb-forma-sids.conll --head 3400 traindev3.conll test3.conll
#split_conll.pl < traindev3.conll --head 3300 train3.conll dev3.conll

NEW DATA SPLIT:
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Note that the current "forma" is smaller than the previous "forma" and that we
do not know what sentences were removed. Thus we change ids of sentences that
exist in both old and new "forma". Not a big deal but it would be better if we
didn't. Marco: lines 58613 to 61399 of the old "forma" were removed.
58613 is the first word of the first removed sentence.   sid=ittb-forma-s2509
61399 is the empty line after the last removed sentence. sid=ittb-forma-s2622
cat ittb-forma-sids.conll | head -58613 | tail
cat ittb-forma-sids.conll | head -61399 | tail
Total 114 duplicate sentences were removed. Hence we adjust the preprocess.pl:
If we are preprocessing "forma" and if the current index is >= 2509, add 114
and use the result in sid.
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
cat IT-TB_03-05-2016_lbis-scg.conll | preprocess.pl scg > ittb-scg-sids.conll
cat IT-TB_03-05-2016_lbis-forma.conll | preprocess.pl forma > ittb-forma-sids.conll
split_conll.pl < ittb-scg-sids.conll --head 500 dev.conll testtrain-scg.conll
split_conll.pl < testtrain-scg.conll --head 500 test.conll train-scg.conll
cat train-scg.conll ittb-forma-sids.conll > train.conll

for i in *.conll ; do echo $i `wc_conll.pl $i` ; done
#OLD: train.conll 14295 sentences, 245330 tokens
train.conll 16258 sentences, 276941 tokens
dev.conll 500 sentences, 7806 tokens
test.conll 500 sentences, 6548 tokens

cat train2.conll train3.conll | wc_conll.pl
14500 sentences, 246573 tokens (previously 14500 sentences, 246607 tokens)
cat dev2.conll dev3.conll | wc_conll.pl
400 sentences, 6040 tokens (previously 400 sentences, 6020 tokens)
cat test2.conll test3.conll | wc_conll.pl
395 sentences, 7071 tokens (previously 394 sentences, 7056 tokens)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
DATA SPLIT FOR UD V2:

For the CoNLL 2017 shared task we require that development and test data contain
at least 10000 words each, thus we must re-split the data once again.
split_conll.pl < ittb-scg-sids.conll --head 700 dev.conll testtrain-scg.conll
split_conll.pl < testtrain-scg.conll --head 750 test.conll train-scg.conll
cat train-scg.conll ittb-forma-sids.conll > train.conll

for i in *.conll ; do echo $i `wc_conll.pl $i` ; done
train.conll 15808 sentences, 270403 tokens
dev.conll 700 sentences, 10331 tokens
test.conll 750 sentences, 10561 tokens
