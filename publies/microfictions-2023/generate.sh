asciidoctor -a stylesheet=styles.css --out-file all-pdf.html all-pdf.asciidoc
sed -i '' 's/&#8201;&#8212;&#8201;/\&#8239;\&#8212;\&#8201;/g' all-pdf.html
weasyprint all-pdf.html microfictions-2023.pdf
rm all-pdf.html
asciidoctor-epub3 all-epub.asciidoc -a ebook-validate --out-file microfictions-2023.epub
