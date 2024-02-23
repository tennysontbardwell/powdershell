FROM ocaml/opam:debian-10-ocaml-4.03

RUN opam install utop yojson lambda-term.1.13 oUnit

RUN mkdir /home/opam/{rules,saves,src,test_files}
ADD Makefile /home/opam/
ADD rules /home/opam/rules
ADD saves /home/opam/saves
ADD test_files /home/opam/test_files
ADD src /home/opam/src
RUN sudo chown -R opam:opam /home/opam/src

RUN cd /home/opam/src \
  && eval `opam config env` \
  && ocamlbuild -pkgs oUnit,yojson,str,lambda-term -cflags -ccopt,-static main.native main.byte \
  && cp /home/opam/src/main.byte /home/opam

USER opam
WORKDIR /home/opam
CMD /bin/bash -c "/home/opam/main.byte"
