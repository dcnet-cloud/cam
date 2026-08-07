# Session Progress Log

## Current State

**Last Updated:** 2026-08-07 (chiều)
**Active Feature:** (feat-000 DONE; kế tiếp: UI tuning theo user, rồi feat-005 RBAC+audit)

## Status

### What's Done

- [x] Spec ACS CCTV Cloud chốt: [docs/specs/acs-cctv-cloud-spec.md](docs/specs/acs-cctv-cloud-spec.md) (commit 1ba79a1)
- [x] Bootstrap harness dcnet-workflow: feature_list.json (6 feature ACS), init.sh, knowledge/ (seed 4 concept)
- [x] `./init.sh` xanh (syntax check 2 app)
- [x] **feat-000 DONE**: portal ACS live tại https://camera-test.dcnet.vn (flip từ stack POC; xem evidence trong feature_list.json + runbook knowledge/runbooks/acs-portal-deploy.md). Admin mặc định admin/admin — user PHẢI đổi.
- [x] Cam Axis DCNET (NAT 115.79.47.96) vào portal: go2rtc streams cam_dcnet + cam_dcnet_sub (frame JPEG verify OK), camera "DCNET Axis" ghi thẳng SQLite settings (go2rtc_src=cam_dcnet, go2rtc_url=https://camera-test.dcnet.vn/live), monitor auto-start sạch lỗi. Lưu ý: YOLO đang chạy trên cam này (AI chưa gỡ — feat-001).

### What's In Progress

- (chưa bắt đầu feature nào)

### What's Next

1. UI tuning trên bản live (yêu cầu user 2026-08-07) → sau đó hứng thiết bị khách, thêm cam vào go2rtc.yaml + /cameras (xem runbook)
2. feat-005: RBAC + audit log — ƯU TIÊN NHANH theo user 2026-08-07 (~1.5 ngày); MFA tách ra feat-007 để sau
3. feat-001: Gỡ AI + Teldrive khỏi portal ACS
4. feat-002: Recorder ghi liên tục + index + retention (mở khóa demo "xem lại")

DB: chốt giữ SQLite WAL (knowledge/decisions/sqlite-for-acs.md) — file DB đĩa local, KHÔNG đặt NAS.

## Blockers / Risks

- [ ] Bitrate camera ACS chưa chốt — 5-8 Mbps vượt gói BOM 1.6-2.6× (thương mại, chốt trước khi ký)
- [ ] NAS 1TB chỉ đủ demo; production cần ~16 TB (team system)
- [ ] Demo live cần khách bật RTSP + đường mạng portal ↔ camera (điểm hay tắc nhất)

## Decisions Made

- Xem `knowledge/decisions/acs-architecture.md` (portal thay VMS, bỏ AI, bỏ Teldrive, NAS local, RTSP)

## Notes for Next Session

- Đọc `knowledge/index.md` trước khi làm feature ACS — có gotchas go2rtc/RTSP + H.265 và số liệu dung lượng.
- `fall_detection_web` hiện vẫn còn nguyên AI + Teldrive — feat-001 mới gỡ.
- `simple_ai_vision` (v1.4.16) không liên quan phase ACS, không đụng.
