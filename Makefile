FILES = \
	index.md \
	gettime.md \
	parse.md \
	timetable.md \
	tzinfo.md \
	links.md

all: luatz.html luatz.pdf luatz.3

luatz.html: template.html site.css metadata.yaml $(FILES)
	pandoc -o $@ -t html5 -s --toc --template=template.html --section-divs --self-contained -c site.css metadata.yaml $(FILES)

luatz.pdf: metadata.yaml $(FILES)
	pandoc -o $@ -t latex -s --toc --toc-depth=2 -V documentclass=article -V classoption=oneside -V links-as-notes -V geometry=a4paper,includeheadfoot,margin=2.54cm metadata.yaml $(FILES)

luatz.3: metadata.yaml $(FILES)
	pandoc -o $@ -t man -s metadata.yaml $(FILES)

man: luatz.3
	man -l $^

clean:
	rm -f luatz.html luatz.pdf luatz.3

.PHONY: all man install clean
