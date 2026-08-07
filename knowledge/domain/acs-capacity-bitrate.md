---
type: domain
title: Số liệu dung lượng & băng thông ACS (8 camera)
date: 2026-08-07
links:
  - ../decisions/acs-architecture.md
  - ../gotchas/h265-web-playback.md
---
# Dung lượng & băng thông ACS

- 1080p H.265 ~3 Mbps ≈ **32 GB/ngày/cam** → 60 ngày ≈ **2 TB/cam**; 8 cam ≈ **16 TB**.
- BOM "1TB/tháng/channel" khớp bitrate ~3.1 Mbps — **phải chốt bitrate camera trước khi ký**; camera để 5-8 Mbps sẽ vượt gói 1.6-2.6×.
- Băng thông site → storage: 8 cam × 3 Mbps ≈ **24 Mbps upload liên tục** (con số "băng thông tối thiểu mỗi camera" trả lời spec).
- **NAS 1TB hiện tại chỉ đủ demo** (~4 ngày × 8 cam, hoặc 1-2 cam vài tuần). Production cần ~16 TB.
- H.264 thay H.265 → +40% dung lượng, tính lại gói.
