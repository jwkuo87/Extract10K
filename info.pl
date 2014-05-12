#!/usr/bin/perl -w
use strict;
use Time::Progress;

#All variables
my $os="WIN";                   #Declare operating system for correct directory handling: WIN for Windows and OSX for Macintosh
my $source;                     #Source of text files
my $target;                     #Destination for output
my $slash;                      #Declare slash (dependent on operating system)
my @allfiles;                   #All files in source directory, put into an array
my $p;                          #Variable for progress-bar
my $c;                          #Variable for progress-bar
my $output_info;                #Output file for basic info from 10K
my @threads;                    #All threads in array

if($os ne "WIN" && $os ne "OSX")
{
print "Declare valid operating system!\n";
exit; 
}

elsif($os eq "WIN")
{
#Set folders for Windows
$source="C:\\EDGAR\\10K";
$target="C:\\EDGAR\\10K_Info";
$slash="\\";
}

elsif($os eq "OSX")
{
#Set folders for Macintosh
$source="/Volumes/Data/Documents/10K";
$target="/Volumes/Data/Documents/10K_Info";
$slash="/";
}


#Directory with all 10K filings (as downloaded from EDGAR)
opendir(DIR,"$source") or die $!;
@allfiles=grep ! /^\./, readdir DIR;

#Creates output file in destination folder
mkdir $target;
open $output_info, ">>", "$target$slash"."10K_info.txt" or die $!;
print $output_info "File;HTML;CIK;Reporting Date;Filing Date;Name;SIC\n";

#Keep track of progress
$|=1;
$p=new Time::Progress;
$p->attr(min => 0, max => scalar @allfiles);
$c=0;

{
my $cik="not found";
my $report_date="not found";
my $file_date="not found";
my $name="not found";
my $sic="not found";
my $HTML=0;
my $data="";

foreach my $file(@allfiles)
    {
    print $p->report("%45b %p\r", $c);
        {
            {
            local $/;
            open (SLURP, "<", "$source$slash$file") or die $!;
            $data = <SLURP>;
            }
        close SLURP or die $!;

        #Obtain basic info from 10K
        if($data=~m/<HTML>/i){$HTML=1;}
        if($data=~m/^\s*CENTRAL\s*INDEX\s*KEY:\s*(\d*)/m){$cik=$1;}
        if($data=~m/^\s*CONFORMED\s*PERIOD\s*OF\s*REPORT:\s*(\d*)/m){$report_date=$1;}
        if($data=~m/^\s*FILED\s*AS\s*OF\s*DATE:\s*(\d*)/m){$file_date=$1;}
        if($data=~m/^\s*COMPANY\s*CONFORMED\s*NAME:\s*(.*$)/m){$name=$1;}
        if($data=~m/^\s*STANDARD\s*INDUSTRIAL\s*CLASSIFICATION:.*?\[(\d{4})/m){$sic=$1;}

        print $output_info "$file;$HTML;$cik;$report_date;$file_date;$name;$sic\n";
        }
    $c++;
    print $p->report("%45b %p\r", $c);
    }

close $output_info;
print $p->report("$c files processed: %L (%l sec) \n", $c);
}
