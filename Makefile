.PHONY: build docker-build docker-run docker-extract run

docker-build:
	docker build . -t powdershell

docker-run: docker-build
	docker run --rm -it powdershell

src/main.exe: docker-build
	docker run --rm -it powdershell /bin/bash -c 'cat /home/opam/src/main.exe | base64 -w 0' \
		| base64 -d > ./src/main.exe \
    && chmod +x ./src/main.exe

docker-extract build: src/main.exe

clean:
	rm -rf src/main.exe

run: src/main.exe
	cd src && ./main.exe
