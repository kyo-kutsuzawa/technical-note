for %%f in (%*) do (
    pandoc -o "%%~dpnf.html" "%%~ff" -f markdown+ignore_line_breaks --mathjax --template=template.html --eol=lf --toc
)
pause
