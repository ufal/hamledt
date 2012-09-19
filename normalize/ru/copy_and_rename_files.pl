#!/usr/bin/perl
# Reads Syntagrus files from the source folder and copies them to the target folder.
# Converts file names so that they do not use Cyrillic letters.
# Copyright © 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
use Encode;

$srcdir = "$ENV{TMT_ROOT}/share/resource_data/syntagrus";
$tgtdir = "$ENV{TMT_ROOT}/share/data/resources/hamledt/ru/source";
@src_subdirs = qw(2003 2004 2005 2006 2007 2008 Uppsala news);
# File renaming pattern. Note that the mapping is not reversible.
@latin = qw(
    E JO DJ GJ JE DZ I JI J LJ NJ TSH KJ I W DZH
    A B V G D E ZH Z I J K L M N O P R S T U F H C CH SH SHCH + Y - E JU JA
    a b v g d e zh z i j k l m n o p r s t u f h c ch sh shch + y - e ju ja
    e jo dj gj je dz i ji j lj nj tsh kj i w dzh
);
for(my $i = 1024; $i<=1119; $i++)
{
    $latin{chr($i)} = $latin[$i-1024];
}
# Get rid of spaces, too.
$latin{' '} = '_';
foreach my $subdir (@src_subdirs)
{
    my $path = "$srcdir/$subdir";
    opendir(DIR, $path) or die("Cannot read folder $path: $!\n");
    my @files = readdir(DIR);
    closedir(DIR);
    # There are many files named using Cyrillic.
    # The ÚFAL network file system returns them in 8-bit encoding but in fact these are bytes of UTF-8.
    foreach my $file (@files)
    {
        if($file =~ m/\.tgt$/)
        {
            # Every "character" of $file is in fact a byte of the UTF-8 encoding.
            # Perl now thinks it is a character and since its value can exceed 127, it itself can be encoded internally using multiple bytes.
            # Let's make each character a single byte first.
            my $file1 = encode('iso-8859-1', $file);
            # Perl now thinks of the string as a single-byte encoding. Let's interpret it as UTF-8, which is what it really is.
            my $file2 = decode('utf8', $file1);
            # Convert unwanted characters to ASCII.
            my $file3 = join('', map {exists($latin{$_}) ? $latin{$_} : $_} (split(//, $file2)));
            print("$file2\t$file3\n");
            # Hard-wired selection of the test file:
            if($file3 eq 'vyzhivshij_kamikadze.tgt')
            {
                $file3 .= '.TEST';
            }
            # Copy the source file to the target file.
            my $srcfile = "$path/$file";
            my $tgtfile = "$tgtdir/$file3";
            open(SRC, $srcfile) or die("Cannot read $srcfile: $!\n");
            binmode(SRC, ':encoding(windows-1251)');
            open(TGT, ">$tgtfile") or die("Cannot write $tgtfile: $!\n");
            while(<SRC>)
            {
                # Change the information about encoding because we are recoding the contents to UTF-8.
                s/encoding="windows-1251"/encoding="utf8"/;
                print TGT;
            }
            close(SRC);
            close(TGT);
        }
    }
}
