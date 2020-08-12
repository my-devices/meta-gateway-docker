#
# This is the Dockerfile for the macchina.io Remote Manager Device Agent (WebTunnelAgent)
#

#
# Stage 1: Build
#
FROM ubuntu:18.04 as buildstage

# Install required components for building
RUN apt-get -y update \
 && apt-get -y install \
 	git \
    g++ \
    libssl-dev \
    cmake

# Create user
RUN adduser --system --group build

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
		-DENABLE_WEBTUNNELAGENT=OFF \
		-DENABLE_WEBTUNNELCLIENT=OFF \
		-DENABLE_WEBTUNNELSSH=OFF \
		-DENABLE_WEBTUNNELVNC=OFF \
		-DENABLE_WEBTUNNELRDP=OFF \
		-DCMAKE_INSTALL_PREFIX=/home/build/install \
	&& cmake --build . --config Release --target install

# Build Gateway
RUN cd /home/build/work/gateway \
	&& cmake /home/build/source/gateway -DCMAKE_PREFIX_PATH=/home/build/install \
	&& cmake --build . --config Release

#
# Stage 2: Install
#
FROM ubuntu:18.04 as runstage

RUN apt-get -y update \
 && apt-get -y install \
    libssl1.1 \
    ca-certificates \
    iputils-ping

# Copy Agent executable
COPY --from=buildstage /home/build/work/gateway/rmgateway /usr/local/bin
ADD rmgateway.properties /etc/rmgateway.properties

ENV LOGPATH=/var/log/WebTunnelAgent.log
ENV LOGLEVEL=information
ENV LOGCHANNEL=console
ENV DOMAIN=00000000-0000-0000-0000-000000000000
ENV REFLECTOR_URI=https://reflector.my-devices.net/
ENV HTTP_PORT=8080

CMD ["/usr/local/bin/rmgateway", "--config=/etc/rmgateway.properties"]
