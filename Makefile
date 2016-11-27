run: compile
	./main.byte

test: compile
	./test.byte

compile:
	ocamlbuild -pkgs oUnit,yojson,str,lambda-term \
		main.byte test.byte \

check:
	bash checkenv.sh && bash checktypes.sh

clean:
	ocamlbuild -clean
	rm -f checktypes.ml
