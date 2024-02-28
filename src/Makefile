.PHONY: run test build clean check install-dep

run: main.exe
	main.exe

test:
	eval `opam config env` && dune runtest

build: main.exe

install-dep:
	opam install ./powdershell.opam --deps-only
# opam switch create . 4.08 -y --deps-only

main.exe:
	eval `opam config env` && dune build @install

clean:
	rm -rf main.exe
