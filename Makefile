DOC_FMT = html  # File format for documentation
READMES = $(subst .md,.$(DOC_FMT),README.md $(wildcard */README.md))
NOTES   = $(subst .md,.$(DOC_FMT),NOTES.md  $(wildcard */NOTES.md) )
TODOS   = $(subst .md,.$(DOC_FMT),TODO.md   $(wildcard */TODO.md)  )
ALL_DOCS = READMES NOTES TODOS

all: docs figs
docs: $(READMES) $(NOTES) TODO.$(DOC_FMT)
figs: ;

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
	rm -f $(READMES) $(NOTES) $(TODOS)
