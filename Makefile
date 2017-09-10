# OASIS_START
# DO NOT EDIT (digest: a3c674b4239234cbbe53afe090018954)

SETUP = ocaml setup.ml

build: setup.data
	$(SETUP) -build $(BUILDFLAGS)

scripts:
	$(MAKE) -C scripts all

scriptlinks:
	if [ -f styles/lunr.min.js ]; then echo "lunr.min.js linked"; else ln -s ../scripts/lunr.js/lunr.min.js styles/lunr.min.js; fi
	if [ -f styles/lunr.stemmer.support.min.js ]; then echo "lunr.stemmer.support.min.js linked"; else ln -s ../scripts/lunr-languages/min/lunr.stemmer.support.min.js styles/lunr.stemmer.support.min.js; fi
	if [ -f styles/lunr.da.min.js ]; then echo "lunr.da.min.js linked"; else ln -s ../scripts/lunr-languages/min/lunr.da.min.js styles/lunr.da.min.js; fi
	if [ -f styles/website.css ]; then echo "styles/website.css linked"; else ln -s ../scripts/theme-default/_assets/website/style.css styles/website.css; fi
	if [ -f styles/gitbook.js ]; then echo "styles/gitbook.js linked"; else ln -s ../scripts/theme-default/_assets/website/gitbook.js styles/gitbook.js; fi
	if [ -f styles/theme.js ]; then echo "styles/theme.js linked"; else ln -s ../scripts/theme-default/_assets/website/theme.js styles/theme.js; fi
	if [ -d styles/fonts ]; then echo "styles/fonts/ linked"; else ln -s ../scripts/theme-default/_assets/website/fonts styles/fonts; fi
	if [ -f styles/search-engine.js ]; then echo "styles/search-engine.js linked"; else ln -s ../scripts/plugin-search/assets/search-engine.js styles/search-engine.js; fi
	if [ -f styles/search.js ]; then echo "styles/search.js linked"; else ln -s ../scripts/plugin-search/assets/search.js styles/search.js; fi
	if [ -f styles/search.css ]; then echo "styles/search.js linked"; else ln -s ../scripts/plugin-search/assets/search.css styles/search.css; fi

doc: setup.data build
	$(SETUP) -doc $(DOCFLAGS)

test: setup.data build
	$(SETUP) -test $(TESTFLAGS)

all:
	$(SETUP) -all $(ALLFLAGS)

install: setup.data
	$(SETUP) -install $(INSTALLFLAGS)

uninstall: setup.data
	$(SETUP) -uninstall $(UNINSTALLFLAGS)

reinstall: setup.data
	$(SETUP) -reinstall $(REINSTALLFLAGS)

clean:
	$(SETUP) -clean $(CLEANFLAGS)

distclean:
	$(SETUP) -distclean $(DISTCLEANFLAGS)

setup.data:
	$(SETUP) -configure $(CONFIGUREFLAGS)

configure:
	$(SETUP) -configure $(CONFIGUREFLAGS)

.PHONY: build doc test all install uninstall reinstall clean distclean configure scripts

# OASIS_STOP
