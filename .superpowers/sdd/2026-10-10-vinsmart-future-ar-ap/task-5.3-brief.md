# Task 5.3 Brief: Đối Soát Kênh Thanh Toán B2C & Hoàn Tiền Chi Hộ

## 1. Mục tiêu
Xây dựng 2 chứng từ phục vụ quản lý kênh thanh toán trực tuyến (VNPAY, VinClub, MoMo) và hoàn tiền khách hàng B2C:
1. `Document.BangKeDoiSoatKenhThanhToan`:
   - Tiếp nhận bảng kê đối soát định kỳ từ cổng thanh toán.
   - Ghi nhận: Tiền thực nhận vào tài khoản ngân hàng, Phí giao dịch kênh (`PhiKenh`), và giảm số dư tạm giữ trên `AccumulationRegister.GiaoDichDienTuTamGiu`:
     $$\text{Nợ TK 1121} (\text{Thực nhận}), \quad \text{Nợ TK 6427} (\text{Phí kênh}) \quad / \quad \text{Có TK 1388} (\text{hoặc Có GiaoDichTamGiu})$$
2. `Document.YeuCauHoanTienChiHo`:
   - Quản lý yêu cầu hoàn tiền cho khách hàng khi giao dịch lỗi hoặc hủy dịch vụ.
   - Hạch toán hoàn tiền giảm trực tiếp số tiền nhận từ kênh thanh toán.

## 2. File tác động
- `tests/unit/DoiSoatKenhThanhToanTest.bsl` (New)
- `src/Documents/BangKeDoiSoatKenhThanhToan.xml` (New)
- `src/Documents/BangKeDoiSoatKenhThanhToan/Ext/ObjectModule.bsl` (New)
- `src/Documents/YeuCauHoanTienChiHo.xml` (New)
- `src/Documents/YeuCauHoanTienChiHo/Ext/ObjectModule.bsl` (New)

## 3. Kịch bản kiểm thử
1. Bảng kê đối soát: Khớp 10tr tạm giữ, 150k phí kênh -> Thực nhận 9.85tr, giải phóng sổ tạm giữ.
2. Hoàn tiền chi hộ: Khấu trừ đúng số tiền hoàn tiền, cập nhật trạng thái giao dịch.

## 4. Báo cáo nghiệm thu
- Ghi báo cáo tại `.superpowers/sdd/2026-10-10-vinsmart-future-ar-ap/task-5.3-report.md`.
