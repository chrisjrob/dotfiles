#! /usr/bin/perl
#
# vehicle-reminder-tracker.pl
#
# Accepts two files as arguments
# compares them 
# and outputs a third file listing the changes
#

use warnings;
use strict;

my $count = @ARGV;
if ($count != 2) {
    print "USAGE vehicle-reminder-tracker.pl file1.xls file2.xls\n";
    exit;
}

# Load CSV files into hash refs
# with registration number as key
my $file0_ref = load_file_from_csv( $ARGV[0] );
my $file1_ref = load_file_from_csv( $ARGV[1] );

# Build unique list of registration numbers from both files
my @vehicles  = list_of_vehicles( $file0_ref, $file1_ref );

my $vehicles_ref;
foreach my $vehicle (sort @vehicles) {

    # Vehicle does not exist in the second database
    # assume deleted since
    #
    if ( (defined $file0_ref->{ $vehicle }) and (not defined $file1_ref->{ $vehicle }) ) {
        $vehicles_ref->{ $vehicle } = $file0_ref->{ $vehicle };
        $vehicles_ref->{ $vehicle }{'Delta Service'} = '';
        $vehicles_ref->{ $vehicle }{'Delta MOT'} = '';
        $vehicles_ref->{ $vehicle }{'Delta Visit'} = '';
        $vehicles_ref->{ $vehicle }{'Comment'} = 'Deleted in file 2';

    # vehicles does not exist in the first database
    # assume new vehicle
    #
    } elsif ( (not defined $file0_ref->{ $vehicle }) and (defined $file1_ref->{ $vehicle }) ) {
        $vehicles_ref->{ $vehicle } = $file1_ref->{ $vehicle };
        $vehicles_ref->{ $vehicle }{'Delta Service'} = '';
        $vehicles_ref->{ $vehicle }{'Delta MOT'} = '';
        $vehicles_ref->{ $vehicle }{'Delta Visit'} = '';
        $vehicles_ref->{ $vehicle }{'Comment'} = 'New record in file 2';

    # Hash is identical
    # except possibly for date of last visit
    #
    } elsif ( hash_matches( $file0_ref->{ $vehicle }, $file1_ref->{ $vehicle } ) ) {
        next;

    # Vehicle is in both databases, but has changed
    # record the change
    #
    } else {

        $vehicles_ref->{ $vehicle } = $file1_ref->{ $vehicle };
        $vehicles_ref->{ $vehicle }{'Comment'} = 'Changed ';

        # Service reminder flag has changed
        #
        if ($file0_ref->{ $vehicle }{'Allow Service Reminder'} ne $file1_ref->{ $vehicle }{'Allow Service Reminder'}) {
            $vehicles_ref->{ $vehicle }{'Delta Service'} = 'TRUE';
            $vehicles_ref->{ $vehicle }{'Comment'} .= 'Service Reminder ';
        }

        # MOT reminder flag has changed
        if ($file0_ref->{ $vehicle }{'MOT Reminder'} ne $file1_ref->{ $vehicle }{'MOT Reminder'}) {
            $vehicles_ref->{ $vehicle }{'Delta MOT'} = 'TRUE';
            $vehicles_ref->{ $vehicle }{'Comment'} .= 'MOT Reminder';
        }

    }

    # List of keys
    my @keys = (
        'Registration Number',
        'Last Workshop Visit',
        'Allow Service Reminder',
        'MOT Reminder',
        'Delta Service',
        'Delta MOT',
        'Delta Visit',
        'Comment'
    );

    # Cannot seem to write a hash of hashes to CSV directly in CSV_XS
    # so convert to array of hashes first
    #
    my $out_ref = convert_hash_to_array( $vehicles_ref, \@keys );

    # Write out array of hashes
    csv( in => $out_ref, out => 'outfile.csv', headers => \@keys );

    #use Data::Dumper;
    #print Dumper( $out_ref );

}


exit;

# Convert a hash of hashes into an array hash
# where the first element of each record is the hash key
# 
sub convert_hash_to_array {
    my $vehicles_ref    = shift;
    my $keys_ref        = shift;

    my @vehicles;
    foreach my $vehicle (sort keys %{ $vehicles_ref }) {

        my @vehicle;
        foreach my $key (@{ $keys_ref }) {
            if ($key eq 'Registration Number') {
                push( @vehicle, $vehicle );
            } else {
                push( @vehicle, $vehicles_ref->{ $vehicle }{ $key } );
            }
        }

        push( @vehicles, \@vehicle );
    }

    return \@vehicles;

}

# Returns true if the hash contents match
# for both keys and values
# ignoring Last Workshop Visit
#
sub hash_matches {
    my ($veh0_ref, $veh1_ref) = @_;

    foreach my $key (keys %{ $veh0_ref }) {
        if ($key eq 'Last Workshop Visit') {
            next;
        } elsif (not defined $veh1_ref->{ $key }) {
            return 0;
        } elsif ($veh0_ref->{ $key } ne $veh1_ref->{ $key }) {
            return 0;
        }
    }

    foreach my $key (keys %{ $veh1_ref }) {
        if ($key eq 'Last Workshop Visit') {
            next;
        } elsif (not defined $veh0_ref->{ $key }) {
            return 0;
        }
    }

    return 1;
}

# Combine both databases
# and then de-dupe to ensure we have 
# a complete list of all vehicles
#
sub list_of_vehicles {
    my ($file0_ref, $file1_ref) = @_;

    my @file0_vehicles = keys %{ $file0_ref };
    my @file1_vehicles = keys %{ $file0_ref };

    my %unique;
    foreach my $vehicle (@file0_vehicles, @file1_vehicles) {
        $unique{ $vehicle } = 1;
    }

    return keys %unique;
}

# Simple load from CSV
#
sub load_file_from_csv {
    my $filename = shift;

    use Text::CSV_XS 'csv';

    my $data_ref = csv(in => $filename, key => 'Registration Number', headers => 'auto');

    return $data_ref;
}
