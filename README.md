# JBS Docker Image

[![Docker Image](https://img.shields.io/docker/pulls/ssedov/jbs)](https://hub.docker.com/r/ssedov/jbs)
[![Docker Image Version](https://img.shields.io/docker/v/ssedov/jbs)](https://hub.docker.com/r/ssedov/jbs)

Docker image for [Joonte Billing System](https://joonte.com/) - a free billing system for hosting providers.

## Features

- Based on PHP 7.4 with Apache
- Includes all required PHP extensions and system packages
- Multi-arch support (amd64, arm64)
- Automatic updates with latest JBS version and commits

## Tags

- `latest`: Latest stable build
- `X.Y.Z-<commit>`: Versioned builds with specific JBS version and Git commit hash

## Usage

### Run with Docker

```bash
docker run -d \
  --name jbs \
  -p 80:80 \
  -v /path/to/jbs/data:/var/www/html/data \
  ssedov/jbs:latest
```

### Docker Compose

```yaml
services:
  jbs:
    image: ssedov/jbs:latest
    ports:
      - "80:80"
    volumes:
      - ./data:/var/www/html/data
    depends_on:
      - db
    restart: unless-stopped

  db:
    image: mysql:8
    environment:
      MYSQL_ROOT_PASSWORD: your_password
      MYSQL_DATABASE: jbs
    volumes:
      - mysql_data:/var/lib/mysql
    command:
      [
        "mysqld",
        "--character-set-server=utf8mb4",
        "--collation-server=utf8mb4_unicode_ci",
      ]
    restart: unless-stopped

volumes:
  mysql_data:
```

## Environment Variables

- None required - JBS is configured via web interface

## Volumes

- `/var/www/html/data`: Persistent storage for JBS data and configurations

## Ports

- `80`: HTTP port for web interface

## Build Information

This image is automatically built daily from the latest JBS repository commits. Version information is fetched from Joonte's public API.

## License

Free - as per Joonte Billing System license.

## Support

For JBS support, visit [joonte.com](https://joonte.com/).

For Docker image issues, create an issue in this repository.
