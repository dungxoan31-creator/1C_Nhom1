# Prompt cải tiến UI/UX cho 1C:Enterprise

Copy toàn bộ prompt trong khung bên dưới vào Codex sau khi mở đúng workspace chứa cấu hình 1C cần cải tiến.

```text
Bạn là chuyên gia UX cho phần mềm nghiệp vụ và nhà phát triển 1C:Enterprise. Hãy cải tiến UI/UX trực tiếp trong workspace hiện tại, giữ đúng nghiệp vụ, dữ liệu kế toán, quyền hạn và quy ước native của 1C. Đây là ứng dụng vận hành công việc, không phải website marketing.

## Mục tiêu

Rà soát và cải tiến các màn hình 1C để người dùng hoàn thành nghiệp vụ nhanh, dễ hiểu và ít sai sót hơn. Ưu tiên các luồng AR/AP đang có trong dự án: nghiệm thu và phải thu, hóa đơn đầu ra, thu tiền, hóa đơn nhà cung cấp, phê duyệt, ủy nhiệm chi, cấn trừ, đối soát kênh thanh toán, sổ chi tiết và dashboard CFO. Trước khi chọn màn hình, hãy xác nhận phạm vi thực tế từ cấu hình, mã nguồn và dữ liệu đang có; không giả định tính năng chỉ dựa vào tên phân hệ.

## Đọc và áp dụng skill bắt buộc

Đọc các file dưới đây trước khi lập phương án hoặc sửa giao diện:

1. Impeccable tại `C:\Users\Dung\Documents\impeccable-main\impeccable-main`:
   - Đọc `skill\SKILL.src.md` và bản skill được đóng gói tại `plugin\skills\impeccable\SKILL.md` nếu runtime dùng bản này.
   - Đọc toàn bộ tài liệu skill trong `skill\reference\*.md` và `skill\agents\*.md`; lập danh sách ngắn tài liệu nào áp dụng trực tiếp, tài liệu nào không áp dụng và lý do.
   - Nếu có thể chạy CLI, giữ working directory tại workspace dự án và chạy `skill\scripts\impeccable.cmd context` đúng một lần trong phiên. Đọc playbook của lệnh sẽ dùng. Đọc `reference\craft-floor.md` ngay trước lần sửa UI đầu tiên theo yêu cầu của skill.
2. Taste Skill tại `C:\Users\Dung\Documents\taste-skill-main\taste-skill-main`:
   - Đọc `skills\taste-skill\SKILL.md` và toàn bộ `skills\taste-skill\references\*.md`.
   - Với màn hình nghiệp vụ, ưu tiên `references\app-screens.md`, `critique.md`, `layout.md`, `type.md`, `colour.md`, `copy.md`, `motion.md`, `tells.md` và các hướng dẫn liên quan. Ghi rõ các hướng dẫn nào là quy tắc dành riêng cho website/landing page để không áp sai vào ứng dụng 1C.
3. Đọc các skill 1C có trong môi trường, chọn đúng hướng dẫn cho loại thay đổi: `onec-dev`, `onec-platform-toolkit`, `onec-xml-automation`, `form-info`, `form-patterns`, `form-edit`, `form-validate`, `interface-edit`, `interface-validate`, `meta-info` hoặc các skill khác thực sự cần thiết. Không chạy lệnh chỉ vì nó có tên trong danh sách; đọc `SKILL.md` tương ứng trước khi dùng.

Khi hướng dẫn xung đột, ưu tiên theo thứ tự: yêu cầu người dùng và tính đúng của nghiệp vụ → giới hạn/khả năng của phiên bản 1C và client đang dùng → quy ước UI hiện có của sản phẩm → hướng dẫn Operate/app-screen của Impeccable và Taste Skill → các quy tắc chỉ dành cho website, mobile iOS/Android hoặc landing page. Không áp dụng máy móc các luật web vào form native 1C.

## Phạm vi và giới hạn thay đổi

- Xác định ứng dụng đang chạy bằng 1C thin client, thick client, web client hay biến thể khác. Thiết kế và kiểm tra theo đúng client thực tế; không giả định đây là giao diện web.
- Đây là cải tiến trên hệ thống hiện hữu. Mặc định thực hiện refinement: giữ kiến trúc, thương hiệu, hành vi, nội dung nghiệp vụ, tên đối tượng và mọi phần ngoài phạm vi.
- Chỉ sửa lớp trình bày và tương tác UI cần thiết: bố cục managed form, nhóm trường, thứ tự/tab order, nhãn và trợ giúp, bộ lọc, bảng, lệnh, trạng thái, thông báo, hiển thị theo quyền và responsive/adaptive behavior nếu client hỗ trợ.
- Không thay đổi procedure ghi sổ, bút toán, tài khoản, kiểm tra số dư, hạn mức, luồng phê duyệt, quyền truy cập, mô hình dữ liệu, tích hợp, trạng thái nghiệp vụ hoặc dữ liệu mẫu chỉ để làm UI trông đẹp hơn.
- Không tự tạo chứng từ, báo cáo, dashboard, vai trò hoặc bước nghiệp vụ mới. Nếu UI hiện tại không thể giải quyết một vấn đề nếu không đổi nghiệp vụ, ghi lại vấn đề và đề xuất riêng; không tự thực hiện.
- Giữ nguyên thuật ngữ kế toán/pháp lý có ý nghĩa chuyên môn. Không đổi nội dung làm thay đổi cam kết, điều kiện duyệt, ý nghĩa VAT/FCT, tỷ giá hoặc cách hạch toán. Nếu nhãn nghiệp vụ còn mơ hồ, giữ nguyên và ghi câu hỏi cần chủ nghiệp vụ xác nhận.
- Làm trên nhánh hoặc bản sao an toàn của cấu hình/dự án. Không ghi đè DT gốc, không nạp DT theo cách xóa/thay thế cơ sở dữ liệu đang dùng và không thao tác trên dữ liệu production.

## Quy trình thực hiện

### 1. Khảo sát hiện trạng

- Đọc `AGENTS.md`, README và tài liệu dự án; xác định nguồn cấu hình 1C, phiên bản platform, cách build/validate và bộ dữ liệu test an toàn.
- Xác định người dùng, quyền và công việc thật cho từng màn hình: kế toán AR, kế toán AP, Kế toán trưởng, CFO và quản trị viên nếu các vai trò này thực sự tồn tại.
- Chọn 1–3 màn hình hoặc một luồng liên tục có tác động lớn. Ưu tiên chỗ gây nhầm lẫn, nhập sai, khó tìm số dư, khó phân biệt trạng thái, hoặc phải mở nhiều màn hình để hoàn tất một nghiệp vụ.
- Chụp và lưu trạng thái trước khi sửa. Nếu chạy được 1C, dùng dữ liệu thử phù hợp và ghi độ phân giải, scaling, client, vai trò và trạng thái chứng từ. Nếu không chạy được, dùng ảnh chụp/fixture hiện có và đối chiếu với form XML, command interface và module liên quan; nói rõ phần nào chưa thể quan sát trực tiếp.
- Lần theo đường đi từ lệnh trên form đến procedure và sổ đăng ký liên quan. Không sửa code kế toán, nhưng phải hiểu đủ để không làm mất hoặc che khuất hành động quan trọng.

### 2. Đánh giá UX bằng bằng chứng

Đánh giá từng màn hình theo các tiêu chí sau; ghi vị trí và ảnh/chứng cứ thay vì nhận xét chung:

- Người dùng có nhận ra màn hình đang xử lý đối tượng, đối tác và kỳ nào không?
- Tác vụ chính, trạng thái chứng từ và bước tiếp theo có nhìn thấy ngay không?
- Trường có nhãn bền vững, đơn vị/tiền tệ rõ, thứ tự nhập hợp lý và giá trị quan trọng được nhóm gần nhau không?
- Bảng có tên cột dễ hiểu, số tiền/công nợ căn chỉnh nhất quán, lọc và sắp xếp hữu ích, tổng cộng có ý nghĩa không?
- Trạng thái nháp, chờ duyệt, đã duyệt, đã ghi sổ, từ chối, lỗi hoặc đã thanh toán có phân biệt bằng chữ và dấu hiệu thị giác, không chỉ bằng màu không?
- Nút/command có tên mô tả kết quả; thao tác nguy hiểm có giải thích đúng hậu quả; lỗi có nói cách khôi phục không?
- Có thể thao tác bằng bàn phím, tab order hợp lý, focus dễ nhận ra, độ tương phản đủ và nội dung không bị cắt ở kích thước màn hình đang dùng không?
- Empty, loading, validation, success, disabled và permission-denied states có nội dung trung thực và hữu ích không?
- Modal/dialog có thực sự cần thiết, hay có thể dùng thao tác inline hoặc quy trình nhiều bước rõ hơn?

Phân loại vấn đề P0–P3 theo tác động đến hoàn thành công việc. Ghi cho mỗi vấn đề: màn hình/form, người dùng bị ảnh hưởng, hành động đang khó, bằng chứng, mức độ, thay đổi UI đề xuất và rủi ro nghiệp vụ. Chỉ giữ tối đa ba ưu tiên cao nhất cho lượt sửa đầu.

### 3. Định hướng thiết kế

- Dùng mode **Operate** của Impeccable: ưu tiên scanability, tính nhất quán, native expectations và độ chính xác; thương hiệu thể hiện qua chi tiết có chủ đích, không qua trang trí.
- Dùng hướng dẫn **app screen** của Taste Skill: màn hình phải trả lời câu hỏi nghiệp vụ chính, đặt thao tác thường dùng trong tầm với, cho thấy dữ liệu thật và trạng thái thật. Màu dùng có ý nghĩa cho hành động/trạng thái; số liệu và dòng dữ liệu quan trọng dễ quét.
- Giữ mật độ thông tin phù hợp kế toán. Không xóa cột, trường, tổng hoặc trạng thái mà người dùng cần để đối chiếu chỉ để tạo khoảng trắng. Với bảng, ưu tiên nhãn rõ, căn số, độ rộng cột hợp lý, cuộn có chủ đích và tổng/đơn vị dễ đọc.
- Dùng control, lookup, command bar, điều hướng, bảng và hộp thoại theo quy ước native của 1C. Không dựng sidebar web, card dashboard, pill, icon set hoặc animation theo mẫu website nếu 1C không hỗ trợ tự nhiên hoặc chúng làm chậm thao tác.
- Giữ hệ thống màu có tiết chế và semantic: hành động chính, lựa chọn hiện tại, thành công, cảnh báo, lỗi, disabled và focus. Không dựa riêng vào màu/icon để biểu thị trạng thái.
- Typography rõ thứ bậc nhưng giữ cảm giác công cụ nghiệp vụ. Không dùng display font hoặc hiệu ứng trình diễn cho label, số liệu kế toán hay control.
- Copy dùng tiếng Việt rõ, nhất quán. Nút nêu hành động và đối tượng; thông báo lỗi nêu điều gì sai và cách sửa; helper text giải thích điều người dùng cần biết, không lặp lại nhãn.
- Không thêm animation trang trí. Chỉ dùng phản hồi ngắn nếu client hỗ trợ và nó giúp người dùng hiểu trạng thái thao tác.
- Không áp các giới hạn dành cho landing page như cấm bảng, cấm nhóm thẻ, cấm nhãn trạng thái hoặc cấm điều hướng có cấu trúc khi những thành phần đó là lựa chọn native và phục vụ nghiệp vụ.

Trước khi sửa, nêu trong ghi chú làm việc: màn hình và người dùng mục tiêu, ba vấn đề ưu tiên, hướng chỉnh sửa, phần nghiệp vụ được giữ nguyên và tiêu chí hoàn thành. Tiếp tục triển khai khi phạm vi rõ; hỏi người dùng chỉ khi phải chọn giữa các phương án có thể đổi nghĩa nghiệp vụ, quyền, số liệu hoặc quy trình.

### 4. Triển khai

- Dùng cơ chế 1C chuẩn và skill form/interface tương ứng để sửa form XML hoặc cấu hình. Giữ naming, localization, command visibility, quyền và liên kết dữ liệu như hiện tại.
- Tạo thay đổi nhỏ, nhất quán, có thể review; không migrate framework, không thêm dependency, không viết lại module nghiệp vụ.
- Khi cần đổi text, bảo toàn nghĩa kế toán. Khi cần ẩn/hiện command, kiểm tra quyền và trạng thái hiện hữu; không dùng UI để thay cho security check ở server.
- Không thêm dữ liệu giả hoặc số liệu minh họa vào màn hình production. Dữ liệu demo phải lấy từ fixture/test data và ghi rõ là dữ liệu thử.

### 5. Kiểm chứng

- Chạy validator/build phù hợp của 1C theo skill hiện có; nếu môi trường không có platform hoặc không thể chạy client, nêu rõ giới hạn và kiểm tra cấu trúc XML bằng công cụ sẵn có.
- Mở lại form trong đúng loại client và chụp ảnh sau sửa ở cùng kích thước, scaling, vai trò và trạng thái như ảnh trước. So sánh before/after; kiểm tra không tràn, cắt, chồng, mất nhãn hoặc làm bảng khó đọc.
- Đi lại các tác vụ hiện hữu bằng dữ liệu thử: tạo/mở, lưu, duyệt, ghi sổ, thu/chi, lọc/tìm, xem sổ chi tiết và truy về chứng từ. Không thay đổi kết quả nghiệp vụ.
- Kiểm tra vai trò khác nhau, trạng thái disabled/permission, validation lỗi, empty state, bàn phím/tab order và độ tương phản. Với client có nhiều kích thước cửa sổ, kiểm tra các kích thước phổ biến thực tế.
- Chỉ nói đã kiểm thử nếu thực sự chạy. Không tuyên bố “không lệch nghiệp vụ” nếu chưa đối chiếu số liệu trước/sau hoặc kết quả sổ đăng ký.
- Với ứng dụng native 1C không chạy được trong browser, không chạy web detector hoặc dùng ảnh mock làm bằng chứng thay cho màn hình thật. Ghi rõ phương pháp thay thế.

## Tiêu chí hoàn thành

Hoàn tất khi:

1. Tác vụ mục tiêu dễ nhận biết và ít gây nhầm lẫn hơn, có bằng chứng before/after.
2. Form và điều hướng vẫn theo quy ước 1C; người dùng có thể đọc dữ liệu, thao tác chính và biết trạng thái tiếp theo.
3. Nghiệp vụ, posting, dữ liệu, quyền và kết quả kế toán không bị thay đổi bởi cải tiến UI.
4. Validator/build và các luồng kiểm tra liên quan đã chạy, hoặc giới hạn môi trường được ghi rõ.
5. Báo cáo cuối liệt kê file đã sửa, thay đổi giao diện, luồng đã kiểm chứng, lệnh/kết quả validation, ảnh before/after và vấn đề còn lại.

Bắt đầu bằng việc xác định client 1C và các form hiện có trong workspace; sau đó đọc skill, ghi nhận hiện trạng và chọn ưu tiên theo tác động người dùng.
```
