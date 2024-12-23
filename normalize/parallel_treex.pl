#!/usr/bin/env perl
# Processes a set of Treex files in the HamleDT ecosystem, in parallel on the
# cluster. Writes the modified files to the target folder.
# Copyright © 2023 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use Cwd;
use cluster; # Dan's library for the ÚFAL cluster

sub usage
{
    print STDERR ("Usage: parallel_treex.pl <scenario>\n");
    print STDERR ("    This script may be called the same way as the original treex -p was called.\n");
    print STDERR ("    However, it is only prepared for the HamleDT ecosystem. It is not a general wrapper.\n");
    print STDERR ("    <scenario> will be passed to treex as is.\n");
    print STDERR ("    List of input files will be appended at the end.\n");
    print STDERR ("    The input files are 'data/{00,01,...}/{train,dev,test}/*.treex'.\n");
    print STDERR ("    Parallel Treex can use even a different path (if found after Read::Treex or at the\n");
    print STDERR ("    end of the scenario) but it expects the path to end with '/*.treex'.\n");
}

my $input_pattern = get_input_pattern_and_discard_reader(); # modifies @ARGV in-place
if(!defined($input_pattern))
{
    die("Unknown HamleDT input pattern");
}
if(scalar(@ARGV) == 0)
{
    die("Unknown Treex scenario");
}

# Typically we either run make prague or make ud. The former converts the input
# Treex files (00) to Prague-style HamleDT (01), the latter converts this to
# Universal Dependencies (02). If we are in the HamleDT normalize subfolder of
# the given treebank, the Treex files are accessible via a path like this:
# data/treex/{00,01,02}/{train,dev,test}/*.treex (or *.treex.gz)
# The total number of files can range from 1 to over 5000.

if(!-d 'data/treex')
{
    die("Cannot find 'data/treex'");
}
my @files_treex = glob("$input_pattern/*.treex");
my @files_treex_gz = glob("$input_pattern/*.treex.gz");
my $nt = scalar(@files_treex);
my $ntg = scalar(@files_treex_gz);
print("In $input_pattern, there are $nt treex files and $ntg treex.gz files (train, dev and test combined).\n");
if($ntg > 0)
{
    die("Processing treebanks with gzipped Treex files is currently not supported");
}
# The job names on the cluster will be derived from the current treebank folder.
my $jobname = getcwd();
$jobname =~ s:^.+/([^/]+)$:$1:;
# For each planned job, collect the names of the files it will process.
###!!! Původně jsem tady měl 300 úloh a fungovalo to, ale 15.1.2023 odpoledne
###!!! se mi najednou začalo opakovaně stávat, že jen 123 úloh naběhlo, zatímco
###!!! zbývajících 177 skončilo, zřejmě napořád, ve stavu pending (launch
###!!! failed requeued held). Tak zkusím odeslat jen 100 úloh najednou.
###!!! To zřejmě pomohlo, akorát ten výpočet samozřejmě trvá déle.
###!!! Googlením jsem zjistil, že ten problém může být způsoben různými věcmi,
###!!! např. přetížením plánovače. Taky že ten stav úlohy je míněn pro uživatele
###!!! ke kontrole a nemusí nutně znamenat, že tahle úloha je ztracená. Mělo by
###!!! být možné ji oživit pomocí scontrol release $job_id.
my $njobs = 100;
my $min_files_per_job = int($nt / $njobs);
my $n_jobs_extra_file = $nt % $njobs;
my @jobfiles = ();
for(my $ijob = 0; $ijob < $njobs; $ijob++)
{
    my $n_files_this_job = $min_files_per_job;
    if($n_jobs_extra_file > 0)
    {
        $n_files_this_job++;
        $n_jobs_extra_file--;
    }
    die if(scalar(@files_treex) < $n_files_this_job); # sanity check
    push(@{$jobfiles[$ijob]}, splice(@files_treex, 0, $n_files_this_job));
}
# Submit the jobs to the cluster.
my @chunks = ();
my $command = join(' ', ('treex', escape_argv_elements(@ARGV)));
my $i = 1;
for my $j (@jobfiles)
{
    # Do not submit empty jobs if there are fewer files than the pre-set $njobs.
    my $n = scalar(@{$j});
    last if($n == 0);
    my $files = join(' ', @{$j});
    my $fcommand = "$command -- $files";
    my $jobid = cluster::qsub('name' => $jobname, 'command' => $fcommand);
    print STDERR ("$jobid: $n files\n");
    push(@chunks, {'number' => $i++, 'job_id' => $jobid});
}
while(cluster::qstat_resubmit(\@chunks))
{
    stop_if_job_failed(@chunks);
    sleep(5);
}
# Make sure that all chunks were processed successfully.
my $ok = 1;
my $nw = 0;
my $ne = 0;
my @warnings = ();
my @logfiles_with_errors = ();
foreach my $chunk (@chunks)
{
    my $logfile = "$jobname.$$.o$chunk->{job_id}";
    if(!-f $logfile)
    {
        print STDERR ("ERROR: $logfile does not exist.\n");
        $ok = 0;
    }
    else
    {
        # If there are warnings, print them.
        my $treexlog = `grep -P '^TREEX-' $logfile`;
        chomp($treexlog);
        my @loglines = ();
        my $docname = ' ' x 20;
        foreach my $line (split(/\n/, $treexlog))
        {
            # TREEX-INFO:     4.531:  Document 1/7 data/treex/01/test/wsj2393 loaded from data/treex/01/test/wsj2393.treex
            if($line =~ m/^TREEX-INFO:.*Document \d+\/\d+ (data\S+) loaded from/)
            {
                $docname = $1;
                $docname = '...'.substr($docname, length($docname)-17) if(length($docname) > 20);
                $docname .= (' ' x (20-length($docname))) if(length($docname) < 20);
            }
            push(@loglines, "$chunk->{job_id} $docname $line\n");
            # TREEX-INFO:     5.506:  Saving to data/conllu/test/wsj2393.conllu
            if($line =~ m/^TREEX-INFO:.*Saving to data\S+/)
            {
                # If the scenario ends with multiple writers, only the first one
                # will have the docname prepended but that is no disaster.
                $docname = ' ' x 20;
            }
        }
        $nw += scalar(grep {m/TREEX-WARN/} (@loglines));
        $ne += scalar(grep {m/TREEX-FATAL/} (@loglines));
        push(@warnings, grep {m/TREEX-(WARN|FATAL)/} (@loglines));
        $treexlog = join('', @loglines);
        print STDERR ($treexlog);
        # Sometimes SLURM reports some internal problems after Treex has successfully finished its job; let's ignore this.
        my $lastline = `grep -v '^slurmstepd:' $logfile | tail -1`;
        chomp($lastline);
        if($lastline !~ m/Execution succeeded\./)
        {
            print STDERR ("ERROR: last line of $logfile is '$lastline'.\n");
            push(@logfiles_with_errors, $logfile);
            $ok = 0;
        }
    }
}
# Print warnings and fatal errors again so that the user does not have to search
# for them among the thousands of TREEX-INFO lines above.
if($nw || $ne)
{
    print STDERR ("-------------------------------------------------------------------------------\n");
    print STDERR (join('', @warnings));
    print STDERR ("-------------------------------------------------------------------------------\n");
}
if($nw)
{
    print STDERR ("There were $nw warnings.\n");
}
if($ne)
{
    print STDERR ("There were $ne fatal errors.\n");
}
if($ok)
{
    print STDERR ("All jobs executed successfully.\n");
}
else
{
    print STDERR ("At least one of the jobs failed.\n");
    print STDERR ("See ".join(', ', @logfiles_with_errors).".\n");
    die;
}



#------------------------------------------------------------------------------
# Scans the @ARGV for either the Read::Treex block or the list of files at the
# end. Removes this from @ARGV. Derives the input step number from the file
# pattern and returns it.
#------------------------------------------------------------------------------
sub get_input_pattern_and_discard_reader
{
    my @new_argv = ();
    my $pattern = '';
    my $state = 'normal';
    foreach my $arg (@ARGV)
    {
        # The reader is not necessarily the first item in @ARGV. There can be
        # also options, such as -Lcs.
        if($state eq 'reader')
        {
            # :: signals a name of a block, i.e., no longer a parameter of the reader.
            if($arg =~ m/::/)
            {
                $state = 'normal';
            }
            elsif($arg =~ m/^from=/)
            {
                $pattern = $arg;
            }
        }
        if($state eq 'infilelist')
        {
            # Any input file or file pattern should contain the path we are
            # looking for, so we do not have to remember them all.
            $pattern = $arg;
        }
        if($state eq 'normal')
        {
            if($arg eq 'Read::Treex')
            {
                $state = 'reader';
                next;
            }
            if($arg eq '--')
            {
                $state = 'infilelist';
                next;
            }
            push(@new_argv, $arg);
        }
    }
    @ARGV = @new_argv;
    $pattern =~ s/^from=//;
    # Treex uses the exclamation mark to signal that the path contains wildcards
    # that should be resolved. We assume that this is always the case and ignore
    # the exclamation mark.
    $pattern =~ s/^\!//;
    # Treex can read various types of files. At present, we assume that this
    # script is only called on .treex files. But it can be easily modified to
    # work with other files, too.
    if($pattern !~ s/\/\*\.treex(\.gz)?$//)
    {
        die("Input file pattern '$pattern' does not end with '/*.treex'");
    }
    return $pattern;
}



#------------------------------------------------------------------------------
# Escapes one or more @ARGV elements so that they can be passed again via
# commandline. For example, if someone called us with this command-line argument
# (a parameter of Util::Eval):
#     anode='if($.deprel() eq "coord") {$.set_deprel("dep");}'
# we will find it without the apostrophes in @ARGV:
#     anode=if($.deprel() eq "coord") {$.set_deprel("dep");}
# So we must put the apostrophes back.
#------------------------------------------------------------------------------
sub escape_argv_elements
{
    return map
    {
        my $argv = $_;
        # Treex block name is OK.
        if(m/^[A-Za-z_0-9:]+$/)
        {
            # Do nothing.
        }
        # Treex block parameter could have apostrophes around everything but it is natural to only put them around the value, if necessary.
        elsif(m/^([a-z_A-Z0-9]+)=(.*)$/)
        {
            my $parameter = $1;
            my $value = $2;
            if($value !~ m/^[a-z_A-Z0-9]*$/)
            {
                $argv = "$parameter='$value'";
            }
        }
        # We do not expect anything else but if we encounter it, let's escape it, too.
        else
        {
            $argv = "'$argv'";
        }
        $argv
    }
    (@_);
}



#------------------------------------------------------------------------------
# Stop waiting if a job failed.
#------------------------------------------------------------------------------
sub stop_if_job_failed
{
    my @chunks = @_;
    foreach my $chunk (@chunks)
    {
        my $logfile = "$jobname.$$.o$chunk->{job_id}";
        if(-f $logfile)
        {
            # If there are warnings, print them.
            my $treexlog = `grep -P '^TREEX-' $logfile`;
            chomp($treexlog);
            my @loglines = ();
            my $docname = ' ' x 20;
            foreach my $line (split(/\n/, $treexlog))
            {
                # TREEX-INFO:     4.531:  Document 1/7 data/treex/01/test/wsj2393 loaded from data/treex/01/test/wsj2393.treex
                if($line =~ m/^TREEX-INFO:.*Document \d+\/\d+ (data\S+) loaded from/)
                {
                    $docname = $1;
                    $docname = '...'.substr($docname, length($docname)-17) if(length($docname) > 20);
                    $docname .= (' ' x (20-length($docname))) if(length($docname) < 20);
                }
                push(@loglines, "$chunk->{job_id} $docname $line\n");
                # TREEX-INFO:     5.506:  Saving to data/conllu/test/wsj2393.conllu
                if($line =~ m/^TREEX-INFO:.*Saving to data\S+/)
                {
                    # If the scenario ends with multiple writers, only the first one
                    # will have the docname prepended but that is no disaster.
                    $docname = ' ' x 20;
                }
            }
            if(scalar(grep {m/TREEX-FATAL/} (@loglines)) >= 1)
            {
                my $treexlog = join('', @loglines);
                print STDERR ($treexlog);
                print STDERR ("At least one of the jobs failed.\n");
                print STDERR ("See $logfile.\n");
                die;
            }
        }
    }
}
