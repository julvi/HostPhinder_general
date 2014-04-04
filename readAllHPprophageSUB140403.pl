#!/usr/bin/perl

use warnings;
use strict;

use Data::Dumper;

my $fnas = "../PROPHAGES/HostPhinder/results/prophage_fnas";
my (%frac_qFreq, %frac_dFreq); #These hashes of array will count the frequency of right [1]and wrong [0]predictions per each value of frac_q and frac_d respectively
my ( $frac_qMAX, $frac_qmin, $frac_dMAX, $frac_dmin ) = ( 0 ) x 4;

################################################################################ READ tax_info ################################################################################

open ( IN, '<', "../PROPHAGES/tax_info" ) or die "Can't open the file: $!";
#Save the file into an array
my @taxonomies;
while ( <IN> ) {
	push @taxonomies, [ split ];
}
close IN;
############################################################# Open each profage for each bacterium ###################################################################################################

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
		
		opendir ( NC, "$fnas/$bact/$NCid" );
		
		#read each prophage
		while ( my $prophage = readdir ( NC ) ) {
			next if ( $prophage =~ m/^\./ );
		
			
			my $pfilename = "$fnas/$bact/$NCid/$prophage";
			#save the name of the folders (bacterium and NC)
			my $sp_NC_names = $1 if "$bact/$NCid" =~ m/(.*?)_1$/;
			
#----------------------------------------------------------------------------------------------------------------------------------
#SORT HostPhinder PREDICTIONS
#----------------------------------------------------------------------------------------------------------------------------------
			
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

			my ( $first_frac_q, $first_frac_d ) = "";

			my ( $new_frac_q, $new_frac_d ) = ( 0 ) x 2;
		
			#after the first while loop (read the first line), $i == 1 and here we have the results
			if ( $i == 1 ) {
				#----------------------------------------------------- Sort array of arrays according to frac_q ------------------------------------------------------------
				my @results_Q = sort_array_by_column ( 5, \@HPpredictions, $frac_qMAX, $frac_qmin );	#column number, reference to HPprediction, $frac_MAX, $frac_min
				# Return: prediction, frac, frac_MAX, $frac_min
				$first_frac_q = shift @results_Q;
				$new_frac_q = shift @results_Q;
				$frac_qMAX = shift @results_Q;
				$frac_qmin = shift @results_Q;
				#----------------------------------------------------- Sort array of arrays according to frac_d ------------------------------------------------------------
				my @results_D = sort_array_by_column ( 6, \@HPpredictions, $frac_dMAX, $frac_dmin );
				$first_frac_d = shift @results_D;
				$new_frac_d = shift @results_D;
				$frac_dMAX = shift @results_D;
				$frac_dmin = shift @results_D;

################################################################################################################################################################################
#READ tax_info
################################################################################################################################################################################
			
				my $right_species = "";
			
				for my $i ( 0 .. $#taxonomies ) {
					if ( $taxonomies[$i][0] =~ m/\/panfs1\/cge\/people\/henrike\/genomes\/tmp\/(.*?)\.gbk/ && $1 eq $sp_NC_names ) {
						$right_species = $taxonomies[$i][6];
					
					}
					
				}
############################################################## Check for identities ##################################################################################################################
			
				#the first element of the array of the hash [0] will contain the count of the predictions
				#the second element of the array of the hash [1] will contain the count of the matches
				if ( $right_species eq $first_frac_q && $right_species eq $first_frac_d ) {
					#print "Both the highest frac_q and highest frac_d give the right species: $right_species, $first_frac_q, $first_frac_d\n\n";
					$frac_qFreq{$new_frac_q}[1] += 1;
					$frac_qFreq{$new_frac_q}[0] += 1;
					$frac_dFreq{$new_frac_d}[1] += 1;
					$frac_dFreq{$new_frac_d}[0] += 1;
				} elsif ( $right_species eq $first_frac_q ) {
					#print "The highest frac_q gives the right species: $right_species, $first_frac_q\n\n";
					$frac_qFreq{$new_frac_q}[1] += 1;
					$frac_qFreq{$new_frac_q}[0] += 1;
					$frac_dFreq{$new_frac_d}[0] += 1;
					$frac_dFreq{$new_frac_d}[1] += 0;
				} elsif ( $right_species eq $first_frac_d ) {
					#print "The highest frac_d gives the right species: $right_species, $first_frac_d\n\n";
					$frac_dFreq{$new_frac_d}[1] += 1;
					$frac_dFreq{$new_frac_d}[0] += 1;
					$frac_qFreq{$new_frac_q}[0] += 1;
					$frac_qFreq{$new_frac_q}[1] += 0;
				} else {
					#print "No match\n\n";
					$frac_qFreq{$new_frac_q}[0] += 1;
					$frac_qFreq{$new_frac_q}[1] += 0;
					$frac_dFreq{$new_frac_d}[0] += 1;
					$frac_dFreq{$new_frac_d}[1] += 0;
				}
			}
			

		}
		
	}

}

#make 10 bins and calculate the matches/totPrediction ratio for each bin
my %q = makeintervals ( $frac_qmin, $frac_qMAX, \%frac_qFreq);

foreach my $key (sort ( keys %q ) ) {
	print "$key => $q{$key}\n";
}

my %d = makeintervals ( $frac_dmin, $frac_dMAX, \%frac_dFreq);

foreach my $key (sort ( keys %d ) ) {
	print "$key => $d{$key}\n";
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub max { #returns maximum of two numnber
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

sub sort_array_by_column {	#column number, reference to HPprediction, $frac_MAX, $frac_min
	my $column = shift;
	my $HPpredictions_ref = shift;
	my $frac_MAX = shift;
	my $frac_min = shift;

	my @sortedAoA = sort { $b -> [$column] <=> $a -> [$column] } @{ $HPpredictions_ref };

	my $first_frac = "";
	my $new_frac = 0;
	my @return;
	
	$first_frac = $1 if $sortedAoA[0][10] =~ m/"(.*?)"/;
	push ( @return, $first_frac );
	$new_frac = $sortedAoA[0][$column] + 0;
	push ( @return, $new_frac );		
	#save the max frac and the min frac met so far
	$frac_MAX = max($frac_MAX, $new_frac);
	push ( @return, $frac_MAX );
	if ( $frac_min == 0 ) {
		$frac_min = $new_frac;
	} else {
		$frac_min = min($frac_min, $new_frac);
	}
	push ( @return, $frac_min );			
	
# Return: top prediction, new frac, $frac_MAX, $frac_min
	return @return;
}

sub makeintervals { 
#arguments: $frac_min, $frac_max, \%frac_Freq

	my $min = shift;
	my $max = shift;
	my $frac_Freq_ref = shift;
	my $range = $max - $min;
	#divide the frac range into 10 bins
	my $range_size = $range / 10;
	my %matchesXrange;
	my %matchratio;
	#go through each bin
	for my $i ( 0 .. 9 ) {

		foreach my $key (sort ( keys %{$frac_Freq_ref} ) ) {
	        #count the number of matches and the number of total prediction
	        if ( $i == 9 && $key >= $min ) {
	        	$matchesXrange{$i}[1] += $$frac_Freq_ref{$key}[1];
	        	$matchesXrange{$i}[0] += $$frac_Freq_ref{$key}[0];	        	

	        } elsif ( $key >= $min && $key < $min + $range_size ) {

	        	$matchesXrange{$i}[1] += $$frac_Freq_ref{$key}[1];
	        	$matchesXrange{$i}[0] += $$frac_Freq_ref{$key}[0];	        	
	        }	        
		}		
		$min += $range_size;		
	}

	foreach my $key ( sort ( keys %matchesXrange ) ) {
	
	    $matchratio{$key} = $matchesXrange{$key}[1]/$matchesXrange{$key}[0];	    
	 }
	 return %matchratio;
}