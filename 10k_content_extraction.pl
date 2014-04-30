#!/usr/bin/perl -w
use strict;
use Time::Progress;
#use HTML::Entities;
no warnings 'utf8';
no warnings 'recursion';

#All variables
my $os="WIN";                   #Declare operating system for correct directory handling: WIN for Windows and OSX for Macintosh
my $base;                       #Base folder for the 10K filings
my $folder;                     #Folder where 10K filings are placed
my $target_10k;                 #Destination for output (10K)
my $target_mda;                 #Destination for output (MD&A)
my $slash;                      #Declare slash (dependent on operating system)
my @allfiles;                   #All files in source directory, put into an array
my $p;                          #Variable for progress-bar
my $c;                          #Variable for progress-bar
my $data;                       #Contents from source file
my $tenk;                       #Results of the search query (10K)
my $mda;                        #Results of the search query (MD&A)
my $output_10k;                 #Output file for full 10K
my $output_mda;                 #Output file for MD&A
my $log;                        #Log file (also used to determine point to continue progress)
my @filesinlog;                 #Files that have been processed according to log file
my $replace_old;                #Partial text to be replaced
my $replace_new;                #Partial text with the new replacement

#Searchstrings in regular expressions
my $tenkstart='item\s1\.?\s[^0-9A-Za-z]{0,3}(business)?';
my $tenkend='ENDOFTENK';
my $item7start='item\s*7\s*[^0-9A-Za-z]{0,2}\s*(management)?';
my $item8start='item\s*8\s*[^0-9A-Za-z]{0,2}\s*(financial)?';     
my $item9start='item\s*9\s*[^0-9A-Za-z]{0,2}\s*(change)?';
my $item10start='item\s*(10|11|12|13|14|15|16)\s*';

if($os ne "WIN" && $os ne "OSX")
{
print "Declare valid operating system!\n";
exit; 
}

elsif($os eq "WIN")
{
#Set folders for Windows. Put raw 10K filings in a folder called "10K" and set the base folder below (replace / with \\)
#E.g. if the filings are located in C:/EDGAR/10K/*.txt then set the $base folder as C:\\EDGAR
$slash="\\";
$base="C:\\EDGAR";
$folder="10K";
$target_10k="$base$slash"."10K_Full"."$slash$folder";
$target_mda="$base$slash"."10K_MDA"."$slash$folder";
}

elsif($os eq "OSX")
{
#Set folders for Macintosh. Put raw 10K filings in a folder called "10K" and set the base folder below
#E.g. if the filings are located in /Volumes/Untitled/EDGAR/10K/*.txt then set the $base folder as /Volumes/Untitled/EDGAR
$slash="/";
$base="/Volumes/Data/Documents";
$folder="10K";
$target_10k="$base$slash"."10K_Full"."$slash$folder";
$target_mda="$base$slash"."10K_MDA"."$slash$folder";
}

#Open source folder and read all files
opendir(DIR,"$base$slash$folder") or die $!;
@allfiles=grep ! /(^\.|^(log\.txt))/, readdir DIR;
chomp(@allfiles);

#Creates destination folder
mkdir "$base$slash"."10K_Full";
mkdir "$base$slash"."10K_MDA";
mkdir $target_10k;
mkdir $target_mda;

#Keep track of progress
$|=1;
$p=new Time::Progress;
$p->attr(min => 0, max => scalar @allfiles);
$c=0;

if (-e "$base$slash"."log.txt")
{
open (FH, "<", "$base$slash"."log.txt") or die $!;
@filesinlog = <FH>;
chomp(@filesinlog);
close FH or die $!;
}
 
foreach my $file(@allfiles)
{
print $p->report("%45b %p\r", $c);
if (grep $file eq $_, @filesinlog){}
else
    {
        {
        local $/;
        open (SLURP, "<", "$base$slash$folder"."$slash$file") or die $!;
        $data = <SLURP>;
        }
    close SLURP or die $!;

    #Steps to extract text
        {
        #HTML Cleanup
        $data=~ s/\nM[^a-z]+\n/\n/gs;                               #Remove line if it starts with capital M and everything thereafter does not contain a single lower case letter
        $data=~ s/<\/SEC-DOCUMENT>/ENDOFTENK/is;                    #Mark end of 10K
        #$data=decode_entities($data);                              #Remove HTML entities with HTML::Entities Module (may convert to invalid characters, especially on OSX)
        $data=~ s/<\/p>/\./ig;                                      #End of sentence for paragraph
        $data=~ s/<\/div>/\./ig;                                    #End of sentence for paragraph
        $data=~ s/<br.{0,2}>/\./ig;                                 #End of sentence for break
        $data=~ s/<\/tr>/\.\n/ig;                                   #Break line for end of table rows
        $data=~ s/<.*?>/ /igms;                                     #Remove html tags (starts with "<", ends with ">")
        $data=~ s/&.{2,4};/ /ig;                                    #Replace all HTML entities with spaces
        $data=~ s/\S{30,}/ /g;                                      #Remove long strings (+30 characters)
        
        #Text Cleanup
        $data=~ s/('s|"|\(|\))//g;                                  #Remove symbols from words (e.g. ['s] and ["])
        $data=~ s/[^A-Za-z0-9 .?!]{3,}/ /g;                         #Remove string it it consists of 3 or more non-alphanumeric characters
        $data=~ s/\.([0-9])/$1/g;                                   #Look for false end of sentences
                                                                    #Remove string if it contains forbidden special characters

        #Optional Text Cleanup
        $data=~ s/\.\s+\./\./g;                                     #Remove double end of sentences        
        $data=~ s/ {2,}/ /g;                                        #Remove double spaces        
        $data=~ s/\n /\n/g;                                         #Remove redundant empty lines
        $data=~ s/\n{3,}/\n\n/g;                                    #Remove redundant empty lines
        $data=~ s/\s+\./\./gms;                                     #Remove blank space when it is followed by a period
        
        #Add ! as suffix when "Item" is used as a reference (either when preceded by a preposition or when within 1000 characters, there is another mention of "Item")
        $data=~ s/(see|under|in|of|with|this|,)( *.{0,4})(item)/$1$2$3\!/igm; 
        $data=~ s/(item)( *[0-9][0-9A-Za-z]{0,2} *of)/$1\!$2/igm;
        $replace_old="(item *[0-9][0-9A-Za-z]{0,2}.{0,200}item *[0-9][0-9A-Za-z]{0,2})";
        while($data=~m/$replace_old/ismo)
            {
            $data=~m/$replace_old/ismo;
            $replace_new=$1;
            $replace_new=~s/item/Item\!/ismo;
            $data=~s/$replace_old/$replace_new/ismo;
            }          
                                         
        if($data=~m/($tenkstart.*?)$tenkend/ismo)
            {
            $tenk=$1;
            }
        else
            {
            $tenk="not found";
            }
        
        if($tenk=~m/($item7start.*?)($item8start|$item9start|$item10start)/ismo)
            {
            $mda=$1;
            $mda=~s/(item)\!/$1/gis;
            }
        else
            {
            $mda="not found";
            }
        $tenk=~s/(item)\!/$1/gis;
        
        }
        
    #Save output to file in destination folder (use the same filename as source file)
    open $output_10k, ">", "$target_10k$slash$file" or die $!;
    print $output_10k $tenk;
    close $output_10k;
    
    open $output_mda, ">", "$target_mda$slash$file" or die $!;
    print $output_mda $mda;
    close $output_mda;
    
    open $log, ">>", "$base$slash"."log.txt" or die $!;
    print $log "$file\n";
    close $log;
    }
    
    $c++;
    #Update progress
    print $p->report("%45b %p\r", $c);
}

#Print job duration
print $p->report("$c files processed: %L (%l sec) \n", $c);