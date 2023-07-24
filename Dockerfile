FROM rust:latest as builder

RUN apt update
RUN apt install -y clang cmake protobuf-compiler

RUN rustup default stable
RUN rustup update

RUN rustup update nightly
RUN rustup target add wasm32-unknown-unknown --toolchain nightly
RUN rustup default nightly

WORKDIR /var/www/ewx-avn-node
ENV CARGO_HOME=/var/www/ewx-avn-node/.cargo

COPY . /var/www/ewx-avn-node

ENV RUST_BACKTRACE 1
RUN cargo build --release

FROM ubuntu:22.04

# show backtraces
ENV RUST_BACKTRACE 1

RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y \
	libssl3 \
	ca-certificates \
	curl \
	jq && \
	# apt cleanup
	apt-get autoremove -y && \
	apt-get clean && \
	find /var/lib/apt/lists/ -type f -not -name lock -delete; \
	# add user and link ~/.local/share/avn-node to /data
	useradd -m -u 1000 -U -s /bin/sh -d /avn-node avn-node && \
	mkdir -p /data /avn-node/.local/share && \
	chown -R avn-node:avn-node /data && \
	ln -s /data /avn-node/.local/share/avn-node && \
	mkdir -p /specs

COPY --from=builder /var/www/ewx-avn-node/target/release/avn-dev-node /usr/local/bin/

RUN chmod +x /usr/local/bin/avn-dev-node

USER avn-node

# check if executable works in this container
RUN /usr/local/bin/avn-dev-node --version

EXPOSE 30333 9933 9944 9615

VOLUME ["/data"]

ENTRYPOINT ["/usr/local/bin/avn-dev-node"]
