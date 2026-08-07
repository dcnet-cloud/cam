---
type: system
title: Tận dụng deploy stack từ repo camera-ai (POC ngưng, live camera-test.dcnet.vn)
date: 2026-08-07
links:
  - ../decisions/acs-architecture.md
---
# Deploy stack camera-ai — nguồn tận dụng cho ACS

Repo: `/Users/vovanduc/Code/dcnet/camera-ai` (POC ngưng 2026-07-01). Prod: VM `163.227.121.206` (`ssh camera`), domain `camera-test.dcnet.vn`. **Chỉ tận dụng tầng deploy; code app không lấy** (FDW bên đó là fork Postgres/pgvector + MQTT/counting/ReID — ACS bỏ AI, `cam` vẫn SQLite).

## Lấy được

- `docker-compose.prod.yml` — khung: no-publish-port, healthcheck, `restart: unless-stopped`, external network `dcnet-shared` (Caddy reach qua đó). Cắt: postgres, event_collector, reid_worker, MQTT env.
- `docs/ops/Caddyfile.post-flip.draft` — TLS auto (đáp ứng ACS "TLS ≥1.2"), `forward_auth fall_detection_web:8090 { uri /api/auth/check; copy_headers Cookie }` gate `/live/*` → `reverse_proxy go2rtc:1984` (kèm WS Upgrade headers).
- `go2rtc.yaml` — pattern stream chính + substream 720p@15 riêng; map Hikvision `/Streaming/Channels/101` (main) / `102` (sub).
- `.env.example` — quy ước secrets (DB_PASSWORD/SECRET_KEY/JWT_SECRET_KEY/CAM_*).
- `docs/ops/2026-06-26-phase4-cutover-runbook.md` — O-checklist deploy: `nc -zv <cam-ip> 554` (RTSP reach), pin version go2rtc (không dùng `latest`), backup cron, check RAM/disk, bẫy `go2rtc_src` rỗng → live "stream not found".
- `fall_detection_web/Dockerfile` — identical với repo `cam` (đã sync sẵn).

## Gap khi mang qua

1. `cam` **chưa có** `/api/auth/check` — camera-ai đã implement cho forward_auth; phải port (~vài chục dòng, mẩu code duy nhất đáng lấy).
2. NAS mount ghi 60 ngày: bên kia dùng docker volume; ACS cần bind mount NFS/SMB cho recorder.
3. VM camera-test.dcnet.vn còn chạy stack POC cũ — chốt đè hay chạy song song trước khi deploy demo ACS. Mosquitto 8883 mượn cert Caddy (cert-sync) — đừng phá nếu chạy song song.
