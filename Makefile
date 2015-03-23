################################################################################
# Copyright 2011
# Andrew Redd
# 11/23/2011
#
# Description of File:
# Makefile for knitr compiling
#
################################################################################
all:pdf  # default rule DO NOT EDIT
################################################################################
MAINFILE  := RCodeOptimizationProfiling
RTEXFILES  :=
RFILES    :=
TEXFILES  :=
CACHEDIR  := cache
FIGUREDIR := figures
LATEXMK_FLAGS :=
##### Explicit Dependencies #####
################################################################################
RTEXTEX = $(RTEXFILES:.Rnw=.tex)
ROUTFILES = $(RFILES:.R=.Rout)
RDATAFILES= $(RFILES:.R=.Rdata)
MAINTEX = $(MAINFILE:=.tex)
MAINPDF = $(MAINFILE:=.pdf)
ALLTEX = $(MAINTEX) $(RTEXTEX) $(TEXFILES)

# Dependencies
$(RTEXTEX): $(RDATAFILES)
$(MAINTEX): $(RTEXTEX) $(TEXFILES)
$(MAINPDF): $(MAINTEX) $(ALLTEX)

.PHONY:pdf tex clean clearcache cleanall
pdf: $(MAINPDF)
tex: $(RDATAFILES) $(ALLTEX)

$(CACHEDIR):
	mkdir $(CACHEDIR)

$(FIGUREDIR):
	mkdir $(FIGUREDIR)

%.tex:%.Rnw
	Rscript \
		-e "library(knitr)" \
		-e "knitr::opts_chunk[['set']](fig.path='$(FIGUREDIR)/$*-')" \
		-e "knitr::opts_chunk[['set']](cache.path='$(CACHEDIR)/$*-')" \
		-e "knitr::knit('$<','$@')"


%.R:%.Rnw
	Rscript -e "Sweave('$^', driver=Rtangle())"

%.Rout:%.R
	R CMD BATCH "$^" "$@"

%.pdf: %.tex
	latexmk -xelatex  $<

clean:
	-latexmk -c -quiet $(MAINFILE).tex
	-rm -f $(MAINTEX) $(RTEXTEX)
	-rm -rf $(FIGUREDIR)
	-rm *tikzDictionary
	-rm $(MAINPDF)

clearcache:
	-rm -rf cache

cleanall: clean clearcache
