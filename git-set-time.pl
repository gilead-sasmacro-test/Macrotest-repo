################################
# This script will change the files time stamp based on the commit log
# After cloning a repo run this script in side that repository 
# this script require perl 
##############################
#!/usr/bin/perl
my %attributions;
my $remaining = 0;

open IN, "git ls-tree -r --full-name HEAD |" or die;
while (<IN>) {
    if (/^\S+\s+blob \S+\s+(\S+)$/) {
        $attributions{$1} = -1;
    }
}
close IN;

$remaining = (keys %attributions) + 1;
print "Number of files: $remaining\n";
open IN, "git log -r --root --raw --no-abbrev --date=raw --pretty=format:%h~%cd~ |" or die;
while (<IN>) {
    if (/^([^:~]+)~([^~]+)~$/) {
        ($commit, $date) = ($1, $2);
    } elsif (/^:\S+\s+1\S+\s+\S+\s+\S+\s+\S\s+(.*)$/) {
        if ($attributions{$1} == -1) {
            $attributions{$1} = "$date";
            $remaining--;

            utime $date, $date, $1;
            if ($remaining % 1000 == 0) {               
                print "$remaining\n";
            }
            if ($remaining <= 0) {
                break;
            }
        }
    }
}
close IN;
