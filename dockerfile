FROM ocaml/opam

RUN mkdir /home/opam/src

ADD Makefile /home/opam/
RUN opam install utop yojson lambda-term oUnit

ADD src /home/opam/src/
RUN mkdir /home/opam/rules
ADD rules /home/opam/rules
RUN mkdir /home/opam/saves
ADD rules /home/opam/saves
RUN mkdir /home/opam/test_files
ADD rules /home/opam/test_files
RUN sudo chown -R opam:opam /home/opam/src

WORKDIR /home/opam/src
RUN eval `opam config env` && ocamlbuild -pkgs oUnit,yojson,str,lambda-term main.byte
RUN cp /home/opam/src/main.byte /home/opam/main.byte

USER opam
WORKDIR /home/opam
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
CMD /bin/bash -c "/home/opam/main.byte"
