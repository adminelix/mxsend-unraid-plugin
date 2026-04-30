.PHONY: build clean lint

build:
	./build.sh

clean:
	rm -rf dist/

lint:
	shellcheck build.sh
