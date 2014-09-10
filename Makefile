README_FMT = html  # What file format do 
READMES = $(subst .md,.$(README_FMT),README.md $(wildcard */README.md))

all: docs
docs: $(READMES)

pandoc_recipe_html = \
pandoc -f markdown -t html5 -s \
       --highlight-style pygments --mathjax \
       --toc --toc-depth=4 \
       <$< >$@
%/README.html: %/README.md
	$(pandoc_recipe_html)
README.html: README.md
	$(pandoc_recipe_html)

clean:
	rm -f $(READMES)
