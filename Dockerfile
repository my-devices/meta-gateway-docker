#
# This is the Dockerfile for the macchina.io Remote Manager Device Agent (WebTunnelAgent)
#

#
# Stage 1: Build
#
FROM alpine:3.18 as buildstage

# Install required components for building
RUN apk update \
 && apk add \
 	git \
    g++ \
    linux-headers \
    cmake \
    make \
    openssl-dev

# Create user
RUN addgroup -S build && adduser -S -G build build

# Setup Directories
RUN mkdir -p /home/build/source \
	&& mkdir -p /home/build/work/sdk \
	&& mkdir -p /home/build/work/gateway \
	&& mkdir -p /home/build/install \
	&& chown -R build:build /home/build

USER build:build
WORKDIR /home/build

# Fetch Sources
RUN cd /home/build/source \
	&& git clone https://github.com/my-devices/sdk.git \
	&& git clone https://github.com/my-devices/gateway.git

# Build SDK
RUN cd /home/build/work/sdk \
	&& cmake /home/build/source/sdk \
		-DENABLE_JSON=ON \
        -DENABLE_PAGECOMPILER=ON \
        -DENABLE_PAGECOMPILER_FILE2PAGE=ON \
		-DENABLE_WEBTUNNELAGENT=OFF \
		-DENABLE_WEBTUNNELCLIENT=OFF \
		-DENABLE_WEBTUNNELSSH=OFF \
		-DENABLE_WEBTUNNELSCP=OFF \
		-DENABLE_WEBTUNNELSFTP=OFF \
		-DENABLE_WEBTUNNELVNC=OFF \
		-DENABLE_WEBTUNNELRDP=OFF \
		-DCMAKE_INSTALL_PREFIX=/home/build/install \
	&& cmake --build . --config Release --target install

# Build Gateway
RUN cd /home/build/work/gateway \
	&& cmake /home/build/source/gateway -DCMAKE_PREFIX_PATH=/home/build/install \
	&& cmake --build . --config Release \
	&& strip rmgateway

#
# Stage 2: Install
#
FROM alpine:3.18 as runstage

RUN apk update \
 && apk add \
    libstdc++ \
    openssl \
    ca-certificates \
    iputils

# Copy Agent executable
COPY --from=buildstage /home/build/work/gateway/rmgateway /usr/local/bin
ADD rmgateway.properties /etc/rmgateway.properties
RUN mkdir -p /var/lib/rmgateway

ENV LOGPATH=/var/log/rmgateway.log
ENV LOGLEVEL=information
ENV LOGCHANNEL=console
ENV DOMAIN=00000000-0000-0000-0000-000000000000
ENV TENANT=
ENV REFLECTOR_URI=https://remote.macchina.io
ENV HTTP_PORT=8080
ENV CONFIGDIR=/var/lib/rmgateway

CMD ["/usr/local/bin/rmgateway", "--config=/etc/rmgateway.properties"]
