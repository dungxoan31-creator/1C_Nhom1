# VinSmart Future — Quản lý Công nợ AR/AP trên 1C:Enterprise 8.3

Hệ thống quản trị tài chính, công nợ Phải thu (AR) và Phải trả (AP) độc lập nội sinh trên nền tảng **1C:Enterprise 8.3**.

---

## 1. Cấu trúc dự án

| Thư mục / File | Mô tả nội dung |
| :--- | :--- |
| [`src/`](src/) | Metadata XML và toàn bộ mã nguồn BSL của cấu hình 1C. |
| [`scripts/`](scripts/) | Các script PowerShell và Python phục vụ nạp cấu hình, xuất báo cáo và chạy kiểm thử tự động. |
| [`tests/`](tests/) | Mã kiểm thử BSL (Unit test, Migration test, UAT scenarios). |
| [`docs/`](docs/) | Báo cáo kiểm toán ERP, đặc tả kỹ thuật, kế hoạch và tài liệu tham chiếu 1C. |
| [`Lessons/`](Lessons/) & [`Bài thực hành/`](Bài%20thực%20hành/) | Tài liệu đào tạo, lý thuyết và bài tập thực hành phát triển 1C:Enterprise. |
| [`1C-Mentor-Skill-Gemini/`](1C-Mentor-Skill-Gemini/) | Công cụ và tài nguyên hỗ trợ học tập, hướng dẫn lập trình 1C. |
| [`VinSmart_Future_AR_AP_Full.dt`](VinSmart_Future_AR_AP_Full.dt) | Gói CSDL sao lưu đầy đủ 21 tháng nghiệp vụ (6.473 chứng từ đã ghi sổ). |
| [`VinSmart_Future_AR_AP_Test.dt`](VinSmart_Future_AR_AP_Test.dt) | Gói CSDL sao lưu tối giản phục vụ môi trường kiểm thử cô lập nhanh. |
| [`HUONG_DAN_SU_DUNG_FILE_DT.md`](HUONG_DAN_SU_DUNG_FILE_DT.md) | Tài liệu chi tiết hướng dẫn khôi phục dữ liệu và danh sách tài khoản mẫu. |

---

## 2. Cách dựng Infobase từ file `.dt`

### Cách 1: Nạp qua giao diện 1C Designer (Khuyến nghị)
1. Mở **1C:Enterprise** -> Bấm **Add...** -> Chọn **Create an infobase without configuration...** -> Đặt tên cơ sở dữ liệu và chọn thư mục lưu trữ.
2. Chọn CSDL vừa tạo -> Bấm **Designer** để mở chế độ quản trị.
3. Trên thanh menu, chọn: **Administration** -> **Restore infobase...**
4. Trỏ đến file [`VinSmart_Future_AR_AP_Full.dt`](VinSmart_Future_AR_AP_Full.dt) -> Bấm **Open** và xác nhận ghi đè.
5. Xem danh sách tài khoản mẫu (Admin, ketoan_ar, ketoan_ap, cfo_giamdoc...) và mật khẩu chi tiết tại: [HUONG_DAN_SU_DUNG_FILE_DT.md](HUONG_DAN_SU_DUNG_FILE_DT.md).

### Cách 2: Nạp nhanh bằng PowerShell
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\import_dt.ps1 -InputPath ".\VinSmart_Future_AR_AP_Full.dt"
```

---

## 3. Cách chạy Script & Kiểm thử (Testing)

### Cập nhật cấu hình từ mã nguồn `src/` vào CSDL
Khi có thay đổi code trong `src/`, nạp cấu hình vào Infobase bằng lệnh:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\update_db.ps1 -IBPath .\Infobase_FullData
```

### Chạy các bộ kiểm thử tự động
```powershell
# 1. Kiểm tra nguyên tắc độc lập 1C (không kết nối ngoài)
python scripts/test_1c_only.py

# 2. Kiểm tra tính cô lập môi trường thử nghiệm
python scripts/test_env_isolation.py

# 3. Kiểm thử 4 báo cáo quản trị chuyên sâu (CFO Dashboard, Aging AR/AP, Netting, Cloud Alert)
python scripts/test_executive_reports.py

# 4. Kiểm thử bảo mật ma trận phân quyền, Maker-Checker và SoD trên 1C runtime
python scripts/test_user_roles.py
```

---

## 4. Tài liệu chi tiết & Liên kết tham chiếu

Mọi thông tin chi tiết về kiến trúc, kiểm toán và báo cáo xin vui lòng tham khảo các tài liệu chuyên sâu:
- **Báo cáo kiểm toán hệ thống ERP toàn diện:** [docs/ERP_AUDIT_2026-10-12.md](docs/ERP_AUDIT_2026-10-12.md)
- **Báo cáo audit và dọn dẹp repository:** [CLEANUP_REPORT.md](CLEANUP_REPORT.md)
- **Kế hoạch triển khai khắc phục kiểm toán:** [docs/superpowers/plans/](docs/superpowers/plans/)
- **Báo cáo kết quả kiểm thử điều hành:** [docs/superpowers/reports/](docs/superpowers/reports/)
- **Tài liệu tham khảo nền tảng 1C:** [docs/reference/](docs/reference/)
