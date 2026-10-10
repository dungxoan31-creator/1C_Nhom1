# Báo Cáo Triển Khai Task 4.2: Luồng Phê Duyệt AP 4+1 Cấp & Nhánh Duyệt CFO Khi Vượt Ngân Sách > 10%

**Dự án:** Phân hệ Quản lý Công nợ AR & AP — Công ty Cổ phần VinSmart Future (VSF), Tập đoàn Vingroup  
**Nền tảng:** 1C:Enterprise 8.3 (Managed Application / Taxi / BSL / XML Metadata Version 2.15)  
**Nhiệm vụ:** Task 4.2 - Luồng Phê Duyệt AP 4+1 Cấp & Nhánh Duyệt CFO Khi Vượt Ngân Sách > 10%  
**Trạng thái (Status):** **DONE** (5/5 Tests Pass, 100% Invariant Compliant)  
**Thời gian hoàn thành:** 10/10/2026  

---

## 1. Tóm Tắt Kết Quả Triển Khai (Executive Summary)

1. **Tuân thủ quy trình Test-Driven Development (TDD / Test-first):**
   - Đã khởi tạo bộ kiểm thử tự động `tests/unit/WorkflowPheDuyetAPTest.bsl` với 5 kịch bản kiểm thử:
     * **Test 1:** Luồng duyệt chuẩn trong hạn mức: Chuyển tuần tự qua các cấp: `DuThao` $\rightarrow$ `ChoDuyetKyThuat` $\rightarrow$ `ChoDuyetPM` $\rightarrow$ `ChoDuyetITDirector` $\rightarrow$ `ChoKeToanAP` $\rightarrow$ `DaGhiSo`.
     * **Test 2:** Luồng duyệt vượt ngân sách $>10\%$: Kích hoạt nhánh `ChoDuyetCFO` giữa `ChoDuyetITDirector` và `ChoKeToanAP`.
     * **Test 3:** Maker-Checker: Chặn tuyệt đối người lập (Author) tự phê duyệt tại mọi cấp duyệt.
     * **Test 4:** Xử lý từ chối (`TuChoi`): Chuyển trạng thái sang `TuChoi`, lưu vết lý do từ chối.
     * **Test 5:** Re-check Anti-Split: Tự động cảnh báo phát hiện dấu hiệu chia nhỏ hóa đơn (3+ hóa đơn trong tháng vượt ngưỡng ngân sách).

2. **Khởi tạo CommonModule `QuyTrinhPheDuyetAPServer` (`src/CommonModules/QuyTrinhPheDuyetAPServer.xml` & `Ext/Module.bsl`):**
   - Đăng ký `CommonModule` trên server chuẩn 1C version 2.15 (`Server=true`, `ServerCall=true`, `ExternalConnection=true`).
   - Cung cấp 4 hàm/thủ tục giao tiếp chuẩn:
     * `XacDinhTrangThaiTiepTheo(TrangThaiHienTai, VuotNganSach)`
     * `KiemTraQuyenDuyet(NguoiTao, NguoiDuyet, TrangThaiDangDuyet)`
     * `TuChoiPheDuyet(TrangThaiHienTai, LyDoTuChoi)`
     * `KiemTraAntiSplit(SoHoaDonTrongThang, TongTienLuyKe, NguongCanhBao)`

3. **Tích hợp hệ thống & Cập nhật Database:**
   - Đăng ký `QuyTrinhPheDuyetAPServer` trong `src/Configuration.xml`.
   - Cập nhật cấu hình cơ sở dữ liệu `UpdateDBCfg` thành công 100% không cảnh báo.

---

## 2. Danh Sách File Đã Tạo & Cập Nhật

| STT | File | Loại | Mô Tả |
| :-: | :--- | :--- | :--- |
| 1 | `tests/unit/WorkflowPheDuyetAPTest.bsl` | BSL Test Suite | 5 Test cases kiểm thử luồng duyệt chuẩn, nhánh CFO, Maker-Checker, từ chối, và Anti-Split |
| 2 | `src/CommonModules/QuyTrinhPheDuyetAPServer.xml` | XML Metadata | CommonModule v2.15 với Server=true, ServerCall=true |
| 3 | `src/CommonModules/QuyTrinhPheDuyetAPServer/Ext/Module.bsl` | BSL Module | Logic điều hướng trạng thái, kiểm soát Maker-Checker và Anti-Split |
| 4 | `src/Configuration.xml` | Config | Đăng ký CommonModule QuyTrinhPheDuyetAPServer |
| 5 | `tests/unit/workflow_phe_duyet_ap_test_result.log` | Test Log | Log kết quả kiểm thử 5/5 PASS |
