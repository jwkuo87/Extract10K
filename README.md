10k_content_extraction
======================

Extracting text from the raw 10-K filings on SEC's EDGAR database. Output is two-fold: One for the entire 10-K and one for Item 7(A), both in txt files. 

The script does not include HTML::Parse or HTML::Strip, since they gave errors. Hence the approach of using Regex to solve the problem. Since the script will be used to analyze readability (with the ReadabilityStatistics in PHP), the issue with formatting is less relevant. The script does provide some basic means to recognize sentences and new lines (changing </p> and such into end of sentences) and cleaning the result (removing duplicate periods/spaces/breaks). 

Another part of this script is that it leaves tables in the output (albeit not in their original formatting, but split into seperate lines). The underlying assumption is that the numbers will not affect the readability results, since numerical characters are ignored. Also, removing all information stored between <TABLE> and </TABLE> would result in removing relevant information where the <TABLE> tag was improperly used to list bulletpoints in the 10K. 



The basic info from the 10K filing can be obtained with the 10k_info_extraction.pl file. Basic info includes the following:
- Central Index Key
- Reporting Date
- Filing Date
- Company Name
- Standard Industrial Classification

The output for all files in the source directory will be written to a text file (semicolon separated values)
