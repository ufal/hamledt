#!/usr/bin/env perl
# Takes a freshly made release of Universal Dependencies, makes it available
# on the ÚFAL network and starts import to HamleDT. This is an ÚFAL-specific
# script with hard-coded paths.
# Copyright © 2023 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use Getopt::Long;
use dzsys; # from Dan's Perl libraries
use udlib; # from Universal Dependencies tools repository

sub usage
{
    print STDERR ("Usage: $0 --release 2.12\n");
}

my $udpath = '/net/work/people/zeman/unidep'; # clones of all UD repos, as well as the packed releases, are here
my $datapath = '/net/data'; # ÚFAL data (downloaded or mostly static)
my $treexpath = '/net/work/people/zeman/treex';
my $release;
GetOptions
(
    'release=s' => \$release
);

# Check that Treex knows all language codes that are used in UD.
chdir($treexpath) or die("Cannot go to '$treexpath': $!");
dzsys::saferun("git pull --no-edit") or die;
chdir('lib/Treex/Core') or die("Cannot go to '$treexpath/treex/lib/Treex/Core': $!");
my $udlanguages = udlib::get_language_hash($udpath.'/docs-automation/codes_and_flags.yaml');
my $n_missing_codes = 0;
my %known_codes;
open(XMLSCHEMA, 'share/tred_extension/treex/resources/treex_subschema_langcodes.xml') or die("Cannot read '$treexpath/lib/Treex/Core/share/tred_extension/treex/resources/treex_subschema_langcodes.xml': $!");
while(<XMLSCHEMA>)
{
    # <value>cs</value> <!-- Czech -->
    if(m:<value>([a-z]+)</value>:)
    {
        $known_codes{$1}++;
    }
}
close(XMLSCHEMA);
my @udlangnames = sort {$udlanguages->{$a}{family} cmp $udlanguages->{$b}{family}} (keys(%{$udlanguages}));
print("Add to $treexpath/lib/Treex/Core/share/tred_extension/treex/resources/treex_subschema_langcodes.xml:\n");
foreach my $udl (@udlangnames)
{
    my $lcode = $udlanguages->{$udl}{lcode};
    if(!exists($known_codes{$lcode}))
    {
        print("      <value>$lcode</value> <!-- $udl -->\n");
        $n_missing_codes++;
    }
}
%known_codes = ();
open(TYPES, 'Types.pm') or die("Cannot read '$treexpath/lib/Treex/Core/Types.pm': $!");
while(<TYPES>)
{
    # 'abq'     => "Abaza",
    if(m/'([a-z]{3})' +=> ".+?",/)
    {
        $known_codes{$1}++;
    }
}
close(TYPES);
@udlangnames = sort {$udlanguages->{$a}{lcode} cmp $udlanguages->{$b}{lcode}} (keys(%{$udlanguages}));
print("Add to $treexpath/lib/Treex/Core/Types.pm:\n");
foreach my $udl (@udlangnames)
{
    my $lcode = $udlanguages->{$udl}{lcode};
    # In Types.pm the hash is called %EXTRA_LANG_CODES and it only contains three-letter codes.
    next if(length($lcode) < 3);
    if(!exists($known_codes{$lcode}))
    {
        print("    '$lcode'     => \"$udl\",\n");
        $n_missing_codes++;
    }
}
if($n_missing_codes > 0)
{
    die("$n_missing_codes language codes are missing in Treex. Add them there first");
}
# Copy the release to /net/data.
if(!defined($release))
{
    usage();
    die("Unknown release number");
}
elsif($release !~ m/^[1-9]\.[1-9][0-9]*$/)
{
    usage();
    die("Release number '$release' is in wrong format");
}
chdir($udpath) or die("Cannot go to '$udpath': $!");
if(!-d 'release-'.$release)
{
    die("Release does not exist: $udpath/release-$release");
}
if(!-f 'release-'.$release.'/ud-treebanks-v'.$release.'.tgz')
{
    die("Release does not exist: $udpath/release-$release/ud-treebanks-v$release.tgz");
}
chdir($datapath) or die("Cannot go to '$datapath': $!");
if(-d 'universal-dependencies-'.$release)
{
    die("$datapath/universal-dependencies-$release already exists");
}
dzsys::saferun("tar xzf $udpath/release-$release/ud-treebanks-v$release.tgz ; mv ud-treebanks-v$release universal-dependencies-$release") or die;
