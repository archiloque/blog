asciidoctor -a stylesheet=styles.css pdf.asciidoc
./venv/bin/weasyprint pdf.html invisibles-networks-2022.pdf
rm pdf.html