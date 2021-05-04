#! /usr/bin/perl
# 
# monitor-webpage.pl
#
# Monitors a webpage and outputs on change
#

my $webpage = $ARGV[0];
my $file    = $ARGV[1];

if (${ @ARGV } < 2) {
    print "monitor-webpage https://example.com/page /home/user/page\n";
}

if (-e $file) {
    rename($file, "$file.old") or die "Cannot rename $file to $file.old: $!";
} else {
    print "Hmm $file does not exist\n";
}


system('/usr/bin/wget', '-O', $file, $webpage);

if ( (-e $file) and (-e "$file.old") ) {
    system('/usr/bin/diff', "$file.old", $file);
}

