10K Content Analysis
======================

Extracting text from the raw 10-K filings on SEC's EDGAR database. Output will be in two-fold for each raw filing: One for the entire 10-K and one for Item 7(A). Retrieving the raw filings can be done with SAS and Perl (tutorial from WRDS) or by using Perl with the scripts by Andy Leone.

The scripts have not been written from scratch, but are an extension of existing scripts. Most notably, the additions include:
- retrieving folder contents
- keeping a log (so you can cancel and continue with the batch process a later time)
- showing a progress bar. 

The script can be used on both Windows and  Mac, but your OS has to be configured in the script.

The script extract10k.pl does not include HTML::Parse or HTML::Strip, since they produced errors. Hence the approach of using Regex to solve the problem. Since the script will be used to analyze readability, the issue with formatting is less relevant. The script does provide some basic means to recognize sentences and new lines (changing </p> and such into end of sentences) and cleaning the result (removing duplicate periods/spaces/breaks). 

Another part of this script is that it leaves tables in the output (albeit not in their original formatting, but split into seperate lines). The underlying assumption is that the numbers will not affect the readability results, since numerical characters are ignored. The alternative, removing all information stored between &lt;TABLE&gt; and &lt;/TABLE&gt;, would result in removing relevant information where the &lt;TABLE&gt; tag was improperly used to list bulletpoints in the 10K, and sometimes even the 10K filing itself (including chapters and text). 

The ideal format for the extract10k.pl script, is to have the file in HTML. When HTML tags are absent, there's an increased likelihood the script will not be able to find the end of the document. Currently, the &lt;/SEC-DOCUMENT&gt; tag is used. Subsequently, the script won't be able to find the MD&A section. For the sample I used, which consisted of about 100,000 filings from 1994-2014, the success rate of the script being able to extract the 10K AND the MD&A section, is 88%. For 2000-2014, it's 92%. In general, the following applies to the more recent years: 5% will fail because there was no end of document tag to be found, and another 1-2% will fail because the MD&A section is either not present or could not be found.

The basic info from the 10K filing can be obtained with the 10k_info_extraction.pl file. Basic info includes the following:
- Central Index Key
- Reporting Date
- Filing Date
- Company Name
- Standard Industrial Classification

The output for all files in the source directory will be written to a text file (semicolon separated values)

After these two scripts, you will have two folders: one for the entire 10K filing and one for the MD&A section (Item 7 and 7A). Readability can then be analyzed with either PHP which gives easier editing if you want readability to be calculated somewhat differently. It is however much slower than Perl (about 10 times slower). Perl considers words only those strings that consist of at least one vowel after cleaning (removing symbols like apostrofes and hyphens). Numbers are disregarded. PHP takes them into account however. This leads to higher readability indices because of approximately the same amount of syllables but relatively more words for the same text, especially when the filings contain a lot of numbers. Considering tables remain in the output files, this can result in a vast difference in indices. Which is more accurate is highly subjective, especially so since there is no strict rule regarding parsing of numbers/abbreviations/symbols. Where one might argue that numbers cannot be dissected into syllables, another may say that since most numbers come from tables, and tables lead to easier comprehension of data, that it would justify the lower indices.

On the todo list:
- Improve multithreading so files are processed correctly; currently the scripts only run single threaded. You could easily copy the script, adjust the subfolders and run them simultaneously without cross interference.
