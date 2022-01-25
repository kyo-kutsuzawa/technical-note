pandoc -o "%~dpn1.html" "%~f1" -f markdown+ignore_line_breaks --mathjax --template=template.html --eol=lf

pause
