---
type: decision
title: Giữ SQLite (WAL) cho portal ACS — không chuyển Postgres/MySQL
status: accepted
date: 2026-08-07
links:
  - acs-architecture.md
  - ../systems/camera-ai-deploy-stack.md
  - ../domain/acs-capacity-bitrate.md
---
# Giữ SQLite cho ACS

Chốt với user 2026-08-07.

**Tải thực tế:** bảng `segments` 8 cam × 1440 row/ngày ≈ 690k row/60 ngày; ghi ~0.2 write/giây (segment + audit log); vài user đọc. SQLite WAL (đã bật sẵn trong `db.py`) dư sức — video nằm trên NAS filesystem, DB chỉ metadata.

**Khi nào mới cần Postgres:** nhiều instance portal chung 1 DB, hoặc SaaS multi-tenant (giai đoạn CMC S3). Migration path đã chứng minh: fork `camera-ai` đã chuyển SQLite→Postgres (pgvector), code tham khảo nằm bên đó.

**Bẫy:** file SQLite PHẢI nằm đĩa local — KHÔNG đặt trên NAS (NFS/SMB locking phá WAL → corrupt). NAS chỉ chứa video segment. Index `segments` theo `(camera, start)` cho query timeline.
