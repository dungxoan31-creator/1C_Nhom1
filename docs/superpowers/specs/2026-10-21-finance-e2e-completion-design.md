# Đặc tả hoàn thiện báo cáo và E2E tài chính VSF

**Trạng thái:** Người dùng đã duyệt phạm vi ban đầu ngày 21/10/2026; các yêu cầu bổ sung AR/AP ở mục 3.5 được ghi nhận từ chỉ dẫn tiếp theo của người dùng. Kế hoạch triển khai đang chờ duyệt; chưa sửa cấu hình hoặc tạo `.dt`.

## 1. Mục tiêu

Hoàn thiện cấu hình 1C để người dùng có thể tự xem và đối chiếu công nợ sau mỗi bước nghiệp vụ, mở chứng từ nguồn từ báo cáo/dashboard, nhập bảng kê ngân hàng hoặc cổng thanh toán từ CSV, và trình bày rõ luồng nghiệp vụ cùng kết quả ghi sổ. Mở rộng E2E để kiểm tra trực tiếp các điểm này trên giao diện 1C, sau đó dựng và bàn giao một file `.dt` đã được kiểm chứng.

Đầu vào hiện tại đã có các luồng ghi sổ AR/AP, thu/chi, cấn trừ, đối soát tổng tiền cổng thanh toán và dashboard. Run gần nhất theo tài liệu dự án là `finance-e2e-20261021-154500-dc7c3b127103435faab1f81a611f0a43`, 90/90 pha PASS. Run đó chưa chứng minh người dùng mở được sổ chi tiết, báo cáo tuổi nợ hoặc drill-down từ dashboard; cũng chưa kiểm tra import sao kê CSV.

## 2. Phạm vi

### Trong phạm vi

1. Báo cáo sổ chi tiết công nợ phải thu AR và phải trả AP, có số dư đầu kỳ, phát sinh trong kỳ, số dư cuối kỳ, bộ lọc và mở chứng từ nguồn.
2. Báo cáo tuổi nợ AR/AP và drill-down nhất quán từ các chỉ số, biểu đồ, danh sách nợ trên dashboard.
3. Nhập bảng kê ngân hàng/cổng thanh toán từ CSV, xem trước, ánh xạ cột, phát hiện trùng, ghép dòng thu với hóa đơn AR và kiểm soát sai lệch trước khi ghi sổ.
4. Hướng dẫn luồng nghiệp vụ trong ứng dụng và tài liệu giải thích chứng từ, tài khoản, kết quả ghi sổ, điểm vào mã xử lý.
5. Hoàn tất kịch bản demo thủ công AR, AP, cấn trừ, đối soát, xem sổ và báo cáo; thêm checklist phỏng vấn/đánh giá nhóm thành một tài liệu riêng.
6. Mở rộng E2E UI và kiểm tra đối chiếu dữ liệu của các chức năng mới.
7. Dựng file `.dt` cuối từ cấu hình đã cập nhật, giữ bản sao file hiện tại, thử nạp file ứng viên vào bản sao infobase và chỉ thay file gốc sau khi kiểm tra đạt.
8. Sửa form AR/AP, tự điền hóa đơn đầu ra từ BBNT, cấu hình người lập/người duyệt/trạng thái đúng tab, thêm cờ FCT trên form AP và lệnh xem chuyển động sổ cho mọi chứng từ có ghi sổ.

### Ngoài phạm vi

- Kết nối API ngân hàng/cổng thanh toán thật hoặc gửi lệnh thanh toán thật.
- Gửi, ký hoặc phát hành hóa đơn điện tử với nhà cung cấp/CQT.
- Thay đổi quy tắc thuế, hệ thống tài khoản hoặc chính sách hạch toán pháp định. Các ví dụ thuế trong demo là dữ liệu trình diễn; cấu hình thuế nghiệp vụ phải được xác nhận riêng.
- Tự động ghép những khoản thu tổng hợp với nhiều hóa đơn mà không có phân bổ do người dùng xác nhận. Bản đầu hỗ trợ ghép một dòng sao kê với một hóa đơn AR; khoản thu cho nhiều hóa đơn cần nhập/phân bổ thành các dòng rõ ràng.
- Đánh giá mức độ hiểu nghiệp vụ của từng thành viên bằng E2E; phần này là checklist trao đổi riêng.

## 3. Thiết kế chức năng

### 3.1. Sổ chi tiết AR và AP

Tạo hai báo cáo 1C có thể mở từ giao diện ứng dụng: **Sổ chi tiết công nợ phải thu (AR)** và **Sổ chi tiết công nợ phải trả (AP)**. Báo cáo đọc dữ liệu từ các register công nợ hiện có (`CongNoPhaiThu`, `CongNoPhaiTra`), không tự tính lại số dư từ danh sách chứng từ và không tạo bản sao số liệu kế toán.

Mỗi báo cáo có các bộ lọc: khoảng ngày, pháp nhân, đối tác, hợp đồng, tiền tệ và chứng từ nguồn. Có thể chạy theo tất cả đối tác mà quyền người dùng cho phép hoặc giới hạn vào một đối tác. Kết quả hiển thị số dư đầu kỳ, phát sinh tăng/giảm trong kỳ, số dư cuối kỳ; từng dòng có ngày, số chứng từ, loại chứng từ, diễn giải, số tiền và số dư lũy kế. Chỉ chứng từ đã ghi sổ mới tạo phát sinh. Hủy ghi sổ phải làm dòng phát sinh biến mất khi chạy lại báo cáo.

Số chứng từ nguồn là liên kết 1C có thể bấm để mở đúng chứng từ. Dòng có đối tác/hợp đồng/chứng từ rỗng hoặc không còn truy cập được phải được chỉ rõ; không âm thầm bỏ khỏi tổng. Báo cáo cung cấp tổng cộng theo pháp nhân/đối tác và một chỉ báo đối chiếu với các tài khoản công nợ trên sổ cái theo cùng kỳ, pháp nhân và phạm vi lọc. Đối chiếu dùng cách hạch toán và ánh xạ tài khoản đang có trong cấu hình; nếu khác biệt, hiển thị số chênh và cảnh báo để kiểm tra, không tự điều chỉnh bút toán.

### 3.2. Tuổi nợ và dashboard

Tạo báo cáo **Tuổi nợ AR/AP** có thể chọn loại công nợ, ngày chốt, pháp nhân, đối tác và hợp đồng. Số dư tuổi nợ lấy từ số dư còn mở trên register tại ngày chốt, không lấy tổng giá trị hóa đơn ban đầu. Ngày đến hạn tiếp tục theo nguồn ngày chứng từ và số ngày thanh toán của hợp đồng mà dashboard hiện đang dùng. Nếu thiếu hợp đồng hoặc thiếu kỳ hạn thanh toán, đưa dòng vào nhóm **Chưa xác định hạn** để người dùng thấy và xử lý; không gộp vào nhóm trong hạn.

Các nhóm tuổi nợ: **Trong hạn**, **Quá hạn 1–30 ngày**, **31–60 ngày**, **61–90 ngày**, **Trên 90 ngày**, và **Chưa xác định hạn**. Báo cáo hiển thị tổng từng nhóm và danh sách chứng từ còn dư, số ngày đến/quá hạn, đối tác, hợp đồng và số dư. Từng dòng mở được chứng từ nguồn.

Dashboard và báo cáo phải dùng chung cách phân nhóm và cùng ngày chốt. Bấm một nhóm tuổi nợ, phần trăm trên biểu đồ, dòng khách hàng quá hạn hoặc khoản mục chờ xử lý sẽ mở báo cáo chi tiết với sẵn bộ lọc tương ứng. Biểu đồ doanh thu/dòng tiền mở bảng dữ liệu kỳ tương ứng. Các hành động dùng lệnh/form 1C được đăng ký trực tiếp; không dựa vào protocol tùy biến `vsmart://` hoặc `vinsmart:` mà hệ điều hành không nhận diện.

### 3.3. Nhập và đối soát CSV

Mở rộng luồng **Đối soát kênh thanh toán** bằng bước **Nhập CSV → Ánh xạ cột → Xem trước → Đối chiếu → Xác nhận**. Import không tự ghi sổ, không tự gửi lệnh tiền và không gọi dịch vụ ngoài. Người dùng chọn pháp nhân, tài khoản tiền, kênh, tiền tệ và file. Có thể lưu cấu hình ánh xạ theo ngân hàng/kênh để dùng lại.

Các dữ liệu dòng tối thiểu: mã giao dịch bên ngoài (nếu có), ngày giao dịch/ngày giá trị, nội dung, số tiền thu hoặc chi, tiền tệ, mã tham chiếu hóa đơn/đối tác (nếu có), phí và số tiền thực nhận khi bảng kê tách riêng phí. Màn hình xem trước báo số dòng hợp lệ, lỗi, trùng, chưa ghép và lệch tiền; lỗi nêu số dòng và trường cần sửa. Hỗ trợ chọn dấu phân cách, encoding và ánh xạ tên cột; không tự đoán rồi âm thầm ghi nhận.

Với dòng tiền vào, hệ thống gợi ý hóa đơn AR đã phát hành và còn dư theo số hóa đơn/mã tham chiếu, đối tác và số tiền còn phải thu. Người dùng xác nhận ghép trước khi tạo chứng từ thu liên kết. Cho phép thu một phần trong giới hạn số dư còn lại; phần công nợ dư tiếp tục hiện trong sổ/tuổi nợ. Dòng chưa ghép, trùng hoặc sai số tiền không được ghi sổ cho tới khi xử lý hoặc loại khỏi đợt đối soát kèm lý do. Hệ thống không tự gán dòng thu vào hóa đơn chỉ vì số tiền trùng nhau.

Nhận diện trùng ưu tiên mã giao dịch ngoài hệ thống cùng pháp nhân/tài khoản/kênh; khi file không có mã giao dịch thì dùng dấu vân tay chuẩn hóa từ tài khoản, ngày, tiền tệ, số tiền và nội dung tham chiếu. Nhập lại cùng dòng phải được đánh dấu trùng và không tạo thêm phiếu thu, phát sinh tiền hoặc bút toán.

Với khoản thanh toán qua cổng có phí, kiểm tra bất biến **Tổng giao dịch = Phí + Thực nhận** theo đúng tiền tệ và quy tắc làm tròn hiện có. Chỉ số thực nhận mới đi vào sổ tiền; phí và tài khoản đối ứng theo logic đối soát hiện tại. Dòng không có đủ thông tin để xác định phí/số thực nhận phải được đưa vào danh sách cần xử lý thay vì suy ra số liệu.

### 3.4. Hướng dẫn quy trình và giải thích nghiệp vụ

Thêm mục **Hướng dẫn quy trình tài chính** trong giao diện ứng dụng, trình bày sơ đồ AR, AP, cấn trừ nội bộ và đối soát bảng kê. Mỗi sơ đồ chỉ rõ vai trò lập/duyệt, thứ tự chứng từ, điều kiện chuyển bước và kết quả công nợ/tiền/sổ cái mong đợi. Các trang hướng dẫn giải thích mục đích từng chứng từ, tài khoản bị tác động theo cấu hình hiện tại, điều kiện ghi sổ/hủy ghi sổ, các kiểm tra Maker-Checker, và tên module/method BSL liên quan để nhóm trình bày có thể tra cứu.

Cập nhật `docs/Kich_ban_demo_VinSmart_Future.md` để đi hết các bước: hóa đơn AR được phát hành theo dữ liệu demo hợp lệ → phiếu thu → sổ AR; hóa đơn AP → duyệt/ghi sổ → ủy nhiệm chi → sổ AP/tiền; cấn trừ → thu phần dư; import và ghép bảng kê CSV; mở tuổi nợ/dashboard và kiểm tra drill-down. Ghi rõ tài khoản demo, dữ liệu chuẩn bị, kết quả số cần thấy, vai trò từng người và điểm dừng an toàn. Tạo thêm checklist trao đổi/đánh giá thành viên dưới `docs`, không lưu câu trả lời cá nhân hoặc thông tin nhạy cảm trong file `.dt`.

Đối với VAT trình diễn, dùng một bộ dữ liệu demo thống nhất ở mức 10% như kịch bản hiện có: hóa đơn AR 200.000.000 + 20.000.000 VAT = 220.000.000 VND; hóa đơn AP dịch vụ 100.000.000 + 10.000.000 VAT = 110.000.000 VND, nếu phù hợp fixture/điều kiện thuế đã có. Giữ các case 8% hiện có trong E2E như case kiểm tra riêng có nhãn rõ ràng; không thay đổi tỷ lệ thuế hoặc kết luận về điều kiện giảm thuế chỉ để làm đẹp số demo. Mọi số cấn trừ mới trong lời thoại phải khớp kết quả kiểm tra từ fixture.

### 3.5. Form chứng từ, duyệt và chuyển động sổ

**Hóa đơn đầu ra AR:** sắp xếp trang **4. Nhật ký & Phê duyệt** để có người tạo, người duyệt, trạng thái quy trình, trạng thái hóa đơn điện tử và diễn giải. Trạng thái quy trình (`ChoDuyetNoiBo`) và trạng thái hóa đơn (`DaPhatHanh`) là hai trường riêng, cùng nằm trên Tab 4; trạng thái hóa đơn được bỏ khỏi Tab 3 **Thuế & HĐĐT**, nơi giữ thông tin thuế và định danh hóa đơn. Người tạo tự điền từ người dùng hiện hành lúc tạo và chỉ đọc. Người duyệt là lựa chọn từ danh sách tài khoản có thẩm quyền, gồm `ketoan_truong`, `Admin` và CFO khi số tiền thuộc diện phải có CFO theo ngưỡng 500.000.000 VND. Trên Tab 4 còn có trường diễn giải.

**Chọn BBNT trên hóa đơn AR:** sau khi người dùng chọn một biên bản nghiệm thu hợp lệ tại Tab 1, tự điền pháp nhân, đối tác, hợp đồng, giá trị chưa thuế, thuế suất, tiền thuế và tổng thanh toán từ biên bản/dữ liệu thuế của chứng từ nguồn. Với fixture demo đã thống nhất, các giá trị phải là 200.000.000 VND, 10%, 20.000.000 VND và 220.000.000 VND. Không hard-code 10% cho mọi BBNT; thuế suất phải theo dữ liệu được hệ thống tính cho BBNT đang chọn.

**Hóa đơn đầu vào AP:** trên Tab 1 **Thông tin chung**, thêm checkbox **Có khấu trừ thuế nhà thầu (FCT)** ngay sau tiền dịch vụ, gắn với đúng thuộc tính và logic tính/ghi sổ FCT hiện có. Trên Tab 3 **Trạng thái phê duyệt**, thêm trường người duyệt sử dụng cùng danh sách quyền và ngưỡng; trạng thái quy trình tiếp tục ở tab này. Bản ghi có FCT phải xem được đủ bút toán theo thiết kế hạch toán hiện hữu.

**Chuyển động sổ:** thêm lệnh **Khác → Chuyển động của chứng từ theo sổ** trên form của tất cả chứng từ có ghi sổ, tối thiểu BBNT, hóa đơn AR, hóa đơn AP, phiếu thu, ủy nhiệm chi, cấn trừ và đối soát. Lệnh mở cửa sổ native của 1C cho đúng chứng từ đang xem; các register có phát sinh hiển thị thành các tab ngay trong cùng màn hình, chẳng hạn BBNT có `SoCaiKeToan` và `CongNoPhaiThu`, hóa đơn AP có `SoCaiKeToan` và `CongNoPhaiTra`. Nếu chứng từ chưa ghi sổ, màn hình phải thể hiện không có phát sinh thay vì đưa người dùng tới một nơi không rõ. Tài liệu demo ghi đường dẫn menu và tên tab cụ thể.

Các trường người tạo/người duyệt là dữ liệu kiểm soát chứ không thay thế kiểm tra quyền phía server. Hệ thống vẫn bắt buộc người duyệt khác người lập và kiểm tra đúng vai trò/hạn mức lúc duyệt hoặc ghi sổ. CFO chỉ là lựa chọn hợp lệ khi tổng số tiền vượt ngưỡng 500.000.000 VND; các giá trị ngưỡng lấy từ cấu hình hiện hành, không chép cố định riêng trong form.

## 4. Mở rộng E2E và điều kiện nghiệm thu

Sau khi cập nhật, E2E cần kiểm tra các điều kiện sau trên bản sao infobase dùng riêng cho test:

1. Mở báo cáo AR và AP trên giao diện, lọc theo đối tác/kỳ; xác nhận số dư đầu, phát sinh và cuối kỳ bằng register sau các bước lập/ghi sổ chính.
2. Mở chứng từ nguồn từ một dòng báo cáo và xác nhận đúng số tham chiếu. Sau khi hủy ghi sổ trên fixture kiểm thử, chạy lại báo cáo và xác nhận movement đã được loại.
3. Tuổi nợ theo ngày chốt: các khoảng 1–30/31–60/61–90/trên 90, trong hạn và thiếu hạn khớp số dư fixture; tổng các nhóm bằng tổng số dư đang được phân nhóm.
4. Dashboard hiển thị số liệu có kiểm tra giá trị, không chỉ kiểm tra đã mở; bấm chỉ số/nhóm/dòng phải mở đúng báo cáo với đúng bộ lọc và tập chứng từ.
5. Import CSV hợp lệ, ánh xạ cột, ghép dòng thu với hóa đơn, ghi một phần và đối chiếu lại AR/cash/GL. Import lại cùng file phải phát hiện trùng, không tạo phát sinh lần hai.
6. CSV sai cấu trúc/thiếu cột/định dạng số không hợp lệ phải có lỗi chỉ dòng và không ghi sổ. Dòng không ghép được, lệch tiền hoặc sai invariant tổng-phí-thực nhận phải bị chặn cho đến khi được xử lý rõ ràng.
7. Thử case bảng kê VNPAY: tổng 75.000.000 = thực nhận 73.875.000 + phí 1.125.000 VND; cash/GL chỉ phản ánh phần thực nhận và phí theo hạch toán hiện tại.
8. Mở trang hướng dẫn trong ứng dụng, xác nhận các sơ đồ và mục giải thích có nội dung cho AR/AP/cấn trừ/đối soát; các nút thao tác liên quan mở được form 1C đích.
9. Chạy lại các luồng hồi quy AR, AP, cấn trừ, maker-checker, số dư GL/subledger và các case VAT hiện có. Kết quả phải ghi rõ PASS/FAIL/BLOCKED và lưu `summary.json` cùng log trong thư mục kết quả mới; không lấy run cũ làm bằng chứng cho code mới.
10. Dựng `.dt` ứng viên, nạp ứng viên vào một infobase tạm, kiểm tra cấu hình đã cập nhật và chạy E2E trên đúng bản dựng sẽ bàn giao. Chỉ thay file `.dt` chính sau khi kiểm tra này đạt; giữ lại bản trước thay thế.
11. Tab 4 AR hiển thị đúng người tạo (tự điền `ketoan_ar`, chỉ đọc), người duyệt, trạng thái quy trình `ChoDuyetNoiBo`, trạng thái hóa đơn `DaPhatHanh` và diễn giải; hai trạng thái không còn nhầm tab. Tab 3 chỉ giữ thông tin thuế/HĐĐT.
12. Danh sách người duyệt cho phép `ketoan_truong` và `Admin`; chỉ hiển thị/cho chọn CFO khi số tiền vượt 500.000.000 VND. Người lập không thể tự duyệt; người không có quyền hoặc chọn sai hạn mức bị từ chối ở server.
13. Chọn BBNT demo tự điền đúng pháp nhân, đối tác, hợp đồng, 200.000.000 VND trước thuế, VAT 10%, tiền thuế 20.000.000 VND và tổng 220.000.000 VND. Chọn BBNT có thuế suất khác phải dùng dữ liệu thuế của BBNT đó.
14. Với BBNT và hóa đơn AP, menu **Khác → Chuyển động của chứng từ theo sổ** mở đúng chứng từ; cửa sổ hiển thị đồng thời các tab `SoCaiKeToan` và register công nợ liên quan. Kiểm tra AP fixture 250.000.000 VND có đầy đủ dòng FCT theo fixture. Thực hiện smoke tương tự trên các form chứng từ có ghi sổ khác.

## 5. Bàn giao dự kiến

- Cấu hình XML/BSL đã cập nhật trong `VSF_Finance_E2E/Configuration`.
- Kịch bản E2E mở rộng và artifact kết quả của run mới.
- Form AR/AP đã sắp xếp lại, có luồng tự điền từ BBNT và lệnh mở chuyển động sổ cho các chứng từ có ghi sổ.
- Kịch bản demo và checklist đánh giá nhóm trong `docs`.
- File `.dt` hoàn thiện tại vị trí file chính hiện có: `VinSmart_Future_AdminFull_v5_SuaFont.dt`; lưu bản `.dt` trước khi thay cạnh đó làm dự phòng.
- Ghi chú bàn giao nêu phiên bản runtime, hash SHA-256, run E2E ứng với file `.dt` và mọi hạng mục chưa thể kiểm tra.

Không tuyên bố `.dt` hoàn tất nếu không thể cập nhật cấu hình, nạp lại file ứng viên và chạy được kiểm tra trên đúng artifact. Runtime 1C `8.3.22.1704` hiện có trong máy; công cụ khám phá nền tảng của toolkit chưa tìm thấy platform đã đăng ký nên quy trình build/nạp thực tế cần được xác nhận ở giai đoạn triển khai.

## 6. Tự rà soát đặc tả

- Đã phân biệt rõ các năng lực đang có với các phần chưa được chứng minh bằng run 90/90.
- Báo cáo dùng register hiện hữu làm nguồn số liệu, tránh tạo sổ song song.
- Quy tắc tuổi nợ được thống nhất giữa dashboard và báo cáo; số dư thiếu kỳ hạn được hiển thị riêng.
- Import CSV có xem trước, phát hiện trùng, xác nhận ghép và chặn ghi sổ khi còn dòng không hợp lệ; không gọi API thật.
- Các bước hoàn thiện E2E có giá trị đối chiếu dữ liệu và thao tác drill-down cụ thể.
- Các trường người tạo/người duyệt, hai loại trạng thái, FCT và lệnh chuyển động sổ có tiêu chí giao diện lẫn kiểm soát server riêng.
- Đã tách checklist phỏng vấn nhóm khỏi `.dt` và giữ case VAT 8% như hồi quy riêng, không thay quy tắc thuế để đồng nhất demo.
- Hạng mục cần xác minh khi triển khai: cách đăng ký platform 1C trong môi trường toolkit và khả năng dựng/nạp `.dt` cuối trên runtime đang có.
