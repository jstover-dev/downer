# Downer

docker-compose file for running media download and management containers behind a VPN

Mullvad has been configured as the VPN provider, but `gluetun` supports many others.
To configure a different provider, edit `docker-compose.yml` and update the relevant settings for the `gluetun` service.
See the [gluetun wiki](https://github.com/qdm12/gluetun/wiki) for details.


## Services

| Name         | Description               | Links                                                                                               |  Port  |
|:-------------|:--------------------------|:----------------------------------------------------------------------------------------------------|:------:|
| gluetun      | VPN Remote Control        | https://github.com/qdm12/gluetun <br>https://hub.docker.com/r/qmcgaw/gluetun                        | `8000` |
| gluetun      | VPN HTTP/S Proxy          | https://github.com/qdm12/gluetun <br>https://hub.docker.com/r/qmcgaw/gluetun                        | `8888` |
| Jackett      | Tracker API interface     | https://github.com/Jackett/Jackett <br>https://hub.docker.com/r/linuxserver/jackett/                | `9117` |
| Transmission | Torrent client            | https://github.com/transmission/transmission <br>https://hub.docker.com/r/linuxserver/transmission/ | `9091` |
| SABnzbd      | Usenet binary downloader  | https://github.com/sabnzbd/sabnzbd <br>https://hub.docker.com/r/sabnzbd/sabnzbd                     | `8080` |
| sonarr       | TV grabber                | https://github.com/Sonarr/Sonarr <br>https://hub.docker.com/r/linuxserver/sonarr                    | `8989` |
| radarr       | Movie grabber             | https://github.com/Radarr/Radarr <br>https://hub.docker.com/r/linuxserver/radarr                    | `7878` |


## Configuration

Copy the example to create a new `.env` file and edit as required
```shell
cp .env.example .env
vim .env
```

Example `.env`:
```shell
# .env

# # Configure timezone
TZ=Etc/UTC

# User to use inside containers. Match this to the media owner on the host
DOCKER_UID=1000
DOCKER_GID=1000

# Comma-separated list of subnets that containers are allowed to access, including the local router/gateway
VPN_OUTBOUND_SUBNETS=10.0.0.0/8,192.168.0.0/16,172.16.0.0/12
# Alternatively, if access to other network hosts is not required, then limit access to the gateway only
#VPN_OUTBOUND_SUBNETS=10.0.0.1/32

# Mullvad Wireguard settings. Get these from a config file generated at mullvad.net
WIREGUARD_PRIVATE_KEY=
WIREGUARD_ADDRESSES=

# Use Mullvad DNS server
DNS_ADDRESS=194.242.2.2

# VPN exit server country
VPN_COUNTRY=Switzerland

# Create a forwarded port on mullvad.net and use it for Transmission
TRANSMISSION_LISTEN_PORT=51413

# Bind mounts for downloads
TRANSMISSION_DOWNLOAD_DIR=/storage/media/downloads/
SABNZBD_DOWNLOAD_DIR=/storage/media/downloads

# Bind mounts for media files. This should be a parent containing both downloads and final media
RADARR_MEDIA_DIR=/storage/media
SONARR_STORAGE_DIR=/storage/media
```

## Usage

```shell
# Start the stack and detach from the current console
docker-compose up -d

# View the logs of a running stack (use -f to follow the logs live)
docker-compose logs

# Stop the running stack
docker-compose down

# Reset all containers (this will clear all configuration)
docker-compose down -v

# Start a terminal inside a specific container (e.g. transmission)
docker-compose exec -it transmission sh
```
