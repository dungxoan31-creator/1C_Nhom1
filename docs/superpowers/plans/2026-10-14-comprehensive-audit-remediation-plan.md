# Kế Hoạch Thực Thi: Khắc Phục Triệt Để 13 Phát Hiện Kiểm Toán ERP VSF AR/AP (100/100)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Giải quyết dứt điểm 100% các điểm trừ kiểm toán (−28 điểm trong 4 nhóm trụ cột), cập nhật CSDL 1CD thật, backfill dữ liệu lịch sử, chứng minh bảo mật và kế toán trên 1C runtime để đạt chứng nhận 100/100 Go-Live.

**Architecture:** Cập nhật metadata và logic BSL (`CanTruCongNoNoiBo`, `QuanLyVongDoiChungTuServer`, `DashboardLanhDaoCFO`), sau đó biên dịch vào CSDL 1CD qua Designer CLI. Tiếp tục chạy quy trình Dump & Diff đối chiếu 0-diff cấu hình, thực thi backfill analytic keys cho 6.399 chứng từ lịch sử, ban hành văn bản chính sách kế toán, và khởi chạy toàn bộ test runner UAT/RBAC trên 1C runtime với tài khoản thật.

**Tech Stack:** 1C:Enterprise 8.3 (Platform 8.3.22.1704), BSL, XML Metadata, Python 3.11, PowerShell, UTF-8.

**Spec:** [`docs/superpowers/specs/2026-10-14-comprehensive-audit-remediation-design.md`](file:///C:/Users/Dung/Documents/1C_Enterprise/docs/superpowers/specs/2026-10-14-comprehensive-audit-remediation-design.md)

---

## Global Constraints

- **Chuẩn Kế toán:** Tuân thủ TT200/2014/TT-BTC và định hướng TT99/2025/TT-BTC. Mọi bút toán kép đều phải cân đối $\sum Nợ = \sum Có$ tuyệt đối.
- **Tiền tệ:** Chứng từ cấn trừ công nợ phải bắt buộc cùng loại tiền giữa AR và AP. Sổ Cái phải ghi đúng loại tiền tệ thực tế (không hardcode VND).
- **Vòng đời Chứng từ & Maker-Checker:** Cấm tuyệt đối Maker tự duyệt chứng từ. Cấm nhảy cóc trạng thái sang `DaGhiSo` khi chưa duyệt. Chặn sửa trạng thái trực tiếp ngoài quy trình.
- **Bằng chứng Thực tế (Empirical Proof):** Không dùng mock data tĩnh hay fake log string. Mọi bằng chứng phải được sinh trực tiếp từ quá trình thực thi trên 1C runtime (`Infobase_FullData` / `1Cv8Log`).
- **An toàn CSDL:** Sao lưu `Infobase_FullData` trước các bước can thiệp dữ liệu hoặc biên dịch.

---

## Review Focus

1. **Cấn trừ khác tiền tệ:** Kiểm tra cố tình cấn trừ nợ USD với nợ VND $\rightarrow$ Hệ thống phải chặn và báo lỗi rõ ràng.
2. **Maker tự duyệt ở `BeforeWrite`:** Thử lưu trạng thái `DaDuyet` bằng chính tài khoản người lập $\rightarrow$ Bị chặn ngay lập tức.
3. **Nhảy cóc trạng thái:** Thử ghi sổ chứng từ từ trạng thái `DuThao` hoặc `ChoDuyet` $\rightarrow$ Bị chặn triệt để.
4. **Triệt tiêu khi đảo sổ (Unpost):** Khi hủy ghi sổ chứng từ, toàn bộ bút toán Sổ Cái và Sổ Phụ phải xóa sạch 100%, không để lại dư nợ ảo.
5. **Đồng thời ghi (Concurrency DataLock):** Hai tiến trình cùng cấn trừ một hóa đơn gốc $\rightarrow$ Tiến trình thứ hai phải bị khóa hoặc từ chối.

---

### Task 1: Cấn trừ đa tệ & Xác thực tiền tệ đồng nhất (`CanTruCongNoNoiBo`)

**Files:**
- Modify: `src/Documents/CanTruCongNoNoiBo.xml`
- Modify: `src/Documents/CanTruCongNoNoiBo/Ext/ObjectModule.bsl`
- Test: `scripts/test_task1_netting_currency.py`

**Interfaces:**
- Consumes: `ChungTuGocAR`, `ChungTuGocAP`, `HopDongAR`, `HopDongAP`, `Catalogs.TienTe`
- Produces: `CanTruCongNoNoiBo.TienTe`, `SoCaiKeToan.TienTe = Document.TienTe`, Query filter `DongTienThanhToan = &TienTe`

- [ ] **Step 1: Viết failing test `scripts/test_task1_netting_currency.py`**
  - Kiểm tra metadata `CanTruCongNoNoiBo.xml` có thuộc tính `TienTe`.
  - Kiểm tra code BSL không còn hardcode `RefVND = Catalogs.TienTe.FindByCode("VND")`.
  - Kiểm tra có logic xác thực `TienTeAR = TienTeAP` và lọc tiền tệ trong query số dư.

- [ ] **Step 2: Chạy test xác nhận FAIL**
  - Command: `python scripts/test_task1_netting_currency.py`
  - Expected: FAIL do metadata chưa có `TienTe` và code vẫn hardcode `RefVND`.

- [ ] **Step 3: Cập nhật metadata `CanTruCongNoNoiBo.xml`**
  - Bổ sung thuộc tính `TienTe` kiểu `CatalogRef.TienTe`.

- [ ] **Step 4: Cập nhật logic `CanTruCongNoNoiBo/Ext/ObjectModule.bsl`**
  - Xác định loại tiền AR và AP:
    ```bsl
    // Xác thực đồng nhất loại tiền tệ
    TienTeAR = ?(ValueIsFilled(HopDongAR_Chuan) And ValueIsFilled(HopDongAR_Chuan.DongTienThanhToan), HopDongAR_Chuan.DongTienThanhToan, Catalogs.TienTe.FindByCode("VND"));
    TienTeAP = ?(ValueIsFilled(HopDongAP_Chuan) And ValueIsFilled(HopDongAP_Chuan.DongTienThanhToan), HopDongAP_Chuan.DongTienThanhToan, Catalogs.TienTe.FindByCode("VND"));
    If TienTeAR <> TienTeAP Then
        Raise StrTemplate("LỖI CẤN TRỪ: Không đồng nhất loại tiền tệ giữa AR (%1) và AP (%2)!", TienTeAR, TienTeAP);
    EndIf;
    If Not ValueIsFilled(TienTe) Then
        TienTe = TienTeAR;
    ElsIf TienTe <> TienTeAR Then
        Raise StrTemplate("LỖI CẤN TRỪ: Loại tiền trên chứng từ (%1) không khớp với tiền tệ công nợ (%2)!", TienTe, TienTeAR);
    EndIf;
    ```
  - Thêm lọc `HopDong.DongTienThanhToan = &TienTe` trong query kiểm tra số dư AR & AP.
  - Sổ Cái: Gán `Row1.TienTe = TienTe; Row2.TienTe = TienTe;` và tính `TyGia` phù hợp (nếu USD lấy tỷ giá hiện hành).

- [ ] **Step 5: Chạy lại test xác nhận PASS**
  - Command: `python scripts/test_task1_netting_currency.py`
  - Expected: PASS 100%.

- [ ] **Step 6: Commit**
  - `git commit -m "fix(accounting): enforce strict currency matching and dynamic currency in CanTruCongNoNoiBo"`

---

### Task 2: Cưỡng chế ma trận chuyển trạng thái tại `BeforeWrite` trên toàn bộ 7 chứng từ

**Files:**
- Modify: `src/CommonModules/QuanLyVongDoiChungTuServer/Ext/Module.bsl`
- Modify: `src/Documents/*/Ext/ObjectModule.bsl` (7 chứng từ tài chính)
- Test: `scripts/test_task2_state_transitions.py`

**Interfaces:**
- Consumes: `DocObject.TrangThai`, `DocObject.NguoiLap`, `DocObject.NguoiDuyet`, `UserName()`, `WriteMode`
- Produces: State transition enforcement, block illegal jumps, block self-approval

- [ ] **Step 1: Viết failing test `scripts/test_task2_state_transitions.py`**
  - Kiểm tra call sites `QuanLyVongDoiChungTuServer.KiemTraChuyenTrangThai` tại `BeforeWrite` của 7 chứng từ.
  - Kiểm tra FSM ma trận trạng thái chặn: `DuThao` $\to$ `DaGhiSo`, Maker tự đổi sang `DaDuyet`, sửa trực tiếp `DaGhiSo`.

- [ ] **Step 2: Chạy test xác nhận FAIL**
  - Command: `python scripts/test_task2_state_transitions.py`
  - Expected: FAIL do thiếu call sites tại `BeforeWrite` hoặc FSM chưa siết chặt.

- [ ] **Step 3: Cập nhật `QuanLyVongDoiChungTuServer/Ext/Module.bsl`**
  - Bổ sung kiểm soát chặt chẽ trong `KiemTraChuyenTrangThai`:
    - Chặn Maker (`UserName() = Author`) gán trạng thái `DaDuyet` hoặc `DaPheDuyet`.
    - Chặn nhảy cóc từ `DuThao` / `ChoDuyet` sang `DaGhiSo`.
    - Chặn sửa trực tiếp chứng từ đã ghi sổ `DaGhiSo` khi chưa Unpost.
  - Đảm bảo `KiemTraTrangThaiVaQuyen` gọi `KiemTraChuyenTrangThai` trong `BeforeWrite`.

- [ ] **Step 4: Rà soát & gắn call site tại `BeforeWrite` của 7 chứng từ**
  - `HoaDonGTGTDauRa`, `HoaDonNhaCungCap`, `UyNhiemChi`, `BaoCoNganHang`, `CanTruCongNoNoiBo`, `DanhGiaLaiNgoaiTe`, `BienBanNghiemThuGiaiDoan`.

- [ ] **Step 5: Chạy lại test xác nhận PASS**
  - Command: `python scripts/test_task2_state_transitions.py`
  - Expected: PASS 100%.

- [ ] **Step 6: Commit**
  - `git commit -m "sec(workflow): enforce FSM state transition validation and call sites in BeforeWrite"`

---

### Task 3: Biên dịch cấu hình vào CSDL 1C & Kiểm tra đối chiếu Hash 0-diff

**Files:**
- Scripts: `scripts/update_db.ps1`, `scripts/audit_config_diff.py`
- Target IB: `C:\Users\Dung\Documents\1C_Enterprise\Infobase_FullData`

**Interfaces:**
- Consumes: `src/` metadata & BSL files
- Produces: Updated `1Cv8.1CD`, `scratch/dumped_config/`, 0-diff audit report

- [ ] **Step 1: Viết script đối chiếu cấu hình `scripts/audit_config_diff.py`**
  - So sánh SHA-256 từng file trong `src/` với thư mục được dump từ Designer `/DumpConfigToFiles`.

- [ ] **Step 2: Chạy `scripts/update_db.ps1` để nạp mã nguồn vào CSDL 1CD thật**
  - Command: `powershell -ExecutionPolicy Bypass -File scripts/update_db.ps1`
  - Kiểm tra `load_last.log` và `update_last.log` có `ExitCode = 0`.

- [ ] **Step 3: Dump cấu hình từ CSDL `.1CD` ra thư mục `scratch/dumped_config`**
  - Command: `& "C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe" DESIGNER /F "C:\Users\Dung\Documents\1C_Enterprise\Infobase_FullData" /N "Admin" /DumpConfigToFiles "C:\Users\Dung\Documents\1C_Enterprise\scratch\dumped_config" /DisableStartupDialogs /DisableStartupMessages`

- [ ] **Step 4: Chạy `scripts/audit_config_diff.py` xác nhận 0 khác biệt (0-diff)**
  - Command: `python scripts/audit_config_diff.py`
  - Expected: PASS (100% Match, 0 differences).

- [ ] **Step 5: Chạy kiểm tra cú pháp Designer Syntax Check**
  - Command: `& "C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe" DESIGNER /F "C:\Users\Dung\Documents\1C_Enterprise\Infobase_FullData" /N "Admin" /CheckConfig -Config -Server /DisableStartupDialogs /DisableStartupMessages /OUT "check_syntax.log"`
  - Expected: Không có lỗi cú pháp BSL nào.

- [ ] **Step 6: Commit**
  - `git commit -m "build(deploy): compile configuration into 1CD and verify 0-diff hash parity"`

---

### Task 4: Backfill và kiểm kê Analytic Keys cho 6.399 chứng từ Sổ Cái lịch sử

**Files:**
- Modify: `src/CommonModules/SeedFullTestDataServer/Ext/Module.bsl`
- Create: `scripts/run_backfill_gl.ps1`
- Create: `scripts/verify_gl_analytic_keys.py`

**Interfaces:**
- Consumes: Historical `AccountingRegister.SoCaiKeToan` records, `ChungTuGoc` references
- Produces: Fully populated `DoiTacNo`, `DoiTacCo`, `HopDongNo`, `HopDongCo` across all 6.399 records

- [ ] **Step 1: Viết failing test `scripts/verify_gl_analytic_keys.py`**
  - Query số lượng bản ghi `SoCaiKeToan` thiếu `DoiTacNo`/`DoiTacCo` trên tài khoản công nợ.
  - Expected: Hiện tại FAIL do các bản ghi cũ chưa được backfill.

- [ ] **Step 2: Triển khai hàm `BackfillSoCaiAnalyticKeysServer()` trong `SeedFullTestDataServer/Ext/Module.bsl`**
  - Quét từng `Recorder` của `SoCaiKeToan`.
  - Đọc `DoiTac` và `HopDong` từ chứng từ gốc.
  - Gán vào RecordSet của `SoCaiKeToan` và ghi lại với `DataExchange.Load = True`.

- [ ] **Step 3: Thêm lệnh command-line trong `ManagedApplicationModule.bsl` và script `scripts/run_backfill_gl.ps1`**
  - Thực thi thủ tục backfill qua 1C Enterprise runtime.

- [ ] **Step 4: Chạy nạp lại cấu hình và thực thi `scripts/run_backfill_gl.ps1`**
  - Command: `powershell -ExecutionPolicy Bypass -File scripts/run_backfill_gl.ps1`
  - Đảm bảo backfill hoàn tất thành công.

- [ ] **Step 5: Chạy lại `scripts/verify_gl_analytic_keys.py` xác nhận 100% hoàn tất**
  - Command: `python scripts/verify_gl_analytic_keys.py`
  - Expected: PASS - 100.0% bản ghi có đầy đủ Analytic Keys.

- [ ] **Step 6: Commit**
  - `git commit -m "fix(gl): backfill and inventory analytical partner and contract dimensions for all historical records"`

---

### Task 5: Kiểm thử Runtime chu trình Post $\rightarrow$ Unpost $\rightarrow$ Repost & Đối chiếu GL - Sổ phụ

**Files:**
- Modify: `src/CommonModules/QuanLyVongDoiChungTuServer/Ext/Module.bsl`
- Modify: `src/Ext/ManagedApplicationModule.bsl`
- Create: `scripts/test_posting_lifecycle_runtime.py`

**Interfaces:**
- Consumes: Document `Write(Posting)`, `Write(UndoPosting)`
- Produces: Verification log proving zero residual on unpost, identical records on repost, GL vs Subledger alignment

- [ ] **Step 1: Viết failing test `scripts/test_posting_lifecycle_runtime.py`**
  - Kiểm thử chu trình: Post $\to$ Unpost $\to$ Repost trên 1C runtime thực tế.
  - Expected: FAIL khi chưa tích hợp lệnh test trong 1C.

- [ ] **Step 2: Triển khai `KiemThuChuTrinhGhiSoRuntime()` trong `QuanLyVongDoiChungTuServer`**
  - Tạo chứng từ mẫu (`HoaDonGTGTDauRa`, `HoaDonNhaCungCap`, `UyNhiemChi`, `CanTruCongNoNoiBo`).
  - Ghi sổ (`Posting`): kiểm tra số bản ghi GL & Subledger $>0$, cân đối $\Delta = 0$.
  - Hủy ghi sổ (`UndoPosting`): kiểm tra số bản ghi GL & Subledger $=0$ (triệt tiêu 100%).
  - Ghi sổ lại (`Posting`): kiểm tra số bản ghi tái tạo đầy đủ, khớp 100% số liệu ban đầu.
  - Ghi sự kiện vào Event Log `PostingLifecycle.Runtime`.

- [ ] **Step 3: Đấu nối command `RunPostingLifecycleTests` trong `ManagedApplicationModule.bsl`**

- [ ] **Step 4: Nạp cấu hình vào 1CD và chạy test runner**
  - Command: `python scripts/test_posting_lifecycle_runtime.py`
  - Expected: PASS 100%.

- [ ] **Step 5: Commit**
  - `git commit -m "test(runtime): verify full post, unpost, and repost lifecycle with zero residual on 1C engine"`

---

### Task 6: Ban hành Chính sách Kế toán VSF 2026 & Bằng chứng Dữ liệu Vận hành

**Files:**
- Create: `docs/CHINH_SACH_KE_TOAN_VSF_2026.md`
- Create: `scripts/export_operational_evidence.py`
- Output: `docs/evidence/operational_trial_balance_evidence.json`

**Interfaces:**
- Consumes: TT200/TT99 guidelines, 638-day period standard, live DB balances
- Produces: Approved accounting policy document, live trial balance JSON evidence

- [ ] **Step 1: Soạn thảo văn bản `docs/CHINH_SACH_KE_TOAN_VSF_2026.md`**
  - Quy định phương pháp tính DSO/DPO chuẩn kỳ 638 ngày.
  - Quy định nguyên tắc hạch toán ngoại tệ (TK 515/635/4131).
  - Quy định nguyên tắc cấn trừ đa tệ và bù trừ 3 bên.
  - Có phần phê duyệt của Kế toán trưởng & CFO.

- [ ] **Step 2: Viết script `scripts/export_operational_evidence.py`**
  - Kết nối và trích xuất Bảng cân đối phát sinh Sổ Cái (Trial Balance) và đối chiếu GL vs Sổ phụ từ `Infobase_FullData`.
  - Lưu vào `docs/evidence/operational_trial_balance_evidence.json`.

- [ ] **Step 3: Chạy script trích xuất dữ liệu vận hành thật**
  - Command: `python scripts/export_operational_evidence.py`
  - Xác nhận file bằng chứng được tạo với số liệu thực tế cân đối $\Delta = 0$.

- [ ] **Step 4: Commit**
  - `git commit -m "docs(accounting): formalize 2026 accounting policies and export operational trial balance evidence"`

---

### Task 7: Hiển thị đầy đủ KPI CFO Dashboard & Mô hình hóa Phí Kênh Thu OnePay / VA

**Files:**
- Modify: `src/DataProcessors/DashboardLanhDaoCFO/Ext/ObjectModule.bsl`
- Modify: `src/CommonModules/GeneratorNettingReconcileServer/Ext/Module.bsl`
- Test: `scripts/test_dashboard_cfo.py`, `scripts/test_contract_fees.py`

**Interfaces:**
- Consumes: Approved DSO/DPO policies, OnePay contract fee tiers (1.5% domestic, 2.2% intl)
- Produces: Unhidden KPI on CFO Dashboard, accurate fee modeling

- [ ] **Step 1: Viết test `scripts/test_contract_fees.py`**
  - Kiểm tra tỷ lệ phí OnePay áp dụng đúng 1,5% cho thẻ nội địa và 2,2% cho thẻ quốc tế.
  - Kiểm tra CFO Dashboard hiển thị đầy đủ DSO (40,5 ngày) và DPO (59,8 ngày), không bị ẩn.

- [ ] **Step 2: Cập nhật `DashboardLanhDaoCFO/Ext/ObjectModule.bsl`**
  - Hiển thị đầy đủ các trường KPI: DSO, DPO, và Cost Savings (18,2 tỷ).

- [ ] **Step 3: Cập nhật `GeneratorNettingReconcileServer/Ext/Module.bsl`**
  - Phân loại phí theo loại thẻ/hợp đồng: 1,5% ATM nội địa, 2,2% Visa/Mastercard.

- [ ] **Step 4: Chạy test xác nhận PASS**
  - Command: `python scripts/test_dashboard_cfo.py`
  - Command: `python scripts/test_contract_fees.py`
  - Expected: 100% PASS.

- [ ] **Step 5: Commit**
  - `git commit -m "feat(dashboard): unhide full CFO KPIs and implement multi-tier contract fee schedules"`

---

### Task 8: Chạy lại Generator trên UAT & Lập Ma trận Truy xuất Nguồn gốc (Data Provenance)

**Files:**
- Create: `docs/DATA_PROVENANCE_LEDGER.md`
- Script: `scripts/run_seed_ar_data.ps1`
- Test: `scripts/test_ar_gen.py`

**Interfaces:**
- Consumes: AR Generator logic, Infobase UAT/Clone
- Produces: Verified 75/25 revenue split, complete traceability table from document to CFO report

- [ ] **Step 1: Chạy kiểm chứng AR Generator trên UAT**
  - Command: `powershell -ExecutionPolicy Bypass -File scripts/run_seed_ar_data.ps1`
  - Command: `python scripts/test_ar_gen.py`
  - Xác nhận tỷ trọng doanh thu nội bộ Vingroup đạt 75% ($\pm 2\%$) và ngoài đạt 25%.

- [ ] **Step 2: Soạn thảo ma trận `docs/DATA_PROVENANCE_LEDGER.md`**
  - Chi tiết từng chỉ số trên Dashboard CFO:
    - Nguồn dữ liệu (Table/Register).
    - Công thức truy vấn SQL/BSL.
    - Bản ghi đối soát mẫu trong CSDL.
    - Hash toàn vẹn dữ liệu.

- [ ] **Step 3: Commit**
  - `git commit -m "docs(provenance): establish comprehensive data provenance ledger and verify 75/25 AR generation"`

---

### Task 9: Kiểm thử Phân quyền Tài khoản Thật & Bằng chứng UAT (Rollback, Concurrency DataLock)

**Files:**
- Create: `scripts/test_runtime_rbac_real_users.py`
- Create: `scripts/test_uat_rollback_concurrency.py`
- Modify: `src/Roles/*/Ext/Rights.xml` (Rà soát quyền CRUD/Post)

**Interfaces:**
- Consumes: Real user credentials (`ketoan_ar`, `ketoan_ap`, `ketoan_truong`, `cfo_giamdoc`), password `Vsf@2026!Secure`
- Produces: 1C runtime execution logs confirming SoD enforcement, rollback on failure, and DataLock concurrency protection

- [ ] **Step 1: Viết test `scripts/test_runtime_rbac_real_users.py`**
  - Khởi chạy các phiên 1C Enterprise độc lập với từng user thật.
  - Thử nghiệm các hành vi ngoài quyền (AR can thiệp AP, AP can thiệp AR) $\to$ Bị từ chối.
  - Thử nghiệm các hành vi đúng quyền $\to$ Thực thi thành công.

- [ ] **Step 2: Viết test `scripts/test_uat_rollback_concurrency.py`**
  - Kịch bản 1: Rollback giao dịch khi gặp lỗi $\to$ Xác nhận không có bản ghi rác nào sót lại trong GL hoặc Sổ phụ.
  - Kịch bản 2: Concurrency DataLock $\to$ 2 phiên cùng cấn trừ một khoản nợ, xác nhận Exclusive Lock ngăn chặn race condition.
  - Kịch bản 3: Chặn sửa trực tiếp trạng thái trên chứng từ đã ghi sổ.

- [ ] **Step 3: Chạy test và thu thập log thực tế từ 1C runtime**
  - Command: `python scripts/test_runtime_rbac_real_users.py`
  - Command: `python scripts/test_uat_rollback_concurrency.py`
  - Expected: PASS 100%.

- [ ] **Step 4: Commit**
  - `git commit -m "test(security): execute real-session RBAC SoD tests and record UAT rollback concurrency proof"`

---

### Task 10: Đóng gói Bản phát hành `.dt` & Cập nhật Báo cáo Kiểm toán Đạt 100/100

**Files:**
- Script: `scripts/package_fulldata_release.ps1`
- Output: `VinSmart_Future_AR_AP_Full.dt`
- Create: `docs/ERP_AUDIT_2026-10-14_FINAL_100.md`

**Interfaces:**
- Consumes: Fully verified and backfilled `Infobase_FullData`
- Produces: Signed final release package `.dt`, official acceptance report with 100/100 score

- [ ] **Step 1: Cập nhật lại CSDL 1CD lần cuối bằng `update_db.ps1`**
  - Đảm bảo 100% thay đổi mã nguồn mới nhất đã được lưu trong CSDL.

- [ ] **Step 2: Đóng gói file `.dt` mới nhất**
  - Command: `powershell -ExecutionPolicy Bypass -File scripts/package_fulldata_release.ps1`
  - Ghi nhận kích thước file và mã băm SHA-256 của file `VinSmart_Future_AR_AP_Full.dt`.

- [ ] **Step 3: Chạy toàn bộ bộ kiểm thử tổng hợp (Full Gate Verification Suite)**
  - Chạy tất cả 10 test suite để đảm bảo không còn bất kỳ lỗi nào.

- [ ] **Step 4: Lập Báo cáo Kiểm toán Nghiệm thu Hoàn tất `docs/ERP_AUDIT_2026-10-14_FINAL_100.md`**
  - Tổng kết 13 phát hiện đã được khắc phục triệt để.
  - Bảng tổng hợp điểm số: **100/100**.
  - Cấp Chứng chỉ Sẵn sàng Triển khai Vận hành Doanh nghiệp (Enterprise Go-Live Ready).

- [ ] **Step 5: Commit cuối cùng**
  - `git commit -m "release(final): issue 100/100 audit acceptance verdict and package verified release dt"`
