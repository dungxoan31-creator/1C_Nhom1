# 01 — HIỆN TRẠNG DỰ ÁN

> Rà soát ngày 15/10/2026 trên commit `f993fc1` (nhánh mặc định, tác giả Nguyễn Hữu Dũng, 15/10/2026 08:51).
> Chỉ đọc code, không sửa file code nào. Điều gì chưa chắc ghi "Cần xác nhận".

## 1. Dự án làm gì (3 câu)

1. **VinSmart Future (VSF) AR/AP** là một cấu hình 1C:Enterprise 8.3 (giao diện Taxi, chế độ Managed Application) quản lý **công nợ phải thu (AR)**, **công nợ phải trả (AP)**, **tiền ngân hàng** và **cấn trừ công nợ nội bộ tập đoàn**.
2. Mỗi nghiệp vụ được nhập bằng một **chứng từ** (Document). Khi bấm **Ghi sổ (Post)**, chứng từ ghi số liệu đồng thời vào **sổ chi tiết** (sổ công nợ, sổ dòng tiền) và **sổ cái kế toán** `SoCaiKeToan` theo bút toán Nợ/Có.
3. Ngoài ra có **phê duyệt nhiều cấp, nguyên tắc Maker-Checker** (người lập không được tự duyệt), **đánh giá lại ngoại tệ**, **báo cáo tuổi nợ** và **Dashboard cho CFO**.

## 2. Thuật ngữ dùng trong tài liệu (mỗi thuật ngữ 1 câu)

| Thuật ngữ | Giải thích ngắn |
|---|---|
| Cấu hình (Configuration) | Toàn bộ "khung" của phần mềm 1C: bảng dữ liệu, chứng từ, báo cáo, code; nằm trong thư mục `src/`. |
| Infobase / file `.dt` | Cơ sở dữ liệu 1C; file `.dt` là bản sao lưu chứa cả cấu hình lẫn dữ liệu, nạp vào là chạy được. |
| Catalog (Danh mục) | Bảng dữ liệu nền như Đối tác, Hợp đồng, Tiền tệ. |
| Document (Chứng từ) | Phiếu nghiệp vụ có ngày giờ, ví dụ Hóa đơn, Phiếu thu; có thể "Ghi sổ". |
| Ghi sổ / Hủy ghi sổ (Post / Unpost) | Ghi sổ là sinh ra các dòng số liệu (movement) vào sổ; hủy ghi sổ là xóa các dòng đó. |
| Movement | Một dòng số liệu do chứng từ ghi vào sổ. |
| Accumulation Register (Sổ tích lũy) | Sổ cộng dồn số dư, ví dụ `CongNoPhaiThu` cho biết khách còn nợ bao nhiêu. Receipt = tăng, Expense = giảm. |
| Accounting Register (Sổ cái) | Sổ kế toán kép, mỗi dòng có TK Nợ, TK Có, số tiền. |
| Information Register | Bảng tra cứu theo khóa, ví dụ tỷ giá theo ngày. |
| Enum (Liệt kê) | Danh sách giá trị cố định, ví dụ trạng thái chứng từ. |
| Common Module | Thư viện hàm dùng chung cho nhiều chứng từ. |
| BSL | Ngôn ngữ lập trình của 1C (file `.bsl`). |
| Maker-Checker | Người lập (maker) và người duyệt (checker) phải là 2 người khác nhau. |
| SoD | Phân tách nhiệm vụ: mỗi vai trò chỉ được làm phần việc của mình. |
| DataLock (khóa dữ liệu) | Khóa số dư lúc đang ghi để 2 người không trừ cùng một khoản nợ cùng lúc. |
| DCS | Data Composition System: công cụ dựng báo cáo chuẩn của 1C, người dùng tự lọc/nhóm được. |
| FCT | Thuế nhà thầu nước ngoài (VAT + TNDN khấu trừ khi trả tiền cho NCC nước ngoài như AWS). |
| Netting (Cấn trừ) | Bù trừ phải thu với phải trả giữa các công ty trong tập đoàn, chỉ thanh toán phần chênh. |
| Aging (Tuổi nợ) | Phân loại khoản nợ theo số ngày quá hạn: trong hạn, 1-30, 31-60, 61-90, >90 ngày. |

## 3. Cấu trúc repo

| Thư mục / file | Nội dung |
|---|---|
| `src/` | Cấu hình 1C dạng XML (metadata) + code BSL. ~13.400 dòng BSL trong 45 file. |
| `scripts/` | ~70 script Python/PowerShell để nạp cấu hình, tạo clone UAT, sinh dữ liệu, chạy test runtime. |
| `tests/` | 21 file BSL unit + 3 file migration. **Chỉ là kịch bản tham khảo, chưa được đăng ký chạy trong cấu hình** (theo `tests/README.md`). |
| `docs/` | Đặc tả, kế hoạch, báo cáo audit cũ (`ERP_AUDIT_*.md`, `docs/superpowers/...`), chính sách kế toán. 5 file tài liệu mới của đợt rà soát này nằm ở đây (`01_` → `05_`). |
| `1C-Mentor-Skill-Gemini/` | Tài liệu hướng dẫn của mentor ("1c mentor"): quy tắc review code, đề bài BTL, thang điểm. |
| `Lessons/` | 24 bài giảng 1C (Theory/Practice, có bản tiếng Việt). |
| `Bài thực hành/` | 2 bài thực hành. |
| `VinSmart_Future_AR_AP_Full.dt` | File sao lưu CSDL đầy đủ (cấu hình + dữ liệu mẫu) dùng để demo. |
| `HUONG_DAN_SU_DUNG_FILE_DT.md` | Hướng dẫn nạp file `.dt`, tài khoản đăng nhập. |
| `audit_logic_1c.md/.xlsx` | Báo cáo audit logic cũ (tham khảo). |
| `.superpowers/sdd/...` | Nhật ký tiến độ task của các agent AI trước đây. |

## 4. Thành phần cấu hình (đếm từ `src/`)

| Loại đối tượng | Số lượng | Danh sách |
|---|---|---|
| Documents (Chứng từ) | 13 | xem mục 5 |
| Catalogs (Danh mục) | 10 | PhapNhan, DoiTac, HopDong, TaiKhoanTien, TaiKhoanAo, KenhThanhToan, DichVuCNTT, DuAn, KhoanMucDongTien, TienTe |
| Accumulation Registers | 4 | `CongNoPhaiThu`, `CongNoPhaiTra` (chiều: PhapNhan, DoiTac, HopDong, ChungTuGoc), `DongTien` (PhapNhan, TaiKhoanTien, TienTe, KhoanMucDongTien), `GiaoDichDienTuTamGiu` (tiền tạm giữ ở cổng thanh toán) |
| Accounting Register | 1 | `SoCaiKeToan` (chiều: PhapNhan, TienTe; số tiền VND + ngoại tệ) |
| Chart of Accounts | 1 | `HeThongTaiKhoan` — **không có tài khoản định sẵn (predefined)**, code tìm tài khoản bằng `FindByCode("1311")`… nên phụ thuộc dữ liệu trong `.dt`. |
| Information Registers | 3 | `TyGiaHoiDoai` (theo ngày), `HanMucVaChanXuatDichVu`, `KeHoachChiTien` |
| Enums | 7 | Trạng thái HĐ AP, trạng thái AR, trạng thái HĐĐT, trạng thái lệnh chi, trạng thái cấn trừ, loại đối tác, hướng dòng tiền |
| Constants | 12 | Ngưỡng duyệt CFO, ngưỡng cảnh báo Cloud, timeout cấn trừ, cờ cho phép sinh dữ liệu mẫu… |
| Reports | 4 | Tuổi nợ phân tách nội bộ; Cảnh báo hạn mức Cloud; Đối soát kênh thanh toán; Ma trận cấn trừ nội bộ |
| Data Processors | 4 | Dashboard CFO (có form HTML); Động cơ đối soát; Lập ma trận cấn trừ; Nạp số dư đầu kỳ |
| Common Modules | 18 | 7 module nghiệp vụ + 11 module seed/test (xem mục 6) |
| Roles | 9 | QuanTriHeThong, KeToanTruong, KeToanPhaiThu, KeToanPhaiTra, GiamDocTaiChinh_CFO, ChuyenVienDoiSoatTapDoan, ProjectManager, TechLead, ITDirector |
| Subsystems (menu) | 6 | 1. Phải thu · 2. Phải trả · 3. Ngân hàng & Quỹ · 4. Bù trừ & Netting · 5. Sổ cái & CFO · 6. Danh mục |
| Forms | 1 | Chỉ Dashboard CFO có form tự thiết kế. **13 chứng từ và 10 danh mục không có form riêng** (1C tự sinh form mặc định). |
| Templates (mẫu in, DCS) | 0 | **Không có mẫu in, không có sơ đồ DCS cho báo cáo.** |

## 5. 13 chứng từ và luồng nghiệp vụ

| Phân hệ | Chứng từ | Làm gì | Ghi vào sổ |
|---|---|---|---|
| Phải thu | `BienBanNghiemThuGiaiDoan` | Ghi nhận doanh thu theo đợt nghiệm thu (chưa VAT). Có Maker-Checker. | CongNoPhaiThu (+), Nợ 1311/1312 – Có 5113 |
| Phải thu | `HoaDonGTGTDauRa` | Hóa đơn điện tử. Có biên bản: chỉ ghi VAT. Xuất thẳng: ghi doanh thu + VAT. | CongNoPhaiThu (+), Nợ 131 – Có 5113/33311 |
| Phải thu | `PhieuThuTienKhachHang` | Thu tiền theo một biên bản; kiểm tra số dư nợ có khóa dữ liệu. | CongNoPhaiThu (−), DongTien (+), Nợ 112 – Có 131 |
| Phải thu | `DieuChinhCongNo` | Giảm công nợ sau tranh chấp (giảm doanh thu + VAT). | CongNoPhaiThu (−), Nợ 5113/33311 – Có 131 |
| Ngân hàng | `BaoCoNganHang` | Tiền về ngân hàng, khớp với biên bản. Có Maker-Checker. | CongNoPhaiThu (−), DongTien (+), Nợ 1121 – Có 131 |
| Ngân hàng | `BangKeDoiSoatKenhThanhToan` | Đối soát cổng VNPAY/OnePay: Tổng = Thực nhận + Phí. | GiaoDichDienTuTamGiu (−), DongTien (+), Nợ 1121/6427 – Có 1388 |
| Ngân hàng | `YeuCauHoanTienChiHo` | Hoàn tiền cho khách lẻ qua cổng thanh toán. | GiaoDichDienTuTamGiu (−), DongTien (−), Nợ 1388/6427 – Có 1121 |
| Phải trả | `HoaDonNhaCungCap` | Hóa đơn NCC, tự tính tỷ giá và thuế nhà thầu FCT; duyệt 4+1 cấp (Tech Lead → PM → IT Director → CFO → Kế toán AP). | CongNoPhaiTra (+), Nợ 627/1331 – Có 331x/3338/33318 |
| Phải trả | `NghiemThuThauPhu` | Nghiệm thu thầu phụ. | CongNoPhaiTra (+), Nợ 627/1331 – Có 3311/3312 |
| Phải trả | `DeNghiThanhToanDichVu` | Đề nghị thanh toán nội bộ, chỉ kiểm tra đã duyệt. | Không ghi sổ nào |
| Phải trả | `UyNhiemChi` | Lệnh chi: Dự thảo → Chờ duyệt → Đã duyệt → Đã gửi NH → Đã ghi sổ. Có chênh lệch tỷ giá, phí NH, bút toán hoàn trả. | CongNoPhaiTra (−), DongTien (−), Nợ 331x – Có 1121/1122 |
| Netting | `CanTruCongNoNoiBo` | Cấn trừ AR/AP nội bộ (song phương hoặc qua TK trung gian 1388); có khóa số dư. | CongNoPhaiThu (−), CongNoPhaiTra (−), Nợ 3312 – Có 1312 |
| Sổ cái | `DanhGiaLaiNgoaiTe` | Đánh giá lại số dư ngoại tệ cuối kỳ qua 4131, kết chuyển 515/635. **Không nằm trong menu nào.** | DongTien, CongNoPhaiTra, SoCaiKeToan |

Luồng chính:
- **AR:** Biên bản nghiệm thu → Hóa đơn GTGT → Phiếu thu hoặc Báo có → (nếu tranh chấp) Điều chỉnh công nợ.
- **AP:** Hóa đơn NCC (duyệt nhiều cấp) → (Đề nghị thanh toán) → Ủy nhiệm chi.
- **Nội bộ:** AR và AP với công ty cùng tập đoàn → Cấn trừ.
- **Cuối kỳ:** Đánh giá lại ngoại tệ → Báo cáo tuổi nợ, Dashboard CFO.

## 6. Common Modules

| Module | Vai trò |
|---|---|
| `QuanLyVongDoiChungTuServer` | Vòng đời chứng từ: kiểm tra chuyển trạng thái, đọc số dư AR có khóa, kiểm tra cân đối Nợ/Có, ghi log, test lifecycle. |
| `PhanQuyenBaoMatServer` | Maker-Checker, kiểm tra quyền theo vai trò (so tên user/role), test SoD. Cờ **Privileged + ServerCall**. |
| `PheDuyetDaCapServer`, `QuyTrinhPheDuyetAPServer` | Ngưỡng duyệt nhiều cấp, phát hiện chia nhỏ hóa đơn, nhánh duyệt CFO. |
| `QuanLyTyGiaVaNgoaiTeServer` | Lấy tỷ giá hạch toán, tính tỷ giá xuất quỹ bình quân, quy đổi VND. |
| `BaoCaoQuanTriServer` | Toàn bộ logic 4 báo cáo + dữ liệu Dashboard + xuất bằng chứng JSON. |
| `UserProvisioningServer` | Tạo người dùng mẫu và gán vai trò. Cờ **Privileged + ServerCall**. |
| 11 module `Seed*`, `Generator*`, `*TestsServer` | Sinh dữ liệu mẫu và test chạy trên bản clone UAT; được gọi qua tham số dòng lệnh `/C` trong `src/Ext/ManagedApplicationModule.bsl`. |

## 7. Cách chạy

**Cách nhanh để demo (khuyến nghị):**
1. Cài 1C:Enterprise 8.3 (README nói runner mặc định dùng bản Training `1cv8t` 8.3.22.1704; hướng dẫn `.dt` ghi "8.3.22 trở lên").
2. Mở 1C → **Add** → "Create an infobase without configuration" → đặt tên, chọn thư mục → Finish.
3. Chọn infobase vừa tạo → **Designer** → `Administration → Restore infobase...` → chọn `VinSmart_Future_AR_AP_Full.dt` → Yes.
4. Đóng Designer → bấm **1C:Enterprise** để chạy.
5. Đăng nhập (theo `HUONG_DAN_SU_DUNG_FILE_DT.md`): `Admin` (mật khẩu trống) hoặc user nghiệp vụ `ketoan_ar`, `ketoan_ap`, `chuyenvien_doisoat`, `cfo_giamdoc`, `ketoan_truong`, `pm_duan`, `techlead_kythuat`, `it_director` (mật khẩu `123`).
   - **Cần xác nhận:** `src/CommonModules/UserProvisioningServer/Ext/Module.bsl` dòng 118-126 đặt mật khẩu khác (`Vsf@2026!Secure`). Phải thử đăng nhập thật trên `.dt` trước buổi demo.

**Cách cho developer:** `scripts/create_uat_clone.py` (không dùng `scripts/import_dt.ps1` — xem B66), `scripts/onec_runtime.py update-db ...` (chi tiết trong `README.md`). Test offline Python: `python -B -m unittest discover -s scripts -p test_audit_tools.py -v`.

## 8. Cái gì đã xong

- Đủ khung dữ liệu: 13 chứng từ, 10 danh mục, 4 sổ tích lũy, 1 sổ cái, 7 enum, 12 hằng số, 9 vai trò, 6 phân hệ menu.
- Ghi sổ kép: hầu hết chứng từ ghi đồng thời sổ chi tiết và sổ cái; dấu tăng/giảm (Receipt/Expense) đúng chiều nghiệp vụ.
- Có khóa dữ liệu (DataLock) khi trừ số dư ở Phiếu thu, Báo có, Ủy nhiệm chi, Cấn trừ, Đánh giá lại; chế độ khóa của cấu hình là Managed.
- Có Maker-Checker, chuỗi duyệt AP 4+1 cấp, thuế nhà thầu FCT, đánh giá lại ngoại tệ, xử lý chênh lệch tỷ giá khi chi tiền.
- Có Dashboard CFO (HTML) và 4 báo cáo ở mức tính toán.
- Có file `.dt` kèm dữ liệu mẫu và tài liệu hướng dẫn; README ghi nhận một số ca test runtime đã PASS trên clone (SeedSafety, RBAC 6 user, lifecycle 3 ca…).
- Thông báo cho người dùng dùng `UserMessage` + `NStr` song ngữ; không dùng hộp thoại modal.

## 9. Cái gì còn dở / chưa đúng (tóm tắt — chi tiết ở `02_BUG.md`)

- **Giao diện:** không có form chứng từ, không có mẫu in, 4 báo cáo không có DCS và chỉ in 1 dòng tổng; 3 data processor không có form (mở từ menu không làm được gì).
- **Phân quyền:** 9 file `src/Roles/*/Ext/Rights.xml` giống hệt nhau, không cấp quyền cụ thể cho đối tượng nào; phân quyền thực tế làm bằng code so tên user (Cần xác nhận hiệu lực trên `.dt`).
- **Kiểm soát:** Maker-Checker dựa vào ô chữ người lập tự gõ; state machine chỉ chặn vài trạng thái; nhiều chứng từ giảm nợ/chi tiền không có quy trình duyệt.
- **Số liệu:** một số chỗ sổ chi tiết lệch sổ cái, hủy hóa đơn không xóa bút toán, cấn trừ/đánh giá lại ngoại tệ không cập nhật số dư USD, gọi hàm tỷ giá không tồn tại.
- **Chưa làm thật:** `NapSoDuDauKy` chỉ ghi log; `DongCoDoiSoatTuDong` và watchdog cấn trừ không được gọi; dashboard và cảnh báo Cloud có nhiều số cứng (`Date(2026,9,30)`, quota theo mã `TEST_`).
- **Tài liệu mâu thuẫn:**
  - `.superpowers/sdd/.../progress.md` ghi đã xong HTTPService webhook, `TichHopNganHangServer`, `TichHopHoaDonDienTuServer`, `DongBoButToanSAP`, scheduled job tỷ giá — **không có trong `src/`**.
  - `README.md` dòng 3 ghi VerifyGLAnalyticKeys **FAIL** (8.215/8.579), nhưng `docs/ERP_AUDIT_2026-10-14_FINAL_100.md` dòng 25 ghi **PASS** (8.681/8.681).
  - `HUONG_DAN_SU_DUNG_FILE_DT.md` dòng 11 ghi "6.473 chứng từ", mục 2-3 cùng file ghi "43 chứng từ".
- **Công cụ:** nhiều script và module seed dùng đường dẫn cứng `C:\Users\Dung\...`; `scripts/import_dt.ps1` restore đè vào infobase chính; hàm bổ sung khóa sổ cái tự gán đối tác/hợp đồng mặc định.
- **Test:** 24 file BSL trong `tests/` chưa chạy trên engine (README: SourceBslReference NOT_RUN); test 2 phiên đồng thời NOT_RUN do bản Training giới hạn kết nối.

## 10. Giả định

1. "Folder 1c mentor" = `1C-Mentor-Skill-Gemini/`; "folder lessons" = `Lessons/` (đọc thêm `Bài thực hành/`).
2. Rà soát dựa trên mã nguồn `src/`. Không chạy được 1C trong môi trường rà soát nên không mở được `.dt`; những gì phụ thuộc dữ liệu trong `.dt` (tài khoản, quyền thật) ghi "Cần xác nhận".
3. Các module seed/test được coi là công cụ phát triển; lỗi ở đó xếp mức thấp hơn lỗi ở chứng từ nghiệp vụ, trừ khi ảnh hưởng dữ liệu thật hoặc bảo mật.
4. Dự án tự xây từ cấu hình trống nên áp dụng lộ trình M (MIS) trong tài liệu mentor; thang điểm BTL trong `btl-1-de-bai-y-tuong.md` dùng để tham khảo (Cần xác nhận với giảng viên).
