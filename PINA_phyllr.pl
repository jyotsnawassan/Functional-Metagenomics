#! /usr/bin/perl;

#use strict;

use Getopt::Long;
use Getopt::Std;
use Getopt::Std;
my $OTUS_relation;
my $Abundance_CSV;
my $OUT_CSV;
GetOptions (
"OTUS_csv=s" => \$OTUS_relation,
"ABUNDANCE_csv=s" => \$Abundance_CSV,
"phylogeny=s" => \$PHYL,
"filter=s" => \$FILT,
"OUT_W=s" => \$W_CSV,
"LOG=s" => \$W_log,
);
if ((! defined $OTUS_relation) || (! defined $PHYL) || (! defined $FILT) ||  (! defined $Abundance_CSV)  || (! defined $W_CSV) || (! defined $W_log)){
   die "          -------------------- USAGE---------------------
        perl <script name> -OTUS_csv <OTU relation csv file>  -ABUNDANCE_csv  <ABUNDANCE csv file> -phylogeny <phylogeny file> -filter < 0.0 - 1.0 >  -OUT_W <output weightedcsv file> -LOG <output log file>


"
}




open (INFILE1, "< $OTUS_relation");
open (INFILE2, "< $Abundance_CSV");
open (INFILE3, "< $PHYL");
open(OUTFILE1,">> $W_CSV");
open(OUTFILE2,">> $W_log");



@IN1 = <INFILE1>;
@IN2 = <INFILE2>;
@IN3 = <INFILE3>;
@mapper = "";
@DENOM  = "";
@TINA_W = "";
%class = "";
@class_a = "";

@otu_counts = split(/,/,$IN2[0]);
$otu_count = $#otu_counts - 1;
print "OTU count :  $otu_count\n";


######### mappin the tree

$node = 0;    ### to see if line is a begining of a node
$node_close = 0; ## to track closing brace
$node_depth = -1;
$node_column = -1 ;
%out_hash = "";
@node_otus = "";
$max_depth = 0;
$max_weight = 0;

for ($i=0;$i<=$#IN3;$i++) {
   $line = $IN3[$i];
   chomp($line);
   $node = 0;  ### initiate every line is not a node
   if ($line =~ /^\(/) {
      $edge_weight = 0; 
      $node_depth = $node_depth + 1;
      if ($node_depth > $max_depth) { $max_depth = $node_depth;}
      $node_column = $node_column + 1;
      @OTUs_list = "";
      @OTUs_wgt = "";
      @OTUs_CL = "";
      $node = 1; 
      $node_close = 0;     ###  to track at which level we are from node under consideration
      for ($j=$i+1;$j<=$#IN3;$j++) {
           $sub_line = $IN3[$j]; 
           chomp($sub_line);
           if ($sub_line =~ /^\(/) {
              $node_close = $node_close + 1;
              next;
           } 
           if ($sub_line =~ /^\)/) {
              $node_close = $node_close - 1;
              if ($node_close == -1) {last;}
              @a  = split(/,/,$sub_line);
              @weights = split(/:/,$a[0]);
              for ($m=0;$m<= $#OTUs_wgt; $m++) {
                 if ($OTUs_CL[$m] > $node_close ) {
                    $OTUs_wgt[$m]  = $OTUs_wgt[$m] +  $weights[1];
                    $OTUs_CL[$m] = $node_close;
                    if ($OTUs_wgt[$m] > $max_weight) {
                       $max_weight = $OTUs_wgt[$m] ;
                    }
                 }
              }       
           }
           if ($node_close == -1) {
               my @weights = split(/:/,$sub_line);
               $edge_weight = $weights[1];
               $edge_weight =~ s/,//g;
               last; 
           }
           if ($sub_line =~ /:/) {
              my @otus = split(/,/,$sub_line);      
              for ($m=0; $m<= $#otus; $m++) {
                  if ($otus[$m] =~ /\)/) {next;}
                  my @otu_name = split(/:/,$otus[$m]);
                  push (@OTUs_list, $otu_name[0]);
                  push (@OTUs_wgt, $otu_name[1]);
                  push (@OTUs_CL, $node_close);
              }
           }

       }      
     
       my $col = $node_column; 
       my $OTUs_j = join(",",@OTUs_list );
       my $OTUs_w = join(",",@OTUs_wgt );
       $OTUs_j =~ s/"//g;
       $OTUs_w =~ s/"//g;
       
       $node_otus[$col]  = join(",--",$OTUs_j,$OTUs_w) ; 
      print " $node_column  :: $node_otus[$col]    \n";  
       #####  Print to array output      

   }
   if ($line =~ /^\)/) {
        $node_depth = $node_depth - 1;
   }
   if ($line =~ /:/) {
      $otu_depth = 0;
      my @otus = split(/,/,$line);
      for ($m=0; $m<= $#otus; $m++) { 
         if ($m == 0) { $otu_depth = $node_depth + 1;}
         if ($otus[$m] =~ /\)/) {next;}   
	 #  $node_column = $node_column + 1;
         my @otu_name = split(/:/,$otus[$m]);  
	 #  my $col = $node_column;
         #  $node_otus[$col]  = join(",--",$otu_name[0], 1)   ;
          $otu_name[0] =~ s/"//g;
	  #print " $node_column    :: $otu_name[0]    \n";
         if ($otu_depth > $max_depth) { $max_depth = $otu_depth;}
      }
   }

}

@node_otus_org = @node_otus;
################################


### mapping the OTUS between two files to save time
@abun_2 = split(/,/, $IN2[0]);
@abun_1 = split(/,/ ,$IN1[0]);
print " check ::  @abun_2 \n";
for ($n=1;$n<=$#abun_1;$n++) {
   $abun_1[$n]  =~ s/\s+//g;
   $abun_1[$n]  =~ s/"//g;
} 
for ($m=1;$m<$#abun_2;$m++) {
  $abun_2[$m]  =~ s/\s+//g;
  $abun_2[$m]  =~ s/"//g;
  for ($n=1;$n<=$#abun_1;$n++) {
     $abun_1[$n]  =~ s/\s+//g;
     $abun_1[$n]  =~ s/"//g;
     if ($abun_2[$m] eq $abun_1[$n]) {
       $mapper[$m] = $n;
       #print "$mapper[$m]\n";
     }
  }
  for ($n=0;$n<= $#node_otus;$n++) {
      $node_otus[$n] =~ s/$abun_2[$m],/$m,/g;
   }	  
}


for ($n=0;$n<= $#node_otus;$n++) {
   print " $node_otus[$n] \n";
}

#### calculating big denominator term for each sample
@sum_k = "" ;
for ($y=0;$y <= $#node_otus  ; $y++) {
   @OTUS_i = split(/--/,$node_otus[$y]);
   @OTUS_ind = split(/,/,$OTUS_i[0]);
 for ($k=1;$k<=$#IN2;$k++) {
   print "FInding Denom term for node ::$y  and sample ::$k\n";
   @all_abun_k = split(/,/, $IN2[$k]);
   $sum_k[$k][$y] = 0;
   # for ($m=1;$m<$#all_abun_k;$m++) {
   for ($m=1;$m<=$#OTUS_ind;$m++) {
    $m_n = $OTUS_ind[$m];
    $sum_k[$k][$y]  = $sum_k[$k][$y] + $all_abun_k[$m_n];
   }
   #  print "Sample $k , Node $y  ::  $sum_k[$k][$y]\n";
   $DENOM[$k][$y] = 0.000001; 
   #$DENOM[$k][$y] = 0; 
   #for ($i=1;$i<$#all_abun_k;$i++) {
   for ($i=1;$i<=$#OTUS_ind;$i++) {
      $i_n = $OTUS_ind[$i];	   
      if ($all_abun_k[$i_n] == 0) {next;}
      #for ($j=1;$j<$#all_abun_k;$j++) {
      for ($j=1;$j<=$#OTUS_ind;$j++) {
         $j_n = $OTUS_ind[$j];	   
         if ($all_abun_k[$j_n] == 0) {next;}
         $ind1 = $mapper[$i_n];           
         $ind2 = $mapper[$j_n];           
	 $IN1_Cij = $IN1[$ind1];
	 chomp($IN1_Cij);
         @all_otus =  split(/,/, $IN1_Cij);
         $Cij =  $all_otus[$ind2];
       #print "Cij :: $Cij :: $ind1 :: $ind2 :: abc :: $i_n : $j_n : $j\n";
	 # $Cij =  0.5 * ( 1 + $Cij);    #### delete it for PINA
         $DENOM[$k][$y]  =   $DENOM[$k][$y] + (( $all_abun_k[$i_n] * $all_abun_k[$j_n] * $Cij )/( $sum_k[$k][$y] * $sum_k[$k][$y] ) );         
         if ($i == $j) {# print "$k :: $i :: $Cij\n";
	 }
      }
   }
	 print "denominator::  $DENOM[$k][$y] \n";
 }
}
 


#####  Finding TINA between all samples, at different node levels
#@NUMEN = "";
for ($y=0;$y <= $#node_otus  ; $y++) {
   @OTUS_i = split(/--/,$node_otus[$y]);
   @OTUS_ind = split(/,/,$OTUS_i[0]);
  for ($k=1;$k<=$#IN2;$k++) {
   @all_abun_k = split(/,/, $IN2[$k]);
   print OUTFILE2 "$all_abun_k[0]";
   for ($l=1;$l<=$#IN2;$l++) {
	   # print "PRocesing SAMPLE :: $k : $l\n";
     $NUMEN = 0; 
     @all_abun_l = split(/,/, $IN2[$l]);
     # for ($i=1;$i<$#all_abun_k;$i++) {
     for ($i=1;$i<=$#OTUS_ind;$i++) {
        $i_n = $OTUS_ind[$i];
       if ($all_abun_k[$i_n] == 0) {next;}
       #for ($j=1;$j<$#all_abun_l;$j++) {      
       for ($j=1;$j<=$#OTUS_ind;$j++) {      
	  $j_n = $OTUS_ind[$j];     
         if ($all_abun_l[$j_n] == 0) {next;}
         $ind1 = $mapper[$i_n];
         $ind2 = $mapper[$j_n];
	  $IN1_Cij = $IN1[$ind1];
	 chomp($IN1_Cij);
         @all_otus =  split(/,/, $IN1_Cij);
         $Cij =  $all_otus[$ind2];
	 # $Cij =  0.5 * ( 1 + $Cij);   ### delete it for PINA
         $NUMEN = $NUMEN +  (($all_abun_k[$i_n] * $all_abun_l[$j_n] * $Cij)/( $sum_k[$k][$y] * $sum_k[$l][$y] ) );
       }
     }
     print "TINA  between sample :: $k  & $l  ::  for node : $y\n"; 
     $TINA_W[$k][$l][$y] = $NUMEN/(sqrt($DENOM[$k][$y] * $DENOM[$l][$y]));  
     print "$TINA_W[$k][$l][$y] ::  $NUMEN\n";
     #$TINA_W[$k][$l][$y] = $NUMEN[$y]/(sqrt($DENOM[$k] * $DENOM[$l]));  
     #print "DENOM  :: $DENOM[$k][$y] :: $DENOM[$l][$y] :: $NUMEN[$y]\n";
     print OUTFILE2 ",$TINA_W[$k][$l][$y] ";
   }
   print  OUTFILE2 "\n";
 }
 print OUTFILE2 "\n\n\n";
}



##########################################
##########  Main script to find weights by Relief Measure

## map classes

for ($k=1;$k<=$#IN2;$k++) {
  @all_abun_k = split(/,/, $IN2[$k]);
  $class_a[$k] =  $all_abun_k[$#all_abun_k];
}

  ### update branch weights
 @weig = "";
 for ($y=1;$y <= $#node_otus  ; $y++) {
    $weig[$y] = 0;
 }
 for ($k=1;$k<=$#IN2;$k++) {
      print "Update weights for Sample $k\n";
      $near_hit = "";	   
      $near_miss = "";	   
      $min_hit = 0;
      $min_miss = 0;
      ### find nearest hit & miss
      for ($l=1;$l<=$#IN2;$l++) {
	if ($k == $l) {next;}      
        if ($class_a[$k] eq  $class_a[$l]) {
           if ($TINA_W[$k][$l][0] > $min_hit) { 
		$min_hit =  $TINA_W[$k][$l][0];
		$near_hit = $l;
	   }
	}	
        else {
           if ($TINA_W[$k][$l][0] > $min_miss) { 
		$min_miss =  $TINA_W[$k][$l][0];
		$near_miss = $l;
	   }
        }
      }
      print "hit miss :: $near_hit  :  $near_miss\n";      
      for ($y=1;$y <= $#node_otus  ; $y++) {
         $weig[$y] = $weig[$y] + ($TINA_W[$k][$near_hit][$y]/$#IN2) - ($TINA_W[$k][$near_miss][$y]/$#IN2);  
      }
}

###########################
@out_abun = "";
%out_w_h = "";
for ($y=1;$y <= $#node_otus  ; $y++) {
   @OTUS_i = split(/--/,$node_otus[$y]);
   $out_w_h{$OTUS_i[0]} =  $weig[$y];
   print "Branch importance : $y  ::  $weig[$y]\n";
}

#### print the output file
for ($k=1;$k<=$#IN2;$k++) {
  $IN2_line = $IN2[$k];
  chomp($IN2_line);
  @all_abun_k = split(/,/, $IN2_line);
  for ($l=0;$l<=$#all_abun_k;$l++) {
    $out_abun[$k][$l] = $all_abun_k[$l]; 
  }
    #$temp_i = (2 * $l) -4 ;
    $temp_i = ($#all_abun_k-1) + ($FILT * ($#all_abun_k - 1))  ;
    $out_abun[$k][$temp_i] = $all_abun_k[$l-1]; 
}

$col = $#all_abun_k ;
$fil_count  = 0;
foreach my $otu_n (reverse sort { $out_w_h{$a} <=> $out_w_h{$b} } keys %out_w_h) {
	#printf OUTFILE1 "%-8s %s\n", $otu_n, $out_w_h{$otu_n};
    for ($k=1;$k<=$#IN2;$k++) {
       @all_abun_k = split(/,/, $IN2[$k]);
       print OUTFILE2 "\n######## Chcking weights #############\n";
       print OUTFILE2 "Weight :$out_w_h{$otu_n} ::  $otu_n\n";
       @otus_l = split(/,/,$otu_n);
       $s_c = 0;
       for ($m =0;$m<=$#otus_l;$m++) {
	   $ind = $otus_l[$m]; 
           $s_c  = $s_c  +  $all_abun_k[$ind]; 
       }
       $out_abun[$k][$col] =  $s_c;
    
    }
  $fil_count = $fil_count + 1;
 if ($fil_count >= ($FILT * $#all_abun_k)) {last;}   
 $col  = $col  + 1;
}


print OUTFILE1 "\n";
for ($k=1;$k<=$#IN2;$k++) {
  for ($l=0;$l<=$col;$l++) {
    print OUTFILE1 "$out_abun[$k][$l],";
  }
    print OUTFILE1 "\n";
}

close(INFILE1);
close(INFILE2);
close(INFILE3);
close(OUTFILE1);
close(OUTFILE2);





