# Task 1.3 Brief: Cấu hình `HeThongTaiKhoan`, Sổ Cái `SoCaiKeToan`, 9 Roles & Maker-Checker Rule

## 1. Mục tiêu
Xây dựng hệ thống tài khoản kế toán doanh nghiệp có bảng ánh xạ `MaLogic -> SoHieuTK`, Sổ kế toán kép `SoCaiKeToan` có Invariant cân đối tiền tệ $\sum Dr = \sum Cr$, 9 Roles phân quyền và Common Module kiểm soát Maker-Checker tập trung.

## 2. File tác động
- `tests/unit/ChartOfAccountsTest.bsl` (New)
- `src/ChartsOfAccounts/HeThongTaiKhoan.xml` (New)
- `src/AccountingRegisters/SoCaiKeToan.xml` (New)
- `src/Roles/QuanTriHeThong.xml` đến `src/Roles/ITDirector_GiamDocHaTang.xml` (9 files New)
- `src/CommonModules/QuanLyVongDoiChungTuServer.xml` (New)
- `src/CommonModules/QuanLyVongDoiChungTuServer/Ext/Module.bsl` (New)

## 3. Yêu cầu Chi tiết Kỹ thuật
1. **ChartOfAccounts.HeThongTaiKhoan:**
   - Thuộc tính: `MaLogic` (String 20 - Index), `TenTaiKhoan` (String 150), `TinhChat` (Active/Passive).
   - Nạp predefined accounts / danh mục: 1311, 1312, 3311, 3312, 1121, 1122, 1331, 33311, 33318, 3338, 5113, 627, 642, 6427, 635, 515, 4131, 711.
2. **AccountingRegister.SoCaiKeToan:**
   - `Correspondence = True`.
   - Dimensions: `PhapNhan` (CatalogRef.PhapNhan), `TienTe` (CatalogRef.TienTe).
   - Resources: `SoTien` (Number 15,2), `SoTienNgoaiTe` (Number 15,2).
   - Attributes: `ChungTuGoc` (DocumentRef), `TyGia` (Number 10,4), `DienGiai` (String 250).
3. **9 Roles:**
   - `QuanTriHeThong`, `KeToanPhaiThu`, `KeToanPhaiTra`, `ChuyenVienDoiSoatTapDoan`, `KeToanTruong`, `GiamDocTaiChinh_CFO`, `TechLead_KiemTraKyThuat`, `ProjectManager_QuanLyDuAn`, `ITDirector_GiamDocHaTang`.
4. **CommonModule.QuanLyVongDoiChungTuServer:**
   - `Server = True`, `CallServer = True`.
   - Hàm `KiemTraChuyenTrangThai(ChungTuRef, TrangThaiMoi, CurrentUser)`:
     * Cấm người tạo tự duyệt (Maker-Checker, không ngoại lệ Admin).
     * Cấm tuyệt đối với lệnh chi tiền `UyNhiemChi`.
     * Cho phép tài khoản hệ thống `SA_BankingIntegration` (tự động ghi sổ `BaoCoNganHang`) bypass kiểm tra người dùng.

## 4. Test Case `tests/unit/ChartOfAccountsTest.bsl`
- Test 1: Ánh xạ thành công `MaLogic = "1312"` (AR Nội bộ) và `MaLogic = "33318"` (Thuế VAT Nhà thầu).
- Test 2: Invariant cân đối tiền tệ $\sum Dr = \sum Cr$ trên bản ghi `SoCaiKeToan`.
- Test 3: Maker-Checker chặn người tạo tự ký duyệt (kể cả Admin).
- Test 4: Maker-Checker cấm tuyệt đối người tạo ký lệnh chi tiền `UyNhiemChi`.

## 5. Ràng buộc Kỹ thuật
- Không sửa file trong `src/Catalogs/`, `src/Enums/`, `src/Constants/`, `src/Configuration.xml`.
- Báo cáo kết quả tại: `.superpowers/sdd/2026-10-10-vinsmart-future-ar-ap/task-1.3-report.md`.
