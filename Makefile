# $Id: Makefile,v 1.3 2008-04-01 17:05:37 rjones Exp $

OCAMLFIND = ocamlfind
OCAMLMKLIB = ocamlmklib


OCAMLCFLAGS = -g
OCAMLCPACKAGES =
OCAMLOPTFLAGS =
OCAMLOPTPACKAGES =

EXAMPLES := $(wildcard examples/*.ml)

TESTS	:= $(patsubst %.ml,%,$(wildcard tests/*.ml))

all:	pa_bitmatch.cmo bitmatch.cma bitmatch.cmxa

pa_bitmatch.cmo: pa_bitmatch.ml
	ocamlfind ocamlc -I +camlp4 camlp4lib.cma -pp camlp4of.opt -c $< -o $@

bitmatch.cma: bitmatch.cmo
	$(OCAMLFIND) ocamlc -a -o $@ $^

bitmatch.cmxa: bitmatch.cmx
	$(OCAMLFIND) ocamlopt -a -o $@ $^

test: pa_bitmatch.cmo bitmatch.cma
	@for f in $(TESTS); do \
	  echo Test: $$f; \
	  $(OCAMLFIND) ocamlc $(OCAMLCFLAGS) -pp "camlp4o pa_bitmatch.cmo" \
	    -I . bitmatch.cma $$f.ml -o $$f; \
	  if [ $$? -ne 0 ]; then exit 1; fi; \
	  $$f; \
	  if [ $$? -ne 0 ]; then exit 1; fi; \
	done

print-tests: pa_bitmatch.cmo
	@for f in $(TESTS); do \
	  echo Test: $$f.ml; \
	  cmd="camlp4o pa_bitmatch.cmo -printer pr_o.cmo $$f.ml"; \
	  echo $$cmd; \
	  $$cmd; \
	done

print-examples: pa_bitmatch.cmo
	@for f in $(EXAMPLES); do \
	  echo Example: $$f; \
	  camlp4o pa_bitmatch.cmo -printer pr_o.cmo $$f; \
	done

.mli.cmi:
	$(OCAMLFIND) ocamlc $(OCAMLCFLAGS) $(OCAMLCPACKAGES) -c $<
.ml.cmo:
	$(OCAMLFIND) ocamlc $(OCAMLCFLAGS) $(OCAMLCPACKAGES) -c $<
.ml.cmx:
	$(OCAMLFIND) ocamlopt $(OCAMLOPTFLAGS) $(OCAMLOPTPACKAGES) -c $<

depend: .depend

.depend: bitmatch.ml bitmatch.mli
	rm -f .depend
	$(OCAMLFIND) ocamldep $(OCAMLCPACKAGES) $^ > $@

ifeq ($(wildcard .depend),.depend)
include .depend
endif

.PHONY: depend dist check-manifest dpkg doc print-examples print-tests test

.SUFFIXES:      .cmo .cmi .cmx .ml .mli .mll
