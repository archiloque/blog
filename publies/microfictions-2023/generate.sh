asciidoctor -a stylesheet=styles.css all.asciidoc
sed -i '' 's/&#8201;&#8212;&#8201;/\&#8239;\&#8212;\&#8201;/g' all.html
weasyprint all.html microfictions-2023.pdf
rm all.html
asciidoctor-epub3 all.asciidoc -a ebook-validate --out-file microfictions-2023.epub
