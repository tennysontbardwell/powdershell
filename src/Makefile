.PHONY: run test build clean check install-dep

run: main.exe
	main.exe

test:
	eval `opam config env` && dune runtest

build: main.exe

install-dep:
	cp powdershell.opam.locked powdershell.opam.locked.bak
	opam install . --locked --deps-only
	opam lock .
	diff -q powdershell.opam.locked powdershell.opam.locked.bak
	rm powdershell.opam.locked.bak

main.exe:
	eval `opam config env` && dune build @check
	eval `opam config env` && dune build @install

clean:
	rm -rf main.exe
