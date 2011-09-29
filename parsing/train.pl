#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Treex::Core::Config;

my $data_dir = Treex::Core::Config::share_dir()."/data/resources/normalized_treebanks/";
my $mcd_dir  = $ENV{TMT_ROOT}."/libs/other/Parser/MST/mstparser-0.4.3b";
my $malt_dir = $ENV{TMT_ROOT}."/share/installed_tools/malt_parser/malt-1.5";

my ($help, $mcd, $mcdproj, $malt, $maltsmf, $feat, $trans, $new);
$feat = '_'; # default
$trans = '';

GetOptions(
    "help|h"  => \$help,
    "mcd"     => \$mcd,
    "malt"    => \$malt,
    "maltsmf" => \$maltsmf,
    "mcdproj" => \$mcdproj,
    "trans=s"   => \$trans,
    "feat=s"  => \$feat,
    "new"     => \$new,
);


if ($help || !@ARGV) {
    die "Usage: train.pl [OPTIONS] [LANGUAGES]
    LANGUAGES  - list of ISO codes of languages to be processed
    --mcd      - train McDonald's non-projective MST parser
    --mcdproj  - train McDonald's projective MST parser
    --malt     - train Malt parser
    --maltsmf  - train Malt parser with stack algorithm and morph features
    --new      - recreate training file, don't reuse existing
    --trans    - select transformationis separated by comma. All transformations are run otherwise.
    --feat     - select features conll|iset|_ (_ is default)
    -h,--help  - print this help
";
}

my %transformation;
map {$transformation{$_} = 1} split(/,/, $trans);

foreach my $language (@ARGV) {
    foreach my $dir (glob "$data_dir/$language/treex/*") {
        next if (!-d $dir);
        my $name = $dir;
        $name =~ s/^.+\///;
        # Compress transformation names because qstat only shows 10 characters.
        next if $trans && !$transformation{$name};
        $name =~ s/^trans_/t/;
        $name = "$language-$name";
        my $deprel_attribute = $name =~ /000_orig/ ? 'conll/deprel' : 'afun';
        system "mkdir -p $dir/parsed";
        # Send error messages to /dev/null because it is quite probable that there are files
        # that we do not own and thus cannot change their permissions although we have write access to them.
        system "chmod -R g+wx $dir/parsed 2>/dev/null";
        my ($trainfilename, $f);
        if ( $feat =~ m/^conll/i ) {
            $trainfilename = 'train-conllfeat.conll';
            $f = 'feat_attribute=conll/feat';
        } elsif ( $feat =~ m/^i(nter)?set/i ) {
            $trainfilename = 'train-iset.conll';
            $f = 'feat_attribute=iset';
        } else {
            $trainfilename = 'train.conll';
            $f = '';
        }

        # create training CoNLL file if needed.
        # all afuns but 'Coord', 'AuxX', and 'AuxY' are substituted by 'Atr' 
        if ($new || !-e "$dir/parsed/$trainfilename") {
            my $command =  "treex -p -j 20 ";
               $command .= "Util::SetGlobal language=$language ";
               $command .= "Util::Eval anode='\$anode->set_attr(\"$deprel_attribute\", \"Atr\");' ";
               $command .= "Write::CoNLLX $f deprel_attribute=$deprel_attribute is_member_within_afun=1 is_shared_modifier_within_afun=1 is_coord_conjunction_within_afun=1 ";
               $command .= "-- $dir/train/*.treex.gz > $dir/parsed/$trainfilename";
            system $command;   
        }
        if ($mcd || $mcdproj) {
            system "cat $dir/parsed/$trainfilename | ./conll2mst.pl > $dir/parsed/train.mst\n";
        }
        if ($mcd) {
            my $scriptname = "mcd-$name.sh";
            print STDERR "Creating script for training McDonald's non-projective parser ($name).\n";
            open (BASHSCRIPT, ">:utf8", $scriptname) or die;
            print BASHSCRIPT "#!/bin/bash\n\n";
            print BASHSCRIPT "java -cp $mcd_dir/output/mstparser.jar:$mcd_dir/lib/trove.jar -Xmx9g mstparser.DependencyParser \\\n";
            print BASHSCRIPT "  train order:2 format:MST decode-type:non-proj train-file:$dir/parsed/train.mst model-name:$dir/parsed/mcd_nonproj_o2.model\n";
            close BASHSCRIPT;
            system "qsub -hard -l mf=10g -l act_mem_free=10g -cwd -j yes $scriptname";
        }
        if ($mcdproj) {
            my $scriptname = "mcp-$name.sh";
            print STDERR "Creating script for training McDonald's projective parser ($name).\n";
            open (BASHSCRIPT, ">:utf8", $scriptname) or die;
            print BASHSCRIPT "#!/bin/bash\n\n";
            print BASHSCRIPT "java -cp $mcd_dir/output/mstparser.jar:$mcd_dir/lib/trove.jar -Xmx9g mstparser.DependencyParser \\\n";
            print BASHSCRIPT "  train order:2 format:MST decode-type:proj train-file:$dir/parsed/train.mst model-name:$dir/parsed/mcd_proj_o2.model\n";
            close BASHSCRIPT;
            system "qsub -hard -l mf=10g -l act_mem_free=10g -cwd -j yes $scriptname";
        }
        if ($malt) {
            my $scriptname = "mlt-$name.sh";
            print STDERR "Creating script for training Malt parser ($name).\n";
            open (BASHSCRIPT, ">:utf8", $scriptname) or die;
            print BASHSCRIPT "#!/bin/bash\n\n";
            print BASHSCRIPT "cd $dir/parsed/;\n";
            # If there is the temporary folder from failed previous runs, erase it or Malt will decline training.
            print BASHSCRIPT "rm -rf malt_nivreeager\n";
            print BASHSCRIPT "java -Xmx15g -jar $malt_dir/malt.jar -i $trainfilename -c malt_nivreeager -a nivreeager -l liblinear -m learn\n";
            close BASHSCRIPT;
            system "qsub -hard -l mf=16g -l act_mem_free=16g -cwd -j yes $scriptname";
        }
        if ($maltsmf) {
            my $scriptname = "smf-$name.sh";
            print STDERR "Creating script for training Malt parser with stack and morph features ($name).\n";
            open (BASHSCRIPT, ">:utf8", $scriptname) or die;
            print BASHSCRIPT "#!/bin/bash\n\n";
            # Debugging message: anyone here eating my memory?
            print BASHSCRIPT "hostname -f\n";
            print BASHSCRIPT "top -bn1 | head -20\n";
            print BASHSCRIPT "cd $dir/parsed/;\n";
            # If there is the temporary folder from failed previous runs, erase it or Malt will decline training.
            print BASHSCRIPT "rm -rf malt_stacklazy\n";
            my $features = '/net/work/people/zeman/parsing/malt-parser/marco-kuhlmann-czech-settings/CzechNonProj-JOHAN-NEW-MODIFIED.xml';
            my $command = "java -Xmx29g -jar $malt_dir/malt.jar -i $trainfilename -c malt_stacklazy -a stacklazy -F $features -grl Pred -d POSTAG -s 'Stack[0]' -T 1000 -gds T.TRANS,A.DEPREL -l libsvm -m learn\n";
            print BASHSCRIPT "echo $command";
            print BASHSCRIPT $command;
            close BASHSCRIPT;
            my $memory = '31g';
            system "qsub -hard -l mf=$memory -l act_mem_free=$memory -cwd -j yes $scriptname";
        }
    }
}
