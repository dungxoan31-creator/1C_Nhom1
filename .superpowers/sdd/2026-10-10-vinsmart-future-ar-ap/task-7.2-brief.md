# Task 7.2 Brief: Tích Hợp HĐĐT HSM & Scheduled Job Nạp Tỷ Giá

## 1. Mục tiêu
1. **Module Tích Hợp Hóa Đơn Điện Tử HSM (`CommonModule.TichHopHoaDonDienTuServer`):**
   - Đóng gói dữ liệu hóa đơn GTGT đầu ra theo Nghị định 123/2020/NĐ-CP và Thông tư 78/2021/TT-BTC.
   - Ký số HSM tập trung (Cloud HSM / Viettel S-Invoice / VNPT): Nhận mã CQT (`MaCuaCQT`).
   - Xử lý đồng bộ trạng thái hóa đơn điện tử: `ChoCapMa`, `DaCapMa`, `TuChoiCapMa`.
2. **Scheduled Job Nạp Tỷ Giá Ngoại Tệ (`ScheduledJob.CapNhatTyGiaNgoaiTeTuDong`):**
   - Tự động nạp tỷ giá ngoại tệ từ API ngân hàng (Vietcombank/Techcombank) lúc 08:00 hàng ngày.
   - Cập nhật số liệu vào `InformationRegister.TyGiaHoiDoai`.

## 2. File tác động
- `tests/integration/EInvoiceAndFXIntegrationTest.bsl` (New)
- `src/CommonModules/TichHopHoaDonDienTuServer.xml` & `Ext/Module.bsl` (New)
- `src/CommonModules/QuanLyTyGiaVaNgoaiTeServer/Ext/Module.bsl` (Add `CapNhatTyGiaTuDong`)
- `src/ScheduledJobs/CapNhatTyGiaNgoaiTeTuDong.xml` (New)
- `src/Configuration.xml` (Register CommonModule and ScheduledJob)

## 3. Kịch bản kiểm thử (TDD)
1. Ký số HSM hóa đơn GTGT: Gửi payload hợp lệ -> HSM ký số thành công, nhận `MaCuaCQT` 34 ký tự.
2. Kiểm tra trạng thái cấp mã CQT: Tổng cục thuế xác nhận hợp lệ -> Hóa đơn chuyển sang `DaCapMa`.
3. Từ chối cấp mã CQT: Hóa đơn sai thông tin mã số thuế -> Chuyển sang `TuChoiCapMa` và lưu lý do lỗi.
4. Scheduled Job nạp tỷ giá tự động: Ghi nhận tỷ giá USD vào `InformationRegister.TyGiaHoiDoai`.
5. Metadata Schema XML của ScheduledJob và CommonModule hợp lệ 100% theo chuẩn 1C version 2.15.
