asciidoctor-pdf -r ./custom.rb -a pdf-fontsdir=. -a pdf-style=theme.yml README.asciidoc
mv README.pdf ../baba.pdf

asciidoctor -b docbook README.asciidoc
pandoc --from=docbook --to=epub README.xml -o ../baba.epub
rm README.xml
