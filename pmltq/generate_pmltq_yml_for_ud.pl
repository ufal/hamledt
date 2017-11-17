#!/usr/bin/env perl
# Generates the pmltq.yml configuration file for a UD treebank.
# Copyright © 2017 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use Getopt::Long;

my $udrel;  # e.g. "21"; to be used in treebank id ("ud21"), paths etc.
my $lname;       # = 'Ancient Greek';
my $tname = '';  # = 'PROIEL';
my $lcode;  # = 'grc';
my $ltcode; # = 'grc_proiel'; # language and treebank code separated by underscore
my $folder; # = 'grc-proiel'; # language and treebank code separated by hyphen

GetOptions
(
    'udrel=s'  => \$udrel,
    'lname=s'  => \$lname,
    'tname=s'  => \$tname,
    'ltcode=s' => \$ltcode
);
if(!defined($udrel) || !defined($lname) || !defined($ltcode))
{
    print STDERR ("Usage: generate_pmltq_yml_for_ud.pl --udrel 21 --lname 'Ancient Greek' [--tname PROIEL] --ltcode grc_proiel\n");
    die("Missing options");
}
my $udreldec = $udrel;
$udreldec =~ s/^(\d)(\d+)$/$1.$2/;
$lcode = $ltcode;
$lcode =~ s/_.*//;
$folder = $ltcode;
$folder =~ s/_/-/;

print("---\n");
print("title: 'Universal Dependencies $udreldec – $lname");
print(" – $tname") if(defined($tname) && $tname ne '');
print("'\n");
print("treebank_id: ud$udrel_$ltcode\n");
print("homepage: 'http://universaldependencies.org/#$lcode'\n");
print("description: 'Universal Dependencies is a project that is developing cross-linguistically consistent treebank annotation for many languages, with the goal of facilitating multilingual parser development, cross-lingual learning, and parsing research from a language typology perspective.'\n");
print("isFree: 'true'\n");
print("isAllLogged: 'true'\n");
print("isPublic: 'true'\n");
print("isFeatured: 'false'\n");
print("languages:\n  - $lcode\n");
print("tags:\n  - 'Universal Dependencies'\n");
print("data_dir: 'treex/$folder'\n");
print("output_dir: 'sql_dump/$folder'\n");
print("layers:\n");
print("  -\n");
print("    name: treex_document\n");
# The data will be stored on the euler.ms.mff.cuni.cz server in /opt/pmltq-data/ud$udrel/treex/ga.
# Assuming that PMLTQ knows that the data folder on the server is /opt/pmltq-data,
# here we should provide the relative path, i.e. "ud$udrel/treex/ga".
print("    path: 'ud$udrel/treex/$folder'\n");
print("    data: '*.treex.gz'\n");
print <<EOF
    references:
      a-node/p_terminal.rf: p-terminal
      a-root/giza_scores/counterpart.rf: '-'
      a-root/ptree.rf: p-nonterminal
      a-root/s.rf: '-'
      a_coreference/target-node.rf: '-'
      align-links/counterpart.rf: '-'
      n-node/a.rf: a-node
      t-a/aux.rf: a-node
      t-a/lex.rf: a-node
      t-bridging-link/target_node.rf: t-node
      t-coref_text-link/target_node.rf: t-node
      t-node/compl.rf: t-node
      t-node/coref_gram.rf: t-node
      t-node/coref_text.rf: t-node
      t-node/original_parent.rf: t-node
      t-node/src_tnode.rf: t-node
      t-node/val_frame.rf: '-'
      t-root/atree.rf: a-root
      t-root/src_tnode.rf: t-node
EOF
;
print("sys_db: postgres\n");
print("db:\n");
print("  host: euler.ms.mff.cuni.cz\n");
print("  port: 5432\n");
print("  user: 'pmltq'\n");
print("  name: ud$udrel_$ltcode\n");
print("web_api:\n");
print("  url: 'https://lindat.mff.cuni.cz/services/pmltq/'\n");
print("  dbserver: 'euler'\n");
print("  user: 'DanZeman'\n");
print("  password: 'klZ2yDWoAN'\n"); ###!!! Raději neukládat ve zdrojáku, ale předávat z příkazového řádku!
print("test_query:\n");
print("  queries:\n");
print("    -\n");
print("      query: 'a-node [];'\n");
print("      filename: $ltcode-01.svg\n");
print("  result_dir: webverify_query_results\n");
