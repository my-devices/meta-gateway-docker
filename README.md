# The macchina.io REMOTE Gateway Docker Image

## About macchina.io REMOTE

[macchina.io REMOTE](https://macchina.io/remote) provides secure remote access to connected devices
via HTTP or other TCP-based protocols and applications such as secure shell (SSH) or
Virtual Network Computing (VNC). With macchina.io REMOTE, any network-connected device
running the macchina.io REMOTE Device Agent software can be securely accessed remotely over the internet
from browsers, mobile apps, desktop, server or cloud applications.

This even works if the device is behind a NAT router, firewall or proxy server.
The device becomes just another host on the internet, addressable via its own URL and
protected by the macchina.io REMOTE server against unauthorized or malicious access.
macchina.io REMOTE is a great solution for secure remote support and maintenance,
as well as for providing secure remote access to devices for end-users via web or
mobile apps.

Visit [macchina.io/remote](https://macchina.io/remote) to learn more and to register for a free account.
Specifically, see the [Getting Started](https://macchina.io/remote_signup.html) page and the
[Frequently Asked Questions](https://macchina.io/remote_faq.html) for
information on how to use the macchina.io REMOTE device agent.

There is also a [blog post](https://macchina.io/blog/?p=257) showing step-by-step instructions to connect a Raspberry Pi.

## About This Docker Image

This repository contains a [Dockerfile](Dockerfile) and related files for building and running
the [macchina.io REMOTE Gateway](https://github.com/my-devices/gateway) in a Docker container.

The image comes with a configuration file ([`rmgateway.properties`](rmgateway.properties)) that allows
configuring the most essential settings via environment variables.
The following environment variables are supported:

  - `DOMAIN`: The domain (UUID) of the device. Must be specified.
  - `HTTP_PORT`: The port number where the gateway's web server runs on. Defaults to 8080.
  - `REFLECTOR_URI`: The address of the macchina.io REMOTE Server (*reflector*).
    Default: https://remote.macchina.io
  - `LOGPATH`: Path to the log file (defaults to `/var/log/rmgateway.log`); can be
    overridden to log to a different file (e.g. in a volume). Note: `LOGCHANNEL` must
    be set to `file` for the logfile to be written.
  - `LOGLEVEL`: Specifies the log level (`debug`, `information`, `notice`, `warning`,
    `error`, `critical`, `fatal`, `none`). Defaults to `information`.
  - `LOGCHANNEL`: Specifies where log messages go (`file` or `console`). Defaults to `console`.
  - `CONNECT_TIMEOUT`: The timeout (in seconds) for connecting to the local (forwarded) server socket.
    Defaults to 10 seconds.
  - `LOCAL_TIMEOUT`: The timeout (in seconds) for local (forwarded) socket connections. Defaults to 7200 seconds or 2 hours.
  - `REMOTE_TIMEOUT`: The timeout (in seconds) for the WebTunnel connection to the macchina.io REMOTE server (*reflector*).
    Defaults to 300 seconds or 5 minutes.

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
created by Docker will work. The gateway server's web user interface runs on port 8080
(unless configured otherwise via the `HTTP_PORT` environment variable), so you may want
to map this port to make it accessible from the host system.

Furthermore, a volume needs to be created to store persistent data, mounted to
`/var/lib/rmgateway`. Otherwise, any device definitions created in the gateway will be
lost when the container is stopped.

```
$ docker run -e DOMAIN=eac8b99b-1866-4ef4-8f57-76b655949c29 -p 8080:8080 -v datavol:/var/lib/rmgateway macchina/rmgateway
```

You must replace the value for `DOMAIN` with your specific domain ID which you can
find in the macchina.io REMOTE Server's web application. It's also possible to leave
the DOMAIN environment variable unset. In this case, when logging in to the gateway,
it will obtain the default domain assigned to the user account from the macchina.io
REMOTE server.

Getting the network configuration right can be a bit tricky, as the *Gateway* running in
the Docker container must be able to connect to network services provided by other containers,
the host running Docker, or other hosts in the network (depending on your needs).

Please refer to the Docker documentation on [networking](https://docs.docker.com/engine/network/)
for more information.

This repository also contains an example [`docker-compose.yml`](docker-compose.yml) file.


## Configuration

The most important configuration settings can be set via environment variables (see above).
If you need to change other configuration options, edit [`rmgateway.properties`](rmgateway.properties)
and rebuild the Docker image, or use a volume to pass a custom `/etc/rmgateway.properties` to the
container.
