# Checklist trao đổi và đánh giá thành viên nhóm

Dùng một bản checklist cho mỗi lượt trao đổi. Ghi nhận nội dung nghiệp vụ đã quan sát được; để trống thông tin cá nhân và câu trả lời mẫu trước khi sử dụng. Không ghi mật khẩu, thông tin liên hệ cá nhân hoặc dữ liệu ngân hàng thật.

## 1. Luồng phải thu AR

- [ ] Giải thích BBNT → hóa đơn đầu ra → phiếu thu.
- [ ] Nêu được khi nào hóa đơn làm tăng AR và phiếu thu làm giảm AR.
- [ ] Thực hiện chọn BBNT và kiểm tra dữ liệu tự điền: pháp nhân, đối tác, hợp đồng, tiền trước thuế, VAT và tổng tiền.
- [ ] Mở chuyển động chứng từ và chỉ ra `SoCaiKeToan`, `CongNoPhaiThu`.
- [ ] Phân biệt trạng thái quy trình duyệt với trạng thái hóa đơn điện tử.

## 2. Luồng phải trả AP

- [ ] Giải thích hóa đơn nhà cung cấp → người duyệt → ủy nhiệm chi.
- [ ] Nêu tác động đến `CongNoPhaiTra`, `SoCaiKeToan` và `DongTien`.
- [ ] Giải thích checkbox FCT và kiểm tra được các dòng thuế đa tài khoản.
- [ ] Mở được chuyển động của hóa đơn AP và chỉ ra `SoCaiKeToan`, `CongNoPhaiTra`.
- [ ] Phân biệt Gross phải trả với tiền Net thực chuyển.

## 3. Cấn trừ (CanTru) và đối soát

- [ ] Giải thích điều kiện bù trừ cùng đối tác/pháp nhân/tiền tệ.
- [ ] Nêu vì sao cấn trừ không sinh dòng tiền.
- [ ] Kiểm tra được số dư AR/AP trước và sau cấn trừ.
- [ ] Mô tả cách nhập, xem trước, ghép, chống trùng và ghi sổ CSV.
- [ ] Đối chiếu được Gross = Net + phí và chỉ ra các register liên quan.

## 4. Báo cáo, dashboard và an toàn

- [ ] Mở sổ chi tiết AR/AP và báo cáo tuổi nợ.
- [ ] Mở chứng từ nguồn từ báo cáo hoặc dashboard.
- [ ] Giải thích các nhóm tuổi nợ và nhóm chưa xác định hạn.
- [ ] Giải thích Maker-Checker, trường hợp tự duyệt bị từ chối và ngưỡng CFO.
- [ ] Nêu được dữ liệu nào là fixture/demo và giới hạn của bank stub.

## 5. Bằng chứng và ghi nhận

| Mục | Ghi nhận |
|---|---|
| Mã lượt đánh giá | |
| Ngày đánh giá | |
| Vai trò đang kiểm tra (AR/AP/Checker/CFO) | |
| Luồng đã trình bày | |
| Chứng từ/báo cáo quan sát được | |
| Evidence đã lưu (đường dẫn nội bộ) | |
| Lỗi hoặc tình huống bị chặn đã giải thích | |

## 6. Thang điểm

Chấm từng nhóm từ 0 đến 2: `0` chưa thực hiện/giải thích được; `1` hoàn thành một phần hoặc cần gợi ý; `2` hoàn thành độc lập và đối chiếu đúng kết quả. Chỉ ghi điểm sau khi quan sát.

| Nhóm | Điểm (0–2) | Bằng chứng quan sát được |
|---|---:|---|
| AR | | |
| AP | | |
| Cấn trừ | | |
| CSV | | |
| Sổ cái và sổ phụ (`SoCaiKeToan`, `CongNoPhaiThu`, `CongNoPhaiTra`) | | |
| Maker-Checker và xử lý từ chối | | |
| Báo cáo và drill-down | | |

**Tổng điểm:** ____ / 14

**Điểm làm tốt đã quan sát:**


**Câu hỏi cần theo dõi thêm:**


**Hành động tiếp theo và thời hạn:**


