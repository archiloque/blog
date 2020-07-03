asciidoctor -b docbook all.asciidoc

pandoc --from=docbook --to=pdf all.xml -o all.pdf --pdf-engine=xelatex -V 'monofont:Menlo.ttf' -V 'mainfont:NewYorkMedium.otf' -V 'mainfontoptions:Extension=.otf, UprightFont=*, BoldFont=*-Bold, ItalicFont=*-Italic' -V 'monofontoptions:Extension=.ttf, UprightFont=*, BoldFont=*-Bold, ItalicFont=*-Italic' -V geometry:margin=1in -V linestretch:1.25

pandoc --from=docbook --to=epub all.xml -o all.epub

rm all.xml