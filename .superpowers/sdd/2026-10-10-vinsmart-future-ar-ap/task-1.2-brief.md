# Task 1.2 Brief: Khởi tạo 8 Enums & Khởi Tạo Đủ 12 Constants Hệ Thống

## 1. Mục tiêu
Xây dựng 8 Enumerations định nghĩa các trạng thái vòng đời chứng từ và 12 Constants cấu hình tĩnh hệ thống theo chuẩn 1C:Enterprise 8.3 (CompatibilityMode Version8_3_22).

## 2. File tác động
- `tests/unit/EnumsConstantsTest.bsl` (New)
- `src/Enums/TrangThaiNghiemThuAR.xml` (New)
- `src/Enums/TrangThaiHoaDonAP.xml` (New)
- `src/Enums/TrangThaiLenhThanhToan.xml` (New)
- `src/Enums/TrangThaiCanTru.xml` (New)
- `src/Enums/TrangThaiHoaDonDienTu.xml` (New)
- `src/Enums/LoaiDoiTac.xml` (New)
- `src/Enums/HuongDongTien.xml` (New)
- `src/Enums/TrangThaiDongBo.xml` (New)
- `src/Constants/PhapNhanMacDinh.xml` (New)
- `src/Constants/NguongPheDuyetChiTienCFO.xml` (New)
- `src/Constants/TaiKhoanTrungGianCanTru.xml` (New)
- `src/Constants/TuDongDongBoSAP.xml` (New)
- `src/Constants/NguongThanhToanKhongDungTienMat.xml` (New)
- `src/Constants/TaiKhoanPhiNganHang.xml` (New)
- `src/Constants/SoLuongHoaDonFIFOMax.xml` (New)
- `src/Constants/GiaTriFIFOMax.xml` (New)
- `src/Constants/TimeoutChoCanTruPhut.xml` (New)
- `src/Constants/CanhBaoCloudMucVang.xml` (New)
- `src/Constants/CanhBaoCloudMucCam.xml` (New)
- `src/Constants/CanhBaoCloudMucDo.xml` (New)

## 3. Chi tiết Giá trị 8 Enums
1. **Enum.TrangThaiNghiemThuAR:** `DuThao`, `ChoDuyetNoiBo`, `DaDuyetNoiBo`, `ChoDoiTacKy`, `DaGhiSo`, `DaThanhToanMotPhan`, `DaTatToan`, `TranhChap`.
2. **Enum.TrangThaiHoaDonAP:** `DuThao`, `ChoDuyetKyThuat`, `ChoDuyetPM`, `ChoDuyetITDirector`, `ChoDuyetCFO`, `ChoKeToanAP`, `DaGhiSo`, `TuChoi`.
3. **Enum.TrangThaiLenhThanhToan:** `DuThao`, `ChoDuyet`, `DaDuyet`, `DaGuiNganHang`, `DaGhiSo`, `TuChoi`, `HuyBo` (Đủ 7 giá trị).
4. **Enum.TrangThaiCanTru:** `DuThao`, `ChoDuyetNoiBo`, `ChoTapDoanDuyet`, `ChoCanTru`, `DaTatToan`, `HuyBo`.
5. **Enum.TrangThaiHoaDonDienTu:** `DuThao`, `ChoKySo`, `DaPhatHanh`, `DaDieuChinh`, `DaThayThe`, `DaHuy`.
6. **Enum.LoaiDoiTac:** `KhachHangNgoai`, `NoiBoVingroup`, `NhaCungCapCloud`, `NhaCungCapLinhKien`, `ThauPhuCNTT`.
7. **Enum.HuongDongTien:** `Thu`, `Chi`.
8. **Enum.TrangThaiDongBo:** `ChuaDongBo`, `ChoDongBo`, `ThanhCong`, `LoiDongBo`.

## 4. Chi tiết Giá trị Mặc định 12 Constants
1. `PhapNhanMacDinh`: Type `CatalogRef.PhapNhan` hoặc String "VSF_CORP".
2. `NguongPheDuyetChiTienCFO`: Type Number (15,0) = `500000000`.
3. `TaiKhoanTrungGianCanTru`: Type String (20) = `"1388"`.
4. `TuDongDongBoSAP`: Type Boolean = `True`.
5. `NguongThanhToanKhongDungTienMat`: Type Number (15,0) = `5000000`.
6. `TaiKhoanPhiNganHang`: Type String (20) = `"6427"`.
7. `SoLuongHoaDonFIFOMax`: Type Number (3,0) = `2`.
8. `GiaTriFIFOMax`: Type Number (15,0) = `100000000`.
9. `TimeoutChoCanTruPhut`: Type Number (4,0) = `120`.
10. `CanhBaoCloudMucVang`: Type Number (3,0) = `30`.
11. `CanhBaoCloudMucCam`: Type Number (3,0) = `14`.
12. `CanhBaoCloudMucDo`: Type Number (3,0) = `7`.

## 5. Ràng buộc Kỹ thuật
- Không sửa file trong thư mục `src/Catalogs/` (tránh xung đột với Agent 1).
- Định dạng XML 1C theo `CompatibilityMode Version8_3_22`.
- Unit test `tests/unit/EnumsConstantsTest.bsl`: Kiểm tra đọc đủ các giá trị của 8 Enums và 12 Constants.
- Báo cáo kết quả tại: `.superpowers/sdd/2026-10-10-vinsmart-future-ar-ap/task-1.2-report.md`.
