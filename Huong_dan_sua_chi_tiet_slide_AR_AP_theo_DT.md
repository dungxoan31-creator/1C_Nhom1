# Hướng dẫn sửa chi tiết slide AR/AP theo thực trạng DT

## 1. Mục đích và phạm vi

Tài liệu này hướng dẫn sửa bộ slide `VinSmart_Future_AR_AP_Presentation_Expanded_v2.pptx.pdf` theo cấu hình và mã nguồn trong `VinSmart_Future_AdminFull_v5_SuaFont.dt` đã được kiểm tra.

DT là căn cứ cho những nội dung nói về chức năng đã triển khai: đối tượng 1C, chứng từ, phân hệ, quy trình ghi sổ, bút toán, sổ đăng ký và màn hình điều hành. Thông tin về doanh nghiệp, khách hàng thật, địa điểm, số liệu kinh doanh hoặc kiến trúc ngoài DT cần có nguồn riêng.

Tài liệu này chỉ hướng dẫn sửa nội dung. Không sửa DT hoặc PDF. Các số liệu minh họa cần lấy từ dữ liệu đang có trong đúng bản DT trước buổi demo; không mặc định dữ liệu của một bộ test khác cũng có trong DT này.

### Kết luận rà soát

Bộ slide giải thích được ý tưởng AR/AP, nhưng một số số lượng đối tượng và một số bước quy trình chưa khớp với DT. Cần ưu tiên sửa slide 7, 10–15. Slide 14 có nhiều số lượng đúng với DT nhưng tuyên bố “51 E2E tests” cần chứng minh bằng kết quả chạy của đúng phiên bản.

### Mức ưu tiên

- **P0 – phải sửa trước khi trình bày:** số lượng sai; mô tả chức năng như đã triển khai trong khi DT chưa có; bút toán hoặc phê duyệt chưa đúng; tuyên bố kiểm thử không có bằng chứng cùng phiên bản.
- **P1 – nên sửa để demo dễ hiểu:** trình tự chứng từ; điểm mở sổ chi tiết; phân biệt chứng từ, sổ đăng ký, dashboard và báo cáo.
- **P2 – cần dẫn nguồn:** thông tin doanh nghiệp và bối cảnh thị trường không nằm trong DT.

---

## 2. Đối chiếu nhanh với DT

| Hạng mục | Thực trạng trong DT | Cách thể hiện trên slide |
|---|---:|---|
| Phân hệ (subsystem) | 6 | Có thể ghi 6 phân hệ; tên phân hệ phải khớp đúng cấu hình |
| Chứng từ (document) | 7 | Ghi đúng 7, không ghi 13 |
| Danh mục (catalog) | 9 | Ghi đúng 9, không ghi 10 |
| Vai trò (role) | 5 | Ghi đúng 5, không ghi 9 |
| Sổ đăng ký tích lũy (accumulation register) | 3 | Ghi đúng 3, không ghi 4 |
| Sổ đăng ký kế toán / GL | 1 | Ghi 1 |
| Đối tượng Report | 0 | Không giới thiệu như có các report object đã cấu hình |
| DataProcessor | 1 | Có `BanLamViecWebERP`, gồm dashboard và biểu mẫu phê duyệt hàng loạt |

### Bảy chứng từ trong DT

1. `BienBanNghiemThuGiaiDoan`
2. `HoaDonGTGTDauRa`
3. `PhieuThuTienKhachHang`
4. `HoaDonNhaCungCap`
5. `UyNhiemChi`
6. `CanTruCongNoNoiBo`
7. `DoiSoatKenhThanhToan`

### Các sổ đăng ký trong DT

- AR
- AP
- Tiền / dòng tiền
- Một sổ đăng ký kế toán để ghi nhận bút toán GL

Khi trình bày, phân biệt **chứng từ** (nguồn phát sinh nghiệp vụ), **sổ đăng ký** (nơi tập kết số dư/phát sinh sau ghi sổ), **GL** (bút toán kế toán) và **dashboard** (màn hình tổng hợp để theo dõi). Dashboard không đồng nghĩa với một report object.

---

## 3. Hướng dẫn sửa từng slide

### Slide 2 — Bối cảnh doanh nghiệp

**Đánh giá:** Nội dung giới thiệu doanh nghiệp không thể xác nhận chỉ bằng DT.

**Cách sửa:** Giữ lại nếu có tài liệu nguồn hoặc được nhóm xác nhận là bối cảnh giả lập. Gắn nhãn rõ “Bối cảnh doanh nghiệp” hoặc “Tình huống giả lập” nếu tên công ty và số liệu chỉ dùng để minh họa.

**Trước khi chốt:** Ghi nguồn cho tên pháp nhân, quy mô, doanh thu, ngành nghề và số liệu. Không dùng các dữ liệu trên như bằng chứng rằng DT đã cấu hình đầy đủ pháp nhân tương ứng.

### Slide 3 — Cơ cấu tổ chức / đơn vị

**Đánh giá:** Cần kiểm tra nguồn ngoài DT; sơ đồ tổ chức không chứng minh được quy trình phê duyệt trong phần mềm.

**Cách sửa:** Nếu giữ sơ đồ, thêm chú thích “cơ cấu bối cảnh”. Tách rõ sơ đồ tổ chức thật với vai trò hệ thống 1C. Vai trò được khai báo trong DT hiện có 5 role; không suy ra từ sơ đồ rằng mọi chức danh doanh nghiệp đã được phân quyền trong phần mềm.

### Slide 4 — Nguồn tri thức / quy trình hiện tại

**Đánh giá:** Slide có dẫn “Knowledge Base IT nội bộ do nhóm cung cấp”. Đây là nguồn ngoài DT.

**Cách sửa:** Giữ trích dẫn nếu nhóm có tài liệu thực tế. Thêm tên tài liệu, người/đơn vị cung cấp và ngày truy cập; nếu không có tài liệu để đối chiếu, đổi thành “Giả định nghiệp vụ dùng trong demo”.

### Slide 5 — Phạm vi bài toán

**Đánh giá:** Nội dung phạm vi có thể giữ nếu đúng mục tiêu đề tài, nhưng cần chỉ rõ đâu là nghiệp vụ được DT hỗ trợ.

**Câu gợi ý:** “Phạm vi demo tập trung vào ghi nhận và theo dõi công nợ phải thu, công nợ phải trả, thanh toán, cấn trừ và đối soát kênh thanh toán trong cấu hình DT hiện tại.”

### Slide 6 — Mục tiêu / giá trị

**Đánh giá:** Có thể giữ các mục tiêu như giảm thao tác và tăng khả năng đối chiếu. Tránh khẳng định đã đạt hiệu quả định lượng nếu chưa có số liệu đo.

**Cách sửa:** Dùng các cụm “hỗ trợ”, “cho phép theo dõi”, “giảm thao tác nhập lặp trong kịch bản demo”; chỉ ghi phần trăm tiết kiệm hoặc mức giảm sai sót khi có số liệu kiểm chứng.

### Slide 7 — Quy mô hệ thống

**Đánh giá:** Số lượng trên slide đang không khớp DT: slide nêu 13 Documents, 10 Catalogs, 9 Roles, 4 Accumulation Registers và 4+4 Reports/DP. Thực tế là 7 chứng từ, 9 danh mục, 5 vai trò, 3 sổ đăng ký tích lũy, 1 sổ kế toán, 0 Report object và 1 DataProcessor.

**Thay nội dung bằng:**

> **Cấu hình DT hiện tại**  
> 6 phân hệ · 7 chứng từ · 9 danh mục · 5 vai trò  
> 3 sổ đăng ký tích lũy · 1 sổ đăng ký kế toán  
> 1 DataProcessor điều hành (`BanLamViecWebERP`) · 0 Report object

**Ghi chú trình bày:** Nếu dashboard tạo ra bảng xem hoặc biểu đồ, có thể gọi là “dashboard/màn hình điều hành”. Không cộng dashboard vào số lượng report object. Nếu muốn nêu “4 báo cáo”, phải chỉ ra từng báo cáo đang tồn tại ở đâu và phân biệt báo cáo cấu hình trong metadata với truy vấn hoặc màn hình tổng hợp.

### Slide 8 — Bài toán nghiệp vụ

**Đánh giá:** Có thể giữ phần mô tả vấn đề tổng quát.

**Cách sửa:** Dẫn từ vấn đề sang hai quy trình sẽ demo: **phải thu khách hàng** và **phải trả nhà cung cấp**. Các vấn đề như theo dõi tuổi nợ, đối chiếu thanh toán, chậm phê duyệt nên gắn với thao tác cụ thể sẽ trình diễn ở slide 11 và 15.

### Slide 9 — Giải pháp tổng quan

**Đánh giá:** Hướng giải pháp AR/AP, ghi sổ và theo dõi công nợ phù hợp ở mức tổng quát.

**Cách sửa:** Dùng từ “hệ thống hỗ trợ” thay cho cam kết tự động hoàn toàn. Tách rõ các bước người dùng nhập chứng từ, chạy kiểm tra/phê duyệt, ghi sổ, rồi xem số phát sinh trên sổ AR/AP và GL.

**Câu gợi ý:** “Chứng từ là điểm bắt đầu của nghiệp vụ. Khi ghi sổ thành công, hệ thống cập nhật sổ công nợ và sổ kế toán; dashboard tổng hợp dữ liệu để người dùng theo dõi.”

### Slide 10 — Các phân hệ

**Đánh giá:** Con số 6 phân hệ phù hợp với DT. Thẻ AP đang liệt kê “Đề nghị thanh toán” như thể đó là một chứng từ riêng, nhưng DT không có document object này.

**Cách sửa:** Giữ tên và số phân hệ nếu đúng metadata. Trong thẻ AP, thay “Hóa đơn NCC • Đề nghị TT • UNC” bằng:

> Hóa đơn nhà cung cấp → luồng phê duyệt → Ủy nhiệm chi

Thêm chú thích: “Đề nghị thanh toán là bước nghiệp vụ/đề xuất trong luồng, không phải chứng từ riêng trong metadata DT hiện tại.” Nếu màn hình chạy có đối tượng khác thể hiện đề nghị này, hãy ghi rõ tên và loại đối tượng thực tế.

### Slide 11 — Quy trình AR/AP và cấn trừ

**Đánh giá:** Trình tự khung AR/AP phù hợp, nhưng có các điểm cần thu hẹp: “Tranh chấp → Điều chỉnh công nợ” không có chứng từ điều chỉnh riêng trong DT; đề nghị thanh toán không phải document object; đánh giá lại ngoại tệ cuối kỳ chưa phải quy trình/chứng từ riêng; cấn trừ có giới hạn dữ liệu và điều kiện theo mã nguồn.

#### Nội dung đề xuất cho luồng AR

> **Nghiệm thu dịch vụ** → **Ghi nhận doanh thu/công nợ theo chứng từ đang cấu hình** → **Lập/ghi sổ hóa đơn đầu ra** → **Nhận tiền** → **Đối chiếu sổ chi tiết AR và GL**

Trên slide, ghi tên chứng từ đúng theo DT: biên bản nghiệm thu giai đoạn, hóa đơn GTGT đầu ra và phiếu thu tiền khách hàng. Không mô tả cả biên bản nghiệm thu lẫn hóa đơn là cùng ghi nhận đầy đủ doanh thu, thuế và công nợ nếu chưa xác nhận bút toán thực tế của từng chứng từ; tránh tính doanh thu/AR hai lần.

Đổi “Tranh chấp → Điều chỉnh công nợ” thành “Ghi nhận trạng thái tranh chấp trên hồ sơ nghiệm thu (nếu dùng)”. Chỉ thêm bước điều chỉnh sau khi có chứng từ hoặc thủ tục điều chỉnh thực sự trong phiên bản demo.

#### Nội dung đề xuất cho luồng AP

> **Nhận hóa đơn nhà cung cấp** → **Kiểm tra và trình duyệt theo hạn mức đang áp dụng** → **Lập ủy nhiệm chi** → **Ghi nhận thanh toán** → **Đối chiếu sổ chi tiết AP và GL**

Đưa “đề nghị thanh toán” vào mô tả bước hoặc nhãn trên giao diện nếu có; không đưa vào số lượng chứng từ của DT.

#### Nội dung về cấn trừ

Giữ cấn trừ như một quy trình riêng vì DT có chứng từ `CanTruCongNoNoiBo`. Ghi điều kiện thực tế: mã nguồn hiện giới hạn xử lý theo VND và khớp cặp công nợ theo đối tác/pháp nhân như điều kiện của chứng từ. Chỉ dùng kịch bản VinSmart–VinFast nếu dữ liệu mở trên đúng DT thỏa các khóa đó và số dư AR/AP thực sự còn mở. Nếu không thỏa, không nói rằng cấn trừ giữa hai pháp nhân này đã được demo thành công.

#### Nội dung về ngoại tệ

DT có xử lý tỷ giá/chênh lệch trong một số giao dịch, nhưng chưa thấy chứng từ/quy trình độc lập “đánh giá lại ngoại tệ cuối kỳ”. Đổi nội dung này thành “ghi nhận chênh lệch tỷ giá theo giao dịch hỗ trợ” hoặc bỏ khỏi sơ đồ kỳ này; không trình bày đánh giá lại cuối kỳ như chức năng đã hoàn thiện.

#### Phân biệt báo cáo với dashboard

Gọi `BanLamViecWebERP` là dashboard/bàn làm việc điều hành. Với báo cáo tuổi nợ, ma trận cấn trừ hoặc sổ cái, chỉ ghi là báo cáo đã chạy nếu có màn hình/báo cáo thực tế trong bản demo và đã xác định nguồn dữ liệu. DT không có Report object trong metadata.

### Slide 12 — Kiểm soát và phê duyệt

**Đánh giá:** Maker–Checker và kiểm tra số tiền/cân đối có hỗ trợ trong mã nguồn. Chuỗi “Tech Lead → PM → IT Director → CFO → Kế toán AP” chưa được chứng minh là luồng phê duyệt bắt buộc được phân quyền đầy đủ.

**Thay sơ đồ phê duyệt bằng:**

> Người lập AP → Kế toán trưởng duyệt  
> Khoản vượt ngưỡng 500 triệu đồng → thêm bước CFO duyệt  
> Sau phê duyệt → ghi sổ theo quyền người dùng

Theo mã nguồn đã rà soát, khoản đến 500 triệu đồng có thể được Kế toán trưởng duyệt/ghi sổ; khoản trên 500 triệu cần CFO cùng Kế toán trưởng. Xác nhận lại ngưỡng và vai trò trong đúng bộ dữ liệu/người dùng demo trước khi chiếu.

Các trạng thái kỹ thuật cho Tech Lead, PM hoặc IT Director trong enum không tự chứng minh rằng có vai trò, phân quyền và kiểm tra chuyển trạng thái cho từng chức danh. Nếu nhóm muốn giới thiệu chuỗi này, cần bổ sung và kiểm thử các bước phê duyệt thật trong cấu hình đang demo.

Có thể giữ nội dung USD/FCT nếu trình bày như khả năng được hỗ trợ theo giao dịch. Không gắn nó với “đánh giá lại ngoại tệ cuối kỳ” nếu chưa có quy trình tương ứng.

### Slide 13 — Bút toán và điểm kiểm soát

**Đánh giá:** Khung Nợ/Có phù hợp, nhưng phải thể hiện đúng tài khoản chi tiết và tránh gộp các chứng từ có bút toán khác nhau.

**Bảng gợi ý để đưa lên slide** (các tài khoản cuối cùng cần đối chiếu với bút toán của chứng từ đang demo):

| Nghiệp vụ | Bút toán cần trình bày/đối chiếu | Điểm cần nói rõ |
|---|---|---|
| Ghi nhận nghiệm thu/doanh thu | Nợ 131x / Có 5113; thuế đầu ra 33311 nếu chứng từ này thực sự ghi thuế | Xác định chứng từ nào tạo doanh thu, AR và VAT; không ghi lặp ở chứng từ sau |
| Hóa đơn GTGT đầu ra | Đối chiếu tài khoản AR chi tiết và 33311 theo logic hiện tại | Không khẳng định hóa đơn ghi lại doanh thu nếu doanh thu đã được ghi ở biên bản nghiệm thu |
| Khách hàng thanh toán | Nợ 1121 hoặc tài khoản tiền phù hợp / Có 131x | Mở sổ AR khách hàng và sổ tiền sau ghi sổ |
| Hóa đơn nhà cung cấp | Nợ chi phí phù hợp, ví dụ 627; Nợ 1331 nếu được khấu trừ / Có 331x | Thuế nhà thầu/FCT có thể liên quan 33318/3338 tùy tình huống |
| Thanh toán nhà cung cấp | Nợ 331x / Có 1121 hoặc 1122; chi phí ngân hàng có thể vào 6427 | Đối chiếu công nợ và tiền; chênh lệch tỷ giá nếu có phải lấy từ chứng từ thực tế |
| Cấn trừ công nợ | Nợ 331x / Có 131x | Không có dòng tiền ngân hàng; chỉ trình bày nếu điều kiện của chứng từ được thỏa |
| Đối soát kênh thanh toán | Tổng tiền thực nhận, phí và khoản chờ đối soát; mã nguồn dùng các tài khoản 1121, 6427, 1388 theo luồng | Không làm giảm AR trực tiếp theo logic hiện tại; giải thích tiền gộp = tiền ròng + phí |

`x` biểu thị tài khoản chi tiết theo đối tác/loại đối tác. DT có các nhánh như 1311/1312 và 3311/3312/3313; phải lấy đúng tài khoản từ dòng bút toán được tạo trong bản demo.

**Cách trình bày an toàn:** Đưa bút toán thật của một chứng từ lên slide, chụp từ kết quả sau ghi sổ. Ghi “minh họa theo dữ liệu demo” và không gọi mọi nhánh tài khoản là chuẩn áp dụng cho mọi công ty. Việc khẳng định tuân thủ VAS cần người phụ trách kế toán xác nhận chính sách hạch toán, thuế và tài khoản.

**Điểm kiểm soát:** Sau mỗi lần ghi sổ, tổng Nợ bằng tổng Có của chứng từ; số phát sinh/số dư trên sổ chi tiết phải giải thích được từ dòng bút toán tương ứng. Chỉ nói “không lệch 1 đồng” khi màn hình/đối chiếu của đúng bản demo chứng minh điều đó.

### Slide 14 — Kiến trúc và kiểm thử

**Đánh giá:** Các số Catalogs (9), Documents (7), Common Modules (12), Roles (5) trên sơ đồ khớp kiểm kê DT. Cần đồng bộ thêm 6 phân hệ, 3 accumulation registers và 1 accounting register nếu slide thể hiện các nhóm này. Câu “merge & verify (51 E2E tests)” chưa thể suy ra từ DT.

**Cách sửa:**

1. Giữ đúng các số lượng đã kiểm tra trong DT.
2. Gắn nhãn “cấu hình DT” cho sơ đồ đối tượng 1C.
3. Đổi “51 E2E tests” thành “Kết quả E2E: [số test] — [commit/phiên bản DT] — [ngày chạy]” sau khi có báo cáo chạy đúng phiên bản; nếu chưa có, bỏ con số.
4. Nếu sơ đồ thể hiện quy trình nhóm phát triển, ghi rõ đó là quy trình xây dựng/kiểm thử, không phải sơ đồ luồng nghiệp vụ của hệ thống.

Nguồn E2E trong workspace đã được rà soát có một số module khác với module đóng trong DT. Vì vậy, kết quả test từ source khác không đủ làm bằng chứng cho đúng DT này. Không thay “51” bằng “90” hoặc một số khác nếu chưa xác định cùng source/DT và cùng lần chạy.

### Slide 15 — Kịch bản demo

**Đánh giá:** Slide hiện giới thiệu demo ở mức khái niệm, chưa thể hiện từng bước của hai luồng AR/AP và chưa cho người xem thấy sổ chi tiết sau từng lần ghi sổ.

**Thay bằng agenda ngắn:**

> 1. Phải thu: nghiệm thu → hóa đơn → thu tiền → đối chiếu AR/GL  
> 2. Phải trả: hóa đơn nhà cung cấp → duyệt → ủy nhiệm chi → đối chiếu AP/GL  
> Sau mỗi lần ghi sổ: mở sổ chi tiết tài khoản liên quan và truy ngược về chứng từ.

Có thể dành phần cuối cho đối soát kênh thanh toán hoặc cấn trừ như điểm nhấn bổ sung, nếu dữ liệu demo có chứng từ hợp lệ.

---

## 4. Kịch bản demo chi tiết

### Kịch bản A — Phải thu khách hàng (AR)

**Mục tiêu:** Chứng minh một khoản phải thu đi từ chứng từ nguồn đến sổ chi tiết AR và GL, sau đó giảm đúng khi nhận tiền.

| Thứ tự | Thao tác trình diễn | Điều cần giải thích | Mở để đối chiếu ngay sau bước |
|---:|---|---|---|
| 1 | Chọn khách hàng và chứng từ nghiệm thu giai đoạn đang có trong DT | Dịch vụ/giai đoạn nào được nghiệm thu, số tiền và thuế lấy từ đâu | Kiểm tra trạng thái chứng từ, dòng dịch vụ, đối tác, tiền tệ và thuế |
| 2 | Ghi sổ nghiệm thu, nếu quy trình demo hiện tại dùng chứng từ này để hạch toán | Giải thích thao tác `Ghi sổ` gọi kiểm tra nghiệp vụ rồi phát sinh số liệu | Mở sổ chi tiết AR theo khách hàng; mở dòng bút toán GL của chứng từ; so tài khoản 131x với số phát sinh |
| 3 | Mở/lập hóa đơn đầu ra theo luồng thực tế của DT và ghi sổ nếu còn bước này | Hóa đơn thể hiện nghĩa vụ thuế/chứng từ bán hàng theo cấu hình; không mô tả doanh thu bị ghi hai lần | Mở lại sổ AR, chi tiết 33311 và GL; kiểm tra hóa đơn liên kết chứng từ trước nếu có |
| 4 | Lập phiếu thu tiền khách hàng và ghi sổ | Tiền thu được phân bổ cho khoản phải thu nào | Mở sổ chi tiết AR: số dư phải giảm; mở sổ tiền và GL: đối chiếu dòng Nợ/Có |
| 5 | Hiển thị kết quả cuối | Nối từ chứng từ đến số dư và bút toán | Đưa số dư trước/sau và trạng thái chứng từ; xác nhận tổng Nợ = tổng Có |

**Lời thoại mẫu:** “Tôi bắt đầu từ chứng từ nghiệm thu có thật trong dữ liệu demo. Sau khi ghi sổ, ta kiểm tra ngay phát sinh ở sổ chi tiết AR của đúng khách hàng và dòng GL được tạo. Khi ghi nhận tiền thu, số phải thu giảm theo đúng khoản được phân bổ. Đây là liên kết giữa chứng từ, sổ công nợ và sổ kế toán.”

**Lưu ý:** Nếu trong bản DT đang chạy chỉ một trong hai chứng từ nghiệm thu/hóa đơn tạo AR hoặc doanh thu, hãy trình diễn theo đúng thứ tự đó. Không dùng lời thoại “doanh thu tức thì” cho chứng từ chỉ ghi hóa đơn/thuế.

### Kịch bản B — Phải trả nhà cung cấp (AP)

**Mục tiêu:** Chứng minh công nợ nhà cung cấp hình thành khi ghi nhận hóa đơn, được duyệt theo luồng đang thi hành, và giảm khi thanh toán.

| Thứ tự | Thao tác trình diễn | Điều cần giải thích | Mở để đối chiếu ngay sau bước |
|---:|---|---|---|
| 1 | Chọn nhà cung cấp và hóa đơn nhà cung cấp trong dữ liệu demo | Hàng hóa/dịch vụ, thuế, tiền tệ, điều khoản thanh toán | Kiểm tra nhà cung cấp, dòng chi phí, thuế và tổng tiền |
| 2 | Ghi sổ hóa đơn theo quy trình hiện tại | Giải thích kiểm tra chứng từ, tài khoản công nợ và chi phí/thuế | Mở sổ chi tiết AP theo nhà cung cấp; mở GL; đối chiếu 331x và tài khoản chi phí/thuế |
| 3 | Trình duyệt theo hạn mức của dữ liệu demo | Nêu đúng các vai trò được kiểm tra trong mã nguồn; nếu trên 500 triệu đồng, trình diễn CFO khi dữ liệu phù hợp | Mở lịch sử/trạng thái phê duyệt hoặc màn hình phê duyệt thực tế |
| 4 | Lập và ghi sổ ủy nhiệm chi | Chọn khoản AP cần thanh toán và tài khoản tiền phù hợp | Mở sổ AP: số dư giảm; mở sổ tiền và GL: đối chiếu khoản thanh toán, phí hoặc chênh lệch nếu có |
| 5 | Hiển thị kết quả cuối | Chứng minh khoản phải trả còn lại hoặc đã tất toán | Đối chiếu sổ chi tiết AP với các chứng từ đã ghi sổ và tổng Nợ = tổng Có |

**Lời thoại mẫu:** “Hóa đơn nhà cung cấp tạo khoản phải trả. Tôi mở sổ chi tiết AP ngay sau ghi sổ để xác nhận số dư theo đúng nhà cung cấp. Sau khi qua bước duyệt đang có trong hệ thống, ủy nhiệm chi làm giảm công nợ; sổ AP, sổ tiền và GL phải cùng giải thích được số dư cuối.”

**Lưu ý:** Không thêm “Đề nghị thanh toán” thành một chứng từ riêng khi không có object tương ứng. Không trình diễn chuỗi chức danh chưa được cấu hình/phân quyền thật.

### Điểm nhấn tùy chọn — Bảng kê đối soát kênh thanh toán

Giải thích bảng kê này dùng để đối chiếu **tiền gộp, tiền ròng và phí kênh**. Sau khi được chấp nhận/ghi sổ, dữ liệu tập kết vào sổ tiền và GL theo logic hiện tại; không làm giảm AR trực tiếp. Dùng công thức minh họa:

> Tiền gộp = Tiền thực nhận + Phí kênh

Sau ghi sổ, mở sổ tiền và GL để chỉ ra các tài khoản liên quan (trong mã nguồn có 1121, 6427, 1388). Chỉ dùng số tiền của chứng từ đang có trong đúng DT; không lấy số liệu từ bộ test khác.

### Điểm nhấn tùy chọn — Cấn trừ công nợ nội bộ

Mô tả cấn trừ là bù trừ AR với AP theo chứng từ `CanTruCongNoNoiBo`, không phải chuyển tiền ngân hàng. Trước khi demo, kiểm tra đối tác, pháp nhân, tiền tệ, khoản AR/AP còn mở và hạn chế VND trong mã nguồn. Sau ghi sổ phải mở cả sổ chi tiết AR, AP và GL để chứng minh hai bên giảm đúng số tiền. Nếu dữ liệu không thỏa điều kiện, bỏ demo này; không dùng số dư giả định.

---

## 5. Cách giải thích việc ghi sổ và các phần mã

Trình bày `Ghi sổ (Post)` theo chuỗi sau:

1. **Nhận chứng từ:** người dùng chọn một chứng từ đã nhập.
2. **Kiểm tra điều kiện:** trạng thái, đối tác, số tiền, tiền tệ, tài khoản và quyền/phê duyệt.
3. **Tạo phát sinh:** procedure ghi sổ đọc các dòng chứng từ và tạo dòng vào sổ AR, AP, tiền và/hoặc GL tùy loại nghiệp vụ.
4. **Lưu kết quả:** chứng từ chuyển trạng thái đã ghi sổ; dòng phát sinh liên kết được về chứng từ nguồn.
5. **Đối chiếu:** người dùng mở sổ chi tiết và GL để kiểm tra kết quả.

Khi giải thích mã, tập trung vào ba câu hỏi thay vì đọc code:

- **Procedure nào đang chạy?** Nêu tên procedure/handler của thao tác đang xem và chứng từ gọi nó.
- **Nó kiểm tra điều gì?** Chỉ ra điều kiện có thể làm từ chối ghi sổ hoặc yêu cầu phê duyệt.
- **Nó ghi dữ liệu đi đâu?** Nối chứng từ với sổ AR/AP/tiền và GL tương ứng.

Một bảng kê đối soát kênh thanh toán là ví dụ dễ hiểu: bảng kê nhận số tiền thanh toán gộp, phí và tiền ròng; procedure kiểm tra các giá trị; khi ghi sổ, phát sinh vào dòng tiền/GL theo cấu hình. Vì vậy cần mở sổ tiền và GL sau ghi sổ, còn sổ AR không tự giảm theo luồng đối soát này.

Tên module hoặc procedure nên lấy trực tiếp từ đúng source của DT đang trình diễn. Có thể dùng `BanLamViecWebERP` để giới thiệu dashboard và biểu mẫu làm việc; không suy diễn dashboard là nơi lưu các phát sinh kế toán. Phát sinh được lưu ở các sổ đăng ký tương ứng.

---

## 6. Checklist trước khi xuất bản slide

- [ ] Slide 7 và 14 dùng cùng một bộ số liệu: 6 phân hệ, 7 chứng từ, 9 danh mục, 5 vai trò, 3 sổ tích lũy, 1 sổ kế toán.
- [ ] Không ghi có 4 report object; gọi đúng `BanLamViecWebERP` là DataProcessor/dashboard.
- [ ] “Đề nghị thanh toán” được ghi là bước nghiệp vụ nếu không có chứng từ riêng.
- [ ] Slide 11 nêu rõ chứng từ nào tạo doanh thu, thuế và AR; không ghi nhận trùng.
- [ ] Tranh chấp không được mô tả thành quy trình điều chỉnh nếu chưa có chứng từ/module hỗ trợ trong phiên bản demo.
- [ ] Cấn trừ được giới hạn theo dữ liệu và tiền tệ mà mã nguồn thực thi; đã xác nhận đúng pháp nhân/đối tác và số dư mở.
- [ ] Không quảng bá đánh giá lại ngoại tệ cuối kỳ như quy trình hoàn chỉnh nếu chưa có object/luồng tương ứng.
- [ ] Chuỗi phê duyệt khớp quyền và hạn mức thực sự đang chạy; vai trò trong enum không bị nhầm với role được phân quyền.
- [ ] Bút toán trên slide lấy từ chứng từ đã ghi sổ trong đúng bản DT; tổng Nợ bằng tổng Có.
- [ ] Sau từng lần ghi sổ trong demo, đã chuẩn bị sẵn bước mở sổ AR/AP/tiền và GL chi tiết.
- [ ] Mỗi ảnh chụp màn hình có thể truy ngược từ sổ về chứng từ nguồn.
- [ ] Tuyên bố số lượng E2E có commit/phiên bản DT, lệnh hoặc báo cáo chạy và ngày chạy tương ứng; nếu thiếu thì bỏ số.
- [ ] Tên công ty, số tiền và số liệu trong lời thoại khớp dữ liệu thực tế trên màn hình demo.
- [ ] Các tuyên bố về VAS/thuế/chính sách hạch toán đã được người phụ trách kế toán xác nhận.

## 7. Giới hạn của kết luận

Đối chiếu này mô tả cấu hình và mã nguồn của DT đã kiểm tra. Nó không xác nhận rằng mọi dữ liệu danh mục, quyền người dùng, màn hình đã triển khai, hoặc số dư mẫu đều giống nhau giữa các bản DT. Mã nguồn E2E trong workspace có chỗ khác với module trong DT; cần chạy lại hoặc truy xuất bằng chứng kiểm thử theo đúng phiên bản trước khi ghi kết quả kiểm thử vào slide. Tài liệu này không thay cho xác nhận chính sách kế toán/thuế của doanh nghiệp.
