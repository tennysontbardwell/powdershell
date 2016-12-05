run: compile
	./main.byte

test: compile
	# ________________________________
	rm -rd test_build || true
	mkdir test_build
	# ________________________________
	./test.byte || true
	# ________________________________
	rm -rd test_build

compile:
	ocamlbuild -pkgs oUnit,yojson,str,lambda-term \
		main.byte test.byte \

check:
	bash checkenv.sh && bash checktypes.sh

clean:
	ocamlbuild -clean
	rm -f checktypes.ml
