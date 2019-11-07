use Tk;





#Global Variables
my $age = 10;
my $gender = "Male";

# Main Window
my $mw = new MainWindow;

#GUI Building Area
my $frm_name1 = $mw -> Frame();
#my $lab_name1 = $frm_name1 -> Label(-text=>"Abundance file Path:", -foreground => "green");
my $lab_name1 = $frm_name1 -> Label(-text=>"Abundance file Path:");
my $ent_name1 = $frm_name1 -> Entry();

#Gender
my $frm_name2 = $mw -> Frame();
my $lab_name2= $frm_name2 -> Label(-text=>"Phylogeny file Path ");
my $ent_name2 = $frm_name2 -> Entry();


my $frm_name3 = $mw -> Frame();
my $lab_name3= $frm_name3 -> Label(-text=>"OutPut PAAM file Path");
my $ent_name3 = $frm_name3 -> Entry();






my $but = $mw -> Button(-text=>"Generate", -background  => "blue" , -command =>\&push_button);

#Text Area
my $textarea = $mw -> Frame();
#my $txt = $textarea -> Text(-width=>40, -height=>10);
my $txt = $textarea -> Scrolled("Text", -scrollbars => 'se')->pack(-expand => 1, -fill => 'both');
#my $srl_y = $textarea -> Scrollbar(-orient=>'v',-command=>[yview => $t
#+xt]);
#my $srl_x = $textarea -> Scrollbar(-orient=>'h',-command=>[xview => $t
#+xt]);
#$txt -> configure(-yscrollcommand=>['set', $srl_y],
#        -xscrollcommand=>['set',$srl_x]);

#Geometry Management
$lab_name1 -> grid(-row=>1,-column=>1);
$ent_name1-> grid(-row=>1,-column=>2);
$frm_name1 -> grid(-row=>1,-column=>1,-columnspan=>2);

$lab_name2 -> grid(-row=>2,-column=>1);
$ent_name2-> grid(-row=>2,-column=>2);
$frm_name2 -> grid(-row=>2,-column=>1,-columnspan=>2);


$lab_name3 -> grid(-row=>3,-column=>1);
$ent_name3-> grid(-row=>3,-column=>2);
$frm_name3 -> grid(-row=>3,-column=>1,-columnspan=>2);




$but -> grid(-row=>6,-column=>1,-columnspan=>2);

$txt -> grid(-row=>1,-column=>1);
#$srl_y -> grid(-row=>1,-column=>2,-sticky=>"ns");
#$srl_x -> grid(-row=>2,-column=>1,-sticky=>"ew");
$textarea -> grid(-row=>7,-column=>1,-columnspan=>2);

MainLoop;




## Functions  PAAM
#This function will be executed when the button is pushed
sub push_button {
    my $Abundance_CSV = $ent_name1 -> get();
    my $PHYL = $ent_name2 -> get();
    my $OUT_CSV = $ent_name3 -> get();

    if ((! defined $PHYL) || (! defined $Abundance_CSV) || (! defined $OUT_CSV) ){
   die "          -------------------- USAGE---------------------
              perl <script name> -phylogeny <phylogeny file>  -ABUNDANCE_csv  <ABUNDANCE csv file> -OUTPUT_csv <output csv file> 


"
     }


     # my $PHYL = " ./processed_phylogeny_file_zxc.txt" ;
     #system("rm -rf $PHYL");
     #system( "sed 's/(/(\n/g' $PHYL2 |sed 's/)/\n)/g' |sed 's/,(/,\n(/g' > $PHYL") ;
     #$PHYL =  `sed 's/(/(\n/g' $PHYL2 |sed 's/)/\n)/g' |sed 's/,(/,\n(/g'` ;
     #print $PHYL ;
      
      open (INFILE1, "< $PHYL");
      open (INFILE2, "< $Abundance_CSV");
      open(OUTFILE,">> $OUT_CSV");
      open(OUT_3,">> map_nodes ");
      
      
      @IN1 = <INFILE1>;
      @IN2 = <INFILE2>;
      
      @otu_counts = split(/,/,$IN2[0]);
      $otu_count = $#otu_counts - 1;
      print "OTU count :  $otu_count\n";
      
      
      ############ start parsing tree ######
      $node = 0;    ### to see if line is a begining of a node
      $node_close = 0; ## to track closing brace
      $node_depth = -1;
      $node_column = -1 ;
      %out_hash = "";
      @node_otus = "";
      $max_depth = 0;
      @nodes_names = "";
      @nodes_nam = "";
      
      for ($i=0;$i<=$#IN1;$i++) {
         $line = $IN1[$i];
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
            for ($j=$i+1;$j<=$#IN1;$j++) {
                 $sub_line = $IN1[$j]; 
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
             $nodes_names[$col] =  "Internal_$col"; 
             my $OTUs_j = join(",",@OTUs_list );
             my $OTUs_w = join(",",@OTUs_wgt );
             print OUT_3 "Internal_$col  :: $OTUs_j\n";  
             $OTUs_j =~ s/"//g;
             $OTUs_w =~ s/"//g;
             
             $node_otus[$col]  = join("--",$OTUs_j,$OTUs_w) ; 
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
               $node_column = $node_column + 1;
        #       if ($otus[$m] =~ //) {next;}   
               my @otu_name = split(/:/,$otus[$m]);  
               my $col = $node_column;
               $nodes_names[$col] =  "OTU_$col"; 
               $node_otus[$col]  = join("--",$otu_name[0], 1)   ;
                $otu_name[0] =~ s/"//g;
               print OUT_3 "OTU_$col  :: $otu_name[0]\n";  
               print " $node_column    :: $otu_name[0]    \n";
               if ($otu_depth > $max_depth) { $max_depth = $otu_depth;}
            }
         }
      
      }
      
      $total_col = $node_column + 1; 
      print "\nColumn num :: $total_col  \n\n ";
      
      
      ###### PRINTING each sample now
      print OUTFILE "\n\n";
       $IN2[0] =~ s/"//g;
       @otus_name  = split(/,/,$IN2[0]);
       
      for ($l = 0; $l<= $node_column ; $l++ ) {
        print OUTFILE ",$nodes_names[$l]";
      }
      print OUTFILE "\n";
      
      
      
      for ($j= 1; $j<= $#IN2; $j++) { 
         print "Running Sample :$j\n";
         @otu_vals = split(/,/,$IN2[$j]); 
         print OUTFILE "$otu_vals[0]," ;
         for ($m=1;$m<$#otu_vals;$m++) {
           $out_hash{$otus_name[$m]} = $otu_vals[$m];
         }
           for ($l = 0; $l<= $node_column ; $l++ ) {
             my @otu_main = split(/--/,$node_otus[$l]);
             my @otu_spl  = split(/,/,$otu_main[0]);     
             my @otu_wgt_spl  = split(/,/,$otu_main[1]);     
             my $sum_otu = 0;
             for ($p=0;$p<=$#otu_spl;$p++) {
                my $otu_ref = $otu_spl[$p];
                if ($otu_wgt_spl[$p] == 0) {$otu_wgt_spl[$p] = 0.1;}
                $sum_otu = $sum_otu + ($out_hash{$otu_ref}/$otu_wgt_spl[$p]) ; 
             }
             print OUTFILE  "$sum_otu ,";
           } 
      print OUTFILE "$otu_vals[$#otu_vals]";
      }
      
      close(INFILE1);
      close(INFILE2);
      close(OUTFILE);
    

      open(OUTFILE," $OUT_CSV");
      while(<OUTFILE>) { $txt->insert('end',$_); }

      close(OUTFILE);

      #system("rm -rf $PHYL");
  #    $txt -> insert('end',"$name\($gender\) is $age years old.");
}
