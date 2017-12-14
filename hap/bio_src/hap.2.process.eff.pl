use warnings;

$ARGV[0]=~/(\S+).(\S+effective)$/;
my $outdir=$1;
my $tag=$2;

main(@ARGV);
sub main{
	open (FH1, $ARGV[0]);
	my @effective_index;
	my @effective;
	my @effective_atcg;
	my $genotype_cell_num;
	my $parenta_homo;
	my $parenta_heter;
	my @need2discard;

	my $mater_pater;

	while(<FH1>){
		next if $_ =~ /^\s*$/;
		my @temp = split("\t",$_);

		if(homo_heter($temp[1]) eq "homo"){
			$parenta_homo = $temp[1];
			$parenta_heter = $temp[2];
			$mater_pater = "p";
		}
		else{
			$parenta_homo = $temp[2];
			$parenta_heter = $temp[1];
			$mater_pater = "m";
		}

		my @local;
		my @local_atcg;
		@local_atcg = (@local_atcg, $parenta_homo, $parenta_heter);
		$genotype_cell_num = scalar(@temp)-1;
		for my $i (3..$genotype_cell_num){
			chomp($temp[$i]) if $i == $genotype_cell_num;
			@local = (@local,measure_genotype($parenta_homo,$parenta_heter,$temp[$i]));
			@local_atcg = ( @local_atcg, $temp[$i]);
		}
		my $too_many_null = 0;
		my $count_null_line=0;
		for my $test_null (@local){
			if ($test_null == 4){
				$count_null_line = $count_null_line+1;
				if ($count_null_line/scalar(@local) == 1 ){
					$too_many_null = 1;
					last;
				}
			}
		}
		print STDERR "discard_line: too_many_null ".$temp[0]."\n" if $too_many_null;
		print STDERR "discard_line: three_allele  ".$temp[0]." $parenta_homo, $parenta_heter\n" if three_allele($parenta_homo, $parenta_heter); 
		@need2discard = (@need2discard, $temp[0]);
		next if $too_many_null;
		next if three_allele($parenta_homo, $parenta_heter);

		@effective_index = (@effective_index, $temp[0]);
		push @effective, [ @local ];
		push @effective_atcg, [ @local_atcg ];
	}
	close(FH1);

	if (scalar @effective ==0 ) {
		print STDERR "no effective site exists in $tag\n";
		print STDERR "deletion may occur in $tag\n";
		`touch $outdir/12_04geno_$tag $outdir/12_04haplo_$tag $outdir/12_04parental_$tag $outdir/12_04_$tag`;
		exit;
	}

	my @complement;
	for my $i (0..($genotype_cell_num-3)){
		@complement = (@complement,'');
		for my $j (0..$genotype_cell_num-3){
			next if $i==$j;
			my $ifcomplement = 1;
			for my $k (0..scalar(@effective_index)-1){
				next if $effective[$k][$i]!=1 || $effective[$k][$j]>1; #0,1 are normal
				if ($effective[$k][$i] == $effective[$k][$j]){
					$ifcomplement = 0;
					last;
				}
			}
			$complement[$i] = $complement[$i].$j.'-' if $ifcomplement == 1;
		}
	}

	my %already_tested;
	for my $i (0..($genotype_cell_num-3)){
		next if not $complement[$i];
#		if (not %already_tested){
#			$already_tested{$local_largest} = 1;
#		}
#		else{
#			next if exists $already_tested{$local_largest};
#			$already_tested{$local_largest} = 1;
#		}
		my @need_test = split("-", $complement[$i]);
		if (scalar(@need_test)==1) {
			if (not $complement[$need_test[0]]) {
				$complement[$i] = "";
			}
			next;
		}
#		next if scalar(@need_test) == 1;
		
		my @similar;
		my $local_largest = "";
		for my $j (0..scalar(@need_test)-1){
			@similar = (@similar,"");
			for my $k (0..scalar(@need_test)-1){
				if ($k==$j){
					$similar[$j] = $similar[$j].$need_test[$j].'-';
					next;
				}
				my $ifsimilar = 1;
				for my $g (0..scalar(@effective_index)-1){
					next if $effective[$g][$need_test[$j]]>1 || $effective[$g][$need_test[$k]]>1; #0,1 are normal
					if ($effective[$g][$need_test[$j]] != $effective[$g][$need_test[$k]]){
						$ifsimilar = 0;
						last;
					}
				}
				$similar[$j] = $similar[$j].$need_test[$k].'-' if $ifsimilar == 1;
			}
			if (length($similar[$j]) > length($local_largest)){
				$local_largest = $similar[$j];
			}
		}
		$complement[$i] = $local_largest;
		#for my $j (0..scalar(@need_test)-1){
		#	next if $similar[$j] eq $local_largest;
		#   $complement[$need_test[$j]] = "";
		#}
	}

	my $local_complement_merge = recombinant_merge_recombinant(@complement);
	my @complement_merge = @$local_complement_merge;
	my $complement_type = statistic(@complement_merge);
	my %complement_type = %$complement_type;

	my $largest_complement_type = 0;
	my $largest_complement_type_key = '';
	foreach my $key (keys %complement_type){
#		print "$key\t$complement_type{$key}\n";
		if ($largest_complement_type<$complement_type{$key}){
			$largest_complement_type = $complement_type{$key};
			$largest_complement_type_key =$key;
		}
	}

	my $local_recombinant = find_normal($largest_complement_type_key,@complement_merge);
	my @recombinant = @$local_recombinant;
	my $filename = "$outdir.$tag";
	my @check_1_hap = sort {$a<=>$b} @recombinant;

	system("touch $filename");
	open (FILE1, ">$filename");

	my @haplotype;
	if ($check_1_hap[0] == $check_1_hap[-1] and $check_1_hap[0] ==1) {
		for my $i (0..($genotype_cell_num-3)){
			@haplotype = (@haplotype, 0);
			print FILE1 "0\t";
		}
	}
	else{
		for my $i (0..($genotype_cell_num-3)){
			if ($recombinant[$i]){
				@haplotype = (@haplotype, 2);
				print FILE1 "2\t";
				next;
			}
			if (substr($largest_complement_type_key,0,1) eq substr($complement[$i],0,1)){
				@haplotype = (@haplotype, 0);
				print FILE1 "0\t";
			}
			else{
				@haplotype = (@haplotype, 1);
				print FILE1 "1\t";
			}
		}
	}

	close (FILE1);

	my $geno_heter_heter;  
	my $geno_heter_homo;

	my @total_geno;   
	my @total_heter_homo; 

	my $filename1 = "$outdir.$tag.parental";
	system("touch $filename1");
	open (FILE3, ">$filename1");

	my @new_effective_index;

	for my $i (0..scalar(@effective_index)-1){
		my @local_geno;
		my @local_heter_homo;

		($parenta_homo, $parenta_heter) = ($effective_atcg[$i][0],$effective_atcg[$i][1]);
		my $result = find_heter_homo($parenta_homo, $parenta_heter);
		($geno_heter_homo,$geno_heter_heter) = @$result;

		my %hash_genotype;
		my %hash_heter_homo;
		my $check_1=0;
		my $check_0=0;
		my @check_hap;
		for my $j (2..$genotype_cell_num-1){
			next if $haplotype[$j-2] == 2;
			next if $effective[$i][$j-2]>1;
			push @check_hap,$haplotype[$j-2];
			if ($effective[$i][$j-2]==1) {
				$check_1+=1;
				$hash_genotype{$haplotype[$j-2]} = $geno_heter_heter;
				$hash_heter_homo{$haplotype[$j-2]} = $effective[$i][$j-2];
			}
			else{
				$check_0+=1;
				#$hash_genotype{$haplotype[$j-2]} = $geno_heter_homo;
				#$hash_heter_homo{$haplotype[$j-2]} = $effective[$i][$j-2];
			}
		}

		if (not %hash_genotype){
			if ($check_1==0 and $check_0 > 0) {
				my ($hap_0,$hap_1)=(0,0);
				foreach my $tmp (@check_hap) {
					$hap_0+=1 if ($tmp==0);
					$hap_1+=1 if ($tmp==1);
				}
				if ($hap_0>=$hap_1) {
					$hash_genotype{'0'} = $geno_heter_homo;
					$hash_heter_homo{'0'} = 0;
				}else{
					$hash_genotype{'1'} = $geno_heter_homo;
					$hash_heter_homo{'1'} = 0;
				}
			}else{
				print STDERR "can't decide $effective_index[$i]\n" ;
				next;
			}
		}
		if (scalar(keys%hash_genotype) < 2){
			my @all_keys = keys%hash_genotype;
			if ($hash_genotype{$all_keys[0]} eq $geno_heter_homo){
				$hash_genotype{1-$all_keys[0]} = $geno_heter_heter;
			}
			else{
				$hash_genotype{1-$all_keys[0]} = $geno_heter_homo;
			}
			
			my @all_keys2 = keys%hash_heter_homo; 
			$hash_heter_homo{1-$all_keys[0]} = 1 - $hash_heter_homo{$all_keys[0]};
		}
		elsif ($hash_genotype{'0'} eq $hash_genotype {'1'}) {
			print STDERR "can't decide $effective_index[$i]\n" ;			####add a array record these site and phase them after.
			next;
		}
		
		foreach $key (sort keys %hash_genotype)  {  
			@local_geno = (@local_geno, $hash_genotype{$key});
		}

		print  FILE3 $effective_index[$i]."\t";
		foreach $key (sort keys %hash_heter_homo)  
		{  
		print FILE3 $hash_heter_homo{$key}."\t"; 
		@local_heter_homo = (@local_heter_homo, $hash_heter_homo{$key});
		}
		print FILE3 "\n";
		@new_effective_index = (@new_effective_index, $effective_index[$i]);
		push @total_geno, [ @local_geno ];
		push @total_heter_homo, [ @local_heter_homo ];
	}
	close(FILE3);

	my $filename2 = "$outdir.$tag.haplo";
	system("touch $filename2");
	open (FILE2, ">$filename2");

	my $filename3 = "$outdir.$tag.geno";
	system("touch $filename3");
	open (FILE4, ">$filename3");

	my @whole_haplotype_partial;
	my @whole_haplotype;

	my $update_count=0;
	for my $i (0..scalar(@effective_index)-1){
		next if $effective_index[$i] ne $new_effective_index[$update_count];
		my @local_whole_haplotype_partial;
		print FILE2 $new_effective_index[$update_count]."\t";
		print FILE2 $total_heter_homo[$update_count][0]."\t".$total_heter_homo[$update_count][1]."\t";
		
		print FILE4 $new_effective_index[$update_count]."\t";
		if ($mater_pater eq "m") {
			print FILE4 $total_geno[$update_count][0].$total_geno[$update_count][1]."\t".$effective_atcg[$i][0]."\t";
		}
		else{
			print FILE4 $effective_atcg[$i][0]."\t".$total_geno[$update_count][0].$total_geno[$update_count][1]."\t";
		}
		
		for my $j (0..$genotype_cell_num-3){
			if ($effective[$i][$j]>1){
				print FILE2 $effective[$i][$j]."\t";
				print FILE4 $effective_atcg[$i][$j+2]."\t";
				@local_whole_haplotype_partial = (@local_whole_haplotype_partial, $effective[$i][$j]);
				next;
			}
			
			if ($haplotype[$j] < 2){
				print FILE2 $haplotype[$j]."\t";
				if ($mater_pater eq "m") {
					#print FILE4 $total_geno[$update_count][$haplotype[$j]].substr($effective_atcg[$i][0],0,1)."\t";
					if (substr($effective_atcg[$i][$j+2],0,1) eq $total_geno[$update_count][$haplotype[$j]]) {
						
						print FILE4 substr($effective_atcg[$i][$j+2],0,1).substr($effective_atcg[$i][$j+2],1,1)."\t";
					}
					else{
						
						print FILE4 substr($effective_atcg[$i][$j+2],1,1).substr($effective_atcg[$i][$j+2],0,1)."\t";
					}
				}
				else{
					#print FILE4 substr($effective_atcg[$i][0],0,1).$total_geno[$update_count][$haplotype[$j]]."\t";
					
					if (substr($effective_atcg[$i][$j+2],0,1) eq $total_geno[$update_count][$haplotype[$j]]) {
						print FILE4 substr($effective_atcg[$i][$j+2],1,1).substr($effective_atcg[$i][$j+2],0,1)."\t";
					}
					else{
						print FILE4 substr($effective_atcg[$i][$j+2],0,1).substr($effective_atcg[$i][$j+2],1,1)."\t";
					}
				}				
				@local_whole_haplotype_partial = (@local_whole_haplotype_partial, $haplotype[$j]);
				next;
			}
			
			if ($effective[$i][$j] == $total_heter_homo[$update_count][0]){
				print FILE2 "0\t";
				if ($effective[$i][$j] == 0){
					print FILE4 $effective_atcg[$i][$j+2]."\t";
				}
				else{
					if ($mater_pater eq "m") {
						if (substr($effective_atcg[$i][$j+2],0,1) eq $total_geno[$update_count][0]){
							
							print FILE4 substr($effective_atcg[$i][$j+2],0,1).substr($effective_atcg[$i][$j+2],1,1)."\t";
						}
						else{
							
							print FILE4 substr($effective_atcg[$i][$j+2],1,1).substr($effective_atcg[$i][$j+2],0,1)."\t";
						}
					}
					else{
						if (substr($effective_atcg[$i][$j+2],0,1) eq $total_geno[$update_count][0]){
							print FILE4 substr($effective_atcg[$i][$j+2],1,1).substr($effective_atcg[$i][$j+2],0,1)."\t";
						}
						else{
							print FILE4 substr($effective_atcg[$i][$j+2],0,1).substr($effective_atcg[$i][$j+2],1,1)."\t";
						}
					}
				}
				
				@local_whole_haplotype_partial = (@local_whole_haplotype_partial, 0);
				next;
			}

			@local_whole_haplotype_partial = (@local_whole_haplotype_partial, 1);
			print FILE2 "1\t";
			if ($effective[$i][$j] == 0){
				print FILE4 $effective_atcg[$i][$j+2]."\t";
			}
			else{
				if ($mater_pater eq "m") {
					if (substr($effective_atcg[$i][$j+2],0,1) eq $total_geno[$update_count][0]){
						
						print FILE4 substr($effective_atcg[$i][$j+2],1,1).substr($effective_atcg[$i][$j+2],0,1)."\t";
					}
					else{
						
						print FILE4 substr($effective_atcg[$i][$j+2],0,1).substr($effective_atcg[$i][$j+2],1,1)."\t";
					}
				}
				else{
					if (substr($effective_atcg[$i][$j+2],0,1) eq $total_geno[$update_count][0]){
						print FILE4 substr($effective_atcg[$i][$j+2],0,1).substr($effective_atcg[$i][$j+2],1,1)."\t";
					}
					else{
						print FILE4 substr($effective_atcg[$i][$j+2],1,1).substr($effective_atcg[$i][$j+2],0,1)."\t";
					}
				}
			}
		}
		print FILE2 "\n";
		print FILE4 "\n";
		push @whole_haplotype_partial, [ @local_whole_haplotype_partial ];
		push @whole_haplotype, [ @local_whole_haplotype_partial ];
		$update_count = $update_count + 1;

	}

	close (FILE2);

	for my $j (0..($genotype_cell_num-3)){
		my $previous = -1; 
		for my $i (0..scalar(@total_geno)-1){
			if ($whole_haplotype_partial[$i][$j] > 1){
				if ($haplotype[$j] < 2){
					$whole_haplotype[$i][$j] = $haplotype[$j];
				}
				else{
					if ($previous > -1){
						$whole_haplotype[$i][$j] = $previous;
					}
				}
				
			}
			else{
				$previous = $whole_haplotype[$i][$j];
			}
		}
	}
}

sub measure_genotype{
	my ($parenta_homo,$parenta_heter,$offspring) = @_;
	return 4 if $offspring eq ".";

	if(homo_heter($offspring) eq "homo"){
		return 0 if $offspring eq $parenta_homo;
		if(substr($parenta_heter,0,1) eq substr($offspring,0,1)){
			return 1;
		}
		if(substr($parenta_heter,1,1) eq substr($offspring,0,1)){
			return 1;
		}
		return 3;
	}
	else{
		if(substr($parenta_heter,0,1) eq substr($offspring,0,1)){
			return 1 if substr($parenta_heter,1,1) eq substr($offspring,1,1);
			return 2;
		}
		if(substr($parenta_heter,0,1) eq substr($offspring,1,1)){
			return 1 if substr($parenta_heter,1,1) eq substr($offspring,0,1);
			return 2;
		}
		return 2;
	}
}

sub homo_heter{
	my ($geno) = @_;
	return "homo" if substr($geno,0,1) eq substr($geno,1,1);
	return "heter";
}

sub recombinant_merge_recombinant{
	my @complement = @_;
	my @complement_merge;
	for my $i (0..scalar(@complement)-1){
		@complement_merge = (@complement_merge,'');
		next if !$complement[$i];
		my $comp_index;
		my $comp_index_first;
		if (substr($complement[$i],1,1) eq "-"){
			$comp_index = substr($complement[$i],0,1);
		}
		else{
			$comp_index = substr($complement[$i],0,2);
		}
		if (substr($complement[$comp_index],1,1) eq "-"){   
			$comp_index_first = substr($complement[$comp_index],0,1);
		}
		else{
			$comp_index_first = substr($complement[$comp_index],0,2);
		}
		#$comp_index_first = substr($complement[$comp_index],0,1);
		$complement_merge[$i] = $complement[$i].$complement[$comp_index] if $comp_index < $comp_index_first;
		$complement_merge[$i] = $complement[$comp_index].$complement[$i] if $comp_index > $comp_index_first;
	}
	return \@complement_merge; 
}

#3
sub statistic{
	my @complement_merge = @_;
	my %complement_type;

	for my $i (0..scalar(@complement_merge)-1){
		next if !$complement_merge[$i];
		if (!%complement_type){
			$complement_type{$complement_merge[$i]} = 1;
			next;
		}
		my $in_keys=0;
		foreach my $key (keys %complement_type){
			if ($key eq  $complement_merge[$i]){
				$complement_type{$key} = $complement_type{$key}+1;
				$in_keys=1;
				last;
			}
		}
		$complement_type{$complement_merge[$i]} = 1 if $in_keys==0;
	}
	return \%complement_type;
}

sub find_normal{
	my ($largest_complement_type_key,@complement_merge)=@_ ;
	my @recombinant;
	for my $i (0..scalar(@complement_merge)-1){
		@recombinant = (@recombinant,'');
		if (!$complement_merge[$i]){
			$recombinant[$i] = 1;
			next;
		}
		if ($complement_merge[$i] ne $largest_complement_type_key){
			$recombinant[$i] = 1;
			next;
		}
		$recombinant[$i] = 0;
	}
	return \@recombinant;
}

#1108 07    AG AA ----  A G
sub find_heter_homo{
	my ($parenta_homo, $parenta_heter) = @_;
	my $heter_heter;
	my $heter_homo = substr($parenta_homo,0,1);
	if (substr($parenta_heter,0,1) eq $heter_homo){
		$heter_heter = substr($parenta_heter,1,1);
	}
	else{
		$heter_heter = substr($parenta_heter,0,1);
	}	
	my @output = ($heter_homo, $heter_heter);
	return \@output;
}

sub three_allele{
	my ($parenta_homo, $parenta_heter) = @_;
	my $heter_homo = substr($parenta_homo,0,1);
	if (substr($parenta_heter,0,1) ne $heter_homo && substr($parenta_heter,1,1) ne $heter_homo){
		return 1;
	}
	return 0;
}
