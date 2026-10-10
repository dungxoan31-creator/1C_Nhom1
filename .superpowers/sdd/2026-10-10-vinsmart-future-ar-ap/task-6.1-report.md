# Báo Cáo Nghiệm Thu Task 6.1: Động Cơ Lập Ma Trận Cấn Trừ Tập Đoàn & Watchdog Timeout (P3.2)

## 1. Thông Tin Nghiệm Thu
- **Thời gian hoàn thành:** 10/10/2026 14:03
- **Trạng thái:** HOÀN THÀNH (100% PASS - 5/5 Unit Tests)
- **Hệ thống:** VinSmart Future - Phân hệ AR & AP Management (1C:Enterprise 8.3)
- **Tài liệu tham chiếu:** Spec v5.0, `task-6.1-brief.md`

---

## 2. Các Thành Phần Đã Xây Dựng & Kiểm Thử

### 2.1. Động Cơ Xử Lý: `DataProcessor.LapMaTranCanTruTapDoan`
- Quét nợ phải thu (AR) và nợ phải trả (AP) giữa các đơn vị nội bộ trong Tập đoàn Vingroup.
- Tính toán cấn trừ tay đôi (`TinhCanTruTayDoi`) hoặc cấn trừ đa bên bắc cầu thông qua tài khoản trung gian `TK 1388`.
- **Cơ chế Watchdog Timeout 120 phút (P3.2):**
  - Tuyệt đối không giữ database locks dài hạn trong suốt chu kỳ phê duyệt.
  - Quét kiểm tra định kỳ, nếu thời gian chờ phê duyệt vượt quá `TimeoutChoCanTruPhut` (120 phút): Tự động giải phóng trạng thái về `TrangThaiTruocDo` và xóa khóa logic.

### 2.2. Metadata XML & ObjectModule: `Document.CanTruCongNoNoiBo`
- Chứng từ ghi nhận cấn trừ công nợ nội bộ khi được phê duyệt đầy đủ (`TrangThai = "DaGhiSo"`).
- **Ràng buộc Maker-Checker:** Kiểm tra nghiêm ngặt tại `BeforeWrite`, người lập chứng từ tuyệt đối không được tự phê duyệt (`NguoiLap <> NguoiDuyet`).
- **Ghi nhận hạch toán Subledger & GL:**
  - Sổ phụ `AccumulationRegister.CongNoPhaiThu`: Ghi giảm nợ phải thu nội bộ (`RecordType.Expense`).
  - Sổ phụ `AccumulationRegister.CongNoPhaiTra`: Ghi giảm nợ phải trả nội bộ (`RecordType.Expense`).
  - Sổ cái kế toán `AccountingRegister.SoCaiKeToan`:
    - Cấn trừ trực tiếp 2 bên:
      $$\text{Nợ TK 3312} (\text{Phải trả nội bộ}) \quad / \quad \text{Có TK 1312} (\text{Phải thu nội bộ}) = \text{Số tiền cấn trừ}$$
    - Cấn trừ bắc cầu đa bên qua TK trung gian 1388:
      $$\text{Nợ TK 3312} / \text{Có TK 1388} \quad \text{và} \quad \text{Nợ TK 1388} / \text{Có TK 1312}$$
    - Số dư tài khoản trung gian 1388 triệt tiêu hoàn toàn về 0.
  - **Reconciliation Invariant:** $\Delta = |\text{Subledger} - \text{GL}| = 0$ và $\text{Debit} = \text{Credit}$ được kiểm soát tự động.

### 2.3. Cập Nhật Cơ Sở Dữ Liệu
- Đăng ký `DataProcessor.LapMaTranCanTruTapDoan` và `Document.CanTruCongNoNoiBo` vào `src/Configuration.xml`.
- Chạy `update_db.ps1`: `Load exit code: 0`, `Update exit code: 0`, cấu hình được cập nhật thành công không cảnh báo.

---

## 3. Kết Quả Kiểm Thử Độc Lập (Unit Test Verification)

Bộ kiểm thử BSL độc lập `tests/unit/MaTranCanTruNettingTest.bsl` và kịch bản xác thực `scripts/verify_task6_1.py`:

```
=================================================================
   VINSMART FUTURE - MA TRAN CAN TRU NETTING TEST (TASK 6.1)     
   Thoi gian chay: 10/10/2026 02:03:49 PM
=================================================================
[PASS] Test 1: Can tru tay doi VSF - VinFast 300tr thanh cong, AR giam 300tr, AP giam 300tr, GL: No 3312 / Co 1312 - Delta = 0.
[PASS] Test 2: Can tru da ben bac cau qua TK trung gian 1388 can doi hoan toan, so du TK 1388 triet tieu ve 0.
[PASS] Test 3: Watchdog Timeout quet qua 120 phut tu dong hoan nguyen trang thai chung tu ve TrangThaiTruocDo.
[PASS] Test 4: Maker-Checker chan thanh cong truong hop nguoi lap chung tu can tru tu phe duyet.
[PASS] Test 5: Metadata XML cua LapMaTranCanTruTapDoan va CanTruCongNoNoiBo hop le 100% theo chuan 1C 2.15.
=================================================================
KET QUA: Tong so: 5 | Thanh cong: 5 | That bai: 0
=================================================================
```
