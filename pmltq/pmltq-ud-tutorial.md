# Querying Universal Dependencies in PML-TQ – Quick Start

PML-TQ comes with some rudimentary
[help](http://ufal.mff.cuni.cz/pmltqdoc/doc/pmltq_tutorial_web_client.html#section-output-filters)
and query examples. Most of it is generated automatically from the XML (PML)
schema of the treebank. Since we abuse a non-UD schema (Treex) to index UD
data in PML-TQ, these sample queries are not very informative. More
seriously, they hide some peculiarities of the data structures that are not
intuitive for someone knowledgeable about UD. Here we try to overcome these
obstacles. For more detail on PML-TQ, see the PML-TQ manual, sections [PML-TQ
Syntax
Reference](https://ufal.mff.cuni.cz/pmltqdoc/doc/pmltq_doc.html#outputFilter)
and [Group
Functions](https://ufal.mff.cuni.cz/pmltqdoc/doc/pmltq_doc.html#agg_functions).

## Searching for Nodes with Given Attributes

```
a-node [];
```

```
a-root [];
```

The simplest possible query. It returns any node in the treebank. Note that
the results come in random order, PML-TQ ignores the order of the trees in
the input data. Also note that the number of returned results is limited by
default (if it returns 100 trees, there may be more than 100 hits but only
the first 100 are returned). If you use a-root[] instead of a-node[], you
will get the artificial ROOT nodes, i.e. every result is a new tree (but
roots do not have the attributes that we list below for normal nodes).

```
a-node [tag="PART"];
```

```
a-node [conll/pos="RP"];
```

The UPOS tag is stored as “tag”. The above query returns nodes tagged as
particles. If you want to query the XPOS tag, use the “conll/pos” attribute.

```
a-node [lower(form)~"^(wh|how)", lemma=lower(lemma)];
```

You can match regular expressions using the ~ operator. The syntax of the
expressions is Perl-like but you need two backslashes (instead of just one!)
to escape special characters. The above query looks for nodes whose word form
starts with “wh” or “how” (case-insensitive) and whose lemma does not contain
uppercase letters.

PML-TQ does not know about [multi-word
tokens](https://universaldependencies.org/format.html#words-tokens-and-empty-nodes).
You are always querying individual syntactic words (nodes), even if their
form does not match the surface token.

```
a-node [iset/prontype="prs", iset/reflex="yes", iset/poss="yes"];
```

Features are nested in a structured attribute called “iset”; feature names
and values are lowercased. The above query searches for reflexive possessive
personal pro-forms (we have not specified the UPOS tag, thus both PRON and
DET could appear in the results).

Some language-specific features may not be available this way. Commonly used
layered features are available but they have different names, e.g.
Number[psor] can be queried as iset/possnumber.

If there are multi-values (e.g. “Case=Acc,Nom”), they will be separated by a
vertical bar instead of the comma used in UD (e.g. “iset/case="acc|nom"”).

Features that are not available via iset can still be queried, even if in a
slightly less convenient way. The full feature string from UD is available in
the node attribute “conll/feat”. Regular expressions can be used to query
individual features in this string (remember that features are sorted
alphabetically in CoNLL-U files):

<!-- We need four backslashes instead of one. First level will be consumed by
MarkDown and four will become two. The second level will be consumed by
PML-TQ and two will become one, which will enter the internal Perl RE
processor. -->

```
a-node [conll/feat~"Number\\\\[psor\\\\]=Plur.*Poss=Yes"];
```

## Aggregation Filters

Instead of browsing trees with highlighted nodes, you may want to see a table
with aggregated statistics about the results. That is done by appending a
filter to the query. A filter always starts with “>>” and uses one or more
keywords. The filters we will use have the form “>> for $NODE give $COLUMNS
sort by $SORTCOLUMNS”. A query may specify more than one node; in order to
refer to the nodes, we will have to label them. The label starts with the
dollar sign, e.g. the “$a” in the following query:

```
a-node $a := [iset/prontype~"int"] >> for $a.lemma, $a.tag give $1, $2,
count() sort by $3 desc, $2;
```

The $1 and $2 variables of the give keyword refer to the first and second
item of the for keyword; similarly, the $3 of sort refers to the third item
of give, i.e. the count() function. This query will list all unique lemma-tag
pairs whose pronominal type contains “int” (interrogative); it will give the
number of occurrences of each such pair, and sort the table in descending
order by frequency.

## Querying Multiple Nodes

```
a-node [deprel~"^obj", parent a-node [tag="VERB"]];
```

This query searches for nodes whose relation to their parent starts with
“obj” (i.e. it is either the universal “obj”, or a language-specific subtype
thereof, e.g., “obj:dir”) and whose parent is a verb. We can also query other
tree relations, e.g. child, ancestor, descendant etc. We can also query the
direction of the dependencies by comparing positions of the nodes in the word
order:

```
a-node $d := [deprel~"^conj", parent a-node $p := [order-follows
$d]];
```

This query looks for ill-formed coordination: a node is attached as “conj” to
a parent that lies somewhere to the right.

There are endless possibilities and the queries can get much more complex but
that goes beyond this quick-start guide. Please look at the PML-TQ
documentation. There are no additional surprises for a UD user (but ignore
any example queries with other types of nodes than a-node and a-root. For
example, the Prague Dependency Treebank has so-called t-nodes but these do
not exist in UD.) It is currently not possible to query the enhanced UD
graphs in PML-TQ.

