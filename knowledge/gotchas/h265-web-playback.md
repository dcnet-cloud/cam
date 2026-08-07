---
type: gotcha
title: H.265 không xem được ổn định trên web browser
date: 2026-08-07
links:
  - ../decisions/acs-architecture.md
  - ../domain/acs-capacity-bitrate.md
---
# H.265 trên web — bẫy

Chrome chỉ decode HEVC khi có hardware decoder; hls.js/MSE không chơi H.265 ổn định.

**Hệ quả cho ACS:** chào **H.264 mặc định** cho playback web mượt (spec cho phép "hỗ trợ H.264, ưu tiên H.265"). H.265 ghi được nhưng phải note giới hạn xem trên web.

**Bẫy chi phí kéo theo:** H.264 tốn ~+40% dung lượng so với H.265 → phải tính lại gói lưu trữ khi báo giá.
