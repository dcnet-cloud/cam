# Spec: ACS CCTV Cloud Storage — Portal DCNET

> Cập nhật: 2026-08-07. Nguồn: bảng yêu cầu khách ACS + BOM v1.0 + thảo luận giải pháp.
> Repo triển khai: `dcnet-cloud/cam` (fork từ `camera-check`, portal `fall_detection_web` làm nền).

## 1. Yêu cầu khách hàng (ACS)

| Nhóm | Yêu cầu |
|---|---|
| Phạm vi | Dịch vụ kết nối, quản lý, lưu trữ Cloud cho hệ thống camera hiện hữu của ACS |
| Tương thích | Camera IP hiện có: Hikvision DS-2CD1123G0E-I(L) 2.8mm, DS-2CD2955G0 ISUHUN 5MP (1.05mm) — qua ONVIF Profile S **hoặc RTSP** |
| Đường truyền | Không bắt buộc dùng Internet của vendor; vendor phải nêu băng thông tối thiểu mỗi camera |
| Chất lượng | 2 lựa chọn 720p và 1080p, tối thiểu 15 fps; hỗ trợ H.264, ưu tiên H.265 |
| Thời gian lưu | **Ghi liên tục tối thiểu 60 ngày, tự ghi đè khi hết hạn** |
| Chức năng | Quản lý tập trung, xem trực tiếp, xem lại, tìm theo camera/thời gian, tải video theo phân quyền, cảnh báo mất kết nối |
| Truy cập | Web browser, tài khoản cá nhân, RBAC, MFA |
| Bảo mật | TLS ≥1.2 khi truyền + mã hóa lưu trữ; nhật ký đăng nhập/xem/tải/quản trị |
| Vị trí dữ liệu | Công bố vị trí DC, đơn vị vận hành, bên thứ ba; **ưu tiên lưu tại Việt Nam** |
| Dữ liệu cá nhân | Chỉ xử lý cho an ninh văn phòng; **không nhận diện khuôn mặt / chấm công / sinh trắc** |
| SLA | Uptime cam kết, hỗ trợ 24/7, thời gian phản hồi/khắc phục rõ ràng |
| Triển khai | Tích hợp cam hiện hữu, cấu hình, kiểm thử, hướng dẫn, tài liệu bàn giao. Không gồm phần cứng camera |
| Báo giá | Tách phí tích hợp một lần + thuê bao theo camera/tháng (720p, 1080p, 60 ngày); VAT, thời hạn HĐ, thanh toán |
| Kết thúc DV | ACS xuất được video cần thiết; vendor xóa dữ liệu và xác nhận |

BOM v1.0: Cloud VMS (bỏ — thay bằng portal này) + Cloud Storage 1TB/tháng/channel × 8 channel.

## 2. Quyết định kiến trúc đã chốt

1. **Portal này thay VMS** (bỏ Ossia VMS trong BOM).
2. **Bỏ toàn bộ AI** (YOLO + AI Vision verification) — khách không cần, spec cấm sinh trắc học, đỡ CPU.
3. **Bỏ Teldrive** — đẩy data lên Telegram vi phạm "dữ liệu lưu tại Việt Nam".
4. **Giai đoạn hiện tại: ghi liên tục vào NAS local** (đã có sẵn 1TB, team system phụ trách mount NFS/SMB).
5. **Tương lai: đẩy cloud object storage CMC S3** (API tương thích S3/boto3) — chưa làm giai đoạn này.
6. Kết nối camera: **RTSP** (spec cho phép RTSP hoặc ONVIF; không cần ONVIF).
   URL Hikvision: `rtsp://user:pass@<ip>:554/Streaming/Channels/101` (main) / `102` (sub).

## 3. Đánh giá repo hiện tại vs yêu cầu

### Có sẵn, tận dụng
- UI dark theme → đổi logo/brand (`brand.config.json`)
- Quản lý camera tập trung (CRUD, snapshot, config), multi-cam mỗi cam 1 thread
- Xem live (MJPEG `/api/camera/video`) — đủ demo; nâng WebRTC/HLS qua go2rtc khi nhiều user xem đồng thời
- Auth JWT + bcrypt, bảng `users` → làm móng RBAC
- Hạ tầng ffmpeg copy-codec, go2rtc, config 3 tầng (env > SQLite > default)
- Telegram alert → tái dùng cho cảnh báo mất kết nối

### Phải xây mới
| # | Hạng mục | Ghi chú | Ước lượng |
|---|---|---|---|
| 1 | **Recorder ghi liên tục** | ffmpeg segment 60s copy-codec → NAS mount, mỗi cam 1 process, restart + alert khi chết | 2-3 ngày |
| 2 | **Index + retention** | Bảng `segments` (camera, start, duration, path); cron xóa file cũ nhất khi đầy / quá 60 ngày | (gộp #1) |
| 3 | **Playback timeline** | Query segments theo cam + khoảng thời gian, phát tuần tự; UI thanh timeline là phần nặng nhất | 1-2 tuần |
| 4 | **Download theo khoảng** | 1 segment trả thẳng; nhiều segment ffmpeg concat | 1 ngày |
| 5 | **RBAC** | Thêm cột `role` vào `users`, decorator phân quyền (admin/viewer, quyền tải video) | ~vài ngày |
| 6 | **MFA** | TOTP (pyotp) | (gộp #5) |
| 7 | **Audit log** | Bảng `audit_log`: login, xem, tải, thao tác quản trị | (gộp #5) |
| 8 | **Cảnh báo mất kết nối** | Hook vào recorder/monitor, Telegram sẵn | nhẹ |

### Ngoài code
- TLS: reverse proxy (nginx/caddy). Mã hóa at-rest: disk encryption trên NAS (team system).
- SLA / báo giá / vị trí DC: vận hành + thương mại.

## 4. Số liệu dung lượng & băng thông

- 1080p H.265 ~3 Mbps ≈ **32 GB/ngày/cam** → 60 ngày ≈ **2 TB/cam**; 8 cam ≈ **16 TB**.
- BOM "1TB/tháng/channel" khớp bitrate ~3.1 Mbps — **phải chốt bitrate camera trước khi ký** (5-8 Mbps sẽ vượt gói 1.6-2.6×).
- Băng thông site → storage: 8 cam × 3 Mbps ≈ **24 Mbps** upload liên tục (con số "băng thông tối thiểu" trả lời spec).
- **NAS 1TB hiện tại: chỉ đủ demo** (~4 ngày × 8 cam, hoặc 1-2 cam vài tuần). Production cần ~16 TB.

## 5. Bẫy kỹ thuật H.265 trên web

Chrome chỉ decode HEVC khi có hardware; hls.js/MSE không chơi H.265 ổn định.
→ Chào **H.264 mặc định** cho playback web mượt (spec cho phép), H.265 ghi được nhưng note giới hạn xem trên web. H.264 tốn ~+40% dung lượng → tính lại gói.

## 6. Kế hoạch demo với khách

Khách có cam sẵn — bật RTSP là demo live được ngay (portal hiện tại đủ). Checklist gửi khách:
1. Bật RTSP trên cam (port 554, thường bật sẵn)
2. Cấp user/password camera (không dùng admin chính)
3. Đường mạng: server portal reach được IP cam (cùng LAN hoặc VPN) — điểm hay tắc nhất
4. Cam không ở chế độ "Hik-Connect only"

Demo "xem lại" cần build tối thiểu #1 + list segment theo cam/giờ trước (~2-4 ngày), chưa cần timeline đẹp.
