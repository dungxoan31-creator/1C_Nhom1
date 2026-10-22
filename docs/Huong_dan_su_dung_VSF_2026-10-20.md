# Hướng dẫn sử dụng VINSMART FUTURE – Hệ thống Tài chính & Kế toán

## 1. Phạm vi và cách đọc tài liệu

Tài liệu này được lập từ file `VinSmart_Future_AdminFull_v5_SuaFont.dt` ở thư mục gốc khi file có SHA-256 `073080DE1DF644EE8F9A34E4D5E51D98D5BCBEC929685AAE94DBD3040A79A3BE` (hiện lưu lại là `*_pre_mockup_20261020.dt`). File đã được phục hồi vào **bản sao kiểm tra** và xuất XML bằng 1C 8.3.22.1704. Trong lúc dọn workspace, bản `.dt` chính được cập nhật thành file 1.093.027 byte, SHA-256 `1E6D7A2866517267257870AD8CEEA03B7584C495E155E0D526727FC085FF427A`. Tôi phục hồi và xuất lại bản mới: **161 file XML/BSL/TXT của cấu hình trùng với bản đã dùng để viết hướng dẫn** sau khi chuẩn hóa xuống dòng; dữ liệu demo trong hai DT khác nhau. Cấu hình có 6 phân hệ, 9 danh mục, 7 chứng từ, 2 sổ thông tin, 3 sổ tích lũy, 1 sổ cái, 5 vai trò và 12 form quản lý tự thiết kế. Màn hình thực tế còn phụ thuộc vai trò, dữ liệu và cách 1C hiển thị thanh lệnh chuẩn.

Trong các bảng dưới đây, **bắt buộc** nghĩa là thuộc tính 1C `FillChecking=ShowError`; “chỉ đọc” nghĩa là form chủ động khóa ô. Một trường **có trong đối tượng** chưa chắc hiện trên form thiết kế riêng. Danh sách cuối tài liệu ghi đủ trường metadata để tra cứu khi dùng form mặc định hoặc cấu hình nghiệp vụ. Tên trong dấu `` `...` `` là tên kỹ thuật để tìm đúng ô khi giao diện dịch khác nhau.

## 2. Bắt đầu từ màn hình trong ảnh

Ảnh hiện đang ở ngăn **Favorites**, giữa màn hình trắng. Đây là vùng các mục đã gắn sao, chưa phải danh sách chức năng. Bấm biểu tượng **☰** góc trên trái để mở menu chức năng/phân hệ; dùng ô **Search Ctrl+Shift+F** để tìm tên chức năng; biểu tượng **☆** thêm hoặc bỏ một mục khỏi Favorites; biểu tượng đồng hồ mở lịch sử. Dòng tên người dùng góc trên phải là tài khoản đang đăng nhập. Chuông là thông báo; các nút `_`, ô vuông, `×` là thu nhỏ, phóng to, đóng cửa sổ. Biểu tượng 1C mở menu ứng dụng. Những nút này thuộc vỏ giao diện 1C, không tạo chứng từ tài chính.

Khi đăng nhập tương tác, mã ứng dụng gọi mở **Bàn làm việc & Điều hành Web ERP**. Nếu vẫn chỉ có màn hình trắng: mở ☰ rồi chọn một phân hệ; tìm `Bàn làm việc` trong menu/tìm kiếm; kiểm tra tài khoản CFO có quyền mở xử lý; đóng và vào lại ứng dụng. Nếu cả menu lẫn tìm kiếm không thấy đối tượng, quản trị viên cần kiểm tra vai trò và nhật ký khởi động, vì ảnh một mình không xác định được lỗi. Không bấm **Làm mới (F5)** của dashboard khi dashboard chưa hiện.

### Các thao tác chuẩn trên danh sách và chứng từ

Trên danh sách 1C, lệnh chuẩn thường gồm **Tạo**, **Mở**, **Sao chép**, **Làm mới**, **Tìm**, **Thêm vào Favorites**; chứng từ có thêm **Ghi/Lưu**, **Ghi và đóng**, **Ghi sổ/Đăng**, **Hủy ghi sổ**, **Đánh dấu xóa** tùy quyền và trạng thái. Tên và vị trí nút chuẩn do client 1C quyết định, nên hãy nhìn thanh lệnh của form đang mở. **Ghi/Lưu** chỉ lưu bản nháp; **Ghi sổ** tạo bút toán/số dư; **Hủy ghi sổ** rút bút toán theo kiểm soát phụ thuộc. Sau khi ghi sổ, 5 form chứng từ thiết kế riêng chuyển sang chỉ đọc. `Số CT/Number` được hệ thống cấp và là ô chỉ đọc.

Trên 5 danh sách tự thiết kế, thanh lọc gồm **Kỳ**, **Trạng thái**, **Đối tác/Khách hàng/Nhà cung cấp**. Kỳ khai báo `TatCa/HomNay/ThangNay/QuyNay`; trạng thái thường khai báo `TatCa/DaGhiSo/BanNhap/DaHuy`, riêng danh sách AP có `ChoPheDuyet` thay `DaHuy`. Các bộ lọc kết hợp với nhau: kỳ lọc theo khoảng ngày của trường chứng từ `Date`, trạng thái lọc theo `Posted`/`DeletionMark` (hoặc trạng thái nghiệp vụ AP), còn đối tác lọc theo đối tác đã chọn. `TatCa` không giới hạn ngày. Cột **Đã ghi sổ** phản ánh `Posted`; nhấp dòng/số chứng từ để mở. Danh sách hiển thị số, ngày, đối tác, giá trị, trạng thái tùy loại (xem phụ lục form).

## 3. Menu phân hệ

| Phân hệ | Mở để làm gì | Mục khai báo trong phân hệ |
|---|---|---|
| Danh mục | Chuẩn bị dữ liệu gốc | Pháp nhân, Đối tác, Hợp đồng, Tài khoản tiền, Dịch vụ CNTT, Dự án, Khoản mục dòng tiền, Tiền tệ, Tỷ giá hối đoái, Bàn làm việc |
| Công nợ phải thu (AR) | Nghiệm thu, hóa đơn bán, thu tiền | Biên bản nghiệm thu giai đoạn, Hóa đơn GTGT đầu ra, Phiếu thu tiền khách hàng, Sổ chi tiết công nợ phải thu, Bàn làm việc |
| Công nợ phải trả (AP) | Hóa đơn mua, lệnh chi | Hóa đơn nhà cung cấp, Ủy nhiệm chi, Sổ chi tiết công nợ phải trả, Bàn làm việc |
| Ngân hàng & Quỹ | Thu/chi và đối soát | Phiếu thu tiền khách hàng, Ủy nhiệm chi, Bảng kê đối soát kênh thanh toán, Sổ chi tiết dòng tiền, Bàn làm việc |
| Cấn trừ công nợ | Khấu trừ hai khoản AR/AP của cùng đối tác liên kết | Cấn trừ công nợ nội bộ, Bàn làm việc |
| Sổ cái & Đồng bộ | Xem tài khoản và bút toán | Hệ thống tài khoản, Sổ cái kế toán, Bàn làm việc |

Mục **Bàn làm việc** lặp trong nhiều phân hệ nhưng mở cùng một xử lý. Danh mục **Chi nhánh** và sổ **Phân quyền chi nhánh** có trong cấu hình nhưng **không được khai báo trong nội dung phân hệ Danh mục**; quản trị viên có thể phải mở qua tìm kiếm/cấu hình quyền. Các hằng số cũng không được đưa vào menu phân hệ thông thường.

## 4. Bàn làm việc, từng nút và chỉ số

Dashboard mở một vùng HTML. Phía trên có nhãn ngày cập nhật (chỉ hiển thị) và nút **Làm mới (F5)**: tải lại dữ liệu KPI; mã xử lý click gọi máy chủ và báo “Làm mới thành công”. Các ô hành động nhanh:

| Ô/nút | Tác dụng |
|---|---|
| **+ Hóa đơn bán ra** | Mở form tạo Hóa đơn GTGT đầu ra. |
| **+ Hóa đơn mua vào** | Mở form tạo Hóa đơn nhà cung cấp. |
| **+ Lập Ủy nhiệm chi** | Mở form tạo Ủy nhiệm chi. |
| **+ Lập Phiếu thu** | Mở form tạo Phiếu thu tiền khách hàng. |
| **⚡ Bàn duyệt hàng loạt** | Mở hàng đợi Maker–Checker. |

Bốn thẻ số liệu là **Doanh thu bán ra** và số hóa đơn đã ghi sổ, **Phải thu AR** và nợ quá hạn, **Phải trả AP** và khoản đến hạn trong 7 ngày, **Tiền khả dụng**. Hai biểu đồ là **Doanh thu và tiền thu trong 6 tháng** và **Cơ cấu tuổi nợ AR** (phần trăm trong hạn và các nhóm tuổi nợ). Hai bảng dưới là **Top khách hàng nợ quá hạn** (mã, tên, số dư, quá hạn) và **Chứng từ cần xử lý** (loại, số, số tiền; có huy hiệu số lượng). Các thẻ/bảng này là dữ liệu đọc; template không khai báo ô chọn kỳ hoặc bộ lọc tương tác trên dashboard. Mã form đang gọi dữ liệu `ThangNay`.

### Bàn duyệt hàng loạt

Bảng hiển thị **Loại chứng từ**, **Số chứng từ** (bấm để mở), **Ngày**, **Đối tác**, **Số tiền**, **Trạng thái**; phía trên là số chứng từ chờ và tổng giá trị. **Làm mới** đọc lại danh sách. **Phê duyệt toàn bộ** xử lý *toàn bộ hàng đợi đang trả về*, không có ô tick chọn từng dòng trên form này. Kết quả thông báo số thành công/thất bại. Hàng đợi gồm tối đa 20 hóa đơn AP và 20 ủy nhiệm chi cho các trạng thái phù hợp vai trò; AR/AP thường không thấy hàng đợi nếu không có quyền Kế toán trưởng/CFO. Hóa đơn AP trong ngưỡng được Kế toán trưởng duyệt và ghi sổ; trên ngưỡng chuyển CFO. Ủy nhiệm chi ở `Chờ duyệt` chuyển `Đã duyệt`; **gửi ngân hàng là nút riêng**; CFO ghi sổ sau xác nhận ngân hàng hoặc tiền hoàn. Quản trị hệ thống không được dùng vai trò Admin để duyệt thay.

## 5. Chuẩn bị danh mục trước khi nhập chứng từ

Mở **Danh mục → [tên danh mục] → Tạo**, nhập mã/tên và các ô bên dưới, rồi **Ghi và đóng**. Trong 1C, ô chọn tham chiếu (pháp nhân, đối tác, hợp đồng, tiền tệ…) cho phép chọn bản ghi đã có; dấu chọn `✓` là Boolean. Mỗi danh mục có **Mã/Code**, **Tên/Description** và ô **Đánh dấu xóa** chuẩn. Mã có thể để trống theo thuộc tính metadata của nhiều danh mục, nhưng thực tế các luồng gốc và tích hợp dùng mã cố định, nên hãy quản lý mã nhất quán.

| Danh mục | Các ô riêng và cách nhập |
|---|---|
| **Chi nhánh** | Chỉ Mã và Tên. Tạo chi nhánh trước pháp nhân khi phân quyền theo chi nhánh. |
| **Pháp nhân** | `ChiNhanh`: chi nhánh sở hữu; `MaSoThue`: mã số thuế; `DiaChi`: địa chỉ. |
| **Đối tác** | `LoaiDoiTac`: loại khách/NCC/nội bộ; `LaBenLienKet`: đánh dấu đối tác liên kết, bắt buộc về mặt nghiệp vụ cho cấn trừ; `DaDangKyThueTrucTiep`: đăng ký thuế trực tiếp; `MaSoThue`: **bắt buộc**; `DiaChi`; `SoTaiKhoanNganHang`; `TenNganHang`. Hai ô ngân hàng phải có trước khi gửi lệnh chi. |
| **Hợp đồng** | `PhapNhan`: **bắt buộc**; `ChuSoHuu`: đối tác/chủ sở hữu; `DongTienThanhToan`: tiền tệ; `GrossUpThue`: áp dụng gross-up; `HanThanhToanNgay`: thời hạn thanh toán theo ngày. |
| **Dịch vụ CNTT** | `MaDichVu`, `TenDichVu`, `TyLeVATMacDinh`: mã, tên, tỷ lệ VAT mặc định. |
| **Dự án** | `PhapNhan`, `MaDuAn`, `TenDuAn`: pháp nhân, mã và tên dự án. |
| **Khoản mục dòng tiền** | `LoaiDongTien`: nhập `Thu` hoặc `Chi` theo luồng. Cần `Thu` cho đối soát kênh thanh toán. |
| **Tiền tệ** | `MaTienTe` (mã 3 ký tự), `TenDayDu`; mã chuẩn của đối tượng (`Code`) cũng được logic dùng, ví dụ `VND`. |
| **Tài khoản tiền** | `TienTe`, `SoTaiKhoan`, `NganHang`; thêm 6 ô tích hợp ngân hàng ở mục 9. |

**Tỷ giá hối đoái** là sổ thông tin theo ngày: chọn **Ngày/Period**, `TienTe`, nhập `TyGiaMua` (mua), `TyGiaBan` (bán), `TyGiaHachToan` (hạch toán), rồi ghi. **Hệ thống tài khoản** là kế hoạch tài khoản: Mã, Tên, tài khoản cha, loại tài khoản, ngoại bảng, thứ tự; `MaLogic`, `TenTaiKhoan`, `TinhChat` là các ô riêng. Nhiều bút toán tìm mã tài khoản cụ thể; thay mã mà không rà lại logic có thể làm ghi sổ thất bại.

## 6. Quy trình công nợ phải thu (AR)

### 6.1 Biên bản nghiệm thu giai đoạn

Vào **Công nợ phải thu → Biên bản nghiệm thu giai đoạn → Tạo**. Tab **1. Thông tin chung**: `Number` chỉ đọc; nhập `Date`, `NgayNghiemThu`, `PhapNhan`, `DoiTac`, `HopDong`; nhập `GiaTriNghiemThuChuaVAT`, `TyLeVAT`; tick `ApDungGiamThueGTGT` **chỉ khi hàng/dịch vụ đủ điều kiện**; `TienVAT` được tính lại theo thay đổi; `TongGiaTri` chỉ đọc. Tab **2. Chi tiết nghiệm thu** hiển thị lại ô giá trị trước thuế, dùng cùng trường dữ liệu. Tab **3. Thuế & HĐĐT** có `TrangThai`. Tab **4. Nhật ký & Phê duyệt** có `DienGiai`. Dải HTML trên cùng hiển thị trạng thái, không phải ô nhập. Lưu bản nháp, chuyển trạng thái qua các bước phê duyệt nghiệp vụ, rồi người có quyền **Ghi sổ**. Ghi sổ tạo phải thu và bút toán doanh thu. Chỉ tiêu ngày nghiệm thu và điều kiện giảm VAT được kiểm tra khi đổi ô; tỷ lệ VAT 8% không được tùy ý áp dụng ngoài điều kiện của hệ thống.

Danh sách biên bản có bộ lọc **Kỳ/Trạng thái/Khách hàng** và cột Số CT, Ngày lập, Khách hàng, Tổng giá trị, Trạng thái, Đã ghi sổ. Các trường metadata không có ô trên form riêng như `ChiNhanh`, `NguoiTao`, `NguoiDuyet` được ghi ở phụ lục.

### 6.2 Hóa đơn GTGT đầu ra

Vào **Công nợ phải thu → Hóa đơn GTGT đầu ra → Tạo**. Tab **1. Thông tin chung**: Số CT chỉ đọc; Ngày; Pháp nhân; Đối tác; Hợp đồng; `BienBanNghiemThu` chọn biên bản đã ghi sổ; `TienChuaThue`; `ThueSuatVAT` chỉ đọc; tick điều kiện giảm VAT (`ApDungGiamThueGTGT`); `TienThueVAT`; `TongTienThanhToan` chỉ đọc. Khi chọn biên bản, ô tick điều kiện giảm VAT bị khóa và theo chứng từ nguồn. Đổi tiền trước thuế/tick sẽ tính lại VAT và tổng. Tab **2. Chi tiết hàng hóa/dịch vụ** lặp tiền trước thuế và VAT; tab **3. Thuế & HĐĐT** lặp VAT và tổng (tổng chỉ đọc); tab **4. Nhật ký & Phê duyệt** có diễn giải. Nút riêng **Xem chứng từ liên quan** hiện thông báo chuỗi Hợp đồng → Hóa đơn → Phiếu thu, **không mở danh sách liên kết**.

Các ô số hóa đơn thuế `SoHoaDon`, ký hiệu `KyHieu`, ngày hóa đơn `NgayHoaDon` là metadata **bắt buộc** nhưng không nằm trong form riêng đang khai báo. Mã có tự điền ngày hóa đơn bằng ngày hiện tại khi khởi tạo, nhưng **không thấy tự sinh `SoHoaDon` và `KyHieu` trên form**; người nhập cần đường nhập phù hợp do quản trị viên cấu hình hoặc yêu cầu bổ sung form nếu lưu từ UI bị chặn vì thiếu ô. Trạng thái HĐĐT là một trường nội bộ; cấu hình không có tích hợp phát hành HĐĐT trực tiếp. Danh sách có Kỳ báo cáo/Trạng thái/Đối tác và cột Số CT, Ngày lập, Khách hàng, Tổng tiền, Đã ghi sổ.

### 6.3 Phiếu thu tiền khách hàng

Vào **Công nợ phải thu** hoặc **Ngân hàng & Quỹ → Phiếu thu tiền khách hàng → Tạo**. Tab **1. Thông tin chung**: Số CT chỉ đọc, Ngày, Pháp nhân, Đối tác, Hợp đồng, Tài khoản tiền, Khoản mục dòng tiền, Số tiền. Tab **2. Chi tiết thu tiền** lặp Số tiền; tab **3. Đối soát chứng từ** lặp Hợp đồng; tab **4. Diễn giải & Nhật ký** có Diễn giải. Nút **Xem chứng từ liên quan** chỉ hiện thông báo chuỗi chứng từ. Sau khi gắn chứng từ gốc và kiểm tra số dư AR còn lại, **Ghi sổ** làm giảm phải thu, tăng tiền và tạo bút toán sổ cái; thu quá dư bị từ chối. `ChungTuGoc`, `TienTe`, `SoTienNgoaiTe`, `TyGia`, `NgayThu` tồn tại trong metadata nhưng không có ô trên form riêng. Ngày thu và VND được mã tự điền; chứng từ gốc chỉ được tự gắn khi đối tượng được tạo với dữ liệu nguồn qua mã, còn `BasedOn` của metadata đang trống. Danh sách có lọc Kỳ/Trạng thái/Khách hàng và cột Số CT, Ngày lập, Khách hàng, Số tiền, Diễn giải, Đã ghi sổ.

## 7. Quy trình công nợ phải trả (AP)

### 7.1 Hóa đơn nhà cung cấp

Vào **Công nợ phải trả → Hóa đơn nhà cung cấp → Tạo**. Tab **1. Thông tin chung**: Số CT chỉ đọc; Ngày; Pháp nhân; Nhà cung cấp (`DoiTac`); Hợp đồng; Số hóa đơn (`SoHoaDon`); Tiền dịch vụ (`TienDichVu`); Tiền VAT (`TienThueVAT`); Tổng tiền (`TongTien`) chỉ đọc. Đổi Tiền dịch vụ trên form tính VAT tạm theo 10% và cập nhật tổng; kiểm tra lại theo hóa đơn thực tế/FCT trước khi lưu. Tab **2. Chi tiết hàng hóa/dịch vụ** lặp Tiền dịch vụ/VAT; tab **3. Trạng thái phê duyệt** có `TrangThai`; tab **4. Diễn giải & Nhật ký** có `DienGiai`. **Xem chứng từ liên quan** chỉ thông báo chuỗi Hợp đồng → Hóa đơn NCC → Ủy nhiệm chi. `NgayHoaDon`, `TienTe` là metadata bắt buộc nhưng không hiện ở form riêng; mã tự điền ngày hiện tại và VND khi tạo mới. Các trường tỷ giá, FCT và tài khoản chi phí cũng chưa có ô ở form riêng; giao diện hiện tại không cho nhập thủ công những trường này.

Lưu bản nháp, đưa vào `Chờ Kế toán trưởng duyệt`; Kế toán trưởng duyệt. Nếu `TongTien` vượt **Ngưỡng chi tiền cần CFO phê duyệt**, hóa đơn chuyển `Chờ CFO duyệt`; nếu không, Kế toán trưởng có thể ghi sổ. CFO ghi sổ hóa đơn thuộc hàng đợi của mình. Không để người lập tự duyệt. Danh sách có lọc Kỳ/Trạng thái/Nhà cung cấp và cột Số CT, Ngày lập, Nhà cung cấp, Tổng tiền, Trạng thái, Đã ghi sổ.

### 7.2 Ủy nhiệm chi và hoàn tiền

Vào **Công nợ phải trả** hoặc **Ngân hàng & Quỹ → Ủy nhiệm chi → Tạo**. Tab **1. Thông tin chung**: Số CT chỉ đọc; Ngày; Pháp nhân; Đối tác thụ hưởng; Hợp đồng; Tài khoản tiền; Khoản mục dòng tiền; Số tiền. Tab **2. Chi tiết lệnh chi** lặp Số tiền. Tab **3. Trạng thái thanh toán** có `TrangThai` và ba ô chỉ đọc **Trạng thái ngân hàng**, **Mã giao dịch ngân hàng**, **Thời điểm gửi ngân hàng**. Tab **4. Diễn giải & Nhật ký** có Diễn giải. **Xem chứng từ liên quan** chỉ hiện thông báo Hóa đơn NCC → Ủy nhiệm chi. Danh sách có Kỳ/Trạng thái/Đối tác, cột Số CT, Ngày lập, Đối tác thụ hưởng, Số tiền, Trạng thái lệnh, Đã ghi sổ.

Luồng chi tiền: chọn hóa đơn NCC **đã ghi sổ** làm `ChungTuGoc`, đối tác/hợp đồng/pháp nhân/tiền tệ trùng hóa đơn, nhập số tiền không vượt AP còn lại; lưu trạng thái `Chờ duyệt`; Kế toán trưởng duyệt thành `Đã duyệt`; trên form xuất hiện nút **Gửi lệnh chi ngân hàng** cho Kế toán trưởng nếu tài khoản ngân hàng đã cấu hình. Nút gửi gọi HTTP, nhận `ACCEPTED` cùng mã giao dịch, chuyển `Đã gửi ngân hàng` nhưng **chưa ghi sổ**. CFO duyệt/ghi sổ sau đó; hệ thống giảm AP và tiền, kiểm tra số dư ngân hàng. Nếu gửi thất bại, xem thông báo “Chưa gửi được lệnh chi” và ô trạng thái ngân hàng; không tự suy ra giao dịch đã thành công.

Luồng hoàn tiền NCC dùng cùng loại chứng từ với `LaTraSoatHoanTra` bật và `ChungTuGoc` là ủy nhiệm chi gốc đã ghi sổ. Khoản hoàn phải khớp toàn bộ pháp nhân, NCC, hợp đồng, tài khoản, tiền tệ và số tiền với lệnh gốc. Kế toán trưởng duyệt; CFO thấy nút **Xác nhận hoàn tiền ngân hàng** khi thỏa điều kiện; chỉ khi ngân hàng trả `REFUND_RECEIVED` và mã giao dịch thì mới chuyển `Đã nhận hoàn tiền`, rồi CFO ghi sổ. Không dùng nút **Gửi lệnh chi** cho khoản tiền *đi vào* tài khoản. Các ô nguồn, tiền tệ, tỷ giá, phí ngân hàng và cờ hoàn tiền hiện **không có trên form thiết kế riêng**; cần một giao diện nhập thích hợp trước khi dùng luồng đó bằng tay.

## 8. Hai chứng từ dùng form mặc định

### Cấn trừ công nợ nội bộ

Mở **Cấn trừ công nợ → Cấn trừ công nợ nội bộ → Tạo**. Form mặc định lấy trường từ metadata: Ngày, Số tự động; `PhapNhan`, `DoiTac`, `ChungTuAR` (biên bản hoặc hóa đơn đầu ra), `ChungTuAP` (hóa đơn NCC), `SoTien` đều bắt buộc; `NguoiLap`, `NguoiDuyet`, `DienGiai` để theo dõi. Chỉ dùng cho đối tác có `LaBenLienKet`, hai chứng từ gốc đã ghi sổ, cùng pháp nhân/đối tác và AP bằng VND. Số cấn trừ phải dương, không vượt số dư nhỏ hơn giữa AR và AP. **Ghi sổ** giảm cả hai sổ chi tiết và tạo Nợ 3312/Có 1312, không tạo biến động tiền. **Hủy ghi sổ** hoàn tác nếu không vướng chứng từ phụ thuộc. Cấu hình hiện chỉ xử lý cấn trừ song phương bằng VND.

### Bảng kê đối soát kênh thanh toán

Mở **Ngân hàng & Quỹ → Bảng kê đối soát kênh thanh toán → Tạo**. Form mặc định: Ngày, Số tự động; bắt buộc `PhapNhan`, `DoiTacTrungGian`, `TaiKhoanTien`, `KhoanMucDongTien`, `TienTe`, `KenhThanhToan`, `TongTienGiaoDich` (gross), `TongPhi` (fee), `TongTienThucNhan` (net); thêm `NguoiLap`, `NguoiDuyet`, `DienGiai`. Nhập kênh `VNPAY` hoặc `ONEPAY`. Kiểm tra **gross = net + fee**, gross/net dương, phí không âm; hiện yêu cầu VND, tài khoản tiền cùng tiền tệ và khoản mục dòng tiền loại `Thu`. **Ghi sổ** ghi đúng tiền thực nhận vào sổ tiền, phí vào chi phí và xóa khoản đang đối soát/clearing trên sổ cái. Đây là chứng từ đối soát từ số liệu đã có, không phải màn hình tải sao kê tự động hay kết nối gateway trực tiếp.

## 9. Cấu hình tài khoản ngân hàng và các nút ngân hàng

Mở **Danh mục → Tài khoản tiền**; ngoài tên/mã, nhập `TienTe`, `SoTaiKhoan`, `NganHang`, rồi các ô dưới đây trên form danh mục mặc định:

| Ô | Ý nghĩa |
|---|---|
| `BankApiHost` | Host HTTP của cổng ngân hàng, không gồm protocol/path. |
| `BankApiPort` | Cổng; phải lớn hơn 0. |
| `BankApiPath` | Đường dẫn API gửi lệnh chi. |
| `BankRefundConfirmationPath` | Đường dẫn API xác nhận tiền hoàn. |
| `BankApiTimeoutSeconds` | Thời gian chờ; giá trị không dương dùng mặc định 10 giây. |
| `BankApiUseTLS` | Tick để dùng TLS. |

Nút **Gửi lệnh chi ngân hàng** chỉ hiện cho Kế toán trưởng với lệnh chưa ghi sổ, trạng thái `Đã duyệt`, nguồn là hóa đơn AP đã ghi sổ; mã cũng kiểm tra thông tin ngân hàng NCC, tiền tệ, số dư AP. Nút **Xác nhận hoàn tiền ngân hàng** chỉ hiện cho CFO với chứng từ hoàn chưa ghi sổ, đã duyệt, lệnh gốc đã ghi sổ và được ngân hàng chấp nhận. Phản hồi API phải là JSON có `status` và `transactionId`; gửi chi yêu cầu `ACCEPTED`, hoàn tiền yêu cầu `REFUND_RECEIVED`. Không thấy cơ chế khai báo chứng thư/chữ ký hay bí mật ngân hàng trong các ô này; cổng thực tế cần adapter phù hợp.

## 10. Tra cứu sổ, tỷ giá, phân quyền và hằng số

**Sổ chi tiết công nợ phải thu** và **phải trả** có chiều Pháp nhân, Đối tác, Hợp đồng, Chứng từ gốc; hai số tiền là VND và ngoại tệ. **Sổ chi tiết dòng tiền** có Pháp nhân, Tài khoản tiền, Tiền tệ, Khoản mục; số tiền VND/ngoại tệ. **Sổ cái kế toán** có Pháp nhân, Tiền tệ, tài khoản Nợ/Có, số tiền, tỷ giá, diễn giải và các chiều đối tác/hợp đồng/chứng từ/tài khoản tiền ở hai vế. Các sổ này dùng để đọc/đối soát sau **Ghi sổ**; tránh nhập tay trực tiếp vào sổ phát sinh khi quy trình yêu cầu chứng từ gốc.

**Phân quyền chi nhánh** là sổ thông tin độc lập: mỗi dòng chọn `NguoiDung` (tên đăng nhập) và `ChiNhanh`. `PhapNhan.ChiNhanh` và `DuAn.PhapNhan` phục vụ phạm vi chi nhánh. Các vai trò: **Kế toán phải thu**, **Kế toán phải trả**, **Kế toán trưởng**, **Giám đốc Tài chính/CFO**, **Quản trị hệ thống**. Quyền xem/sửa/phê duyệt phụ thuộc vai trò và điều kiện chi nhánh; nếu không thấy menu/bản ghi, kiểm tra người dùng/chi nhánh thay vì nhập lại chứng từ ở nơi khác.

Ba hằng số: `PhapNhanMacDinh` chọn pháp nhân mặc định; `NguongPheDuyetChiTienCFO` là ngưỡng duyệt CFO (mã dùng 500.000.000 VND khi giá trị không dương); `ChoPhepSinhDuLieuMau` chỉ cho phép sinh dữ liệu mẫu trên bản sao UAT. Không dùng chức năng sinh dữ liệu mẫu trên cơ sở dữ liệu thật.

## 11. Những gì hiện chưa có nút trên giao diện

7 chứng từ đều có nhiều trường metadata, nhưng 5 form thiết kế riêng chỉ trình bày một phần. Một số trường **bắt buộc theo metadata** không xuất hiện trên form, nổi bật là số/ký hiệu/ngày hóa đơn đầu ra, ngày/tiền tệ hóa đơn AP, và nguồn/tiền tệ phiếu thu hoặc ủy nhiệm chi. Vì vậy hướng dẫn không thể cam kết quy trình nhập tay từ các form hiện tại sẽ đi trọn nếu hệ thống yêu cầu trường còn ẩn. Có thể phải dùng form mặc định do quản trị viên cấu hình hoặc sửa form để lộ các ô đó. Phụ lục ghi đủ để đối chiếu.

Các trạng thái kỹ thuật như phê duyệt kỹ thuật/PM/IT Director được định nghĩa trong enum AP, nhưng hàng đợi duyệt hàng loạt đang chỉ xử lý nhánh Kế toán trưởng/CFO. Dashboard, sổ và chứng từ không tạo báo cáo tài chính pháp định, tờ khai VAT, phát hành hóa đơn điện tử, nhập sao kê ngân hàng hay báo cáo tồn kho. Cấu hình có API gửi lệnh chi/xác nhận hoàn tiền dựa trên host đã nhập, song tài liệu này chỉ xác nhận mã nguồn và XML của `.dt` hiện tại; chưa chạy từng nút trên phiên giao diện trong ảnh.

## 12. Phụ lục đối chiếu đầy đủ

Phần dưới được kết xuất từ đúng XML của `.dt`. **Trường metadata** bao gồm cả trường chưa có ô trên form; **điều khiển form** liệt kê từng ô, checkbox, tab, nút riêng, cột danh sách. Các lệnh chuẩn của nền tảng 1C đã giải thích tại mục 2.

<!-- GENERATED INVENTORY -->
### A. Toàn bộ trường của từng đối tượng

#### Danh mục

**Chi nhánh** (`ChiNhanh`)

Trường chuẩn: `Code` (Mã), `Description` (Tên), `DeletionMark` (Đánh dấu xóa).

**Dịch vụ CNTT** (`DichVuCNTT`)

Trường chuẩn: `Code` (Mã), `Description` (Tên), `DeletionMark` (Đánh dấu xóa).

| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |
|---|---|---|---|
| `MaDichVu` | Mã dịch vụ | xs:string |  |
| `TenDichVu` | Tên dịch vụ | xs:string |  |
| `TyLeVATMacDinh` | Thuế suất GTGT mặc định (%) | xs:decimal |  |

**Đối tác** (`DoiTac`)

Trường chuẩn: `Code` (Mã), `Description` (Tên), `DeletionMark` (Đánh dấu xóa).

| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |
|---|---|---|---|
| `LaBenLienKet` | Là bên liên kết | xs:boolean |  |
| `DaDangKyThueTrucTiep` | Đã đăng ký thuế trực tiếp | xs:boolean |  |
| `LoaiDoiTac` | Loại đối tác | EnumRef.LoaiDoiTac |  |
| `MaSoThue` | Mã số thuế | xs:string | Có |
| `DiaChi` | Địa chỉ | xs:string |  |
| `SoTaiKhoanNganHang` | Số tài khoản ngân hàng | xs:string |  |
| `TenNganHang` | Tên ngân hàng | xs:string |  |

**Dự án** (`DuAn`)

Trường chuẩn: `Code` (Mã), `Description` (Tên), `DeletionMark` (Đánh dấu xóa).

| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |
|---|---|---|---|
| `MaDuAn` | Mã dự án | xs:string |  |
| `TenDuAn` | Tên dự án | xs:string |  |
| `PhapNhan` | Pháp nhân | CatalogRef.PhapNhan |  |

**Hợp đồng** (`HopDong`)

Trường chuẩn: `Code` (Mã), `Description` (Tên), `DeletionMark` (Đánh dấu xóa).

| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |
|---|---|---|---|
| `PhapNhan` | Pháp nhân | CatalogRef.PhapNhan | Có |
| `ChuSoHuu` | Chủ sở hữu (Đối tác) | CatalogRef.DoiTac |  |
| `GrossUpThue` | Tính gộp thuế (gross-up) | xs:boolean |  |
| `HanThanhToanNgay` | Hạn thanh toán (ngày) | xs:decimal |  |
| `DongTienThanhToan` | Đồng tiền thanh toán | CatalogRef.TienTe |  |

**Khoản mục dòng tiền** (`KhoanMucDongTien`)

Trường chuẩn: `Code` (Mã), `Description` (Tên), `DeletionMark` (Đánh dấu xóa).

| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |
|---|---|---|---|
| `LoaiDongTien` | Loại dòng tiền | xs:string |  |

**Pháp nhân** (`PhapNhan`)

Trường chuẩn: `Code` (Mã), `Description` (Tên), `DeletionMark` (Đánh dấu xóa).

| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |
|---|---|---|---|
| `MaSoThue` | Mã số thuế | xs:string |  |
| `DiaChi` | Địa chỉ | xs:string |  |
| `ChiNhanh` | ChiNhanh | CatalogRef.ChiNhanh |  |

**Tài khoản tiền** (`TaiKhoanTien`)

Trường chuẩn: `Code` (Mã), `Description` (Tên), `DeletionMark` (Đánh dấu xóa).

| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |
|---|---|---|---|
| `SoTaiKhoan` | Số tài khoản | xs:string |  |
| `NganHang` | Ngân hàng | xs:string |  |
| `TienTe` | Tiền tệ | CatalogRef.TienTe |  |
| `BankApiHost` | BankApiHost | xs:string |  |
| `BankApiPort` | BankApiPort | xs:decimal |  |
| `BankApiPath` | BankApiPath | xs:string |  |
| `BankRefundConfirmationPath` | Đường dẫn xác nhận ngân hàng nhận hoàn tiền | xs:string |  |
| `BankApiTimeoutSeconds` | BankApiTimeoutSeconds | xs:decimal |  |
| `BankApiUseTLS` | BankApiUseTLS | xs:boolean |  |

**Tiền tệ** (`TienTe`)

Trường chuẩn: `Code` (Mã), `Description` (Tên), `DeletionMark` (Đánh dấu xóa).

| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |
|---|---|---|---|
| `MaTienTe` | Mã tiền tệ (ISO 4217) | xs:string |  |
| `TenDayDu` | Tên đầy đủ | xs:string |  |

#### Chứng từ

**Biên bản nghiệm thu giai đoạn** (`BienBanNghiemThuGiaiDoan`)

Trường chuẩn: `Number` (Số tự động), `Date` (Ngày, bắt buộc), `Posted` (Đã ghi sổ), `DeletionMark` (Đánh dấu xóa).

| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |
|---|---|---|---|
| `PhapNhan` | Pháp nhân | CatalogRef.PhapNhan | Có |
| `ChiNhanh` | Chi nhánh | CatalogRef.ChiNhanh |  |
| `DoiTac` | Đối tác | CatalogRef.DoiTac | Có |
| `HopDong` | Hợp đồng | CatalogRef.HopDong | Có |
| `GiaTriNghiemThuChuaVAT` | Giá trị nghiệm thu chưa thuế GTGT | xs:decimal | Có |
| `TyLeVAT` | Thuế suất GTGT (%) | xs:decimal |  |
| `TienVAT` | Tiền thuế GTGT | xs:decimal |  |
| `TongGiaTri` | Tổng giá trị | xs:decimal | Có |
| `TrangThai` | Trạng thái | EnumRef.TrangThaiNghiemThuAR | Có |
| `NguoiTao` | Người tạo | xs:string |  |
| `NguoiDuyet` | Người duyệt | xs:string |  |
| `NgayNghiemThu` | Ngày nghiệm thu | xs:dateTime |  |
| `DienGiai` | Diễn giải | xs:string |  |
| `ApDungGiamThueGTGT` | ApDungGiamThueGTGT | xs:boolean |  |

**Cấn trừ công nợ nội bộ** (`CanTruCongNoNoiBo`)

Trường chuẩn: `Number` (Số tự động), `Date` (Ngày, bắt buộc), `Posted` (Đã ghi sổ), `DeletionMark` (Đánh dấu xóa).

| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |
|---|---|---|---|
| `PhapNhan` | PhapNhan | CatalogRef.PhapNhan | Có |
| `DoiTac` | DoiTac | CatalogRef.DoiTac | Có |
| `ChungTuAR` | ChungTuAR | DocumentRef.BienBanNghiemThuGiaiDoan, DocumentRef.HoaDonGTGTDauRa | Có |
| `ChungTuAP` | ChungTuAP | DocumentRef.HoaDonNhaCungCap | Có |
| `SoTien` | SoTien | xs:decimal | Có |
| `NguoiLap` | NguoiLap | xs:string |  |
| `NguoiDuyet` | NguoiDuyet | xs:string |  |
| `DienGiai` | DienGiai | xs:string |  |

**Bảng kê đối soát kênh thanh toán** (`DoiSoatKenhThanhToan`)

Trường chuẩn: `Number` (Số tự động), `Date` (Ngày, bắt buộc), `Posted` (Đã ghi sổ), `DeletionMark` (Đánh dấu xóa).

| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |
|---|---|---|---|
| `PhapNhan` | PhapNhan | CatalogRef.PhapNhan | Có |
| `DoiTacTrungGian` | DoiTacTrungGian | CatalogRef.DoiTac | Có |
| `TaiKhoanTien` | TaiKhoanTien | CatalogRef.TaiKhoanTien | Có |
| `KhoanMucDongTien` | KhoanMucDongTien | CatalogRef.KhoanMucDongTien | Có |
| `TienTe` | TienTe | CatalogRef.TienTe | Có |
| `KenhThanhToan` | KenhThanhToan | xs:string | Có |
| `TongTienGiaoDich` | TongTienGiaoDich | xs:decimal | Có |
| `TongPhi` | TongPhi | xs:decimal | Có |
| `TongTienThucNhan` | TongTienThucNhan | xs:decimal | Có |
| `NguoiLap` | NguoiLap | xs:string |  |
| `NguoiDuyet` | NguoiDuyet | xs:string |  |
| `DienGiai` | DienGiai | xs:string |  |

**Hóa đơn GTGT đầu ra** (`HoaDonGTGTDauRa`)

Trường chuẩn: `Number` (Số tự động), `Date` (Ngày, bắt buộc), `Posted` (Đã ghi sổ), `DeletionMark` (Đánh dấu xóa).

| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |
|---|---|---|---|
| `PhapNhan` | Pháp nhân | CatalogRef.PhapNhan | Có |
| `DoiTac` | Đối tác | CatalogRef.DoiTac | Có |
| `MaSoThueNguoiMua` | Mã số thuế | xs:string |  |
| `DiaChiNguoiMua` | Địa chỉ | xs:string |  |
| `HopDong` | Hợp đồng | CatalogRef.HopDong | Có |
| `BienBanNghiemThu` | Biên bản nghiệm thu | DocumentRef.BienBanNghiemThuGiaiDoan | Có |
| `SoHoaDon` | Số hóa đơn | xs:string | Có |
| `KyHieu` | Ký hiệu hóa đơn | xs:string | Có |
| `NgayHoaDon` | Ngày hóa đơn | xs:dateTime | Có |
| `TienChuaThue` | Thành tiền chưa thuế | xs:decimal |  |
| `ThueSuatVAT` | Thuế suất GTGT (%) | xs:decimal |  |
| `TienThueVAT` | Tiền thuế GTGT | xs:decimal |  |
| `TongTienThanhToan` | Tổng tiền thanh toán | xs:decimal | Có |
| `TrangThaiHDDT` | Trạng thái hóa đơn điện tử | EnumRef.TrangThaiHoaDonDienTu |  |
| `MaCQT` | Mã của cơ quan thuế | xs:string |  |
| `DienGiai` | Diễn giải | xs:string |  |
| `NguoiLap` | Người lập | xs:string |  |
| `NguoiDuyet` | Người duyệt | xs:string |  |
| `ApDungGiamThueGTGT` | ApDungGiamThueGTGT | xs:boolean |  |
| `TienTe` | TienTe | CatalogRef.TienTe |  |
| `TyGia` | TyGia | xs:decimal |  |
| `TongTienNgoaiTe` | TongTienNgoaiTe | xs:decimal |  |

**Hóa đơn đầu vào (nhà cung cấp)** (`HoaDonNhaCungCap`)

Trường chuẩn: `Number` (Số tự động), `Date` (Ngày, bắt buộc), `Posted` (Đã ghi sổ), `DeletionMark` (Đánh dấu xóa).

| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |
|---|---|---|---|
| `PhapNhan` | Pháp nhân | CatalogRef.PhapNhan | Có |
| `DoiTac` | Nhà cung cấp | CatalogRef.DoiTac | Có |
| `HopDong` | Hợp đồng | CatalogRef.HopDong | Có |
| `SoHoaDon` | Số hóa đơn | xs:string | Có |
| `NgayHoaDon` | Ngày hóa đơn | xs:dateTime | Có |
| `TienTe` | Tiền tệ | CatalogRef.TienTe | Có |
| `TyGia` | Tỷ giá | xs:decimal |  |
| `TongTien` | Tổng tiền VND | xs:decimal | Có |
| `TongTienNgoaiTe` | Tổng tiền ngoại tệ | xs:decimal |  |
| `TienDichVu` | Tiền dịch vụ | xs:decimal |  |
| `TienThueVAT` | Tiền thuế GTGT | xs:decimal |  |
| `CoKhauTruFCT` | Có khấu trừ thuế nhà thầu (FCT) | xs:boolean |  |
| `TyLeThueVATNhaThau` | Tỷ lệ thuế GTGT nhà thầu (%) | xs:decimal |  |
| `TyLeThueTNDNNhaThau` | Tỷ lệ thuế TNDN nhà thầu (%) | xs:decimal |  |
| `TienThueVATNhaThau` | Thuế GTGT nhà thầu | xs:decimal |  |
| `TienThueTNDNNhaThau` | Thuế TNDN nhà thầu | xs:decimal |  |
| `ChiPhiVSF` | Chi phí VSF | xs:decimal |  |
| `NoThucTraNCC` | Số tiền thực trả nhà cung cấp | xs:decimal |  |
| `TrangThai` | Trạng thái | EnumRef.TrangThaiHoaDonAP |  |
| `TaiKhoanChiPhi` | Tài khoản chi phí | ChartOfAccountsRef.HeThongTaiKhoan |  |
| `DienGiai` | Diễn giải | xs:string |  |
| `NguoiLap` | Người lập | xs:string |  |
| `NguoiDuyet` | Người duyệt | xs:string |  |

**Phiếu thu tiền khách hàng** (`PhieuThuTienKhachHang`)

Trường chuẩn: `Number` (Số tự động), `Date` (Ngày, bắt buộc), `Posted` (Đã ghi sổ), `DeletionMark` (Đánh dấu xóa).

| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |
|---|---|---|---|
| `PhapNhan` | Pháp nhân | CatalogRef.PhapNhan | Có |
| `DoiTac` | Đối tác | CatalogRef.DoiTac | Có |
| `HopDong` | Hợp đồng | CatalogRef.HopDong | Có |
| `ChungTuGoc` | Chứng từ gốc | DocumentRef.BienBanNghiemThuGiaiDoan, DocumentRef.HoaDonGTGTDauRa |  |
| `TaiKhoanTien` | Tài khoản tiền | CatalogRef.TaiKhoanTien | Có |
| `KhoanMucDongTien` | Khoản mục dòng tiền | CatalogRef.KhoanMucDongTien | Có |
| `TienTe` | Tiền tệ | CatalogRef.TienTe | Có |
| `SoTien` | Số tiền (VND) | xs:decimal | Có |
| `SoTienNgoaiTe` | Số tiền ngoại tệ | xs:decimal |  |
| `TyGia` | Tỷ giá | xs:decimal |  |
| `NgayThu` | Ngày thu | xs:dateTime |  |
| `DienGiai` | Diễn giải | xs:string |  |
| `NguoiLap` | Người lập | xs:string |  |
| `NguoiDuyet` | Người duyệt | xs:string |  |

**Ủy nhiệm chi** (`UyNhiemChi`)

Trường chuẩn: `Number` (Số tự động), `Date` (Ngày, bắt buộc), `Posted` (Đã ghi sổ), `DeletionMark` (Đánh dấu xóa).

| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |
|---|---|---|---|
| `PhapNhan` | Pháp nhân | CatalogRef.PhapNhan | Có |
| `DoiTac` | Nhà cung cấp | CatalogRef.DoiTac | Có |
| `HopDong` | Hợp đồng | CatalogRef.HopDong | Có |
| `ChungTuGoc` | Chứng từ gốc | DocumentRef.HoaDonNhaCungCap, DocumentRef.UyNhiemChi |  |
| `TaiKhoanTien` | Tài khoản ngân hàng | CatalogRef.TaiKhoanTien | Có |
| `KhoanMucDongTien` | Khoản mục dòng tiền | CatalogRef.KhoanMucDongTien | Có |
| `TienTe` | Tiền tệ | CatalogRef.TienTe | Có |
| `TyGia` | Tỷ giá | xs:decimal |  |
| `SoTien` | Số tiền chi | xs:decimal | Có |
| `SoTienNgoaiTe` | Số tiền ngoại tệ | xs:decimal |  |
| `PhiNganHang` | Phí ngân hàng | xs:decimal |  |
| `TrangThai` | Trạng thái | EnumRef.TrangThaiLenhThanhToan |  |
| `NgayLap` | Ngày lập | xs:dateTime |  |
| `NgayGhiSo` | Ngày ghi sổ | xs:dateTime |  |
| `LaTraSoatHoanTra` | Là chứng từ hoàn trả (tra soát) | xs:boolean |  |
| `NguoiLap` | Người lập | xs:string |  |
| `NguoiDuyet` | Người duyệt | xs:string |  |
| `DienGiai` | Diễn giải | xs:string |  |
| `MaGiaoDichNganHang` | MaGiaoDichNganHang | xs:string |  |
| `TrangThaiGuiNganHang` | TrangThaiGuiNganHang | xs:string |  |
| `ThoiDiemGuiNganHang` | ThoiDiemGuiNganHang | xs:dateTime |  |

#### Sổ thông tin

**Phân quyền chi nhánh** (`PhanQuyenChiNhanh`)


| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |
|---|---|---|---|
| `NguoiDung` | NguoiDung | xs:string | Có |
| `ChiNhanh` | ChiNhanh | CatalogRef.ChiNhanh | Có |

**Tỷ giá hối đoái** (`TyGiaHoiDoai`)

Trường chuẩn: `Period` (Ngày/Kỳ ghi tỷ giá).

| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |
|---|---|---|---|
| `TyGiaMua` | Tỷ giá mua | xs:decimal |  |
| `TyGiaBan` | Tỷ giá bán | xs:decimal |  |
| `TyGiaHachToan` | Tỷ giá hạch toán | xs:decimal |  |
| `TienTe` | Tiền tệ | CatalogRef.TienTe |  |

#### Sổ tích lũy

**Sổ chi tiết công nợ phải thu** (`CongNoPhaiThu`)


| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |
|---|---|---|---|
| `SoTien` | Số tiền (VND) | xs:decimal |  |
| `SoTienNgoaiTe` | Số tiền ngoại tệ | xs:decimal |  |
| `PhapNhan` | Pháp nhân | CatalogRef.PhapNhan |  |
| `DoiTac` | Đối tác | CatalogRef.DoiTac |  |
| `HopDong` | Hợp đồng | CatalogRef.HopDong |  |
| `ChungTuGoc` | Chứng từ gốc | Dimension |  |

**Sổ chi tiết công nợ phải trả** (`CongNoPhaiTra`)


| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |
|---|---|---|---|
| `SoTien` | Số tiền (VND) | xs:decimal |  |
| `SoTienNgoaiTe` | Số tiền ngoại tệ | xs:decimal |  |
| `PhapNhan` | Pháp nhân | CatalogRef.PhapNhan |  |
| `DoiTac` | Đối tác | CatalogRef.DoiTac |  |
| `HopDong` | Hợp đồng | CatalogRef.HopDong |  |
| `ChungTuGoc` | Chứng từ gốc | Dimension |  |

**Sổ chi tiết dòng tiền** (`DongTien`)


| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |
|---|---|---|---|
| `SoTien` | Số tiền (VND) | xs:decimal |  |
| `SoTienNgoaiTe` | Số tiền ngoại tệ (USD) | xs:decimal |  |
| `PhapNhan` | Pháp nhân | CatalogRef.PhapNhan |  |
| `TaiKhoanTien` | Tài khoản tiền | CatalogRef.TaiKhoanTien |  |
| `TienTe` | Tiền tệ | CatalogRef.TienTe |  |
| `KhoanMucDongTien` | Khoản mục dòng tiền | CatalogRef.KhoanMucDongTien |  |

#### Sổ cái

**Sổ cái kế toán** (`SoCaiKeToan`)


| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |
|---|---|---|---|
| `PhapNhan` | Pháp nhân | CatalogRef.PhapNhan |  |
| `TienTe` | Tiền tệ | CatalogRef.TienTe |  |
| `SoTien` | Số tiền | xs:decimal |  |
| `SoTienNgoaiTe` | Số tiền ngoại tệ | xs:decimal |  |
| `ChungTuGoc` | Chứng từ gốc | Attribute |  |
| `TyGia` | Tỷ giá | xs:decimal |  |
| `DienGiai` | Diễn giải | xs:string |  |
| `DoiTac` | Đối tác | CatalogRef.DoiTac |  |
| `HopDong` | Hợp đồng | CatalogRef.HopDong |  |
| `TaiKhoanTien` | Tài khoản tiền | CatalogRef.TaiKhoanTien |  |
| `DoiTacNo` | Đối tác | CatalogRef.DoiTac |  |
| `DoiTacCo` | Đối tác | CatalogRef.DoiTac |  |
| `HopDongNo` | Hợp đồng | CatalogRef.HopDong |  |
| `HopDongCo` | Hợp đồng | CatalogRef.HopDong |  |
| `ChungTuGocNo` | Chứng từ gốc | Attribute |  |
| `ChungTuGocCo` | Chứng từ gốc | Attribute |  |
| `TaiKhoanTienNo` | Tài khoản tiền | CatalogRef.TaiKhoanTien |  |
| `TaiKhoanTienCo` | Tài khoản tiền | CatalogRef.TaiKhoanTien |  |

#### Kế hoạch tài khoản

**Hệ thống tài khoản** (`HeThongTaiKhoan`)

Trường chuẩn: `Code`, `Description`, `Parent`, `Type`, `OffBalance`, `Order`, `DeletionMark`.

| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |
|---|---|---|---|
| `MaLogic` | Mã logic | xs:string |  |
| `TenTaiKhoan` | Tên tài khoản | xs:string |  |
| `TinhChat` | Tính chất | xs:string |  |

#### Hằng số

**Cho phép sinh dữ liệu mẫu trên bản sao UAT** (`ChoPhepSinhDuLieuMau`)

Giá trị: `xs:boolean`.

**Ngưỡng chi tiền cần CFO phê duyệt** (`NguongPheDuyetChiTienCFO`)

Giá trị: `xs:decimal`.

**Pháp nhân mặc định** (`PhapNhanMacDinh`)

Giá trị: `CatalogRef.PhapNhan`.

#### Giá trị chọn

**Hướng dòng tiền** (`HuongDongTien`)


| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |
|---|---|---|---|
| `Thu` | Thu tiền | Giá trị trạng thái |  |
| `Chi` | Chi tiền | Giá trị trạng thái |  |

**Loại đối tác** (`LoaiDoiTac`)


| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |
|---|---|---|---|
| `KhachHangNgoai` | Khách hàng ngoài | Giá trị trạng thái |  |
| `NoiBoVingroup` | Nội bộ Vingroup | Giá trị trạng thái |  |
| `NhaCungCapCloud` | Nhà cung cấp Cloud | Giá trị trạng thái |  |
| `NhaCungCapLinhKien` | Nhà cung cấp linh kiện | Giá trị trạng thái |  |
| `ThauPhuCNTT` | Thầu phụ CNTT | Giá trị trạng thái |  |
| `KhachHangVaNhaCungCap` | Khách hàng và Nhà cung cấp | Giá trị trạng thái |  |
| `KhachHang` | Khách hàng | Giá trị trạng thái |  |
| `NhaCungCap` | Nhà cung cấp | Giá trị trạng thái |  |
| `NoiBoTapDoan` | Nội bộ tập đoàn | Giá trị trạng thái |  |

**Trạng thái hóa đơn đầu vào** (`TrangThaiHoaDonAP`)


| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |
|---|---|---|---|
| `DuThao` | Dự thảo | Giá trị trạng thái |  |
| `ChoDuyetKyThuat` | Chờ duyệt kỹ thuật | Giá trị trạng thái |  |
| `ChoDuyetPM` | Chờ Quản lý dự án duyệt | Giá trị trạng thái |  |
| `ChoDuyetITDirector` | Chờ Giám đốc hạ tầng CNTT duyệt | Giá trị trạng thái |  |
| `ChoDuyetCFO` | Chờ CFO duyệt | Giá trị trạng thái |  |
| `ChoKeToanTruongDuyet` | Chờ Kế toán trưởng duyệt | Giá trị trạng thái |  |
| `DaGhiSo` | Đã ghi sổ | Giá trị trạng thái |  |
| `TuChoi` | Từ chối | Giá trị trạng thái |  |

**Trạng thái hóa đơn điện tử** (`TrangThaiHoaDonDienTu`)


| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |
|---|---|---|---|
| `DuThao` | Dự thảo | Giá trị trạng thái |  |
| `ChoKySo` | Chờ ký số | Giá trị trạng thái |  |
| `DaPhatHanh` | Đã phát hành | Giá trị trạng thái |  |
| `DaDieuChinh` | Đã điều chỉnh | Giá trị trạng thái |  |
| `DaThayThe` | Đã thay thế | Giá trị trạng thái |  |
| `DaHuy` | Đã hủy | Giá trị trạng thái |  |

**Trạng thái ủy nhiệm chi** (`TrangThaiLenhThanhToan`)


| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |
|---|---|---|---|
| `DuThao` | Dự thảo | Giá trị trạng thái |  |
| `ChoDuyet` | Chờ duyệt | Giá trị trạng thái |  |
| `DaDuyet` | Đã duyệt | Giá trị trạng thái |  |
| `DaGuiNganHang` | Đã gửi ngân hàng | Giá trị trạng thái |  |
| `DaNhanHoanTien` | Đã nhận hoàn tiền | Giá trị trạng thái |  |
| `DaGhiSo` | Đã ghi sổ | Giá trị trạng thái |  |
| `TuChoi` | Từ chối | Giá trị trạng thái |  |
| `HuyBo` | Hủy bỏ | Giá trị trạng thái |  |

**Trạng thái nghiệm thu phải thu** (`TrangThaiNghiemThuAR`)


| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |
|---|---|---|---|
| `DuThao` | Dự thảo | Giá trị trạng thái |  |
| `ChoDuyetNoiBo` | Chờ duyệt nội bộ | Giá trị trạng thái |  |
| `DaDuyetNoiBo` | Đã duyệt nội bộ | Giá trị trạng thái |  |
| `ChoDoiTacKy` | Chờ đối tác ký | Giá trị trạng thái |  |
| `DaGhiSo` | Đã ghi sổ | Giá trị trạng thái |  |
| `DaThanhToanMotPhan` | Đã thanh toán một phần | Giá trị trạng thái |  |
| `DaTatToan` | Đã tất toán | Giá trị trạng thái |  |
| `TranhChap` | Tranh chấp | Giá trị trạng thái |  |

### B. Từng điều khiển trên 12 form tự thiết kế

Ký hiệu trong danh sách: `[Input]` là ô nhập/chọn, `[Check]` là checkbox, `[Page]` là tab, `[Button]` là nút riêng; `[ro]` là chỉ đọc. Tên sau `->` là dữ liệu được ghi/đọc. Các trường lặp ở hai tab cùng trỏ vào **một** trường dữ liệu. Thanh lệnh `[autofill]` do 1C tự tạo và phụ thuộc quyền.

#### Danh sách Biên bản nghiệm thu giai đoạn

Nguồn: `VSF_Finance_E2E/guide_work_20261020/Configuration/Documents/BienBanNghiemThuGiaiDoan/Forms/FormDanhSach/Ext/Form.xml`

```text
AutoCommandBar  [autofill]

Elements:
  ├─ [Group:H] BoLocNhanh
  │ ├─ [Input] BoLocKy -> BoLocKy [title:Kỳ] {OnChange}
  │ ├─ [Input] BoLocTrangThai -> BoLocTrangThai [title:Trạng thái] {OnChange}
  │ └─ [Input] BoLocDoiTac -> BoLocDoiTac [title:Khách hàng] {OnChange}
  └─ [Table] DanhSach -> DanhSach [cmdBar:DanhSachCommandBar]
    ├─ [Input] DanhSachNumber -> DanhSach.Number [title:Số CT]
    ├─ [Input] DanhSachDate -> DanhSach.Date [title:Ngày lập]
    ├─ [Input] DanhSachDoiTac -> DanhSach.DoiTac [title:Khách hàng]
    ├─ [Input] DanhSachTongGiaTri -> DanhSach.TongGiaTri [title:Tổng giá trị]
    ├─ [Input] DanhSachTrangThai -> DanhSach.TrangThai [title:Trạng thái]
    └─ [Check] DanhSachPosted -> DanhSach.Posted [title:Đã ghi sổ]

Attributes:
  *DanhSach: DynamicList -> Document.BienBanNghiemThuGiaiDoan (main)
   BoLocKy: string
   BoLocTrangThai: string
   BoLocDoiTac: CatalogRef.DoiTac
```

#### Danh sách Hóa đơn nhà cung cấp (AP)

Nguồn: `VSF_Finance_E2E/guide_work_20261020/Configuration/Documents/HoaDonNhaCungCap/Forms/FormDanhSach/Ext/Form.xml`

```text
AutoCommandBar  [autofill]

Elements:
  ├─ [Group:H] BoLocNhanh
  │ ├─ [Input] BoLocKy -> BoLocKy [title:Kỳ] {OnChange}
  │ ├─ [Input] BoLocTrangThai -> BoLocTrangThai [title:Trạng thái] {OnChange}
  │ └─ [Input] BoLocDoiTac -> BoLocDoiTac [title:Nhà cung cấp] {OnChange}
  └─ [Table] DanhSach -> DanhSach [cmdBar:DanhSachCommandBar]
    ├─ [Input] DanhSachNumber -> DanhSach.Number [title:Số CT]
    ├─ [Input] DanhSachDate -> DanhSach.Date [title:Ngày lập]
    ├─ [Input] DanhSachDoiTac -> DanhSach.DoiTac [title:Nhà cung cấp]
    ├─ [Input] DanhSachTongTien -> DanhSach.TongTien [title:Tổng tiền]
    ├─ [Input] DanhSachTrangThai -> DanhSach.TrangThai [title:Trạng thái]
    └─ [Check] DanhSachPosted -> DanhSach.Posted [title:Đã ghi sổ]

Attributes:
  *DanhSach: DynamicList -> Document.HoaDonNhaCungCap (main)
   BoLocKy: string
   BoLocTrangThai: string
   BoLocDoiTac: CatalogRef.DoiTac
```

#### Hóa đơn nhà cung cấp (AP) - VinSmart Future

Nguồn: `VSF_Finance_E2E/guide_work_20261020/Configuration/Documents/HoaDonNhaCungCap/Forms/FormChungTu/Ext/Form.xml`

```text
AutoCommandBar FormCommandBar [autofill]
  [Button] FormCmdXemChungTuLienQuan -> Form.Command.CmdXemChungTuLienQuan

Elements:
  ├─ [HTMLDocumentField] TruongHTMLHeader -> NoiDungHTMLHeader
  └─ [Pages] Pages
    ├─ [Page] ThongTinChung [title:1. Thông tin chung]
    │ └─ [Group:H] Group2Cot
    │   ├─ [Group:V] CotTrai
    │   │ ├─ [Input] Number -> Object.Number [ro]
    │   │ ├─ [Input] Date -> Object.Date
    │   │ ├─ [Input] PhapNhan -> Object.PhapNhan
    │   │ ├─ [Input] DoiTac -> Object.DoiTac
    │   │ ├─ [Input] HopDong -> Object.HopDong
    │   │ └─ [Input] SoHoaDon -> Object.SoHoaDon
    │   └─ [Group:V] CotPhai
    │     ├─ [Input] TienDichVu -> Object.TienDichVu {OnChange}
    │     ├─ [Input] TienThueVAT -> Object.TienThueVAT
    │     └─ [Input] TongTien -> Object.TongTien [ro]
    ├─ [Page] ChiTietHangHoa [title:2. Chi tiết hàng hóa/dịch vụ]
    │ ├─ [Input] ChiTietTienDichVu -> Object.TienDichVu
    │ └─ [Input] ChiTietTienThueVAT -> Object.TienThueVAT
    ├─ [Page] ThueVaHoaDonDienTu [title:3. Trạng thái phê duyệt]
    │ └─ [Input] TrangThai -> Object.TrangThai
    └─ [Page] NhatKyVaGhiChu [title:4. Diễn giải & Nhật ký]
      └─ [Input] DienGiai -> Object.DienGiai

Attributes:
  *Object: DocumentObject.HoaDonNhaCungCap (main)
   NoiDungHTMLHeader: string

Commands:
  CmdXemChungTuLienQuan -> CmdXemChungTuLienQuan
```

#### Biên bản nghiệm thu giai đoạn (AR) - VinSmart Future

Nguồn: `VSF_Finance_E2E/guide_work_20261020/Configuration/Documents/BienBanNghiemThuGiaiDoan/Forms/FormChungTu/Ext/Form.xml`

```text
AutoCommandBar  [autofill]

Elements:
  ├─ [HTMLDocumentField] TruongHTMLHeader -> NoiDungHTMLHeader
  └─ [Pages] Pages
    ├─ [Page] ThongTinChung [title:1. Thông tin chung]
    │ └─ [Group:H] Group2Cot
    │   ├─ [Group:V] CotTrai
    │   │ ├─ [Input] Number -> Object.Number [ro]
    │   │ ├─ [Input] Date -> Object.Date
    │   │ ├─ [Input] NgayNghiemThu -> Object.NgayNghiemThu {OnChange}
    │   │ ├─ [Input] PhapNhan -> Object.PhapNhan
    │   │ ├─ [Input] DoiTac -> Object.DoiTac
    │   │ └─ [Input] HopDong -> Object.HopDong
    │   └─ [Group:V] CotPhai
    │     ├─ [Input] GiaTriNghiemThuChuaVAT -> Object.GiaTriNghiemThuChuaVAT {OnChange}
    │     ├─ [Input] TyLeVAT -> Object.TyLeVAT {OnChange}
    │     ├─ [Check] ApDungGiamThueGTGT -> Object.ApDungGiamThueGTGT [title:Thuộc đối tượng được giảm thuế GTGT] {OnChange}
    │     ├─ [Input] TienVAT -> Object.TienVAT
    │     └─ [Input] TongGiaTri -> Object.TongGiaTri [ro]
    ├─ [Page] ChiTietHangHoa [title:2. Chi tiết nghiệm thu]
    │ └─ [Input] ChiTietGiaTriNghiemThuChuaVAT -> Object.GiaTriNghiemThuChuaVAT
    ├─ [Page] ThueVaHoaDonDienTu [title:3. Thuế & HĐĐT]
    │ └─ [Input] TrangThai -> Object.TrangThai
    └─ [Page] NhatKyVaGhiChu [title:4. Nhật ký & Phê duyệt]
      └─ [Input] DienGiai -> Object.DienGiai

Attributes:
  *Object: DocumentObject.BienBanNghiemThuGiaiDoan (main)
   NoiDungHTMLHeader: string
```

#### Phiếu thu tiền khách hàng (AR) - VinSmart Future

Nguồn: `VSF_Finance_E2E/guide_work_20261020/Configuration/Documents/PhieuThuTienKhachHang/Forms/FormChungTu/Ext/Form.xml`

```text
AutoCommandBar FormCommandBar [autofill]
  [Button] FormCmdXemChungTuLienQuan -> Form.Command.CmdXemChungTuLienQuan

Elements:
  ├─ [HTMLDocumentField] TruongHTMLHeader -> NoiDungHTMLHeader
  └─ [Pages] Pages
    ├─ [Page] ThongTinChung [title:1. Thông tin chung]
    │ └─ [Group:H] Group2Cot
    │   ├─ [Group:V] CotTrai
    │   │ ├─ [Input] Number -> Object.Number [ro]
    │   │ ├─ [Input] Date -> Object.Date
    │   │ ├─ [Input] PhapNhan -> Object.PhapNhan
    │   │ ├─ [Input] DoiTac -> Object.DoiTac
    │   │ └─ [Input] HopDong -> Object.HopDong
    │   └─ [Group:V] CotPhai
    │     ├─ [Input] TaiKhoanTien -> Object.TaiKhoanTien
    │     ├─ [Input] KhoanMucDongTien -> Object.KhoanMucDongTien
    │     └─ [Input] SoTien -> Object.SoTien {OnChange}
    ├─ [Page] ChiTietThanhToan [title:2. Chi tiết thu tiền]
    │ └─ [Input] ChiTietSoTien -> Object.SoTien
    ├─ [Page] ThueVaHoaDonDienTu [title:3. Đối soát chứng từ]
    │ └─ [Input] DoiSoatHopDong -> Object.HopDong
    └─ [Page] NhatKyVaGhiChu [title:4. Diễn giải & Nhật ký]
      └─ [Input] DienGiai -> Object.DienGiai

Attributes:
  *Object: DocumentObject.PhieuThuTienKhachHang (main)
   NoiDungHTMLHeader: string

Commands:
  CmdXemChungTuLienQuan -> CmdXemChungTuLienQuan
```

#### Danh sách Phiếu thu tiền khách hàng

Nguồn: `VSF_Finance_E2E/guide_work_20261020/Configuration/Documents/PhieuThuTienKhachHang/Forms/FormDanhSach/Ext/Form.xml`

```text
AutoCommandBar  [autofill]

Elements:
  ├─ [Group:H] BoLocNhanh
  │ ├─ [Input] BoLocKy -> BoLocKy [title:Kỳ] {OnChange}
  │ ├─ [Input] BoLocTrangThai -> BoLocTrangThai [title:Trạng thái] {OnChange}
  │ └─ [Input] BoLocDoiTac -> BoLocDoiTac [title:Khách hàng] {OnChange}
  └─ [Table] DanhSach -> DanhSach [cmdBar:DanhSachCommandBar]
    ├─ [Input] DanhSachNumber -> DanhSach.Number [title:Số CT]
    ├─ [Input] DanhSachDate -> DanhSach.Date [title:Ngày lập]
    ├─ [Input] DanhSachDoiTac -> DanhSach.DoiTac [title:Khách hàng]
    ├─ [Input] DanhSachSoTien -> DanhSach.SoTien [title:Số tiền]
    ├─ [Input] DanhSachDienGiai -> DanhSach.DienGiai [title:Diễn giải]
    └─ [Check] DanhSachPosted -> DanhSach.Posted [title:Đã ghi sổ]

Attributes:
  *DanhSach: DynamicList -> Document.PhieuThuTienKhachHang (main)
   BoLocKy: string
   BoLocTrangThai: string
   BoLocDoiTac: CatalogRef.DoiTac
```

#### Danh sách Hóa đơn GTGT đầu ra (AR)

Nguồn: `VSF_Finance_E2E/guide_work_20261020/Configuration/Documents/HoaDonGTGTDauRa/Forms/FormDanhSach/Ext/Form.xml`

```text
AutoCommandBar  [autofill]

Elements:
  ├─ [Group:H] BoLocNhanh
  │ ├─ [Input] BoLocKy -> BoLocKy [title:Kỳ báo cáo] {OnChange}
  │ ├─ [Input] BoLocTrangThai -> BoLocTrangThai [title:Trạng thái] {OnChange}
  │ └─ [Input] BoLocDoiTac -> BoLocDoiTac [title:Đối tác] {OnChange}
  └─ [Table] DanhSach -> DanhSach [cmdBar:DanhSachCommandBar]
    ├─ [Input] DanhSachNumber -> DanhSach.Number [title:Số CT]
    ├─ [Input] DanhSachDate -> DanhSach.Date [title:Ngày lập]
    ├─ [Input] DanhSachDoiTac -> DanhSach.DoiTac [title:Khách hàng]
    ├─ [Input] DanhSachTongTienThanhToan -> DanhSach.TongTienThanhToan [title:Tổng tiền]
    └─ [Check] DanhSachPosted -> DanhSach.Posted [title:Đã ghi sổ]

Attributes:
  *DanhSach: DynamicList -> Document.HoaDonGTGTDauRa (main)
   BoLocKy: string
   BoLocTrangThai: string
   BoLocDoiTac: CatalogRef.DoiTac
```

#### Hóa đơn GTGT đầu ra (AR) - VinSmart Future

Nguồn: `VSF_Finance_E2E/guide_work_20261020/Configuration/Documents/HoaDonGTGTDauRa/Forms/FormChungTu/Ext/Form.xml`

```text
AutoCommandBar FormCommandBar [autofill]
  [Button] FormCmdXemChungTuLienQuan -> Form.Command.CmdXemChungTuLienQuan

Elements:
  ├─ [HTMLDocumentField] TruongHTMLHeader -> NoiDungHTMLHeader
  └─ [Pages] Pages
    ├─ [Page] ThongTinChung [title:1. Thông tin chung]
    │ └─ [Group:H] Group2Cot
    │   ├─ [Group:V] CotTrai
    │   │ ├─ [Input] Number -> Object.Number [ro]
    │   │ ├─ [Input] Date -> Object.Date
    │   │ ├─ [Input] PhapNhan -> Object.PhapNhan
    │   │ ├─ [Input] DoiTac -> Object.DoiTac
    │   │ ├─ [Input] HopDong -> Object.HopDong
    │   │ └─ [Input] BienBanNghiemThu -> Object.BienBanNghiemThu
    │   └─ [Group:V] CotPhai
    │     ├─ [Input] TienChuaThue -> Object.TienChuaThue {OnChange}
    │     ├─ [Input] ThueSuatVAT -> Object.ThueSuatVAT [ro] [title:Thuế suất GTGT (%)]
    │     ├─ [Check] ApDungGiamThueGTGT -> Object.ApDungGiamThueGTGT [title:Thuộc đối tượng được giảm thuế GTGT] {OnChange}
    │     ├─ [Input] TienThueVAT -> Object.TienThueVAT
    │     └─ [Input] TongTienThanhToan -> Object.TongTienThanhToan [ro]
    ├─ [Page] ChiTietHangHoa [title:2. Chi tiết hàng hóa/dịch vụ]
    │ ├─ [Input] ChiTietTienChuaThue -> Object.TienChuaThue
    │ └─ [Input] ChiTietTienThueVAT -> Object.TienThueVAT
    ├─ [Page] ThanhToanVaThue [title:3. Thuế & HĐĐT]
    │ ├─ [Input] ThueTienThueVAT -> Object.TienThueVAT
    │ └─ [Input] ThueTongTienThanhToan -> Object.TongTienThanhToan [ro]
    └─ [Page] NhatKyVaGhiChu [title:4. Nhật ký & Phê duyệt]
      └─ [Input] DienGiai -> Object.DienGiai

Attributes:
  *Object: DocumentObject.HoaDonGTGTDauRa (main)
   NoiDungHTMLHeader: string

Commands:
  CmdXemChungTuLienQuan -> CmdXemChungTuLienQuan
```

#### Danh sách Ủy nhiệm chi

Nguồn: `VSF_Finance_E2E/guide_work_20261020/Configuration/Documents/UyNhiemChi/Forms/FormDanhSach/Ext/Form.xml`

```text
AutoCommandBar  [autofill]

Elements:
  ├─ [Group:H] BoLocNhanh
  │ ├─ [Input] BoLocKy -> BoLocKy [title:Kỳ] {OnChange}
  │ ├─ [Input] BoLocTrangThai -> BoLocTrangThai [title:Trạng thái] {OnChange}
  │ └─ [Input] BoLocDoiTac -> BoLocDoiTac [title:Đối tác] {OnChange}
  └─ [Table] DanhSach -> DanhSach [cmdBar:DanhSachCommandBar]
    ├─ [Input] DanhSachNumber -> DanhSach.Number [title:Số CT]
    ├─ [Input] DanhSachDate -> DanhSach.Date [title:Ngày lập]
    ├─ [Input] DanhSachDoiTac -> DanhSach.DoiTac [title:Đối tác thụ hưởng]
    ├─ [Input] DanhSachSoTien -> DanhSach.SoTien [title:Số tiền]
    ├─ [Input] DanhSachTrangThai -> DanhSach.TrangThai [title:Trạng thái lệnh]
    └─ [Check] DanhSachPosted -> DanhSach.Posted [title:Đã ghi sổ]

Attributes:
  *DanhSach: DynamicList -> Document.UyNhiemChi (main)
   BoLocKy: string
   BoLocTrangThai: string
   BoLocDoiTac: CatalogRef.DoiTac
```

#### Ủy nhiệm chi ngân hàng (AP) - VinSmart Future

Nguồn: `VSF_Finance_E2E/guide_work_20261020/Configuration/Documents/UyNhiemChi/Forms/FormChungTu/Ext/Form.xml`

```text
AutoCommandBar FormCommandBar [autofill]
  [Button] FormCmdXemChungTuLienQuan -> Form.Command.CmdXemChungTuLienQuan
  [Button] CmdGuiLenhChiNganHang -> Form.Command.CmdGuiLenhChiNganHang
  [Button] CmdXacNhanHoanTienNganHang -> Form.Command.CmdXacNhanHoanTienNganHang

Elements:
  ├─ [HTMLDocumentField] TruongHTMLHeader -> NoiDungHTMLHeader
  └─ [Pages] Pages
    ├─ [Page] ThongTinChung [title:1. Thông tin chung]
    │ └─ [Group:H] Group2Cot
    │   ├─ [Group:V] CotTrai
    │   │ ├─ [Input] Number -> Object.Number [ro]
    │   │ ├─ [Input] Date -> Object.Date
    │   │ ├─ [Input] PhapNhan -> Object.PhapNhan
    │   │ ├─ [Input] DoiTac -> Object.DoiTac
    │   │ └─ [Input] HopDong -> Object.HopDong
    │   └─ [Group:V] CotPhai
    │     ├─ [Input] TaiKhoanTien -> Object.TaiKhoanTien
    │     ├─ [Input] KhoanMucDongTien -> Object.KhoanMucDongTien
    │     └─ [Input] SoTien -> Object.SoTien {OnChange}
    ├─ [Page] ChiTietThanhToan [title:2. Chi tiết lệnh chi]
    │ └─ [Input] ChiTietSoTien -> Object.SoTien
    ├─ [Page] ThueVaHoaDonDienTu [title:3. Trạng thái thanh toán]
    │ ├─ [Input] TrangThai -> Object.TrangThai
    │ ├─ [Input] TrangThaiGuiNganHangUI -> Object.TrangThaiGuiNganHang [ro] [title:Trạng thái ngân hàng]
    │ ├─ [Input] MaGiaoDichNganHangUI -> Object.MaGiaoDichNganHang [ro] [title:Mã giao dịch ngân hàng]
    │ └─ [Input] ThoiDiemGuiNganHangUI -> Object.ThoiDiemGuiNganHang [ro] [title:Thời điểm gửi ngân hàng]
    └─ [Page] NhatKyVaGhiChu [title:4. Diễn giải & Nhật ký]
      └─ [Input] DienGiai -> Object.DienGiai

Attributes:
  *Object: DocumentObject.UyNhiemChi (main)
   NoiDungHTMLHeader: string

Commands:
  CmdXemChungTuLienQuan -> CmdXemChungTuLienQuan
  CmdGuiLenhChiNganHang -> GuiLenhChiNganHang
  CmdXacNhanHoanTienNganHang -> XacNhanHoanTienNganHang
```

#### Bàn làm việc & Điều hành Web ERP - VinSmart Future

Nguồn: `VSF_Finance_E2E/guide_work_20261020/Configuration/DataProcessors/BanLamViecWebERP/Forms/FormBanLamViec/Ext/Form.xml`

```text
AutoCommandBar  [autofill]

Elements:
  └─ [HTMLDocumentField] TruongHTMLCockpit -> NoiDungHTML {OnClick}

Attributes:
  *Object: DataProcessorObject.BanLamViecWebERP (main)
   NoiDungHTML: string
```

#### Bàn Duyệt Maker-Checker Hàng Loạt - VinSmart Future

Nguồn: `VSF_Finance_E2E/guide_work_20261020/Configuration/DataProcessors/BanLamViecWebERP/Forms/FormPheDuyetHangLoat/Ext/Form.xml`

```text
AutoCommandBar  [autofill]

Elements:
  └─ [HTMLDocumentField] TruongHTMLPheDuyet -> NoiDungHTML {OnClick}

Attributes:
  *Object: DataProcessorObject.BanLamViecWebERP (main)
   NoiDungHTML: string
```

