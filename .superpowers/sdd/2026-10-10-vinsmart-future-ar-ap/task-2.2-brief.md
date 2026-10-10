# Task 2.2 Brief: Cấu hình 5 Sổ Thông Tin (Information Registers)

## 1. Mục tiêu
Xây dựng 5 Sổ thông tin (Information Registers) lưu vết tỷ giá, hạn mức dịch vụ, đồng bộ SAP, Idempotency ngân hàng và kế hoạch chi tiêu.

## 2. File tác động
- `tests/unit/InformationRegistersTest.bsl` (New)
- `src/InformationRegisters/TyGiaHoiDoai.xml` (New)
- `src/InformationRegisters/HanMucVaChanXuatDichVu.xml` (New)
- `src/InformationRegisters/TrangThaiDongBoSAP.xml` (New)
- `src/InformationRegisters/LichSuGiaoDichNganHang.xml` (New)
- `src/InformationRegisters/KeHoachChiTien.xml` (New)

## 3. Yêu cầu Chi tiết Kỹ thuật
1. **InformationRegister.TyGiaHoiDoai:**
   - Periodic: `Day`.
   - Dimensions: `TienTe` (CatalogRef.TienTe).
   - Resources: `TyGiaMua` (Number 10,4), `TyGiaBan` (Number 10,4), `TyGiaHachToan` (Number 10,4).
2. **InformationRegister.HanMucVaChanXuatDichVu:**
   - Non-periodic.
   - Dimensions: `PhapNhan`, `DoiTac`, `HopDong`.
   - Resources: `HanMucCongNo` (Number 15,2), `TrangThaiKhoa` (Boolean), `LyDoKhoa` (String 200).
3. **InformationRegister.TrangThaiDongBoSAP:**
   - Non-periodic.
   - Dimensions: `ChungTu` (DocumentRef), `NgayDongBo` (Date).
   - Resources: `TrangThai` (EnumRef.TrangThaiDongBo), `MaGiaoDichSAP` (String 100), `SoLanRetry` (Number 2), `ThongBaoLoi` (String 500).
4. **InformationRegister.LichSuGiaoDichNganHang:**
   - Non-periodic. Lock Mode: `Managed`.
   - Dimensions (Unique Index): `IdempotencyKey` (String 150).
   - Resources: `MaGiaoDichNganHang` (String 100), `NgayGiaoDich` (Date), `SoTien` (Number 15,2), `PayloadHash` (String 64), `TrangThaiXuLy` (String 50).
5. **InformationRegister.KeHoachChiTien:**
   - Non-periodic.
   - Dimensions: `Thang` (Date), `DuAn` (CatalogRef.DuAn), `KhoanMucDongTien` (CatalogRef.KhoanMucDongTien), `PhapNhan` (CatalogRef.PhapNhan).
   - Resources: `SoTienNganSach` (Number 15,2), `SoTienDaDuyet` (Number 15,2), `SoTienThucChi` (Number 15,2).

## 4. Test Case `tests/unit/InformationRegistersTest.bsl`
- Test 1: Ghi nhận tỷ giá hối đoái USD theo ngày.
- Test 2: Ghi nhận ngân sách 4 chiều chi tiêu `KeHoachChiTien`.
- Test 3: Bắt trùng lặp `IdempotencyKey` trong `LichSuGiaoDichNganHang`.

## 5. Ràng buộc Kỹ thuật
- Không sửa file ngoài thư mục `src/InformationRegisters/` và `tests/unit/InformationRegistersTest.bsl`.
- Báo cáo kết quả tại: `.superpowers/sdd/2026-10-10-vinsmart-future-ar-ap/task-2.2-report.md`.
