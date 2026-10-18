# Kế Hoạch Triển Khai Phân Hệ Quản Lý Công Nợ AR & AP (Phiên Bản 3.0 - Pre-Implementation Audited)
**Dự án:** Phân hệ Quản lý Công nợ Phải thu (AR) & Phải trả (AP) — Công ty Cổ phần VinSmart Future (VSF), Tập đoàn Vingroup  
**Nền tảng:** 1C:Enterprise 8.3 (Platform Build 8.3.22.2243 / Managed Application / Taxi / BSL)  
**Môi trường CSDL:** MS SQL Server 2022 Enterprise / PostgreSQL 15  
**Khung Kiểm thử Tự động:** Vanessa-Automation 1.2.041 / BUnit (1C BSL Unit Testing Framework)  
**Tài liệu tham chiếu:** [2026-10-10-vinsmart-future-ar-ap-management-design.md](file:///C:/Users/Dung/Documents/1C_Enterprise/docs/superpowers/specs/2026-10-10-vinsmart-future-ar-ap-management-design.md) (Spec v5.0)  
**Ngày cập nhật:** 10/10/2026  

---

## 1. NGUYÊN TẮC THIẾT KẾ & TIÊU CHUẨN KỸ THUẬT BẮT BUỘC

1. **Ranh giới Hệ thống (System Boundaries):**
   - 1C:Enterprise là **Operational Subledger of Record**; SAP S/4HANA là **General Ledger of Record** cấp Tập đoàn.
   - Định danh 100% đối tượng và thuộc tính bằng **Tiếng Việt không dấu (PascalCase)**.
2. **Khớp nối Tuyệt đối giữa Subledger và GL (P0.1 Invariant):**
   - Mọi nghiệp vụ tăng/giảm AR/AP trên Sổ tích lũy (`CongNoPhaiThu`, `CongNoPhaiTra`) phải có bút toán đối ứng tương ứng trên Sổ cái (`TK 1312`, `TK 3311/3312`).
   - Tiêu chí nghiệm thu cốt lõi: $\Delta \text{Subledger} - \Delta \text{GL} = 0$ tuyệt đối theo từng chứng từ, đối tác, hợp đồng và đồng tiền.
3. **Quản trị Rủi ro Kế toán 2 Tầng:**
   - **Tầng 1 (Milestone 2.5 - Early Sign-off):** Kế toán trưởng và Kế toán thuế xác nhận bảng số hiệu tài khoản (TT 99/2025/TT-BTC), cơ chế FCT và Netting trước khi viết mã Phase 3.
   - **Tầng 2 (Task 8.2 - Pre-UAT Sign-off):** Nghiệm thu thiết kế tài chính trước khi chạy UAT.

---

## 2. MA TRẬN TRUY VẾT YÊU CẦU & METADATA (TRACEABILITY MATRIX - ĐỦ 69 ĐỐI TƯỢNG)

| STT | Tên Đối Tượng Metadata 1C | Loại Đối Tượng | Phase & Task Triển Khai | Test Case Kiểm Thử Chính | Trạng Thái Sign-off |
| :-: | :--- | :--- | :--- | :--- | :---: |
| 1 | `Catalog.PhapNhan` | Catalog | Phase 1: Task 1.1 | `CatalogsCoreTest.bsl` | Approved |
| 2 | `Catalog.DoiTac` | Catalog | Phase 1: Task 1.1 | `CatalogsCoreTest.bsl` | Approved |
| 3 | `Catalog.HopDong` | Catalog | Phase 1: Task 1.1 | `CatalogsCoreTest.bsl` | Approved |
| 4 | `Catalog.TaiKhoanTien` | Catalog | Phase 1: Task 1.1 | `CatalogsCoreTest.bsl` | Approved |
| 5 | `Catalog.KhoanMucDongTien` | Catalog | Phase 1: Task 1.1 | `CatalogsCoreTest.bsl` | Approved |
| 6 | `Catalog.TienTe` | Catalog | Phase 1: Task 1.1 | `CatalogsCoreTest.bsl` | Approved |
| 7 | `Catalog.DuAn` | Catalog | Phase 1: Task 1.1 | `CatalogsCoreTest.bsl` | Approved |
| 8 | `Catalog.DichVuCNTT` | Catalog | Phase 1: Task 1.1 | `CatalogsCoreTest.bsl` | Approved |
| 9 | `Catalog.KenhThanhToan` | Catalog | Phase 1: Task 1.1 | `CatalogsCoreTest.bsl` | Approved |
| 10 | `Catalog.TaiKhoanAo` | Catalog | Phase 1: Task 1.1 | `CatalogsCoreTest.bsl` | Approved |
| 11 | `Enum.TrangThaiNghiemThuAR` | Enumeration | Phase 1: Task 1.2 | `EnumsConstantsTest.bsl` | Approved |
| 12 | `Enum.TrangThaiHoaDonAP` | Enumeration | Phase 1: Task 1.2 | `EnumsConstantsTest.bsl` | Approved |
| 13 | `Enum.TrangThaiLenhThanhToan` | Enumeration | Phase 1: Task 1.2 | `EnumsConstantsTest.bsl` | Approved |
| 14 | `Enum.TrangThaiCanTru` | Enumeration | Phase 1: Task 1.2 | `EnumsConstantsTest.bsl` | Approved |
| 15 | `Enum.TrangThaiHoaDonDienTu` | Enumeration | Phase 1: Task 1.2 | `EnumsConstantsTest.bsl` | Approved |
| 16 | `Enum.LoaiDoiTac` | Enumeration | Phase 1: Task 1.2 | `EnumsConstantsTest.bsl` | Approved |
| 17 | `Enum.HuongDongTien` | Enumeration | Phase 1: Task 1.2 | `EnumsConstantsTest.bsl` | Approved |
| 18 | `Enum.TrangThaiDongBo` | Enumeration | Phase 1: Task 1.2 | `EnumsConstantsTest.bsl` | Approved |
| 19-30 | 12 Constants Hệ thống | Constants | Phase 1: Task 1.2 | `EnumsConstantsTest.bsl` | Pending-Signoff |
| 31 | `ChartOfAccounts.HeThongTaiKhoan` | Chart of Accounts | Phase 1: Task 1.3 | `ChartOfAccountsTest.bsl` | Pending-Signoff |
| 32 | `AccountingRegister.SoCaiKeToan` | Accounting Reg | Phase 1: Task 1.3 | `ChartOfAccountsTest.bsl` | Approved |
| 33-41 | 9 Roles Phân quyền | Roles | Phase 1: Task 1.3 | `RolesSecurityTest.bsl` | Approved |
| 42 | `AccumulationRegister.CongNoPhaiThu` | Accumulation Reg | Phase 2: Task 2.1 | `AccumulationRegistersTest.bsl` | Approved |
| 43 | `AccumulationRegister.CongNoPhaiTra` | Accumulation Reg | Phase 2: Task 2.1 | `AccumulationRegistersTest.bsl` | Approved |
| 44 | `AccumulationRegister.DongTien` | Accumulation Reg | Phase 2: Task 2.1 | `AccumulationRegistersTest.bsl` | Approved |
| 45 | `AccumulationRegister.GiaoDichDienTuTamGiu` | Accumulation Reg | Phase 2: Task 2.1 | `AccumulationRegistersTest.bsl` | Approved |
| 46 | `InformationRegister.TyGiaHoiDoai` | Information Reg | Phase 2: Task 2.2 | `InformationRegistersTest.bsl` | Approved |
| 47 | `InformationRegister.HanMucVaChanXuatDichVu`| Information Reg | Phase 2: Task 2.2 | `InformationRegistersTest.bsl` | Approved |
| 48 | `InformationRegister.TrangThaiDongBoSAP` | Information Reg | Phase 2: Task 2.2 | `InformationRegistersTest.bsl` | Approved |
| 49 | `InformationRegister.LichSuGiaoDichNganHang` | Information Reg | Phase 2: Task 2.2 | `InformationRegistersTest.bsl` | Approved |
| 50 | `InformationRegister.KeHoachChiTien` | Information Reg | Phase 2: Task 2.2 | `InformationRegistersTest.bsl` | Approved |
| 51 | `Document.BienBanNghiemThuGiaiDoan` | Document | Phase 3: Task 3.1 | `BienBanNghiemThuTest.bsl` | Approved |
| 52 | `Document.HoaDonGTGTDauRa` | Document | Phase 3: Task 3.2 | `HoaDonGTGTDauRaTest.bsl` | Approved |
| 53 | `Document.DieuChinhCongNo` | Document | Phase 3: Task 3.3 | `TranhChapSauGhiSoTest.bsl` | Approved |
| 54 | `Document.PhieuThuTienKhachHang` | Document | Phase 3: Task 3.4 | `PhieuThuTienTest.bsl` | Approved |
| 55 | `Document.HoaDonNhaCungCap` | Document | Phase 4: Task 4.1 | `HoaDonNhaCungCapTest.bsl` | Pending-Signoff |
| 56 | `Document.UyNhiemChi` | Document | Phase 4: Task 4.3 | `UyNhiemChiStateReversalTest.bsl` | Approved |
| 57 | `Document.DeNghiThanhToanDichVu` | Document | Phase 4: Task 4.4 | `DeNghiThanhToanTest.bsl` | Approved |
| 58 | `Document.NghiemThuThauPhu` | Document | Phase 4: Task 4.4 | `NghiemThuThauPhuTest.bsl` | Approved |
| 59 | `Document.BaoCoNganHang` | Document | Phase 5: Task 5.1 | `WebhookIdempotencyTest.bsl` | Approved |
| 60 | `Document.BangKeDoiSoatKenhThanhToan` | Document | Phase 5: Task 5.3 | `DoiSoatKenhThanhToanTest.bsl` | Approved |
| 61 | `Document.YeuCauHoanTienChiHo` | Document | Phase 5: Task 5.3 | `DoiSoatKenhThanhToanTest.bsl` | Approved |
| 62 | `Document.CanTruCongNoNoiBo` | Document | Phase 6: Task 6.1 | `MaTranCanTruNettingTest.bsl` | Approved |
| 63 | `DataProcessor.DongCoDoiSoatTuDong` | Data Processor | Phase 5: Task 5.2 | `DongCoDoiSoatTest.bsl` | Approved |
| 64 | `DataProcessor.LapMaTranCanTruTapDoan` | Data Processor | Phase 6: Task 6.1 | `MaTranCanTruNettingTest.bsl` | Approved |
| 65 | `DataProcessor.DongBoButToanSAP` | Data Processor | Phase 7: Task 7.3 | `DongBoSAPIntegrationTest.bsl` | Approved |
| 66 | `Report.BaoCaoTuoiNoPhanTachNoiBo` | Report | Phase 6: Task 6.2 | `BaoCaoTuoiNoVaSafetyGateTest.bsl` | Approved |
| 67 | `Report.MaTranCanTruNoiBoTapDoan` | Report | Phase 6: Task 6.3 | `BaoCaoNettingReportTest.bsl` | Approved |
| 68 | `Report.DoiSoatKenhThanhToanVaDongTienAo` | Report | Phase 6: Task 6.3 | `BaoCaoDoiSoatKenhTest.bsl` | Approved |
| 69 | `Report.CanhBaoHanMucVaGiaHanCloud` | Report | Phase 6: Task 6.3 | `BaoCaoCanhBaoCloudTest.bsl` | Approved |

---

## 3. KẾ HOẠCH TRIỂN KHAI CHI TIẾT THEO 8 GIAI ĐOẠN (TEST-DRIVEN DEVELOPMENT)

### Phase 1: Nền Tảng Metadata Cốt Lõi, Hệ Thống Tài Khoản & Phân Quyền RLS

#### Task 1.1: Khởi tạo 10 Danh mục (Catalogs) & Thiết Lập RLS Phân Quyền Pháp Nhân (P1.2)
- **Mục tiêu**: Định nghĩa 10 Catalogs. `Catalog.HopDong` bắt buộc có thuộc tính `PhapNhan`. `Catalog.DoiTac` là danh mục dùng chung (Shared) cấp Tập đoàn.
- **File tác động**:
  - `tests/unit/CatalogsCoreTest.bsl` (New)
  - `src/Catalogs/PhapNhan.xml` đến `src/Catalogs/TaiKhoanAo.xml` (10 files New)
- **Implementation & Tests**:
  1. *Test-First Red*: Kiểm tra User VSF Corp không đọc được Hợp đồng thuộc VSF Software qua Session Parameter `#PhapNhanAccess(PhapNhan)`.
  2. *Schema Definition*: Khai báo trường `PhapNhan` (CatalogRef.PhapNhan) trên `Catalog.HopDong`.
  3. *Validation*: Kiểm tra `HanThanhToanNgay > 0` (mặc định 30).
- **Tiêu chuẩn nghiệm thu**: Khởi tạo đủ 10 Catalogs; RLS chặn người dùng truy cập chéo pháp nhân trái thẩm quyền.

#### Task 1.2: Khởi tạo 8 Enums & Khởi Tạo Đủ 12 Constants Hệ Thống
- **Mục tiêu**: Khai báo 8 Enums vòng đời và nạp giá trị mặc định cho toàn bộ 12 Constants.
- **File tác động**:
  - `tests/unit/EnumsConstantsTest.bsl` (New)
  - `src/Enums/*.xml` (8 files New), `src/Constants/*.xml` (12 files New)
- **Giá trị khởi tạo chuẩn xác cho 12 Constants**:
  1. `PhapNhanMacDinh`: "VSF_CORP"
  2. `NguongPheDuyetChiTienCFO`: 500,000,000 VND
  3. `TaiKhoanTrungGianCanTru`: "1388"
  4. `TuDongDongBoSAP`: True
  5. `NguongThanhToanKhongDungTienMat`: 5,000,000 VND
  6. `TaiKhoanPhiNganHang`: "6427"
  7. `SoLuongHoaDonFIFOMax`: 2
  8. `GiaTriFIFOMax`: 100,000,000 VND
  9. `TimeoutChoCanTruPhut`: 120 phút
  10. `CanhBaoCloudMucVang`: 30 ngày
  11. `CanhBaoCloudMucCam`: 14 ngày
  12. `CanhBaoCloudMucDo`: 7 ngày
- **Tiêu chuẩn nghiệm thu**: Đủ 8 Enums và 12 Constants, không trả về giá trị rỗng/Null.

#### Task 1.3: Cấu hình `HeThongTaiKhoan`, Sổ Cái `SoCaiKeToan` & Maker-Checker Tập Trung (P0.4 & P1.3)
- **Mục tiêu**: Xây dựng bảng tài khoản ánh xạ `MaLogic -> SoHieuTK`, sổ kép kiểm soát Invariant và Module phê duyệt tập trung không có ngoại lệ Admin.
- **File tác động**:
  - `tests/unit/ChartOfAccountsTest.bsl` (New)
  - `src/ChartsOfAccounts/HeThongTaiKhoan.xml` (New)
  - `src/AccountingRegisters/SoCaiKeToan.xml` (New)
  - `src/CommonModules/QuanLyVongDoiChungTuServer.bsl` (New)
- **Logic & Code kiểm soát**:
  - Invariant kiểm tra cân đối tiền tệ: $\sum \text{AmountDr} = \sum \text{AmountCr}$ trên từng dòng giao dịch.
  - Hàm kiểm tra chuyển trạng thái tập trung:
    ```bsl
    Procedure KiemTraChuyenTrangThai(ChungTuRef, TrangThaiMoi, CurrentUser) Export
        // Cấm tuyệt đối người lập tự phê duyệt (Maker-Checker, không ngoại lệ Admin)
        If ChungTuRef.Author = CurrentUser Then
            Raise "Vi phạm nguyên tắc Maker-Checker: Người tạo không thể tự phê duyệt chứng từ!";
        EndIf;
        
        // Riêng Lệnh chi tiền, cấm tuyệt đối mọi hình thức tự duyệt
        If TypeOf(ChungTuRef) = Type("DocumentRef.UyNhiemChi") And ChungTuRef.Author = CurrentUser Then
            Raise "CẤM TUYỆT ĐỐI: Người lập lệnh chi tiền không được phép tham gia phê duyệt!";
        EndIf;
    EndProcedure
    ```
- **Tiêu chuẩn nghiệm thu**: Invariant cân đối tiền tệ được xác thực; Maker-Checker chặn người tạo tự duyệt.

---

### Phase 2: Sổ Tích Lũy, Sổ Thông Tin & Thư Viện Xử Lý Ngoại Tệ

#### Task 2.1: Sổ Tích Lũy Dual Subledger & Schema Đầy Đủ Sổ `DongTien` (P1.1)
- **Mục tiêu**: Xây dựng 4 Sổ tích lũy độc lập. Khai báo đầy đủ 2 resource `SoTien` (VND) và `SoTienNgoaiTe` (USD) trên `AccumulationRegister.DongTien`.
- **File tác động**:
  - `tests/unit/AccumulationRegistersTest.bsl` (New)
  - `src/AccumulationRegisters/DongTien.xml` (New)
  - `src/AccumulationRegisters/CongNoPhaiThu.xml`, `CongNoPhaiTra.xml`, `GiaoDichDienTuTamGiu.xml` (New)
- **Tiêu chuẩn nghiệm thu**: Schema `DongTien` hỗ trợ truy vấn cả số dư VND và ngoại tệ.

#### Task 2.2: Cấu hình 5 Sổ Thông Tin (Information Registers)
- **Mục tiêu**: Xây dựng 5 Sổ thông tin với Unique Key Constraint trên `LichSuGiaoDichNganHang.IdempotencyKey`.
- **File tác động**:
  - `tests/unit/InformationRegistersTest.bsl` (New)
  - `src/InformationRegisters/*.xml` (5 files New)

#### Task 2.3: Thư viện `XuLyNgoaiTeServer`: BQGQ Di Động & 5 Kịch Bản Edge Cases (P1.1)
- **Mục tiêu**: Xây dựng hàm tính tỷ giá BQGQ lọc bắt buộc theo `PhapNhan`, `TaiKhoanTien`, `TienTe` và thời điểm.
- **File tác động**:
  - `tests/unit/XuLyNgoaiTeTest.bsl` (New)
  - `src/CommonModules/XuLyNgoaiTeServer.bsl` (New)
- **5 Kịch bản Test Bắt buộc**:
  1. *Test số dư đầu kỳ = 0:* Mua 10k USD @ 25.250 -> BQGQ = 25.250. Xuất quỹ trả nợ HĐ ghi sổ 25.000 -> Lỗ tỷ giá đúng 2.500.000 VND vào TK 635.
  2. *Test nhiều lần mua ngoại tệ:* Mua lần 1: 5k USD @ 25.000. Mua lần 2: 5k USD @ 25.200 -> BQGQ = 25.100.
  3. *Test xuất một phần:* Xuất 3k USD từ số dư 10k USD -> Số dư còn lại 7k USD giữ nguyên tỷ giá BQGQ.
  4. *Test số dư <= 0:* Ném lỗi rõ ràng: `"Không thể xuất quỹ ngoại tệ: Số dư nguyên tệ bằng 0 hoặc âm!"`.
  5. *Test phân lập pháp nhân:* VSF Corp và VSF Software cùng có tiền USD nhưng không bị tính lẫn số dư của nhau.
- **Tiêu chuẩn nghiệm thu**: 5/5 kịch bản test BQGQ đạt kết quả PASS.

#### Task 2.4: Thư viện `PheDuyetDaCapServer`: Anti-Split Quét Hóa Đơn Trong Tháng
- **Mục tiêu**: Quét tổng giá trị các hóa đơn mua dịch vụ phát sinh trong tháng (`Doc.TongTien` từ `HoaDonNhaCungCap` có `Posted = True`).
- **File tác động**:
  - `tests/unit/PheDuyetDaCapTest.bsl` (New)
  - `src/CommonModules/PheDuyetDaCapServer.bsl` (New)

#### Milestone 2.5: Early Financial & Tax Architecture Sign-off (Mốc Rà Soát Sớm Trước Phase 3)
- **Mục tiêu**: Rà soát chính thức với Kế toán trưởng và Kế toán thuế VSF về 3 nội dung trọng yếu trước khi bước vào viết code phân hệ AR/AP:
  1. Xác nhận biểu tài khoản TT 99/2025/TT-BTC và bảng ánh xạ `MaLogic -> SoHieuTK`.
  2. Xác nhận mô hình FCT Khấu trừ tại nguồn (Withholding) và tỷ lệ thuế suất TT 103.
  3. Xác nhận quy tắc thuế suất VAT 8% (NQ 204/2025) vs 10% theo từng loại dịch vụ.
- **Đầu ra**: Biên bản Sign-off kiến trúc tài chính sớm; cập nhật cấu hình mà không sửa code BSL.

---

### Phase 3: Phân Hệ Nghiệp Vụ AR Intercompany & e-Invoice Khớp Nối Subledger 100%

#### Task 3.1: Chứng từ `BienBanNghiemThuGiaiDoan`: Ghi Tăng Doanh Thu Thuần (P0.1)
- **Mục tiêu**: Ghi nhận Doanh thu thuần dịch vụ:
  $$\text{Nợ TK 1312 / Có TK 5113: 200tr} \quad \& \quad \text{CongNoPhaiThu.AddReceipt(): 200tr}$$
- **File tác động**:
  - `tests/unit/BienBanNghiemThuTest.bsl` (New)
  - `src/Documents/BienBanNghiemThuGiaiDoan.xml` (New)
- **Tiêu chuẩn nghiệm thu**: Sổ chi tiết và GL đều tăng 200tr.

#### Task 3.2: Chứng từ `HoaDonGTGTDauRa`: Ghi Tăng VAT Trên Cả Subledger & GL (P0.1)
- **Mục tiêu**: Là nơi phát sinh nghĩa vụ thuế VAT đầu ra. Ghi nhận:
  $$\text{Nợ TK 1312 / Có TK 33311: 20tr} \quad \& \quad \text{CongNoPhaiThu.AddReceipt(): 20tr}$$
  *(Lưu vết `ChungTuGoc = BienBanNghiemThuGiaiDoan` liên quan)*.
- **File tác động**:
  - `tests/unit/HoaDonGTGTDauRaTest.bsl` (New)
  - `src/Documents/HoaDonGTGTDauRa.xml` (New)
- **Tiêu chuẩn nghiệm thu (Reconciliation Invariant)**:
  - Tổng dư nợ Subledger `CongNoPhaiThu` $= 220.000.000$ VND.
  - Tổng số dư Nợ TK 1312 trên `SoCaiKeToan` $= 220.000.000$ VND.
  - $\Delta \text{Variance} = 0$ tuyệt đối!

#### Task 3.3: Xử Lý Tranh Chấp Sau Ghi Sổ: `DieuChinhCongNo` Ghi Sổ Duy Nhất (P0.3)
- **Mục tiêu**: Có Biên bản thỏa thuận sai sót giữa hai bên (NĐ 70/2025/NĐ-CP). `HoaDonGTGTDauRa` điều chỉnh là phi bút toán; `DieuChinhCongNo` là chứng từ DUY NHẤT sinh bút toán kép gộp giảm Doanh thu, Thuế VAT và giảm Subledger Gross.
- **File tác động**:
  - `tests/unit/TranhChapSauGhiSoTest.bsl` (New)
  - `src/Documents/DieuChinhCongNo.xml` (New)
- **Assert kiểm tra**:
  - Sổ `CongNoPhaiThu` giảm đúng 20.000.000 VND (Gross).
  - GL ghi nhận: `Nợ TK 5113: 18.181.818, Nợ TK 33311: 1.818.182 / Có TK 1312: 20.000.000`.
  - Regression Assert: Tổng Có TK 1312 đúng 20.000.000đ (không bị cộng trùng thành 21.818.182đ).

#### Task 3.4: Chứng từ `PhieuThuTienKhachHang`
- **Mục tiêu**: Xây dựng chứng từ thu tiền mặt hoặc thu tiền trực tiếp ngoài ngân hàng, phân bổ gạch nợ trên `PhanBoThanhToan`.
- **File tác động**:
  - `tests/unit/PhieuThuTienTest.bsl` (New)
  - `src/Documents/PhieuThuTienKhachHang.xml` (New)

---

### Phase 4: Phân Hệ AP Cloud, Lệnh Chi Ngân Hàng & Quy Trình Reversal Chuẩn Xác

#### Task 4.1: Chứng từ `HoaDonNhaCungCap`: FCT Khấu Trừ Tại Nguồn Chuẩn Xác (P0.4)
- **Mục tiêu**: Hạch toán hóa đơn AWS USD theo mô hình Khấu trừ tại nguồn (Giả định 4: Gross 250tr đã gồm thuế FCT):
  $$\text{Nợ TK 627: 237.5tr, Nợ TK 1331: 12.5tr / Có TK 3311: 225tr, Có TK 33318: 12.5tr, Có TK 3338: 12.5tr}$$
- **File tác động**:
  - `tests/unit/HoaDonNhaCungCapTest.bsl` (New)
  - `src/Documents/HoaDonNhaCungCap.xml` (New)
- **Tiêu chuẩn nghiệm thu**: Chi phí VSF đúng 237.5tr, nợ thực trả NCC đúng 225tr.

#### Task 4.2: Luồng Phê Duyệt 4+1 Cấp với Nhánh Duyệt CFO khi Vượt Ngân Sách > 10%
- **File tác động**:
  - `tests/unit/WorkflowPheDuyetAPTest.bsl` (New)
  - `src/Documents/HoaDonNhaCungCap/Forms/DocumentForm.bsl` (New)

#### Task 4.3: Chứng từ `UyNhiemChi`: Ghi Sổ Khi Ngân Hàng Xác Nhận & Xử Lý Reversal Thực Tế (P0.2)
- **Mục tiêu**: Khi `DaGuiNganHang`: CHƯA ghi sổ GL. Chỉ ghi sổ khi ngân hàng xác nhận thành công. Ngân hàng từ chối -> Chuyển `TuChoi`, KHÔNG sinh bút toán đảo. Reversal chỉ áp dụng khi có điện tra soát hoàn trả cho lệnh đã ghi sổ.
- **File tác động**:
  - `tests/unit/UyNhiemChiStateReversalTest.bsl` (New)
  - `src/Documents/UyNhiemChi.xml` (New)
- **Tiêu chuẩn nghiệm thu**: Không sinh bút toán rác khi ngân hàng từ chối lệnh chi.

#### Task 4.4: Chứng từ `DeNghiThanhToanDichVu` & `NghiemThuThauPhu`
- **Mục tiêu**: Xây dựng 2 chứng từ phục vụ quản lý thầu phụ gia công phần cứng và đề nghị thanh toán nội bộ.
- **File tác động**:
  - `tests/unit/DeNghiThanhToanTest.bsl`, `tests/unit/NghiemThuThauPhuTest.bsl` (New)
  - `src/Documents/DeNghiThanhToanDichVu.xml`, `src/Documents/NghiemThuThauPhu.xml` (New)

---

### Phase 5: Động Cơ Đối Soát Tự Động 3 Tầng & Xử Lý Lệch Dòng Tiền

#### Task 5.1: Webhook Ngân Hàng, Idempotency Nguyên Tử & Conflict 409 (P3.1)
- **Mục tiêu**: Xử lý Webhook trong Atomic Transaction. Trùng key cùng payload -> 200 OK. Trùng key khác payload -> 409 Conflict.
- **File tác động**:
  - `tests/unit/WebhookIdempotencyTest.bsl` (New)
  - `src/HTTPServices/WebhookNganHang.xml` (New)
  - `src/Documents/BaoCoNganHang.xml` (New)

#### Task 5.2: Động Cơ Đối Soát Tầng 2 & Tầng 3
- **Mục tiêu**: Dung sai khách ngoài $\le 1.000$đ; Dung sai nội bộ Vingroup tuyệt đối bằng 0 (chuyển sang Tầng 3 treo đích danh mã đối tác).
- **File tác động**:
  - `tests/unit/DongCoDoiSoatTest.bsl` (New)
  - `src/DataProcessors/DongCoDoiSoatTuDong.xml` (New)

#### Task 5.3: Đối Soát Kênh Thanh Toán & Hoàn Tiền B2C
- **File tác động**:
  - `tests/unit/DoiSoatKenhThanhToanTest.bsl` (New)
  - `src/Documents/BangKeDoiSoatKenhThanhToan.xml`, `src/Documents/YeuCauHoanTienChiHo.xml` (New)

---

### Phase 6: Bù Trừ Công Nợ Đa Bên (Netting), Báo Cáo Aging & Operational Safety Gate

#### Task 6.1: Động Cơ `LapMaTranCanTruTapDoan` & Watchdog Timeout (Không Lock 120 Phút) (P3.2)
- **Mục tiêu**: Quét nợ chéo sinh ma trận netting. Chứng từ mang trạng thái `ChoCanTru`, lưu `TrangThaiTruocDo`. Scheduled Job Watchdog quét định kỳ 5 phút để giải phóng chứng từ quá hạn 120p. Không giữ database lock dài hạn.
- **File tác động**:
  - `tests/unit/MaTranCanTruNettingTest.bsl` (New)
  - `src/DataProcessors/LapMaTranCanTruTapDoan.xml` (New)
  - `src/Documents/CanTruCongNoNoiBo.xml` (New)

#### Task 6.2: Báo Cáo Tuổi Nợ `BaoCaoTuoiNoPhanTachNoiBo` & Operational Safety Gate
- **Mục tiêu**: Tính Aging từ `DueDate`. Đối tác nội bộ Vingroup quá hạn: CẤM tự động khóa dịch vụ, chỉ cảnh báo CFO.
- **File tác động**:
  - `tests/unit/BaoCaoTuoiNoVaSafetyGateTest.bsl` (New)
  - `src/Reports/BaoCaoTuoiNoPhanTachNoiBo.xml` (New)

#### Task 6.3: Xây Dựng 3 Báo Cáo Chuyên Sâu Cấp Tập Đoàn
- **Mục tiêu**: Xây dựng 3 báo cáo:
  1. `Report.MaTranCanTruNoiBoTapDoan`: Trực quan hóa ma trận bù trừ nợ đa bên.
  2. `Report.DoiSoatKenhThanhToanVaDongTienAo`: Đối chiếu tiền về qua cổng thanh toán & Virtual Account.
  3. `Report.CanhBaoHanMucVaGiaHanCloud`: Cảnh báo hạn mức sử dụng và thời hạn gói Cloud (Vàng/Cam/Đỏ).
- **File tác động**:
  - `tests/unit/BaoCaoChuyenSauTest.bsl` (New)
  - `src/Reports/MaTranCanTruNoiBoTapDoan.xml`, `DoiSoatKenhThanhToanVaDongTienAo.xml`, `CanhBaoHanMucVaGiaHanCloud.xml` (3 files New)

---

### Phase 7: Tích Hợp Hệ Thống Bên Ngoài (External Integrations)

#### Task 7.1: Tích Hợp Webhook Ngân Hàng, HMAC-SHA256 & So Sánh Hằng Thời Gian
- **File tác động**:
  - `tests/integration/BankingWebhookIntegrationTest.bsl` (New)
  - `src/CommonModules/TichHopNganHangServer.bsl` (New)

#### Task 7.2: Tích Hợp HĐĐT HSM & Scheduled Job Nạp Tỷ Giá
- **File tác động**:
  - `tests/integration/EInvoiceAndFXIntegrationTest.bsl` (New)
  - `src/CommonModules/TichHopHoaDonDienTuServer.bsl` (New)
  - `src/ScheduledJobs/CapNhatTyGiaNgoaiTeTuDong.xml` (New)

#### Task 7.3: Động Cơ `DongBoButToanSAP`: Batch 22:00, Retry 3 Lần & Outbox Audit Trail
- **File tác động**:
  - `tests/integration/DongBoSAPIntegrationTest.bsl` (New)
  - `src/DataProcessors/DongBoButToanSAP.xml` (New)
  - `src/ScheduledJobs/DongBoSAPHangNgay.xml` (New)

---

### Phase 8: Data Migration, Go-Live Cutover, Parallel Run & Rollback

#### Task 8.1: Migration Số Dư Đầu Kỳ AR/AP, Tiền Mặt & Quỹ Ngoại Tệ
- **File tác động**:
  - `tests/migration/MigrationSoDuDauKyTest.bsl` (New)
  - `src/DataProcessors/NapSoDuDauKy.xml` (New)

#### Task 8.2: Milestone "Financial & Tax Sign-off Checkpoint" Trước UAT
- **Mục tiêu**: Nghiệm thu thiết kế tài chính chính thức với Kế toán trưởng và Kế toán thuế trước khi bước vào UAT.

#### Task 8.3: UAT Toàn Trình, Kế Hoạch Cutover, Chạy Song Song & Rollback
- **Mục tiêu**: Thực hiện kịch bản kiểm thử chấp nhận người dùng toàn diện, thiết lập kế hoạch chạy song song, cơ chế rollback và chuyển giao hệ thống vận hành chính thức.
- **Kế hoạch Cutover & Vận hành Chuyển đổi**:
  1. *Chạy song song (Parallel Run):* Vận hành song song 1C Subledger với quy trình kế toán cũ/SAP trong **2 tuần đầu tiên** để đối chiếu chéo số liệu phát sinh hằng ngày.
  2. *Quy trình Rollback khẩn cấp:* Nếu phát sinh sai lệch số liệu trọng yếu không thể khắc phục trong 4 giờ, kích hoạt quy trình Rollback về bản backup Infobase (`.dt`) trước giờ Cutover.
  3. *Đối chiếu Ngày đầu tiên (Day 1 Reconciliation Check):* Cuối ngày Golive đầu tiên, chạy đối chiếu 100% số dư giữa 1C Subledger và SAP GL để ký biên bản bàn giao Day 1.

---

## 4. TIÊU CHUẨN NGHIỆM THU ĐO ĐƯỢC (MEASURABLE ACCEPTANCE CRITERIA)

1. **Reconciliation Invariant:** $\text{Variance} = |\Delta \text{CongNoPhaiThu} - \Delta \text{TK 1312}| = 0$ trên 100% chứng từ AR ghi sổ.
2. **Double-Posting Prevention:** Tổng phát sinh Có TK 1312 khi điều chỉnh giảm nợ đúng bằng số tiền thỏa thuận, không bị lệch thuế.
3. **No Phantom Reversal:** 0 bút toán đảo phát sinh khi lệnh chi bị ngân hàng từ chối trước khi ghi sổ.
4. **Zero-Tolerance Intercompany:** 100% giao dịch B2B nội bộ Vingroup đối soát không áp dụng dung sai làm tròn.
5. **Operational Safety:** 0 cuộc gọi ngắt dịch vụ API tự động phát sinh đối với đơn vị thành viên Vingroup.
