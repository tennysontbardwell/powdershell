.PHONY: build docker-build docker-run docker-extract run sync-deps

docker-build:
	docker build . -t powdershell

docker-run: docker-build
	docker run --rm -it powdershell

src/main.exe: docker-build
	docker run --rm -it powdershell /bin/bash -c 'cat main.exe | base64 -w 0' \
		| base64 -d > ./src/main.exe \
    && chmod +x ./src/main.exe

docker-extract build: src/main.exe

sync-deps: docker-build
	rm -rf src/powdershell.opam src/*lock*
	docker run --rm -it powdershell /bin/bash -c 'tar c *lock* *opam 2> /dev/null | cat - | base64 -w 0' | base64 -d | (cd src; tar x)

clean:
	rm -rf src/main.exe

run: src/main.exe
	cd src && ./main.exe
