# 1C:Enterprise AI Skills Repository (Codex & Antigravity)

Kho tri thức, cẩm nang kiến trúc và bộ công cụ tự động hóa phát triển ứng dụng **1C:Enterprise 8.3**, được tối ưu hóa cho AI Coding Agents (OpenAI Codex, Google Antigravity, Claude Code, Cursor).

---

## Cấu trúc 4 Module Kỹ năng Chuẩn hóa

| Module | Tên Kỹ Năng | Vai trò cốt lõi |
|---|---|---|
| [`01-onec-core-developer/`](01-onec-core-developer/SKILL.md) | `onec-core-developer` | **Cẩm nang kiến trúc & Lập trình 1C toàn diện**: 24 bài học nền tảng, thiết kế ERP Mua - Bán - Kho - Tiền từ cấu hình rỗng (MIS), kiến trúc hệ thống 1C:Jet, các mẫu BSL chuẩn (Posting, Virtual Table, Form Client-Server), phân tích nghiệp vụ thực tế. |
| [`02-onec-code-quality/`](02-onec-code-quality/SKILL.md) | `onec-code-quality` | **Review code, Bắt lỗi Antipattern & Gỡ lỗi**: Bộ quy tắc thực chiến P/Q/F/V/T/X/E/M, chuẩn phát triển chính thức của 1C (#stdNNN), giao thức gỡ lỗi 7 bước, từ điển lỗi và tra cứu cú pháp Nga - Anh, các định nghĩa YAML antipattern. |
| [`03-onec-platform-toolkit/`](03-onec-platform-toolkit/SKILL.md) | `onec-platform-toolkit` | **Quản lý Phiên làm việc & Vòng đời Extension**: CLI `scripts/onec.py` an toàn, xuất chọn lọc metadata (`selective-export`), quản lý vòng đời Extension (`onec-extension-lifecycle`), kiểm tra tương thích và biên dịch `.cfe`. |
| [`04-onec-xml-automation/`](04-onec-xml-automation/SKILL.md) | `onec-xml-automation` | **Bộ 70+ Tool Skills thao tác XML & Designer**: Thao tác trực tiếp mã nguồn XML của Form, Metadata, External Data Processors (`epf-build`/`dump`), Báo cáo (`erf`, `skd`), Template mẫu in (`mxl`), Quản lý infobase (`db-*`), và Web client. |

---

## Tiêu chuẩn Agent Skills

Mỗi module đều có file `SKILL.md` với định dạng YAML frontmatter chuẩn:
```yaml
---
name: <tên_kỹ_năng>
description: Use when <điều_kiện_kích_hoạt>
---
```
Các agent như Codex và Antigravity có thể trực tiếp phát hiện và nạp các kỹ năng này khi xử lý các tác vụ liên quan đến 1C:Enterprise.
