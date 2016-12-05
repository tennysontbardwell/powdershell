run: compile
	./main.byte

test: compile
	mkdir test_build
	./test.byte
	rm -rf test_build

compile:
	ocamlbuild -pkgs oUnit,yojson,str,lambda-term \
		main.byte test.byte \

check:
	bash checkenv.sh && bash checktypes.sh

clean:
	ocamlbuild -clean
	rm -f checktypes.ml
