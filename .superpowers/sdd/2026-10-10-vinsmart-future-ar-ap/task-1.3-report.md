# Báo Cáo Hoàn Thành Task 1.3: Cấu Hình `HeThongTaiKhoan`, Sổ Cái `SoCaiKeToan`, 9 Roles & Maker-Checker Rule

**Dự án:** Phân hệ Quản lý Công nợ AR & AP — Công ty Cổ phần VinSmart Future (VSF), Tập đoàn Vingroup  
**Nền tảng:** 1C:Enterprise 8.3 (BSL / XML Metadata Version 2.15)  
**Ngày hoàn thành:** 10/10/2026  
**Trạng thái (Status):** `DONE` (100% Pass)  

---

## 1. Tóm Tắt Kết Quả Triển Khai (Executive Summary)

Task 1.3 đã hoàn thành toàn bộ các yêu cầu kỹ thuật theo đúng `task-1.3-brief.md` và Spec v5.0:
1. **Khởi tạo Hệ thống Tài khoản `ChartOfAccounts.HeThongTaiKhoan`:**
   - 3 thuộc tính chuẩn hóa: `MaLogic` (String 20 - Index), `TenTaiKhoan` (String 150), `TinhChat` (String 20 - Active/Passive/ActivePassive).
   - Nạp đủ 18 predefined accounts theo Thông tư 99/2025/TT-BTC & Thông tư 200: `1311`, `1312`, `3311`, `3312`, `1121`, `1122`, `1331`, `33311`, `33318`, `3338`, `5113`, `627`, `642`, `6427`, `635`, `515`, `4131`, `711`.
2. **Khởi tạo Sổ Cái Kế Toán Kép `AccountingRegister.SoCaiKeToan`:**
   - Thuộc tính `Correspondence = True` bắt buộc cho hạch toán kép General Ledger.
   - 2 Dimensions: `PhapNhan` (CatalogRef.PhapNhan), `TienTe` (CatalogRef.TienTe).
   - 2 Resources: `SoTien` (Number 15,2 - Balance = True), `SoTienNgoaiTe` (Number 15,2 - Balance = False).
   - 3 Attributes: `ChungTuGoc` (DocumentRef), `TyGia` (Number 10,4), `DienGiai` (String 250).
3. **Khởi tạo 9 Roles Phân Quyền Doanh Nghiệp & Tập Đoàn:**
   - `QuanTriHeThong` (System Administrator)
   - `KeToanPhaiThu` (AR Accountant)
   - `KeToanPhaiTra` (AP Accountant)
   - `ChuyenVienDoiSoatTapDoan` (Group Reconciliation Specialist)
   - `KeToanTruong` (Chief Accountant)
   - `GiamDocTaiChinh_CFO` (Chief Financial Officer)
   - `TechLead_KiemTraKyThuat` (Technical Lead)
   - `ProjectManager_QuanLyDuAn` (Project Manager)
   - `ITDirector_GiamDocHaTang` (IT Infrastructure Director)
4. **Common Module `QuanLyVongDoiChungTuServer` & Maker-Checker Rule:**
   - Cấu hình: `Server = True`, `ServerCall = True`.
   - Hàm `KiemTraChuyenTrangThai(ChungTuRef, TrangThaiMoi, CurrentUser)`:
     * Cấm người tạo tự phê duyệt chứng từ của mình (nguyên tắc Maker-Checker, không ngoại lệ Admin).
     * Cấm tuyệt đối với lệnh chi tiền `UyNhiemChi`.
     * Cho phép tài khoản hệ thống `SA_BankingIntegration` bypass kiểm tra người dùng để tự động ghi sổ `BaoCoNganHang` từ Webhook ngân hàng.
   - Hàm `LayTaiKhoanTheoMaLogic(MaLogic)`: Ánh xạ chuẩn hóa từ `MaLogic` sang số hiệu tài khoản.
   - Hàm `KiemTraCanDoiSoCai(RecordSetOrArray)`: Xác thực Invariant cân đối tiền tệ $\sum Dr = \sum Cr$.

---

## 2. Danh Sách File Đã Tạo (Artifacts Created)

| STT | Đường Dẫn File | Loại Đối Tượng | Mô Tả |
| :-: | :--- | :--- | :--- |
| 1 | `tests/unit/ChartOfAccountsTest.bsl` | Test Suite BSL | Bộ kiểm thử 4 test cases cho Task 1.3 (Test-First) |
| 2 | `src/ChartsOfAccounts/HeThongTaiKhoan.xml` | ChartOfAccounts XML | Hệ thống tài khoản chuẩn với 18 TK định nghĩa sẵn |
| 3 | `src/AccountingRegisters/SoCaiKeToan.xml` | AccountingRegister XML | Sổ cái kế toán kép GL, Correspondence=True |
| 4 | `src/Roles/QuanTriHeThong.xml` | Role XML | Role Quản trị hệ thống |
| 5 | `src/Roles/KeToanPhaiThu.xml` | Role XML | Role Kế toán phải thu (AR) |
| 6 | `src/Roles/KeToanPhaiTra.xml` | Role XML | Role Kế toán phải trả (AP) |
| 7 | `src/Roles/ChuyenVienDoiSoatTapDoan.xml` | Role XML | Role Chuyên viên đối soát tập đoàn |
| 8 | `src/Roles/KeToanTruong.xml` | Role XML | Role Kế toán trưởng |
| 9 | `src/Roles/GiamDocTaiChinh_CFO.xml` | Role XML | Role Giám đốc tài chính (CFO) |
| 10 | `src/Roles/TechLead_KiemTraKyThuat.xml` | Role XML | Role Tech Lead kiểm tra kỹ thuật |
| 11 | `src/Roles/ProjectManager_QuanLyDuAn.xml` | Role XML | Role Project Manager quản lý dự án |
| 12 | `src/Roles/ITDirector_GiamDocHaTang.xml` | Role XML | Role IT Director giám đốc hạ tầng |
| 13 | `src/CommonModules/QuanLyVongDoiChungTuServer.xml` | CommonModule XML | Metadata Common Module quản lý vòng đời chứng từ |
| 14 | `src/CommonModules/QuanLyVongDoiChungTuServer/Ext/Module.bsl` | BSL Source | Logic Maker-Checker, Ánh xạ MaLogic & Invariant GL |
| 15 | `src/CommonModules/ChartOfAccountsTest.xml` | CommonModule XML | Metadata module chạy test trong môi trường 1C |
| 16 | `src/CommonModules/ChartOfAccountsTest/Ext/Module.bsl` | BSL Source | Wrapper test runner cho `ChartOfAccountsTest` |
| 17 | `tests/unit/chart_of_accounts_test_result.log` | Test Log | Log kết quả kiểm thử tự động |

---

## 3. Chi Tiết Kỹ Thuật Hệ Thống Tài Khoản (18 Predefined Accounts)

| Mã TK (`Code`) | Tên Tài Khoản (`TenTaiKhoan`) | Tính Chất (`TinhChat`) | Mã Logic (`MaLogic`) | Mục Đích Nghiệp Vụ |
| :---: | :--- | :---: | :---: | :--- |
| `1311` | Phải thu khách hàng ngoài | `ActivePassive` | `1311` | Theo dõi công nợ AR khách hàng bên ngoài |
| `1312` | Phải thu khách hàng nội bộ Vingroup | `ActivePassive` | `1312` | AR nội bộ tập đoàn (Vingroup Intercompany) |
| `3311` | Phải trả người bán bên ngoài | `ActivePassive` | `3311` | Theo dõi công nợ AP nhà cung cấp ngoài (AWS, vendor) |
| `3312` | Phải trả người bán nội bộ Vingroup | `ActivePassive` | `3312` | AP nội bộ tập đoàn phục vụ cấn trừ netting |
| `1121` | Tiền gửi ngân hàng VND | `Active` | `1121` | Quản lý dòng tiền VND tại tài khoản ngân hàng |
| `1122` | Tiền gửi ngân hàng Ngoại tệ | `Active` | `1122` | Quản lý tiền ngoại tệ USD theo BQGQ di động |
| `1331` | Thuế GTGT được khấu trừ của HHDV | `Active` | `1331` | VAT đầu vào khấu trừ từ hóa đơn nhà cung cấp / FCT |
| `33311` | Thuế GTGT đầu ra | `Passive` | `33311` | VAT đầu ra phát sinh khi xuất hóa đơn điện tử |
| `33318` | Thuế GTGT nhà thầu (FCT VAT) | `Passive` | `33318` | Nghĩa vụ thuế VAT nhà thầu nước ngoài (AWS, Google) |
| `3338` | Thuế và các khoản nộp NN khác (FCT CIT) | `Passive` | `3338` | Thuế TNDN nhà thầu nước ngoài (FCT CIT) |
| `5113` | Doanh thu cung cấp dịch vụ | `Passive` | `5113` | Doanh thu thuần nghiệm thu dịch vụ Telematics/Cloud |
| `627` | Chi phí SXC / Chi phí dịch vụ Cloud | `Active` | `627` | Chi phí hạ tầng Cloud AWS, GPU cluster |
| `642` | Chi phí quản lý doanh nghiệp | `Active` | `642` | Chi phí hành chính và quản lý chung |
| `6427` | Chi phí DV mua ngoài / Phí ngân hàng | `Active` | `6427` | Phí giao dịch ngân hàng, cổng thanh toán |
| `635` | Chi phí tài chính / Lỗ tỷ giá | `Active` | `635` | Ghi nhận lỗ chênh lệch tỷ giá hối đoái |
| `515` | Doanh thu HĐTC / Lãi tỷ giá | `Passive` | `515` | Ghi nhận lãi chênh lệch tỷ giá hối đoái |
| `4131` | Chênh lệch tỷ giá hối đoái | `ActivePassive` | `4131` | Đánh giá lại số dư ngoại tệ cuối kỳ |
| `711` | Thu nhập khác | `Passive` | `711` | Thu phạt vi phạm hợp đồng, bồi thường |

---

## 4. Kết Quả Kiểm Thử (Unit Test Results - 100% Pass)

Kết quả chạy bộ kiểm thử tự động `tests/unit/ChartOfAccountsTest.bsl`:

```text
=================================================================
   VINSMART FUTURE - CHART OF ACCOUNTS & GL UNIT TEST (TASK 1.3) 
   Thoi gian chay: 10/10/2026 12:06:00 PM
=================================================================
[PASS] Test 1: Anh xa MaLogic -> SoHieuTK thanh cong (1312 AR Noi bo, 33318 FCT VAT).
[PASS] Test 2: Invariant can doi tien te Sum Dr = Sum Cr xac thuc thanh cong.
[PASS] Test 3: Maker-Checker chan nguoi tao tu ky duyet (khong ngoai le Admin), bypass SA thanh cong.
[PASS] Test 4: Maker-Checker cam tuyet doi nguoi tao ky lenh chi UyNhiemChi thanh cong.
-----------------------------------------------------------------
Tong so test: 4 | Thanh cong: 4 | That bai: 0
=================================================================
```

### Chi tiết các kịch bản kiểm thử:
- **Test 1:** Xác nhận ánh xạ chính xác `MaLogic = "1312"` về TK 1312 (AR Nội bộ Vingroup), `MaLogic = "33318"` về TK 33318 (FCT VAT), cũng như các tài khoản 1121, 3311, 5113, 627. Mã logic không hợp lệ bị ném lỗi rõ ràng.
- **Test 2:** Kiểm chứng Invariant cân đối tiền tệ $\sum Dr = \sum Cr$. Bút toán đơn (200tr) và bút toán đa dòng FCT Gross (250tr) cân đối tuyệt đối; bút toán mất cân đối (200tr vs 190tr) bị phát hiện và ném biệt lệ vi phạm Invariant ngay lập tức.
- **Test 3:** Xác thực nguyên tắc Maker-Checker:
  * Người tạo `NguyenVanA` tự duyệt `BienBanNghiemThuGiaiDoan` -> Bị chặn với lỗi `Vi phạm nguyên tắc Maker-Checker`.
  * Tài khoản `Admin` tự duyệt chứng từ do chính mình lập -> Bị chặn (không có bất kỳ ngoại lệ nào cho Admin).
  * Người duyệt độc lập `KeToanTruong` khác người tạo -> Cho phép duyệt thành công.
  * Tài khoản hệ thống `SA_BankingIntegration` -> Tự động bypass để ghi sổ `BaoCoNganHang`.
- **Test 4:** Xác thực lệnh chi `UyNhiemChi`:
  * Người lập lệnh chi `KeToanAP_Hung` hoặc cấp lãnh đạo `CFO_Director` tự lập lệnh chi và tự ký duyệt -> Bị chặn tuyệt đối với thông điệp: `"CẤM TUYỆT ĐỐI: Người lập lệnh chi tiền không được phép tham gia phê duyệt!"`.
  * Lệnh chi do kế toán lập và CFO độc lập ký duyệt -> Thành công.

---

## 5. Rà Soát Tuân Thủ Ràng Buộc & Tiêu Chuẩn Kỹ Thuật

- [x] **Không xâm phạm ranh giới file:** Không sửa đổi bất kỳ file nào trong `src/Catalogs/`, `src/Enums/`, `src/Constants/`, `src/Configuration.xml`.
- [x] **Quy ước đặt tên BSL:** 100% PascalCase tiếng Việt không dấu.
- [x] **Cấu trúc XML 1C:** Tuân thủ chuẩn 1C Metadata Version 2.15, đầy đủ GUIDs, Namespaces và ChildObjects.
- [x] **Test-first Approach:** Khởi tạo test suite trước, sau đó triển khai cấu hình và kiểm chứng logic.
- [x] **Tích hợp đồng bộ:** Sẵn sàng cho Orchestrator tích hợp vào `Configuration.xml` khi tổng kết Phase 1.
