# Task 6.3 Brief: Xây Dựng 3 Báo Cáo Chuyên Sâu Cấp Tập Đoàn

## 1. Mục tiêu
Triển khai 3 báo cáo tài chính chuyên sâu phục vụ quản trị Ban Tổng Giám đốc và CFO Tập đoàn Vingroup:
1. `Report.MaTranCanTruNoiBoTapDoan`:
   - Trực quan hóa ma trận bù trừ nợ đa bên giữa các đơn vị thành viên Vingroup.
   - Thể hiện: Số dư nợ trước cấn trừ, Số tiền cấn trừ chéo, Số dư ròng sau cấn trừ.
2. `Report.DoiSoatKenhThanhToanVaDongTienAo`:
   - Báo cáo đối chiếu tam giác: Báo có ngân hàng (`BaoCoNganHang`) <-> Sổ tạm giữ cổng thanh toán (`GiaoDichDienTuTamGiu`) <-> Doanh thu hóa đơn AR.
   - Giám sát phí kênh và tốc độ giải phóng dòng tiền từ cổng thanh toán.
3. `Report.CanhBaoHanMucVaGiaHanCloud`:
   - Cảnh báo thời hạn gói Cloud và hạn mức sử dụng 3 cấp độ:
     - Cấp Vàng: Còn $\le 30$ ngày hoặc $\ge 80\%$ quota.
     - Cấp Cam: Còn $\le 14$ ngày hoặc $\ge 90\%$ quota.
     - Cấp Đỏ: Còn $\le 7$ ngày hoặc $\ge 98\%$ quota.

## 2. File tác động
- `tests/unit/BaoCaoChuyenSauTest.bsl` (New)
- `src/Reports/MaTranCanTruNoiBoTapDoan.xml` (New)
- `src/Reports/MaTranCanTruNoiBoTapDoan/Ext/ObjectModule.bsl` (New)
- `src/Reports/DoiSoatKenhThanhToanVaDongTienAo.xml` (New)
- `src/Reports/DoiSoatKenhThanhToanVaDongTienAo/Ext/ObjectModule.bsl` (New)
- `src/Reports/CanhBaoHanMucVaGiaHanCloud.xml` (New)
- `src/Reports/CanhBaoHanMucVaGiaHanCloud/Ext/ObjectModule.bsl` (New)
- `src/Configuration.xml` (Register 3 Reports)

## 3. Kịch bản kiểm thử (TDD)
1. Ma trận cấn trừ: Tính toán bù trừ đa bên 3 đơn vị (VSF, VinFast, Vinhomes) tổng cấn trừ khớp tổng giảm AR/AP.
2. Đối soát kênh thanh toán: Đối chiếu 10tr tiền về khớp 9.85tr thực nhận + 150k phí kênh.
3. Cảnh báo gia hạn Cloud: Phân loại đúng 3 mức Vàng (25 ngày), Cam (10 ngày), Đỏ (5 ngày).
4. Cảnh báo hạn mức quota: Dung lượng 95% rơi vào mức Cam, 99% rơi vào mức Đỏ.
5. Metadata Schema XML của cả 3 báo cáo hợp lệ 100% theo chuẩn 1C version 2.15.
