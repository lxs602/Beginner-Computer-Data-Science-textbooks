#!/bin/env bash
mkdir bottom-up
cd bottom-up
curl -L https://bottomupcs.com | sed 's|href="|\nhref="|g' | grep href | grep -v "#" | grep html | sed 's|href="||' | sed 's|".*||' | uniq > list
wget -B https://bottomupcs.com/ --page-requisites -nd -k -i list
# Remove duplicates without sorting
cat -n list | sort -uk2 | sort -n | cut -f2- > list1
sed 's|.html|&.pdf|' list1 > list2
# Remove navigation pane
sed -i 's|<nav.*<\/nav>||g' *.html
# Fix for text in tables overspilling edge of page
sed -i -z 's|<td>[^\.]*\.|&<br>|g' *.html
# Consequent fix for error: ! LaTeX Error: Something's wrong--perhaps a missing \item...    l.119 ..
sed -i -e 's|<br>\.</td>|.</td>|g' -e 's|<br></td>|</td>|g' -e  's|\.</td>|</td>|g' -e 's|<sup>.<br>|<sup>.|g' *.html
# Consequent formatting fix
sed -i 's|>0\.<br>|>0.|g' *.html
for i in *.html; do pandoc -V pagestyle=empty -V monofont:lmmonoltcond10-regular.otf -V geometry:margin=20mm --pdf-engine=lualatex -t pdf -i "$i" -o "$i.pdf"; done
sejda-console merge -b one_entry_each_doc -o "temp.pdf" --overwrite -t doc_titles -f $(sed -z 's|\n| |' list2)
sejda-console setheaderfooter -f "temp.pdf" -o "Computer Science Bottom Up - Wienand $(date +%Y-%m-%d).pdf" --pageRange all --verticalAlign bottom --horizontalAlign right --label "Page [PAGE_OF_TOTAL]"
mv Computer*.pdf ../
