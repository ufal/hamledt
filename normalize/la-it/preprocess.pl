#!/usr/bin/env perl
my $docid = shift(@ARGV); # scg | forma
my $i = 1;
while(<>)
{
    ###!!! Only for this version of the input data!
    ###!!! Correction of the sentence id to keep in sync with the removed "forma" sentences.
    my $skip = ($docid eq 'forma' && $i >= 2509) ? 114 : 0;
    $sid = sprintf("ittb-$docid-s%d", $i+$skip);
    if(m/^\s*$/)
    {
        $i++;
    }
    else
    {
        my @f = split(/\t/, $_);
        # Read the semantic type and remove the extra column.
        my $st = $f[10];
        $st =~ s/\r?\n$//;
        splice(@f, 10);
        $f[9] .= "\n";
        # Add semantic type and sentence id to features.
        $f[5] = "" if($f[5] eq "_");
        my @ff = split(/\|/, $f[5]);
        push(@ff, "st$st") unless($st eq "_");
        push(@ff, "sid=$sid");
        $f[5] = scalar(@ff) ? join("|", @ff) : "_";
        $_ = join("\t", @f);
    }
    print;
}