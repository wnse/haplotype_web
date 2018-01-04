#!/usr/bin/perl -w
use strict;
use SVG;

die "usage :*.pl <hap.txt> \n" if @ARGV<1;

my $inupt = shift;
my $out   = shift;

my %color_chr;
$color_chr{'M0'} = 'red';
$color_chr{'M1'} = 'hotpink';
$color_chr{'F0'} = 'green';
$color_chr{'F1'} = 'springgreen';

my $width  = 1000;
my $height = 2000;

my $svg = SVG->new('width'=>500+$width,'height'=>200+$height,);
$svg->rect('x'=>0,'y'=>0,'width'=>200+$width,'height'=>200+$height,'fill'=>'white','stroke'=>'white','stroke-width'=>1);

my $line = 0;
my (@sm,@hap);
my (%tosvg,%mp,%title);
my %sm_rec_num;
open IN,"$inupt";
while(<IN>){
	chomp;
	$_ =~ s/\s+$//;
	$line ++;
	if ($line == 1){
		@sm = split /\t/,$_;
		next;
	}elsif($line == 3){
		@hap = split /\t/,$_;
		my $j = 0;
		for (my $i = 2;$i < @hap;$i ++){
			push @{ $title{$line} },$hap[$i];
		}
		next;
	}elsif($line == 2){
		my @rec = split /\t/,$_;
		for (my $i = 2;$i < @rec;$i ++){
			$rec[$i] =~ s/(\d)\|?(\d)/$1\|$2/;
			push @{ $title{$line} },$rec[$i];
		}
		next;
	}

	my @temp      = split /\t/,$_;
	$mp{$temp[0]} = $temp[1];
	my $j         = 0;
	for (my $i = 2;$i < @temp;$i ++){
		$hap[$i]  =~ /(\S+)\|(\S+)/;
		my $hap1  = $1;
		my $hap2  = $2;
		$j        ++;

		if ($temp[$i] =~ /\./){
			$temp[$i] = ".|.";
		}
		$temp[$i] =~ /(\S+)\|(\S+)/;
		my ($hap1_bp,$hap2_bp) = ($1,$2);
		my ($hap1_01,$hap1_02,$hap2_01,$hap2_02) = ($hap1,$hap1,$hap2,$hap2);
		if ($hap1 =~ /\D+\d\d/){
			my @hap_rec = &sm_recom($hap1);
			$hap1_01    = $hap_rec[0];
			$hap1_02    = $hap_rec[1];
			if ($hap1_bp =~ /\^/){
				$sm_rec_num{$sm[$i]}{$hap1} ++;
			}
			if ($sm_rec_num{$sm[$i]}{$hap1} && $sm_rec_num{$sm[$i]}{$hap1} >= 1){
				if ($sm_rec_num{$sm[$i]}{$hap1}%2 == 0){	###hap1_01
					push @{ $tosvg{$temp[0]}{$sm[$i]} },$hap1_01,$hap2_01,$hap1_bp,$hap2_bp;
				}else{						###hap1_02
					push @{ $tosvg{$temp[0]}{$sm[$i]} },$hap1_02,$hap2_01,$hap1_bp,$hap2_bp;
				}
			}else{
				push @{ $tosvg{$temp[0]}{$sm[$i]} },$hap1_01,$hap2_01,$hap1_bp,$hap2_bp;
			}
		}elsif($hap2 =~ /\D+\d\d/){
			my @hap_rec = &sm_recom($hap2);
			$hap2_01    = $hap_rec[0];
			$hap2_02    = $hap_rec[1];
			if ($hap2_bp =~ /\^/){
				$sm_rec_num{$sm[$i]}{$hap2} ++;
			}
			if ($sm_rec_num{$sm[$i]}{$hap2} && $sm_rec_num{$sm[$i]}{$hap2} >= 1){
				if ($sm_rec_num{$sm[$i]}{$hap2} %2 == 0){	###hap2_01
					push @{ $tosvg{$temp[0]}{$sm[$i]} },$hap1_01,$hap2_01,$hap1_bp,$hap2_bp;
				}else{						###$hap2_02
					push @{ $tosvg{$temp[0]}{$sm[$i]} },$hap1_01,$hap2_02,$hap1_bp,$hap2_bp;
				}
			}else{
				push @{ $tosvg{$temp[0]}{$sm[$i]} },$hap1_01,$hap2_01,$hap1_bp,$hap2_bp;
			}
		}else{
			push @{ $tosvg{$temp[0]}{$sm[$i]} },$hap1_01,$hap2_01,$hap1_bp,$hap2_bp;
		}
	}
}
close IN;


my $w_k = sprintf"%.0f",$width  / (@sm - 1);
my $h_k = sprintf"%.0f",$height / ($line + 5);
my $sm_num = 0;
foreach my $sm(@sm){
	$sm_num      ++;
	if ($sm_num  <= 2){next;}
	my $x_i1     = $sm_num * $w_k;
	my $x_i0     = ($sm_num - 3) * $w_k;

	if ($sm_num == 3){
		$svg->text('x'=>150,'y'=>100,'font-size'=>10,'font-family'=>'Verdana','fill'=>'black')->cdata('N');
	}
	$svg->text('x'=>200 + $x_i0 ,'y'=>100,'font-size'=>10,'font-family'=>'Verdana','fill'=>'black')->cdata($sm);
}

my $num = 0;
foreach my $id (sort {$a <=> $b} keys %title){
	my @title = @{ $title{$id} };
	$num ++;

	if ($num == 1){
		$svg->text('x'=>150,'y'=>150,'font-size'=>10,'font-family'=>'Verdana','fill'=>'black')->cdata('C');
	}else{
		$svg->text('x'=>150,'y'=>200,'font-size'=>10,'font-family'=>'Verdana','fill'=>'black')->cdata('G');
	}
	$sm_num = 0;
	for(my $i = 0;$i < @title;$i++){
		$sm_num ++;
		$title[$i]   =~ /(\S+)\|(\S+)/;
		my $x0        = ($sm_num - 1 ) * $w_k;

		$svg->text('x'=>200 + $x0,'y'=>150 + ($num - 1) * 50,'font-size'=>10,'font-family'=>'Verdana','fill'=>'black')->cdata($1);
		$svg->text('x'=>200 + $x0 + 20,'y'=>150 + ($num - 1) * 50,'font-size'=>10,'font-family'=>'Verdana','fill'=>'black')->cdata($2);
	}
}

foreach my $id(sort {$a <=> $b} keys %tosvg){
	$svg->text('x'=>100,'y'=>250 + $h_k * $id,'font-size'=>10,'font-family'=>'Verdana','fill'=>'black')->cdata($id);
	$svg->text('x'=>150,'y'=>250 + $h_k * $id,'font-size'=>10,'font-family'=>'Verdana','fill'=>'black')->cdata($mp{$id});

	$sm_num  = 0;
	foreach my $sm(@sm){
		$sm_num ++;
		if ($sm_num <= 2){next;}

		my @sm_info = @{ $tosvg{$id}{$sm} };	###hap1,hap2,hap1_bp,hap2_bp
		
		my $x0   = ($sm_num - 3) * $w_k;

		$svg->rect('x'=>200 + $x0 - 5,'y'=> 250 + $h_k * $id-10,
				'width'=>15,'height'=>$h_k-1,'fill'=>$color_chr{$sm_info[0]});
		$svg->rect('x'=>200 + $x0  + 20 - 5,'y'=>250 + $h_k * $id-10,
				'width'=>15,'height'=>$h_k-1,'fill'=>$color_chr{$sm_info[1]});

		$svg->text('x'=>200 + $x0,'y'=>250 + $h_k * $id,
				'font-size'=>10,'font-family'=>'Verdana','fill'=>'black',
			)->cdata($sm_info[2]);
		$svg->text('x'=>200 + $x0 + 20,'y'=>250 + $h_k * $id,
				'font-size'=>10,'font-family'=>'Verdana','fill'=>'black',
			)->cdata($sm_info[3]);

#		my $x = 300 + $x0 + 60;
#		print "$id\t$sm\t@sm_info\t##$x0##\t$x\n";
	}
}

#open OUT," > $out";
print $svg->xmlify();
#close OUT;

#`java -jar /datapool/user/zhangxj/work/PGS/PGS-CNV-DIFF-PIPLINE/03-CNV-pipline/public-file/common-file/batik-1.6/batik-rasterizer.jar $out`;


sub sm_recom (){
	my $hap   = shift;
	$hap      =~ /(\D)(\d)(\d)/;
	my $hap01 = "$1$2";
	my $hap02 = "$1$3";
	return $hap01,$hap02;
}
