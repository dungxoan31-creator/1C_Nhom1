# Kịch bản demo VinSmart Future Finance

Kịch bản này đi hết các luồng AR, AP, cấn trừ, CSV, báo cáo và đối chiếu sổ. Dùng riêng infobase demo/test với dữ liệu tổng hợp. Giao dịch ngân hàng thật và phát hành hóa đơn điện tử thật không thuộc demo này.

## Chuẩn bị

- Dùng các user nghiệp vụ đã được quản trị viên cấu hình: `ketoan_ar`, `ketoan_ap`, `ketoan_truong`, và khi cần kiểm tra ngưỡng cao `cfo_giamdoc`. Không dùng Admin để giả lập người duyệt tài chính.
- Đảm bảo dữ liệu thử cho pháp nhân Công ty Cổ phần VinSmart Future, khách hàng VinFast, nhà cung cấp thử nghiệm, hợp đồng và tài khoản ngân hàng có sẵn. Không gõ mã tham chiếu tự do khi mã đó không tồn tại trong danh sách lựa chọn.
- Dùng file CSV tổng hợp VNPAY có trong bộ kiểm thử; không đưa file sao kê thật hoặc thông tin tài khoản vào workspace.
- Có hai bộ tiền khác nhau: bộ demo AR/AP thông thường và fixture AP FCT. Không cộng chéo hoặc thay số giữa các bộ.
- VAT 10% trong kịch bản là số liệu demo. Các kiểm thử VAT 8% vẫn là bộ hồi quy độc lập.

## 1. AR: nghiệm thu, hóa đơn, thu tiền và sổ chi tiết

**Người lập:** `ketoan_ar`. **Người duyệt:** `ketoan_truong` hoặc người khác đủ quyền theo chính sách. Maker và checker phải là hai người khác nhau.

1. Mở **Functions → Biên bản nghiệm thu giai đoạn** và tạo BBNT cho Công ty Cổ phần VinSmart Future, đối tác Công ty Cổ phần Sản xuất và Kinh doanh VinFast, hợp đồng thử nghiệm tương ứng.
2. Nhập giá trị chưa thuế `200.000.000 VND`, VAT demo `10%`, tiền VAT `20.000.000 VND`, tổng `220.000.000 VND`. Lưu, kiểm tra người tạo tự điền và chỉ đọc, trạng thái ban đầu là chờ duyệt nội bộ; chọn checker khác người lập.
3. Mở **Khác → Chuyển động của chứng từ theo sổ** trên BBNT. Cùng màn hình hiển thị các tab `SoCaiKeToan` và `CongNoPhaiThu`; nếu BBNT chưa ghi sổ, không được mô tả là đã có bút toán.
4. Mở **Functions → Hóa đơn GTGT đầu ra**. Chọn BBNT tại tab 1; kiểm tra pháp nhân, đối tác, hợp đồng và toàn bộ số tiền được tự điền. Không sửa tay số VAT đã sao chép.
5. Tab 4 **Nhật ký & Phê duyệt**: kiểm tra người tạo, người duyệt, trạng thái quy trình và diễn giải. Trạng thái hóa đơn điện tử riêng có thể chọn `Đã phát hành` sau khi đã có xác nhận phát hành trong môi trường demo. Fixture mô phỏng không phát hành hóa đơn thật.
6. Lưu/duyệt/ghi sổ theo đúng quyền được cấp. Mở **Khác → Chuyển động của chứng từ theo sổ** của hóa đơn và đối chiếu `SoCaiKeToan`, `CongNoPhaiThu`.
7. Mở **Functions → Phiếu thu tiền khách hàng**, chọn hóa đơn nguồn, tài khoản tiền và khoản mục dòng tiền. Thu đủ `220.000.000 VND`, ghi sổ, rồi mở chuyển động chứng từ và sổ chi tiết AR. Dư nợ của hóa đơn phải về 0 sau khi thu đủ.

**Đối chiếu:** báo cáo **Sổ chi tiết công nợ phải thu** phải thể hiện chứng từ nguồn, phát sinh tăng/giảm và số dư. Tổng công nợ liên quan phải khớp sổ phụ `CongNoPhaiThu` và tài khoản kiểm soát trên `SoCaiKeToan`.

## 2. AP: hóa đơn nhà cung cấp, phê duyệt và thanh toán

**Người lập:** `ketoan_ap`. **Người duyệt:** `ketoan_truong`; CFO chỉ được chọn khi giá trị vượt `500.000.000 VND`. Không tự duyệt chứng từ do mình lập.

1. Mở **Functions → Hóa đơn nhà cung cấp**. Với fixture AP thông thường, nhập dịch vụ `100.000.000 VND`, VAT demo `10.000.000 VND`, tổng phải trả `110.000.000 VND`; chọn nhà cung cấp, hợp đồng và tài khoản chi phí phù hợp.
2. Tab 1 có checkbox `Có khấu trừ thuế nhà thầu (FCT)` sau trường tiền dịch vụ. Với bộ demo thông thường ở đây, để bỏ chọn.
3. Tab 3 chọn người duyệt và trạng thái chờ duyệt. Lưu bằng `ketoan_ap`; đăng nhập `ketoan_truong` để duyệt và ghi sổ theo quy trình.
4. Trên hóa đơn đã ghi sổ, mở **Khác → Chuyển động của chứng từ theo sổ**. Đối chiếu hai tab `SoCaiKeToan` và `CongNoPhaiTra`.
5. Lập ủy nhiệm chi từ hóa đơn nguồn, điền tài khoản tiền và khoản mục dòng tiền, thanh toán đủ `110.000.000 VND`, duyệt và ghi sổ bằng checker đủ quyền.
6. Mở chuyển động của ủy nhiệm chi và báo cáo **Sổ chi tiết công nợ phải trả**; xác nhận công nợ và số dư tiền giảm đúng số đã thanh toán.

### Fixture riêng: FCT Gross 250 triệu

Fixture `INV-AWS-2026-10` kiểm tra khấu trừ thuế nhà thầu đa tài khoản: Gross `250.000.000 VND`, khấu trừ `25.000.000 VND`, tiền thực trả `225.000.000 VND`. Đánh dấu FCT trước khi ghi sổ. Trên **Khác → Chuyển động của chứng từ theo sổ**, kiểm tra từng dòng chi phí/thuế FCT (bao gồm các tài khoản 3338/33311 theo cấu hình fixture) ở `SoCaiKeToan` và số dư Gross trên `CongNoPhaiTra`. Ủy nhiệm chi thanh toán thực tế `225.000.000 VND`. Đây là bộ kiểm thử riêng, không thay cho bộ AP thông thường `110.000.000 VND`.

## 3. Cấn trừ công nợ và khép số dư

1. Mở **Functions → Cấn trừ công nợ nội bộ**; chọn cùng pháp nhân, đối tác, tiền tệ và các chứng từ AR/AP đủ điều kiện.
2. Dùng số liệu fixture: AR `43.200.000 VND`, AP `40.000.000 VND`. Kiểm tra số tiền cấn trừ không vượt số dư rồi ghi sổ.
3. Mở chuyển động chứng từ theo sổ. Đối chiếu `CongNoPhaiThu`, `CongNoPhaiTra` và `SoCaiKeToan`; cấn trừ không tạo phát sinh trên register tiền `DongTien`.
4. Số dư sau cấn trừ: AR `3.200.000 VND`, AP `0 VND`. Thu phần AR còn lại `3.200.000 VND`; kiểm tra AR về 0.

## 4. Đối soát sao kê CSV với hóa đơn AR

1. Mở **Functions → Đối soát kênh thanh toán**. Chọn pháp nhân, tài khoản ngân hàng, VNPAY, tiền tệ VND và cấu hình dấu phân cách/cột theo file fixture.
2. Nhập/xem trước dữ liệu; kiểm tra mã giao dịch, ngày, hóa đơn AR, tiền Gross, phí, Net và trạng thái ghép. Bản demo dùng giao dịch Gross `75.000.000 VND`, phí `1.125.000 VND`, thực nhận `73.875.000 VND`.
3. Xác nhận `Gross = Net + phí`, ghép đúng hóa đơn và chỉ ghi sổ dòng hợp lệ. Giao dịch trùng hoặc sai định dạng phải bị chặn, không làm đổi AR, tiền hoặc sổ cái.
4. Mở **Khác → Chuyển động của chứng từ theo sổ** của đối soát. Kiểm tra `SoCaiKeToan`, `DongTien` và `CongNoPhaiThu`.
5. Thử nhập lại mã giao dịch để xác nhận chống trùng; sau đó bỏ ghi sổ fixture và kiểm tra mọi dòng đã sinh được đảo.

## 5. Dashboard, báo cáo và đường dẫn kiểm tra sổ

- **Dashboard:** mở **Bàn làm việc & Điều hành Web ERP**. Nút **Làm mới (F5)** cập nhật dữ liệu. Chọn nhóm tuổi nợ hoặc dòng công nợ để mở báo cáo tương ứng; chọn kỳ trên biểu đồ để đối chiếu kỳ nguồn.
- **Báo cáo AR:** **Functions → Sổ chi tiết công nợ phải thu**. Chọn kỳ, pháp nhân, đối tác, hợp đồng và tiền tệ. Kiểm tra số dư đầu kỳ, phát sinh, số dư cuối kỳ và mở chứng từ nguồn.
- **Báo cáo AP:** **Functions → Sổ chi tiết công nợ phải trả** với cùng nguyên tắc đối chiếu.
- **Báo cáo tuổi nợ:** **Functions → Báo cáo tuổi nợ**. Kiểm tra các nhóm trong hạn, quá hạn 1–30, 31–60, 61–90, trên 90 ngày và chưa xác định hạn; thử mở chứng từ nguồn.
- **Đường dẫn chi tiết chứng từ:** mở BBNT/hóa đơn/phiếu thu/ủy nhiệm chi/cấn trừ/đối soát đã ghi sổ → **Khác → Chuyển động của chứng từ theo sổ**. Tab xuất hiện theo register của chứng từ: ví dụ BBNT là `SoCaiKeToan` + `CongNoPhaiThu`; hóa đơn đầu vào là `SoCaiKeToan` + `CongNoPhaiTra`.
- Với chứng từ chưa ghi sổ, màn hình chuyển động có thể trống. Không dùng màn hình trống làm bằng chứng cho kết quả hạch toán.

## 6. Kiểm tra Maker-Checker và lỗi được chặn

1. Tạo chứng từ bằng user maker, chọn user checker khác; xác nhận người tạo ở chế độ chỉ đọc.
2. Thử để trống người duyệt, tự duyệt, chọn user không có quyền hoặc đặt trạng thái không hợp lệ. Hệ thống phải chặn ở phía server và không phát sinh sổ.
3. Thử ngưỡng CFO tại đúng `500.000.000 VND` và `500.000.001 VND`: CFO chỉ xuất hiện khi vượt ngưỡng nghiêm ngặt.
4. Ghi lại thông báo, mã chứng từ và kết quả số dư; không ghi mật khẩu, câu trả lời cá nhân hay thông tin ngân hàng thật vào bằng chứng demo.

## 7. Giải thích nhanh cho người trình bày

- AR tăng khi ghi nhận hóa đơn; giảm khi thu tiền hoặc cấn trừ. AP tăng khi ghi nhận hóa đơn nhà cung cấp; giảm khi thanh toán hoặc cấn trừ.
- `SoCaiKeToan` là sổ cái; `CongNoPhaiThu`/`CongNoPhaiTra` là sổ phụ công nợ; `DongTien` ghi biến động tiền. Cấn trừ không phải là thu/chi.
- Màn hình “Chuyển động của chứng từ theo sổ” cho biết chứng từ đã tạo những dòng nào trên register; báo cáo công nợ tổng hợp số dư theo kỳ và nguồn.
- FCT là cấu hình khấu trừ trên hóa đơn AP; phải kiểm tra tài khoản thuế và khoản tiền thực trả từ các dòng đã ghi sổ, không chỉ nhìn checkbox.
- Test E2E dùng dữ liệu tổng hợp và bank stub. Nó không chứng minh đã gửi lệnh ngân hàng thật hay phát hành hóa đơn điện tử thật.
