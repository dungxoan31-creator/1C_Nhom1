# Task 8.3 Brief: UAT Toàn Trình, Kế Hoạch Cutover, Chạy Song Song & Rollback Playbook

## 1. Mục tiêu
1. Thực hiện kịch bản kiểm thử chấp nhận người dùng toàn trình (UAT End-to-End) bao quát toàn bộ 8 giai đoạn của hệ thống AR & AP VinSmart Future.
2. Thiết lập Kế hoạch Cutover 72h chi tiết, Kế hoạch Chạy song song (Parallel Run 2 tuần) và Quy trình Rollback khẩn cấp không mất mát dữ liệu.
3. Ký biên bản bàn giao và đưa hệ thống vào trạng thái Go-Live Ready.

## 2. File tác động
- `tests/migration/UATEndToEndTest.bsl` (New)
- `.superpowers/sdd/2026-10-10-vinsmart-future-ar-ap/task-8.3-report.md` (New)

## 3. Kịch bản kiểm thử (TDD)
1. Kịch bản UAT AR & Open Banking: Tạo hóa đơn GTGT -> Webhook báo có VA -> Tầng 1 tự động gạch nợ -> GL cân đối.
2. Kịch bản UAT AP & Phê duyệt chi: Tạo hóa đơn NCC AWS USD với FCT -> Phê duyệt AP 4 cấp -> Lệnh chi ngân hàng -> Ghi sổ AP.
3. Kịch bản UAT Đối soát & Kênh thanh toán: Bảng kê cổng B2C giải phóng 10tr tạm giữ, 150k phí kênh -> Hoàn tiền chi hộ.
4. Kịch bản UAT Netting nội bộ & Safety Gate: Bù trừ chéo 3 bên VSF - VinFast - Vinhomes -> Báo cáo tuổi nợ chặn ngắt API.
5. Kịch bản UAT Đồng bộ SAP ERP & Cutover Sign-off: Batch 22:00 đồng bộ thành công sang SAP ERP, sẵn sàng Go-Live.
