FROM ocaml/opam:debian-10-ocaml-4.08

# RUN opam install utop.2.12.1 yojson.2.1.2 lambda-term.3.3.2 oUnit.2.2.7
RUN opam install utop yojson lambda-term.3.3.2 oUnit
USER root
RUN apt update \
  && apt install -y ocaml-native-compilers camlp4-extra opam ocaml-findlib bzip2 m4
USER opam

ADD src /home/opam/src
RUN sudo chown -R opam:opam /home/opam/src

RUN cd /home/opam/src && make clean
RUN cd /home/opam/src && make main.exe

USER opam
WORKDIR /home/opam/src

CMD /bin/bash -c "./main.exe"
