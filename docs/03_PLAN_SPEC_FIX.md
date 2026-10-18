# 03 — PLAN SPEC SỬA LỖI

> Đi kèm `02_BUG.md` (mã bug B01…). Phần cuối (mục 6) bổ sung các mục cần sửa thêm từ **1c mentor** (`1C-Mentor-Skill-Gemini/`) và **lessons** (`Lessons/`, `Bài thực hành/`).
> Ký hiệu đường dẫn giống `02_BUG.md`: `Doc/X` = `src/Documents/X/Ext/ObjectModule.bsl`, `CM/X` = `src/CommonModules/X/Ext/Module.bsl`.

## 1. Nguyên tắc chung khi sửa

1. **Mỗi lần sửa:** tạo clone UAT mới → sửa → Designer bấm F7 (*Check configuration*, kiểm cú pháp toàn cấu hình) → chạy ca test tương ứng trong `04_KICH_BAN_TEST.md` → dump `.dt` mới.
2. **Không đổi `Name` của đối tượng metadata** đã có dữ liệu (chỉ đổi Synonym = tên hiển thị) — đổi Name làm gãy dữ liệu trong `.dt` (lời khuyên trong `btl-1-de-bai-y-tuong.md` §3).
3. **Viết hàm dùng chung một lần** trong Common Module rồi cho các chứng từ gọi, thay vì sửa 3-5 bản copy.
4. Trong `Posting`: lỗi nghiệp vụ → `Cancel = True` + `UserMessage` có `Field` (ô bị lỗi); không để `Except` trống.
5. Ghi lại mỗi quyết định vào một "nhật ký quyết định" (mentor yêu cầu, `mis-erp-practice.md` §tu-xay-dung-he-thong) để trả lời khi bảo vệ.

## 2. Thứ tự làm (6 đợt)

| Đợt | Mục tiêu | Bug | Lý do làm trước |
|---|---|---|---|
| 1 | Chặn vượt kiểm soát & bảo mật | B28, B29, B30, B31, B32, B33, B34, B35, B08, B10, B18, B37, B65, B66, B67 | Mentor sẽ thử đăng nhập từng vai trò; lỗi bảo mật là lỗi nặng nhất khi bảo vệ. |
| 2 | Sổ phụ khớp sổ cái | B01, B02, B03, B05, B17, B39, B09, B21 | Sai số liệu kế toán; ảnh hưởng mọi báo cáo phía sau. |
| 3 | Tham chiếu & số dư đúng khóa | B04, B06, B07, B11, B12, B13, B14, B16, B19, B20, B22 | Tránh công nợ âm, công nợ không thu được. |
| 4 | Ngoại tệ | B15, B23, B24, B25, B26, B27, B40, B61 | Phụ thuộc đợt 2-3. |
| 5 | Báo cáo, dashboard, nạp số dư | B41, B42, B43, B44, B45, B46, B47, B48, B49, B50, B51, B38 | Cần số liệu đúng từ đợt 2-4 mới kiểm được. |
| 6 | Dọn dẹp, công cụ seed/scripts, tài liệu | B36, B52-B60, B62-B64, B68-B75 | Không ảnh hưởng người dùng cuối nhưng ảnh hưởng dữ liệu demo và độ tin cậy tài liệu. |

## 3. Hàm dùng chung cần viết trước (dùng cho nhiều bug)

| Hàm (đề xuất đặt trong `CM/QuanLyVongDoiChungTuServer`) | Làm gì | Dùng cho |
|---|---|---|
| `GanNguoiLapKhiTaoMoi(DocObject)` | Gọi trong `BeforeWrite` khi `IsNew()`: `NguoiLap = UserName()`; nếu không mới thì so với giá trị đã lưu trong CSDL, khác thì báo lỗi. | B28, B08, B10, B18 |
| `KiemTraChuyenTrangThaiHopLe(TrangThaiCu, TrangThaiMoi, LoaiChungTu)` | Bảng **danh sách cho phép** (whitelist) các cặp chuyển trạng thái, so bằng giá trị Enum (`Enums.TrangThaiHoaDonAP.DaGhiSo`), mỗi bước gắn vai trò bắt buộc (`IsInRole`). | B29, B30, B31 |
| `LayTaiKhoanCongNo(DoiTac, LoaiCongNo, TienTe)` | Một quy tắc duy nhất chọn 1311/1312/3311/3312/3313. | B14, B19, B24 |
| `KiemTraSoDuVaKhoa(Register, KhoaPhanTich, SoTien)` | DataLock theo đủ chiều + đọc số dư + báo lỗi nếu không đủ. Đã có mẫu `LaySoDuARTheoChungTu` (dòng 36-48) — mở rộng cho AP, tạm giữ. | B04, B07, B12, B22 |
| `KiemTraKhongCoChungTuPhuThuoc(Ref)` | Query sổ phụ: có movement của chứng từ khác với `ChungTuGoc = Ref` thì chặn hủy ghi sổ. | B11, B31 |
| `KiemTraKhopGLVaSoPhu(RegisterRecords)` | Sau khi tạo movement trong `Posting`: tổng GL Nợ 131/331 phải = tổng Receipt sổ phụ; lệch thì `Cancel`. Thay cho `KiemTraCanDoiSoCai` hiện tại. | B02, B05, B17, B39 |

## 4. Kế hoạch sửa từng bug

### Đợt 1 — Kiểm soát & bảo mật

| Bug | Cách sửa | File cần đổi | Kiểm tra đã sửa xong |
|---|---|---|---|
| B28 | Gọi `GanNguoiLapKhiTaoMoi` trong BeforeWrite của mọi chứng từ có NguoiLap; khóa ô NguoiLap trên form; `NguoiDuyet` do server gán khi bấm duyệt. So sánh không phân biệt hoa/thường (`Upper(TrimAll())`). Dài hạn: đổi kiểu sang tham chiếu người dùng. | `CM/PhanQuyenBaoMatServer` (10-51), `CM/QuanLyVongDoiChungTuServer`, BeforeWrite của BienBan, HoaDonGTGT, BaoCo, BangKe, HoaDonNCC, UyNhiemChi, CanTru, DanhGiaLai | TC-SEC-01: user A gõ NguoiLap = "B" → khi lưu, NguoiLap tự thành "A"; A không ghi sổ được. |
| B29 | Thay khối dòng 253-259 bằng `KiemTraChuyenTrangThaiHopLe` (whitelist, so Enum). Bỏ so sánh bằng `String(enum)` và `Metadata().Name` (dòng 110, 122-139). Thêm kiểm trạng thái vào `DanhGiaLaiNgoaiTe.Posting` (42-49). | `CM/QuanLyVongDoiChungTuServer`, `Doc/DanhGiaLaiNgoaiTe` | TC-SEC-02: hóa đơn NCC ở "Chờ duyệt PM" hoặc "Từ chối" → đổi sang Đã ghi sổ → bị chặn. UNC từ "Đã duyệt" lên "Đã ghi sổ" (bỏ qua "Đã gửi NH") → bị chặn. |
| B30 | Nối `PheDuyetDaCapServer.LayDanhSachCapPheDuyetHoaDon` và `QuyTrinhPheDuyetAPServer.XacDinhTrangThaiTiepTheo` vào BeforeWrite của `HoaDonNhaCungCap`; mỗi bước kiểm vai trò (TechLead → PM → ITDirector → CFO → KeToanPhaiTra). Sửa luôn B36 khi nối. | `Doc/HoaDonNhaCungCap`, 2 module trên | TC-AP-03: hóa đơn 600tr phải qua đủ cấp; user sai vai trò bấm duyệt → bị chặn. |
| B31 | Thêm `UndoPosting` cho HoaDonNCC, UNC, CanTru, NghiemThu, BienBan: (1) kiểm quyền (chỉ KeToanTruong/CFO), (2) `KiemTraKhongCoChungTuPhuThuoc`, (3) đưa trạng thái về "Chờ duyệt" trong cùng transaction. Thêm thao tác `"HuyGhiSo"` vào `PhanQuyenBaoMatServer` dòng 130. | Các ObjectModule trên, `CM/PhanQuyenBaoMatServer`, `CM/QuanLyVongDoiChungTuServer:164-165, 263` | TC-SEC-04: `pm_duan` hủy ghi sổ hóa đơn → bị chặn. Hủy hóa đơn đã có UNC → bị chặn kèm tên UNC. |
| B32 | Chặn ký duyệt theo vai trò `QuanTriHeThong`, không theo tên "Admin". Bỏ `Return` sớm cho Admin trong SoD đối với thao tác tài chính. | `CM/PhanQuyenBaoMatServer:28, 41, 58-60, 143-145` | TC-SEC-05: user "sysadmin" có role quản trị → không ghi sổ được hóa đơn. |
| B33 | Bỏ cờ Privileged + ServerCall; đầu hàm kiểm `KiemTraMoiTruongUAT` + `IsInRole("QuanTriHeThong")`; bỏ mật khẩu khỏi code (nhận tham số hoặc sinh ngẫu nhiên); **không fallback mật khẩu rỗng**; không reset user đã tồn tại; không log mật khẩu. | `CM/UserProvisioningServer`, `src/CommonModules/UserProvisioningServer.xml`, `AppModule:149-155` | TC-SEC-06: đăng nhập `ketoan_ar` với `/C SetupSampleUsers` → không đổi được mật khẩu Admin; Event Log không có mật khẩu. |
| B34 | Ở đầu `OnStart`: mọi `Cmd` khác rỗng phải qua `HardeningTestsServer.KiemTraMoiTruongUAT()` + kiểm vai trò. Tách hàm test khỏi `PhanQuyenBaoMatServer` sang module test riêng không Privileged, không ServerCall. `KiemTraQuyenChungTu` bỏ tham số tên user, luôn dùng `UserName()`. | `AppModule`, `CM/PhanQuyenBaoMatServer` (+ `.xml`) | TC-SEC-07: chạy `/C RunTask2SecurityTests` trên CSDL không phải clone → bị từ chối, không sinh chứng từ "T2-%". |
| B35 | Lập ma trận quyền vai trò × đối tượng (mục 6, M09); khai báo quyền trong Designer cho 9 role (Read/Insert/Update/Posting/UndoPosting theo phân hệ; sổ chỉ Read; View cho phân hệ); chỉ `QuanTriHeThong` để `setForNewObjects`. Gọi `KiemTraQuyenBaoCao` trong báo cáo nhạy cảm. | `src/Roles/*/Ext/Rights.xml` (sửa qua Designer), `Rep/*` | TC-SEC-08: lần lượt đăng nhập 8 user nghiệp vụ, mỗi user chỉ thấy phân hệ của mình. |
| B08 | Gọi `KiemTraMakerChecker` + `KiemTraQuyenChungTu(..., "GhiSo")` trong Posting; đổi `TrangThai` sang Enum `TrangThaiLenhThanhToan`; chưa duyệt thì `Cancel = True`. | `Doc/YeuCauHoanTienChiHo`, metadata `.xml` | TC-BANK-04: tự gõ "DaDuyet", người duyệt trống → không ghi sổ được. |
| B10 | Thêm thuộc tính NguoiLap/NguoiDuyet/TrangThai cho Phiếu thu, Điều chỉnh công nợ; Posting gọi `KiemTraMakerChecker`; Điều chỉnh phải qua trạng thái "Đã duyệt nội bộ". | `Doc/PhieuThuTienKhachHang`, `Doc/DieuChinhCongNo`, 2 file `.xml` | TC-AR-07: `ketoan_ar` tự tạo và ghi sổ Điều chỉnh 50tr → bị chặn. |
| B18 | NghiemThuThauPhu: dùng `KiemTraTrangThaiVaQuyen`, chỉ ghi sổ ở trạng thái đã duyệt, thêm NguoiLap/NguoiDuyet. DeNghiThanhToan: dùng `KiemTraMakerChecker` (bắt buộc cả 2 trường), đọc `KeHoachChiTien` để kiểm ngân sách, `SoTienDeNghi > 0`. | `Doc/NghiemThuThauPhu`, `Doc/DeNghiThanhToanDichVu`, 2 `.xml` | TC-AP-05: nghiệm thu ở Dự thảo → không ghi sổ được. |
| B37 | Đổi `KiemTraQuyenChungTu` sang danh sách cho phép: vai trò → loại chứng từ; loại chưa khai báo thì chặn. Gán DanhGiaLaiNgoaiTe cho KeToanTruong. | `CM/PhanQuyenBaoMatServer:81-98` | TC-SEC-09: `ketoan_ar` ghi sổ Đánh giá lại → bị chặn. |
| B65 | Bỏ toàn bộ khóa mặc định (`TEST_DT_01`, `DT-ONEPAY`, `NCC-AWS`, "hợp đồng đầu tiên"); ưu tiên hợp đồng ghi trên chứng từ; mỗi chứng từ bọc trong transaction; dòng không suy ra được thì **xuất danh sách** cho kế toán xử lý, không tự điền. Ghi lại kết quả GL keys thật vào README. | `CM/SeedFullTestDataServer:208-478` | Chạy trên clone có dòng thiếu khóa → không dòng nào bị gán đối tác mặc định; danh sách thiếu được xuất ra. |
| B66 | Bắt buộc tham số `-IBPath` (không mặc định), từ chối `Infobase`/`Infobase_FullData`, hỏi xác nhận, trả đúng `$p.ExitCode`; hoặc thay bằng `create_uat_clone.py`. Sửa `HUONG_DAN_SU_DUNG_FILE_DT.md:108` cho khớp. | `scripts/import_dt.ps1`, `HUONG_DAN_SU_DUNG_FILE_DT.md` | Chạy không có `-IBPath` → báo lỗi, không động vào infobase nào. |
| B67 | Admin tạo mới chỉ nhận role `QuanTriHeThong`, mật khẩu do người chạy nhập; bỏ Privileged/ServerCall của module seed (xem M10). | `CM/SeedDataCleanServer:290-300` + `.xml` | Sau seed trên clone: Admin có đúng 1 role, có mật khẩu. |

### Đợt 2 — Sổ phụ khớp sổ cái

| Bug | Cách sửa | File cần đổi | Kiểm tra đã sửa xong |
|---|---|---|---|
| B01 | Chuyển 2 dòng `RegisterRecords.CongNoPhaiThu.Write = True; RegisterRecords.SoCaiKeToan.Write = True;` (82-83) lên **ngay sau** `Clear()` (64-65). Tốt hơn: hóa đơn DaHuy/DaThayThe thì yêu cầu hủy ghi sổ (`Cancel = True` + thông báo). | `Doc/HoaDonGTGTDauRa` | TC-AR-03: ghi sổ hóa đơn, đổi sang Đã hủy, ghi sổ lại → *Document register records* trống. |
| B02 | BeforeWrite luôn tính lại VAT và Tổng (bỏ điều kiện "= 0"); Posting kiểm `TongTienThanhToan = TienChuaThue + TienThueVAT`, sai thì Cancel. | `Doc/HoaDonGTGTDauRa:47-54` | TC-AR-04: lưu VAT 0, sửa 10%, ghi sổ → AR = GL 131 = 110tr. |
| B03 | Bỏ `Try…Except EndTry` trống; thay bằng `KiemTraKhopGLVaSoPhu` + `Cancel = True`. Chứng từ số tiền 0 → không tạo movement, báo lỗi. | `Doc/HoaDonGTGTDauRa:193-205`, `Doc/DieuChinhCongNo:169-177`, `Doc/NghiemThuThauPhu:135-140`, `Doc/HoaDonNhaCungCap:274-285` | TC-AR-05: hóa đơn có biên bản, VAT 0% → không ghi sổ, có thông báo. |
| B05 | Posting kiểm `GiamDoanhThu > 0`, `GiamThueVAT >= 0`, tổng = `TongTienGiam`; đưa phần tính toán vào Posting để luồng `DataExchange.Load` không bỏ qua. | `Doc/DieuChinhCongNo` | TC-AR-08: nhập 20tr = 15tr + 1tr → bị chặn. |
| B17 | BeforeWrite luôn tính `TienDichVu = TongTien − TienThueVAT`; Posting kiểm `TienDichVu + TienThueVAT = TongTien` (và `GiaTriNghiemThu + TienVAT = TongGiaTri`); sổ phụ ghi đúng tổng Có 331 của GL. | `Doc/HoaDonNhaCungCap`, `Doc/NghiemThuThauPhu` | TC-AP-02: sửa Tổng sau lần lưu đầu → GL Có 331 = sổ phụ AP. |
| B39 | Thay `KiemTraCanDoiSoCai` bằng `KiemTraKhopGLVaSoPhu` đọc thẳng từ `RegisterRecords`. | `CM/QuanLyVongDoiChungTuServer:346-397` | Chạy lại TC-AR-04, TC-AP-02 với dữ liệu cố tình lệch → bị chặn. |
| B09 | Thống nhất nghiệp vụ hoàn tiền: nếu giảm tạm giữ thì GL ghi **Có 1388**; nếu là chi hộ thì sổ tạm giữ ghi Receipt. Chặn `PhiHoanTien < 0`. Hỏi kế toán trưởng/giảng viên để chốt (ghi vào nhật ký quyết định). | `Doc/YeuCauHoanTienChiHo:99-106, 129-133` | TC-BANK-05: hoàn 5tr → số dư 1388 trên GL = số dư sổ tạm giữ. |
| B21 | Phí ngân hàng luôn ghi Có 1121 VND; thêm thuộc tính "Tài khoản thu phí" trên UNC thay cho `SELECT TOP 1`. | `Doc/UyNhiemChi:611-615, 632-640`, `src/Documents/UyNhiemChi.xml` | TC-AP-08: UNC 1.000 USD từ TK USD, phí 50.000đ → GL 1122 = sổ DongTien TK USD. |

### Đợt 3 — Tham chiếu và số dư

| Bug | Cách sửa | File cần đổi | Kiểm tra đã sửa xong |
|---|---|---|---|
| B04 | Gọi `LaySoDuARTheoChungTu(PhapNhan, DoiTac, BienBanNghiemThu, , Ref)` (đã có khóa), chặn khi `TongTienGiam > SoDu`; kiểm biên bản đã ghi sổ, cùng Đối tác/Hợp đồng. | `Doc/DieuChinhCongNo:117-126` | TC-AR-09: biên bản đã thu đủ → điều chỉnh 20tr bị chặn. |
| B06 | Mở rộng kiểu `ChungTuGoc` (Phiếu thu, Điều chỉnh) và `ChungTuKhop` (Báo có) thành kiểu tổng hợp: Biên bản **hoặc** Hóa đơn GTGT. | `src/Documents/PhieuThuTienKhachHang.xml`, `BaoCoNganHang.xml`, `DieuChinhCongNo.xml` | TC-AR-10: hóa đơn xuất thẳng 110tr → tạo phiếu thu chọn được hóa đơn, AR về 0. |
| B07 | Lấy `DoiTac`, `HopDong` từ `ChungTuGoc` (như Báo có đã làm, dòng 85-91), hoặc kiểm khớp; lệch thì Cancel. | `Doc/PhieuThuTienKhachHang:57, 80, 140` | TC-AR-06: chọn hợp đồng khác biên bản → bị chặn. |
| B11 | `UndoPosting` gọi `KiemTraKhongCoChungTuPhuThuoc`; hủy thành công thì đưa trạng thái về "Đã duyệt nội bộ". Áp tương tự cho `Doc/DieuChinhCongNo:24-27`. | `Doc/BienBanNghiemThuGiaiDoan:153-155` | TC-AR-11: biên bản đã thu tiền → hủy ghi sổ bị chặn. |
| B12 | Chốt phạm vi: nếu chứng từ bán B2C ngoài phạm vi thì ghi rõ trong tài liệu; nếu trong phạm vi thì thêm chứng từ ghi Receipt tạm giữ + Nợ 1388. Bảng kê: kiểm trùng `MaGiaoDichKenh` trong bảng và giữa các bảng kê, khóa + kiểm số dư tạm giữ. | `Doc/BangKeDoiSoatKenhThanhToan:114-135` | TC-BANK-03: 2 bảng kê cùng mã "TX1" → bảng thứ 2 bị chặn. |
| B13 | Chỉ ghi sổ khi `TrangThaiHDDT = DaPhatHanh` và `MaCQT` có giá trị; `DaThayThe` xử lý như `DaHuy`; chặn hóa đơn thứ 2 cho cùng biên bản. | `Doc/HoaDonGTGTDauRa:57-75` | TC-AR-12: hóa đơn Dự thảo → không ghi sổ; 2 hóa đơn cùng biên bản → cái thứ 2 bị chặn. |
| B14 | Dùng `LayTaiKhoanCongNo` cho cả 5 chứng từ AR; xóa 3 bản `LayTaiKhoanCongNoTheoDoiTac`. | 5 ObjectModule AR, `CM/QuanLyVongDoiChungTuServer` | TC-AR-13: đối tác NoiBoVingroup + LaBenLienKet = False → mọi chứng từ dùng cùng 1 TK. |
| B16 | Bỏ gán mặc định ngầm (bắt nhập hoặc lấy từ hằng `PhapNhanMacDinh` và báo cho người dùng); kiểm trùng `MaGiaoDichNganHang`. | `Doc/BaoCoNganHang:16-22` | TC-BANK-02: 2 báo có cùng mã giao dịch → cái thứ 2 bị chặn. |
| B19 | Dùng `LayTaiKhoanCongNo`; UNC bắt buộc tiền tệ = tiền tệ hóa đơn gốc; đánh giá lại và cấn trừ dùng đúng TK đã ghi theo từng dòng. | `Doc/HoaDonNhaCungCap`, `Doc/UyNhiemChi`, `Doc/DanhGiaLaiNgoaiTe`, `Doc/CanTruCongNoNoiBo` | TC-AP-07: hóa đơn USD trả bằng UNC VND → bị chặn. |
| B20 | Bắt buộc `ChungTuGoc` của chứng từ hoàn trả là UNC đã ghi sổ, không phải chứng từ hoàn trả; đảo **từng dòng** movement gốc (đọc RecordSet theo Recorder, copy đủ chiều, gồm `ChungTuGoc` = hóa đơn). Kiểm trùng thêm điều kiện trạng thái. | `Doc/UyNhiemChi:142-276` | TC-AP-09: UNC trả hóa đơn 50tr rồi hoàn trả → số dư AP theo hóa đơn quay lại 50tr. |
| B22 | Số dư < số đề nghị → `Cancel = True` + thông báo (không tự sửa số). | `Doc/CanTruCongNoNoiBo:223-226, 249-251` | TC-NET-02: AR 60tr, đề nghị 100tr → bị chặn, thông báo rõ số dư. |

### Đợt 4 — Ngoại tệ

| Bug | Cách sửa | File cần đổi | Kiểm tra đã sửa xong |
|---|---|---|---|
| B23 | Đổi `LayTyGiaHienHanh` → `LayTyGiaHachToanHieuLuc`; bỏ fallback tỷ giá = 1; ghi `SoTienNgoaiTe` cho movement AR/AP theo tỷ lệ số dư (giống UNC dòng 392-400); chênh lệch VND vào 515/635. | `Doc/CanTruCongNoNoiBo:257-289` | TC-NET-04: cấn trừ USD → GL có tỷ giá thật, USD trên sổ phụ giảm. |
| B24 | Thêm `CongNoPhaiThu` vào RegisterRecords của DanhGiaLaiNgoaiTe; ghi điều chỉnh VND như phần AP; lọc `HopDong.DongTienThanhToan = &TienTe`; TK theo `LayTaiKhoanCongNo`. | `Doc/DanhGiaLaiNgoaiTe:266-332`, `src/Documents/DanhGiaLaiNgoaiTe.xml` | TC-FX-02: đánh giá lại 2 lần liên tiếp cùng tỷ giá → lần 2 chênh lệch = 0. |
| B25 | Kiểm `|SoTien − Round(SoTienNgoaiTe × TyGia)|` trong ngưỡng; xác định 1122 theo `TienTe ≠ VND`. | `Doc/UyNhiemChi:118-127, 404-415` | TC-AP-10: UNC 1.000 USD nhập 1.000đ → bị chặn. |
| B26 | Query chặn trùng PhapNhan + TienTe + NgayChot; bắt `NgayChot <= EndOfDay(Date)`; tính tổng ở BeforeWrite; `Round(…, 0)`. | `Doc/DanhGiaLaiNgoaiTe:14-18, 65, 359-360` | TC-FX-03: chứng từ thứ 2 cùng kỳ → bị chặn. |
| B27 | Thêm cờ "đã nhập thuế suất" thay vì dùng 0; rẽ nhánh theo `GrossUpThue`; bỏ FCT khi `DaDangKyThueTrucTiep`. Chốt nghiệp vụ với giảng viên trước. | `Doc/HoaDonNhaCungCap:56-69` | TC-AP-11: thuế TNDN 0% → lưu đúng 0%. |
| B40 | Query lỗi → `Raise`; kiểm tỷ giá không quá N ngày; tỷ giá ≤ 0/Undefined → `Raise`; xuất hết ngoại tệ thì lấy đúng số dư VND còn lại; làm tròn 0 cho VND. | `CM/QuanLyTyGiaVaNgoaiTeServer:36-67, 102-111, 135-161` | TC-FX-04: xuất hết 1.000 USD → số dư VND 1122 = 0. |
| B61 | Có số ngoại tệ thì bắt buộc chọn Tiền tệ. | `Doc/HoaDonNhaCungCap:36-41, 50-52` | Lưu hóa đơn có USD nhưng tiền tệ trống → bị chặn. |
| B15 | Quy ước: chiều `TienTe` trên GL = tiền tệ thực của khoản công nợ/tiền; dòng VND thì TienTe = VND; tỷ giá lấy từ `TyGiaHoiDoai`. Viết vào `CHINH_SACH_KE_TOAN_VSF_2026.md`. | `Doc/BienBanNghiemThuGiaiDoan`, `HoaDonGTGTDauRa`, `DieuChinhCongNo`, `BaoCoNganHang`, `PhieuThuTienKhachHang` | TC-FX-05: số dư GL 1312 theo TienTe = sổ phụ AR theo hợp đồng. |

### Đợt 5 — Báo cáo, dashboard, nạp số dư

| Bug | Cách sửa | File cần đổi | Kiểm tra đã sửa xong |
|---|---|---|---|
| B41 | Tạo chứng từ `NhapSoDuDauKy` (có bảng dòng) ghi Receipt vào sổ phụ và GL Nợ/Có đối ứng TK 000; ghi lại thì thay toàn bộ (không cộng dồn); có form. | Document mới, `DP/NapSoDuDauKy` (bỏ hoặc gọi document) | TC-RPT-06: nạp AR 100tr 2 lần → số dư 100tr, TK 000 = 0. |
| B42 | Mỗi báo cáo tạo sơ đồ DCS đọc bảng ảo `Balance`/`BalanceAndTurnovers` với tham số kỳ, nhóm theo Đối tác/Hợp đồng/nhóm tuổi nợ (xem mục 6, M06). Logic Safety Gate giữ ở `BaoCaoQuanTriServer` và gọi qua trường tính toán. | `src/Reports/*` (thêm Templates), `Rep/*` | TC-RPT-01..04: mở từng báo cáo, chọn kỳ, bấm Tạo → có bảng chi tiết. |
| B43 | Lấy quota, ngày hết hạn từ Hợp đồng/Information register; lọc hóa đơn theo hợp đồng cloud và kỳ; đọc ngưỡng từ `Constants.CanhBaoCloudMuc*`. | `CM/BaoCaoQuanTriServer:488-593` | TC-RPT-04: NCC mới không có mã TEST → số ngày còn hạn đúng hợp đồng. |
| B44 | Netting: so `Turnovers` Expense AR và AP của chứng từ cấn trừ với tổng cấn trừ; kênh: so tổng thực nhận với `DongTien` Receipt; trial balance tách Nợ/Có thật; in giá trị Delta thật. | `CM/BaoCaoQuanTriServer:330-333, 434-435, 789-840`, `Rep/MaTranCanTruNoiBoTapDoan:47`, `Rep/DoiSoatKenhThanhToanVaDongTienAo:37` | TC-RPT-05: tạo lệch có chủ đích → Delta ≠ 0. |
| B45 | Mặc định ngày = `CurrentSessionDate()`; `EndOfDay(DenNgay)`; `New Boundary(NgayChot, BoundaryType.Including)`; tỷ giá qua `TyGiaHoiDoai.SliceLast(&NgayBaoCao, …)`. | `CM/BaoCaoQuanTriServer` (các dòng ở B45), `DP/DashboardLanhDaoCFO:19` | TC-RPT-07: phiếu thu ngày 05/10/2026 → dashboard giảm AR. |
| B46 | Doanh thu từ GL (Có 511x), chi phí từ GL (Nợ 627/632/642) trong kỳ; DSO dùng AR không VAT hoặc doanh thu có VAT; phân khối theo thuộc tính của Hợp đồng/Dự án. | `DP/DashboardLanhDaoCFO:185-343, 532-545` | TC-RPT-08: tính tay DSO trên dữ liệu mẫu = số dashboard. |
| B47 | Bỏ số cứng; nhãn/màu theo dấu thật của NWC, CCC, Delta; không có dữ liệu thì hiện "N/A". | `DP/DashboardLanhDaoCFO:590-612`, `CM/BaoCaoQuanTriServer:1010-1079` | TC-RPT-09: dữ liệu AP > AR → nhãn không còn "Dương an toàn". |
| B48 | Đưa ngày hóa đơn/hạn thanh toán vào query (join), bỏ dereference trong vòng lặp; thêm cột tín dụng chưa phân bổ để tổng khớp GL; đếm đối tác bằng Map. | `CM/BaoCaoQuanTriServer:75-184` | TC-RPT-01: tổng tuổi nợ = số dư GL 131 tại ngày chốt. |
| B49 | Truyền đường dẫn qua tham số `/C ExportTrialBalanceEvidence;run_id;path`. | `AppModule:262` | Chạy lệnh có đường dẫn → file được tạo. |
| B50 | Trạng thái theo kết quả thật từng báo cáo; đường dẫn từ tham số/hằng; tách hàm ghi file ra module không ServerCall. | `CM/BaoCaoQuanTriServer:655-774` | Cố tình làm lỗi 1 báo cáo → trạng thái không còn "SUCCESS_100". |
| B51 | Quyết định: hoặc nối vào Báo có (bắt `SoTienNhan > 0`, TK treo riêng, thống nhất mặc định), hoặc xóa khỏi cấu hình và ghi "ngoài phạm vi". | `DP/DongCoDoiSoatTuDong` | Gọi với số tiền 0 → không ra "Đã đối soát". |
| B38 | Dùng `= VALUE(ChartOfAccounts.HeThongTaiKhoan.EmptyRef)`; `Boundary Including`; FULL OUTER JOIN; lọc `Active`. | `CM/QuanLyVongDoiChungTuServer:410-670` | Phiếu thu đúng 23:59:59 ngày chốt → Delta = 0. |

### Đợt 6 — Dọn dẹp, tài liệu

| Bug | Cách sửa | File cần đổi | Kiểm tra đã sửa xong |
|---|---|---|---|
| B36 | Đặt `ReturnValuesReuse = DontUse`; lưu `ThoiDiem` trong `DangKyHoaDon`; đếm cả hóa đơn chờ duyệt, loại Ref hiện tại, cửa sổ 30 ngày; luôn thêm CFO khi vượt ngân sách; map trạng thái → vai trò trong `KiemTraQuyenDuyet`. | `CM/PheDuyetDaCapServer` (+ `.xml`), `CM/QuyTrinhPheDuyetAPServer` | TC-AP-04: 3 hóa đơn 90tr cùng NCC chờ duyệt → hóa đơn thứ 3 cần cấp Kế toán trưởng. |
| B52, B53 | Xóa nhánh lệnh gọi hàm không tồn tại và nhánh không bao giờ chạy tới. | `AppModule:193-207, 246-266` | F7 sạch; grep không còn tên hàm không tồn tại. |
| B54 | Bỏ `RollbackTransaction` trước `BeginTransaction`; dùng mẫu transaction chuẩn (`BeginTransaction` → `Try … CommitTransaction` → `Except RollbackTransaction; Raise`). | `CM/QuanLyVongDoiChungTuServer:1006` | Đọc lại code theo mẫu. |
| B55 | Test kiểm đúng thông điệp lỗi mong đợi; rút ngắn tiền tố số chứng từ ≤ 20 ký tự. | `CM/PhanQuyenBaoMatServer:697-848` | Chạy test khi danh mục Đối tác rỗng → FAIL (không còn PASS giả). |
| B56 | Cổng seed dựa trên hằng `ChoPhepSinhDuLieuMau` + marker file clone, không chỉ dò chuỗi đường dẫn. | `CM/QuanLyVongDoiChungTuServer:17-28` | Đường dẫn production chứa "/scratch/uat/" mà cờ = False → bị chặn. |
| B57 | Bỏ ServerCall cho hàm ghi log; `LayTaiKhoanTheoMaLogic` báo lỗi rõ khi query hỏng. | `CM/QuanLyVongDoiChungTuServer:7-13, 287-306` | TC-TECH-10 |
| B58 | Watchdog đọc `Constants.TimeoutChoCanTruPhut`, chạy qua scheduled job hoặc xóa; `Max(0, Min(AR, AP))`. | `DP/LapMaTranCanTruTapDoan:13-37` | `TinhCanTruTayDoi(-5, 10)` = 0. |
| B59 | Thêm `Document.DanhGiaLaiNgoaiTe` vào phân hệ "Sổ cái & CFO"; data processor không có form thì thêm form hoặc gỡ khỏi menu. | `src/Subsystems/PhanHeSoCaiVaDongBo.xml`, 3 DataProcessor | Menu có "Đánh giá lại ngoại tệ"; không còn mục bấm vào trống. |
| B60 | Khóa theo số tài khoản ảo + TrimAll trước khi kiểm. | `src/Catalogs/TaiKhoanAo/Ext/ObjectModule.bsl:7-31` | Nhập " 123 " và "123" → cái sau bị chặn. |
| B62 | Xóa code chết; yêu cầu chưa duyệt → `Cancel = True`. | `Doc/BangKeDoiSoatKenhThanhToan:44-49, 126-135`, `Doc/YeuCauHoanTienChiHo:58-60` | TC-TECH-15 |
| B63 | Tắt Posting (`Deny`) cho `DeNghiThanhToanDichVu`, kiểm duyệt bằng `FillCheckProcessing`; hoặc giải thích lý do khi bảo vệ. | `src/Documents/DeNghiThanhToanDichVu.xml` | TC-TECH-16 |
| B68 | Đổi `KhachHang`/`NhaCungCap` → `DoiTac`; bỏ `Except` rỗng. | `CM/GeneratorNettingReconcileServer:656-698` | Chạy generator netting trên clone → chứng từ cấn trừ có chứng từ gốc và ghi sổ được. |
| B69 | Gán bằng tham chiếu: `Catalogs.PhapNhan.FindByCode("PN-VSF")`, `ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1388")`; log đúng số hằng đã đặt. | `CM/SeedDataCleanServer:264, 274` | Sau seed, mở form hằng số → 2 hằng có giá trị. |
| B70 | `IsUSD = Left(CodeDT, 9) = "TEST_NCC_" And Left(CodeDT, 12) <> "TEST_NCC_VN_"`. | `CM/GeneratorMasterDataServer:326` | Hợp đồng NCC trong nước có tiền tệ VND. |
| B71 | Kiểm cờ seed = False trước khi chạy; bọc `KiemThuTrangThai` và việc bật cờ trong `BeginTransaction … RollbackTransaction`. | `CM/HardeningTestsServer:2-36, 49-121, 260` | Kill tiến trình giữa test → cờ vẫn False; không còn chứng từ test sót lại. |
| B72 | Chỉ thêm bản ghi tỷ giá mới (không `Write(True)` xóa cả tập); không ghi đè tỷ giá đã có. | `CM/GeneratorMasterDataServer:351-368`, `CM/SeedDataCleanServer:99-112` | Số bản ghi tỷ giá USD cũ giữ nguyên sau khi chạy generator. |
| B73 | Bỏ mặc định `Infobase_FullData`, bắt tham số clone; bỏ `SendKeys`, dùng `/C` + `/N /P` của 1C. | `scripts/setup_sample_users.ps1`, `scripts/test_single_login.ps1` | Chạy không tham số → báo lỗi. |
| B74 | Generator lấy người duyệt từ user thật (`ketoan_truong`/`cfo_giamdoc`) và chạy duyệt bằng phiên của user đó (như `SeedWorkflowServer` đã làm). | `CM/GeneratorARServer:148-149`, `CM/GeneratorAPServer:283-284`, `CM/GeneratorNettingReconcileServer:341-342, 478-479` | `ketoan_truong` ghi sổ lại được chứng từ do generator sinh. |
| B75 | Thay đường dẫn cứng bằng tham số/biến môi trường hoặc đường dẫn tương đối từ gốc repo. | Các script và 2 module nêu ở B75 | Chạy trên máy khác không lỗi đường dẫn. |
| B64 | Sửa `progress.md`/README/hướng dẫn `.dt` cho khớp code; ghi rõ các tích hợp (webhook, SAP, HĐĐT) là **ngoài phạm vi**; thống nhất số liệu kiểm thử. | `README.md`, `docs/ERP_AUDIT_2026-10-14_FINAL_100.md`, `HUONG_DAN_SU_DUNG_FILE_DT.md`, `.superpowers/.../progress.md` | Đọc chéo 3 tài liệu không còn mâu thuẫn. |

## 5. Định nghĩa "xong" cho toàn bộ plan

- [ ] F7 (Check configuration) không lỗi.
- [ ] Toàn bộ 94 ca trong `04_KICH_BAN_TEST.md` (mục 8 là ca kỹ thuật TC-TECH-xx cho các bug B38-B75 còn lại) có "Kết quả thực tế" khớp "Kết quả mong đợi".
- [ ] Autotest anh Dũng gửi chạy PASS (khi có).
- [ ] Đăng nhập lần lượt 9 user, mỗi user chỉ làm được phần việc của mình.
- [ ] Báo cáo đối soát độc lập GL ↔ sổ phụ (sau khi sửa B38, B44) cho Delta = 0 trên dữ liệu `.dt` mới.
- [ ] Dump `.dt` mới, cập nhật README.

---

## 6. Bổ sung từ 1c mentor và lessons

> **Nguồn:** `1C-Mentor-Skill-Gemini/` (SKILL.md, `references/code-review.md`, `code-chinh-sach-patterns-debug.md`, `mis-erp-practice.md`, `phan-tich-erp.md`, `btl-1-de-bai-y-tuong.md`) và `Lessons/` (ưu tiên bản tiếng Việt), `Bài thực hành/`.
> Dự án tự xây từ cấu hình trống nên thuộc **lộ trình M (MIS)** trong `SKILL.md` §1a. Đề BTL trong `btl-1` viết cho lộ trình Jet → dùng tham khảo phần nộp bài và demo (**Cần xác nhận** với giảng viên áp thang điểm nào).
> Các mục trùng bug ở trên chỉ ghi tham chiếu, không lặp lại.

### 6.1. Code chưa làm theo góp ý / đang lặp lại lỗi trong lessons

| Mã | Nguồn | Góp ý / quy tắc | Hiện trạng code (bằng chứng) | Mức | Cách sửa | Kiểm tra |
|---|---|---|---|---|---|---|
| M01 | 1c mentor — `code-review.md` quy tắc **P2**, #std603 | Không để movement cũ khi ghi sổ lại có nhánh `Return` sớm trước `Write = True`. | Trùng **B01** (`Doc/HoaDonGTGTDauRa:64-83`). | Cao | Xem B01. | TC-AR-03 |
| M02 | 1c mentor — `code-review.md` **P3/P6**, #std661; `phan-tich-erp.md` §3.6 | Quy tắc phụ thuộc số dư phải kiểm trong Posting, có DataLock. | Không có kiểm số dư/khóa ở `Doc/DieuChinhCongNo:117-126`, `Doc/YeuCauHoanTienChiHo:98-118`, `Doc/BangKeDoiSoatKenhThanhToan:114-135` (grep `LaySoDu\|Balance(\|DataLock` trong 3 file = 0). | Cao | Xem B04, B12; thêm cho Yêu cầu hoàn tiền (kiểm số dư `DongTien` trước khi chi). | TC-AR-09, TC-BANK-03 |
| M03 | 1c mentor — `code-review.md` **P3**, #std733 | Ghi sổ lùi ngày phải đọc số dư theo thời điểm chứng từ. | `CM/QuanLyVongDoiChungTuServer:47` gọi `CongNoPhaiThu.Balance(, …)` không truyền thời điểm; `Doc/UyNhiemChi:372, 424, 465, 484`; `Doc/CanTruCongNoNoiBo:205, 231` cũng vậy. **Cần xác nhận** có phải cố ý. | Trung | Theo chế độ ghi sổ: thời gian thực → số dư hiện tại; không thời gian thực → `New Boundary(PointInTime(), BoundaryType.Excluding)`. Chuẩn bị câu trả lời khi bị hỏi. | TC-AR-14 (ghi sổ lùi ngày) |
| M04 | 1c mentor — `code-chinh-sach-patterns-debug.md` mục 2 & 4.3; lessons — Bài 12 (`12. Theory - VN.docx`), Bài 16 | Kiểm bắt buộc nhập/ràng buộc nội bộ chứng từ ở **Fill checking / FillCheckProcessing**, không chỉ ở form/BeforeWrite; thông báo có `Field`. | Grep `Procedure FillCheckProcessing` trong `src/` = 0. 8/13 chứng từ không có thuộc tính nào bật Fill checking (BangKe, BaoCo, CanTru, DeNghi, HoaDonNCC, NghiemThu, UyNhiemChi, YeuCauHoan). Kiểm bắt buộc nằm trong Posting (`Doc/PhieuThuTienKhachHang:57-64`, thông báo không có `Field`). | Trung | Bật Fill checking = "Show error" cho trường bắt buộc; chuyển kiểm MST/ngày/số tiền > 0 sang `FillCheckProcessing` (kèm `Cancel = True`, `Field`, `SetData`); Posting chỉ giữ kiểm số dư. | TC-UI-02: để trống Đối tác → ô bị tô đỏ trước khi lưu. |
| M05 | 1c mentor — `code-review.md` **T2**, #std499; lessons — Bài 12 (dòng ~160: "không để trống khối Except") | Không bắt lỗi rồi im lặng. | Có **49 khối `Except` rỗng** trong `src/` (VD `Doc/HoaDonGTGTDauRa:204-205`, `Doc/DieuChinhCongNo:176-177`, `Doc/PhieuThuTienKhachHang:119-120`). Dùng `Raise "chuỗi"` trong BeforeWrite/Posting (`Doc/CanTruCongNoNoiBo:23, 54-81, 161, 167, 221`; `Doc/UyNhiemChi:457`). | Trung | Mỗi `Except`: ghi `WriteLogEvent` + `Cancel = True` hoặc `Raise` lại. Trong Posting thay `Raise` bằng `UserMessage` + `Cancel = True`. | Grep `Except\s*EndTry` = 0. |
| M06 | 1c mentor — `code-chinh-sach-patterns-debug.md` 4.6, `mis-erp-practice.md` Bước 6; lessons — Bài 17 (`17. Theory - vi.docx` ~dòng 186: báo cáo điền bằng code "rất hiếm khi dùng"), Bài 18; `Bài thực hành số 1, 2` (báo cáo DCS có tham số kỳ) | Báo cáo dựng bằng **DCS** đọc bảng ảo của sổ, có tham số kỳ. | Trùng **B42**: 4 báo cáo `<MainDataCompositionSchema/>` rỗng, không có `Templates`. | Cao | Làm DCS cho ít nhất 2 báo cáo chính: Tuổi nợ (`CongNoPhaiThu.Balance(&NgayChot)` + nhóm tuổi nợ) và Sổ chi tiết công nợ (`BalanceAndTurnovers(&TuNgay, &DenNgay)`). | TC-RPT-01 |
| M07 | lessons — `Bài thực hành số 1` (Print Wizard), Bài 17, Bài 22; 1c mentor — `mis-erp-practice.md` Bước 6 "danh sách print form" | Chứng từ cần in phải có **mẫu in**. | 13/13 chứng từ không có template/command in; grep `GetTemplate` ngoài báo cáo = 0. | Cao | Dùng Print Wizard làm mẫu in cho **Phiếu thu, Ủy nhiệm chi, Hóa đơn GTGT** (template tên `PF_MXL_...` theo `lessons-21-24-extensions.md`, lệnh In, hàm `Print` ở manager module). | TC-UI-03: mở UNC → bấm In → ra bản in đủ thông tin. |
| M08 | 1c mentor — `SKILL.md` §2, `code-review.md` **F1**; lessons — Bài 7 (logic không đặt trong form), `Bài thực hành số 1` §4.1, `số 2` Nhiệm vụ 1 (OnChange) | Có **form chứng từ**; tính toán khi nhập ở client (`&AtClient`, OnChange); directive đúng. | 0 form cho 13 chứng từ, 10 danh mục (`<DefaultObjectForm/>` rỗng, VD `src/Documents/PhieuThuTienKhachHang.xml:56`). Tính VAT/Tổng trong BeforeWrite (`Doc/HoaDonGTGTDauRa:47-54`) → người dùng không thấy kết quả khi đang nhập. | Trung–Cao (ảnh hưởng demo) | Tạo form cho 4 chứng từ chính (Biên bản, Hóa đơn GTGT, Phiếu thu, UNC): OnChange `&AtClient` tính VAT/Tổng; lấy tỷ giá bằng `&AtServerNoContext` dùng `SliceLast`. Logic kiểm tra vẫn giữ ở ObjectModule. | TC-UI-01: nhập chưa thuế 100tr, VAT 10% → Tổng hiện 110tr ngay. |
| M09 | lessons — Bài 20 (`20. Theory - vi.docx`: mặc định cấm; chỉ FullAccess tick "Set rights for new objects"; cấp View cho subsystem); 1c mentor — `mis-erp-practice.md` Bước 6 & checklist H ("Chỉ có role FullAccess → không chứng minh được thiết kế phân quyền"), #std689 | Có **ma trận quyền vai trò × đối tượng**; role cấp quyền tối thiểu. | Trùng **B35**: 9 `Rights.xml` giống hệt nhau, `setForNewObjects=true`, không có quyền cụ thể. | Cao | Lập bảng ma trận (9 vai trò × 13 chứng từ + 4 sổ + 4 báo cáo) trong tài liệu nộp; khai báo đúng trong Designer. | TC-SEC-08 |
| M10 | lessons — Bài 14 (`14. Theory - vi.docx`: Privileged tắt kiểm soát quyền cho toàn module); 1c mentor — #std485, #std679, **M1** | Không bật Privileged cả module; không bật Server call mặc định. | 18/18 Common Module bật `ServerCall`; 4 module **Privileged + ServerCall** (`PhanQuyenBaoMatServer`, `UserProvisioningServer`, `SeedDataCleanServer`, `SeedFullTestDataServer`); grep `SetPrivilegedMode` = 0. | Cao | Tắt ServerCall cho module chỉ gọi từ server (Posting); bỏ Privileged, dùng `SetPrivilegedMode(True)` … `SetPrivilegedMode(False)` bọc đúng đoạn cần. Xem B33, B34. | Gọi các hàm từ form client → lỗi "không gọi được". |
| M11 | 1c mentor — #std740 | Không lưu mật khẩu dạng rõ trong code. | Trùng **B33** (`CM/UserProvisioningServer:118, 122, 126`). | Cao | Xem B33. | TC-SEC-06 |
| M12 | 1c mentor — `code-review.md` **Q1**, **M2**; lessons — Bài 4 (Predefined), Bài 22 (`22. Theory - vi.docx` ~dòng 34: tìm theo mã/tên là giải pháp kém) | Không tìm phần tử theo mã/tên trong thuật toán; dùng **tài khoản định sẵn (predefined)** hoặc hằng số. | 56 lệnh `FindByCode("<số TK>")` trong chứng từ (VD `Doc/HoaDonGTGTDauRa:98-105`, `Doc/PhieuThuTienKhachHang:105-126`); `HeThongTaiKhoan` không có tài khoản predefined. | Trung | Khai báo predefined (TK1311, TK1312, TK3311, TK33311, TK5113, TK1121, TK1122…) và dùng `ChartsOfAccounts.HeThongTaiKhoan.TK1311`. Đồng thời sửa B14/B19 qua `LayTaiKhoanCongNo`. | Đổi tên tài khoản 1311 → các chứng từ vẫn ghi sổ đúng. |
| M13 | 1c mentor — `mis-erp-practice.md` Bước 4 / checklist D | Tập giá trị cố định mà code rẽ nhánh theo → dùng **Enum**. | `TrangThai` kiểu chuỗi ở BangKe, BaoCo, CanTru, YeuCauHoan; code so `"DaDuyet"`, `"DaCanTru"`, `"DaDoiSoat"` (`Doc/CanTruCongNoNoiBo:21-24`, `Doc/YeuCauHoanTienChiHo:41, 59`, `Doc/BaoCoNganHang:34`). Enum `TrangThaiCanTru` có sẵn nhưng không dùng. | Trung | Đổi kiểu thuộc tính sang Enum (`TrangThaiCanTru`, `TrangThaiLenhThanhToan`…); sửa so sánh. Cần chuyển đổi dữ liệu cũ trong `.dt`. | Không gõ được trạng thái tự do. |
| M14 | 1c mentor — `code-review.md` **Q1**, #std496; lessons — Bài 16 | Không đọc thuộc tính qua dấu chấm trong vòng lặp/Posting (mỗi lần là 1 truy vấn ẩn). | `Doc/HoaDonGTGTDauRa:99` (`DoiTac.LaBenLienKet`), `:106`; `Doc/NghiemThuThauPhu:73`; `Doc/PhieuThuTienKhachHang:94`; `Doc/BaoCoNganHang:42`; vòng lặp `Row.ChungTuGoc.Date` ở `CM/BaoCaoQuanTriServer:100, 181`. | Thấp–Trung | Lấy các thuộc tính trong 1 query đầu Posting; báo cáo join bảng chứng từ. Xem B48. | Bật Performance Measurement khi chạy báo cáo tuổi nợ → không còn hàng nghìn truy vấn nhỏ. |
| M15 | 1c mentor — `code-review.md` **V5**, #std773 | Kiểm `DataExchange.Load` ở **đầu** BeforeWrite. | Thiếu ở 7/13 BeforeWrite (BaoCo, BienBan, CanTru, DanhGiaLai, HoaDonGTGT, HoaDonNCC, UyNhiemChi); Phiếu thu kiểm sau khi đã kiểm quyền (`Doc/PhieuThuTienKhachHang:17-21`). | Thấp | Thêm `If DataExchange.Load Then Return; EndIf;` ở đầu — **nhưng** giữ kiểm quyền import trạng thái đã ghi sổ (README ghi đã sửa lỗ hổng Load cho đối soát; đọc `CM/QuanLyVongDoiChungTuServer:150` trước khi đổi). | Nạp `.dt`/trao đổi dữ liệu không báo lỗi giả. |
| M16 | 1c mentor — `SKILL.md` §8 ("không phải Document nào cũng post"), `mis-erp-practice.md` Bước 3 | Chứng từ không ghi sổ thì không bật Posting. | Trùng **B63** (`DeNghiThanhToanDichVu`). | Thấp | Xem B63. | TC-TECH-16 |
| M17 | lessons — Bài 11 (Generation / "Tạo dựa trên"), `Bài thực hành số 2` §2.3; 1c mentor — `phan-tich-erp.md` §1 bước 3 | Chuỗi chứng từ dùng **"Tạo dựa trên" (Based on + Filling)**. | 13/13 chứng từ `<BasedOn/>` rỗng; grep `Procedure Filling` = 0 → người dùng chọn tay chứng từ gốc (dễ chọn sai, gây B07). | Trung | Đặt Based on: Hóa đơn GTGT ← Biên bản; Phiếu thu ← Hóa đơn/Biên bản; UNC ← Hóa đơn NCC; viết `Filling` chỉ điền khi ô còn trống. | TC-UI-04: từ Biên bản bấm "Tạo dựa trên → Hóa đơn" → đối tác, hợp đồng, số tiền tự điền. |
| M18 | lessons — Bài 20 (DefaultRoles), Bài 13 (Constants form); 1c mentor — `code-review.md` §2c (`CurrentDate()` → `CurrentSessionDate()`) | Có vai trò mặc định, form hằng số; dùng `CurrentSessionDate()`. | `src/Configuration.xml:54` `<DefaultRoles/>` rỗng; `:223` `<DefaultConstantsForm/>` rỗng, không phân hệ nào chứa Constant; `Doc/HoaDonGTGTDauRa:37` dùng `CurrentDate()`. | Thấp | Đặt QuanTriHeThong làm DefaultRoles; tạo Constants form đưa vào phân hệ "Danh mục"; đổi `CurrentSessionDate()`. | Kế toán trưởng mở được form cài đặt ngưỡng duyệt. |
| M19 | 1c mentor — `code-review.md` **M2**, `mis-erp-practice.md` Bước 4, #std455 | Đặt tên nhất quán, chia `#Region`, không để code test trong cấu hình nộp. | 11 module seed/test nằm trong cấu hình; 6 module test/seed không có `#Region`; tên trộn Anh/Việt (`HardeningTestsServer`, `RunSeedWorkflow`). Chỉ có ngôn ngữ `src/Languages/English.xml` (`Configuration.xml:211`) trong khi synonym tiếng Việt khai dưới `lang=en` → **Cần xác nhận** giao diện hiện tiếng gì khi demo. | Thấp | Tách module test/seed sang extension hoặc data processor ngoài trước khi nộp; thống nhất quy ước tên; kiểm tra giao diện demo. | Danh sách Common Module trong bản nộp chỉ còn module nghiệp vụ. |
| M20 | 1c mentor — `mis-erp-practice.md` §1-§4, `phan-tich-erp.md` K1-K11 | Hồ sơ lộ trình M phải có: bảng phạm vi (trong/**ngoài phạm vi**), ma trận posting, ma trận quyền, danh sách báo cáo, danh sách print form, kịch bản kiểm thử có số dư kỳ vọng, **nhật ký quyết định**. | Có đặc tả trong `docs/superpowers/specs/`, nhưng không tìm thấy ma trận quyền, danh sách print form, bảng "ngoài phạm vi" (các tích hợp webhook/SAP/HĐĐT được ghi "DONE" nhưng không có code — xem B64). | Trung | Bổ sung 1 tài liệu nộp gồm các bảng trên; ghi rõ webhook ngân hàng, SAP, ký số HĐĐT là **ngoài phạm vi**. | Mentor hỏi "cái này có làm không?" → trả lời được theo bảng phạm vi. |

### 6.2. Điểm đã làm đúng theo mentor/lessons (nên nêu khi thuyết trình)

- Chế độ khóa dữ liệu `Managed`, tắt hộp thoại modal (`src/Configuration.xml:217, 219`).
- Không dùng `Message()`; thông báo dùng `UserMessage` + `NStr` song ngữ.
- Hầu hết `Posting` có `Clear()` + `Write = True`; dấu Receipt/Expense đúng chiều nghiệp vụ.
- Chứng từ thanh toán và cấn trừ có `DataLock` tường minh, khóa theo thứ tự (`Doc/UyNhiemChi:325`) để tránh deadlock.
- 12/13 chứng từ bật "Post/Unpost in privileged mode".
- Có sổ cái kế toán (Accounting Register) có đối ứng tài khoản.
- Form Dashboard có directive (`&AtClient`, `&AtServer`) đúng.

## 7. Giả định

1. Thứ tự đợt ưu tiên kiểm soát/bảo mật trước vì tài liệu mentor nhấn mạnh thử đăng nhập từng vai trò khi bảo vệ.
2. Những thay đổi kiểu dữ liệu (B06, B28 đổi sang tham chiếu người dùng, M13 đổi sang Enum) cần chuyển đổi dữ liệu cũ trong `.dt`; nếu không đủ thời gian, làm phần kiểm tra trong code trước, đổi kiểu sau.
3. Với các nghiệp vụ kế toán chưa rõ (B09, B12, B27), cần chốt với giảng viên/người phụ trách kế toán trước khi code.
