# Kế Hoạch Tái Cấu Trúc Kho Kỹ Năng 1C:Enterprise (Implementation Plan)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Dọn sạch toàn bộ dữ liệu rác (>8.800 files), chuẩn hóa cấu trúc thư mục, tổ chức lại kho tri thức và công cụ 1C:Enterprise thành 4 module độc lập, chuẩn hóa theo Agent Skills Specification cho OpenAI Codex và Antigravity.

**Architecture:** Tạo 4 module kỹ năng độc lập trong `Skill/`: `01-onec-core-developer`, `02-onec-code-quality`, `03-onec-platform-toolkit`, `04-onec-xml-automation`. Mỗi module có `SKILL.md` chuẩn, tách biệt `references/`, `scripts/`, `docs/`, `skills/`.

**Tech Stack:** PowerShell, Markdown, YAML, Python (onec.py CLI).

**Spec:** `docs/superpowers/specs/2026-10-19-1c-skills-reorganization-design.md`

## Global Constraints
- Không làm mất mát bất kỳ tài liệu kỹ thuật, kiến trúc, bài giảng hoặc quy tắc review nào.
- Giữ nguyên các scripts Python/PowerShell cần thiết của toolkit.
- Đảm bảo toàn bộ liên kết nội bộ trong `SKILL.md` của các module đều trỏ tới file có thực, không có broken link.
- Loại bỏ hoàn toàn 8.848 files test của `cc-1c-skills` và mã nguồn Python thừa của `1c-ai-assistant`.

---

### Task 1: Trích xuất Knowledge Base từ `1c-ai-assistant-main` & Xóa bỏ rác backend

**Files:**
- Source: `Skill/1c-ai-assistant-main/1c-ai-assistant-main/knowledge-base/`
- Target: `Skill/_temp_kb/`
- Delete: `Skill/1c-ai-assistant-main/`

- [x] **Step 1: Copy `knowledge-base` sang vị trí tạm**
- [x] **Step 2: Xóa toàn bộ thư mục `Skill/1c-ai-assistant-main`**
- [x] **Step 3: Xác minh thư mục `1c-ai-assistant-main` đã biến mất và `_temp_kb` nguyên vẹn**

---

### Task 2: Dọn sạch tests và rác từ `cc-1c-skills-main` & Phá bỏ lớp lồng thư mục

**Files:**
- Source: `Skill/cc-1c-skills-main/cc-1c-skills-main/`
- Target: `Skill/04-onec-xml-automation/`
- Delete: `tests/`, `.github/`, `.gitattributes`, `.gitignore`, `.git-blame-ignore-revs`, `Skill/cc-1c-skills-main/`

- [x] **Step 1: Xóa thư mục `tests/` (8.848 files rác) trong `cc-1c-skills-main`**
- [x] **Step 2: Xóa các file git boilerplate**
- [x] **Step 3: Di chuyển các thư mục hữu ích (`.claude/skills` thành `skills`, `docs`, `scripts`, `hooks`, `.v8-xsd`) sang `Skill/04-onec-xml-automation/`**
- [x] **Step 4: Tạo `SKILL.md` tổng hợp index cho `04-onec-xml-automation`**
- [x] **Step 5: Xóa thư mục cũ `Skill/cc-1c-skills-main`**
- [x] **Step 6: Xác minh `04-onec-xml-automation` gọn gàng, không còn test rác**

---

### Task 3: Tinh giản và tái cấu trúc `1C-Enterprise-Agent-Toolkit-main`

**Files:**
- Source: `Skill/1C-Enterprise-Agent-Toolkit-main/1C-Enterprise-Agent-Toolkit-main/`
- Target: `Skill/03-onec-platform-toolkit/`
- Delete: `tests/`, `.github/`, `Skill/1C-Enterprise-Agent-Toolkit-main/`

- [x] **Step 1: Xóa `tests/` và các file metadata không cần thiết**
- [x] **Step 2: Di chuyển `skills/`, `scripts/`, `assets/`, `examples/`, `install.py`, `README.md`, `README.en.md` sang `Skill/03-onec-platform-toolkit/`**
- [x] **Step 3: Tạo `SKILL.md` chính điều phối cho `03-onec-platform-toolkit`**
- [x] **Step 4: Xóa thư mục cũ `Skill/1C-Enterprise-Agent-Toolkit-main`**
- [x] **Step 5: Xác minh thư mục `03-onec-platform-toolkit` hoạt động độc lập**

---

### Task 4: Xây dựng Module `01-onec-core-developer`

**Files:**
- Source: `Skill/lessons/`, `Skill/jet/`, `Skill/mis/`, `Skill/erp-practice/`, `Skill/erp-cases/`, `Skill/phan-tich/`, `Skill/btl/`, các file `.md` gốc.
- Target: `Skill/01-onec-core-developer/`

- [x] **Step 1: Tạo cấu trúc thư mục con trong `Skill/01-onec-core-developer/references/`**
  - `lessons/`
  - `architecture/`
  - `jet-erp/`
  - `business-analysis/`
  - `standards/`
  - `projects-and-cases/`
  - `resources/`
  - `legal/`
- [x] **Step 2: Di chuyển các file tương ứng vào các thư mục tham chiếu**
- [x] **Step 3: Viết lại `SKILL.md` của `01-onec-core-developer` với frontmatter chuẩn, nâng cấp từ "gia sư sinh viên" thành Senior 1C Developer/Architect, cập nhật toàn bộ đường dẫn tham chiếu**
- [x] **Step 4: Xác minh mọi file bài giảng và tài liệu kiến trúc nằm đúng vị trí**

---

### Task 5: Xây dựng Module `02-onec-code-quality`

**Files:**
- Source: `Skill/code-review/`, `Skill/debug/`, `Skill/_temp_kb/`
- Target: `Skill/02-onec-code-quality/`

- [x] **Step 1: Tạo thư mục `Skill/02-onec-code-quality/references/` và `references/rules-yaml/`**
- [x] **Step 2: Di chuyển và đổi tên các file tri thức review/debug một cách khoa học:**
  - `code-review/review-code.md` → `review-rules.md`
  - `code-review/chuan-phat-trien.md` → `development-standards.md`
  - `debug/giao-thuc-debug.md` → `debug-protocol.md`
  - `code-review/loi-da-biet.md` → `known-traps.md`
  - `code-review/thuat-ngu-ru-en.md` → `ru-en-dictionary.md`
  - `code-review/ssl-api-en.md` → `ssl-api-english.md`
  - `code-review/nguon-ngoai.md` → `external-tools.md`
- [x] **Step 3: Di chuyển `_temp_kb/antipatterns`, `patterns`, `standards` vào `references/rules-yaml/`, xóa `_temp_kb`**
- [x] **Step 4: Viết `SKILL.md` chuyên sâu cho `02-onec-code-quality`**
- [x] **Step 5: Xóa các thư mục cũ `Skill/code-review` và `Skill/debug`**

---

### Task 6: Kiểm tra, hoàn thiện và tổng kết

- [x] **Step 1: Quét toàn bộ thư mục `Skill/`, đảm bảo không còn file rác thừa ở thư mục gốc**
- [x] **Step 2: Đo lường tổng dung lượng và số lượng file sau khi tinh gọn (so sánh với trước khi dọn)**
- [x] **Step 3: Kiểm tra tính hợp lệ của frontmatter YAML và đường dẫn liên kết của cả 4 modules**
- [x] **Step 4: Tổng kết báo cáo cho người dùng**
