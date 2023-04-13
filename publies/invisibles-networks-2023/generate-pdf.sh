asciidoctor -a stylesheet=styles.css pdf.asciidoc
weasyprint pdf.html invisibles-networks-2023.pdf
rm pdf.html
asciidoctor -b docbook README.asciidoc
pandoc -f docbook -t markdown_strict README.xml -o README.md
rm README.xml