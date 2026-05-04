.PHONY: build clean lint

build:
	./build.sh

clean:
	rm -rf dist/

lint:
	shellcheck build.sh
	sed -n '/<!\[CDATA\[/,/\]\]>/p' source/usr/local/emhttp/plugins/dynamix/agents/Mxsend.xml | \
	  sed '1d;$$d' | shellcheck -s bash -
