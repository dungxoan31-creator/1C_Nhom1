# Task 7.1 Brief: Tích Hợp Webhook Ngân Hàng, HMAC-SHA256 & So Sánh Hằng Thời Gian

## 1. Mục tiêu
Xây dựng `CommonModule.TichHopNganHangServer` để chuẩn hóa tầng tích hợp Open Banking (Techcombank, VietinBank):
1. **Xác thực chữ ký số HMAC-SHA256:**
   - Tính toán chữ ký HMAC-SHA256 từ `PayloadRaw` và `SecretKey`.
   - Hàm so sánh hằng thời gian (`SoSanhHangThoiGian`) để triệt tiêu lỗ hổng Timing Attack.
2. **Phân tích và điều phối nghiệp vụ Webhook:**
   - Bóc tách mã đối tác và mã hợp đồng từ `VirtualAccount` (VA 9624...).
   - Kiểm tra tính toàn vẹn payload và trạng thái kết nối.

## 2. File tác động
- `tests/integration/BankingWebhookIntegrationTest.bsl` (New)
- `src/CommonModules/TichHopNganHangServer.xml` (New)
- `src/CommonModules/TichHopNganHangServer/Ext/Module.bsl` (New)
- `src/Configuration.xml` (Register CommonModule)

## 3. Kịch bản kiểm thử (TDD)
1. Xác thực HMAC-SHA256 chuẩn xác: Payload và SecretKey khớp -> Kết quả chữ ký đúng.
2. Timing Attack Mitigation: Hàm `SoSanhHangThoiGian` trả về False an toàn khi chữ ký sai lệch mà không bị rò rỉ thời gian.
3. Chữ ký bị can thiệp (Tampered Signature) -> Bị từ chối ngay lập tức.
4. Bóc tách Virtual Account 96248888001 -> Nhận diện đúng cấu trúc VA 9624 và mã định danh hợp đồng.
5. Metadata Schema XML của CommonModule hợp lệ 100% theo chuẩn 1C version 2.15.
