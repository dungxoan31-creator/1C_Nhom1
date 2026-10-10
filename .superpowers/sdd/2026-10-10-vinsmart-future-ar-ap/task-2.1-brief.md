# Task 2.1 Brief: Sổ Tích Lũy Dual Subledger & Schema Đầy Đủ Sổ `DongTien`

## 1. Mục tiêu
Xây dựng 4 Sổ tích lũy (Accumulation Registers) độc lập quản lý chi tiết công nợ AR/AP và dòng tiền. Khai báo đầy đủ 2 resource `SoTien` (VND) và `SoTienNgoaiTe` (USD) trên `DongTien`.

## 2. File tác động
- `tests/unit/AccumulationRegistersTest.bsl` (New)
- `src/AccumulationRegisters/CongNoPhaiThu.xml` (New)
- `src/AccumulationRegisters/CongNoPhaiTra.xml` (New)
- `src/AccumulationRegisters/DongTien.xml` (New)
- `src/AccumulationRegisters/GiaoDichDienTuTamGiu.xml` (New)

## 3. Yêu cầu Chi tiết Kỹ thuật
1. **AccumulationRegister.CongNoPhaiThu:**
   - Chế độ: `Balances`.
   - Dimensions: `PhapNhan` (CatalogRef.PhapNhan), `DoiTac` (CatalogRef.DoiTac), `HopDong` (CatalogRef.HopDong), `ChungTuGoc` (DocumentRef).
   - Resources: `SoTien` (Number 15,2), `SoTienNgoaiTe` (Number 15,2).
2. **AccumulationRegister.CongNoPhaiTra:**
   - Chế độ: `Balances`.
   - Dimensions: `PhapNhan`, `DoiTac`, `HopDong`, `ChungTuGoc`.
   - Resources: `SoTien` (Number 15,2), `SoTienNgoaiTe` (Number 15,2).
3. **AccumulationRegister.DongTien:**
   - Chế độ: `BalancesAndTurnovers`.
   - Dimensions: `PhapNhan` (CatalogRef.PhapNhan), `TaiKhoanTien` (CatalogRef.TaiKhoanTien), `TienTe` (CatalogRef.TienTe), `KhoanMucDongTien` (CatalogRef.KhoanMucDongTien).
   - Resources: `SoTien` (Number 15,2 - VND), `SoTienNgoaiTe` (Number 15,2 - Ngoại tệ).
4. **AccumulationRegister.GiaoDichDienTuTamGiu:**
   - Chế độ: `Balances`.
   - Dimensions: `PhapNhan`, `KenhThanhToan` (CatalogRef.KenhThanhToan), `MaGiaoDichKenh` (String 100).
   - Resources: `SoTien` (Number 15,2), `PhiKenh` (Number 15,2).

## 4. Test Case `tests/unit/AccumulationRegistersTest.bsl`
- Test 1: Kiểm tra ghi nhận tăng nợ AR `Receipt` 100tr, giảm nợ `Expense` 40tr -> Bảng ảo `.Balances()` trả về đúng 60tr theo `(HopDong, ChungTuGoc)`.
- Test 2: Kiểm tra ghi nhận tăng nợ AP `Receipt` 200tr, giảm nợ `Expense` 150tr -> Số dư đúng 50tr.
- Test 3: Kiểm tra bảng ảo `DongTien.Balance()` trả về cả `SoTienBalance` và `SoTienNgoaiTeBalance` chính xác.

## 5. Ràng buộc Kỹ thuật
- Không sửa file ngoài thư mục `src/AccumulationRegisters/` và `tests/unit/AccumulationRegistersTest.bsl`.
- Báo cáo kết quả tại: `.superpowers/sdd/2026-10-10-vinsmart-future-ar-ap/task-2.1-report.md`.
