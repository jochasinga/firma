FROM ocaml/opam2:4.08
MAINTAINER Joe Chasinga "jo.chasinga@gmail.com"
WORKDIR .

RUN opam update -y
RUN sudo apt update -y && \
    sudo apt upgrade -y && \
    sudo apt install -y \
	bash \
	curl \
	git \
	m4 \
	perl \
	pkg-config \
        build-essential \
	libgmp-dev \
	zlib1g-dev \
	libssl-dev \
        
ADD . .
RUN opam install -y -j 10 core dune cryptokit cohttp yojson async cohttp-async
RUN sudo chown -R opam:nogroup .
RUN sudo chown -R opam:nogroup _build

CMD ["./_build/default/api_server.exe"]
EXPOSE 8080
