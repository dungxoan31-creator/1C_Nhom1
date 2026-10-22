---
name: onec-platform-toolkit
description: Use when managing isolated 1C:Enterprise infobase sessions, performing selective metadata export, managing extension (CFE) full lifecycle (create, load, dump, backup, rollback, delete), or validating BSL syntax and applicability via the onec.py CLI.
---

# 1C Enterprise Agent Toolkit

Bộ công cụ tự động hóa chu trình làm việc an toàn trên nền tảng 1C:Enterprise (phiên bản 8.3 trở lên) thông qua CLI thuần Python `scripts/onec.py`.

## 1. Các kỹ năng cốt lõi (`skills/`)

| Kỹ năng | Thư mục | Chức năng |
|---|---|---|
| **onec-dev** | `skills/onec-dev/` | Khởi tạo phiên làm việc cô lập (`session-create`), bảo vệ cơ sở dữ liệu gốc, dọn dẹp dữ liệu tạm (`session-cleanup`). |
| **onec-selective-export** | `skills/onec-selective-export/` | Xuất chọn lọc đúng đối tượng cần sửa qua `/DumpConfigToFiles -listFile` thay vì xuất toàn bộ cấu hình nặng nề. |
| **onec-extension-lifecycle** | `skills/onec-extension-lifecycle/` | Quản lý toàn diện vòng đời extension: tạo mới, nạp vào DB, sao lưu, phục hồi rollback, và xóa extension. |
| **onec-extension-validate** | `skills/onec-extension-validate/` | Kiểm tra tính hợp lệ của BSL, tính tương thích khi cập nhật DB (`UpdateDBCfg`), và xuất file thành phẩm `.cfe`. |

## 2. Lệnh CLI nhanh (`scripts/onec.py`)

CLI sử dụng thư viện chuẩn của Python, không cần cài đặt thêm dependency:

```powershell
# 1. Tự động phát hiện phiên bản 1C:Enterprise đã cài đặt trên máy
python "03-onec-platform-toolkit/scripts/onec.py" discover

# 2. Tạo phiên làm việc cô lập từ file infobase (.1CD)
python "03-onec-platform-toolkit/scripts/onec.py" session-create `
  --base-file "C:\path\to\infobase" `
  --user "Administrator"

# 3. Xuất chọn lọc một đối tượng metadata
python "03-onec-platform-toolkit/scripts/onec.py" selective-export `
  --session "C:\path\to\session\manifest.json" `
  --object "Catalog.Products"

# 4. Kiểm tra extension và cập nhật thử nghiệm
python "03-onec-platform-toolkit/scripts/onec.py" extension-validate `
  --session "C:\path\to\session\manifest.json" `
  --name "MyExtension"
```

Chi tiết tham khảo [README.md](README.md) hoặc từng kỹ năng trong `skills/`.
