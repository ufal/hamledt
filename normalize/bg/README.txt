BulTreeBank (BTB)
as prepared for the CoNLL 2006 shared task
(originally it is a HPSG treebank)

Note: This data was actually obtained after the shared task directly from the providers in Sofija.
It turns out that it slightly differs from the data that was distributed to the participants of the
shared task. The order of the documents in training data is no longer defined (there was one file
train.conll in the shared task; there are several separate files in our dataset; and sorting the
documents alphabetically does not give the same order). The number of training sentences and tokens
slightly dropped since the shared task (cleaning?) The test set seems to be identical in both versions.

We kept the official train/test split in HamleDT 2.0 and older.
We continue to keep the original test set but we cut off a part of the training set and declared it
a development data set. People are free to join these two parts again before training a parser that
will be used to parse the test set.

Dan signed a license in 2006 (research only, cite article, do not distribute).

HamleDT 2.0 and older:
training size = 12823 sentences, 190217 tokens
test size     =   398 sentences,   5934 tokens

HamleDT 2.1:
training size = 12000 sentences, 177125 tokens
dev size      =   823 sentences,  13092 tokens
test size     =   398 sentences,   5934 tokens

See the README file in /net/data/conll/2006/bg/doc.
