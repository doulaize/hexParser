#!/usr/bin/perl
use strict;
use Data::Dumper;

my @files = ("ex2.hex");


sub calcCS {
	my ($s) = @_;
	my $res = 0;
	foreach my $byte (( $s =~ m/../g )) {
		$res += hex($byte); 
	}
	return 0xff - ($res&0xff) + 1;
}

sub analyzeLineHex {
	my ($s, $baseAdd, $curAdd, @parsedData) = @_;
	
	if  (substr($s, 0, 1) ne ":") { die "First char must be ':'\n";}

	my $byteCount = hex(substr($s, 1, 2));
	my $address = hex(substr($s, 3, 4));

	my $recordType = hex(substr($s, 7, 2));
	my $data = substr($s, 9, $byteCount*2);
	my $cs = hex(substr($s, 9 + $byteCount*2, 2));

	if (calcCS(substr($s,1, 8 + $byteCount*2)) != $cs) {die "CS is wrong. Expected $cs\n";}
	
	if ($recordType == 0)  {
		if ($baseAdd+$curAdd == $baseAdd+$address) #continue in the same parsed entry
		{
			print " -- continue -- \n";
			$parsedData[0][1].=$data;
			$curAdd += $byteCount;
		} else {
			print " -- new entry -- \n";
			splice @parsedData, 0, 0, [$baseAdd+$address, $data];
			$curAdd = $address + $byteCount;		
		}
	}
	if ($recordType == 1)  {print "End Of File \n";}
	if ($recordType == 2)  {print "Extended Segment Address\n";}
	if ($recordType == 3)  {print "Start Segment Address\n";}
	if ($recordType == 4)  {print "Extended Linear Address\n";}
	if ($recordType == 5)  {print "Start Linear Address\n";}
 
	return ($baseAdd, $curAdd, @parsedData);
	
}

sub parseHex { 

	my ($filename) = @_;

	my $currentAddress = 0;
	my $baseAddress = 0;
	my @parsedData = ([0,""]);

        open(my $fh, $filename) or warn "Can't open $filename: $!";
        while ( ! eof($fh) ) {
            defined( $_ = readline $fh )
                or die "readline failed for $filename: $!";
            
		($baseAddress, $currentAddress, @parsedData) = analyzeLineHex($_, $baseAddress, $currentAddress, @parsedData);
		
        }

	 print Dumper(@parsedData);
}


foreach my $file (@files) {
	parseHex($file);
}
