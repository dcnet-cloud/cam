---
type: log
title: Knowledge change log
---
# Knowledge change log

<!-- YYYY-MM-DD — <type>/<concept> — thêm|sửa: mô tả -->
- 2026-08-07 — decisions/acs-architecture — thêm: quyết định kiến trúc ACS (portal thay VMS, bỏ AI/Teldrive, NAS local, RTSP)
- 2026-08-07 — gotchas/h265-web-playback — thêm: H.265 không xem ổn trên web, chào H.264 mặc định (+40% dung lượng)
- 2026-08-07 — gotchas/go2rtc-rtsp-snapshot — thêm: bẫy go2rtc/RTSP đã trả giá (track fragment 404, audio 500, copy-codec)
- 2026-08-07 — domain/acs-capacity-bitrate — thêm: số liệu dung lượng/băng thông ACS, NAS 1TB chỉ đủ demo
- 2026-08-07 — systems/camera-ai-deploy-stack — thêm: khảo sát repo camera-ai, tầng deploy tận dụng được (compose/Caddy/go2rtc/runbook) + 3 gap
- 2026-08-07 — decisions/sqlite-for-acs — thêm: chốt giữ SQLite WAL cho ACS; bẫy KHÔNG đặt file DB trên NAS
