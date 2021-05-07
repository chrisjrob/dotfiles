#! /usr/bin/perl
# 
# monitor-webpage.pl
#
# Monitors a webpage and outputs on change
#

my $webpage = $ARGV[0];
my $file    = $ARGV[1];
my $count   = @ARGV;

if ($count < 2) {
    print "monitor-webpage https://example.com/page /home/user/page\n";
}

if (-e $file) {
    rename($file, "$file.old") or die "Cannot rename $file to $file.old: $!";
} else {
    print "Hmm $file does not exist\n";
}

dump_text($webpage, $file);

compare_pages("$file.old", $file);

exit;

sub dump_page {
    my ($webpage, $file) =@_;

    system('/usr/bin/wget', '--quiet', '-O', $file, $webpage);

}

sub dump_text {
    my ($webpage, $file) =@_;

    my $content = `lynx --dump $webpage`;
    
    open(my $fh , ">", $file) or die "Cannot write to $file: $!";
    print $fh $content;
    close($fh) or die "Cannot close $file: $!";

}

sub compare_pages {
    my ($old, $new) = @_;

    if ( (-e $old) and (-e $new) ) {
        system('/usr/bin/diff', $old, $new);
    }

}
