
palladio.browser.js: palladio.ls
	lsc -c palladio.ls
	browserify palladio.js > palladio.browser.js

all: palladio.browser.js
