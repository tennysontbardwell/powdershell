FROM ocaml/opam:debian-12-ocaml-5.1 as build

USER root
RUN apt update \
  && apt install -y ocaml-native-compilers camlp4-extra opam ocaml-findlib bzip2 m4

USER opam
ADD src/Makefile src/powdershell.opam* /home/opam/src/
RUN sudo chown -R opam:opam /home/opam/src
WORKDIR /home/opam/src

RUN make install-dep

ADD src /home/opam/src
RUN sudo chown -R opam:opam /home/opam/src

RUN cd /home/opam/src && make clean test main.exe

FROM debian:12
COPY --from=build /home/opam/src/main.exe /home/opam/src/*opam* /home/opam/src/rules /home/opam/src/saves /root/
COPY --from=build /home/opam/src/rules /root/rules
COPY --from=build /home/opam/src/saves /root/saves
WORKDIR /root
CMD /bin/bash -c "./main.exe"
