#!/usr/bin/perl -w
use strict;
use Time::Progress;
use Path::Class;
use Lingua::EN::Fathom;
#no warnings 'utf8';
#no warnings 'recursion';

#All variables
my $os="WIN";                           #Declare operating system for correct directory handling: WIN for Windows and OSX for Macintosh
my $folder;                             #Base directory for the 10K filings
my $subfolder="2012";                   #Subdirectory where 10K filings are placed
my $target="Readability";               #Name of target directory
my $slash;                              #Declare slash (dependent on operating system)
my $file;                               #Filename
my @allfiles;                           #All files in directory, put into an array
my $allfiles;                           #Total files in directory
my $p;                                  #Variable for progress-bar
my $c;                                  #Variable for progress-bar
my $text = new Lingua::EN::Fathom;      #Input file contents
my $text_string = "";                   #Input file contents in strings
my $output;                             #Output file with readability statistics
my $log;                                #Log file (also used to determine point to continue progress)
my $logfile="$subfolder".".log";        #Filename of log file
my @filesinlog;                         #Files that have been processed according to log file
my $accumulate = 1;

if($os ne "WIN" && $os ne "OSX")
{
print "Declare valid operating system!\n";
exit; 
}

elsif($os eq "WIN")
{
#Set folders for Windows. Put raw 10K filings in folder\subfolder
$slash="\\";
$folder="C:\\10K\\10K_Full\\";
}

elsif($os eq "OSX")
{
#Set folders for Macintosh. Put raw 10K filings in folder\subfolder
$slash="/";
$folder="/Volumes/Data/Documents/10K/10K_Full";
}

#Open source folder and read all files
opendir(DIR, "$folder$slash$subfolder") or die $!;
@allfiles=grep /(.\.txt)/, readdir(DIR);
chomp(@allfiles);
closedir(DIR);

#Create folders
mkdir "$folder$slash$subfolder$slash$target";

#Keep track of progress
$|=1;
$p=new Time::Progress;
$p->attr(min => 0, max => scalar @allfiles);
$c=0;
$allfiles=scalar @allfiles;

#Check if output file is present
if (-e "$folder$slash$subfolder$slash$target$slash$subfolder"."_output.txt"){}
else
{
open $output, ">", "$folder$slash$subfolder$slash$target$slash$subfolder"."_output.txt" or die $!;
print $output "$folder$subfolder\n\nFilename;Gunning Fog Score;Flesch-Kincaid;Sentences;Words;Unique Words;Syllables;Character Count\n";
close $output;
}

#Check if log file is present
if (-e "$folder$slash$subfolder$slash$target$slash$logfile")
{
open (FH, "<", "$folder$slash$subfolder$slash$target$slash$logfile") or die $!;
@filesinlog = <FH>;
chomp(@filesinlog);
close FH or die $!;
}

foreach my $file(@allfiles)
{
if (grep $file eq $_, @filesinlog){}
else
    {
    $text->analyse_file("$folder$slash$subfolder$slash$file");
    $text->analyse_block($text_string,$accumulate);

    my $fog                     = sprintf "%.1f", $text->fog;
    my $kincaid                 = sprintf "%.1f", $text->kincaid;
    my $num_sentences           = $text->num_sentences;
    my $num_words               = $text->num_words;
    my %words                   = $text->unique_words;
    my $unique_words            = keys %words;
    my $num_syllables           = $text->{num_syllables};
    my $num_chars               = $text->num_chars;
    my $readability             = 
                "$file"
        . ";" . "$fog"
        . ";" . "$kincaid"
        . ";" . "$num_sentences"
        . ";" . "$num_words"
        . ";" . "$unique_words"
        . ";" . "$num_syllables"
        . ";" . "$num_chars"
        . "\n";
        
    foreach my $search ($text)
        {
        open $output, ">>", "$folder$slash$subfolder$slash$target$slash$subfolder"."_output.txt" or die $!;
        print $output $readability;
        close $output;
    
        open $log, ">>", "$folder$slash$subfolder$slash$target$slash$logfile" or die $!;
        print $log "$file\n";
        close $log;
        }
    }

#Update progress
$c++;
print $p->report("$c/$allfiles files processed: %L %20b %p\r", $c);
}

#Print job duration
print $p->report("$c/$allfiles files processed: %L \n", $c);
