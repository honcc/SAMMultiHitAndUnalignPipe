#!/usr/bin/perl -w
$|++;
use strict;

######################################################################################################################################################
#
#	Description
#		This is a perl script to read the SAM output streaming from bowtie STDIN, then add NH tag, remove unampped read, and remove secondary read and stream to STDOUT.
#
#	Input
#		--noSec do not output secondary alignment, will only output the first bowtie alignment of the same read;
#	Output
#
#	Usage
#
#		v0.1
#		debut
#
######################################################################################################################################################
#

#---get the noSec value
my $noSec = "no";
$noSec = "yes" if grep /--noSec/, @ARGV;
my $lastReadName = "initialize";
my $NM = 0;
my @outputAry = ();
while (my $theLine = <STDIN>) {
	chomp $theLine;
	if ($theLine !~ m/^\@/) { #---non header line
		my @theLineSplt = split /\t/, $theLine;
		my $SAMFlag = $theLineSplt[1];
		next if $SAMFlag == 4; #---unaligned single end reads;

		my $curntReadName = $theLineSplt[0];
		#---change read
		if (($curntReadName ne $lastReadName) and ($lastReadName ne "initialize")) {
			my $qual = 255;
			$qual = 0 if ($NM > 1);
			foreach my $alignmentToPrint (@outputAry) {
				my @alignmentToPrintSplt = split /\t/, $alignmentToPrint;
				$alignmentToPrintSplt[4] = $qual;
				push @alignmentToPrintSplt, "NH:i:".$NM;
				my $alignmentToPrintNHAdded = join "\t", @alignmentToPrintSplt;
				print $alignmentToPrintNHAdded."\n";
				last if ($noSec eq "yes");
			}
			@outputAry = ();
			$NM = 1;
			
		} else {#----same read or the first read
			$NM++;
		}
		push @outputAry, $theLine;
		$lastReadName = $curntReadName;
		
	} else {#---header line
		print $theLine."\n";
	}
}
exit;
