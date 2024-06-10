#!/bin/env bash
mkdir dcic-world
cd dcic-world
# Download index page, extract html links and download them
curl -L https://dcic-world.org/2023-02-21/index.html | sed 's|href="|\nhref="|g' | grep href | grep html | grep -v "#" | sed 's|href="||' | sed 's|".*||' > list
wget -B https://dcic-world.org/2023-02-21/ --page-requisites -nd -i list
# Remove table of contents on each page
sed -i 's|<div class="tocset">.*<h|<h|g' *.html
sed -i 's|</h4>.*<\/table>|</h4></table>|g' *.html
sed -i 's|</h3>.*<\/table>|</h3></table>|g' *.html
# Convert some of the unicode characters that Latex does not handle to text
sed -i 's|&#9760;|Danger! |g' *.html && sed -i 's|&#x2620;|Danger! |g' *.html && sed -i 's|&#9873;|Attention! |g' *.html && sed -i 's|&#x2691;|Attention! |g' *.html && sed -i 's|&#127988|Attention! |g' *.html
# Deactivate tables, due to pandoc bug on nested tables; see https://stackoverflow.com/questions/73685374/error-when-using-pandoc-convert-docx-to-pdf
sed -i 's|<table|<mable|g' *.html
# Convert to pdf
for i in *.html; do pandoc -V pagestyle=empty -V geometry:margin=20mm --pdf-engine=lualatex -t pdf -i "$i" -o "$i.pdf"; done
# Create list of pdfs to be merged, by removing subcontents pages
sed 's|booklet_intro.html|_ooklet_intro.html|g' list | sed -z 's|_ooklet_intro|__oklet_intro|' | grep -v ooklet | sed 's|__oklet|booklet|' | sed 's|part_appendix|part#_appendix|' | grep -v part_ | sed 's|part#_appendix|part_appendix|' | sed 's|$|.pdf|' > list2
# With sejda-console merge pdfs and generate bookmarks and a table of contents 
# https://github.com/torakiki/sejda/releases/tag/v3.2.85
sejda-console merge -b one_entry_each_doc -o DataCentricIntroductiontoComputing.pdf --overwrite -t doc_titles -f $(sed -z 's|\n| |' list2)
mv DataCentricIntroductiontoComputing.pdf ../
