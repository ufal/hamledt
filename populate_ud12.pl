#!/usr/bin/env perl
# Creates folders and Makefiles for Universal Dependencies 1.2.
# Copyright © 2015 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

my $udpath = '/net/work/people/zeman/unidep';
opendir(DIR, $udpath) or die("Cannot read the contents of $udpath: $!");
my @folders = sort(grep {-d "$udpath/$_" && m/^UD_[A-Z]/} (readdir(DIR)));
closedir(DIR);
print("Found ", scalar(@folders), " UD folders in $udpath.\n");
# We need a mapping from the English names of the languages (as they appear in folder names) to their ISO codes.
my %langcodes =
(
    'Amharic'             => 'am',
    'Ancient_Greek'       => 'grc',
    'Arabic'              => 'ar',
    'Basque'              => 'eu',
    'Bulgarian'           => 'bg',
    'Catalan'             => 'ca',
    'Croatian'            => 'hr',
    'Czech'               => 'cs',
    'Danish'              => 'da',
    'Dutch'               => 'nl',
    'English'             => 'en',
    'Estonian'            => 'et',
    'Finnish'             => 'fi',
    'French'              => 'fr',
    'German'              => 'de',
    'Gothic'              => 'got',
    'Greek'               => 'el',
    'Hebrew'              => 'he',
    'Hindi'               => 'hi',
    'Hungarian'           => 'hu',
    'Indonesian'          => 'id',
    'Irish'               => 'ga',
    'Italian'             => 'it',
    'Japanese'            => 'ja',
    'Kazakh'              => 'kk',
    'Korean'              => 'ko',
    'Latin'               => 'la',
    'Norwegian'           => 'no',
    'Old_Church_Slavonic' => 'cu',
    'Persian'             => 'fa',
    'Polish'              => 'pl',
    'Portuguese'          => 'pt',
    'Romanian'            => 'ro',
    'Russian'             => 'ru',
    'Slovak'              => 'sk',
    'Slovenian'           => 'sl',
    'Spanish'             => 'es',
    'Swedish'             => 'sv',
    'Tamil'               => 'ta',
    'Turkish'             => 'tr'
);
foreach my $folder (@folders)
{
    # The name of the folder: 'UD_' + language name + optional treebank identifier.
    # Example: UD_Ancient_Greek-PROIEL
    my $language = '';
    my $treebank = '';
    my $langcode;
    if($folder =~ m/^UD_([A-Za-z_]+)(?:-([A-Z]+))?$/)
    {
        $language = $1;
        $treebank = $2 if(defined($2));
        if(exists($langcodes{$language}))
        {
            $langcode = $langcodes{$language};
            # Read the README file first. We need to know whether this repository is scheduled for the upcoming release.
            my $metadata = read_readme("$udpath/$folder");
            if($metadata->{release})
            {
                # Look for the other files in the repository.
                opendir(DIR, "$udpath/$folder") or die("Cannot read the contents of the folder $udpath/$folder");
                my @files = readdir(DIR);
                my @conllufiles = grep {-f "$udpath/$folder/$_" && m/\.conllu$/} (@files);
                my $n = scalar(@conllufiles);
                # Only process folders that are git repositories and contain CoNLL-U files.
                if($n > 0 && -d "$udpath/$folder/.git")
                {
                    my $lctreebank = lc($treebank);
                    my $key = $langcode;
                    $key .= '_'.$lctreebank if($treebank ne '');
                    my $hfolder = "$langcode-ud12$lctreebank";
                    print("$folder --> $hfolder\n");
                    if(1) # can be switched off for dry runs
                    {
                        my $hpath = "/net/work/people/zeman/hamledt/normalize/$hfolder";
                        system("mkdir -p $hpath");
                        my $makefile = <<EOF
LANGCODE=$langcode
TREEBANK=$hfolder
UDCODE=$key
UDNAME=$language
include ../common.mak

SOURCEDIR=/net/work/people/zeman/unidep/UD_\$(UDNAME)
source:
	cp \$(SOURCEDIR)/\$(UDCODE)-ud-train.conllu data/source/train.conllu
	cp \$(SOURCEDIR)/\$(UDCODE)-ud-dev.conllu data/source/dev.conllu
	cp \$(SOURCEDIR)/\$(UDCODE)-ud-test.conllu data/source/test.conllu

# Do not convert Universal Dependencies to the Prague style and then back to UD. Instead, read directly UD.
# Note that there will be just one tree per sentence, not three. (There are three trees per sentence for treebanks that are converted via Prague.)
ud: conllu_to_treex
EOF
                        ;
                        open(MAKEFILE, ">$hpath/Makefile") or die("Cannot write to Makefile: $!");
                        print MAKEFILE ($makefile);
                        close(MAKEFILE);
                        system("cd $hpath ; git add Makefile ; make dirs ; make source ; make ud");
                    }
                }
                closedir(DIR);
            }
        }
    }
}



#------------------------------------------------------------------------------
# Reads the README file of a treebank and finds the metadata lines. Example:
#=== Machine-readable metadata ================================================
#Documentation status: partial
#Data source: automatic
#Data available since: UD v1.2
#License: CC BY-NC-SA 2.5
#Genre: fiction
#Contributors: Celano, Giuseppe G. A.; Zeman, Daniel
#==============================================================================
#------------------------------------------------------------------------------
sub read_readme
{
    my $folder = shift;
    my $filename = (-f "$folder/README.txt") ? "$folder/README.txt" : "$folder/README.md";
    open(README, $filename) or return;
    binmode(README, ':utf8');
    my %metadata;
    my @attributes = ('Documentation status', 'Data source', 'Data available since', 'License', 'Genre', 'Contributors');
    my $attributes_re = join('|', @attributes);
    while(<README>)
    {
        s/\r?\n$//;
        s/^\s+//;
        s/\s+$//;
        s/\s+/ /g;
        if(m/^($attributes_re):\s*(.*)$/i)
        {
            my $attribute = $1;
            my $value = $2;
            $value = '' if(!defined($value));
            if(exists($metadata{$attribute}))
            {
                print("WARNING: Repeated definition of '$attribute' in $folder/$filename\n");
            }
            $metadata{$attribute} = $value;
            if($attribute eq 'Data available since')
            {
                if($metadata{$attribute} =~ m/^UD v1\.(\d)$/ && $1 <= 2)
                {
                    $metadata{'release'} = 1;
                }
            }
        }
        elsif(m/change\s*log/i)
        {
            $metadata{'changelog'} = 1;
        }
    }
    close(README);
    return \%metadata;
}
