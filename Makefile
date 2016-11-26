run: compile
	./main.byte

test: compile
	./test.byte

compile:
	ocamlbuild -pkgs oUnit,yojson,str,lambda-term \
		main.byte gui.byte rules.byte clock.byte filemanager.byte model.byte updater.byte testy.byte \
		test.byte filemanager_tests.byte

check:
	bash checkenv.sh && bash checktypes.sh

clean:
	ocamlbuild -clean
	rm -f checktypes.ml
