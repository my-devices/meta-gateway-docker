# The macchina.io Remote Manager Gateway Docker Image

## About macchina.io Remote Manager

[macchina.io Remote Manager](https://macchina.io) provides secure remote access to connected devices
via HTTP or other TCP-based protocols and applications such as secure shell (SSH) or
Virtual Network Computing (VNC). With macchina.io Remote Manager, any network-connected device
running the Remote Manager Agent software (*WebTunnelAgent*, contained in this SDK)
can be securely accessed remotely over the internet from browsers, mobile apps, desktop,
server or cloud applications.

This even works if the device is behind a NAT router, firewall or proxy server.
The device becomes just another host on the internet, addressable via its own URL and
protected by the Remote Manager server against unauthorized or malicious access.
macchina.io Remote Manager is a great solution for secure remote support and maintenance,
as well as for providing secure remote access to devices for end-users via web or
mobile apps.

Visit [macchina.io](https://macchina.io/remote.html) to learn more and to register for a free account.
Specifically, see the [Getting Started](https://macchina.io/remote_signup.html) page and the
[Frequently Asked Questions](https://macchina.io/remote_faq.html) for
information on how to use the macchina.io Remote Manager device agent.

There is also a [blog post](https://macchina.io/blog/?p=257) showing step-by-step instructions to connect a Raspberry Pi.

## About This Docker Image

This repository contains a [Dockerfile](Dockerfile) and related files for building and running
the [Remote Manager Gateway](https://github.com/my-devices/gateway) in a Docker container.

The image comes with a configuration file ([rmgateway.properties](rmgateway.properties)) that allows
configuring the most essential settings via environment variables.
The following environment variables are supported:

  - `DOMAIN`: The domain (UUID) of the device. Must be specified.
  - `HTTP_PORT`: The port number where the gateway's web server runs on. Defaults to 8080.
  - `REFLECTOR_URI`: The address of the macchina.io Remote Manager Server (*reflector*).
    Default: https://reflector.my-devices.net
  - `LOGPATH`: Path to the log file (defaults to `/var/log/WebTunnelAgent.log`); can be
    overridden to log to a different file (e.g. in a volume). Note: `LOGCHANNEL` must
    be set to `file` for the logfile to be written.
  - `LOGLEVEL`: Specifies the log level (`debug`, `information`, `notice`, `warning`,
    `error`, `critical`, `fatal`, `none`). Defaults to `information`.
  - `LOGCHANNEL`: Specifies where log messages go (`file` or `console`). Defaults to `console`.

## Prerequisites

  - Docker

## Building

```
$ docker build . -t macchina/rmgateway
```

## Running

The gateway server must be able to connect to the device's web server and/or any other services
that are to be forwarded. So when running the container, an appropriate network configuration
for the container must be set up. In many cases, just using the default `bridge` network
created by Docker will work. For example, assuming that we want to access a web server
running on host port 8080, and also the host's SSH port:

```
$ docker run -e DOMAIN=eac8b99b-1866-4ef4-8f57-76b655949c29 macchina/rmgateway
```

You must replace the value for `DOMAIN` with your specific domain ID which you can
find in the Remote Manager Server's web application.

Getting the network configuration right can be a bit tricky, as the *Gateway* running in
the Docker container must be able to connect to network services provided by other containers,
the host running Docker, or other hosts in the network (depending on your needs).

Please refer to the Docker documentation on [network containers](https://docs.docker.com/engine/tutorials/networkingcontainers/)
for more information.


## Configuration

The most important configuration settings can be set via environment variables (see above).
If you need to change other configuration options, edit [rmgateway.properties](rmgateway.properties)
and rebuild the Docker image.
