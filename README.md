# Peekaping Dockerfile for Choreo

# Version

0.0.46

# Releases


### Added

### Changed

### Fixed

## Raw Commit List

- test: add mock for task info retrieval in processMonitor test (Thanks @yevhen.piotrovskyi) 9ce4232
- docs: update README.md to enhance clarity and detail on Peekaping's features and advantages as an alternative to Uptime Kuma (Thanks @yevhen.piotrovskyi) 6232a51
- drop healthcheck task if archived and older than ((mon.Timeout + mon.RetryInterval) * mon.MaxRetries) seconds (Thanks @pgulbinowicz) ab1e838
- add compose for testing stale duplicate healthcheck (Thanks @pgulbinowicz) 428dae2
- add Dockerfile for not-responding test http server (Thanks @pgulbinowicz) 105bfde
- add not-responding test http server (Thanks @pgulbinowicz) 37e59ee
- fix: update token verification to use request context for improved reliability (Thanks @yevhen.piotrovskyi) 2953116
- Re-Enabling custom Message starts and adding rich embeds to forum posts (Thanks @justinjakull) 263c2b4
- Add embeds and rich messages to the discord notifications (Thanks @justinjakull) fcabfba
- Add additional fields to the bindings (icon, color, response_time, ping, time) (Thanks @justinjakull) 4737fea

Release Statistics
- **15** commits since 0.0.45
- **3** contributors

Contributors
Thanks to: @justinjakull @pgulbinowicz @yevhen.piotrovskyi 

## Docker Images

### GitHub Container Registry (GHCR)
- UI: `ghcr.io/0xfurai/peekaping-web:0.0.46` / `ghcr.io/0xfurai/peekaping-web:latest`
- API: `ghcr.io/0xfurai/peekaping-api:0.0.46` / `ghcr.io/0xfurai/peekaping-api:latest`
- Worker: `ghcr.io/0xfurai/peekaping-worker:0.0.46` / `ghcr.io/0xfurai/peekaping-worker:latest`
- Producer: `ghcr.io/0xfurai/peekaping-producer:0.0.46` / `ghcr.io/0xfurai/peekaping-producer:latest`
- Ingester: `ghcr.io/0xfurai/peekaping-ingester:0.0.46` / `ghcr.io/0xfurai/peekaping-ingester:latest`
- Migrate: `ghcr.io/0xfurai/peekaping-migrate:0.0.46` / `ghcr.io/0xfurai/peekaping-migrate:latest`

### Bundle Containers (GHCR)
- SQLite Bundle: `ghcr.io/0xfurai/peekaping-bundle-sqlite:0.0.46` / `ghcr.io/0xfurai/peekaping-bundle-sqlite:latest`
- MongoDB Bundle: `ghcr.io/0xfurai/peekaping-bundle-mongo:0.0.46` / `ghcr.io/0xfurai/peekaping-bundle-mongo:latest`
- PostgreSQL Bundle: `ghcr.io/0xfurai/peekaping-bundle-postgres:0.0.46` / `ghcr.io/0xfurai/peekaping-bundle-postgres:latest`

### Docker Hub
- UI: `0xfurai/peekaping-web:0.0.46` / `0xfurai/peekaping-web:latest`
- API: `0xfurai/peekaping-api:0.0.46` / `0xfurai/peekaping-api:latest`
- Worker: `0xfurai/peekaping-worker:0.0.46` / `0xfurai/peekaping-worker:latest`
- Producer: `0xfurai/peekaping-producer:0.0.46` / `0xfurai/peekaping-producer:latest`
- Ingester: `0xfurai/peekaping-ingester:0.0.46` / `0xfurai/peekaping-ingester:latest`
- Migrate: `0xfurai/peekaping-migrate:0.0.46` / `0xfurai/peekaping-migrate:latest`

### Bundle Containers (Docker Hub)
- SQLite Bundle: `0xfurai/peekaping-bundle-sqlite:0.0.46` / `0xfurai/peekaping-bundle-sqlite:latest`
- MongoDB Bundle: `0xfurai/peekaping-bundle-mongo:0.0.46` / `0xfurai/peekaping-bundle-mongo:latest`
- PostgreSQL Bundle: `0xfurai/peekaping-bundle-postgres:0.0.46` / `0xfurai/peekaping-bundle-postgres:latest`
