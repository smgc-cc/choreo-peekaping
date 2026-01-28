# Peekaping Dockerfile for Choreo

# Version

0.0.45

# Releases

### Added
- Kubernetes config files

### Changed

### Fixed
- forms reset after tab change

## Raw Commit List

- feat: add support for optional TLS secret in ingress configuration (Thanks @yevhen.piotrovskyi) a48826b
- fix: disable refetching on window focus in useCheckCustomDomain hook to improve performance (Thanks @yevhen.piotrovskyi) cc52d18
- feat: add SEO content section with toggle functionality to enhance user engagement and improve visibility (Thanks @yevhen.piotrovskyi) d704729
- fixed hardcoded istio selector and hardcoded service ports (Thanks @razorsk8jz) 18f1b34
- changes (Thanks @razorsk8jz) 79f3c1a
- updated ingress with routes (Thanks @razorsk8jz) d6e027c
- changes (Thanks @razorsk8jz) 9498bf3
- changes (Thanks @razorsk8jz) fc1be48
- added existing secret compatibility (Thanks @razorsk8jz) 76e7cb0
- changes (Thanks @razorsk8jz) f8d6c85
- changes (Thanks @razorsk8jz) 27e3439
- chore: remove GitHub Actions workflow for deploying documentation (Thanks @0xfurai) d22eba5
- feat: add Google Analytics tracking configuration to docs (Thanks @0xfurai) 46ce220

Release Statistics
- **15** commits since 0.0.44
- **3** contributors

Contributors
Thanks to: @0xfurai @razorsk8jz @yevhen.piotrovskyi 

## Docker Images

### GitHub Container Registry (GHCR)
- UI: `ghcr.io/0xfurai/peekaping-web:0.0.45` / `ghcr.io/0xfurai/peekaping-web:latest`
- API: `ghcr.io/0xfurai/peekaping-api:0.0.45` / `ghcr.io/0xfurai/peekaping-api:latest`
- Worker: `ghcr.io/0xfurai/peekaping-worker:0.0.45` / `ghcr.io/0xfurai/peekaping-worker:latest`
- Producer: `ghcr.io/0xfurai/peekaping-producer:0.0.45` / `ghcr.io/0xfurai/peekaping-producer:latest`
- Ingester: `ghcr.io/0xfurai/peekaping-ingester:0.0.45` / `ghcr.io/0xfurai/peekaping-ingester:latest`
- Migrate: `ghcr.io/0xfurai/peekaping-migrate:0.0.45` / `ghcr.io/0xfurai/peekaping-migrate:latest`

### Bundle Containers (GHCR)
- SQLite Bundle: `ghcr.io/0xfurai/peekaping-bundle-sqlite:0.0.45` / `ghcr.io/0xfurai/peekaping-bundle-sqlite:latest`
- MongoDB Bundle: `ghcr.io/0xfurai/peekaping-bundle-mongo:0.0.45` / `ghcr.io/0xfurai/peekaping-bundle-mongo:latest`
- PostgreSQL Bundle: `ghcr.io/0xfurai/peekaping-bundle-postgres:0.0.45` / `ghcr.io/0xfurai/peekaping-bundle-postgres:latest`

### Docker Hub
- UI: `0xfurai/peekaping-web:0.0.45` / `0xfurai/peekaping-web:latest`
- API: `0xfurai/peekaping-api:0.0.45` / `0xfurai/peekaping-api:latest`
- Worker: `0xfurai/peekaping-worker:0.0.45` / `0xfurai/peekaping-worker:latest`
- Producer: `0xfurai/peekaping-producer:0.0.45` / `0xfurai/peekaping-producer:latest`
- Ingester: `0xfurai/peekaping-ingester:0.0.45` / `0xfurai/peekaping-ingester:latest`
- Migrate: `0xfurai/peekaping-migrate:0.0.45` / `0xfurai/peekaping-migrate:latest`

### Bundle Containers (Docker Hub)
- SQLite Bundle: `0xfurai/peekaping-bundle-sqlite:0.0.45` / `0xfurai/peekaping-bundle-sqlite:latest`
- MongoDB Bundle: `0xfurai/peekaping-bundle-mongo:0.0.45` / `0xfurai/peekaping-bundle-mongo:latest`
- PostgreSQL Bundle: `0xfurai/peekaping-bundle-postgres:0.0.45` / `0xfurai/peekaping-bundle-postgres:latest`
