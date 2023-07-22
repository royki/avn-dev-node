FROM ubuntu:22.04

# metadata
ARG VCS_REF
ARG BUILD_DATE
ARG IMAGE_NAME

# TODO once public, add io.aventus.image.source
LABEL io.aventus.image.authors="devops@aventus.io" \
	io.aventus.image.vendor="Aventus Network Services" \
	io.aventus.image.title="${IMAGE_NAME}" \
	io.aventus.image.description="AvN Development parachain" \
	io.aventus.image.revision="${VCS_REF}" \
	io.aventus.image.created="${BUILD_DATE}" \
	io.aventus.image.documentation="https://github.com/Aventus-Network-Services/avn-dev-node"

# show backtraces
ENV RUST_BACKTRACE 1

# install tools and dependencies
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

# add avn-dev-node binary to the docker image
COPY target/release/avn-dev-node /usr/local/bin/

USER avn-node
RUN chmod +x /usr/local/bin/avn-dev-node
# check if executable works in this container
RUN /usr/local/bin/avn-dev-node --version

EXPOSE 30333 30334 9933 9944 9615
VOLUME ["/data"]

ENTRYPOINT ["/usr/local/bin/avn-dev-node"]
