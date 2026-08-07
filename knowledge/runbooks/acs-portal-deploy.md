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

1. Sửa `/opt/cam-acs/go2rtc.yaml` (pattern Hikvision trong file) + `CAM_USER/CAM_PASS` trong `/opt/cam-acs/.env`
2. `ssh camera 'cd /opt/cam-acs && docker compose -f docker-compose.prod.yml restart go2rtc-acs'`
3. UI `/cameras`: thêm cam với `go2rtc_src` = tên stream (bẫy: rỗng → live "stream not found")
4. Check RTSP reach từ VM: `nc -zv <ip-cam> 554`

## Rollback về stack POC cũ

```bash
ssh camera 'cd /opt/camera && cp Caddyfile.pre-acs-flip-20260807-* Caddyfile && docker exec camera-caddy-1 caddy reload --config /etc/caddy/Caddyfile'
```

## Bẫy

- Tên service PHẢI khác `fall_detection_web` (stack cũ chiếm alias đó trên `dcnet-shared` — trùng = DNS round-robin trỏ nhầm).
- Mosquitto 8883 mượn cert Caddy của domain này (cert-sync) — KHÔNG xóa site block, không đổi domain.
- `.env` chứa `JWT_SECRET` (openssl rand) — đổi secret = mọi session logout.
- SQLite nằm trong volume `cam-acs_fdw_data` (local disk, đúng quyết định sqlite-for-acs).
- Verify sau deploy: `curl -s -o /dev/null -w "%{http_code}" https://camera-test.dcnet.vn/login` → 200; `/live/` chưa login → 401.
