#!/bin/env bash
mkdir StatsPredict
cd StatsPredict
curl -L https://rafalab.dfci.harvard.edu/dsbook-part-2/ | sed 's|href="|\nhref="|g' | grep href | grep -v "http" | grep -v "#" | grep ".html" | sed 's|href=||' | sed 's|^"./||' | sed 's|".*||' | grep html | uniq > list
wget -B https://rafalab.dfci.harvard.edu/dsbook-part-2/ --page-requisites -nd -k -i list
sed -i 's|sidebar -->|sidebar|g; s|<nav class="page-navigation">|<!-- &|; s|<!-- /content -->|<!-- /content|; /class="breadcrumb"/d' *.html
for i in *.html; do pandoc -V pagestyle=empty -V geometry:margin=20mm --pdf-engine=lualatex -t pdf -i "$i" -o "$i.pdf"; done
sed 's|.*/||' list | sed -z 's|intro.html|_ntro.html|' | grep -v ^intro.html | sed 's|_ntro|intro|' | sed 's|.html|&.pdf|g' > list2
sejda-console merge -b one_entry_each_doc -o "temp.pdf" --overwrite -t doc_titles -f $(sed -z 's|\n| |' list2)
sejda-console setheaderfooter -f "temp.pdf" -o "Statistics and Prediction Algorithms Through Case Studies - Irizarry - $(date +%Y-%m-%d).pdf" --pageRange all --verticalAlign bottom --horizontalAlign right --label "Page [PAGE_OF_TOTAL]"
mv Statistics*.pdf ../
