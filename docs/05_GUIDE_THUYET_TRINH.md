# 05 — GUIDE CHO NGƯỜI THUYẾT TRÌNH

> Viết cho người **không viết code** vẫn demo được. Đọc từ trên xuống, làm đúng thứ tự.
> Thời lượng gợi ý: 15-20 phút demo + 10 phút hỏi đáp.
> Lời nói gợi ý đặt trong khung *"…"* — đọc gần nguyên văn cũng được.

---

## 1. Dự án làm gì (nói trong 3 câu)

> *"Nhóm em xây dựng trên 1C:Enterprise một hệ thống quản lý **công nợ phải thu và phải trả** cho công ty công nghệ giả định VinSmart Future thuộc tập đoàn Vingroup.*
> *Mỗi nghiệp vụ — nghiệm thu, xuất hóa đơn, thu tiền, trả tiền nhà cung cấp, cấn trừ nội bộ — được nhập bằng một chứng từ; khi ghi sổ, hệ thống tự cập nhật **sổ công nợ, sổ tiền và sổ cái kế toán** theo bút toán Nợ/Có.*
> *Hệ thống có kiểm soát **người lập khác người duyệt**, chặn thu/chi vượt số dư, tính **thuế nhà thầu nước ngoài**, xử lý **ngoại tệ USD**, và có **Dashboard cho Giám đốc tài chính**."*

### Từ khóa cần hiểu trước khi lên (1 câu mỗi từ)

| Từ | Nghĩa dễ hiểu |
|---|---|
| Chứng từ (Document) | Một "phiếu" nghiệp vụ, VD Phiếu thu, Ủy nhiệm chi. |
| Ghi sổ (Post) | Bấm để chứng từ chính thức ghi số liệu vào sổ. |
| Sổ công nợ phải thu / phải trả | Sổ cho biết khách còn nợ mình bao nhiêu / mình còn nợ nhà cung cấp bao nhiêu. |
| Sổ cái (`SoCaiKeToan`) | Sổ kế toán ghi bút toán Nợ TK… / Có TK…. |
| Maker-Checker | Người lập chứng từ không được tự duyệt chứng từ của mình. |
| Cấn trừ (Netting) | Hai công ty vừa nợ nhau vừa bị nợ, bù trừ cho nhau, chỉ trả phần chênh. |
| FCT (thuế nhà thầu) | Khi trả tiền cho công ty nước ngoài (AWS), mình phải giữ lại 5% VAT + 5% thuế TNDN nộp thay. |
| Tuổi nợ | Khoản nợ đã quá hạn bao nhiêu ngày. |
| DSO / DPO | Số ngày bình quân thu được tiền / số ngày bình quân trả tiền. |
| Register records | Màn hình xem chứng từ đã ghi những dòng gì vào sổ — **công cụ quan trọng nhất khi demo**. |

---

## 2. Chuẩn bị trước khi demo

### 2.1. Một ngày trước

- [ ] Máy demo cài **1C:Enterprise 8.3** (bản 8.3.22 trở lên; nhóm đang dùng bản Training 8.3.22.1704).
- [ ] Có file `VinSmart_Future_AR_AP_Full.dt` (ở thư mục gốc repo).
- [ ] Nạp `.dt` vào **2 infobase**: `VSF_DEMO` (để demo) và `VSF_DUPHONG` (dự phòng nếu làm hỏng dữ liệu). Cách nạp:
  1. Mở 1C → **Add** → *Create an infobase without configuration* → đặt tên → chọn thư mục → **Finish**.
  2. Chọn infobase vừa tạo → **Designer** → menu `Administration → Restore infobase...` → chọn file `.dt` → **Yes**.
  3. Chờ báo *"Infobase successfully restored"* → đóng Designer.
  4. ⚠️ **Không dùng `scripts/import_dt.ps1`**: script này ghi đè cứng vào thư mục `C:\Users\Dung\...\Infobase` (bug B66).
- [ ] **Thử đăng nhập tất cả tài khoản sẽ dùng** và ghi lại mật khẩu đúng:

| Tài khoản | Vai trò | Mật khẩu theo tài liệu |
|---|---|---|
| `Admin` | Quản trị hệ thống | (trống) |
| `ketoan_ar` | Kế toán phải thu | `123` |
| `ketoan_ap` | Kế toán phải trả | `123` |
| `ketoan_truong` | Kế toán trưởng (người duyệt) | `123` |
| `cfo_giamdoc` | Giám đốc tài chính | `123` |
| `chuyenvien_doisoat` | Chuyên viên đối soát | `123` |
| `pm_duan`, `techlead_kythuat`, `it_director` | Các cấp duyệt kỹ thuật | `123` |

  > ⚠️ **Cần xác nhận:** trong code có chỗ đặt mật khẩu `Vsf@2026!Secure`. Nếu `123` không vào được, thử mật khẩu này hoặc mật khẩu trống. **Không đọc mật khẩu thành tiếng khi trình bày.**

- [ ] Chạy thử toàn bộ mục 3 một lần trên `VSF_DEMO`, sau đó **nạp lại `.dt`** để dữ liệu sạch.
- [ ] Ghi sẵn ra giấy các số dư "TRƯỚC" ở mục 3.2 (mentor có thể hỏi so sánh trước/sau).
- [ ] Chuẩn bị slide: hồ sơ doanh nghiệp, sơ đồ luồng chứng từ, ma trận posting (bảng chứng từ → sổ, có thể lấy từ `docs/01_HIEN_TRANG.md` mục 5), danh sách bug đã biết (`docs/02_BUG.md` phần tổng hợp).

### 2.2. 15 phút trước giờ demo

- [ ] Tắt thông báo, sạc pin, độ phân giải màn hình chiếu ≥ 1366×768, phóng to chữ (Ctrl + lăn chuột trong 1C nếu cần).
- [ ] Mở sẵn 1C ở màn hình chọn infobase, chọn `VSF_DEMO`.
- [ ] Mở sẵn file này và `04_KICH_BAN_TEST.md` trên máy khác/điện thoại để nhìn.
- [ ] Giao diện có thể hiện **tiếng Anh** (cấu hình chỉ khai báo ngôn ngữ English — Cần xác nhận). Nếu vậy, chuẩn bị nói tên menu bằng tiếng Việt theo bảng ở mục 3.1.

---

## 3. Kịch bản demo từng bước

> **Nếu demo bản đã sửa lỗi (nhánh `fix/claude-review-dot1-2`, xem `06_LOG_SUA_LOI.md`)** — chỉ áp dụng sau khi nhóm đã nạp code mới và dump lại `.dt`:
> - Ô *Người tạo / Người lập* **tự điền** theo người đăng nhập → bỏ qua bước gõ tên người lập.
> - *Phiếu thu* có thêm ô **Người duyệt** → chọn `ketoan_truong`, rồi đăng nhập `ketoan_truong` để ghi sổ.
> - *Ủy nhiệm chi* phải qua *Đã gửi ngân hàng* trước khi *Đã ghi sổ*; *Hóa đơn GTGT* phải *Chờ ký số → Đã phát hành* trước khi ghi sổ.
> - Có thể demo thêm: đăng nhập `Admin` bấm Ghi sổ một chứng từ → bị chặn (*"Tài khoản quản trị không được ghi sổ chứng từ tài chính"*); đăng nhập `pm_duan` bấm Hủy ghi sổ → bị chặn (*"Chỉ Kế toán trưởng hoặc CFO…"*).

### 3.1. Mở hệ thống và giới thiệu giao diện (2 phút)

1. Chọn `VSF_DEMO` → **1C:Enterprise** → đăng nhập `Admin`.
2. Dashboard CFO tự mở. Chỉ vào bên trái: 6 phân hệ.

> *"Đây là màn hình chính. Bên trái là 6 phân hệ theo đúng quy trình kế toán: (1) Phải thu, (2) Phải trả, (3) Ngân hàng và Quỹ, (4) Bù trừ nội bộ, (5) Sổ cái và bàn làm việc CFO, (6) Danh mục nền như đối tác, hợp đồng, tỷ giá."*

3. Mở **6. Danh mục → Đối tác** → chỉ vào Vingroup, VinFast (nội bộ) và AWS (nước ngoài).

> *"Đối tác được phân loại nội bộ tập đoàn hay bên ngoài, vì công nợ nội bộ hạch toán vào tài khoản riêng 1312/3312 và được phép cấn trừ."*

### 3.2. Luồng Phải thu: nghiệm thu → thu tiền (5 phút)

Ghi trước: số dư công nợ phải thu của VinFast (mở `Phải thu → Công nợ phải thu`, lọc VinFast).

**Bước A — Biên bản nghiệm thu**
1. Đăng xuất, đăng nhập `ketoan_ar`.
2. **Phải thu → Biên bản nghiệm thu giai đoạn → Tạo**. Nhập: Pháp nhân VSF; Đối tác VinFast; Hợp đồng của VinFast; Giá trị chưa VAT `100.000.000`; Người tạo `ketoan_ar` (ở chứng từ này ô tên là *Người tạo*, các chứng từ khác là *Người lập*); Người duyệt `ketoan_truong`; Trạng thái *Chờ duyệt nội bộ* → **Lưu**.

> *"Kế toán phải thu lập biên bản nghiệm thu. Lúc này mới là bản nháp, chưa ảnh hưởng sổ sách."*

3. **Thử Maker-Checker:** sửa Người duyệt thành `ketoan_ar` (trùng Người tạo) → đổi trạng thái *Đã duyệt nội bộ* → **Ghi sổ** → hệ thống báo lỗi vi phạm Maker-Checker.

> *"Nếu người lập tự duyệt, hệ thống chặn ngay — đây là nguyên tắc 4 mắt trong kiểm soát nội bộ."*

4. Sửa lại Người duyệt = `ketoan_truong`, trạng thái *Chờ duyệt nội bộ* → Lưu. Đăng nhập `ketoan_truong`, mở biên bản → trạng thái *Đã duyệt nội bộ* → **Ghi sổ**.
5. Bấm **More → Document register records**.

> *"Sau khi kế toán trưởng duyệt và ghi sổ, chứng từ sinh ra 2 loại dòng: sổ công nợ phải thu tăng 100 triệu, và sổ cái ghi Nợ 1312 – Có 5113 doanh thu dịch vụ. Hai sổ luôn được ghi cùng lúc trong một giao dịch."*

**Bước B — Phiếu thu, và chặn thu vượt**
6. **Phải thu → Phiếu thu tiền khách hàng → Tạo**: chứng từ gốc = biên bản vừa tạo, cùng đối tác/hợp đồng, TK Techcombank VND, số tiền `150.000.000` → **Ghi sổ** → bị chặn vì vượt số còn nợ.

> *"Khách chỉ nợ 100 triệu mà nhập thu 150 triệu thì hệ thống chặn. Lúc kiểm tra, hệ thống còn **khóa số dư** để hai kế toán không cùng thu một khoản nợ cùng lúc."*

7. Sửa số tiền `60.000.000` → **Ghi sổ** → mở Register records.

> *"Thu 60 triệu: công nợ giảm 60, tiền ngân hàng tăng 60, sổ cái Nợ 1121 – Có 1312. Khách còn nợ 40 triệu."*

8. Mở lại sổ công nợ phải thu (lọc VinFast) → so với số đã ghi trước: tăng 100, giảm 60, chênh +40tr.

### 3.3. Luồng Phải trả: hóa đơn nhà cung cấp nước ngoài (3 phút)

1. Mở hóa đơn mẫu **AP0001** (AWS, USD) trong **Phải trả → Hóa đơn nhà cung cấp** (dùng dữ liệu có sẵn để tiết kiệm thời gian).
2. Chỉ vào các ô: tiền tệ USD, tỷ giá, thuế nhà thầu 5% VAT + 5% TNDN, số thực trả NCC.

> *"AWS là nhà cung cấp nước ngoài nên khi trả tiền, mình giữ lại thuế nhà thầu. Hệ thống tự lấy tỷ giá theo ngày và tự tính thuế."*

3. Mở **Register records**: Nợ 627 / Có 3313, Nợ 627 / Có 3338, Nợ 1331 / Có 33318.

> *"Công nợ phải trả chỉ ghi số tiền thực trả nhà cung cấp; phần thuế ghi vào tài khoản thuế phải nộp."*

4. Mở **Ủy nhiệm chi UNC0001** → chỉ trạng thái và kể quy trình.

> *"Lệnh chi đi qua các bước: Dự thảo → Chờ duyệt → Đã duyệt → Đã gửi ngân hàng → Đã ghi sổ. Chỉ khi ngân hàng xác nhận mới ghi giảm công nợ và giảm tiền; chênh lệch tỷ giá giữa lúc nhận hóa đơn và lúc trả tiền vào tài khoản 515 hoặc 635."*

### 3.4. Cấn trừ nội bộ (2 phút)

1. **Bù trừ & Netting → Cấn trừ công nợ nội bộ** → mở `CT-BILATERAL-01`.

> *"VSF vừa bán phần mềm cho VinFast, vừa thuê mặt bằng lab của VinFast. Thay vì chuyển tiền hai chiều, hai bên cấn trừ 40 triệu: công nợ phải thu và phải trả cùng giảm, sổ cái ghi Nợ 3312 – Có 1312."*

2. Mở Register records để chỉ 2 sổ cùng giảm.
3. Mở `CT-MULTILATERAL-01` (3 bên qua TK trung gian 1388) — chỉ nói, không cần mở chi tiết.

### 3.5. Ngân hàng & kênh thanh toán (1 phút)

1. **Ngân hàng & Quỹ → Bảng kê đối soát kênh thanh toán** → mở `BK-VNPAY-01`.

> *"Khách trả qua VNPAY 75 triệu, cổng giữ phí 1,125 triệu, về tài khoản 73,875 triệu. Hệ thống bắt buộc Tổng = Thực nhận + Phí, phí ghi chi phí 6427."*

### 3.6. Dashboard CFO (2 phút)

1. **Sổ cái & CFO → Bàn làm việc Lãnh đạo CFO** → bấm **Làm mới**.

> *"Dashboard tổng hợp cho Giám đốc tài chính: doanh thu theo khối, công nợ phải thu/phải trả, tiền ngân hàng, số ngày thu tiền DSO và trả tiền DPO."*

> ⚠️ Không khẳng định các con số "tiết kiệm 18,2 tỷ", "35,5%", "Cân đối 100%" là tính từ dữ liệu — đó là số cố định trong code (bug B47). Nếu bị hỏi, xem câu hỏi Q8.

### 3.7. Phân quyền (1-2 phút)

1. Đăng nhập `ketoan_ar` → thử mở **Phải trả → Hóa đơn NCC** → tạo và ghi sổ.

> *"Hệ thống phân tách nhiệm vụ: kế toán phải thu không được ghi sổ chứng từ phải trả."*

> ⚠️ Chạy thử trước ở mục 2.1. Nếu `ketoan_ar` vẫn mở/ghi được (do vai trò chưa khai báo quyền chi tiết — bug B35), **bỏ bước này** và nói ở phần "hạn chế" (mục 3.8).

### 3.8. Kết thúc: nói thẳng hạn chế và kế hoạch (1 phút)

> *"Qua tự rà soát, nhóm đã ghi nhận 75 lỗi, trong đó 34 lỗi mức cao; đã sửa xong nhóm lỗi kiểm soát và lệch sổ (Đợt 1–2, đang chạy kiểm tra trên 1C). Các lỗi tập trung ở 3 nhóm: (1) kiểm soát — trước đây người lập gõ tay nên vượt được Maker-Checker, quy trình duyệt nhiều cấp chưa được nối vào (đã sửa); (2) sổ chi tiết lệch sổ cái khi sửa chứng từ (đã sửa); (3) báo cáo chưa dùng DCS, chưa có mẫu in và form chứng từ riêng, phân quyền chi tiết theo vai trò (đang làm ở các đợt sau). Mỗi lỗi đều có kịch bản test để chứng minh trước/sau khi sửa."*

---

## 4. Lỗi hay gặp khi demo và cách xử lý

| Tình huống | Nguyên nhân thường gặp | Cách xử lý ngay |
|---|---|---|
| Không đăng nhập được user nghiệp vụ | Mật khẩu khác tài liệu | Thử `123` → `Vsf@2026!Secure` → trống. Vẫn không được: dùng `Admin` và **nói** vai trò thay vì đăng nhập. |
| Báo lỗi "Vi phạm Maker-Checker" ngoài ý muốn | Người lập = người duyệt, hoặc người đang đăng nhập ≠ người duyệt | Kiểm 2 ô Người lập/Người duyệt; đăng nhập đúng tài khoản ghi ở ô Người duyệt. |
| Báo "Quy trình phê duyệt không hợp lệ… phải ở trạng thái Đã duyệt" | Đổi thẳng từ Dự thảo/Chờ duyệt sang Đã ghi sổ | Lưu ở trạng thái Đã duyệt trước, sau đó mới đổi/ghi sổ. |
| Phiếu thu bị chặn "số dư không đủ" khi không muốn | Biên bản đã được thu hết ở lần chạy thử trước | Dùng biên bản mới tạo ở 3.2, hoặc giảm số tiền. Nạp lại `.dt` trước buổi demo. |
| Ghi sổ báo thiếu Pháp nhân/Đối tác/Hợp đồng | Chưa chọn đủ | Chọn đủ 3 ô; hợp đồng phải thuộc đúng đối tác. |
| Mở báo cáo chỉ thấy tiêu đề và 1 dòng tổng, hoặc không có nút Tạo | Báo cáo chưa có DCS/form (bug B42) | **Không demo báo cáo**; nếu bị yêu cầu, nói đây là hạn chế đã ghi nhận và chỉ Dashboard thay thế. |
| Bấm "Nạp số dư đầu kỳ", "Động cơ đối soát", "Lập ma trận cấn trừ" không thấy gì | 3 xử lý này chưa có form (B41, B51, B59) | Không bấm khi demo. |
| Không tìm thấy "Đánh giá lại ngoại tệ" trong menu | Chưa đưa vào phân hệ (B59) | Mở qua menu chính → **All functions (Tất cả chức năng)** → Documents. |
| Dashboard không có số liệu tháng 10/2026 | Ngày chốt đang cố định 30/09/2026 (B45) | Nói: "Dashboard đang chốt số liệu đến hết quý 3/2026." |
| Ghi sai dữ liệu, sổ bị lệch giữa buổi | Thao tác nhầm | Chuyển sang infobase `VSF_DUPHONG`. |
| 1C treo / báo "Infobase connections limitation" | Bản Training giới hạn số phiên | Đóng hết cửa sổ 1C khác (kể cả Designer), mở lại. |

---

## 5. Câu hỏi mentor có thể hỏi và gợi ý trả lời

**Q1. Vì sao công nợ dùng Accumulation Register loại số dư (Balance) mà không tính từ chứng từ?**
> Câu hỏi quản lý là "khách còn nợ bao nhiêu tại một thời điểm" → cần **số dư**, nên dùng sổ tích lũy kiểu Balance. Đọc số dư từ sổ nhanh và đúng hơn cộng lại hàng nghìn chứng từ; chiều phân tích Pháp nhân – Đối tác – Hợp đồng – Chứng từ gốc cho phép biết còn nợ theo từng hóa đơn để tính tuổi nợ.

**Q2. Vì sao vừa có sổ công nợ vừa có sổ cái? Có bị trùng không?**
> Hai sổ trả lời hai câu hỏi khác nhau: sổ công nợ trả lời "nợ theo từng khách/hợp đồng/hóa đơn" cho nghiệp vụ; sổ cái trả lời "số dư tài khoản 131, 331" cho báo cáo tài chính. Cả hai được ghi trong **cùng một lần ghi sổ**, nên phải khớp nhau. Nhóm đã phát hiện vài trường hợp chưa khớp khi sửa chứng từ (B02, B05, B17) và đã có kế hoạch kiểm tra khớp ngay trong lúc ghi sổ.

**Q3. Nếu hai kế toán cùng thu tiền một khoản nợ cùng lúc thì sao?**
> Phiếu thu, báo có, ủy nhiệm chi, cấn trừ dùng **khóa dữ liệu (DataLock)** chế độ Managed: khóa số dư của đúng đối tác/hợp đồng/chứng từ gốc, đọc số dư, rồi mới ghi. Người thứ hai phải chờ và sẽ thấy số dư đã giảm. Test hai phiên thật chưa chạy được vì bản Training giới hạn kết nối — nhóm mới chạy kiểm tra tuần tự.

**Q4. Maker-Checker hoạt động thế nào? Có lách được không?**
> Hệ thống so người lập, người duyệt và người đang đăng nhập; trùng thì chặn. **Thật lòng:** hiện ô Người lập đang được gõ tay nên vẫn lách được bằng cách gõ tên người khác (B28). Cách sửa: server tự gán người lập là người đăng nhập khi tạo chứng từ và khóa không cho sửa.

**Q5. Ai trong doanh nghiệp được quyền vượt kiểm soát?**
> Theo thiết kế: không ai được tự duyệt; Quản trị hệ thống không được ký duyệt chứng từ tài chính; Kế toán trưởng là người duyệt ghi sổ; hóa đơn vượt ngân sách cần thêm CFO. Hiện code chặn Admin theo **tên** chứ chưa theo **vai trò** (B32) — đã đưa vào kế hoạch sửa.

**Q6. Vì sao hủy hóa đơn thì không xóa mà đổi trạng thái?**
> Hóa đơn điện tử đã phát hành là chứng từ pháp lý, không được xóa; chỉ được hủy/điều chỉnh/thay thế. Khi trạng thái là Đã hủy, hóa đơn không được còn bút toán. Nhóm phát hiện lỗi khi ghi sổ lại sau hủy còn sót bút toán cũ (B01) — cách sửa đơn giản là đánh dấu ghi sổ đè trước khi thoát.

**Q7. Vì sao báo cáo không dùng DCS (Data Composition System)?**
> Nhóm viết logic tính toán trong module dùng chung để dùng lại cho cả Dashboard. Hạn chế là người dùng không tự lọc/nhóm được và hiện báo cáo chỉ in dòng tổng. Theo Bài 18 và góp ý mentor, nhóm sẽ chuyển ít nhất báo cáo tuổi nợ và sổ chi tiết công nợ sang DCS đọc bảng ảo `Balance`/`BalanceAndTurnovers` có tham số kỳ.

**Q8. Các số trên Dashboard có đúng không?**
> Doanh thu, công nợ, tiền được đọc từ sổ. Một số chỉ tiêu và nhãn (tiết kiệm, "cân đối 100%", ngày chốt 30/09/2026) đang là giá trị cố định để trình diễn — nhóm đã ghi vào danh sách lỗi (B45, B47) và sẽ tính từ dữ liệu thật.

**Q9. Phân quyền theo vai trò khai báo ở đâu? Có ma trận quyền không?**
> Có 9 vai trò. Phần kiểm tra phân tách nhiệm vụ đang viết bằng code (module `PhanQuyenBaoMatServer`). Quyền chi tiết theo đối tượng trong Designer chưa khai báo (B35) — nhóm sẽ lập ma trận vai trò × đối tượng theo Bài 20 và khai báo lại.

**Q10. Tỷ giá lấy ở đâu? Chênh lệch tỷ giá xử lý thế nào?**
> Bảng `TyGiaHoiDoai` lưu tỷ giá theo ngày; chứng từ lấy tỷ giá gần nhất ≤ ngày chứng từ. Khi chi tiền, giá trị VND ghi giảm công nợ theo tỷ giá ghi sổ, chênh với tỷ giá thực chi vào 515 (lãi) hoặc 635 (lỗ). Cuối kỳ chứng từ Đánh giá lại ngoại tệ điều chỉnh số dư USD qua 4131 rồi kết chuyển. Lỗi đã biết: cấn trừ USD đang gọi nhầm tên hàm tỷ giá nên tỷ giá = 1 (B23); đánh giá lại AR chưa cập nhật sổ chi tiết (B24).

**Q11. Thuế nhà thầu tính thế nào? Có xử lý trường hợp gross-up không?**
> Hiện tính theo phương pháp khấu trừ: 5% VAT + 5% TNDN trừ vào số trả NCC. Chưa xử lý hợp đồng gross-up và miễn thuế theo hiệp định (B27) — cần chốt nghiệp vụ trước khi làm.

**Q12. Chứng từ nào không ghi sổ? Vì sao?**
> Đề nghị thanh toán dịch vụ chỉ là bước kiểm soát nội bộ, không làm thay đổi công nợ hay tiền nên không ghi sổ nào. (Mentor có thể góp ý nên tắt Posting cho chứng từ này — đã ghi B63.)

**Q13. Phần nào ngoài phạm vi?**
> Webhook ngân hàng, đồng bộ SAP, ký số hóa đơn điện tử với CQT, chứng từ bán lẻ B2C — **chưa có trong cấu hình** (một số tài liệu cũ ghi "DONE" là sai, đã ghi B64). Nhóm sẽ cập nhật bảng phạm vi.

**Q14. Làm sao biết hệ thống đúng? Đã test gì?**
> Có `04_KICH_BAN_TEST.md` với 94 ca test thủ công (chức năng, bảo mật, số liệu, ngoại tệ, báo cáo, kỹ thuật); mỗi bug có ít nhất 1 ca để chứng minh trước/sau khi sửa. Autotest sẽ được bổ sung sau. Ngoài ra README ghi một số ca runtime đã chạy trên bản clone (phân quyền 6 người dùng, vòng đời ghi sổ, an toàn sinh dữ liệu).

**Q15. Nếu được làm lại, nhóm sẽ thay đổi gì?**
> Gán người lập tự động thay vì nhập tay; dùng tài khoản định sẵn (predefined) thay vì tìm theo mã; làm form chứng từ và "Tạo dựa trên" để giảm nhập tay; dựng báo cáo bằng DCS ngay từ đầu; tách code test ra khỏi cấu hình nộp.

---

## 6. Checklist 1 trang (in ra mang theo)

- [ ] 2 infobase đã nạp `.dt` sạch: `VSF_DEMO`, `VSF_DUPHONG`.
- [ ] Đã thử đăng nhập: Admin, ketoan_ar, ketoan_truong, ketoan_ap. Mật khẩu đúng: ……………
- [ ] Đã ghi số dư công nợ VinFast "trước": ……………
- [ ] Thứ tự demo: Giao diện → Biên bản (thử Maker-Checker) → Phiếu thu (thử vượt số dư) → Hóa đơn AWS → UNC → Cấn trừ → Bảng kê VNPAY → Dashboard → (Phân quyền nếu đã thử OK) → Hạn chế & kế hoạch.
- [ ] **Không** bấm: Nạp số dư đầu kỳ, Động cơ đối soát, Lập ma trận cấn trừ, các báo cáo (nếu chưa sửa B42).
- [ ] Mở sẵn `docs/02_BUG.md` phần Tổng hợp để trả lời "đã biết lỗi gì".
