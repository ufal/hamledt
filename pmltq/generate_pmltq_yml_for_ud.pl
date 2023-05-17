#!/usr/bin/env perl
# Generates the pmltq.yml configuration file for a UD treebank.
# To be called in a loop from load_universal_dependencies.pl.
# Copyright © 2017, 2023 Dan Zeman <zeman@ufal.mff.cuni.cz>
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
my $summary = 'Universal Dependencies is a project that is developing cross-linguistically consistent treebank annotation for many languages, with the goal of facilitating multilingual parser development, cross-lingual learning, and parsing research from a language typology perspective.';

GetOptions
(
    'udrel=s'   => \$udrel,
    'lname=s'   => \$lname,
    'tname=s'   => \$tname,
    'ltcode=s'  => \$ltcode,
    'summary=s' => \$summary
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
$tcode = $ltcode;
$tcode =~ s/^.*_//;
# The treebank textual "icon" in the web interface is also based on the $pmltqcode.
# It contains one or two lines, the rest is lost. Line breaks are underscores and boundaries between letters and digits.
# Hence, "udyo_ytb22" means that the icon will have two lines, "UDYO" and "YTB". There is no way of also displaying "22", and not joining "YO" with "YTB".
$pmltqcode = "ud${lcode}_${tcode}${udrel}";
$folder = $ltcode;
$folder =~ s/_/-/;

print("---\n");
print("title: 'Universal Dependencies $udreldec – $lname");
print(" – $tname") if(defined($tname) && $tname ne '');
print("'\n");
print("treebank_id: $pmltqcode\n");
print("homepage: 'http://universaldependencies.org/#$lcode'\n");
print("description: '$summary'\n");
print("isFree: 'true'\n");
print("isAllLogged: 'true'\n");
print("isPublic: 'true'\n");
print("isFeatured: 'false'\n");
print("languages:\n  - $lcode\n");
print("tags:\n  - 'Universal Dependencies ${udreldec}'\n");
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
# Postgres responds on port 5432 of the machine that used to be known as euler
# (euler.ms.mff.cuni.cz). Since January 2023, euler no longer has a public IP
# address, accessing it is thus more difficult. We have to create an SSH tunnel
# like this:
#    ssh -t -L 15432:127.0.0.1:5432 pmltq@10.10.51.124
# The tunnel must stay active throughout the time when local pmltq is supposed
# to communicate with Postgres on euler. Then the configuration can pretend
# that Postgres is running locally, on the port we defined in the tunnel.
print("db:\n");
print("  host: localhost\n");
print("  port: 15432\n");
print("  user: 'pmltq'\n");
print("  name: $pmltqcode\n");
print("web_api:\n");
print("  url: 'https://lindat.mff.cuni.cz/services/pmltq/'\n");
print("  dbserver: '10.10.51.124'\n");
print("  user: 'DanZeman'\n");
print("  password: 'klZ2yDWoAN'\n"); ###!!! Raději neukládat ve zdrojáku, ale předávat z příkazového řádku!
print("test_query:\n");
print("  queries:\n");
print("    -\n");
print("      query: 'a-node [];'\n");
print("      filename: $ltcode-01.svg\n");
print("  result_dir: webverify_query_results\n");
