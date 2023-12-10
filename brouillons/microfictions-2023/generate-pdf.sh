asciidoctor -a stylesheet=styles.css all.asciidoc
weasyprint all.html microfictions-2023.pdf
rm all.html
