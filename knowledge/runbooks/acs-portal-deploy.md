---
type: runbook
title: Deploy / update / rollback portal ACS trên VM camera-test
date: 2026-08-07
links:
  - ../systems/camera-ai-deploy-stack.md
  - ../decisions/acs-architecture.md
---
# Deploy portal ACS — camera-test.dcnet.vn

VM `163.227.121.206` (`ssh camera`). Stack: `/opt/cam-acs` (project `cam-acs`: `fdw-acs` + `go2rtc-acs`). Caddy nằm ở stack cũ `/opt/camera` (container `camera-caddy-1`), reach qua network `dcnet-shared`. **Flip 2026-08-07:** domain trỏ portal ACS; stack POC camera-ai vẫn chạy nội bộ, hết public.

## Update code (VM không có git access — ship bằng git archive)

```bash
git archive HEAD | ssh camera 'tar -x -C /opt/cam-acs'
ssh camera 'cd /opt/cam-acs && docker compose -f docker-compose.prod.yml up -d --build'
```

## Thêm camera khách

1. Check RTSP reach từ VM trước: `nc -zv <ip-cam> 554`
2. Sửa `/opt/cam-acs/go2rtc.yaml` + creds trong `/opt/cam-acs/.env`. Path RTSP: Hikvision `/Streaming/Channels/101|102`; Axis `/axis-media/media.amp` (sub: `?resolution=1280x720&fps=15`)
3. **`docker compose -f docker-compose.prod.yml up -d --force-recreate go2rtc-acs`** — BẪY: `restart` KHÔNG nạp lại env_file (container giữ env lúc create → rtsp `changeme:changeme` + `${VAR}` không expand); phải force-recreate
4. Verify frame từ container fdw: `docker exec cam-acs-fdw-acs-1 python -c "import urllib.request as u; d=u.urlopen('http://go2rtc-acs:1984/api/frame.jpeg?src=<stream>',timeout=20).read(); print(len(d), d[:2]==b'\xff\xd8')"`
5. UI `/cameras`: thêm cam với `go2rtc_src` = tên stream (bẫy: rỗng → live "stream not found"). `/settings`: `go2rtc_url` = `https://camera-test.dcnet.vn/live`

Hiện trạng 2026-08-07: cam Axis DCNET (NAT 115.79.47.96:554, user root, creds copy từ /opt/camera-ai/.env) → streams `cam_dcnet` (main) + `cam_dcnet_sub` (720p@15), cả 2 verify JPEG OK.

## Rollback về stack POC cũ

```bash
ssh camera 'cd /opt/camera && cp Caddyfile.pre-acs-flip-20260807-* Caddyfile && docker exec camera-caddy-1 caddy reload --config /etc/caddy/Caddyfile'
```

## Bẫy

- **forward_auth phải strip header WS**: thêm `header_up -Upgrade` + `header_up -Connection` trong block `forward_auth` — không thì sub-request auth mang `Upgrade: websocket` sang FastAPI → 403 → Caddy chặn WS → live spin mãi. (CORS manifest.json alexxit.github.io trong console là red herring, kệ.)
- **`/live/*` phải dùng `handle_path` (KHÔNG phải `handle`)** — `handle` giữ nguyên prefix, go2rtc nhận `/live/stream.html` → 404 → live view đen thui dù stream chạy ngon. `handle_path` tự strip `/live`. Đã sửa 2026-08-07.
- **`caddy reload` KHÔNG ăn trên VM này** — container caddy tắt admin API (port 2019 refused) nên reload fail im lặng, config cũ vẫn chạy trong RAM. Đổi Caddyfile xong PHẢI `docker restart camera-caddy-1` (downtime ~3-5 giây). Verify bằng probe: `curl "https://camera-test.dcnet.vn/login?probe=x"` rồi grep marker trong `docker logs cam-acs-fdw-acs-1` — đừng tin HTTP 200 suông (2 app cùng title).

- Tên service PHẢI khác `fall_detection_web` (stack cũ chiếm alias đó trên `dcnet-shared` — trùng = DNS round-robin trỏ nhầm).
- Mosquitto 8883 mượn cert Caddy của domain này (cert-sync) — KHÔNG xóa site block, không đổi domain.
- `.env` chứa `JWT_SECRET` (openssl rand) — đổi secret = mọi session logout.
- SQLite nằm trong volume `cam-acs_fdw_data` (local disk, đúng quyết định sqlite-for-acs).
- Verify sau deploy: `curl -s -o /dev/null -w "%{http_code}" https://camera-test.dcnet.vn/login` → 200; `/live/` chưa login → 401.
