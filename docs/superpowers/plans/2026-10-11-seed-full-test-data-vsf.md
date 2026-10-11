# Kế Hoạch Triển Khai Sinh Dữ Liệu Test Quy Mô Lớn (5.000 – 7.000 Chứng Từ) Hệ Thống AR/AP VinSmart Future

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Xây dựng module tự động hóa sinh khối lượng lớn dữ liệu nghiệp vụ thực tế (~300 Master Data, 5.000 – 7.000 chứng từ AR/AP/Netting/Ngân hàng giai đoạn 01/01/2025 – 30/09/2026) tuân thủ 100% chuẩn kế toán VAS và các Invariant nền tảng 1C của VinSmart Future, xác minh toàn vẹn số sách và đóng gói thành `VinSmart_Future_AR_AP_Test_FULLDATA.dt`.

**Architecture:** Kiến trúc phân mẻ giao dịch tập trung (Batch Transaction Architecture) chạy trực tiếp trong server runtime của 1C:Enterprise qua các CommonModule chuyên trách (`GeneratorMasterDataServer`, `GeneratorARServer`, `GeneratorAPServer`, `GeneratorNettingReconcileServer`, `SeedFullTestDataServer`), điều khiển qua tham số khởi động `/C "SeedFullTestData"`. Mỗi khối nghiệp vụ được ghi theo mẻ 100 chứng từ/transaction, đảm bảo hiệu năng cao, không tràn RAM/khóa bảng trên file CSDL 1CD, và tích hợp bộ kiểm toán đối soát chéo (Reconciliation Engine) xác thực $\sum Nợ = \sum Có$ (DELTA = 0).

**Tech Stack:** 1C:Enterprise 8.3.22 (BSL), AccountingRegister đối ứng (`SoCaiKeToan`), AccumulationRegisters (`CongNoPhaiThu`, `CongNoPhaiTra`, `DongTien`), PowerShell 5.1 / Python 3.14 điều phối kiểm thử tự động, VAS (Thông tư 200/2014/TT-BTC).

**Spec:** Yêu cầu người dùng tại prompt nghiệp vụ VSF (Giai đoạn 01/01/2025 – 30/09/2026, 5.000 – 7.000 chứng từ, seed ngẫu nhiên cố định = 2026, nguyên tắc an toàn CSDL, tỷ lệ tuổi nợ 70/15/8/4/3%, 3–5% edge cases có chủ đích).

## Global Constraints

- Bản sao an toàn: Bắt buộc tạo `VinSmart_Future_AR_AP_Test.ORIGINAL.dt` trước khi thao tác dữ liệu.
- Môi trường thử nghiệm cách ly: Chỉ sinh dữ liệu trên cơ sở dữ liệu thử riêng biệt `Infobase_FullData`, không tác động lên CSDL làm việc hiện tại.
- Tiền tố nhận diện test: Toàn bộ dữ liệu phát sinh phải mang tiền tố `TEST_` trong Mã đối tượng hoặc Diễn giải.
- Dữ liệu mô phỏng bảo mật: Toàn bộ MST (10 hoặc 13 số), số tài khoản, email (`@vinsmartfuture.test`), số hợp đồng đều là giả lập hợp lệ; không dùng dữ liệu nhạy cảm thật.
- Tính lặp lại (Idempotency): Khởi tạo seed số ngẫu nhiên cố định = 2026; chạy lại nhiều lần cho ra cùng một kết quả nhất quán.
- Tuân thủ Invariant P0.1: `BienBanNghiemThuGiaiDoan` chỉ ghi nhận doanh thu thuần Nợ 1311/1312 Có 5113 (CHƯA thuế VAT); `HoaDonGTGTDauRa` ghi nhận thuế Nợ 1311/1312 Có 33311 gắn liên kết nghiệm thu.
- Tuân thủ Invariant Maker-Checker: Người tạo khác Người duyệt; riêng `UyNhiemChi` cấm tuyệt đối người lập tham gia phê duyệt.
- Tuân thủ Invariant Sổ cái: Cân đối kép $\sum Nợ = \sum Có$ tuyệt đối (DELTA = 0); ngoại tệ dùng `RecordGL.SoTienNgoaiTe` duy nhất.
- Thuần nền tảng 1C: Không dùng `TextWriter` ghi file ra đĩa OS bên ngoài; toàn bộ nhật ký ghi qua `WriteLogEvent` chuẩn của nền tảng 1C.

## Review Focus

1. **Khóa dữ liệu và hiệu năng khi nạp >5.000 chứng từ:** Không bọc toàn bộ 5.000 chứng từ trong 1 transaction duy nhất (sẽ gây Out of Memory hoặc treo file DB); bắt buộc chia mẻ 50–100 chứng từ/giao dịch.
2. **Lệch số dư giữa Sổ cái và Sổ công nợ:** Số tiền trên chứng từ nghiệm thu/hóa đơn phải đồng bộ chính xác giữa bản ghi Sổ cái `SoCaiKeToan` và bản ghi sổ tích lũy `CongNoPhaiThu` / `CongNoPhaiTra`.
3. **Thao tác hoàn tiền/hủy ghi không để lại rác:** Khi xử lý biên hoặc lỗi trạng thái, cờ `RegisterRecords.Write = True` phải được kích hoạt để dọn dẹp tập bản ghi cũ.
4. **Vi phạm kiểm tra Maker-Checker:** Tài khoản chạy seed phải thiết lập cặp `NguoiTao` và `NguoiDuyet` hợp lệ (ví dụ: `KeToanAR` và `CFO`), hoặc sử dụng tài khoản hệ thống `SA_BankingIntegration`.
5. **Đồng tiền và tỷ giá ngoại tệ:** Bút toán USD phải có tỷ giá quy đổi tương ứng trong `TyGiaHoiDoai` tại ngày chứng từ, và dòng phí ngân hàng trong `UyNhiemChi` phải dùng đồng bản tệ VND.

---

### Task 1: Khởi Tạo Môi Trường Thử Nghiệm & Cơ Chế Bản Sao An Toàn

**Files:**
- Create: `scripts/backup_and_prepare_env.ps1`
- Test: `scripts/test_env_isolation.py`

**Interfaces:**
- Consumes: `VinSmart_Future_AR_AP_Test.dt`, `C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe`
- Produces: `VinSmart_Future_AR_AP_Test.ORIGINAL.dt`, thư mục CSDL cô lập `C:\Users\Dung\Documents\1C_Enterprise\Infobase_FullData`

- [ ] **Step 1: Viết test kiểm tra tính cô lập môi trường**

Tạo `scripts/test_env_isolation.py` kiểm tra:
1. File `VinSmart_Future_AR_AP_Test.ORIGINAL.dt` tồn tại và có dung lượng > 0.
2. Thư mục `Infobase_FullData` tồn tại độc lập với `Infobase`.
3. Kiểm tra file `1Cv8.1CD` trong `Infobase_FullData` đã được khởi tạo.

- [ ] **Step 2: Chạy test để xác nhận FAIL trước khi thực hiện**

Run: `python scripts/test_env_isolation.py`
Expected: FAIL với thông báo `VinSmart_Future_AR_AP_Test.ORIGINAL.dt not found` hoặc `Infobase_FullData not found`.

- [ ] **Step 3: Triển khai script `scripts/backup_and_prepare_env.ps1`**

Script thực hiện:
1. `Copy-Item VinSmart_Future_AR_AP_Test.dt VinSmart_Future_AR_AP_Test.ORIGINAL.dt -Force`.
2. Tạo thư mục `Infobase_FullData`.
3. Khởi tạo và phục hồi CSDL bằng lệnh:
   `1cv8t.exe CREATEINFOBASE File="...\Infobase_FullData"`
   `1cv8t.exe DESIGNER /F "...\Infobase_FullData" /RestoreIB "...\VinSmart_Future_AR_AP_Test.ORIGINAL.dt" /OUT "prepare_env.log"`

- [ ] **Step 4: Chạy script và xác minh test PASS**

Run: `powershell -ExecutionPolicy Bypass -File scripts/backup_and_prepare_env.ps1`
Run: `python scripts/test_env_isolation.py`
Expected: PASS (Mã thoát 0, CSDL `Infobase_FullData` sẵn sàng độc lập).

- [ ] **Step 5: Commit mã nguồn Task 1**

```bash
git add scripts/backup_and_prepare_env.ps1 scripts/test_env_isolation.py
git commit -m "feat: setup isolated test environment and original backup dt"
```

---

### Task 2: Module Sinh Dữ Liệu Chủ (~300 Master Data Đối Tác, Hợp Đồng & Tỷ Giá)

**Files:**
- Create: `src/CommonModules/GeneratorMasterDataServer.xml`
- Create: `src/CommonModules/GeneratorMasterDataServer/Ext/Module.bsl`
- Modify: `src/Configuration.xml`
- Test: `scripts/test_master_data_gen.py`

**Interfaces:**
- Consumes: `Catalogs.PhapNhan`, `Catalogs.DoiTac`, `Catalogs.HopDong`, `Catalogs.TienTe`, `InformationRegister.TyGiaHoiDoai`
- Produces: `GeneratorMasterDataServer.KhoiTaoMasterDataToanDien(Log)` trả về Structure chứa danh sách Ref:
  - `DanhSachDoiTacAR`: Array của `CatalogRef.DoiTac` (12–20 nội bộ Vingroup, ~100 bên ngoài)
  - `DanhSachDoiTacAP`: Array của `CatalogRef.DoiTac` (NCC quốc tế USD, NCC trong nước, 15–20 đối tác song phương)
  - `DanhSachHopDong`: Map ánh xạ `DoiTacRef -> Array của CatalogRef.HopDong`
  - `BangTyGiaUSD`: Map ánh xạ `Date -> Number` (tỷ giá USD/VND theo ngày)

- [ ] **Step 1: Viết test kiểm tra tính đầy đủ của Master Data**

Tạo `scripts/test_master_data_gen.py` truy vấn qua 1C BSL / Query:
- Đếm `Catalog.DoiTac`: $\ge 240$ đối tác có tiền tố `TEST_`.
- Đếm đối tác nội bộ Vingroup: $\ge 15$ đối tác có `LaBenLienKet = True`.
- Đếm `Catalog.HopDong`: $\ge 250$ hợp đồng.
- Đếm `InformationRegister.TyGiaHoiDoai`: $\ge 600$ bản ghi tỷ giá USD (trải đều các ngày từ 01/01/2025 đến 30/09/2026 trong khoảng 24.800 – 25.650 VND/USD).

- [ ] **Step 2: Chạy test để xác nhận FAIL**

Run: `python scripts/test_master_data_gen.py`
Expected: FAIL do module và dữ liệu master chưa được nạp.

- [ ] **Step 3: Khai báo metadata và triển khai `GeneratorMasterDataServer`**

1. Tạo `src/CommonModules/GeneratorMasterDataServer.xml` (Server = true, Privileged = false).
2. Đăng ký `<CommonModule>GeneratorMasterDataServer</CommonModule>` vào `src/Configuration.xml`.
3. Triển khai trong `Module.bsl`:
   - Hàm sinh mã và tên hợp lệ kiểu Việt Nam nhưng mô phỏng với seed cố định = 2026.
   - Nhóm 15–20 đối tác Vingroup: `TEST_DT_VINFAST`, `TEST_DT_GSM`, `TEST_DT_VINHOMES`, `TEST_DT_VINMEC`, `TEST_DT_VINPEARL`, `TEST_DT_VINUNI`, `TEST_DT_VINBIGDATA`, `TEST_DT_VINES`... (`LaBenLienKet = True`, `LoaiDoiTac = NoiBoVingroup`).
   - Nhóm 100 đối tác ngoài: doanh nghiệp, trường đại học, bệnh viện, đối tác viễn thông.
   - Nhóm NCC quốc tế: `TEST_DT_AWS`, `TEST_DT_MICROSOFT`, `TEST_DT_QUALCOMM`, `TEST_DT_GOOGLE`, `TEST_DT_ORACLE` (`TienTe = USD`).
   - 15–20 đối tác song phương phục vụ Netting: mang cờ vừa KH vừa NCC.
   - Bảng tỷ giá USD/VND: Sinh chuỗi ngẫu nhiên biến thiên có quy luật từ 24.800 đến 25.650 VND/USD cho từng ngày từ 01/01/2025 đến 30/09/2026.

- [ ] **Step 4: Nạp cấu hình vào CSDL thử, kích hoạt sinh Master Data và chạy test xác nhận PASS**

Run: `powershell -ExecutionPolicy Bypass -File scripts/update_db.ps1 -User "Admin"`
Run: `python scripts/test_master_data_gen.py`
Expected: PASS (Đủ số lượng đối tác, hợp đồng, tỷ giá hợp lệ 100%).

- [ ] **Step 5: Commit mã nguồn Task 2**

```bash
git add src/CommonModules/GeneratorMasterDataServer.xml src/CommonModules/GeneratorMasterDataServer/Ext/Module.bsl src/Configuration.xml scripts/test_master_data_gen.py
git commit -m "feat: implement GeneratorMasterDataServer for 250+ partners, contracts and FX rates"
```

---

### Task 3: Module Sinh Giao Dịch Phân Hệ Phải Thu AR (3.000 – 4.000 Chứng Từ)

**Files:**
- Create: `src/CommonModules/GeneratorARServer.xml`
- Create: `src/CommonModules/GeneratorARServer/Ext/Module.bsl`
- Modify: `src/Configuration.xml`
- Test: `scripts/test_ar_gen.py`

**Interfaces:**
- Consumes: Dữ liệu Master Data từ `GeneratorMasterDataServer`, Invariant P0.1, Maker-Checker
- Produces: `GeneratorARServer.SinhChungTuAR(MasterData, Log)`
  - Sinh 1.200 – 1.500 `BienBanNghiemThuGiaiDoan`
  - Sinh 1.200 – 1.500 `HoaDonGTGTDauRa` (gắn liền với nghiệm thu)
  - Sinh 800 – 1.000 `PhieuThuTienKhachHang` & `BaoCoNganHang`
  - Phân bổ tuổi nợ: 70% đúng hạn, 15% trễ 1–30d, 8% trễ 31–60d, 4% trễ 61–90d, 3% quá hạn >90d.

- [ ] **Step 1: Viết test kiểm tra số lượng và tính cân đối phân hệ AR**

Tạo `scripts/test_ar_gen.py` kiểm tra:
1. Số chứng từ `BienBanNghiemThuGiaiDoan` đã post $\ge 1.200$.
2. Số chứng từ `HoaDonGTGTDauRa` đã post $\ge 1.200$.
3. Số chứng từ thu tiền (`PhieuThuTienKhachHang` + `BaoCoNganHang`) $\ge 800$.
4. Kiểm tra Invariant P0.1: Mỗi nghiệm thu tạo ra bút toán Nợ 131 / Có 5113; mỗi hóa đơn VAT tương ứng tạo ra bút toán Nợ 131 / Có 33311.
5. Kiểm tra tính hiện diện của 5 nhóm tuổi nợ trong bảng số dư `AccumulationRegister.CongNoPhaiThu`.

- [ ] **Step 2: Chạy test để xác nhận FAIL**

Run: `python scripts/test_ar_gen.py`
Expected: FAIL do chưa sinh chứng từ AR.

- [ ] **Step 3: Triển khai logic sinh dữ liệu AR phân mẻ trong `GeneratorARServer`**

1. Tạo `src/CommonModules/GeneratorARServer.xml` và đăng ký vào `Configuration.xml`.
2. Trong `GeneratorARServer/Ext/Module.bsl`:
   - Phân chia vòng lặp theo từng tháng từ 01/2025 đến 09/2026.
   - Nhóm Vingroup (VinFast, GSM...): Doanh thu lớn (vài tỷ đến hàng chục tỷ VND), phân phối Pareto; thanh toán theo đợt gộp nhiều hóa đơn qua `BaoCoNganHang`.
   - Nhóm ngoài: Doanh thu trung bình, thanh toán qua chuyển khoản ngân hàng hoặc cổng VNPAY/OnePay (tài khoản ảo VA).
   - Thiết lập kỹ thuật phân mẻ: Cứ 50 chứng từ gọi `BeginTransaction()`, ghi sổ `.Write(DocumentWriteMode.Posting)`, sau đó `CommitTransaction()`. Nếu có ngoại lệ: `RollbackTransaction()` và log lỗi qua `WriteLogEvent`.
   - Đảm bảo thiết lập `NguoiTao = "KeToanAR"` và `NguoiDuyet = "CFO"` để thỏa mãn Maker-Checker.

- [ ] **Step 4: Chạy sinh chứng từ AR và xác minh test PASS**

Run: `powershell -ExecutionPolicy Bypass -File scripts/update_db.ps1 -User "Admin"`
Run: `python scripts/test_ar_gen.py`
Expected: PASS (Tất cả chứng từ AR đã ghi sổ thành công, phân bổ tuổi nợ đầy đủ 5 nhóm).

- [ ] **Step 5: Commit mã nguồn Task 3**

```bash
git add src/CommonModules/GeneratorARServer.xml src/CommonModules/GeneratorARServer/Ext/Module.bsl src/Configuration.xml scripts/test_ar_gen.py
git commit -m "feat: implement GeneratorARServer for 3000+ AR acceptance, VAT and collection documents"
```

---

### Task 4: Module Sinh Giao Dịch Phân Hệ Phải Trả AP (2.000 – 2.800 Chứng Từ)

**Files:**
- Create: `src/CommonModules/GeneratorAPServer.xml`
- Create: `src/CommonModules/GeneratorAPServer/Ext/Module.bsl`
- Modify: `src/Configuration.xml`
- Test: `scripts/test_ap_gen.py`

**Interfaces:**
- Consumes: NCC từ `GeneratorMasterDataServer`, Tỷ giá USD, Maker-Checker UyNhiemChi
- Produces: `GeneratorAPServer.SinhChungTuAP(MasterData, Log)`
  - Sinh 1.000 – 1.400 `HoaDonNhaCungCap` & `NghiemThuThauPhu` (mua thiết bị, cloud quốc tế USD, thầu phụ IT)
  - Sinh 1.000 – 1.400 `UyNhiemChi` & `DeNghiThanhToanDichVu`
  - Đảm bảo dòng phí ngân hàng trong `UyNhiemChi` quy về tiền tệ `VND`
  - Đảm bảo người lập `UyNhiemChi` không được tham gia phê duyệt

- [ ] **Step 1: Viết test kiểm tra phân hệ AP**

Tạo `scripts/test_ap_gen.py` kiểm tra:
1. Số `HoaDonNhaCungCap` đã post $\ge 1.000$.
2. Số `UyNhiemChi` đã post $\ge 1.000$.
3. Kiểm tra các hóa đơn USD (AWS, Microsoft, Qualcomm): Có bản ghi ngoại tệ trên sổ cái và sổ tích lũy `CongNoPhaiTra`.
4. Kiểm tra Maker-Checker: 100% `UyNhiemChi` có `NguoiTao <> NguoiDuyet` và `NguoiTao <> CurrentUser`.
5. Bút toán dòng tiền `DongTien`: Chi tiền giảm số dư tài khoản ngân hàng tương ứng.

- [ ] **Step 2: Chạy test để xác nhận FAIL**

Run: `python scripts/test_ap_gen.py`
Expected: FAIL do chưa sinh chứng từ AP.

- [ ] **Step 3: Triển khai logic sinh dữ liệu AP trong `GeneratorAPServer`**

1. Tạo `src/CommonModules/GeneratorAPServer.xml` và đăng ký vào `Configuration.xml`.
2. Trong `GeneratorAPServer/Ext/Module.bsl`:
   - Phân mẻ giao dịch 50 chứng từ/mẻ.
   - Hóa đơn NCC Cloud USD: Tính `SoTien` theo tỷ giá ngày hóa đơn; ghi sổ cái Nợ 627/642 Có 3312 và thuế nhà thầu/VAT nếu có.
   - Hóa đơn dịch vụ trong nước: Thuê data center Viettel IDC, outsource FPT Telecom, thuê văn phòng Vinhomes.
   - Lệnh chi `UyNhiemChi`: Gán `NguoiTao = "KeToanAP"` và `NguoiDuyet = "KeToanTruong"` (hoặc CFO); phí chuyển khoản 5.500 – 22.000 VND hạch toán Nợ 6425 Có 1121 bằng tiền tệ `VND`.

- [ ] **Step 4: Chạy sinh chứng từ AP và xác minh test PASS**

Run: `powershell -ExecutionPolicy Bypass -File scripts/update_db.ps1 -User "Admin"`
Run: `python scripts/test_ap_gen.py`
Expected: PASS (100% chứng từ AP ghi sổ thành công, Maker-Checker hợp lệ).

- [ ] **Step 5: Commit mã nguồn Task 4**

```bash
git add src/CommonModules/GeneratorAPServer.xml src/CommonModules/GeneratorAPServer/Ext/Module.bsl src/Configuration.xml scripts/test_ap_gen.py
git commit -m "feat: implement GeneratorAPServer for 2000+ vendor invoices and payment orders"
```

---

### Task 5: Module Sinh Cấn Trừ Công Nợ (Netting), Đối Soát & Các Ca Biên (Edge Cases)

**Files:**
- Create: `src/CommonModules/GeneratorNettingReconcileServer.xml`
- Create: `src/CommonModules/GeneratorNettingReconcileServer/Ext/Module.bsl`
- Modify: `src/Configuration.xml`
- Test: `scripts/test_netting_and_edge_cases.py`

**Interfaces:**
- Consumes: Các đối tác song phương (vừa KH vừa NCC), chứng từ gốc AR/AP
- Produces: `GeneratorNettingReconcileServer.SinhNettingVaDoiSoat(MasterData, Log)`
  - 150 – 250 `CanTruCongNoNoiBo`
  - 150 – 250 `BangKeDoiSoatKenhThanhToan`
  - 3–5% trường hợp biên có chủ đích: Khách hàng trả dư tiền (Dư Có 131), cấn trừ một phần (Partially Netted), giữ lại bảo hành 5% chưa thu.

- [ ] **Step 1: Viết test kiểm tra Netting, Đối soát và Edge Cases**

Tạo `scripts/test_netting_and_edge_cases.py` kiểm tra:
1. Số `CanTruCongNoNoiBo` đã post $\ge 150$.
2. Số `BangKeDoiSoatKenhThanhToan` đã post $\ge 150$.
3. Kiểm tra tính liên kết của `ChungTuGocAR` và `ChungTuGocAP` (kiểu `DocumentRef`, không phải string).
4. Xác nhận sự tồn tại của 3–5% edge cases: Có ít nhất 5 đối tác phát sinh dư Có trên TK 131 (tạm ứng trước chưa cấn trừ hết); có hợp đồng giữ lại bảo hành 5%.

- [ ] **Step 2: Chạy test để xác nhận FAIL**

Run: `python scripts/test_netting_and_edge_cases.py`
Expected: FAIL.

- [ ] **Step 3: Triển khai logic trong `GeneratorNettingReconcileServer`**

1. Tạo `src/CommonModules/GeneratorNettingReconcileServer.xml` và đăng ký vào `Configuration.xml`.
2. Triển khai trong `Module.bsl`:
   - Nghiệp vụ Netting: Lấy ngẫu nhiên các cặp chứng từ `BienBanNghiemThuGiaiDoan` (AR) và `HoaDonNhaCungCap` (AP) của cùng một đối tác liên kết (ví dụ Vinhomes, VinFast, GSM). Tạo `CanTruCongNoNoiBo`, ghi sổ giảm nợ cả 2 đầu AR/AP qua tài khoản trung gian cấn trừ.
   - Bảng kê đối soát cổng thanh toán: Gom các giao dịch thanh toán trực tuyến qua VNPAY/OnePay theo từng kỳ 10 ngày, trừ phí cổng thanh toán (1.1% – 1.6%), ghi nhận dòng tiền thực thu về ngân hàng Techcombank.
   - Chèn có chủ đích các trường hợp biên được đánh dấu rõ trong mô tả chứng từ (`GhiChu = "TEST_EDGE_CASE: ..."`).

- [ ] **Step 4: Chạy sinh Netting và xác minh test PASS**

Run: `powershell -ExecutionPolicy Bypass -File scripts/update_db.ps1 -User "Admin"`
Run: `python scripts/test_netting_and_edge_cases.py`
Expected: PASS (Netting và Bảng kê đối soát ghi sổ hợp lệ, danh sách edge cases nhận diện đầy đủ).

- [ ] **Step 5: Commit mã nguồn Task 5**

```bash
git add src/CommonModules/GeneratorNettingReconcileServer.xml src/CommonModules/GeneratorNettingReconcileServer/Ext/Module.bsl src/Configuration.xml scripts/test_netting_and_edge_cases.py
git commit -m "feat: implement GeneratorNettingReconcileServer for Netting, Gateway reconciliation and edge cases"
```

---

### Task 6: Tích Hợp Điều Phối Master Seeder & Kiểm Toán Toàn Vẹn Số Sách 100%

**Files:**
- Modify: `src/CommonModules/SeedFullTestDataServer/Ext/Module.bsl`
- Create: `scripts/run_seed_massive_data.ps1`
- Test: `scripts/test_ledger_integrity.py`

**Interfaces:**
- Consumes: Cả 4 module generator (MasterData, AR, AP, NettingReconcile)
- Produces: `SeedFullTestDataServer.ThucThiNapFullTestData()` hoàn chỉnh và `KiemTraDuLieuDaNap()` xác thực toàn bộ:
  - Tổng số chứng từ: $\ge 5.000$ chứng từ đã ghi sổ.
  - Sổ cái `SoCaiKeToan`: Cân đối kép $\sum Nợ = \sum Có$ (DELTA = 0).
  - Khớp đúng sổ phụ: `CongNoPhaiThu` khớp TK 131; `CongNoPhaiTra` khớp TK 331; `DongTien` khớp TK 111/112.

- [ ] **Step 1: Viết test kiểm toán độc lập toàn bộ hệ thống**

Tạo `scripts/test_ledger_integrity.py` thực hiện:
1. Đếm tổng số chứng từ đã post: khẳng định trong khoảng $5.000 \le N \le 7.000$.
2. Truy vấn Sổ cái: Khẳng định chênh lệch phát sinh `DELTA = SUM(Dr) - SUM(Cr) == 0`.
3. Kiểm tra số dư sổ tích lũy: `CongNoPhaiThu.Balance` và `CongNoPhaiTra.Balance` không bị lỗi thời điểm.
4. Quét nhật ký lỗi: Không có ngoại lệ cấp độ `Error` trong Event Log của phiên seed.

- [ ] **Step 2: Chạy test để xác nhận FAIL**

Run: `python scripts/test_ledger_integrity.py`
Expected: FAIL do CSDL chưa chứa đủ 5.000+ chứng từ.

- [ ] **Step 3: Cập nhật `SeedFullTestDataServer` và script điều phối**

1. Cập nhật `src/CommonModules/SeedFullTestDataServer/Ext/Module.bsl`:
   - Liên kết gọi theo trình tự: `GeneratorMasterDataServer` $\rightarrow$ `GeneratorARServer` $\rightarrow$ `GeneratorAPServer` $\rightarrow$ `GeneratorNettingReconcileServer`.
   - Cập nhật hàm `KiemTraDuLieuDaNap()` để in chi tiết bảng cân đối phát sinh, phân loại 5 bucket tuổi nợ, thống kê doanh thu/chi phí và ghi log Event Log 1C.
2. Tạo script `scripts/run_seed_massive_data.ps1` kích hoạt 1C Enterprise ở chế độ nền với `/C "SeedFullTestData"`, tự động xử lý hộp thoại và hiển thị tiến độ.

- [ ] **Step 4: Chạy toàn bộ tiến trình sinh dữ liệu và kiểm toán PASS**

Run: `powershell -ExecutionPolicy Bypass -File scripts/update_db.ps1 -User "Admin"`
Run: `powershell -ExecutionPolicy Bypass -File scripts/run_seed_massive_data.ps1`
Run: `python scripts/test_ledger_integrity.py`
Expected: PASS (Tất cả 5.000+ chứng từ hoàn tất, Sổ cái cân đối DELTA = 0).

- [ ] **Step 5: Commit mã nguồn Task 6**

```bash
git add src/CommonModules/SeedFullTestDataServer/Ext/Module.bsl scripts/run_seed_massive_data.ps1 scripts/test_ledger_integrity.py
git commit -m "feat: orchestrate massive test data seeding and complete GL/subledger verification"
```

---

### Task 7: Đóng Gói File Dữ Liệu Hoàn Chỉnh (`.dt`) & Báo Cáo Bàn Giao

**Files:**
- Create: `scripts/package_fulldata_release.ps1`
- Test: `scripts/test_fulldata_restore.py`
- Create: `docs/superpowers/reports/2026-10-11-massive-test-data-report.md`

**Interfaces:**
- Consumes: `Infobase_FullData` đã chứa đầy đủ dữ liệu test
- Produces: `VinSmart_Future_AR_AP_Test_FULLDATA.dt`, Báo cáo nghiệm thu số liệu

- [ ] **Step 1: Viết test kiểm tra file DT bàn giao**

Tạo `scripts/test_fulldata_restore.py` thực hiện:
1. Kiểm tra file `VinSmart_Future_AR_AP_Test_FULLDATA.dt` tồn tại, dung lượng $\ge 1.0$ MB.
2. Tạo CSDL tạm, chạy lệnh `/RestoreIB` để xác nhận file DT khôi phục hoàn hảo với ExitCode 0.
3. Chạy truy vấn đếm chứng từ trên CSDL tạm sau khôi phục: khẳng định đủ $\ge 5.000$ chứng từ đã ghi sổ.

- [ ] **Step 2: Chạy test để xác nhận FAIL**

Run: `python scripts/test_fulldata_restore.py`
Expected: FAIL do chưa đóng gói file FULLDATA.dt.

- [ ] **Step 3: Triển khai script đóng gói và lập báo cáo**

1. Tạo `scripts/package_fulldata_release.ps1`:
   - Thực thi lệnh:
     `1cv8t.exe DESIGNER /F "...\Infobase_FullData" /N "Admin" /DumpIB "...\VinSmart_Future_AR_AP_Test_FULLDATA.dt" /OUT "dump_fulldata.log"`
2. Lập báo cáo `docs/superpowers/reports/2026-10-11-massive-test-data-report.md`:
   - Thống kê chi tiết số lượng bản ghi từng đối tượng metadata.
   - Bảng tổng hợp cân đối Sổ cái, doanh thu, chi phí, công nợ AR/AP.
   - Danh sách chi tiết các trường hợp biên (Edge Cases).
   - Hướng dẫn chi tiết cách khôi phục và kiểm tra trên 1C.

- [ ] **Step 4: Chạy đóng gói và xác minh test PASS**

Run: `powershell -ExecutionPolicy Bypass -File scripts/package_fulldata_release.ps1`
Run: `python scripts/test_fulldata_restore.py`
Expected: PASS (File `VinSmart_Future_AR_AP_Test_FULLDATA.dt` tạo thành công và khôi phục đạt 100%).

- [ ] **Step 5: Commit bàn giao Task 7**

```bash
git add scripts/package_fulldata_release.ps1 scripts/test_fulldata_restore.py docs/superpowers/reports/2026-10-11-massive-test-data-report.md
git commit -m "feat: package VinSmart_Future_AR_AP_Test_FULLDATA.dt and publish handover report"
```
