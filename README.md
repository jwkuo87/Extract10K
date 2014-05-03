10K Content Analysis
======================

Extracting text from the raw 10-K filings on SEC's EDGAR database. Output is two-fold: One for the entire 10-K and one for Item 7(A), both in txt files. Retrieving the files can be done with SAS and Perl (Tutorial on WRDS) or by using Perl with scripts by Andy Leone.

All scripts are not written from scratch, but are an extension of existing scripts. Most notably, the additions include retrieving folder contents, keeping a log (so you can cancel and continue with the batch process a later time) and showing a progress bar. The log file also means that despite running the script multiple times, the output will contain unique data and should not contain invalid data, even when the computer freezes. In the worst case, if the computer would freeze during the process of writing to the output, the output would contain empty values which could be easily detected if you import the outputted text file into an excel spreadsheet and filter the data. Also, since output is written first, and the log file right after it succeeds, if the computer would freeze in between these two processes, the log file would say that the file has not been processed yet, while it is in fact already in the output file. The result: your output file would contain duplicate values for that specific file when the computer halted. The script can be both used on Windows and on Mac, but your OS has to be configured in the individual script.

The script extract10k.pl does not include HTML::Parse or HTML::Strip, since they gave errors. Hence the approach of using Regex to solve the problem. Since the script will be used to analyze readability (with the ReadabilityStatistics in PHP), the issue with formatting is less relevant. The script does provide some basic means to recognize sentences and new lines (changing </p> and such into end of sentences) and cleaning the result (removing duplicate periods/spaces/breaks). 

Another part of this script is that it leaves tables in the output (albeit not in their original formatting, but split into seperate lines). The underlying assumption is that the numbers will not affect the readability results, since numerical characters are ignored. Also, removing all information stored between &lt;TABLE&gt; and &lt;/TABLE&gt; would result in removing relevant information where the &lt;TABLE&gt; tag was improperly used to list bulletpoints in the 10K, and sometimes even the 10K filing itself (including chapters and text). 

The basic info from the 10K filing can be obtained with the 10k_info_extraction.pl file. Basic info includes the following:
- Central Index Key
- Reporting Date
- Filing Date
- Company Name
- Standard Industrial Classification

The output for all files in the source directory will be written to a text file (semicolon separated values)

After these two scripts, you will have two folders: one for the entire 10K filing and one for the MD&A section (Item 7 and 7A). Readability can then be analyzed with either PHP which gives easier editing if you want readability to be calculated somewhat differently. It is however much slower than Perl (about 10 times slower). Perl considers words only those strings that consist of at least one vowel after cleaning (removing symbols like apostrofes and hyphens). Numbers are disregarded. PHP takes them into account however. This leads to higher readability indices because of approximately the same amount of syllables but relatively more words for the same text, especially when the filings contain a lot of numbers. Considering tables remain in the output files, this can result in a vast difference in indices. Which is more accurate is highly subjective, especially so since there is no strict rule regarding parsing of numbers/abbreviations/symbols. Where one might argue that numbers cannot be dissected into syllables, another may say that since most numbers come from tables, and tables lead to easier comprehension of data, that it would justify the lower indices.

On the todo list:
- Improve multithreading so files are processed correctly; currently the scripts only run single threaded. You could easily copy the script and adjust the subfolders and run them simultaneously without cross interference. Check your activit
