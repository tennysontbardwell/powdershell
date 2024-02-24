FROM ocaml/opam:debian-10-ocaml-4.03

RUN opam install utop yojson lambda-term.1.13 oUnit
USER root
RUN apt update \
  && apt install -y ocaml-native-compilers camlp4-extra opam ocaml-findlib bzip2 m4
USER opam

ADD src /home/opam/src
RUN sudo chown -R opam:opam /home/opam/src

RUN cd /home/opam/src && make dune

USER opam
WORKDIR /home/opam/src
CMD /bin/bash -c "./main.exe"
