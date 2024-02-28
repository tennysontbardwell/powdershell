FROM ocaml/opam:debian-12-ocaml-5.1

USER root
RUN apt update \
  && apt install -y ocaml-native-compilers camlp4-extra opam ocaml-findlib bzip2 m4

USER opam
ADD src/Makefile /home/opam/src/Makefile
ADD src/powdershell.opam /home/opam/src/powdershell.opam
RUN sudo chown -R opam:opam /home/opam/src

WORKDIR /home/opam/src
# RUN make install-dep

RUN opam install utop.2.12.1 yojson.2.1.2 lambda-term.3.3.2 oUnit.2.2.7
# RUN opam install utop yojson lambda-term.3.3.2 oUnit

ADD src /home/opam/src
RUN sudo chown -R opam:opam /home/opam/src

RUN cd /home/opam/src && make clean test main.exe

CMD /bin/bash -c "./main.exe"
