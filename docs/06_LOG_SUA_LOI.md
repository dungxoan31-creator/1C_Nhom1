# 06 — LOG SỬA LỖI (Đợt 1 + Đợt 2)

> **Nhánh:** `fix/claude-review-dot1-2` (tách từ `master` tại commit `f993fc1`). Ngày sửa: 15/10/2026.
> **Phạm vi:** Đợt 1 (kiểm soát và bảo mật) và Đợt 2 (sổ chi tiết khớp sổ cái) trong `docs/03_PLAN_SPEC_FIX.md`.
> **Mã lỗi** (B01…) lấy theo `docs/02_BUG.md`. **Ca test** (TC-…) lấy theo `docs/04_KICH_BAN_TEST.md`.
> Trong code, mọi chỗ sửa đều có comment dạng `// [FIX Bxx] ...`. Muốn xem nhanh tất cả chỗ sửa: `git grep -n "FIX B"`.

## ⚠️ Đọc trước khi gộp vào `master`

1. **Đã nạp và kiểm tra trên 1C thật (15/10/2026).** Chạy trên máy Huy: 1C:Enterprise Training **8.3.27.1719** (macOS), script `scripts/rebuild_dt_from_src.sh`. Kết quả từng bước:

   | Bước | Lệnh 1C | Kết quả |
   |---|---|---|
   | 01 | `CREATEINFOBASE` (infobase trống, thư mục tạm) | OK |
   | 02 | `/RestoreIB` file `.dt` cũ (cấu hình cũ + dữ liệu) | OK — "Infobase successfully restored" |
   | 03 | `/LoadConfigFromFiles src` (code đã sửa) | OK, không lỗi |
   | 04 | `/CheckConfig` (tương đương F7: Thin client, Server, External connection, tham chiếu sai, handler…) | **0 lỗi biên dịch**. Còn 2 cảnh báo **có từ trước, không do bản sửa**: hàm `TaoKhoaSoDu` (CM `QuanLyTyGiaVaNgoaiTeServer`) không ai gọi; handler `UndoPosting` rỗng trong `BienBanNghiemThuGiaiDoan` (cố ý rỗng — sổ tự xoá theo AutoDeleteOnUnpost). |
   | 05 | `/UpdateDBCfg` | OK — cập nhật cấu trúc bảng `DieuChinhCongNo`, `PhieuThuTienKhachHang`, `NghiemThuThauPhu` (thêm cột NguoiLap/NguoiDuyet) |
   | 06 | `/DumpIB` | OK — ra file `.dt` mới |

   Ngoài ra trước đó: `python -B scripts/verify_bsl_syntax.py` 44 file, 0 lỗi; một người review độc lập đọc toàn bộ diff (mục 5).

   **Chưa làm:** chưa chạy các ca test nghiệp vụ trên engine (mục 3, bước 4–6). Cần chạy trước khi gộp nhánh.
2. **File `VinSmart_Future_AR_AP_Full.dt` ĐÃ được cập nhật** (1.303.195 byte, MD5 `b8a5ad60f3d506868ee41f315ffb0e3f`):
   - Cấu hình = `src/` đã sửa. Dữ liệu = giữ nguyên dữ liệu của file `.dt` cũ (không sinh lại, không ghi sổ lại). Sổ đã ghi trước đây vẫn là kết quả của logic cũ.
   - Chứng từ cũ của 3 loại trên có cột `NguoiLap`/`NguoiDuyet` để trống (dữ liệu cũ chưa có). Hệ thống xử lý được trường hợp này (xem mục 5 — chứng từ cũ thiếu người lập).
   - Đăng nhập: `Admin`, mật khẩu trống (như cũ).
   - **Cần xác nhận:** file dump bằng 1C **8.3.27**; chế độ tương thích cấu hình vẫn là `Version8_3_22`. Nếu 1C **8.3.22** trên máy Dũng báo không nạp được file này, dựng lại ngay trên máy Dũng bằng `scripts/rebuild_dt_from_src.ps1 -SourceDt <file .dt cũ>` (cùng 6 bước như bảng trên, log ở `build_tmp\logs`).
3. **Một số bộ test cũ sẽ báo FAIL** vì quy tắc mới chặt hơn. Đây là test cần sửa theo quy tắc mới, **không phải** do code chạy sai (xem mục 4).

---

## 1. Bảng các lỗi đã sửa

Đường dẫn rút gọn: `Doc/X` = `src/Documents/X/Ext/ObjectModule.bsl`, `CM/X` = `src/CommonModules/X/Ext/Module.bsl`. Số dòng là số dòng **sau khi sửa**.

### Đợt 1 — Kiểm soát và bảo mật

| Mã | File:dòng (sau sửa) | Trước khi sửa | Sau khi sửa | Ca test |
|---|---|---|---|---|
| B28 | `CM/QuanLyVongDoiChungTuServer:449` (hàm mới `GanNguoiLapKhiTaoMoi`), gọi ở đầu `BeforeWrite` của 12 chứng từ; `CM/PhanQuyenBaoMatServer:10` | Ô "Người lập" do người dùng tự gõ. Gõ tên người khác là tự lập tự duyệt được. So sánh tên có phân biệt hoa/thường. | Khi tạo chứng từ, hệ thống tự ghi Người lập = người đang đăng nhập. Sau khi lưu thì không ai sửa được (kể cả khi hủy ghi sổ). So sánh tên không phân biệt hoa/thường. | TC-SEC-01 |
| B29 | `CM/QuanLyVongDoiChungTuServer:117` (`TenTrangThai`), `:194` (`TrangThaiTruocHopLe`), `:359` (`KiemTraChuyenTrangThai`); `Doc/BangKeDoiSoatKenhThanhToan:62`; `Doc/DanhGiaLaiNgoaiTe:44`; `Doc/HoaDonGTGTDauRa:66` | Chỉ cấm vài trạng thái cũ ("danh sách cấm"). Hóa đơn NCC đang "Chờ PM" hoặc "Từ chối" vẫn nhảy thẳng sang "Đã ghi sổ" được. Trạng thái so bằng chữ hiển thị nên đổi ngôn ngữ là hỏng. Bảng kê, Đánh giá lại và Hóa đơn GTGT ghi sổ được từ bản nháp. | Dùng **danh sách cho phép**: mỗi trạng thái mới chỉ được đến từ những trạng thái liệt kê sẵn, so theo tên giá trị Enum. Người lập chỉ được lưu nháp hoặc gửi duyệt; sau khi gửi thì không sửa được chứng từ. Chứng từ đã ghi sổ không đổi trạng thái được bằng lệnh Lưu thường. Bảng kê, Đánh giá lại và Hóa đơn GTGT (phải "Đã phát hành") chỉ ghi sổ được sau khi duyệt. | TC-SEC-02 |
| B30 | `CM/QuyTrinhPheDuyetAPServer:103` (`KiemTraBuocDuyetAP`), `:152` (`HoaDonCanDuyetCFO`); gọi ở `Doc/HoaDonNhaCungCap:44` | Hai module duyệt nhiều cấp có trong cấu hình nhưng không được gọi ở đâu. Ai cũng bấm qua được mọi bước duyệt. | Mỗi bước duyệt hóa đơn NCC phải đúng vai trò: Tech Lead → PM → IT Director → (CFO) → Kế toán AP. Hóa đơn trên 500 triệu, tính cả lũy kế trong tháng (chống chia nhỏ hóa đơn), bắt buộc qua bước CFO. | TC-AP-03, TC-AP-04 |
| B31 | `CM/QuanLyVongDoiChungTuServer:485` (`XuLyHuyGhiSo`), `DanhSachChungTuPhuThuoc`; gọi ở nhánh `UndoPosting` đầu `BeforeWrite` của 12 chứng từ | Ai cũng hủy ghi sổ được. Hủy hóa đơn đã thanh toán làm công nợ âm. Hủy xong chứng từ kẹt ở "Đã ghi sổ" mà chưa ghi sổ. | Chỉ Kế toán trưởng hoặc CFO được hủy ghi sổ. Nếu còn chứng từ khác đã ghi sổ tham chiếu tới thì bị chặn, có báo tên chứng từ đó. Sau khi hủy, trạng thái về bước ngay trước ghi sổ. | TC-SEC-04, TC-AR-11 |
| B32 | `CM/PhanQuyenBaoMatServer:10, 60` (+ hàm mới `LaQuanTriKhongNghiepVu`) | Chỉ chặn đúng tài khoản tên "Admin". Người có vai trò quản trị lại được bỏ qua phân quyền và ký duyệt được. | Người có vai trò quản trị (mà không kiêm Kế toán trưởng/CFO) không được ký duyệt, ghi sổ hay hủy ghi sổ chứng từ tài chính. Vẫn được lưu và bảo trì kỹ thuật. | TC-SEC-05 |
| B33 | `CM/UserProvisioningServer:9`; `src/Ext/ManagedApplicationModule.bsl:8, 167` | Mật khẩu `Vsf@2026!Secure` viết thẳng trong code và ghi ra nhật ký. Ai cũng chạy được `/C SetupSampleUsers` và reset mật khẩu Admin. | Chỉ chạy được trên clone UAT, bởi người có vai trò quản trị. Không động vào người dùng đã có. Mật khẩu truyền qua tham số, không ghi ra nhật ký. Nhật ký khởi động chỉ ghi tên lệnh. | TC-SEC-06 |
| B34 | `src/Ext/ManagedApplicationModule.bsl:15`; `src/CommonModules/PhanQuyenBaoMatServer.xml` (Privileged = false); `CM/QuanLyVongDoiChungTuServer:361` | Lệnh test/seed chạy được trên CSDL thật, ghi sổ và xóa chứng từ thật. Module kiểm quyền chạy ở chế độ toàn quyền và nhận "tên người dùng" do bên gọi truyền vào nên giả mạo được. | Mọi lệnh `/C` (trừ 5 lệnh chỉ đọc) bị từ chối nếu không phải clone UAT. Module kiểm quyền bỏ chế độ toàn quyền và luôn dùng người đăng nhập thật. | TC-SEC-07 |
| B37 | `CM/PhanQuyenBaoMatServer:117` | Chứng từ Đánh giá lại ngoại tệ không thuộc nhóm nào nên ai cũng ghi sổ được. Loại chứng từ mới mặc định không bị kiểm soát. | Đánh giá lại chỉ Kế toán trưởng/CFO ghi sổ. Loại chứng từ chưa khai báo phân quyền thì bị chặn ghi sổ. | TC-SEC-09 |
| B08 | `Doc/YeuCauHoanTienChiHo:28, 69`; `CM/QuanLyVongDoiChungTuServer:268` | Chi tiền hoàn mà không cần duyệt: tự gõ "DaDuyet", để trống Người duyệt. | Maker-Checker đầy đủ. Trạng thái chỉ được chọn trong danh sách hợp lệ và đi đúng thứ tự. | TC-BANK-04 |
| B10 | `Doc/PhieuThuTienKhachHang:23, 60`; `Doc/DieuChinhCongNo:25, 33, 79`; **metadata:** thêm `NguoiLap`, `NguoiDuyet` vào `src/Documents/PhieuThuTienKhachHang.xml`, `DieuChinhCongNo.xml` và `src/ConfigDumpInfo.xml` | Phiếu thu và Điều chỉnh công nợ (làm giảm công nợ) không có người duyệt. Kế toán AR tự xóa nợ khách được. | Có Người lập (tự động) và Người duyệt. Ghi sổ phải đúng Người duyệt, khác Người lập. Điều chỉnh phải qua "Đã duyệt nội bộ". | TC-AR-07 |
| B18 | `Doc/NghiemThuThauPhu:17, 55`; `Doc/DeNghiThanhToanDichVu:9, 16`; **metadata:** thêm `NguoiLap`, `NguoiDuyet` vào `src/Documents/NghiemThuThauPhu.xml` | Nghiệm thu thầu phụ tạo công nợ phải trả không cần duyệt. Đề nghị thanh toán để trống Người duyệt là qua (kể cả qua đường import dữ liệu). | Nghiệm thu: Dự thảo → Chờ kế toán AP → Ghi sổ, có Maker-Checker. Đề nghị: Maker-Checker kiểm tra cả khi import, và số tiền phải > 0. | TC-AP-05 |
| B65 | `CM/SeedFullTestDataServer:224, 461` | Hàm bổ sung khóa sổ cái tự gán đối tác/hợp đồng "mặc định" (`TEST_DT_01`, `DT-ONEPAY`, `NCC-AWS`, hợp đồng đầu tiên) và không dùng transaction. | Không còn bịa khóa: chỉ điền khóa lấy được từ chính chứng từ. Dòng nào không suy ra được thì được liệt kê vào nhật ký `GL.Backfill.Missing`. Mỗi chứng từ ghi trong 1 transaction. | TC-TECH-18 |
| B66 | `scripts/import_dt.ps1` (viết lại); `HUONG_DAN_SU_DUNG_FILE_DT.md` mục 4 | Restore đè thẳng vào `C:\Users\Dung\...\Infobase`, không hỏi, luôn trả mã 0. | Bắt buộc `-IBPath`. Từ chối thư mục tên `Infobase` hoặc `Infobase_FullData`. Phải gõ `YES` (hoặc dùng `-Force`). Trả đúng mã thoát. | TC-TECH-19 |
| B67 | `CM/SeedDataCleanServer:298` | Seed tạo Admin mật khẩu trống, gán **toàn bộ** vai trò (kể cả Kế toán trưởng, CFO). | Admin chỉ nhận vai trò Quản trị hệ thống. | TC-TECH-20 |
| B36 (một phần) | `CM/PheDuyetDaCapServer:52, 251, 310`; `src/CommonModules/PheDuyetDaCapServer.xml` (ReturnValuesReuse = DontUse) | Kết quả bị lưu đệm suốt phiên. Chỉ đếm hóa đơn đã ghi sổ. Lỗi truy vấn thì coi lũy kế = 0. Bộ nhớ mô phỏng thiếu `ThoiDiem` nên lỗi. | Không lưu đệm. Đếm cả hóa đơn đang chờ duyệt, loại trừ hóa đơn hiện tại. Lỗi truy vấn thì dừng lại. Vượt ngân sách luôn cần CFO. | TC-AP-04 |

### Đợt 2 — Sổ chi tiết khớp sổ cái

| Mã | File:dòng (sau sửa) | Trước khi sửa | Sau khi sửa | Ca test |
|---|---|---|---|---|
| B01 | `Doc/HoaDonGTGTDauRa:85` | `Write = True` nằm **sau** các lệnh `Return`. Hủy hóa đơn rồi ghi sổ lại vẫn còn bút toán AR/VAT cũ. | Chuyển `Write = True` lên ngay sau `Clear()`. Hóa đơn "Đã hủy" hoặc "Đã thay thế" ghi sổ lại sẽ xóa sạch bút toán. | TC-AR-03 |
| B02 | `Doc/HoaDonGTGTDauRa:55, 61, 107` | VAT và Tổng chỉ được tính khi đang = 0. Đổi thuế suất sau lần lưu đầu làm sổ chi tiết lệch sổ cái. | Luôn tính lại VAT và Tổng. Khi ghi sổ kiểm tra Tổng = Chưa thuế + VAT. | TC-AR-04 |
| B03 | `Doc/HoaDonGTGTDauRa:116, 234`; `Doc/DieuChinhCongNo:198`; `Doc/BienBanNghiemThuGiaiDoan:159`; `Doc/PhieuThuTienKhachHang:200`; `Doc/BaoCoNganHang:149`; `Doc/BangKeDoiSoatKenhThanhToan:199`; `Doc/HoaDonNhaCungCap:311`; `Doc/NghiemThuThauPhu:161` | `Try … Except EndTry` nuốt lỗi kiểm tra cân đối. Chứng từ số tiền 0 vẫn ghi sổ. | Lỗi được báo cho người dùng và hủy ghi sổ. Hóa đơn theo biên bản có thuế suất 0% thì không sinh dòng 0 đồng. | TC-AR-05 |
| B05 | `Doc/DieuChinhCongNo:103` | Không ràng buộc Giảm doanh thu + Giảm VAT = Tổng giảm. Sổ chi tiết lệch sổ cái. | Bắt buộc cộng đúng, giảm doanh thu > 0, giảm thuế ≥ 0. | TC-AR-08 |
| B17 | `Doc/HoaDonNhaCungCap:75, 105, 271`; `Doc/NghiemThuThauPhu:42, 84, 98` | Tiền dịch vụ (và Tổng nghiệm thu) chỉ được tính một lần. Sửa Tổng làm sổ cái Có 331 ≠ sổ chi tiết AP. | Luôn tính lại theo Tổng. VAT phải < Tổng. Số ghi sổ chi tiết = tổng Có 331 trên sổ cái. | TC-AP-02 |
| B39 | `CM/QuanLyVongDoiChungTuServer:580` (hàm mới `KiemTraKhopGLVaSoPhu`) | Hàm "kiểm tra cân đối" so cặp Nợ = Có do chính chứng từ tự dựng nên không bao giờ phát hiện lệch. | Đối chiếu thật: biến động TK 131x/331x trên sổ cái phải bằng Tăng − Giảm của sổ chi tiết công nợ. Lệch thì hủy ghi sổ và báo rõ hai con số. Áp dụng cho Hóa đơn GTGT, Điều chỉnh, Hóa đơn NCC, Nghiệm thu thầu phụ. | TC-TECH-02 |
| B09 | `Doc/YeuCauHoanTienChiHo:37, 116` | Sổ cái ghi Nợ 1388 (tăng) nhưng sổ tạm giữ ghi Giảm. Phí hoàn âm làm lệch tiền. | Sổ tạm giữ ghi **Tăng** cho cùng chiều với Nợ 1388. Chặn phí âm và số tiền hoàn ≤ 0. **Cần xác nhận nghiệp vụ** (mục 6). | TC-BANK-05 |
| B21 | `Doc/UyNhiemChi:620` | Chi từ TK USD: phí ghi Có 1122 trên sổ cái, nhưng tiền thật trừ ở tài khoản VND. | Phí luôn ghi Có 1121, khớp tài khoản VND bị trừ tiền. | TC-AP-08 |

### Sửa kèm (nhỏ, cùng chỗ)

| Mã | File:dòng | Nội dung |
|---|---|---|
| B13 (một phần) | `Doc/HoaDonGTGTDauRa:85` | Hóa đơn "Đã thay thế" được xử lý như "Đã hủy" (không ghi sổ). |
| B62 | `Doc/YeuCauHoanTienChiHo:50` | Yêu cầu hoàn tiền chưa duyệt không còn được "ghi sổ rỗng". |
| B75 (một phần) | `CM/UserProvisioningServer:175` | Bỏ đường dẫn cứng `C:\Users\Dung\...`, ghi vào nhật ký 1C. |
| M18 (một phần) | `Doc/HoaDonGTGTDauRa` | `CurrentDate()` → `CurrentSessionDate()`. |
| — | `CM/SeedWorkflowServer:250` | Seed hóa đơn NCC bỏ bước CFO, vì Kế toán trưởng không được duyệt thay CFO. |
| — | `CM/NettingReversalTestsServer:239`, `CM/ConcurrencyTestsServer:168` | Test UNC thêm bước "Đã gửi ngân hàng" trước khi ghi sổ, theo quy trình mới. |
| — | `CM/QuanLyVongDoiChungTuServer:1387, 1418` | Test vòng đời ghi sổ không ghi đè Người lập đã lưu nữa. |

---

## 2. Hành vi thay đổi mà người dùng / người demo cần biết

1. **Ô "Người lập" (Biên bản: "Người tạo") tự điền, không sửa được.** Muốn lập chứng từ dưới tên ai thì đăng nhập bằng tài khoản người đó.
2. **Phiếu thu, Điều chỉnh công nợ, Nghiệm thu thầu phụ có thêm ô "Người duyệt".** Phải ghi sổ bằng đúng tài khoản ghi ở ô này, và tài khoản đó phải khác Người lập.
3. **Quy trình phải đi đúng thứ tự:**
   - Hóa đơn GTGT: Dự thảo → Chờ ký số → Đã phát hành → Ghi sổ.
   - Ủy nhiệm chi: Dự thảo/Chờ duyệt → Đã duyệt → Đã gửi ngân hàng → Đã ghi sổ.
   - Hóa đơn NCC: Dự thảo → Chờ duyệt kỹ thuật → Chờ PM → Chờ IT Director → (Chờ CFO) → Chờ kế toán AP → Đã ghi sổ.
   - Nghiệm thu thầu phụ: Dự thảo → Chờ kế toán AP → Ghi sổ.
4. **Người lập không sửa được chứng từ** sau khi đã gửi sang bước duyệt.
5. **Chỉ Kế toán trưởng / CFO được Hủy ghi sổ.**
6. **Tài khoản `Admin` không ghi sổ được chứng từ tài chính** (vẫn lưu nháp và bảo trì được). Các script sinh dữ liệu cũ (generator) đang ghi sổ bằng Admin sẽ bị chặn.
7. **Lệnh khởi động `/C …`** chỉ chạy trên clone UAT, trừ 5 lệnh chỉ đọc: `ExportExecutiveReports`, `VerifyFullTestData`, `VerifySampleUsers`, `TestUserLogin`, `TestDashboardCFO`.
8. **`scripts/import_dt.ps1`** giờ bắt buộc `-IBPath`. Lệnh mới đã ghi trong `HUONG_DAN_SU_DUNG_FILE_DT.md`.
9. **`SetupSampleUsers`**: mật khẩu truyền dạng `/C "SetupSampleUsers;<mật khẩu>"`. Bỏ trống thì mật khẩu trống (bản Training).

## 3. Cách kiểm tra lại (theo thứ tự)

1. Tạo clone UAT: `python -B scripts/create_uat_clone.py --source-dt "<đường dẫn>/VinSmart_Future_AR_AP_Full.dt"`.
2. Nạp code mới: `python -B scripts/onec_runtime.py update-db --ib-path "<clone>/ib" --source-path "<repo>/src" --user Admin`.
3. Mở Designer trên clone → **F7 (Check configuration)**. Phải hết lỗi (đã chạy tương đương bằng `/CheckConfig`: 0 lỗi, xem mục ⚠️).
4. Chạy tay các ca trong `docs/04_KICH_BAN_TEST.md`:
   - Đợt 1: TC-SEC-01, 02, 04, 05, 06, 07, 09; TC-AP-03, 04, 05; TC-AR-07, 11; TC-BANK-04; TC-TECH-18, 19, 20.
   - Đợt 2: TC-AR-03, 04, 05, 08; TC-AP-02, 08; TC-BANK-05; TC-TECH-02.
   - Ca chức năng chính (mục 1 của file test) để chắc không hỏng luồng thường.
5. Chạy seed dương bounded (`run_seed_full_data.ps1 -BoundedWorkflow -Smoke`) để kiểm tra luồng maker → checker vẫn chạy.
6. So kết quả với autotest anh Dũng gửi.

## 4. Test cũ sẽ báo FAIL — cần cập nhật theo quy tắc mới

| Test | Vì sao FAIL | Cần làm |
|---|---|---|
| `CM/PhanQuyenBaoMatServer` → `ThucThiKiemThuBaoMatToanDien` (ca 3, 6, 8; chạy trong `RunUnitTests`/`RunSecurityTests` bằng Admin) | Các ca này "giả làm" người dùng khác bằng tham số tên. Nay hệ thống luôn dùng người đăng nhập thật, và Admin không được ghi sổ. | Chạy lại ca tương ứng bằng đúng tài khoản (ketoan_ar, ketoan_truong…), hoặc viết lại theo vai trò phiên thật. |
| `KiemTraMakerSessionRuntime` (`RunTask2MakerTests`) | Maker `ketoan_ap` tự chuyển Dự thảo → Chờ kế toán AP (nay phải đi qua chuỗi duyệt) và tự hủy ghi sổ (nay chỉ KTT/CFO). | Sửa kỳ vọng của test. |
| `QuanLyVongDoiChungTuServer.KiemThuChuTrinhGhiSoRuntime` | Có thể chọn trúng (TOP 1) chứng từ đã có phiếu thu/UNC tham chiếu, nên Hủy ghi sổ bị chặn (đúng quy tắc B31). | Chọn chứng từ chưa có chứng từ phụ thuộc. |
| `tests/unit/PheDuyetDaCapTest.bsl` (file tham khảo, chưa chạy trên engine) | Bộ nhớ mô phỏng không còn được lưu đệm. | Tách bộ nhớ mô phỏng sang module riêng có lưu đệm, nếu cần chạy bộ test này. |
| `tests/unit/ChartOfAccountsTest.bsl:183-257` (tham khảo) | Dựa vào tham số tên người dùng, nay bị bỏ qua. | Viết lại theo phiên thật. |
| Generator legacy (`GeneratorAR/AP/NettingReconcileServer`) | Ghi sổ bằng Admin, nay bị chặn (vốn đã hỏng theo B74). | Dùng seed dương bounded `SeedWorkflowServer`. |

## 5. Lỗi người review độc lập phát hiện trong bản sửa đầu — đã sửa

| # | Vấn đề | Đã sửa ở |
|---|---|---|
| 1 | Đề nghị thanh toán import (`DataExchange.Load`) vẫn tự duyệt được. | `Doc/DeNghiThanhToanDichVu:16`: kiểm tra trước khi thoát sớm. |
| 2 | Mật khẩu truyền qua tham số bị ghi vào nhật ký khởi động. | `src/Ext/ManagedApplicationModule.bsl:8`: chỉ ghi tên lệnh. |
| 3 | Hóa đơn GTGT "Dự thảo/Chờ ký số" vẫn ghi sổ được. | `Doc/HoaDonGTGTDauRa:66`: chỉ ghi sổ khi "Đã phát hành". |
| 4 | Chứng từ đã ghi sổ đổi trạng thái được bằng Lưu thường. Thông báo lỗi sai thứ tự. | `CM/QuanLyVongDoiChungTuServer` (`KiemTraChuyenTrangThai`, bước 2 trước bước 3). |
| 5 | Lúc Hủy ghi sổ đổi được Người lập, mở đường tự duyệt. | `XuLyHuyGhiSo`: khóa Người lập. |
| 8 | Lệnh chỉ đọc trên bản phát hành bị chặn. | Danh sách 5 lệnh chỉ đọc. |
| 9 | Người lập sửa được số tiền sau khi đã gửi duyệt. | Bước 1b trong `KiemTraChuyenTrangThai`. |
| 10 | Chứng từ cũ đã ghi sổ mà thiếu Người lập bị gán nhầm người ghi sổ lại làm "người lập". | `GanNguoiLapKhiTaoMoi`: không tự gán cho chứng từ đã ghi sổ. |
| 11, 15 | VAT = Tổng hoặc giá trị nghiệm thu = 0 gây dòng sổ cái 0 đồng. | `Doc/HoaDonNhaCungCap`, `Doc/NghiemThuThauPhu:84`. |
| 12 | Biên bản ghi sổ được khi chưa "Đã duyệt nội bộ". | Danh sách cho phép nhóm NghiemThuAR. |
| 13 | Trạng thái chuỗi tiếng Việt cũ ("Đã đối soát"…) bị từ chối. | `ChuanHoaTenTrangThaiChuoi`: bổ sung 6 cặp. |

## 6. Chưa làm / cần nhóm quyết định

| Hạng mục | Tình trạng | Ai làm / làm ở đâu |
|---|---|---|
| **B35** Phân quyền chi tiết trong `Roles/*/Rights.xml` | **Chưa làm.** Sửa tay file XML quyền mà không mở được 1C rất dễ làm hỏng cấu hình. | Làm trong Designer theo ma trận vai trò × đối tượng (`03_PLAN_SPEC_FIX.md` M09). |
| B34 phần còn lại | Các hàm test vẫn nằm trong `PhanQuyenBaoMatServer` (đã bỏ chế độ toàn quyền). | Tách sang module test riêng (Đợt 6). |
| B36 phần còn lại | Vẫn tính lũy kế theo tháng dương lịch (chưa dùng cửa sổ 30 ngày). Bước CFO theo **ngân sách** chưa nối được vì Hóa đơn NCC không có Dự án/Khoản mục. | Thêm thuộc tính Dự án vào Hóa đơn NCC rồi gọi `KiemTraYeuCauDuyetCFO`. |
| Chứng từ cũ thiếu Người lập | Ghi sổ lại sẽ báo "Thiếu Người lập". | Chạy một lần xử lý điền Người lập thật cho dữ liệu cũ trước khi dùng. |
| **Quyết định 1** | Kế toán trưởng được **duyệt thay** các bước kỹ thuật (Tech Lead/PM/IT Director) của hóa đơn NCC; bước CFO chỉ CFO. Mục đích là giữ seed tự động chạy được. | Nhóm chốt có giữ quy ước này không. |
| **Quyết định 2** | Ngưỡng bắt buộc qua CFO = cấp "Giám đốc khối" trở lên (> 500 triệu, tính cả lũy kế tháng). | Nhóm/giảng viên chốt. |
| **Quyết định 3** | Sau Hủy ghi sổ, trạng thái về bước **ngay trước ghi sổ** (Đã duyệt / Chờ kế toán AP / Đã gửi NH), không về "Chờ duyệt" như plan. Lý do: giữ test vòng đời Hủy ghi sổ → Ghi sổ lại chạy được; ghi sổ lại vẫn phải qua Maker-Checker. | Nhóm chốt. |
| **Quyết định 4** | Hoàn tiền chi hộ (B09): sổ tạm giữ ghi Tăng cho khớp Nợ 1388. Nếu thực tế cổng thanh toán tự hoàn cho khách thì bút toán đúng phải là Có 1388. | Hỏi Kế toán trưởng / giảng viên. |
| Seed nhiều lần trên cùng clone | Lũy kế tháng của nhà cung cấp có thể vượt 500 triệu, khi đó seed AP dừng ở bước CFO. | Dùng clone mới cho mỗi lần chạy seed (README đã khuyến nghị). |
| `scripts/setup_sample_users.ps1` | Vẫn chờ file log cũ (nay ghi vào nhật ký 1C). | Sửa ở Đợt 6 (B73). |
| Đợt 3 → 6 | Chưa làm (B04, B06, B07, B11 phần kiểm số dư, B12, B14-B16, B19, B20, B22-B27, B38, B40-B64, B68-B75). | Theo `03_PLAN_SPEC_FIX.md`. |

## 7. Danh sách file thay đổi

```
scripts/import_dt.ps1
scripts/rebuild_dt_from_src.ps1, scripts/rebuild_dt_from_src.sh   (mới — dựng lại .dt từ src)
VinSmart_Future_AR_AP_Full.dt                                     (dựng lại với cấu hình đã sửa)
.gitignore                                                        (thêm build_tmp/)
HUONG_DAN_SU_DUNG_FILE_DT.md
src/ConfigDumpInfo.xml
src/CommonModules/PhanQuyenBaoMatServer.xml, PheDuyetDaCapServer.xml
src/CommonModules/{QuanLyVongDoiChungTuServer, PhanQuyenBaoMatServer, PheDuyetDaCapServer, QuyTrinhPheDuyetAPServer,
                   UserProvisioningServer, SeedDataCleanServer, SeedFullTestDataServer, SeedWorkflowServer,
                   NettingReversalTestsServer, ConcurrencyTestsServer}/Ext/Module.bsl
src/Documents/{PhieuThuTienKhachHang, DieuChinhCongNo, NghiemThuThauPhu}.xml
src/Documents/{BangKeDoiSoatKenhThanhToan, BaoCoNganHang, BienBanNghiemThuGiaiDoan, CanTruCongNoNoiBo, DanhGiaLaiNgoaiTe,
               DeNghiThanhToanDichVu, DieuChinhCongNo, HoaDonGTGTDauRa, HoaDonNhaCungCap, NghiemThuThauPhu,
               PhieuThuTienKhachHang, UyNhiemChi, YeuCauHoanTienChiHo}/Ext/ObjectModule.bsl
src/Ext/ManagedApplicationModule.bsl
docs/01_HIEN_TRANG.md … docs/06_LOG_SUA_LOI.md
```
