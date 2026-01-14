# Nginx Reverse Proxy Configuration

Production-ready Nginx configurations for reverse proxy, load balancing, and SSL termination.

## Files

| File | Purpose |
|------|---------|
| `nginx.conf` | Main reverse proxy configuration |
| `ssl.conf` | SSL/TLS settings (optional include) |

## Features

- ✅ Reverse proxy to backend services
- ✅ WebSocket support
- ✅ Gzip compression
- ✅ Security headers
- ✅ SSL/TLS ready
- ✅ Health check endpoint

## Architecture

```
                    ┌──────────────┐
    :80/:443        │              │        :8080
  ──────────────▶   │    Nginx     │  ──────────────▶  Backend
    Internet        │   (Proxy)    │       Internal
                    │              │
                    └──────────────┘
```

## Quick Start

### With Docker Compose

The nginx service is already configured in the docker-compose example:

```bash
cd ../docker-compose
docker compose up -d nginx
```

### Standalone Testing

```bash
# Test configuration syntax
docker run --rm \
  -v $(pwd)/nginx.conf:/etc/nginx/conf.d/default.conf:ro \
  nginx:alpine nginx -t

# Run Nginx
docker run -d \
  -p 80:80 \
  -v $(pwd)/nginx.conf:/etc/nginx/conf.d/default.conf:ro \
  --name nginx-proxy \
  nginx:alpine
```

## Configuration Sections

### Upstream Block
Defines backend server(s) for load balancing:

```nginx
upstream app_backend {
    server web:8080;
    # Add more servers for load balancing:
    # server web2:8080;
    # server web3:8080;
}
```

### Proxy Headers
Essential headers for proper request forwarding:

```nginx
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
```

### WebSocket Support
Required for real-time applications:

```nginx
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
```

## SSL/TLS Setup

1. Obtain certificates (Let's Encrypt recommended)
2. Uncomment the SSL server block in `nginx.conf`
3. Update certificate paths

```bash
# Using certbot
certbot certonly --webroot -w /var/www/html -d example.com
```

## Common Customizations

### Rate Limiting
```nginx
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

location /api/ {
    limit_req zone=api burst=20 nodelay;
    proxy_pass http://app_backend;
}
```

### Caching
```nginx
proxy_cache_path /tmp/cache levels=1:2 keys_zone=app_cache:10m;

location /static/ {
    proxy_cache app_cache;
    proxy_cache_valid 200 1d;
    proxy_pass http://app_backend;
}
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| 502 Bad Gateway | Check if backend is running |
| 504 Gateway Timeout | Increase `proxy_read_timeout` |
| Mixed Content warnings | Ensure `X-Forwarded-Proto` is set |
