.PHONY: build docker-build docker-run docker-extract run sync-deps

docker-build:
	docker build . -t tennysontbardwell/powdershell

docker-push: docker-build
	docker push tennysontbardwell/powdershell

docker-run: docker-build
	docker run --rm -it tennysontbardwell/powdershell

src/main.exe: docker-build
	docker run --rm -it tennysontbardwell/powdershell /bin/bash -c 'cat main.exe | base64 -w 0' \
		| base64 -d > ./src/main.exe \
    && chmod +x ./src/main.exe

docker-extract build: src/main.exe

sync-deps: docker-build
	rm -rf src/*.opam*
	docker run --rm -it tennysontbardwell/powdershell /bin/bash -c \
    'tar c *.opam* 2> /dev/null | cat - | base64 -w 0' | base64 -d | (cd src; tar x)

clean:
	rm -rf src/main.exe

run: src/main.exe
	cd src && ./main.exe
