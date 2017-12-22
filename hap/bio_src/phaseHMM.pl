#!/usr/bin/perl
use strict;
use warnings;


my ($sam_id,$snp_id,$p,$m,$pro,$embryo)=read_input($ARGV[0]);

my ($p0,$p1,$m0,$m1)=phase_pro(\@{$p},\@{$m},\@{$pro});
=pod
print "@{$sam_id}\n@{$snp_id}\n@{$p}\n@{$m}\n@{$pro}\n";
print "ID\t"."@{$snp_id}\n";
print "P0\t"."@{$p0}\n";
print "P1\t"."@{$p1}\n\n";
print "M0\t"."@{$m0}\n";
print "M1\t"."@{$m1}\n\n";
=cut

my @obs_p;
my @obs_m;
my @eff_id_p;
my %eff_cov_p;
my %eff_cov_m;
my @eff_id_m;
my @hmm_p;
my @hmm_m;
printf "\t%8s\t","M0M1P0P1";
for (my $i=0;$i<scalar(@{$embryo}) ;$i++) {
	print "$$sam_id[$i+3]\t";
#	print "@{$$embryo[$i]}\n";
	($obs_p[$i],$eff_id_p[$i])=get_obs_array(\@{$p0},\@{$p1},\@{$$embryo[$i]},\@{$snp_id},\@{$pro});
	($obs_m[$i],$eff_id_m[$i])=get_obs_array(\@{$m0},\@{$m1},\@{$$embryo[$i]},\@{$snp_id},\@{$pro});
	($hmm_p[$i])=HMM(@{$obs_p[$i]});
	($hmm_m[$i])=HMM(@{$obs_m[$i]});
	for (my $j=0;$j<scalar(@{$eff_id_p[$i]}) ;$j++) {
		$eff_cov_p{$i}{${$eff_id_p[$i]}[$j]}=$j;
	}
	for (my $j=0;$j<scalar(@{$eff_id_m[$i]}) ;$j++) {
		$eff_cov_m{$i}{${$eff_id_m[$i]}[$j]}=$j;
	}	

#	print "\n";
=pod
	for (my $j=0;$j<scalar(@{$eff_id}) ;$j++) {
		printf "%3s","${$$embryo[$i]}[$$eff_id[$j]]";
	}
	print "\n";
	for (my $j=0;$j<scalar(@{$obs}) ;$j++) {
		printf "%3s","$$obs[$j]";
	}
	print "\n";
	my $final_hid=HMM(@{$obs});
	for (my $j=0;$j<scalar(@{$final_hid}) ;$j++) {
		printf "%3s","$$final_hid[$j]";
	}
	print "\n";
=cut
}
print "\n";
for (my $id=0;$id<scalar(@{$snp_id}) ;$id++) {
	printf "%2s\t", "$id";
	printf "%8s\t","$$p0[$id] $$p1[$id] $$m0[$id] $$m1[$id]";
	for (my $i=0;$i<scalar(@{$embryo}) ;$i++) {
#		print "${$$embryo[$i]}[$id] ";
		if (exists $eff_cov_p{$i}{$id}) {
			my $j=$eff_cov_p{$i}{$id};
		#	print "${$obs_p[$i]}[$j]${$hmm_p[$i]}[$j]\t";
			print "M"."${$hmm_p[$i]}[$j]"
		}else{
			print "  ";
		}
		if (exists $eff_cov_m{$i}{$id}) {
			my $j=$eff_cov_m{$i}{$id};
		#	print "${$obs_m[$i]}[$j]${$hmm_m[$i]}[$j]\t";
			print "P"."${$hmm_m[$i]}[$j]"
		}else{
			print "  ";
		}
		print "\t";
	}
	print "\n";
}




sub read_input{
	my $file=$_[0];
	my (@sam_id,@snp_id);
	my (@p,@m,@pro,@embryo);
	open IN,$file or die "Can't open $file\n";
	while (<IN>) {
		chomp;
		$_=~s/^\s+//;
		if (!exists $sam_id[0]) {
			@sam_id=split/\s+/,$_;
			next;
		}
		my @temp=split/\s+/;
		push @snp_id,$temp[0];
		push @p,$temp[1];
		push @m,$temp[2];
		push @pro,$temp[3];
		for (my $i=4;$i<scalar(@temp);$i++) {
			push @{$embryo[$i-4]},$temp[$i];
		}
	}
	close IN;
	return (\@sam_id,\@snp_id,\@p,\@m,\@pro,\@embryo);
}

sub phase_pro{
	my ($p,$m,$pro)=($_[0],$_[1],$_[2]);
	my (@p0,@p1,@m0,@m1);
	for (my $i=0;$i<scalar(@$p);$i++) {
		my $check_geno=check_geno($$p[$i],$$m[$i],$$pro[$i]);
		if ($check_geno==1) {
			my ($num,$base_het,$base_hom)=find_het($$p[$i],$$m[$i]);
			if ($base_het eq "hom" and $base_hom eq "hom") {
				push @p0,substr($$p[$i],0,1);
				push @p1,substr($$p[$i],0,1);
				push @m0,substr($$m[$i],0,1);
				push @m1,substr($$m[$i],0,1);
				next;
			}
			if (check_het_hom($$pro[$i])==1) {
				if ($num==0) {
					push @p0,$base_het;
					push @m0,$base_hom;
				}else{
					push @p0,$base_hom;
					push @m0,$base_het;
				}
				push @p1,$base_hom;
				push @m1,$base_hom;
			}elsif (check_het_hom($$pro[$i])==0) {
				if ($num==0) {
					push @p1,$base_het;
					push @m1,$base_hom;
				}else{
					push @p1,$base_hom;
					push @m1,$base_het;
				}
				push @p0,$base_hom;
				push @m0,$base_hom;	
			}else{
				$p0[$i]=$p1[$i]=$m0[$i]=$m1[$i]=".";
			}
		}else{
			$p0[$i]=$p1[$i]=$m0[$i]=$m1[$i]=".";
		}
	}
	return (\@p0,\@p1,\@m0,\@m1);
}

sub find_het{
	my ($p,$m)=($_[0],$_[1]);
	my @p=split//,$p;
	my @m=split//,$m;
	if (check_het_hom($p)==1) {
		if ($p[0] eq $m[0]) {
			return (0,$p[1],$p[0]);
		}else{
			return (0,$p[0],$p[1]);
		}
	}elsif (check_het_hom($m)==1) {
		if ($p[0] eq $m[0]) {
			return (1,$m[1],$m[0]);
		}else{
			return (1,$m[0],$m[1]);
		}
	}elsif (check_het_hom($p)==0 and check_het_hom($m)==0) {
		return (0,"hom","hom")
	}
}


sub check_geno{
	my ($g1,$g2,$g3)=($_[0],$_[1],$_[2]);

	#any of three genotype is null
	if ($g1 eq "." or $g2 eq "." or $g3 eq ".") {
		return 0;
	}
	
	#three or more allels
	my @temp=split//,$g1.$g2.$g3;
	my %count;
	my @uniq_temp = grep { ++$count{ $_ } < 2; } @temp;
	if (scalar(@uniq_temp)>2) {
		return 0;
	}

	#parent genotype is AB/AB
	my $p_check=check_het_hom($g1);
	my $m_check=check_het_hom($g2);
	if ($p_check==2 or $m_check==2) {
		return 0;
	}elsif ($p_check==1 and $m_check==1) {
		return 0;
	}
	return 1;
}

sub check_het_hom{
	my $g=$_[0];
	my $len=length $g;
	if ($len != 2) {
		return 2;
	}
	my @temp=split//,$g;
	if ($temp[0] eq $temp[1]) {
		return 0;
	}else{
		return 1;
	}
}


sub get_obs_array{
	my ($p0,$p1,$e,$id,$pro)=($_[0],$_[1],$_[2],$_[3],$_[4]);
	my @obs;my @eff_id;
	for (my $i=0;$i<scalar(@$e) ;$i++) {
		if ($$p0[$i] eq $$p1[$i]) {
		#	push @obs,".";
			next;
		}
		if ($$p0[$i] eq "." or $$e[$i] eq ".") {
		#	push @obs,".";
			next;
		}
		my $tmp_pro=join ("",sort(split//,$$pro[$i]));
		my $tmp_e=join ("",sort(split//,$$e[$i]));
		if ($tmp_pro eq $tmp_e) {
			push @obs,0;
			push @eff_id,$$id[$i];
		}else{
			push @obs,1;
			push @eff_id,$$id[$i];
		}

#		if ($$e[$i]=~/$$p0[$i]/) {
#			push @obs,0;
#			push @eff_id,$$id[$i];
#		}elsif ($$e[$i]=~/$$p1[$i]/) {
#			push @obs,1;
#			push @eff_id,$$id[$i];
#		}
#		else{
#			push @obs,".";
#		}

	}
	return \@obs,\@eff_id;
}




sub HMM{
	
	my @obs=@_;
	
	my @init=(0.5,0.5);
	
	my @trans=(
[0.9999,0.0001],
[0.0001,0.9999],
);
	
	my @emit=(
[0.8,0.2],
[0.4,0.6],
);
	
	my @tmp_path;
	my @tmp_value;
	
	my @final_hid;
	
	for (my $i=0;$i<scalar(@obs) ;$i++) {

		if($obs[$i] eq "."){next;}
		my @p_value;

		if($i==0){
			for(my $j=0;$j<scalar(@init);$j++){

				$tmp_value[$i][$j]=log($init[$j]*$emit[$j][$obs[$i]]);
			}
			next;

		}

		for	(my $j=0;$j<scalar(@init) ;$j++) {
			
for (my $z=0;$z<scalar(@init) ;$z++) {
				$p_value[$z]=$tmp_value[$i-1][$z]+log($trans[$z][$j]);
			}


			($tmp_path[$i][$j],$tmp_value[$i][$j])=max(@p_value);
			$tmp_value[$i][$j]+=log($emit[$j][$obs[$i]]);
		}
	}
	my ($id,$value);
	for (my $j=0;$j<scalar(@init) ;$j++) {
		($id,$value)=max(@{$tmp_value[$#obs]});
	}
	@final_hid=(@final_hid,$id);
	for (my $j=$#obs;$j>0 ;$j--) {
		@final_hid=(@final_hid,$tmp_path[$j][$id]);
		$id=$tmp_path[$j-1][$id];
	}
	return \@final_hid;
}

sub max{
	my @test=@_;

	my ($id,$max);

	for (my $i=0;$i<scalar(@test) ;$i++) {

		if ($i==0) {

			$id=0;$max=$test[$i];
	
		next;

		}
	
	if ($max<$test[$i]) {
			$id=$i;

			$max=$test[$i];

		}

	}

	return $id,$max;

}

