# 02 — DANH SÁCH BUG VÀ LỖI LOGIC

> Rà soát commit `f993fc1`, ngày 15/10/2026. Chỉ đọc code, không sửa. Số dòng tính theo file trong `src/` (đường dẫn rút gọn bỏ tiền tố `src/`).
> Ký hiệu: `Doc/X` = `src/Documents/X/Ext/ObjectModule.bsl`; `CM/X` = `src/CommonModules/X/Ext/Module.bsl`; `DP/X` = `src/DataProcessors/X/Ext/ObjectModule.bsl`; `Rep/X` = `src/Reports/X/Ext/ObjectModule.bsl`; `AppModule` = `src/Ext/ManagedApplicationModule.bsl`.

## Cách đọc mức độ

| Mức | Nghĩa |
|---|---|
| **Cao** | Sai số liệu kế toán, vượt được kiểm soát/bảo mật, hoặc chức năng chính không chạy. Phải sửa trước khi demo/nộp. |
| **Trung** | Trường hợp biên có thể xảy ra trong thực tế, hoặc số liệu báo cáo sai lệch nhưng không làm hỏng sổ. |
| **Thấp** | Code thừa/chết, thông điệp, hiệu năng nhỏ, thiếu nhất quán. |

**Thuật ngữ hay gặp trong bảng:** *movement* = dòng số liệu chứng từ ghi vào sổ; *sổ phụ* = sổ chi tiết công nợ/tiền (`CongNoPhaiThu`, `CongNoPhaiTra`, `DongTien`); *GL* = sổ cái `SoCaiKeToan`; *Receipt/Expense* = ghi tăng/ghi giảm sổ tích lũy; *DataLock* = khóa số dư khi ghi; *Privileged* = module chạy với toàn quyền, bỏ qua kiểm tra quyền; *ServerCall* = cho phép phía client gọi trực tiếp.

## Tổng hợp

| Mức | Số bug |
|---|---|
| Cao | 34 |
| Trung | 28 |
| Thấp | 13 |
| **Tổng** | **75** |

---

## A. Chứng từ Phải thu (AR) và Ngân hàng

| STT | File:dòng | Mô tả (lỗi gì – vì sao sai – hậu quả) | Mức độ |
|---|---|---|---|
| B01 | `Doc/HoaDonGTGTDauRa:64-75` (Posting) so với dòng 82-83 | Khi trạng thái HĐĐT là `DaHuy`/`DaDieuChinh`, code `Return` **trước** khi đặt `RegisterRecords.*.Write = True`. Metadata đặt `WriteSelected` nên lệnh `Clear()` không được ghi xuống. Hủy một hóa đơn đã ghi sổ rồi ghi sổ lại → **bút toán AR và VAT cũ vẫn còn**. Comment dòng 81 nói ngược với code. | Cao |
| B02 | `Doc/HoaDonGTGTDauRa:47-54` (BeforeWrite); Posting 156, 170, 185 | VAT chỉ tự tính khi đang = 0, Tổng thanh toán chỉ tính khi đang = 0, không kiểm `Tổng = Chưa thuế + VAT`. Sổ phụ AR ghi `TongTienThanhToan`, GL ghi `TienChuaThue + TienThueVAT`. Lưu lần đầu VAT 0%, sau sửa 10% → VAT tính lại nhưng Tổng giữ cũ → **sổ phụ AR ≠ GL 131**. | Cao |
| B03 | `Doc/HoaDonGTGTDauRa:193-205`; `Doc/DieuChinhCongNo:169-177` (Posting) | Khối `Try … KiemTraCanDoiSoCai … Except EndTry` **nuốt lỗi**, không đặt `Cancel`. Chứng từ số tiền 0 (VD hóa đơn có biên bản, VAT 0%) vẫn ghi sổ ra dòng GL/AR bằng 0. | Cao |
| B04 | `Doc/DieuChinhCongNo:117-126` (Posting) | Giảm công nợ mà **không kiểm số dư AR, không DataLock**, không kiểm biên bản đã ghi sổ hay cùng Đối tác/Hợp đồng. Giảm vượt số dư → **AR âm**; chọn biên bản của khách khác → trừ sai khách. | Cao |
| B05 | `Doc/DieuChinhCongNo:34-52` (BeforeWrite), Posting 125, 146, 160 | Không ràng buộc `GiamDoanhThu + GiamThueVAT = TongTienGiam`. Sổ phụ AR giảm `TongTienGiam`, GL Có 131 = tổng 2 thành phần → nhập lệch là **sổ phụ ≠ GL**. Dòng 45 có thể ra VAT âm. | Cao |
| B06 | `Doc/HoaDonGTGTDauRa:155`; metadata `src/Documents/PhieuThuTienKhachHang.xml` (ChungTuGoc), `src/Documents/BaoCoNganHang.xml` (ChungTuKhop) | Hóa đơn xuất thẳng (không biên bản) ghi AR với `ChungTuGoc` = chính hóa đơn, nhưng Phiếu thu/Báo có/Điều chỉnh chỉ chấp nhận chứng từ gốc kiểu **Biên bản nghiệm thu**. → Khoản AR này **không thu được** bằng chứng từ nào. | Cao |
| B07 | `Doc/PhieuThuTienKhachHang:57, 80` (kiểm số dư) so với dòng 140 (ghi movement) | Kiểm số dư theo hợp đồng của biên bản, nhưng ghi giảm AR theo `HopDong` của phiếu thu; không kiểm 2 cái khớp. Chọn hợp đồng khác → AR hợp đồng đó **âm**, biên bản vẫn còn nợ. | Cao |
| B08 | `Doc/YeuCauHoanTienChiHo:17-60` (BeforeWrite, Posting) | Chứng từ **chi tiền ra** nhưng chỉ kiểm `NguoiLap = NguoiDuyet` khi cả hai có giá trị; không gọi `KiemTraMakerChecker`/kiểm quyền; `TrangThai` là chuỗi tự gõ. Người lập gõ `"DaDuyet"`, để trống người duyệt → **chi tiền không cần duyệt**. | Cao |
| B09 | `Doc/YeuCauHoanTienChiHo:99-106` so với 129-133 | Sổ phụ `GiaoDichDienTuTamGiu` ghi **Expense** (giảm) nhưng GL ghi **Nợ 1388** (tăng) → đối chiếu 1388 lệch gấp đôi số hoàn. `PhiHoanTien` không chặn âm: phí âm làm `DongTien` ≠ GL 112. | Cao |
| B10 | `Doc/PhieuThuTienKhachHang:16-28`; `Doc/DieuChinhCongNo:18-58`; metadata 2 chứng từ không có NguoiLap/NguoiDuyet | Hai chứng từ **giảm công nợ phải thu** không có Maker-Checker, không có bước duyệt; `DieuChinhCongNo` tự đặt `DaGhiSo` (dòng 55-57). Một kế toán AR tự xóa nợ khách được. | Cao |
| B11 | `Doc/BienBanNghiemThuGiaiDoan:153-155` (UndoPosting rỗng) | Hủy ghi sổ biên bản **không kiểm chứng từ đang tham chiếu** (phiếu thu, báo có, hóa đơn). → AR theo biên bản âm, doanh thu 5113 mất trong khi tiền đã thu vẫn còn. Sau hủy, trạng thái vẫn `DaGhiSo` mà Posted = False → lần lưu sau báo lỗi, chứng từ bị kẹt. | Cao |
| B12 | `Doc/BangKeDoiSoatKenhThanhToan:114-135`; `Doc/YeuCauHoanTienChiHo:98-106` | Không chứng từ nào ghi **Receipt** vào `GiaoDichDienTuTamGiu` (grep chỉ thấy 2 chỗ Expense) → sổ này luôn âm. Không kiểm trùng `MaGiaoDichKenh` → cùng 1 giao dịch đối soát 2 lần, tiền về bị ghi gấp đôi. **Cần xác nhận** chứng từ bán B2C có nằm ngoài phạm vi không. | Cao |
| B13 | `Doc/HoaDonGTGTDauRa:57-59, 69-75` | Chỉ loại `DaHuy`/`DaDieuChinh`; hóa đơn `DuThao`/`ChoKySo` (chưa có mã CQT) và `DaThayThe` vẫn ghi sổ VAT. Không chặn 2 hóa đơn cho cùng 1 biên bản → VAT 33311 bị ghi gấp đôi. | Trung |
| B14 | `Doc/HoaDonGTGTDauRa:98-101`, `Doc/DieuChinhCongNo:87-90`, `Doc/BaoCoNganHang:79-80` so với `Doc/BienBanNghiemThuGiaiDoan:102-115`, `Doc/PhieuThuTienKhachHang:111-127` | Quy tắc chọn TK 1311/1312 không thống nhất (3 bản `LayTaiKhoanCongNoTheoDoiTac` khác nhau). Đối tác `LoaiDoiTac = NoiBoVingroup` nhưng `LaBenLienKet = False` → doanh thu vào 1312, VAT/thu tiền vào 1311 → **1311 âm, 1312 dư ảo**. | Trung |
| B15 | `Doc/BienBanNghiemThuGiaiDoan:130-134`, `Doc/HoaDonGTGTDauRa:105-108`, `Doc/DieuChinhCongNo:96-100`, `Doc/BaoCoNganHang:82, 113`, `Doc/PhieuThuTienKhachHang:46-47, 104` | Chiều `TienTe` trên GL lấy lẫn lộn (USD của hợp đồng / VND / tiền tệ phiếu) trong khi số tiền là VND, tỷ giá = 1 → Nợ 1312[USD] và Có 1312[VND] **không bao giờ triệt tiêu**. Phiếu thu VND mà gõ tỷ giá > 1 sẽ tự sinh ngoại tệ và hạch toán nhầm 1122. | Trung |
| B16 | `Doc/BaoCoNganHang:16-22` | Âm thầm gán mặc định pháp nhân `"PN-VSF"` và tài khoản `"TK-TCB-VND"` (mã cứng), không báo người dùng. Không kiểm trùng `MaGiaoDichNganHang` → một khoản tiền về ghi sổ được 2 lần. | Trung |

## B. Chứng từ Phải trả (AP), Cấn trừ, Ngoại tệ

| STT | File:dòng | Mô tả | Mức độ |
|---|---|---|---|
| B17 | `Doc/HoaDonNhaCungCap:72-78` (BeforeWrite), 173, 240-261 (Posting); `Doc/NghiemThuThauPhu:72, 90, 97-120` | `TienDichVu` chỉ tính khi = 0. Sổ phụ AP ghi `TongTien`, GL Có 331 = `TienChiPhi + TienThueVAT`. Sửa Tổng sau lần lưu đầu → **GL ≠ sổ phụ AP**. Nghiệm thu thầu phụ cũng vậy (`TongGiaTri` nhập tay). | Cao |
| B18 | `Doc/NghiemThuThauPhu:10-26, 28-141`; `Doc/DeNghiThanhToanDichVu:15, 34-42` | Nghiệm thu thầu phụ **ghi tăng công nợ phải trả mà không có trạng thái duyệt/Maker-Checker** → tạo được khoản phải trả giả. Đề nghị thanh toán chỉ chặn khi cả 2 tên có giá trị và giống hệt (phân biệt hoa/thường); không kiểm ngân sách `KeHoachChiTien` như tài liệu mô tả. | Cao |
| B19 | `Doc/HoaDonNhaCungCap:143-150`, `Doc/UyNhiemChi:99-107, 455-474`, `Doc/DanhGiaLaiNgoaiTe:191, 212`, `Doc/CanTruCongNoNoiBo:277-279` | TK công nợ AP và tiền tệ mỗi chứng từ tự xác định một kiểu. VD hóa đơn USD (Có 3313) trả bằng UNC VND → Nợ 3311 → **3311 âm, 3313 treo**, số USD trên sổ phụ còn nguyên → kỳ sau đánh giá lại tạo nợ ảo. Cấn trừ luôn dùng 3312/1312 kể cả đối tác không liên kết. | Cao |
| B20 | `Doc/UyNhiemChi:142-276` (nhánh hoàn trả), đặc biệt dòng 238 | Bút toán hoàn trả UNC ghi sổ phụ với `ChungTuGoc` = **UNC gốc**, trong khi UNC gốc đã giảm nợ theo **hóa đơn** (dòng 502) → công nợ hóa đơn không được khôi phục, sinh số dư mồ côi. Đối tác/tài khoản lấy từ chứng từ hoàn trả, không đối chiếu bản gốc. Kiểm trùng (156-158) không lọc trạng thái. | Cao |
| B21 | `Doc/UyNhiemChi:611-615, 632-640` | Chi từ TK 1122 (USD): phí ngân hàng ghi **Có 1122** trên GL nhưng sổ `DongTien` trừ ở tài khoản VND khác (`TaiKhoanTienPhi` chọn bằng `SELECT TOP 1`, có thể của pháp nhân khác) → GL 1122 lệch sổ phụ, sai tỷ giá bình quân. | Cao |
| B22 | `Doc/CanTruCongNoNoiBo:223-226, 249-251` (Posting) | Khi số dư nhỏ hơn số đề nghị, code **tự hạ `SoTienCanTru`** về bằng số dư. Thay đổi trong Posting không được lưu → chứng từ hiển thị 100tr đã duyệt nhưng sổ chỉ ghi 60tr, không cảnh báo. | Cao |
| B23 | `Doc/CanTruCongNoNoiBo:282-289` (Posting), dòng 284 | Gọi `QuanLyTyGiaVaNgoaiTeServer.LayTyGiaHienHanh` — **hàm này không tồn tại** (module chỉ có `LayTyGiaHachToanHieuLuc`). Lỗi bị `Try` nuốt → mọi dòng GL cấn trừ USD có tỷ giá = 1. Movement AR/AP (257-274) không ghi `SoTienNgoaiTe` → USD không giảm. | Cao |
| B24 | `Doc/DanhGiaLaiNgoaiTe:266-332`; metadata `src/Documents/DanhGiaLaiNgoaiTe.xml:67-71` | Đánh giá lại AR **chỉ ghi GL**, không ghi `CongNoPhaiThu` (không có trong RegisterRecords) → lần đánh giá sau tính lại từ gốc, **ghi lặp lãi/lỗ**. Query AR (dòng 276) không lọc tiền tệ; luôn dùng TK 1312 kể cả khách ngoài. | Cao |
| B25 | `Doc/UyNhiemChi:404-415, 118-127` | Số VND thực chi do người dùng nhập, không đối chiếu `SoTienNgoaiTe × TyGia`. Nhập 1 đồng cho 100.000 USD → ghi lãi tỷ giá 515 khoảng 2,5 tỷ. Chỉ USD mới vào 1122, EUR/JPY rơi về 1121. | Trung |
| B26 | `Doc/DanhGiaLaiNgoaiTe:14-18, 42-49, 65, 359-360` | Không chặn 2 chứng từ đánh giá lại cùng kỳ; `Posting` không kiểm trạng thái (bản nháp vẫn ghi sổ); `NgayChot` có thể sau ngày chứng từ; `TongLai515/TongLo635` gán trong Posting nên không được lưu. | Trung |
| B27 | `Doc/HoaDonNhaCungCap:56-69` (BeforeWrite) | Thuế suất FCT = 0 bị ép thành 5% → không khai được miễn thuế theo hiệp định; bỏ qua `HopDong.GrossUpThue`, `DoiTac.DaDangKyThueTrucTiep` có trong metadata. **Cần xác nhận nghiệp vụ.** | Trung |

## C. Phân quyền, quy trình duyệt, vòng đời chứng từ (Common Modules)

| STT | File:dòng | Mô tả | Mức độ |
|---|---|---|---|
| B28 | `CM/PhanQuyenBaoMatServer:10-51` (`KiemTraMakerChecker`); metadata `NguoiLap/NguoiDuyet` kiểu `xs:string` ở các chứng từ | Maker-Checker chỉ so **2 ô chữ người dùng tự gõ**; không chỗ nào gán `NguoiLap = UserName()` khi tạo. Gõ NguoiLap = "người khác", NguoiDuyet = tên mình → **tự lập tự duyệt** qua được. So sánh dòng 23, 36 phân biệt hoa/thường. Ảnh hưởng mọi chứng từ dùng hàm này. | Cao |
| B29 | `CM/QuanLyVongDoiChungTuServer:237-262` (`KiemTraChuyenTrangThai`), 110, 122-139 | State machine dùng **danh sách cấm**: chỉ chặn sang `DaGhiSo` khi trạng thái cũ là ChoDuyet/DuThao/MoiTao/Draft. Hóa đơn NCC đang "Chờ duyệt PM/CFO" hoặc **"Từ chối"** vẫn ghi sổ thẳng; UNC bỏ qua bước "Đã gửi ngân hàng". So sánh bằng chuỗi hiển thị (`String(enum)`), còn `Metadata().Name` trả tên Enum chứ không phải tên giá trị → kiểm tra luôn sai nếu đổi ngôn ngữ/synonym. | Cao |
| B30 | `CM/PheDuyetDaCapServer` (toàn module, 24-293); `CM/QuyTrinhPheDuyetAPServer:16-101` | **Không có nơi nào gọi** 2 module phê duyệt nhiều cấp (grep toàn `src/`). Ngưỡng 100tr/500tr/2 tỷ, chống chia nhỏ hóa đơn, nhánh CFO **không được áp dụng**; không kiểm vai trò ở từng cấp duyệt. | Cao |
| B31 | `CM/QuanLyVongDoiChungTuServer:164-165, 263`; `CM/PhanQuyenBaoMatServer:130`; `Doc/HoaDonNhaCungCap`, `Doc/UyNhiemChi`, `Doc/CanTruCongNoNoiBo`, `Doc/NghiemThuThauPhu` (không có UndoPosting) | **Hủy ghi sổ không cần quyền**, không kiểm chứng từ phụ thuộc. PM/TechLead hủy được hóa đơn AP đã duyệt; hủy hóa đơn đã thanh toán → AP âm; sau hủy, trạng thái vẫn "Đã ghi sổ" nên sửa số tiền rồi ghi sổ lại không cần duyệt lại. | Cao |
| B32 | `CM/PhanQuyenBaoMatServer:28, 41, 58-60, 143-145` | Cấm Admin ký duyệt chỉ so đúng chữ `"Admin"`; nhưng SoD lại cho bỏ qua toàn bộ nếu có role `QuanTriHeThong`. User tên khác (VD "sysadmin") có role quản trị **vừa vượt SoD vừa duyệt được**. | Cao |
| B33 | `CM/UserProvisioningServer:41-55, 117-150`; `src/CommonModules/UserProvisioningServer.xml` (Privileged + ServerCall); `AppModule:149-155` | Mật khẩu cố định `"Vsf@2026!Secure"` cho cả 9 tài khoản kể cả Admin, ghi mật khẩu ra Event Log; lỗi thì **đặt mật khẩu rỗng** (46-49). Chạy được bằng `/C SetupSampleUsers` với bất kỳ user nào, không kiểm môi trường UAT → **reset được mật khẩu Admin**. | Cao |
| B34 | `AppModule:163-190, 212-238`; `CM/PhanQuyenBaoMatServer` các hàm Export test dòng 167, 345, 537, 593, 622-631, 652, 689, 765, 798, 822, 845-925 | Lệnh test (`RunTask2SecurityTests`…) chạy không qua `KiemTraMoiTruongUAT`; hàm test nằm trong module **Privileged + ServerCall**, **ghi sổ thật và xóa chứng từ** trên CSDL đang dùng. `KiemTraQuyenChungTu` nhận tên user do người gọi truyền vào (giả mạo được). | Cao |
| B35 | `src/Roles/*/Ext/Rights.xml` (cả 9 file, 403 byte, giống hệt nhau) | Không file nào cấp quyền cụ thể cho đối tượng nào (chỉ có `setForNewObjects=true`). Phân quyền nền tảng không phản ánh vai trò; toàn bộ SoD dựa vào code. `KiemTraQuyenBaoCao` (`CM/PhanQuyenBaoMatServer:139-164`) không được gọi ở đâu. **Cần xác nhận** quyền thực tế trong `.dt`. | Cao |
| B36 | `CM/PheDuyetDaCapServer:7-9, 52-97, 247-251, 272-274, 300-309, 348`; `src/CommonModules/PheDuyetDaCapServer.xml` (ReturnValuesReuse = DuringSession); `CM/QuyTrinhPheDuyetAPServer:53-63, 96-101` | (Khi nối 2 module này vào) còn nhiều lỗ: kết quả bị **cache suốt phiên** nên lũy kế cũ; `DangKyHoaDon` không lưu `ThoiDiem` → dòng 348 lỗi "field not found"; chỉ đếm hóa đơn đã ghi sổ, lỗi query thì lũy kế = 0; bỏ nhánh CFO khi cấp là Tổng GĐ; `KiemTraQuyenDuyet` không kiểm vai trò theo cấp. | Trung |
| B37 | `CM/PhanQuyenBaoMatServer:81-98` (`KiemTraQuyenChungTu`) | SoD không xếp `DanhGiaLaiNgoaiTe` vào nhóm nào → kế toán AR/AP/đối soát đều ghi sổ được đánh giá lại tỷ giá. Chứng từ mới mặc định không bị kiểm soát (dùng danh sách cấm thay vì danh sách cho phép). | Trung |
| B38 | `CM/QuanLyVongDoiChungTuServer:410, 447-501, 534-670` (`KiemTraDoiSoatDocLapGLVaSoPhu`) | Đối soát GL với sổ phụ có điểm mù: `AccountDr IS NULL` không bao giờ đúng; `Balance(&ThoiDiem)` không gồm phát sinh đúng thời điểm trong khi GL lấy `<=`; LEFT JOIN từ sổ phụ nên bút toán GL không có sổ phụ bị bỏ qua. | Trung |
| B39 | `CM/QuanLyVongDoiChungTuServer:346-397` (`KiemTraCanDoiSoCai`) | Hàm "kiểm tra cân đối" nhận cặp Nợ = Có do chính chứng từ tự dựng → **không bao giờ phát hiện lệch** giữa GL và sổ phụ. Tạo cảm giác an toàn giả. | Trung |
| B40 | `CM/QuanLyTyGiaVaNgoaiTeServer:36-67, 102-111, 135-161` | Query số dư lỗi thì âm thầm dùng tỷ giá khác; chấp nhận tỷ giá cũ bao lâu cũng được; tỷ giá Undefined → quy đổi ra 0 không báo lỗi; làm tròn 2 số lẻ cho VND (nơi khác làm tròn 0) → xuất hết ngoại tệ vẫn còn dư VND trên 1122. | Trung |

## D. Báo cáo, Dashboard, Data Processor

| STT | File:dòng | Mô tả | Mức độ |
|---|---|---|---|
| B41 | `DP/NapSoDuDauKy:12-31` | 3 hàm "nạp số dư đầu kỳ" **chỉ ghi Event Log**, không ghi sổ nào, không có form, không ai gọi. Hệ thống không có cơ chế nạp số dư đầu kỳ dù tài liệu ghi Task 8.1 "DONE". | Cao |
| B42 | `src/Reports/*.xml:28-33` (DCS, form rỗng); `Rep/BaoCaoTuoiNoPhanTachNoiBo:109-124`, `Rep/CanhBaoHanMucVaGiaHanCloud:39-54`, `Rep/DoiSoatKenhThanhToanVaDongTienAo:24-39`, `Rep/MaTranCanTruNoiBoTapDoan:34-49` | 4 báo cáo **không có sơ đồ DCS, không có form**, không có tham số kỳ; kết quả chỉ in tiêu đề + **1 dòng tổng** (dữ liệu chi tiết đã tính nhưng không in). **Cần xác nhận** báo cáo có nút "Tạo báo cáo" khi chạy không. | Cao |
| B43 | `CM/BaoCaoQuanTriServer:488-493, 530-547, 551-569, 586` (`TinhBaoCaoCanhBaoCloud`) | Quota và số ngày còn hạn là **số bịa**: hard-code theo mã `TEST_NCC_*`, số ngày = `35 + (thứ tự × 7) % 60`; query cộng mọi hóa đơn USD từ trước tới nay, không lọc kỳ/loại cloud; ngưỡng Đỏ cứng 98 trong khi có hằng số `CanhBaoCloudMucDo`. | Cao |
| B44 | `CM/BaoCaoQuanTriServer:330-333, 434-435, 789-840`; `Rep/MaTranCanTruNoiBoTapDoan:47`; `Rep/DoiSoatKenhThanhToanVaDongTienAo:37` | "Delta đối soát" tự so với chính nó (giảm AR = giảm AP = tổng cấn trừ; trial balance đưa cùng số vào Nợ và Có) → **luôn = 0**. Báo cáo in cứng chữ "(DELTA = 0)". Kiểm soát giả. | Trung |
| B45 | `CM/BaoCaoQuanTriServer:60, 83, 164, 256, 381, 454, 501, 514-524, 647`; `DP/DashboardLanhDaoCFO:19` | Ngày chốt cứng `Date(2026,9,30,23,59,59)` → hôm nay 15/10/2026 mọi phát sinh tháng 10 **bị bỏ qua**. `Date <= &DenNgay` thiếu EndOfDay; `Balance(&NgayChot)` không gồm thời điểm chốt (dashboard thì gồm → 2 nơi lệch số); tỷ giá lấy TOP 1 không lọc `Period <= ngày báo cáo` → có thể dùng tỷ giá tương lai. | Trung |
| B46 | `DP/DashboardLanhDaoCFO:185-197, 212-224, 282-343, 532-545` | DSO/DPO so lệch cơ sở (AR gồm VAT, doanh thu chưa VAT; doanh thu bỏ sót hóa đơn xuất thẳng; chi phí bỏ sót nghiệm thu thầu phụ). Phân khối kinh doanh theo mã `TEST_VG_*`/`TEST_NCC_*` → đối tác thật dồn hết vào "Khối BO". | Trung |
| B47 | `DP/DashboardLanhDaoCFO:590-591, 609-612`; `CM/BaoCaoQuanTriServer:1010, 1014, 1036, 1064, 1079` | KPI và nhãn **hard-code**: tỷ lệ tiết kiệm 35,5%, tiết kiệm 18,2 tỷ, "Cân đối Sổ Cái: 100%", "Dương an toàn" kể cả khi vốn lưu động âm, "ĐÃ DUYỆT". Dashboard cho lãnh đạo hiện trạng thái "xanh" giả. | Trung |
| B48 | `CM/BaoCaoQuanTriServer:91-103, 136-149, 172-184` (`TinhBaoCaoTuoiNo`) | Tuổi nợ đọc `Row.ChungTuGoc.Date` trong vòng lặp (mỗi dòng 1 lần đọc DB); dùng ngày nhập chứng từ thay ngày hóa đơn; `HAVING SUM > 0` loại dòng âm nên tổng tuổi nợ ≠ GL 131; đếm "số đối tác nội bộ" theo số chứng từ. | Trung |
| B49 | `AppModule:262`; `CM/BaoCaoQuanTriServer:779-782` | Lệnh `/C ExportTrialBalanceEvidence` gọi hàm **không truyền đường dẫn**, hàm `Raise` khi đường dẫn rỗng → lệnh luôn thất bại. | Trung |
| B50 | `CM/BaoCaoQuanTriServer:655-691, 721-722, 774` (`XuatDuLieuVaKiemTraBaoCao`) | Báo `"EXECUTIVE_REPORTS_SUCCESS_100"` kể cả khi từng báo cáo lỗi; đường dẫn cứng `C:\Users\Dung\...`; module ServerCall cho client ghi file tại đường dẫn tùy ý, file JSON chứa chuỗi kết nối CSDL. | Trung |
| B51 | `DP/DongCoDoiSoatTuDong:11-59` | Động cơ đối soát **không được gọi ở đâu**. Nếu gọi: nhận tiền = 0 vẫn "Đã đối soát" khi hóa đơn ≤ 1.000đ; "treo" vào chính 1311/1312 thay vì TK treo; tham số `LaBenLienKet` mặc định ngược nhau giữa Tầng 2 và Tầng 3. | Trung |

## E. Cấu hình, công cụ test, khác

| STT | File:dòng | Mô tả | Mức độ |
|---|---|---|---|
| B52 | `AppModule:193, 200, 207` | 3 lệnh `RunTask3/4/5` gọi hàm không tồn tại trong `QuanLyTyGiaVaNgoaiTeServer` → luôn ghi "Fatal". | Thấp |
| B53 | `AppModule:246-266` | Nhánh `VerifyGLAnalyticKeys`/`RunPostingLifecycleTests`/`ExportTrialBalanceEvidence` phía dưới không bao giờ chạy vì đã bị bắt ở dòng 43 (code chết). | Thấp |
| B54 | `CM/QuanLyVongDoiChungTuServer:1006` | `RollbackTransaction` được gọi trước `BeginTransaction` → có thể hủy transaction của hàm gọi. | Thấp |
| B55 | `CM/PhanQuyenBaoMatServer:697, 720, 768, 776, 827, 848` | Test bảo mật đếm **mọi exception** là "bị chặn" → PASS giả (kể cả lỗi thiếu dữ liệu, số chứng từ dài hơn 20 ký tự bị trùng). | Thấp |
| B56 | `CM/QuanLyVongDoiChungTuServer:17-28` (`KiemTraChoPhepSinhDuLieuMau`); `CM/ConcurrencyTestsServer:14-18` | Cổng chặn sinh dữ liệu mẫu chỉ dò chuỗi `/scratch/uat/` trong connection string → đặt tên thư mục production chứa chuỗi đó là qua; `ConcurrencyTestsServer` chỉ cần chứa chữ "clone" hoặc "uat". | Thấp |
| B57 | `CM/QuanLyVongDoiChungTuServer:7-13, 287-306` | `GhiNhatKyInfo/Error` là ServerCall → client ghi log giả được; `LayTaiKhoanTheoMaLogic` nuốt lỗi query, trả struct thiếu `Ref` → nơi gọi crash về sau. | Thấp |
| B58 | `DP/LapMaTranCanTruTapDoan:13-37` | Watchdog timeout chỉ sửa mảng trong bộ nhớ, không ghi chứng từ, không có job chạy; timeout cứng 120 phút trong khi hằng `TimeoutChoCanTruPhut` = 60; `Min(AR, AP)` với số âm ra số cấn trừ âm. | Thấp |
| B59 | `src/Subsystems/*.xml` (không chứa `Document.DanhGiaLaiNgoaiTe`); `src/DataProcessors/{DongCoDoiSoatTuDong,LapMaTranCanTruTapDoan,NapSoDuDauKy}.xml` (không có form) | Chứng từ Đánh giá lại ngoại tệ không có trong menu nào; 3 data processor có trong menu nhưng không có form → bấm vào không làm được gì. | Thấp |
| B60 | `src/Catalogs/TaiKhoanAo/Ext/ObjectModule.bsl:7-31` | Kiểm trùng số tài khoản ảo không khóa (2 phiên ghi song song đều qua), không TrimAll, bị bỏ qua khi DataExchange.Load. | Thấp |
| B61 | `Doc/HoaDonNhaCungCap:36-41, 50-52` | Tiền tệ trống mà có số ngoại tệ → tỷ giá = 1 → `TongTien` VND = số USD. | Thấp |
| B62 | `Doc/BangKeDoiSoatKenhThanhToan:44-49, 126-135`; `Doc/YeuCauHoanTienChiHo:58-60` | Code chết (nhánh không có dòng chi tiết không bao giờ tới); yêu cầu hoàn tiền chưa duyệt vẫn cho Posted = True mà không có movement. | Thấp |
| B63 | `Doc/DeNghiThanhToanDichVu` + `src/Documents/DeNghiThanhToanDichVu.xml` | Bật Posting nhưng không ghi sổ nào; "ghi sổ" chỉ để kiểm trạng thái → gây hiểu nhầm. | Thấp |

## F. Module sinh dữ liệu mẫu (seed/generator) và scripts

| STT | File:dòng | Mô tả | Mức độ |
|---|---|---|---|
| B65 | `CM/SeedFullTestDataServer:208-478` (`BackfillSoCaiAnalyticKeysServer`), đặc biệt 224-229, 309, 394-452, 470-471 | Hàm "bổ sung khóa phân tích" ghi đè sổ cái đã ghi bằng `DataExchange.Load = True`, **không có transaction** (lỗi giữa chừng → GL sửa một nửa). Thiếu khóa thì **tự gán đối tác/hợp đồng mặc định** (`TEST_DT_01`, `DT-ONEPAY`, `NCC-AWS` — không được tạo ở đâu trong `src/`), ưu tiên "hợp đồng đầu tiên của đối tác" trước hợp đồng trên chứng từ. → Kết quả "8.681/8.681 PASS" có thể đến từ khóa bịa; trái README dòng 130 ("Không … backfill"). | Cao |
| B66 | `scripts/import_dt.ps1:2, 7-8, 18-25` | Script mà `HUONG_DAN_SU_DUNG_FILE_DT.md:108` hướng dẫn dùng lại **restore đè thẳng vào `C:\Users\Dung\Documents\1C_Enterprise\Infobase`** (infobase chính), không hỏi xác nhận, không kiểm clone; đường dẫn exe/infobase cứng; luôn thoát mã 0. Máy khác → lỗi; máy Dũng → mất dữ liệu infobase chính. | Cao |
| B67 | `CM/SeedDataCleanServer:290-300` | Tạo user `Admin` với **mật khẩu rỗng** và gán **toàn bộ** vai trò trong cấu hình (`For Each R In Metadata.Roles`). Module này Privileged + ServerCall. | Cao |
| B68 | `CM/GeneratorNettingReconcileServer:656-698` (`LayMapChungTuGocAR/AP`) | Query cột `KhachHang` (Biên bản) và `NhaCungCap` (Hóa đơn NCC) **không tồn tại** (tên đúng `DoiTac`); lỗi bị `Except EndTry` nuốt (673, 695) → map rỗng → chứng từ cấn trừ sinh ra thiếu chứng từ gốc và bị chặn khi ghi sổ (`Doc/CanTruCongNoNoiBo:64-68`). | Trung |
| B69 | `CM/SeedDataCleanServer:264, 274` | Gán hằng `PhapNhanMacDinh`, `TaiKhoanTrungGianCanTru` bằng **chuỗi** ("PN-VSF", "1388") trong khi kiểu là tham chiếu → hằng rỗng hoặc lỗi; khối Try nuốt lỗi nhưng log vẫn ghi "thành công 12 hằng số". | Trung |
| B70 | `CM/GeneratorMasterDataServer:326`; `CM/GeneratorAPServer:211-219` | `IsUSD = Left(CodeDT, 9) = "TEST_NCC_"` gồm cả NCC trong nước `TEST_NCC_VN_*` → hợp đồng USD nhưng hóa đơn VND → lệch tiền tệ, sai đánh giá lại. | Trung |
| B71 | `CM/HardeningTestsServer:2-36, 49-121, 260` | Test an toàn seed không kiểm cờ đang False trước khi gọi 6 generator (cờ True → chạy thật); `KiemThuTrangThai` sửa chứng từ đã ghi sổ và import chứng từ không có transaction, không dọn; `Constants.ChoPhepSinhDuLieuMau.Set(True)` ngoài transaction → process bị kill thì cờ kẹt ở True. | Trung |
| B72 | `CM/GeneratorMasterDataServer:351-368`; `CM/SeedDataCleanServer:99-112` | Ghi tỷ giá mẫu bằng `Write(True)` sau khi lọc USD → **xóa toàn bộ tỷ giá USD đang có**; seed sạch ghi đè tỷ giá hôm nay bằng 25.400/27.500. Nguy hiểm nếu cổng seed bị vượt (B56). | Trung |
| B73 | `scripts/setup_sample_users.ps1:2, 19-21, 36-44`; `scripts/test_single_login.ps1:2, 17, 25-35` | Mặc định trỏ vào `Infobase_FullData` (bản phát hành) → reset user/mật khẩu của chính bản phát hành; gửi phím ENTER 20-30 lần bằng `SendKeys`, nếu cửa sổ 1C không được focus thì phím đi vào cửa sổ khác. | Trung |
| B74 | `CM/GeneratorARServer:148-149`; `CM/GeneratorAPServer:283-284`; `CM/GeneratorNettingReconcileServer:341-342, 478-479` | Generator gán `NguoiDuyet = "CFO"` nhưng không có user tên "CFO" (user thật là `cfo_giamdoc`) và Maker-Checker đòi phiên = người duyệt → chứng từ sinh ra **không ghi sổ lại được** bởi user thật. **Cần xác nhận** trên runtime. | Trung |
| B75 | `scripts/export_dt.ps1:2, 7-8`; `package_fulldata_release.ps1:1-4`; `run_export_reports.ps1:8-10`; `run_verify_full_data.ps1:13-15`; `verify_dt_restore.ps1:1-4`; `generate_vsf_assets.py:20`; `rebuild_and_export_dt.py:10`; `CM/UserProvisioningServer:161`; `CM/BaoCaoQuanTriServer:690-691` | Đường dẫn cứng `C:\Users\Dung\...` → hỏng trên mọi máy khác; `export_dt.ps1` dump đè `.dt` phát hành không hỏi. | Thấp |

## G. Tài liệu mâu thuẫn với code

| STT | File:dòng | Mô tả | Mức độ |
|---|---|---|---|
| B64 | `.superpowers/sdd/2026-10-10-vinsmart-future-ar-ap/progress.md` (mục Task 5.1, 7.1-7.3); `README.md:3` so với `docs/ERP_AUDIT_2026-10-14_FINAL_100.md:25`; `HUONG_DAN_SU_DUNG_FILE_DT.md:11` so với mục 2-3 | progress.md ghi "DONE" HTTPService webhook, `TichHopNganHangServer`, `TichHopHoaDonDienTuServer`, `DongBoButToanSAP`, scheduled job tỷ giá — **không có trong `src/`**. README ghi GL keys FAIL 8.215/8.579, audit ghi PASS 8.681/8.681 (chính audit dòng 93 lại ghi FAIL). Hướng dẫn `.dt` vừa ghi 6.473 vừa ghi 43 chứng từ, mật khẩu `123` trong khi code đặt `Vsf@2026!Secure`, link `file:///C:/Users/Dung/...` hỏng trên máy khác. Mentor hỏi sẽ không trả lời được. | Trung |

---

## Ghi chú

- Mỗi bug có cách sửa và cách kiểm tra ở `03_PLAN_SPEC_FIX.md`, kịch bản test thủ công ở `04_KICH_BAN_TEST.md`.
- Các bug đánh "Cần xác nhận" (B12, B27, B35, B42) cần mở `.dt` trên 1C để kiểm tra trước khi sửa.
- Những lỗi đã được xác minh lại trực tiếp bằng cách đọc code lần 2: B01, B02, B03, B09, B11, B20, B23, B28, B29, B30, B33, B35, B41, B43, B45, B49, B66, B67, B68.
- Kiểm tra tĩnh đã chạy (chỉ đọc): `python -B scripts/verify_bsl_syntax.py` → 44 file BSL, 0 lỗi token; `python -B -m unittest discover -s scripts -p test_audit_tools.py` → 24 OK. Đây là kiểm tra heuristic, không thay thế Designer /CheckConfig.
