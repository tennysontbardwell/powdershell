test:
	ocamlbuild -pkgs oUnit,yojson,str,lambda-term main.byte && ./main.byte

check:
	bash checkenv.sh && bash checktypes.sh

clean:
	ocamlbuild -clean
	rm -f checktypes.ml