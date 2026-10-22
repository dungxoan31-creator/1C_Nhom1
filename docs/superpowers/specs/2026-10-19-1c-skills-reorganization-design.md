# Thiết Kế Tái Cấu Trúc Kho Kỹ Năng 1C:Enterprise (1C Skills Repository Reorganization)

**Ngày lập:** 19/10/2026  
**Mục tiêu:** Dọn sạch toàn bộ dữ liệu rác, chuẩn hóa cấu trúc thư mục, tổ chức lại kho tri thức và công cụ 1C:Enterprise thành 4 module độc lập, chuẩn hóa theo Agent Skills Specification (`agentskills.io/specification`) tối ưu cho OpenAI Codex và Antigravity.

---

## 1. Bối cảnh & Hiện trạng

Thư mục `C:\Users\Dung\Documents\VSF TEST\Skill` hiện đang bị xáo trộn giữa:
1. **Tri thức phát triển 1C (1C Vietnam)**: Giáo trình 24 bài, kiến trúc MIS (tự xây hệ thống từ cấu hình rỗng), kiến trúc 1C:Jet, các ca nghiệp vụ thực tế, quy tắc review code và gỡ lỗi. Các file tài liệu đang bị phân tán ở thư mục gốc, làm gãy các liên kết `references/...` trong `SKILL.md`.
2. **`cc-1c-skills-main`**: Bộ 70+ tool skills XML cho Claude Code/Codex. Bị lồng 2 tầng thư mục và thư mục `tests/` chứa tới 8.848 files rác (33.77 MB) gồm allure logs, video test, fixture test.
3. **`1C-Enterprise-Agent-Toolkit-main`**: Bộ toolkit Python cho session và extension 1C. Bị lồng 2 tầng thư mục, chứa file boilerplate CI/CD của GitHub.
4. **`1c-ai-assistant-main`**: Dự án backend Python dang dở (Sprint 1) chứa `uv.lock` (589 KB), `pyproject.toml`, `alembic.ini`, docker, 300+ pytest tests. Chỉ có thư mục `knowledge-base/` (chứa các quy tắc YAML về Antipatterns và Standards) là có giá trị.

---

## 2. Danh mục Thành phần & Phân loại Xử lý

### 2.1. Thành phần cần loại bỏ ("Rác")
- Thư mục `cc-1c-skills-main\cc-1c-skills-main\tests\` (8.848 files test slop, allure, hang tests).
- Thư mục `1c-ai-assistant-main\1c-ai-assistant-main\` ngoại trừ `knowledge-base/` (xóa `packages/`, `migrations/`, `docker/`, `tests/`, `uv.lock`, `pyproject.toml`, `alembic.ini`).
- Thư mục `1C-Enterprise-Agent-Toolkit-main\1C-Enterprise-Agent-Toolkit-main\tests\` và các file GitHub boilerplate (`.github/`, `.gitattributes`, `.gitignore`, `CHANGELOG.md`, `CODE_OF_CONDUCT*.md`, `SECURITY*.md`, `CONTRIBUTING*.md`).
- Các file cấu hình repo git thừa trong `cc-1c-skills-main`: `.git-blame-ignore-revs`, `.gitattributes`, `.gitignore`, `.github/`.
- Phá bỏ các lớp thư mục lồng nhau thừa thãi (`folder/folder/...`).

### 2.2. Thành phần cần giữ lại và nâng cấp
- **Toàn bộ 21 file bài giảng giáo trình 1C** (`lessons/bai-01-04.md` đến `bai-24.md` và `bai-extensions.md`).
- **Toàn bộ cẩm nang kiến trúc 1C:Jet** (`jet/jet-*.md`).
- **Tài liệu xây dựng hệ thống từ cấu hình rỗng (MIS)** (`mis/tu-xay-dung-he-thong.md`).
- **Ứng dụng mẫu ERP_Practice** (`erp-practice/erp-practice.md`).
- **Case doanh nghiệp & Khung khảo sát 7+2** (`erp-cases/*.md`).
- **Quy trình phân tích nghiệp vụ & template** (`phan-tich/*.md`).
- **Bộ quy tắc review code & chuẩn phát triển #std** (`code-review/*.md`).
- **Giao thức debug 7 bước & từ điển lỗi Nga - Anh** (`debug/giao-thuc-debug.md`).
- **Chuẩn code, BSL patterns, terminology RU-EN-VI** (`code-patterns.md`, `chinh-sach-code.md`, `terminology.md`).
- **Bộ quy tắc YAML Antipatterns & Standards** trích xuất từ `1c-ai-assistant`.
- **4 Agent Skills & CLI `scripts/onec.py`** từ `1C-Enterprise-Agent-Toolkit`.
- **70+ Agent Skills XML, 41 tài liệu đặc tả DSL, scripts** từ `cc-1c-skills`.

---

## 3. Kiến trúc Cấu trúc Thư mục Đích

Quy hoạch thành 4 module kỹ năng độc lập, chuẩn hóa:

```text
C:\Users\Dung\Documents\VSF TEST\Skill\
│
├── 📂 01-onec-core-developer/
│   ├── SKILL.md                            # Kỹ năng nòng cốt: Lập trình & Kiến trúc giải pháp 1C
│   └── 📂 references/
│       ├── 📂 lessons/                     # 21 bài học nền tảng 1C
│       ├── 📂 architecture/                # Kiến trúc ERP (MIS, ERP_Practice, Case doanh nghiệp, Khảo sát)
│       ├── 📂 jet-erp/                     # Toàn bộ phân hệ và kỹ thuật mở rộng 1C:Jet
│       ├── 📂 business-analysis/           # Quy trình & biểu mẫu phân tích nghiệp vụ
│       ├── 📂 standards/                   # Chuẩn code, BSL patterns, thuật ngữ RU-EN-VI
│       ├── 📂 projects-and-cases/          # Ngân hàng ý tưởng & các đề bài BTL
│       ├── 📂 resources/                   # Tài nguyên cài đặt, link bài giảng, video tra cứu
│       └── 📂 legal/                       # License & Notice
│
├── 📂 02-onec-code-quality/
│   ├── SKILL.md                            # Kỹ năng Review code, Antipatterns & Debugging
│   └── 📂 references/
│       ├── review-rules.md                 # Quy tắc P/Q/F/V/T/X/E/M
│       ├── development-standards.md        # Chuẩn #stdNNN của 1C
│       ├── debug-protocol.md               # Giao thức 7 bước & từ điển lỗi
│       ├── known-traps.md                  # Bẫy lỗi thường gặp
│       ├── ru-en-dictionary.md             # Từ điển Nga - Anh cho BSL
│       ├── ssl-api-english.md              # Chữ ký hàm SSL/BSP tiếng Anh
│       ├── external-tools.md               # Công cụ mã mở
│       └── 📂 rules-yaml/                  # YAML Antipatterns, Patterns & Standards
│           ├── 📂 antipatterns/
│           ├── 📂 patterns/
│           └── 📂 standards/
│
├── 📂 03-onec-platform-toolkit/
│   ├── SKILL.md                            # Kỹ năng Quản lý Phiên làm việc & Vòng đời Extension
│   ├── 📂 scripts/
│   │   └── onec.py                         # CLI script (Python stdlib)
│   ├── 📂 skills/                          # onec-dev, selective-export, lifecycle, validate
│   └── README.md
│
└── 📂 04-onec-xml-automation/
    ├── SKILL.md                            # Kỹ năng Thao tác XML & Tự động hóa Designer
    ├── 📂 skills/                          # 70+ atomic skills (form, meta, cf, cfe, epf, skd, mxl, db, web...)
    ├── 📂 docs/                            # 41 tài liệu đặc tả DSL & hướng dẫn
    ├── 📂 scripts/                         # Scripts thực thi (PowerShell & Python)
    └── 📂 hooks/                           # Hooks gợi ý skill
```

---

## 4. Định dạng Chuẩn `SKILL.md` Cho Cả 4 Module

Mỗi module sẽ có một file `SKILL.md` ở gốc thư mục với YAML frontmatter đầy đủ:
- `name`: Tên kỹ năng viết hoa thường, dấu gạch nối (ví dụ `onec-core-developer`).
- `description`: Bắt đầu bằng "Use when...", mô tả chính xác tình huống kích hoạt.
- Nội dung: Tóm tắt nguyên tắc, bảng tra cứu nhanh, liên kết chuẩn xác đến các tài liệu trong `references/`.
