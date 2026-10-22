---
name: onec-xml-automation
description: Use when automating 1C:Enterprise configuration development, inspecting or editing XML source files, building or dumping external data processors (EPF) and reports (ERF), modifying managed forms (form-edit, form-add), compiling DCS/SKD schemas, editing MXL spreadsheets, managing infobases, or publishing web clients via CLI scripts.
---

# 1C XML Automation & Designer CLI Skills

Bộ công cụ tự động hóa thao tác với cấu hình 1C:Enterprise 8.3 dạng mã nguồn XML và giao tiếp Designer CLI. Giúp agent trực tiếp tạo, sửa đổi, kiểm tra, biên dịch các đối tượng metadata, giao diện form, báo cáo, và quản lý cơ sở dữ liệu mà không cần thao tác thủ công.

## 1. Phân loại kỹ năng theo nhóm

| Nhóm chức năng | Lệnh kỹ năng (`skills/`) | Mô tả & Hướng dẫn chi tiết |
|---|---|---|
| **External Processors (EPF)** | `epf-init`, `epf-build`, `epf-dump`, `epf-validate`, `epf-bsp-init`, `epf-bsp-add-command` | Tạo, đóng gói `.epf`, giải nén ra XML, kiểm tra tính hợp lệ và chuẩn SSL/BSP. Xem [epf-guide.md](docs/epf-guide.md). |
| **External Reports (ERF)** | `erf-init`, `erf-build`, `erf-dump`, `erf-validate` | Xử lý báo cáo ngoài `.erf` tương tự như EPF. Xem [epf-guide.md](docs/epf-guide.md#внешние-отчёты-erf). |
| **Managed Forms (Form)** | `form-add`, `form-edit`, `form-info`, `form-compile`, `form-decompile`, `form-validate`, `form-remove`, `form-patterns` | Sửa trực tiếp `Form.xml` bằng mô tả JSON (thêm input, table, group, command, handler, conditional appearance). Xem [form-guide.md](docs/form-guide.md) & [form-dsl-spec.md](docs/form-dsl-spec.md). |
| **Metadata Configuration** | `meta-edit`, `meta-info`, `meta-compile`, `meta-decompile`, `meta-validate`, `meta-remove` | Quản lý 23 loại đối tượng metadata (Catalog, Document, Register, Subsystem, Role...) bằng JSON DSL. Xem [meta-guide.md](docs/meta-guide.md) & [meta-dsl-spec.md](docs/meta-dsl-spec.md). |
| **Root Configuration (CF)** | `cf-init`, `cf-info`, `cf-edit`, `cf-validate` | Khởi tạo, chỉnh sửa và kiểm tra file gốc `Configuration.xml`. Xem [cf-guide.md](docs/cf-guide.md). |
| **Extensions (CFE)** | `cfe-init`, `cfe-borrow`, `cfe-patch-method`, `cfe-diff`, `cfe-validate` | Tạo extension, vay mượn đối tượng (borrow), chặn và can thiệp method (`&Before`, `&After`, `&Around`). Xem [cfe-guide.md](docs/cfe-guide.md). |
| **Data Composition (DCS/SKD)**| `skd-edit`, `skd-info`, `skd-compile`, `skd-decompile`, `skd-validate` | Chỉnh sửa cấu trúc Scheme báo cáo DCS từ JSON DSL. Xem [skd-guide.md](docs/skd-guide.md) & [skd-dsl-spec.md](docs/skd-dsl-spec.md). |
| **Spreadsheets (MXL)** | `mxl-info`, `mxl-compile`, `mxl-decompile`, `mxl-validate` | Phân tích và biên dịch template mẫu in tabular document từ DSL. Xem [mxl-guide.md](docs/mxl-guide.md) & [mxl-dsl-spec.md](docs/mxl-dsl-spec.md). |
| **Roles & Permissions** | `role-edit`, `role-info`, `role-compile`, `role-validate` | Cấu hình quyền truy cập của vai trò (Role) từ file JSON DSL. Xem [role-guide.md](docs/role-guide.md) & [role-dsl-spec.md](docs/role-dsl-spec.md). |
| **Subsystems & Interface** | `subsystem-edit`, `subsystem-info`, `subsystem-compile`, `subsystem-validate`, `interface-edit`, `interface-validate` | Quản lý cây phân hệ giao diện và menu điều hướng `CommandInterface.xml`. Xem [subsystem-guide.md](docs/subsystem-guide.md). |
| **Infobase Management (DB)** | `db-create`, `db-run`, `db-update`, `db-dump-cf`, `db-load-cf`, `db-dump-dt`, `db-load-dt`, `db-dump-xml`, `db-load-xml`, `db-repo`, `db-cfe-admin` | Tạo infobase, cập nhật F7 qua dòng lệnh, backup/restore `.dt`/`.cf`/XML, quản lý kho lưu trữ repository. Xem [db-guide.md](docs/db-guide.md). |
| **XDTO Packages** | `xdto-edit`, `xdto-info`, `xdto-compile`, `xdto-decompile`, `xdto-validate` | Phân tích và chuyển đổi schema XML sang XDTO packages. Xem [xdto-guide.md](docs/xdto-guide.md). |
| **Web Client Automation** | `web-publish`, `web-stop`, `web-unpublish`, `web-info`, `web-test` | Xuất bản infobase lên web server Apache mini và chạy browser tương tác. Xem [web-guide.md](docs/web-guide.md). |

## 2. Cách thực thi

Tất cả các kỹ năng đều có script PowerShell (`scripts/*.ps1`) sẵn sàng thực thi:

```powershell
# Ví dụ 1: Sửa form qua JSON
powershell.exe -NoProfile -File "04-onec-xml-automation/skills/form-edit/scripts/form-edit.ps1" -FormPath "<đường_dẫn_Form.xml>" -JsonPath "<đường_dẫn_diff.json>"

# Ví dụ 2: Đóng gói External Data Processor (.epf)
powershell.exe -NoProfile -File "04-onec-xml-automation/skills/epf-build/scripts/epf-build.ps1" -SrcPath "<thư_mục_xml>" -OutPath "<file_đích.epf>"
```

Tài liệu hướng dẫn chi tiết từng công cụ nằm trong thư mục `docs/`.
