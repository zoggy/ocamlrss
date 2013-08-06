###############################################################################
#               OCamlrss                                                      #
#                                                                             #
#   Copyright (C) 2004-2013 Institut National de Recherche en Informatique    #
#   et en Automatique. All rights reserved.                                   #
#                                                                             #
#   This program is free software; you can redistribute it and/or modify      #
#   it under the terms of the GNU Lesser General Public License version       #
#   3 as published by the Free Software Foundation.                           #
#                                                                             #
#   This program is distributed in the hope that it will be useful,           #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of            #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             #
#   GNU Library General Public License for more details.                      #
#                                                                             #
#   You should have received a copy of the GNU Library General Public         #
#   License along with this program; if not, write to the Free Software       #
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA                  #
#   02111-1307  USA                                                           #
#                                                                             #
#   Contact: Maxence.Guesdon@inria.fr                                         #
#                                                                             #
#                                                                             #
###############################################################################

# do not forget to update META file too
VERSION=2.2.2

# do not forget to update META file too
PACKAGES=xmlm,netstring

OF_FLAGS=-package $(PACKAGES)
OCAMLFIND=ocamlfind
OCAML_COMPFLAGS= -annot
OCAMLC=$(OCAMLFIND) ocamlc $(OF_FLAGS) $(OCAML_COMPFLAGS)
OCAMLOPT=$(OCAMLFIND) ocamlopt $(OF_FLAGS) $(OCAML_COMFLAGS)
OCAMLDOC=$(OCAMLFIND) ocamldoc $(OF_FLAGS)
OCAMLDEP=ocamldep

all: byte opt
byte: rss.cma
opt: rss.cmxa rss.cmxs

CMOFILES= \
	rss_types.cmo \
	rss_io.cmo \
	rss.cmo

CMXFILES=$(CMOFILES:.cmo=.cmx)
CMIFILES=$(CMOFILES:.cmo=.cmi)

rss.cma: $(CMIFILES) $(CMOFILES)
	$(OCAMLC) -o $@ -a $(CMOFILES)

rss.cmxa: $(CMIFILES) $(CMXFILES)
	$(OCAMLOPT) -o $@ -a $(CMXFILES)

.PHONY: doc depend

doc: all
	mkdir -p html
	$(OCAMLDOC) -d html -html rss.mli

webdoc: doc
	mkdir -p ../ocamlrss-gh-pages/refdoc
	cp html/* ../ocamlrss-gh-pages/refdoc/
	cp web/index.html web/style.css ../ocamlrss-gh-pages/

.depend depend:
	$(OCAMLDEP) rss*.ml rss*.mli > .depend

rsstest: rss.cmxa rsstest.ml
	$(OCAMLOPT) -linkpkg -o $@ $(OCAML_COMPFLAGS) $^

test: rsstest
	@./rsstest test.rss > t.rss
	@./rsstest t.rss > t2.rss
	@((diff t.rss t2.rss && echo OK) || echo "t.rss and t2.rss differ")

# installation :
################
install:
	$(OCAMLFIND) install rss META LICENSE $(wildcard rss.cmi rss.cma rss.cmxa rss.a rss.cmxs rss.mli rss.cmx)

uninstall:
	ocamlfind remove rss

# archive :
###########
archive:
	git archive --prefix=ocamlrss-$(VERSION)/ HEAD | gzip > ../ocamlrss-gh-pages/ocamlrss-$(VERSION).tar.gz

# Cleaning :
############
clean:
	-$(RM) *.cm* *.a *.annot *.o
	-$(RM) -r html
	-$(RM) rsstest t2.rss t.rss

# headers :
###########
HEADFILES=Makefile *.ml *.mli
.PHONY: headers noheaders
headers:
	headache -h header -c .headache_config $(HEADFILES)

noheaders:
	headache -r -c .headache_config $(HEADFILES)

# generic rules :
#################
.SUFFIXES: .mli .ml .cmi .cmo .cmx .mll .mly .sch .html .mail

%.cmi:%.mli
	$(OCAMLC) -c $(OCAML_COMPFLAGS) $<

%.cmo:%.ml
	$(OCAMLC) -c $(OCAML_COMPFLAGS) $<

%.cmi %.cmo:%.ml
	$(OCAMLC) -c $(OCAML_COMPFLAGS) $<

%.cmx %.o:%.ml
	$(OCAMLOPT) -c $(OCAML_COMPFLAGS) $<

%.cmxs: %.cmxa
	$(OCAMLOPT) -I . -shared -linkall -o $@ $<

include .depend

