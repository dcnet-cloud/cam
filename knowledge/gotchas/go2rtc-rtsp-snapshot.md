---
type: gotcha
title: go2rtc / RTSP — các bẫy đã trả giá
date: 2026-08-07
links:
  - ../decisions/acs-architecture.md
---
# go2rtc / RTSP — bẫy đã gặp trong fall_detection_web

- **Snapshot priority:** go2rtc frame URL (`/api/frame.jpeg?src={camera}`) trước → RTSP direct fallback. RTSP fallback PHẢI là RTSP của chính camera (IP cam), **không phải** RTSP của go2rtc.
- **Track fragment 404:** URL go2rtc dạng `src#video=...#audio=...` phải strip phần `#...` trước khi gọi frame API, nếu không go2rtc trả 404 (fix tại commit `ac8bf25`).
- **Audio không tương thích gây 500:** stream go2rtc phải exclude audio codec không tương thích, nếu không record trả 500 (commit `989805b`).
- **Ghi clip copy-codec** (`-c copy`) để không tốn CPU — chỉ transcode khi codec không tương thích (fallback FFmpeg, commit `03719f7`).
