# 04 — KỊCH BẢN TEST THỦ CÔNG

> **Ghi chú:** Autotest sẽ được bổ sung sau (anh Dũng gửi). Kịch bản thủ công này dùng để **đối chiếu** với kết quả autotest và để chạy tay khi demo.
>
> - Cột **Kết quả thực tế** để trống — người test điền khi chạy (ghi "Đạt" / "Không đạt" + mô tả ngắn).
> - Cột **Bug** trỏ tới mã lỗi trong `02_BUG.md`. Với ca kiểm tra bug: **trước khi sửa, ca sẽ "Không đạt"** — đó là bằng chứng bug có thật; sau khi sửa phải "Đạt".
> - Ca không có mã bug là ca chức năng chính (phải đạt ngay trên bản hiện tại).

## 0. Chuẩn bị chung

1. Nạp `VinSmart_Future_AR_AP_Full.dt` vào **một infobase riêng để test** (không dùng bản demo). Cách nạp: `05_GUIDE_THUYET_TRINH.md` mục 2.
2. Tài khoản (theo `HUONG_DAN_SU_DUNG_FILE_DT.md`): `Admin` (mật khẩu trống); `ketoan_ar`, `ketoan_ap`, `chuyenvien_doisoat`, `cfo_giamdoc`, `ketoan_truong`, `pm_duan`, `techlead_kythuat`, `it_director` (mật khẩu `123`). **Cần xác nhận** mật khẩu thật trên `.dt` (code `UserProvisioningServer` đặt mật khẩu khác).
3. Cách xem kết quả ghi sổ của một chứng từ: mở chứng từ → nút **More (Еще)** → **Document register records** (bảng các dòng chứng từ đã ghi vào sổ).
4. Cách xem số dư sổ: mở phân hệ → mục sổ (VD "Công nợ phải thu") hoặc mở sổ cái `SoCaiKeToan` trong phân hệ "5. Sổ cái & CFO".
5. Dữ liệu mẫu có sẵn: biên bản `BB0001-BB0010`, hóa đơn `HD26E0000001-10`, phiếu thu `PT0001-PT0006`, hóa đơn NCC `AP0001-AP0008`, UNC `UNC0001-UNC0005`, bảng kê `BK-VNPAY-01`, `BK-ONEPAY-01`, cấn trừ `CT-BILATERAL-01`, `CT-MULTILATERAL-01`.
6. Ghi lại số dư **trước** khi làm mỗi ca có ghi sổ (cột "Trước") để so sánh "Sau".

---

## 1. Ca chức năng chính

### 1.1. Đăng nhập & giao diện

| ID | Mục tiêu | Các bước | Kết quả mong đợi | Kết quả thực tế |
|---|---|---|---|---|
| TC-UI-00 | Mở được hệ thống | 1. Mở infobase test bằng 1C:Enterprise. 2. Đăng nhập `Admin`. | Vào được giao diện; thanh bên trái có 6 phân hệ: Phải thu, Phải trả, Ngân hàng & Quỹ, Bù trừ & Netting, Sổ cái & CFO, Danh mục. Dashboard CFO tự mở. | |
| TC-UI-05 | Danh mục nền có dữ liệu | Vào "6. Danh mục" → mở lần lượt Pháp nhân, Đối tác, Hợp đồng, Tiền tệ, Tỷ giá. | Mỗi danh mục có dữ liệu mẫu (VD Đối tác có Vingroup, VinFast, FPT, AWS). | |

### 1.2. Phải thu (AR)

| ID | Mục tiêu | Các bước | Kết quả mong đợi | Kết quả thực tế |
|---|---|---|---|---|
| TC-AR-01 | Biên bản nghiệm thu ghi tăng công nợ và doanh thu | 1. Đăng nhập `ketoan_ar`. 2. Phải thu → Biên bản nghiệm thu → Tạo: Pháp nhân VSF, Đối tác VinFast, Hợp đồng bất kỳ của VinFast, giá trị chưa VAT 100.000.000, Người tạo = `ketoan_ar`, Người duyệt = `ketoan_truong`, trạng thái Chờ duyệt nội bộ → Lưu. 3. Đăng nhập `ketoan_truong`, đổi trạng thái "Đã duyệt nội bộ" → Ghi sổ. 4. Xem Document register records. | `CongNoPhaiThu` +100tr (chứng từ gốc = chính biên bản); `SoCaiKeToan`: Nợ 1312 (VinFast là bên liên kết) / Có 5113 = 100tr. | |
| TC-AR-02 | Hóa đơn GTGT theo biên bản chỉ ghi VAT | 1. Tạo Hóa đơn GTGT đầu ra, chọn biên bản ở TC-AR-01, VAT 10%, trạng thái Đã phát hành, người lập/duyệt khác nhau → Ghi sổ bằng người duyệt. 2. Xem register records. | Chỉ có dòng VAT: `CongNoPhaiThu` +10tr; GL Nợ 131 / Có 33311 = 10tr. Không ghi lại doanh thu. | |
| TC-AR-15 | Phiếu thu giảm công nợ | 1. Tạo Phiếu thu: chứng từ gốc = biên bản TC-AR-01, cùng đối tác/hợp đồng, TK Techcombank VND, số tiền 50.000.000 → Ghi sổ. | `CongNoPhaiThu` −50tr; `DongTien` +50tr; GL Nợ 1121 / Có 1312 = 50tr. | |
| TC-AR-16 | Chặn thu vượt công nợ | Tạo Phiếu thu cho cùng biên bản, số tiền 100.000.000 (lớn hơn số còn nợ 60tr) → Ghi sổ. | Bị chặn, thông báo số dư không đủ; không có movement. | |

### 1.3. Phải trả (AP)

| ID | Mục tiêu | Các bước | Kết quả mong đợi | Kết quả thực tế |
|---|---|---|---|---|
| TC-AP-01 | Hóa đơn NCC nước ngoài có FCT | 1. Đăng nhập `ketoan_ap`. 2. Phải trả → Hóa đơn NCC → Tạo: NCC AWS, tiền tệ USD, 1.000 USD, có FCT, Người lập `ketoan_ap`, Người duyệt `ketoan_truong`, trạng thái Chờ kế toán AP → Lưu. 3. `ketoan_truong` đổi trạng thái Đã ghi sổ → Ghi sổ. | Tỷ giá tự lấy từ bảng tỷ giá; thuế nhà thầu 5% VAT + 5% TNDN; `CongNoPhaiTra` + (số nợ thực trả sau FCT); GL Nợ 627 / Có 331x, Nợ 627 / Có 3338, Nợ 1331 / Có 33318. | |
| TC-AP-06 | Ủy nhiệm chi trả nợ NCC | 1. Tạo UNC trả hóa đơn TC-AP-01, TK VCB USD, tiền tệ USD. 2. Lần lượt chuyển trạng thái: Dự thảo → Chờ duyệt → Đã duyệt (bằng người duyệt) → Đã gửi NH → Đã ghi sổ → Ghi sổ. | `CongNoPhaiTra` giảm; `DongTien` giảm ở TK USD; GL Nợ 3313 / Có 1122; chênh lệch tỷ giá (nếu có) vào 515/635. | |
| TC-AP-12 | Chặn chi vượt số dư | Tạo UNC thứ 2 trả cùng hóa đơn với số tiền lớn hơn số còn nợ → Ghi sổ. | Bị chặn, không có movement. | |

### 1.4. Ngân hàng & Kênh thanh toán

| ID | Mục tiêu | Các bước | Kết quả mong đợi | Kết quả thực tế |
|---|---|---|---|---|
| TC-BANK-01 | Bảng kê VNPAY: Tổng = Thực nhận + Phí | 1. Đăng nhập `chuyenvien_doisoat`. 2. Tạo bảng kê kênh VNPAY, 1 dòng: tổng 10.000.000, phí 150.000, thực nhận 9.850.000 → Ghi sổ (người duyệt khác người lập). 3. Tạo bảng kê thứ hai có Tổng ≠ Thực nhận + Phí → Ghi sổ. | Bảng 1: `DongTien` +9,85tr; GL Nợ 1121 / Có 1388 = 9,85tr và Nợ 6427 / Có 1388 = 0,15tr. Bảng 2: bị chặn. | |
| TC-BANK-06 | Báo có ngân hàng khớp công nợ | Tạo Báo có: chứng từ khớp = biên bản còn nợ, số tiền ≤ số còn nợ, trạng thái "DaDoiSoat", người lập ≠ người duyệt → Ghi sổ. | `CongNoPhaiThu` giảm; `DongTien` tăng; GL Nợ 1121 / Có 131. | |

### 1.5. Cấn trừ nội bộ & Ngoại tệ

| ID | Mục tiêu | Các bước | Kết quả mong đợi | Kết quả thực tế |
|---|---|---|---|---|
| TC-NET-01 | Cấn trừ song phương | 1. Chọn một đối tác nội bộ (VinFast) có cả AR và AP cùng pháp nhân. 2. Tạo Cấn trừ công nợ nội bộ số tiền ≤ min(AR, AP), có người lập/duyệt khác nhau, trạng thái Đã duyệt → Ghi sổ. | `CongNoPhaiThu` và `CongNoPhaiTra` cùng giảm đúng số tiền; GL Nợ 3312 / Có 1312. | |
| TC-NET-03 | Báo cáo ma trận cấn trừ | Bù trừ & Netting → Ma trận cấn trừ nội bộ → Tạo báo cáo. | Thấy tổng cấn trừ có cả 40tr (CT-BILATERAL-01), 100tr (CT-MULTILATERAL-01) và ca TC-NET-01. | |
| TC-FX-01 | Đánh giá lại ngoại tệ cuối kỳ | 1. Nhập tỷ giá USD mới cho ngày cuối tháng (cao hơn tỷ giá cũ). 2. Mở chứng từ Đánh giá lại ngoại tệ qua **Tất cả chức năng** (chưa có trong menu — B59) → Tạo, Ngày chốt = cuối tháng, USD → Ghi sổ. | Số dư 1122, 3313 được điều chỉnh qua 4131; phần ròng kết chuyển 515 (lãi) hoặc 635 (lỗ). | |

### 1.6. Báo cáo & Dashboard

| ID | Mục tiêu | Các bước | Kết quả mong đợi | Kết quả thực tế |
|---|---|---|---|---|
| TC-RPT-01 | Báo cáo tuổi nợ | Phải thu → Báo cáo tuổi nợ phân tách nội bộ → Tạo báo cáo. | Có 5 nhóm tuổi nợ (trong hạn, 1-30, 31-60, 61-90, >90), tách nội bộ/ngoài; tổng khớp số dư GL 131 tại ngày chốt. (Hiện chỉ in 1 dòng tổng — B42, B48.) | |
| TC-RPT-02 | Báo cáo đối soát kênh | Ngân hàng & Quỹ → Báo cáo đối soát kênh thanh toán → Tạo. | Thấy VNPAY 75tr / phí 1,125tr và OnePay 40tr / phí 0,88tr. | |
| TC-RPT-03 | Dashboard CFO | Sổ cái & CFO → Bàn làm việc CFO → Làm mới. | Hiển thị doanh thu, AR, AP, tiền, DSO/DPO; số liệu khớp sổ. | |
| TC-RPT-04 | Cảnh báo Cloud | Phải trả → Cảnh báo hạn mức Cloud → Tạo. | Mức cảnh báo theo % quota và số ngày còn hạn **lấy từ hợp đồng**. (Hiện là số cứng — B43.) | |

---

## 2. Ca kiểm tra bảo mật & phân quyền

| ID | Bug | Mục tiêu | Các bước | Kết quả mong đợi | Kết quả thực tế |
|---|---|---|---|---|---|
| TC-SEC-01 | B28 | Không tự lập tự duyệt bằng cách gõ tên người khác | 1. Đăng nhập `ketoan_ap`. 2. Tạo Hóa đơn NCC: Người lập = `ketoan_ar`, Người duyệt = `ketoan_ap`, trạng thái Chờ kế toán AP → Lưu. 3. Đổi trạng thái Đã ghi sổ → Ghi sổ. | Bị chặn: Người lập phải tự động là `ketoan_ap` và không trùng người duyệt. | |
| TC-SEC-02 | B29 | Không nhảy cóc trạng thái | 1. Lưu Hóa đơn NCC ở "Chờ duyệt PM" (hoặc "Từ chối"). 2. Người duyệt đổi thẳng sang "Đã ghi sổ" → Ghi sổ. 3. Lặp với UNC: từ "Đã duyệt" sang thẳng "Đã ghi sổ". | Cả hai bị chặn, thông báo phải đi đúng bước. | |
| TC-AP-03 | B30 | Hóa đơn lớn phải qua đủ cấp duyệt | Tạo Hóa đơn NCC 600.000.000; đi từ Dự thảo, mỗi bước dùng đúng/sai vai trò (`techlead_kythuat` → `pm_duan` → `it_director` → `cfo_giamdoc` → `ketoan_ap`). | Mỗi cấp chỉ người đúng vai trò duyệt được; thiếu cấp không ghi sổ được. | |
| TC-AP-04 | B30, B36 | Chống chia nhỏ hóa đơn để né cấp duyệt | Cùng NCC, cùng tháng: tạo 3 Hóa đơn NCC 90.000.000 ở trạng thái Chờ kế toán AP; xem cấp duyệt yêu cầu cho hóa đơn thứ 3. | Hóa đơn thứ 3 phải lên cấp Kế toán trưởng (lũy kế 270tr > 100tr). | |
| TC-SEC-04 | B31 | Hủy ghi sổ cần quyền và không phá chứng từ phụ thuộc | 1. Đăng nhập `pm_duan`, mở hóa đơn NCC đã ghi sổ → Hủy ghi sổ. 2. Đăng nhập `ketoan_truong`, hủy ghi sổ hóa đơn đã có UNC trả tiền. | Bước 1 bị chặn (thiếu quyền). Bước 2 bị chặn, báo tên UNC phụ thuộc. | |
| TC-SEC-05 | B32 | Quản trị không ký duyệt chứng từ tài chính | 1. `Admin` tạo user `sysadmin` chỉ có role QuanTriHeThong. 2. Đăng nhập `sysadmin`, đặt Người duyệt = `sysadmin` trên hóa đơn NCC → Ghi sổ. | Bị chặn. | |
| TC-SEC-06 | B33 | Không reset được mật khẩu Admin | 1. Chạy 1C với tham số khởi động `/C SetupSampleUsers` bằng user `ketoan_ar`. 2. Thử đăng nhập `Admin` bằng mật khẩu `Vsf@2026!Secure`. 3. Mở Event Log tìm chữ "Pass". | Bước 1 bị từ chối; bước 2 không vào được; Event Log không chứa mật khẩu. | |
| TC-SEC-07 | B34 | Lệnh test không chạy trên CSDL thật | Trên infobase demo (không phải clone UAT), chạy `/C RunTask2SecurityTests`. Sau đó tìm Hóa đơn NCC có số bắt đầu "T2-". | Lệnh bị từ chối; không sinh/xóa chứng từ nào. | |
| TC-SEC-08 | B35 | Mỗi vai trò chỉ thấy phần việc của mình | Đăng nhập lần lượt 8 user nghiệp vụ; ghi lại phân hệ/chứng từ/báo cáo mở được và thao tác được (tạo, ghi sổ). | Khớp ma trận quyền (VD `ketoan_ar` không mở được Hóa đơn NCC, không mở được Ma trận cấn trừ). | |
| TC-SEC-09 | B37 | Kế toán AR không ghi sổ đánh giá lại tỷ giá | Đăng nhập `ketoan_ar`, tạo và ghi sổ Đánh giá lại ngoại tệ. | Bị chặn. | |
| TC-BANK-04 | B08 | Hoàn tiền phải được duyệt | Đăng nhập `ketoan_ar`, tạo Yêu cầu hoàn tiền chi hộ: trạng thái gõ "DaDuyet", Người duyệt để trống → Ghi sổ. | Bị chặn; `DongTien` không đổi. | |
| TC-AR-07 | B10 | Điều chỉnh công nợ phải có người duyệt | Đăng nhập `ketoan_ar`, tạo Điều chỉnh công nợ 50.000.000 cho một biên bản → Ghi sổ ngay. | Bị chặn, yêu cầu người duyệt khác. | |
| TC-AP-05 | B18 | Nghiệm thu thầu phụ / đề nghị thanh toán phải duyệt | 1. `ketoan_ap` tạo Nghiệm thu thầu phụ 1 tỷ ở Dự thảo → Ghi sổ. 2. Tạo Đề nghị thanh toán: Người duyệt trống, trạng thái Đã duyệt → Ghi sổ. | Cả hai bị chặn. | |

## 3. Ca kiểm tra số liệu (sổ phụ ↔ sổ cái)

| ID | Bug | Mục tiêu | Các bước | Kết quả mong đợi | Kết quả thực tế |
|---|---|---|---|---|---|
| TC-AR-03 | B01 | Hủy hóa đơn phải xóa bút toán | 1. Ghi sổ một Hóa đơn GTGT (Đã phát hành). 2. Đổi trạng thái sang "Đã hủy" → Ghi sổ lại. 3. Xem register records. | Không còn dòng nào trong `CongNoPhaiThu` và `SoCaiKeToan` (hoặc hệ thống yêu cầu hủy ghi sổ). | |
| TC-AR-04 | B02 | Sửa VAT sau lần lưu đầu vẫn khớp | 1. Tạo Hóa đơn GTGT **không** biên bản, chưa thuế 100tr, VAT 0% → Lưu. 2. Sửa VAT 10% → Ghi sổ. | Tổng = 110tr; `CongNoPhaiThu` +110tr; GL Nợ 131 = 110tr. | |
| TC-AR-05 | B03 | Chứng từ số tiền 0 không được ghi sổ | Tạo Hóa đơn GTGT có biên bản, VAT 0% → Ghi sổ. | Bị chặn hoặc không sinh dòng 0; có thông báo. | |
| TC-AR-08 | B05 | Thành phần điều chỉnh phải cộng đúng | Điều chỉnh công nợ: Tổng giảm 20tr, Giảm doanh thu 15tr, Giảm VAT 1tr → Ghi sổ. | Bị chặn (15 + 1 ≠ 20). | |
| TC-AP-02 | B17 | Sửa tổng hóa đơn NCC vẫn khớp | 1. Hóa đơn NCC không FCT: Tổng 110, VAT 10 → Lưu. 2. Sửa Tổng 220, VAT 20 → Ghi sổ. | GL Có 331 = sổ phụ AP = 220. | |
| TC-BANK-05 | B09 | Hoàn tiền: 1388 khớp sổ tạm giữ | Ghi sổ Yêu cầu hoàn tiền 5tr (đã duyệt). So sánh thay đổi số dư 1388 trên GL với thay đổi sổ `GiaoDichDienTuTamGiu`. Thử thêm phí hoàn = −1tr. | Hai thay đổi cùng chiều, cùng số tiền; phí âm bị chặn. | |
| TC-AP-08 | B21 | Phí NH khi chi từ TK USD | UNC 1.000 USD từ TK VCB USD, phí 50.000đ → Ghi sổ. So số dư GL 1122 với `DongTien` của TK USD. | Bằng nhau; phí ghi Có 1121 trên đúng TK VND của pháp nhân. | |

## 4. Ca kiểm tra tham chiếu, số dư, trùng lặp

| ID | Bug | Mục tiêu | Các bước | Kết quả mong đợi | Kết quả thực tế |
|---|---|---|---|---|---|
| TC-AR-09 | B04 | Không điều chỉnh vượt số dư | Biên bản 220tr đã thu đủ → tạo Điều chỉnh công nợ 20tr → Ghi sổ. | Bị chặn; số dư AR không âm. | |
| TC-AR-10 | B06 | Thu được tiền hóa đơn xuất thẳng | 1. Ghi sổ Hóa đơn GTGT không biên bản 110tr. 2. Tạo Phiếu thu, chọn chứng từ gốc = hóa đơn đó. | Chọn được hóa đơn; sau ghi sổ, AR của hóa đơn = 0. | |
| TC-AR-06 | B07 | Phiếu thu phải đúng hợp đồng của biên bản | Phiếu thu: chứng từ gốc là biên bản thuộc HĐ-01 nhưng chọn Hợp đồng HĐ-02, thu 50tr → Ghi sổ. | Bị chặn (hoặc hợp đồng tự lấy theo biên bản). | |
| TC-AR-11 | B11 | Không hủy biên bản đã thu tiền | Biên bản đã có phiếu thu → Hủy ghi sổ biên bản. Sau đó (nếu hủy được) sửa diễn giải → Lưu. | Hủy ghi sổ bị chặn, báo tên phiếu thu. | |
| TC-BANK-03 | B12 | Không đối soát trùng giao dịch kênh | Tạo 2 bảng kê cùng mã giao dịch kênh "TX1" → Ghi sổ cả hai. | Bảng thứ 2 bị chặn. | |
| TC-AR-12 | B13 | Chỉ hóa đơn đã phát hành mới ghi sổ; 1 biên bản 1 hóa đơn | 1. Hóa đơn GTGT trạng thái Dự thảo → Ghi sổ. 2. Hai hóa đơn cùng biên bản → Ghi sổ cả hai. | 1 bị chặn; ở 2, hóa đơn thứ hai bị chặn. | |
| TC-AR-13 | B14 | TK 1311/1312 nhất quán | Tạo đối tác Loại = Nội bộ Vingroup nhưng bỏ tick "Bên liên kết". Ghi sổ Biên bản, Hóa đơn, Báo có cho đối tác này. Xem số dư 1311, 1312. | Cả 3 chứng từ dùng cùng 1 tài khoản; không có 1311 âm. | |
| TC-BANK-02 | B16 | Không ghi trùng báo có | Tạo 2 Báo có cùng mã giao dịch ngân hàng → Ghi sổ. | Báo có thứ 2 bị chặn. | |
| TC-AP-07 | B19 | Trả nợ USD đúng tài khoản/tiền tệ | Hóa đơn NCC 1.000 USD → UNC tiền tệ VND, 25tr → Ghi sổ. | Bị chặn (tiền tệ UNC ≠ hóa đơn) hoặc ghi đúng Nợ 3313, USD giảm. | |
| TC-AP-09 | B20 | Hoàn trả UNC khôi phục công nợ hóa đơn | 1. UNC trả hóa đơn #1 50tr → Ghi sổ. 2. Tạo UNC hoàn trả (tra soát) cho UNC đó → Ghi sổ. 3. Xem số dư `CongNoPhaiTra` theo hóa đơn #1. | Số dư theo hóa đơn #1 quay lại 50tr; không có số dư theo khóa UNC. | |
| TC-NET-02 | B22 | Cấn trừ vượt số dư bị chặn | AR 60tr, AP 100tr, tạo cấn trừ 100tr → Ghi sổ. | Bị chặn, thông báo số dư AR 60tr. Không có chuyện chứng từ 100tr nhưng sổ 60tr. | |
| TC-AR-14 | M03 | Ghi sổ lùi ngày đọc số dư đúng thời điểm | 1. Biên bản 100tr ngày 01/09. 2. Phiếu thu 100tr ngày 20/09 → Ghi sổ. 3. Tạo phiếu thu thứ hai ngày 10/09, 50tr → Ghi sổ. | Phiếu thu thứ hai bị chặn (tại 10/09 còn nợ 100tr nhưng tổng sau sẽ âm) — **Cần xác nhận** quy tắc nhóm muốn. | |

## 5. Ca kiểm tra ngoại tệ

| ID | Bug | Mục tiêu | Các bước | Kết quả mong đợi | Kết quả thực tế |
|---|---|---|---|---|---|
| TC-NET-04 | B23 | Cấn trừ USD dùng tỷ giá thật | Cấn trừ AR/AP USD → Ghi sổ → xem cột Tỷ giá trên GL và `SoTienNgoaiTe` sổ phụ. | Tỷ giá = tỷ giá hạch toán của ngày; USD trên sổ phụ giảm tương ứng. (Hiện tỷ giá = 1.) | |
| TC-FX-02 | B24 | Đánh giá lại không ghi lặp | AR 1.000 USD @25.000; tỷ giá mới 25.500; tạo 2 chứng từ đánh giá lại liên tiếp (hoặc 2 kỳ cùng tỷ giá). | Lần 2 chênh lệch = 0; GL 1312 = sổ phụ AR. | |
| TC-FX-03 | B26 | Không đánh giá lại trùng kỳ / bản nháp | 1. Hai chứng từ đánh giá lại cùng ngày chốt → Ghi sổ cả hai. 2. Chứng từ ở Dự thảo → Ghi sổ. | Cả hai trường hợp bị chặn. | |
| TC-AP-10 | B25 | Số VND thực chi hợp lý với ngoại tệ | UNC 1.000 USD, tỷ giá 25.000, nhập số VND = 1.000 → Ghi sổ. | Bị chặn (chênh quá ngưỡng). | |
| TC-AP-11 | B27 | Thuế suất FCT 0% được giữ | Hóa đơn NCC FCT, thuế TNDN nhà thầu = 0 → Lưu. | Giữ 0% (không bị ép 5%). | |
| TC-FX-04 | B40 | Xuất hết ngoại tệ không còn dư VND | TK USD có 1.000 USD / 25.351.237 VND → UNC chi hết 1.000 USD. | Số dư VND của TK = 0. | |
| TC-FX-05 | B15 | GL theo tiền tệ khớp sổ phụ | Sau TC-FX-01, so số dư GL 1312 theo chiều Tiền tệ với `CongNoPhaiThu` theo hợp đồng USD. | Khớp; không có cặp Nợ USD / Có VND treo. | |

## 6. Ca kiểm tra báo cáo, dashboard, nạp số dư

| ID | Bug | Mục tiêu | Các bước | Kết quả mong đợi | Kết quả thực tế |
|---|---|---|---|---|---|
| TC-RPT-05 | B44 | Delta đối soát phát hiện lệch thật | Tạo một bảng kê có Thực nhận + Phí ≠ Tổng (nếu bị chặn thì sửa tay một movement trên clone) → mở báo cáo đối soát kênh và ma trận cấn trừ. | Delta ≠ 0 được hiển thị; không còn chữ cứng "(DELTA = 0)". | |
| TC-RPT-06 | B41 | Nạp số dư đầu kỳ | Nạp AR 100tr cho 1 đối tác; nạp lại lần 2 cùng dữ liệu. Xem số dư `CongNoPhaiThu` và TK 000. | Số dư 100tr (không gấp đôi); TK 000 cân. (Hiện không nạp được gì.) | |
| TC-RPT-07 | B45 | Báo cáo/dashboard tính phát sinh sau 30/09/2026 | Ghi sổ phiếu thu ngày 05/10/2026 → mở Dashboard và báo cáo tuổi nợ. | AR giảm tương ứng. | |
| TC-RPT-08 | B46 | DSO tính đúng | Lấy doanh thu, AR từ sổ cái trên dữ liệu mẫu, tính tay DSO = AR / doanh thu × số ngày → so với dashboard. Thêm khách mới (mã không có "TEST") → xem khối kinh doanh. | DSO khớp tính tay; khách mới không bị dồn vào "Khối BO". | |
| TC-RPT-09 | B47 | Nhãn dashboard theo số thật | Trên clone, tạo AP lớn hơn AR (VD hóa đơn NCC lớn) → Làm mới dashboard. | Nhãn vốn lưu động không còn "Dương an toàn"; không có con số cố định 35,5% / 18,2 tỷ. | |

## 7. Ca kiểm tra giao diện (theo góp ý mentor)

| ID | Nguồn | Mục tiêu | Các bước | Kết quả mong đợi | Kết quả thực tế |
|---|---|---|---|---|---|
| TC-UI-01 | M08 | Form chứng từ tính tiền ngay khi nhập | Mở Hóa đơn GTGT mới, nhập chưa thuế 100tr, VAT 10%. | Ô Tổng hiện 110tr ngay, chưa cần lưu. | |
| TC-UI-02 | M04 | Kiểm bắt buộc trước khi lưu | Tạo Phiếu thu, để trống Đối tác → Lưu. | Ô Đối tác bị tô đỏ, thông báo trỏ đúng ô. | |
| TC-UI-03 | M07 | In chứng từ | Mở một UNC → bấm In. | Ra bản in có đủ số, ngày, người nhận, số tiền bằng số và chữ. | |
| TC-UI-04 | M17 | Tạo chứng từ dựa trên chứng từ trước | Mở Biên bản → "Tạo dựa trên" → Hóa đơn GTGT. | Hóa đơn mới tự điền đối tác, hợp đồng, biên bản, số tiền. | |

## 8. Ca kiểm tra kỹ thuật, công cụ seed/scripts (dùng clone UAT, người có kỹ thuật chạy)

> Các ca này cần mở Designer, chạy lệnh khởi động `/C …` hoặc đọc code; người thuyết trình không cần chạy.

| ID | Bug | Mục tiêu | Các bước | Kết quả mong đợi | Kết quả thực tế |
|---|---|---|---|---|---|
| TC-TECH-01 | B38 | Đối soát GL ↔ sổ phụ tính cả phát sinh đúng giờ chốt | Ghi sổ phiếu thu lúc `30/09/2026 23:59:59`; chạy đối soát độc lập với ngày chốt đó. | Delta = 0. | |
| TC-TECH-02 | B39 | Kiểm tra cân đối phát hiện lệch thật | Trên clone, tạo chứng từ cố tình lệch (VD sửa Tổng sau khi lưu như TC-AR-04) → Ghi sổ. | Bị chặn bởi kiểm tra khớp GL ↔ sổ phụ. | |
| TC-TECH-03 | B49 | Xuất bằng chứng trial balance | Chạy 1C với `/C ExportTrialBalanceEvidence;<run_id>;<đường dẫn>`. | File JSON được tạo, không có lỗi "requires an explicit output path" trong Event Log. | |
| TC-TECH-04 | B50 | Trạng thái xuất báo cáo phản ánh lỗi thật | Trên clone, làm 1 báo cáo lỗi (VD đổi tên trường trong query), chạy lệnh xuất báo cáo quản trị. | Trạng thái không còn `EXECUTIVE_REPORTS_SUCCESS_100`. | |
| TC-TECH-05 | B51 | Đối soát tự động không chấp nhận tiền 0 | Gọi `ThucHienDoiSoatTang2(0, 800)` (qua external data processor hoặc test). | Không trả "Đã đối soát". | |
| TC-TECH-06 | B52, B53 | Không còn nhánh lệnh chết | Chạy `/C RunTask3USDTests`; đọc `AppModule` dòng 246-266. | Lệnh không tồn tại bị báo "không hỗ trợ"; không còn nhánh trùng. | |
| TC-TECH-07 | B54 | Transaction chuẩn | Đọc `CM/QuanLyVongDoiChungTuServer` quanh dòng 1006; chạy lifecycle test trong transaction của người gọi. | Không còn `RollbackTransaction` trước `BeginTransaction`; transaction người gọi không bị hủy. | |
| TC-TECH-08 | B55 | Test bảo mật không PASS giả | Xóa hết Đối tác trên clone → chạy `/C RunTask2SecurityTests` (trên clone). | Kết quả FAIL vì thiếu dữ liệu, không phải PASS. | |
| TC-TECH-09 | B56 | Cổng seed không bị lừa bằng tên thư mục | Copy infobase vào thư mục có tên chứa `/scratch/uat/` nhưng không có marker clone, cờ seed = False → chạy lệnh seed. | Bị chặn. | |
| TC-TECH-10 | B57 | Client không ghi log giả, lỗi query tài khoản báo rõ | Từ external data processor gọi `QuanLyVongDoiChungTuServer.GhiNhatKyInfo`; xóa tạm một mã logic tài khoản rồi ghi sổ. | Gọi từ client bị từ chối; ghi sổ báo lỗi rõ ràng "thiếu tài khoản …" thay vì crash. | |
| TC-TECH-11 | B58 | Watchdog dùng hằng timeout, không ra số âm | Gọi `TinhCanTruTayDoi(-5, 10)`; đặt `TimeoutChoCanTruPhut` = 60, kiểm watchdog. | Kết quả 0; timeout theo 60 phút. | |
| TC-TECH-12 | B59 | Menu đầy đủ, không có mục trống | Mở phân hệ "5. Sổ cái & CFO" và các phân hệ có data processor. | Có "Đánh giá lại ngoại tệ"; mọi mục bấm vào đều mở được form. | |
| TC-TECH-13 | B60 | Không trùng số tài khoản ảo | Tạo 2 tài khoản ảo số `" 123 "` và `"123"`. | Cái thứ hai bị chặn. | |
| TC-TECH-14 | B61 | Bắt chọn tiền tệ khi có ngoại tệ | Hóa đơn NCC có số ngoại tệ 1.000 nhưng để trống Tiền tệ → Lưu. | Bị chặn. | |
| TC-TECH-15 | B62 | Yêu cầu hoàn tiền chưa duyệt không được "ghi sổ rỗng" | Yêu cầu hoàn tiền trạng thái Dự thảo → Ghi sổ. | Bị chặn; Posted vẫn False. | |
| TC-TECH-16 | B63 | Đề nghị thanh toán không bật ghi sổ vô nghĩa | Mở Đề nghị thanh toán dịch vụ. | Không còn nút Ghi sổ (hoặc nhóm có lý do ghi trong nhật ký quyết định). | |
| TC-TECH-17 | B64 | Tài liệu khớp code | Đọc chéo `README.md`, `docs/ERP_AUDIT_2026-10-14_FINAL_100.md`, `HUONG_DAN_SU_DUNG_FILE_DT.md`, `progress.md` so với danh sách đối tượng trong `src/`. | Không còn đối tượng "DONE" mà không có trong `src/`; số liệu GL keys, số chứng từ, mật khẩu thống nhất. | |
| TC-TECH-18 | B65 | Bổ sung khóa sổ cái không tự bịa | Trên clone có dòng GL thiếu đối tác/hợp đồng → chạy hàm bổ sung khóa. | Không dòng nào bị gán `TEST_DT_01`/`DT-ONEPAY`/`NCC-AWS`; có danh sách dòng chưa xử lý; lỗi giữa chừng không để GL sửa dở. | |
| TC-TECH-19 | B66 | Script import không đè infobase chính | Chạy `scripts/import_dt.ps1` không truyền `-IBPath`. | Báo lỗi, không restore vào đâu; mã thoát ≠ 0 khi lỗi. | |
| TC-TECH-20 | B67 | Seed không tạo Admin rỗng mật khẩu, toàn quyền | Chạy seed sạch trên clone chưa có Admin → xem user Admin trong Designer. | Admin có mật khẩu, chỉ 1 role QuanTriHeThong. | |
| TC-TECH-21 | B68 | Generator netting sinh chứng từ gốc | Chạy generator netting trên clone. | Chứng từ cấn trừ có chứng từ gốc AR/AP và ghi sổ được. | |
| TC-TECH-22 | B69 | Hằng số sau seed có giá trị | Chạy seed sạch → mở 2 hằng `PhapNhanMacDinh`, `TaiKhoanTrungGianCanTru`. | Có giá trị đúng (PN-VSF, TK 1388). | |
| TC-TECH-23 | B70 | NCC trong nước hợp đồng VND | Chạy generator master data → mở hợp đồng của `TEST_NCC_VN_*`. | Tiền tệ hợp đồng = VND. | |
| TC-TECH-24 | B71 | Test hardening không làm kẹt cờ / sót dữ liệu | Chạy `RunHardeningUAT` trên clone, kill tiến trình giữa chừng. | Cờ `ChoPhepSinhDuLieuMau` vẫn False; không có chứng từ test sót lại. | |
| TC-TECH-25 | B72 | Generator không xóa tỷ giá cũ | Đếm bản ghi tỷ giá USD → chạy generator master data → đếm lại. | Số bản ghi cũ giữ nguyên (chỉ tăng thêm). | |
| TC-TECH-26 | B73 | Script user không đụng bản phát hành | Chạy `setup_sample_users.ps1` không tham số. | Báo lỗi yêu cầu đường dẫn clone; `Infobase_FullData` không bị đổi. | |
| TC-TECH-27 | B74 | Chứng từ generator ghi sổ lại được | Sinh dữ liệu bằng generator AR → đăng nhập `ketoan_truong` → ghi sổ lại 1 biên bản. | Ghi sổ lại thành công. | |
| TC-TECH-28 | B75 | Script chạy trên máy khác | Clone repo vào thư mục khác `C:\Users\Dung` → chạy `export_dt.ps1` với tham số đường dẫn. | Không lỗi đường dẫn cứng; không ghi đè `.dt` phát hành khi chưa xác nhận. | |

---

## 9. Bảng tổng hợp kết quả (điền sau khi chạy)

| Nhóm | Số ca | Đạt | Không đạt | Ghi chú |
|---|---|---|---|---|
| 1. Chức năng chính | 18 | | | |
| 2. Bảo mật & phân quyền | 13 | | | |
| 3. Số liệu sổ phụ ↔ sổ cái | 7 | | | |
| 4. Tham chiếu, số dư, trùng lặp | 12 | | | |
| 5. Ngoại tệ | 7 | | | |
| 6. Báo cáo, dashboard | 5 | | | |
| 7. Giao diện | 4 | | | |
| 8. Kỹ thuật, công cụ | 28 | | | |
| **Tổng** | **94** | | | |

Người test: ………… Ngày: ………… Bản `.dt` / commit: …………
