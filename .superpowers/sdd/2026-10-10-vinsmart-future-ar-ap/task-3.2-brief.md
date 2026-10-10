# Task 3.2 Brief: Chứng Từ `HoaDonGTGTDauRa` - Ghi Tăng VAT Trên Cả Subledger & GL (P0.1 Invariant)

## 1. Mục tiêu
Xây dựng chứng từ `HoaDonGTGTDauRa` (Document) đại diện cho Hóa đơn điện tử đầu ra có mã của CQT (Nghị định 123/2020/NĐ-CP & Thông tư 78/2021/TT-BTC).
1. **Quy tắc hạch toán then chốt (Khớp nối Subledger & GL P0.1):**
   - Là nơi phát sinh nghĩa vụ thuế VAT đầu ra (20.000.000 VND trên Doanh thu 200.000.000 VND):
     - Ghi Sổ Cái `SoCaiKeToan`: `Nợ TK 1312 (hoặc 1311) / Có TK 33311`: 20.000.000 VND.
     - **BẮT BUỘC** Ghi Sổ Tích Lũy `CongNoPhaiThu` (Receipt / Thêm số dư): 20.000.000 VND với `ChungTuGoc = BienBanNghiemThuGiaiDoan` liên quan!
   - **Bảo toàn Invariant Khớp Nối:**
     - Tổng Subledger `CongNoPhaiThu` $= 200tr (\text{Task 3.1}) + 20tr (\text{Task 3.2}) = 220.000.000$ VND.
     - Tổng Sổ cái TK 1312 $= 200tr (\text{Task 3.1}) + 20tr (\text{Task 3.2}) = 220.000.000$ VND.
     - Sai lệch $\Delta \text{Variance} = 0$ tuyệt đối!
2. **Metadata thuộc tính:**
   - `PhapNhan` (`CatalogRef.PhapNhan`, DenyIncompleteValues: True)
   - `DoiTac` (`CatalogRef.DoiTac`, DenyIncompleteValues: True)
   - `HopDong` (`CatalogRef.HopDong`, DenyIncompleteValues: True)
   - `BienBanNghiemThu` (`DocumentRef.BienBanNghiemThuGiaiDoan`, DenyIncompleteValues: True)
   - `SoHoaDon` (`String 20`)
   - `KyHieu` (`String 10`)
   - `NgayHoaDon` (`Date`)
   - `TienChuaThue` (`Number 15,2`)
   - `ThueSuatVAT` (`Number 2`)
   - `TienThueVAT` (`Number 15,2`)
   - `TongTienThanhToan` (`Number 15,2`)
   - `TrangThaiHĐĐT` (`EnumRef.TrangThaiHoaDonDienTu`)
   - `MaCQT` (`String 50`)

## 2. File tác động
- `tests/unit/HoaDonGTGTDauRaTest.bsl` (New)
- `src/Documents/HoaDonGTGTDauRa.xml` (New)
- `src/Documents/HoaDonGTGTDauRa/Ext/ObjectModule.bsl` (New)

## 3. Kịch bản kiểm thử `tests/unit/HoaDonGTGTDauRaTest.bsl`
1. Khởi tạo `HoaDonGTGTDauRa` gắn kết với `BienBanNghiemThuGiaiDoan` 200tr.
2. Tiền thuế VAT = 20.000.000 VND.
3. Ghi sổ hóa đơn.
4. Assert:
   - Sổ cái `SoCaiKeToan` tăng Có TK 33311: 20tr, Nợ TK 1312: 20tr.
   - Sổ `CongNoPhaiThu` tăng đúng 20tr (tổng dư nợ thành 220tr).
   - Invariant: Tổng Subledger `CongNoPhaiThu` (220tr) == Tổng dư nợ Sổ cái TK 1312 (220tr).
   - $\Delta \text{Variance} = 0$.

## 4. Báo cáo nghiệm thu
- Ghi báo cáo tại `.superpowers/sdd/2026-10-10-vinsmart-future-ar-ap/task-3.2-report.md`.
