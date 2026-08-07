# Session Progress Log

## Current State

**Last Updated:** 2026-08-07
**Active Feature:** (chưa có — tất cả not-started)

## Status

### What's Done

- [x] Spec ACS CCTV Cloud chốt: [docs/specs/acs-cctv-cloud-spec.md](docs/specs/acs-cctv-cloud-spec.md) (commit 1ba79a1)
- [x] Bootstrap harness dcnet-workflow: feature_list.json (6 feature ACS), init.sh, knowledge/ (seed 4 concept)
- [x] `./init.sh` xanh (syntax check 2 app)

### What's In Progress

- (chưa bắt đầu feature nào)

### What's Next

1. feat-000: Deploy stack port từ camera-ai (mở khóa demo live — xem knowledge/systems/camera-ai-deploy-stack.md)
2. feat-001: Gỡ AI + Teldrive khỏi portal ACS
3. feat-002: Recorder ghi liên tục + index + retention (mở khóa demo "xem lại")
4. feat-005 (RBAC+MFA+audit) build nhanh được ~2.5-3 ngày trên auth.py sẵn có — đã chốt hướng với user 2026-08-07

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
