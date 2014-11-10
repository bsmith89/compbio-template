READMES = README.md $(wildcard */README.md)
NOTES   = NOTE.md   $(wildcard */NOTE.md  )
TODOS   = TODO.md   $(wildcard */TODO.md  )
ALL_DOCS_HTML = $(subst .md,.html, $(READMES) $(NOTES) $(TODOS))

all: docs figs
docs: $(ALL_DOCS_HTML)
figs:

pandoc_recipe_md2html = \
pandoc -f markdown -t html5 -s \
       --highlight-style pygments --mathjax \
       --toc --toc-depth=4 \
       --css static/main.css \
    <$< >$@
%/README.html: %/README.md
	$(pandoc_recipe_md2html)
%/NOTEBOOK.html: %/NOTES.md
	$(pandoc_recipe_md2html)
%/TODO.html: %/TODO.md
	$(pandoc_recipe_md2html)
%.html: %.md
	$(pandoc_recipe_md2html)

clean:
	rm -f $(ALL_DOCS_HTML)
