lunr:
	if [ -d lunr.js ]; then echo "Already cloned"; else git clone https://github.com/olivernn/lunr.js; fi
	$(MAKE) -C lunr.js
	$(MAKE) -C lunr.js lunr.min.js

lunrlang:
	if [ -d lunr-languages ]; then echo "Already cloned"; else git clone https://github.com/MihaiValentin/lunr-languages; fi

theme:
	if [ -d theme-default ]; then echo "Already cloned"; else git clone https://github.com/GitbookIO/theme-default; fi
	cd theme-default && npm install
	cd theme-default && npm run prepublish

search:
	if [ -d plugin-search ]; then echo "Already cloned"; else git clone https://github.com/GitbookIO/plugin-search; fi
	cd plugin-search && npm install
	cd plugin-search && npm run prepublish

all: lunr lunrlang theme search
	echo Done
