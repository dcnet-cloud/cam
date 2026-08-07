---
type: decision
title: Kiến trúc ACS CCTV Cloud — portal thay VMS, bỏ AI, bỏ Teldrive
status: accepted
date: 2026-08-07
links:
  - ../../docs/specs/acs-cctv-cloud-spec.md
  - ../gotchas/h265-web-playback.md
  - ../domain/acs-capacity-bitrate.md
---
# Kiến trúc ACS CCTV Cloud

Nguồn: spec ACS ([docs/specs/acs-cctv-cloud-spec.md](../../docs/specs/acs-cctv-cloud-spec.md)), chốt 2026-08-07.

1. **Portal `fall_detection_web` thay VMS** — bỏ Ossia VMS trong BOM.
2. **Bỏ toàn bộ AI** (YOLO + AI Vision verification) — khách không cần, spec cấm nhận diện khuôn mặt/sinh trắc, đỡ CPU.
3. **Bỏ Teldrive** — đẩy data lên Telegram vi phạm yêu cầu "dữ liệu lưu tại Việt Nam".
4. **Giai đoạn hiện tại: ghi liên tục vào NAS local** (NFS/SMB do team system mount). Tương lai: CMC S3 (API tương thích boto3) — chưa làm.
5. **Kết nối camera qua RTSP**, không cần ONVIF. URL Hikvision:
   `rtsp://user:pass@<ip>:554/Streaming/Channels/101` (main) / `102` (sub).
6. Telegram alert giữ lại — tái dùng cho cảnh báo mất kết nối camera.
