# Task 3.1 Brief: Chứng Từ `BienBanNghiemThuGiaiDoan` - Ghi Tăng Doanh Thu Thuần (P0.1 Invariant)

## 1. Mục tiêu
Xây dựng chứng từ `BienBanNghiemThuGiaiDoan` (Document) đại diện cho biên bản nghiệm thu bàn giao dịch vụ CNTT (SaaS/Cloud/AI).
1. **Quy tắc hạch toán (Posting / PostingMode: Regular):**
   - Nghiệp vụ ghi tăng Doanh thu thuần dịch vụ (200.000.000 VND):
     - Ghi Sổ Cái `SoCaiKeToan`: `Nợ TK 1312 (hoặc 1311) / Có TK 5113`: 200.000.000 VND.
     - Ghi Sổ Tích Lũy `CongNoPhaiThu` (Receipt / Thêm số dư): 200.000.000 VND.
   - **Lưu ý P0.1:** Tại thời điểm nghiệm thu, CHƯA phát sinh nghĩa vụ thuế VAT đầu ra (thuế VAT đầu ra sẽ phát sinh khi xuất hóa đơn điện tử ở Task 3.2). Doanh thu thuần và Subledger tăng đồng bộ 200tr.
2. **Metadata thuộc tính:**
   - `PhapNhan` (`CatalogRef.PhapNhan`, DenyIncompleteValues: True)
   - `DoiTac` (`CatalogRef.DoiTac`, DenyIncompleteValues: True)
   - `HopDong` (`CatalogRef.HopDong`, DenyIncompleteValues: True)
   - `GiaTriNghiemThuChuaVAT` (`Number 15,2`, Nonnegative)
   - `TyLeVAT` (`Number 2`, Nonnegative)
   - `TienVAT` (`Number 15,2`, Nonnegative)
   - `TongGiaTri` (`Number 15,2`, Nonnegative)
   - `TrangThai` (`EnumRef.TrangThaiNghiemThuAR`)
   - `NguoiTao` (`String 50`)
   - `NguoiDuyet` (`String 50`)
   - `NgayNghiemThu` (`Date`)
   - `DienGiai` (`String 200`)
3. **Posting Logic (ObjectModule `Posting`):**
   - Đảm bảo kiểm tra trạng thái: Chỉ cho phép ghi sổ khi `TrangThai = DaGhiSo` (hoặc `DaDuyetNoiBo` -> `DaGhiSo`).
   - Ghi đồng thời vào `RegisterRecords.CongNoPhaiThu` và `RegisterRecords.SoCaiKeToan`.

## 2. File tác động
- `tests/unit/BienBanNghiemThuTest.bsl` (New)
- `src/Documents/BienBanNghiemThuGiaiDoan.xml` (New)
- `src/Documents/BienBanNghiemThuGiaiDoan/Ext/ObjectModule.bsl` (New)

## 3. Kịch bản kiểm thử `tests/unit/BienBanNghiemThuTest.bsl`
1. Khởi tạo chứng từ nghiệm thu 200.000.000 VND cho đối tác nội bộ Vingroup.
2. Ghi sổ chứng từ (`WriteMode.Posting`).
3. Assert:
   - Sổ cái `SoCaiKeToan` có bút toán `Nợ 1312 / Có 5113` = 200.000.000 VND.
   - Bảng ảo `AccumulationRegister.CongNoPhaiThu.Balance()` tăng chính xác 200.000.000 VND.
   - Variance $\Delta = |Subledger - GL| = 0$.
4. Unpost: Cả Subledger và GL hoàn nguyên về 0.

## 4. Báo cáo nghiệm thu
- Ghi báo cáo tại `.superpowers/sdd/2026-10-10-vinsmart-future-ar-ap/task-3.1-report.md`.
