#!/usr/bin/env bash
cd files
zip ../book.epub -9 --no-extra mimetype META-INF/container.xml OEBPS/content.opf OEBPS/cover.svg OEBPS/cover.png OEBPS/toc.xhtml OEBPS/cover.xhtml OEBPS/chapter1.xhtml OEBPS/chapter2.xhtml OEBPS/notes.xhtml OEBPS/css.css OEBPS/birds.jpg
cd ..
/opt/homebrew/Cellar/epubcheck/5.2.1/bin/epubcheck --locale en book.epub
