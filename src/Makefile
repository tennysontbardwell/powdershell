.PHONY: run
run: main.exe
	src/main.byte

.PHONY: test
test: main.exe
	rm -rd test_build || true
	mkdir test_build
	./test.byte
	rm -rd test_build

main.exe:
	eval `opam config env` && dune build @install

check:
	bash checkenv.sh && bash checktypes.sh

clean:
	rm main.exe
