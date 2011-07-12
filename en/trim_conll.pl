#/usr/local/bin/perl
open OUTPUT, ">$ARGV[1]" or die $!;
open INPUT, "$ARGV[0]" or die $!;
while (<INPUT>) { 

my @tokens = split("\t",$_);
#print $_;
if(@tokens>2){

print OUTPUT  "$tokens[0]\t$tokens[1]\t$tokens[2]\t$tokens[3]\t$tokens[4]\t$tokens[5]\t$tokens[8]\t$tokens[9] \n";
}
else{
print OUTPUT "\n";
}
}
close OUTPUT;
close INPUT;
