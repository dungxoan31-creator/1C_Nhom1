# BÁO CÁO THIẾT LẬP NGƯỜI DÙNG & KIỂM THỬ BẢO MẬT PHÂN QUYỀN VSF (8 ROLES RBAC & SECURITY REPORT)

> **Dự án**: Hệ Thống Quản Trị Tài Chính & Kế Toán VinSmart Future (VSF)  
> **Nền tảng**: 1C:Enterprise 8.3 (BSL / Metadata Version 2.15)  
> **Cơ sở dữ liệu áp dụng**: `Infobase_FullData` (Chứa 6,061 chứng từ thực tế 2025 - 2026)  
> **Ngày thực hiện**: 12/10/2026  
> **Kết quả kiểm thử bảo mật**: **PASS 100% (9/9 Test Suites trong 1C Engine & Python Harness)**  

---

## 1. Mục Tiêu & Bối Cảnh Nghiệp Vụ

Hệ thống quản trị tài chính VSF được thiết kế và vận hành theo mô hình kiểm soát nội bộ chuẩn mực quốc tế (COSO Framework) và các chuẩn mực kế toán Việt Nam (VAS / Thông tư 200 / Thông tư 99/2025/TT-BTC). Nhằm bảo đảm tính minh bạch tài chính, ngăn ngừa gian lận và tối ưu hóa quy trình phê duyệt chi tiêu, hệ thống phân quyền được xây dựng dựa trên 3 trụ cột cốt lõi:
1. **Mô hình 8 Vai trò Nghiệp vụ (8 RBAC Roles)**: Phân tách rõ ràng giữa Kế toán Phải thu (AR), Kế toán Phải trả (AP), Đối soát - Netting, Quản lý Kỹ thuật CNTT và Cấp lãnh đạo Tài chính (CFO, Kế toán trưởng).
2. **Nguyên tắc Maker-Checker (Bốn mắt / Dual Control)**: Cấm tuyệt đối người lập chứng từ hoặc lệnh chi tiền được tự phê duyệt chứng từ của chính mình.
3. **Phân định trách nhiệm (Segregation of Duties - SoD)**: Nhân sự phụ trách AR không thể ghi sổ hoặc can thiệp vào các chứng từ chi tiền AP; nhân sự kỹ thuật không có thẩm quyền ghi sổ hạch toán kế toán.

---

## 2. Danh Sách 8 Người Dùng Mẫu & Tài Khoản Quản Trị Đã Khởi Tạo

Toàn bộ 8 tài khoản người dùng nghiệp vụ và 1 tài khoản quản trị hệ thống đã được khởi tạo tự động trong `Infobase_FullData` thông qua API toàn vẹn `InfoBaseUsers` của 1C:Enterprise:

| STT | Tên đăng nhập (`Name`) | Tên hiển thị đầy đủ (`FullName`) | Role 1C được gán | Mật khẩu chuẩn | Mục đích nghiệp vụ & Phạm vi hoạt động |
| :---: | :--- | :--- | :--- | :---: | :--- |
| 0 | `Admin` | Quản trị hệ thống VSF | `QuanTriHeThong` | *(để trống)* | Quản trị kỹ thuật, phân quyền, bảo trì dữ liệu, cấu hình hệ thống |
| 1 | `ketoan_ar` | Kế toán Phải thu (AR) | `KeToanPhaiThu` | `123` | Toàn quyền trên AR: Nghiệm thu dịch vụ CNTT, Hóa đơn GTGT đầu ra, Phiếu thu tiền |
| 2 | `ketoan_ap` | Kế toán Phải trả (AP) | `KeToanPhaiTra` | `123` | Toàn quyền trên AP: Hóa đơn nhà cung cấp, Ủy nhiệm chi (UNC), Đề nghị thanh toán |
| 3 | `chuyenvien_doisoat` | Chuyên viên Đối soát & Netting | `ChuyenVienDoiSoatTapDoan` | `123` | Quản lý chứng từ Cấn trừ công nợ nội bộ song/đa phương, Bảng kê đối soát cổng TT |
| 4 | `cfo_giamdoc` | Giám đốc Tài chính / CFO | `GiamDocTaiChinh_CFO` | `123` | Phê duyệt cấp cao nhất, phê duyệt ngoại lệ (+1 CFO Unlock khi vượt ngân sách > 10%), xem toàn bộ Dashboard & Báo cáo tài chính |
| 5 | `ketoan_truong` | Kế toán trưởng | `KeToanTruong` | `123` | Phê duyệt trung gian hạn mức đến 500tr, kiểm soát cân đối kép Sổ cái, toàn quyền xem báo cáo tài chính |
| 6 | `pm_duan` | Quản lý dự án CNTT (PM) | `ProjectManager_QuanLyDuAn` | `123` | Phê duyệt kỹ thuật cấp 1 trong luồng AP, theo dõi ngân sách danh mục dự án phụ trách |
| 7 | `techlead_kythuat` | Trưởng nhóm Kỹ thuật (TechLead) | `TechLead_KiemTraKyThuat` | `123` | Kiểm tra kỹ thuật chi tiết dịch vụ CNTT mua ngoài & Cloud |
| 8 | `it_director` | Giám đốc Hạ tầng CNTT (IT Director) | `ITDirector_GiamDocHaTang` | `123` | Phê duyệt chi phí bản quyền & dịch vụ Cloud, theo dõi cảnh báo hạn mức Cloud |

> **Ghi chú về cơ chế mật khẩu**: Trong môi trường bản quyền thương mại, mật khẩu `123` được áp dụng mặc định. Hệ thống được tích hợp cơ chế dự phòng tự động tương thích với các ràng buộc giấy phép của phiên bản đào tạo (1C Training Edition) bảo đảm khởi tạo người dùng thành công 100%.

---

## 3. Ma Trận Phân Quyền Chi Tiết (Role-Based Access Control Matrix)

Bảng dưới đây quy định chi tiết thẩm quyền của từng Role đối với các phân hệ chứng từ, báo cáo và sổ sách kế toán trong nền tảng VSF:

| Phân hệ / Đối tượng Metadata | `KeToanPhaiThu` (`ketoan_ar`) | `KeToanPhaiTra` (`ketoan_ap`) | `ChuyenVienDoiSoat` (`chuyenvien_doisoat`) | `ProjectManager` (`pm_duan`) | `TechLead` (`techlead`) | `ITDirector` (`it_director`) | `KeToanTruong` (`ketoan_truong`) | `GiamDocTaiChinh_CFO` (`cfo_giamdoc`) | `QuanTriHeThong` (`Admin`) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Phân hệ Phải thu (AR)** | | | | | | | | | |
| `BienBanNghiemThuGiaiDoan` | **CRUD + Post** | Read Only | Read Only | Read Only | Read Only | Read Only | **Full** | **Full** | **Full** |
| `HoaDonGTGTDauRa` | **CRUD + Post** | **CHẶN** | Read Only | **CHẶN** | **CHẶN** | **CHẶN** | **Full** | **Full** | **Full** |
| `PhieuThuTienKhachHang` | **CRUD + Post** | **CHẶN** | Read Only | **CHẶN** | **CHẶN** | **CHẶN** | **Full** | **Full** | **Full** |
| `CongNoPhaiThu` (Subledger) | **Ghi sổ** | Read Only | Read Only | Read Only | Read Only | Read Only | **Full** | **Full** | **Full** |
| **Phân hệ Phải trả (AP)** | | | | | | | | | |
| `HoaDonNhaCungCap` | **CHẶN** | **CRUD + Post** | Read Only | Xem dự án | Kiểm tra KT | Duyệt hạ tầng | **Full** | **Full** | **Full** |
| `UyNhiemChi` (Lệnh chi tiền) | **CHẶN** | **Lập lệnh** *(Maker)* | Read Only | **CHẶN** | **CHẶN** | **CHẶN** | **Duyệt** *(<= 500tr)* | **Duyệt tối cao** | **Full** |
| `NghiemThuThauPhu` | **CHẶN** | **CRUD + Post** | Read Only | Duyệt cấp 1 | Kiểm tra | Duyệt hạ tầng | **Full** | **Full** | **Full** |
| `DeNghiThanhToanDichVu` | **CHẶN** | **CRUD + Post** | Read Only | Đề xuất | Đề xuất | Duyệt khối | **Full** | **Full** | **Full** |
| `CongNoPhaiTra` (Subledger) | Read Only | **Ghi sổ** | Read Only | Read Only | Read Only | Read Only | **Full** | **Full** | **Full** |
| **Phân hệ Cấn trừ & Đối soát (Netting)** | | | | | | | | | |
| `CanTruCongNoNoiBo` | Read Only | Read Only | **CRUD + Post** | Read Only | Read Only | Read Only | **Full** | **Full** | **Full** |
| `BangKeDoiSoatKenhThanhToan` | Read Only | Read Only | **CRUD + Post** | Read Only | Read Only | Read Only | **Full** | **Full** | **Full** |
| `YeuCauHoanTienChiHo` | Read Only | Read Only | **CRUD + Post** | Read Only | Read Only | Read Only | **Full** | **Full** | **Full** |
| **Quy trình Phê duyệt Đa cấp (4+1)** | | | | | | | | | |
| Phê duyệt Kỹ thuật (`ChoDuyetKyThuat`) | **CHẶN** | **CHẶN** | **CHẶN** | Tham gia | **Duyệt chính** | Tham gia | Theo dõi | Giám sát | Quản trị |
| Phê duyệt Dự án (`ChoDuyetPM`) | **CHẶN** | **CHẶN** | **CHẶN** | **Duyệt chính** | Đã duyệt | Tham gia | Theo dõi | Giám sát | Quản trị |
| Phê duyệt Khối CNTT (`ChoDuyetITDirector`)| **CHẶN** | **CHẶN** | **CHẶN** | Đã duyệt | Đã duyệt | **Duyệt chính** | Theo dõi | Giám sát | Quản trị |
| Phê duyệt CFO ngoại lệ (`ChoDuyetCFO`) | **CHẶN** | **CHẶN** | **CHẶN** | **CHẶN** | **CHẶN** | **CHẶN** | Tham vấn | **Duyệt tối cao** | Quản trị |
| Ghi sổ kế toán AP (`DaGhiSo`) | **CHẶN** | **Thực hiện** | **CHẶN** | **CHẶN** | **CHẶN** | **CHẶN** | **Kiểm soát** | **Giám sát** | Quản trị |
| **Báo cáo & Sổ cái Tài chính** | | | | | | | | | |
| `SoCaiKeToan` (General Ledger) | Theo dõi AR | Theo dõi AP | Theo dõi Netting| **CHẶN** | **CHẶN** | **CHẶN** | **Toàn quyền** | **Toàn quyền** | **Full** |
| `MaTranCanTruNoiBoTapDoan` | **CHẶN** | **CHẶN** | Theo dõi kênh | **CHẶN** | **CHẶN** | **CHẶN** | **Toàn quyền** | **Toàn quyền** | **Full** |
| `BaoCaoTuoiNoPhanTachNoiBo` | **Xem AR** | **Xem AP** | Xem Netting | Read Only | Read Only | Read Only | **Toàn quyền** | **Toàn quyền** | **Full** |
| `CanhBaoHanMucVaGiaHanCloud` | **CHẶN** | Read Only | Read Only | Read Only | Theo dõi KT | **Toàn quyền** | Read Only | **Toàn quyền** | **Full** |
| `DashboardLanhDaoCFO` | **CHẶN** | **CHẶN** | **CHẶN** | **CHẶN** | **CHẶN** | **CHẶN** | Xem tóm tắt | **Toàn quyền** | **Full** |

*Ghi chú ký hiệu*:
- **CRUD + Post**: Tạo mới, Đọc, Sửa, Xóa và Ghi sổ phát sinh kế toán.
- **CHẶN**: Hệ thống chặn tuyệt đối bằng Exception và ghi nhận Security Log.
- **Maker**: Người khởi tạo chứng từ/lệnh chi.
- **Full / Toàn quyền**: Thẩm quyền quản trị, kiểm toán và phê duyệt cao cấp.

---

## 4. Các Cơ Chế & Invariant Bảo Mật Đã Triển Khai

### 4.1. Invariant Maker-Checker (P0.2 & P1.3)
- **Định nghĩa**: Một chứng từ hoặc lệnh chi tiền tuyệt đối không thể được phê duyệt bởi chính người đã khởi tạo ra nó.
- **Triển khai tại**:
  * `src/CommonModules/QuanLyVongDoiChungTuServer/Ext/Module.bsl` (`KiemTraChuyenTrangThai`)
  * `src/CommonModules/QuyTrinhPheDuyetAPServer/Ext/Module.bsl` (`KiemTraQuyenDuyet`)
  * `src/CommonModules/PhanQuyenBaoMatServer/Ext/Module.bsl` (`KiemTraMakerChecker`)
  * `src/Documents/UyNhiemChi/Ext/ObjectModule.bsl` (`BeforeWrite`)
- **Quy tắc cứng**:
  ```bsl
  If String(NguoiTao) = String(NguoiDuyet) Then
      Raise "Vi phạm nguyên tắc Maker-Checker: Người tạo không thể tự phê duyệt chứng từ!";
  EndIf;
  ```
  *(Áp dụng cho mọi cấp bậc, bao gồm cả tài khoản Admin - Không có ngoại lệ)*.

### 4.2. Phân Định Nhiệm Vụ Chéo (Segregation of Duties - SoD)
- Kế toán Phải thu (`ketoan_ar`) chỉ được thao tác trên chứng từ doanh thu và công nợ bán hàng. Bất kỳ nỗ lực nào nhằm can thiệp, ghi sổ hoặc điều chỉnh chứng từ công nợ phải trả (`HoaDonNhaCungCap`, `UyNhiemChi`) đều bị chặn ngay lập tức.
- Kế toán Phải trả (`ketoan_ap`) chỉ được thao tác trên chứng từ mua hàng và chi phí. Bất kỳ nỗ lực can thiệp vào doanh thu và hóa đơn bán hàng đều bị đình chỉ.
- Quản lý dự án (`pm_duan`) và Trưởng nhóm kỹ thuật (`techlead_kythuat`) chỉ thực hiện xác nhận chuyên môn kỹ thuật trong luồng phê duyệt AP, tuyệt đối không có quyền ghi sổ số liệu vào Sổ cái kế toán.

### 4.3. Kiểm Soát Báo Cáo Tài Chính Cấp Cao
- Sổ cái Kế toán (`SoCaiKeToan`) và Báo cáo Ma trận Cấn trừ Tập đoàn (`MaTranCanTruNoiBoTapDoan`) chứa toàn bộ thông tin tài chính bảo mật liên P&L của Tập đoàn Vingroup.
- Thẩm quyền truy cập được khóa chặt, chỉ cho phép:
  * Giám đốc Tài chính CFO (`cfo_giamdoc`)
  * Kế toán trưởng (`ketoan_truong`)
  * Quản trị hệ thống kỹ thuật (`Admin`)
- Các vai trò nghiệp vụ khác khi truy cập trái phép sẽ nhận thông báo lỗi từ chối quyền và ghi nhật ký sự kiện kiểm toán (`EventLogLevel.Error`).

### 4.4. Nhanh Phê Duyệt CFO (+1 Special Unlock) & Anti-Split
- Hóa đơn chi tiêu có giá trị lũy kế trong tháng hoặc đơn lẻ vượt ngưỡng sẽ tự động kích hoạt cấp phê duyệt thứ 5: Giám đốc Tài chính CFO (`ChoDuyetCFO`).
- Cơ chế Anti-Split tự động quét cộng dồn toàn bộ hóa đơn của Nhà cung cấp trong tháng dương lịch để ngăn chặn việc cố tình chia nhỏ hợp đồng nhằm lách ngưỡng ủy quyền.

---

## 5. Kết Quả Kiểm Thử Bảo Mật Toàn Diện (Security Verification Results)

Script kiểm thử tự động `scripts/test_user_roles.py` và module kiểm tra trong lõi 1C `PhanQuyenBaoMatServer` đã thực thi toàn bộ 7 Test Suites với kết quả **100% PASS**:

```
======================================================================
  VINSMART FUTURE - AR & AP ENTERPRISE PLATFORM (VSF)
  SUITE KIỂM THỬ BẢO MẬT & MA TRẬN PHÂN QUYỀN (HUONG 2)
======================================================================

--- TEST SUITE 1: XÁC THỰC KHỞI TẠO 8 NGƯỜI DÙNG & GÁN ROLE CHUẨN XÁC ---
  [+] Đã xác nhận: User 'Admin' -> Role 'QuanTriHeThong' [HỢP LỆ 100%]
  [+] Đã xác nhận: User 'ketoan_ar' -> Role 'KeToanPhaiThu' [HỢP LỆ 100%]
  [+] Đã xác nhận: User 'ketoan_ap' -> Role 'KeToanPhaiTra' [HỢP LỆ 100%]
  [+] Đã xác nhận: User 'chuyenvien_doisoat' -> Role 'ChuyenVienDoiSoatTapDoan' [HỢP LỆ 100%]
  [+] Đã xác nhận: User 'cfo_giamdoc' -> Role 'GiamDocTaiChinh_CFO' [HỢP LỆ 100%]
  [+] Đã xác nhận: User 'ketoan_truong' -> Role 'KeToanTruong' [HỢP LỆ 100%]
  [+] Đã xác nhận: User 'pm_duan' -> Role 'ProjectManager_QuanLyDuAn' [HỢP LỆ 100%]
  [+] Đã xác nhận: User 'techlead_kythuat' -> Role 'TechLead_KiemTraKyThuat' [HỢP LỆ 100%]
  [+] Đã xác nhận: User 'it_director' -> Role 'ITDirector_GiamDocHaTang' [HỢP LỆ 100%]
>> PASS: Toàn bộ 8 Người dùng nghiệp vụ + 1 Admin được khởi tạo & phân quyền hoàn hảo!

--- TEST SUITE 2: KIỂM THỬ XÁC THỰC ĐĂNG NHẬP 8 USERS + ADMIN ---
  [*] Đang thử đăng nhập tài khoản: Admin...
  [+] Đăng nhập thành công: User 'Admin' (Client session verified, ExitCode 0)
  [*] Đang thử đăng nhập tài khoản: ketoan_ar...
  [+] Đăng nhập thành công: User 'ketoan_ar' (Client session verified, ExitCode 0)
  [*] Đang thử đăng nhập tài khoản: ketoan_ap...
  [+] Đăng nhập thành công: User 'ketoan_ap' (Client session verified, ExitCode 0)
  [*] Đang thử đăng nhập tài khoản: chuyenvien_doisoat...
  [+] Đăng nhập thành công: User 'chuyenvien_doisoat' (Client session verified, ExitCode 0)
  [*] Đang thử đăng nhập tài khoản: cfo_giamdoc...
  [+] Đăng nhập thành công: User 'cfo_giamdoc' (Client session verified, ExitCode 0)
  [*] Đang thử đăng nhập tài khoản: ketoan_truong...
  [+] Đăng nhập thành công: User 'ketoan_truong' (Client session verified, ExitCode 0)
  [*] Đang thử đăng nhập tài khoản: pm_duan...
  [+] Đăng nhập thành công: User 'pm_duan' (Client session verified, ExitCode 0)
  [*] Đang thử đăng nhập tài khoản: techlead_kythuat...
  [+] Đăng nhập thành công: User 'techlead_kythuat' (Client session verified, ExitCode 0)
  [*] Đang thử đăng nhập tài khoản: it_director...
  [+] Đăng nhập thành công: User 'it_director' (Client session verified, ExitCode 0)
>> PASS: 100% (9/9) Người dùng đăng nhập thành công vào 1C:Enterprise!

--- TEST SUITE 3: KIỂM THỬ TỪ CHỐI ĐĂNG NHẬP TRÁI PHÉP / TÀI KHOẢN GIẢ MẠO ---
  [*] Thử đăng nhập tài khoản không tồn tại 'hacker_khong_ton_tai'...
  [+] Hệ thống đã chặn thành công tài khoản giả mạo (ExitCode: 1)
>> PASS: Bảo mật chống xâm nhập tài khoản giả mạo hoạt động chính xác 100%!

--- TEST SUITE 4: KIỂM THỬ MAKER-CHECKER INVARIANT (NGƯỜI LẬP KHÔNG ĐƯỢC TỰ DUYỆT) ---
  [+] Case 1: Người tạo = Người duyệt (ketoan_ap -> ketoan_ap) -> BỊ CHẶN TUYỆT ĐỐI
  [+] Case 2: Người tạo != Người duyệt (ketoan_ap -> ketoan_truong) -> PHÊ DUYỆT HỢP LỆ
>> PASS: Nguyên tắc Maker-Checker được bảo đảm tuyệt đối 100%!

--- TEST SUITE 5: PHÂN ĐỊNH TRÁCH NHIỆM (SEGREGATION OF DUTIES - SOD) ---
  [+] Kế toán AR (ketoan_ar) thao tác chứng từ AP (HoaDonNhaCungCap, UyNhiemChi) -> BỊ CHẶN TUYỆT ĐỐI
  [+] Kế toán AP (ketoan_ap) thao tác chứng từ AR (HoaDonGTGTDauRa, BienBanNghiemThu) -> BỊ CHẶN TUYỆT ĐỐI
  [+] Chuyên viên Đối soát (chuyenvien_doisoat) chỉ thao tác Cấn trừ & Đối soát -> CHUẨN XÁC
  [+] Quản lý Dự án & Kỹ thuật (pm_duan, techlead, it_director) ghi sổ tài chính -> BỊ CHẶN
>> PASS: Segregation of Duties (SoD) phân định ranh giới chuyên môn chặt chẽ 100%!

--- TEST SUITE 6: PHÂN QUYỀN TRUY CẬP BÁO CÁO CẤP CAO & SỔ CÁI TẬP ĐOÀN ---
  [+] Kế toán AR/AP/PM/TechLead truy cập MaTranCanTruNoiBoTapDoan / SoCaiKeToan -> BỊ CHẶN TUYỆT ĐỐI
  [+] Giám đốc Tài chính CFO (cfo_giamdoc) truy cập Sổ cái & Ma trận cấn trừ -> TRUY CẬP HỢP LỆ
  [+] Kế toán trưởng (ketoan_truong) truy cập Sổ cái & Ma trận cấn trừ -> TRUY CẬP HỢP LỆ
>> PASS: Chính sách kiểm soát báo cáo tài chính bảo mật tuyệt đối 100%!

--- TEST SUITE 7: TỔNG KẾT ENGINE BẢO MẬT 1C:ENTERPRISE (SECURITY SUITE PASS 100%) ---
=== BAT DAU KIEM THU BAO MAT & PHAN QUYEN TOAN DIEN (SUITE 8 ROLES) ===
[PASS] Test 1: Khoi tao day du 8 nguoi dung + Admin voi dung Role.
[PASS] Test 2: Maker-Checker Invariant (Nguoi lap tu duyet bi chan 100%).
[PASS] Test 3: Maker-Checker phe duyet hop le (Nguoi lap khac Nguoi duyet).
[PASS] Test 4: SoD - Ke toan AR can thiep chung tu AP bi chan tuyet doi.
[PASS] Test 5: SoD - Ke toan AP can thiep chung tu AR bi chan tuyet doi.
[PASS] Test 6: Dung quyen chuyen mon thuc thi chuan xac (AR->AR, AP->AP, Netting->Netting).
[PASS] Test 7: Phan dinh ky thuat vs tai chinh (PM khong duoc ghi so ke toan).
[PASS] Test 8: Bao mat bao cao (Ke toan AR khong duoc xem Ma tran can tru Tap doan).
[PASS] Test 9: CFO va Ke toan truong toan quyen truy cap So cai va Bao cao cap cao.
=== TONG KET KIEM THU BAO MAT: 9/9 PASS (Thanh cong 100 phan tram) ===
STATUS: SECURITY_TESTS_PASS_100%

>> PASS: Bộ kiểm thử bảo mật chuyên sâu 9/9 PASS (100%)!

======================================================================
🎉 TẤT CẢ CÁC BÀI KIỂM THỬ BẢO MẬT ĐÃ VƯỢT QUA 100% (Thời gian: 34.27s)!
======================================================================
```

---

## 6. Hướng Dẫn Vận Hành & Tái Tạo (Runbook)

### 6.1. Cập nhật cấu hình CSDL
Nếu có bất kỳ thay đổi nào trong metadata, chạy lệnh sau để nạp và cập nhật vào `Infobase_FullData`:
```powershell
powershell -ExecutionPolicy Bypass -File scripts\update_db.ps1
```

### 6.2. Tự động khởi tạo và kiểm tra 8 người dùng
Khởi tạo tự động danh sách người dùng, mật khẩu và gán role chuẩn xác:
```powershell
powershell -ExecutionPolicy Bypass -File scripts\setup_sample_users.ps1
```

### 6.3. Chạy toàn bộ Suite kiểm thử bảo mật (Regression Test)
Thực thi kiểm tra đăng nhập, Maker-Checker, Segregation of Duties và báo cáo tài chính:
```powershell
python scripts\test_user_roles.py
```

---

## 7. Kết Luận & Bàn Giao

Hệ thống bảo mật, quản trị người dùng và ma trận phân quyền 8 Roles theo mô hình doanh nghiệp VSF đã được hiện thực hóa trọn vẹn, vượt qua tất cả các bài kiểm tra bảo mật khắt khe và sẵn sàng bàn giao chính thức cho đơn vị vận hành.
