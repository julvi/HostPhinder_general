#!/usr/bin/perl

use warnings;
use strict;

use Data::Dumper;

my $fnas = "PROPHAGES/HostPhinder/results/prophage_fnas";
my (%frac_qFreq, %frac_dFreq); #These hashes of array will count the frequency of right [1]and wrong [0]predictions per each value of frac_q and frac_d respectively
my ( $frac_qMAX, $frac_qmin, $frac_dMAX, $frac_dmin ) = ( 0 ) x 4;


################################################################################ READ tax_info ################################################################################

open ( IN, '<', "PROPHAGES/tax_info" ) or die "Can't open the file: $!";
#Save the file into an array
my @taxonomies;
while ( <IN> ) {
	push @taxonomies, [ split ];
}
close IN;
############################################################# Open each profage for each bacgterium ###################################################################################################
#print $frac_qmin . "\n";
opendir ( FNAS, $fnas ) or die $!;
#read each bacteria
while ( my $bact = readdir ( FNAS ) ) {
	next if ( $bact =~ m/^\./ );
	opendir ( BACT, "$fnas/$bact" ) or die $!;
	#read each NC file
	my $NCN = 0;
	while ( my $NCid = readdir ( BACT ) ) {
		next if ( $NCid =~ m/^\./ );
		my $NCN += 1;
		print "NC: $NCN\n";
		opendir ( NC, "$fnas/$bact/$NCid" );
		my $prophageN = 0;
		while ( my $prophage = readdir ( NC ) ) {
			next if ( $prophage =~ m/^\./ );
			$prophageN += 1;
			print "prophage: $prophageN\n";
			my $pfilename = "$fnas/$bact/$NCid/$prophage";
			#save the name of the folders (bacterium and NC)
			my $sp_NC_names = $1 if "$bact/$NCid" =~ m/(.*?)_1$/;
			print "\nFolder name: " . $sp_NC_names . "\n\n";
			#print "$pfilename\n";
################################################################################################################################################################################
#SORT HostPhinder PREDICTIONS
################################################################################################################################################################################
			#my $pfilename = "PROPHAGES/HostPhinder/results/prophage_fnas/Listeria_monocytogenes_J1_220_uid179735/NC_021830_1/prophage.1.fna_pred.new";

			open ( IN, '<', "$fnas/$bact/$NCid/$prophage" ) or die "Can't open the file: $!";

			#Read the file into array of arrays
			my @HPpredictions;
			#Jump to the second line
			my $i = 0;
			while ( defined ( my $line = <IN> ) ) {
				next if $line =~ m/^Template/;
				$HPpredictions[$i] = [ split " ", $line ];
				$i = 1;

			}
			if ( $i == 1 ) {
#				print "$bact/$NCid/$prophage\n";
				#print "######################### Here comes the UNsorted array of arrays #########################\n";
			}
			
			#for my $aref ( @HPpredictions ) {
			#	print "\t [ @$aref ], \n";
			#}
################################################## Sort array of arrays according to frac_q ###########################################################################

			#Reverse sort the array of arrays according to the 6th element of each array (frac_q)
			my @frac_qAoA = sort { $b -> [5] <=> $a -> [5] } @HPpredictions;

			my $first_frac_q = "";
			my $new_frac_q = 0;
			#if $i => 1 means that there is a least one result: see while loop up
			if ( $i == 1 ) {
				$first_frac_q = $1 if $frac_qAoA[0][10] =~ m/"(.*?)"/;
				$new_frac_q = $frac_qAoA[0][5] + 0;
				#$frac_qFreq{$new_frac_q} += 1;
#				print Dumper \@frac_qAoA;
				print "$first_frac_q\n";
				$frac_qMAX = max($frac_qMAX, $new_frac_q);
				if ( $frac_qmin == 0 ) {
					$frac_qmin = $new_frac_q;
				} else {
					$frac_qmin = min($frac_qmin, $new_frac_q);
				}
				#print "The first is: $first_frac_q with frac_q: $frac_qAoA[0][5]\n\n";
				
			}
################################################## Sort array of arrays according to frac_d ###########################################################################


			#Reverse sort the array of arrays according to the 7th element of each array (frac_d)
			my @frac_dAoA = sort { $b -> [6] <=> $a -> [6] } @HPpredictions;

			#print the entire array of arrays
			#print the sorted array
			#for my $aref ( @frac_dAoA ) {
			#	print "\t [ @$aref ], \n";
			#}

			#print the entire first line == first element of the main array
			#print "The first is:\n";
			#for my $j ( 0 .. $#{ $sortedAoA[1] }) {
			#	print $sortedAoA[1][$j] . "\n";
			#}
			my $first_frac_d = "";
			my $new_frac_d = 0;
			if ( $i == 1 ) {
				$first_frac_d = $1 if $frac_dAoA[0][10] =~ m/"(.*?)"/;
				$new_frac_d = $frac_dAoA[0][6] + 0;
				#$frac_dFreq{$new_frac_d} += 1;
				#print "$frac_dAoA[0][6]\n";
				print "$first_frac_d\n";
				$frac_dMAX = max($frac_dMAX, $new_frac_d);
				if ( $frac_dmin == 0 ) {
					$frac_dmin = $new_frac_d;
				} else {
					$frac_dmin = min($frac_dmin, $new_frac_d);
				}
				#print "The first is: $first_frac_q with frac_q: $frac_qAoA[0][5]\n\n";
				
			}

################################################################################################################################################################################
#READ tax_info
################################################################################################################################################################################
			
			#print the array of arrays
			#for my $aref ( @AoA ) {
			#	print "\t [ @$aref ], \n";
			#}

			#print only the first (0) and the 7th column (6)
			#/panfs1/cge/people/henrike/genomes/tmp/Burkholderia_KJ006_uid165871/NC_017923.gbk
			my $right_species = "";
			#Check that that the filenames and the first element of the tax_info array are the same bacteria/NC
			#if ( $i == 1 ){
				for my $i ( 0 .. $#taxonomies ) {
					if ( $taxonomies[$i][0] =~ m/\/panfs1\/cge\/people\/henrike\/genomes\/tmp\/(.*?)\.gbk/ && $1 eq $sp_NC_names ) {
						$right_species = $taxonomies[$i][6];
						#print "tax info file:\n";
						print "#########################$1\t$right_species\n\n";
						#for my $j ( 0 .. $#{ $AoA[$i] }) {
						#	print $AoA[$i][$j] . "\n";
						#}

					}
					
				}
			#}
			

############################################################## Check for identities ##################################################################################################################
			#my ( $genusRS, $genus_fq, $genus_fd) ;
			if ( $i == 1 ) {
				if ( $right_species eq $first_frac_q && $right_species eq $first_frac_d ) {
					print "Both the highest frac_q and highest frac_d give the right species: $right_species, $first_frac_q, $first_frac_d\n\n";
					$frac_qFreq{$new_frac_q}[1] += 1;
					$frac_qFreq{$new_frac_q}[0] += 1;
					$frac_dFreq{$new_frac_d}[1] += 1;
					$frac_dFreq{$new_frac_d}[0] += 1;
				} elsif ( $right_species eq $first_frac_q ) {
					print "The highest frac_q gives the right species: $right_species, $first_frac_q\n\n";
					$frac_qFreq{$new_frac_q}[1] += 1;
					$frac_qFreq{$new_frac_q}[0] += 1;
					$frac_dFreq{$new_frac_d}[0] += 1;
					$frac_dFreq{$new_frac_d}[1] += 0;
				} elsif ( $right_species eq $first_frac_d ) {
					print "The highest frac_d gives the right species: $right_species, $first_frac_d\n\n";
					$frac_dFreq{$new_frac_d}[1] += 1;
					$frac_dFreq{$new_frac_d}[0] += 1;
					$frac_qFreq{$new_frac_q}[0] += 1;
					$frac_qFreq{$new_frac_q}[1] += 0;
				} else {
					print "No match\n\n";
					$frac_qFreq{$new_frac_q}[0] += 1;
					$frac_qFreq{$new_frac_q}[1] += 0;
					$frac_dFreq{$new_frac_d}[0] += 1;
					$frac_dFreq{$new_frac_d}[1] += 0;
				}
			}
			

		}
		
	}

}

foreach my $frac ( sort ( keys %frac_qFreq ) ) {
     print "These are the frequencies: $frac: @{ $frac_qFreq{$frac} }\n"
 }
=pod
#sort hash keys
$Data::Dumper::Sortkeys = sub {
    no warnings 'numeric';
    [ sort { $a <=> $b } keys %{$_[0]} ]
};
#print hashes
print Dumper \%frac_qFreq;
print Dumper \%frac_dFreq;

#print frac_q and frac_d limits
print "frac_qmin: $frac_qmin\nfrac_qMAX: $frac_qMAX\n";
print "frac_dmin: $frac_dmin\nfrac_dMAX: $frac_dMAX\n";

=cut
#Ranges
my $frac_qRange = $frac_qMAX - $frac_qmin;
#calculate range size
my $q_range_size = $frac_qRange / 10;
my %matchesXrange;
#foreach my $key (sort ( keys %frac_qFreq) ) {
 #       print "$key\t$frac_qFreq{$key}\n";
 #}

#Loop on each range
for my $i ( 0 .. 9 ) {
	#print "$frac_qmin\n" if $i == 0;
	my $howmany = 0;
	foreach my $key (sort ( keys %frac_qFreq ) ) {
        #print "$key\n";
        if ( $i == 9 && $key >= $frac_qmin ) {
        	$matchesXrange{$i}[1] += $frac_qFreq{$key}[1];
        	$matchesXrange{$i}[0] += $frac_qFreq{$key}[0];
        	$howmany += $frac_qFreq{$key};

        } elsif ( $key >= $frac_qmin && $key < $frac_qmin + $q_range_size ) {

        	#print "***$key\n";
        	#print "**$frac_qFreq{$key}**\n";
        	$matchesXrange{$i}[1] += $frac_qFreq{$key}[1];
        	$matchesXrange{$i}[0] += $frac_qFreq{$key}[0];
        	$howmany += $frac_qFreq{$key};
        }
        
	}
	print "$howmany\n";
	$frac_qmin += $q_range_size;
	print $frac_qmin ."\n";
}

#foreach my $key (sort ( keys %matchesXrange) ) {
 #       print "$key\t$matchesXrange{$key}\n";
#}


my $matchratio;
foreach my $range ( sort ( keys %matchesXrange ) ) {
	$matchratio = $matchesXrange{$range}[1]/$matchesXrange{$range}[0];
    print "$range: @{ $matchesXrange{$range} }\n";
    #print "***$matchesXrange{$range}[1]/$matchesXrange{$range}[0]***\n";
    print "$matchratio\n";
 }




#--------------------------
#frac_d
my $frac_dRange = $frac_dMAX - $frac_dmin;
#calculate range size
my $d_range_size = $frac_dRange / 10;
my %DmatchesXrange;
#foreach my $key (sort ( keys %frac_qFreq) ) {
 #       print "$key\t$frac_qFreq{$key}\n";
 #}

#Loop on each range
for my $i ( 0 .. 9 ) {
	#print "$frac_qmin\n" if $i == 0;
	#my $howmany = 0;
	foreach my $key (sort ( keys %frac_dFreq ) ) {
        #print "$key\n";
        if ( $i == 9 && $key >= $frac_dmin ) {
        	$DmatchesXrange{$i}[1] += $frac_dFreq{$key}[1];
        	$DmatchesXrange{$i}[0] += $frac_dFreq{$key}[0];
        	#$howmany += $frac_qFreq{$key};

        } elsif ( $key >= $frac_dmin && $key < $frac_dmin + $d_range_size ) {

        	#print "***$key\n";
        	#print "**$frac_qFreq{$key}**\n";
        	$DmatchesXrange{$i}[1] += $frac_dFreq{$key}[1];
        	$DmatchesXrange{$i}[0] += $frac_dFreq{$key}[0];
        	#$howmany += $frac_qFreq{$key};
        }
        
	}
	#print "$howmany\n";
	$frac_dmin += $d_range_size;
	print $frac_dmin ."\n";
}

#foreach my $key (sort ( keys %matchesXrange) ) {
 #       print "$key\t$matchesXrange{$key}\n";
#}


my $Dmatchratio;
foreach my $range ( sort ( keys %DmatchesXrange ) ) {
	$Dmatchratio = $DmatchesXrange{$range}[1]/$DmatchesXrange{$range}[0];
    print "***** frac_d $range: @{ $DmatchesXrange{$range} }\n";
    #print "***$matchesXrange{$range}[1]/$matchesXrange{$range}[0]***\n";
    print "***** frac_d $Dmatchratio\n";
 }
=pod
foreach my $range ( sort ( keys %matchratio ) ) {
	
    print "$range: ***@{ $matchratio{$range} }****\n";
 }



my $frac_dRange = $frac_dMAX - $frac_dmin;
#calculate range size
my $d_range_size = $frac_dRange / 10;
my %matchesXrangeD;
#foreach my $key (sort ( keys %frac_qFreq) ) {
 #       print "$key\t$frac_qFreq{$key}\n";
 #}

#Loop on each range
for my $i ( 0 .. 9 ) {
	#print "$frac_qmin\n" if $i == 0;
	my $howmany = 0;
	foreach my $key (sort ( keys %frac_dFreq ) ) {
        #print "$key\n";
        
        if ( $key >= $frac_dmin && $key < $frac_dmin + $d_range_size ) {

        	#print "***$key\n";
        	#print "**$frac_qFreq{$key}**\n";
        	$matchesXrangeD{$i} += $frac_dFreq{$key};
        	$howmany += $frac_dFreq{$key};
        }
        
	}
	print "$howmany\n";
	
	print $frac_dmin ."\n";
	$frac_dmin += $d_range_size;
}

foreach my $key (sort ( keys %matchesXrangeD) ) {
        print "$key\t$matchesXrangeD{$key}\n";
 }




print "frac_q range length $q\n";
my $frac_dRange = $frac_dMAX - $frac_dmin;
my $d = $frac_dRange / 10;
for my $i ( 0 .. 9 ) {
	$frac_dmin += $d;
	print $frac_dmin ."\n";
}

print "frac_d range length $d\n";

#################################### How many rigth predictions ordering by  frac_q ####################################


=cut



sub max {
	my ( @numbers ) = @_;
	my $max;
	if ( $numbers[0] > $numbers[1]) {
		$max = $numbers[0];

	} else {
		$max = $numbers[1];
	}
	return ( $max );
}

sub min {	#returns minimum of two numnber
	my ( @numbers ) = @_;
	my $min;
	if ( $numbers[0] < $numbers[1] ) {
		$min = $numbers[0];

	} else {
		$min = $numbers[1];
	}
	return ( $min );
}

__END__
sub makeintervals {
	my ( @ranges ) = @_;
	for my $i ( 0 .. 9 ) {
	$frac_qmin += $q;
	print $frac_qmin ."\n";
}

}