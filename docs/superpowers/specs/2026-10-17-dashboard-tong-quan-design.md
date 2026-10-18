# Thiết Kế Chi Tiết: Bàn Làm Việc Tổng Quan Điều Hành (Executive Overview Dashboard)

> **Hệ thống:** VinSmart Future (VSF) — Quản lý công nợ AR & AP  
> **Nền tảng:** 1C:Enterprise 8.3 (Managed Application / Taxi Interface, BSL, XML Metadata Version 2.15)  
> **Tài liệu thiết kế:** Đặc tả kiến trúc và giao diện cho `DataProcessor.DashboardTongQuan`  
> **Ngày lập:** 17/10/2026  
> **Trạng thái:** Đã thống nhất thiết kế (Validated Design)

---

## 1. Mục Tiêu & Bối Cảnh Nghiệp Vụ

Nhằm phục vụ công tác chỉ đạo, điều hành của Ban Giám đốc (CFO) và công tác giám sát, kiểm soát luồng chứng từ của Kế toán trưởng (KTT), hệ thống bổ sung **Bàn làm việc Tổng quan Điều hành** (`DataProcessor.DashboardTongQuan`).

Dashboard cung cấp một điểm truy cập tập trung (Single Pane of Glass) giúp:
1. **Nắm bắt tức thời các chỉ số tài chính trọng yếu (KPI Cards):** Tổng nợ phải thu (TK 1311), Tổng nợ phải trả (TK 3311), Số dư dòng tiền thực tế tại ngân hàng (TK 1121) và Thuế nhà thầu FCT tạm giữ chờ nộp ngân sách (TK 33318 + TK 3338).
2. **Kiểm soát & phê duyệt tập trung (Action Center):** Danh sách toàn bộ các Hóa đơn nhà cung cấp đang chờ duyệt trong hệ thống, phân loại rõ cấp duyệt (Kế toán trưởng duyệt đối với hóa đơn $\le$ 500 triệu VND; Giám đốc tài chính CFO duyệt đối với hóa đơn $>$ 500 triệu VND). Hỗ trợ mở trực tiếp chứng từ để phê duyệt.
3. **Thao tác nhanh theo luồng chuẩn (Quick Actions):** Phím tắt tạo mới nhanh các chứng từ thuộc 2 luồng cốt lõi (Biên bản nghiệm thu, Hóa đơn GTGT đầu ra, Phiếu thu tiền khách hàng, Hóa đơn nhà cung cấp, Ủy nhiệm chi) và mở nhanh các sổ kế toán.

---

## 2. Kiến Trúc Hệ Thống & Tổ Chức Metadata

### 2.1. Cấu trúc đối tượng Metadata
- **Loại đối tượng:** `DataProcessor` (Bộ xử lý dữ liệu / Bàn làm việc).
- **Tên đối tượng:** `DashboardTongQuan`.
- **Tên hiển thị (Synonym):**
  - Tiếng Việt: `Bàn làm việc Tổng quan Điều hành`
  - Tiếng Anh: `Executive Overview Dashboard`
- **Form chính mặc định (DefaultForm):** `Form.Form`.
- **Không ghi dữ liệu:** DataProcessor là đối tượng phi trạng thái, dữ liệu hiển thị được tính toán động (read-only) từ Sổ cái và các chứng từ nghiệp vụ.

### 2.2. Danh mục tệp tin cấu hình (`src/`)
```text
src/
├── Configuration.xml                                              # Đăng ký DataProcessor.DashboardTongQuan vào cấu hình
├── Ext/
│   └── MainSectionCommandInterface.xml                            # Gắn lệnh mở Dashboard lên thanh điều hướng chính
├── Roles/
│   ├── QuanTriHeThong/Rights.xml                                  # Cấp quyền Use, View cho Admin
│   ├── GiamDocTaiChinh_CFO/Rights.xml                             # Cấp quyền Use, View cho CFO
│   ├── KeToanTruong/Rights.xml                                    # Cấp quyền Use, View cho KTT
│   ├── KeToanPhaiThu/Rights.xml                                   # Cấp quyền Use, View cho KT Phải thu
│   └── KeToanPhaiTra/Rights.xml                                   # Cấp quyền Use, View cho KT Phải trả
└── DataProcessors/
    ├── DashboardTongQuan.xml                                      # Metadata định nghĩa DataProcessor
    └── DashboardTongQuan/
        └── Forms/
            └── Form/
                ├── Form.xml                                       # Khai báo Form managed
                └── Ext/
                    ├── Form.xml                                   # Declarative UI layout theo chuẩn Taxi
                    └── Form/
                        └── Module.bsl                             # Client/Server logic truy vấn và tương tác
```

---

## 3. Thiết Kế Giao Diện Taxi (UI / Layout Structure)

### 3.1. Bố cục Wireframe
```text
+---------------------------------------------------------------------------------------------------+
| [VSF] BÀN LÀM VIỆC TỔNG QUAN ĐIỀU HÀNH TÀI CHÍNH                                 [ Làm mới (F5) ] |
| Ngày chốt: [ 17/10/2026 ]             Pháp nhân: [ Công ty CP VinSmart Future             [v] ]   |
+---------------------------------------------------------------------------------------------------+
| KHU VỰC 1: THẺ CHỈ SỐ TÀI CHÍNH CỐT LÕI (KPI CARDS)                                              |
| +--------------------+ +--------------------+ +--------------------+ +--------------------------+ |
| | TỔNG NỢ PHẢI THU   | | TỔNG NỢ PHẢI TRẢ   | | DÒNG TIỀN THỰC TẾ  | | THUẾ FCT TẠM GIỮ         | |
| | (TK 1311 / AR)     | | (TK 3311 / AP)     | | (TK 1121 / Tiền)   | | (TK 33318 + 3338)        | |
| |                    | |                    | |                    | |                          | |
| |  220.000.000 đ     | |  225.000.000 đ     | |  500.000.000 đ     | |   25.000.000 đ           | |
| | (Theo BBNT & HĐ)   | | (Theo Hóa đơn NCC) | | (Ngân hàng VCB/CTG)| | (Chờ nộp NSNN)           | |
| +--------------------+ +--------------------+ +--------------------+ +--------------------------+ |
+---------------------------------------------------------------------------------------------------+
| KHU VỰC 2: TRUNG TÂM CẢNH BÁO & PHÊ DUYỆT (ACTION CENTER)                                         |
| Hóa đơn nhà cung cấp cần phê duyệt (Nhấp đúp chuột để mở chứng từ phê duyệt):                     |
| +--------------+------------+--------------------+----------------+------------------+----------+ |
| | Số chứng từ  | Ngày       | Nhà cung cấp       | Tổng tiền (VND)| Trạng thái duyệt | Cấp duyệt| |
| +--------------+------------+--------------------+----------------+------------------+----------+ |
| | HĐNCC-000001 | 17/10/2026 | Amazon Web Services| 250.000.000    | ChoDuyetKTT      | KTT      | |
| | HĐNCC-000002 | 17/10/2026 | Oracle Cloud       | 600.000.000    | ChoDuyetCFO (!)  | CFO      | |
| +--------------+------------+--------------------+----------------+------------------+----------+ |
+---------------------------------------------------------------------------------------------------+
| KHU VỰC 3: PHÍM TẮT THAO TÁC NHANH (QUICK ACTIONS)                                                |
| [ Luồng AR: ]   [+ Nghiệm thu]   [+ Hóa đơn GTGT AR]   [+ Thu tiền khách hàng]                    |
| [ Luồng AP: ]   [+ Hóa đơn NCC]  [+ Lập Ủy nhiệm chi]                                             |
| [ Sổ kế toán: ] [+ Xem Sổ cái GL] [+ Xem Sổ nợ AR]   [+ Xem Sổ nợ AP]                            |
+---------------------------------------------------------------------------------------------------+
```

### 3.2. Thuộc tính trên Form (`FormAttributes`)
1. `NgayChot` (Kiểu `Date`): Mặc định là ngày hiện tại (`CurrentDate()`).
2. `PhapNhan` (Kiểu `CatalogRef.PhapNhan`): Mặc định lấy từ `Constants.PhapNhanMacDinh`.
3. `TongNoAR` (Kiểu `Number(15, 2)`): Hiển thị dư Nợ TK 1311.
4. `TongNoAP` (Kiểu `Number(15, 2)`): Hiển thị dư Có TK 3311.
5. `TongSoDuTien` (Kiểu `Number(15, 2)`): Hiển thị dư Nợ TK 1121.
6. `TongThueFCT` (Kiểu `Number(15, 2)`): Hiển thị dư Có TK 33318 + 3338.
7. `DanhSachChoDuyet` (Kiểu `ValueTable`):
   - `ChungTu` (Kiểu `DocumentRef.HoaDonNhaCungCap`)
   - `SoChungTu` (Kiểu `String`)
   - `Ngay` (Kiểu `Date`)
   - `DoiTac` (Kiểu `CatalogRef.DoiTac`)
   - `TongTien` (Kiểu `Number(15, 2)`)
   - `TrangThaiPheDuyet` (Kiểu `EnumRef.TrangThaiHoaDonAP`)
   - `CapDuyet` (Kiểu `String`) — Giá trị: `"KẾ TOÁN TRƯỞNG"` hoặc `"GIÁM ĐỐC TÀI CHÍNH (CFO)"`

---

## 4. Logic Nghiệp Vụ & Truy Vấn BSL Server

### 4.1. Khởi tạo và làm mới dữ liệu
Tại `OnCreateAtServer` và sự kiện `NutLamMoiClick`:
1. Gán mặc định `NgayChot = CurrentDate()`.
2. Gán mặc định `PhapNhan = Constants.PhapNhanMacDinh.Get()`.
3. Gọi thủ tục Server `NapDuLieuDashboardTaiServer()`.

### 4.2. Câu lệnh truy vấn tổng hợp số liệu
Thủ tục `NapDuLieuDashboardTaiServer()` thực hiện truy vấn BSL:
```bsl
&AtServer
Procedure NapDuLieuDashboardTaiServer()
	
	// Đọc ngưỡng CFO
	NguongCFO = Constants.NguongPheDuyetChiTienCFO.Get();
	If NguongCFO = 0 Then
		NguongCFO = 500000000; // Giá trị an toàn mặc định 500tr
	EndIf;
	
	PeriodVal = EndOfDay(NgayChot);
	
	// 1. Truy vấn số dư sổ cái
	QueryGL = New Query;
	QueryGL.Text = 
		"SELECT
		|	ISNULL(SUM(CASE WHEN SoCai.Account = VALUE(ChartOfAccounts.HeThongTaiKhoan.TK1311) THEN SoCai.AmountBalanceDr ELSE 0 END), 0) AS TongNoAR,
		|	ISNULL(SUM(CASE WHEN SoCai.Account = VALUE(ChartOfAccounts.HeThongTaiKhoan.TK3311) THEN SoCai.AmountBalanceCr ELSE 0 END), 0) AS TongNoAP,
		|	ISNULL(SUM(CASE WHEN SoCai.Account = VALUE(ChartOfAccounts.HeThongTaiKhoan.TK1121) THEN SoCai.AmountBalanceDr ELSE 0 END), 0) AS TongSoDuTien,
		|	ISNULL(SUM(CASE WHEN SoCai.Account IN (VALUE(ChartOfAccounts.HeThongTaiKhoan.TK33318), VALUE(ChartOfAccounts.HeThongTaiKhoan.TK3338)) THEN SoCai.AmountBalanceCr ELSE 0 END), 0) AS TongThueFCT
		|FROM
		|	AccountingRegister.SoCaiKeToan.Balance(&PeriodVal, , , PhapNhan = &PhapNhan) AS SoCai";
	
	QueryGL.SetParameter("PeriodVal", PeriodVal);
	QueryGL.SetParameter("PhapNhan", PhapNhan);
	
	ResGL = QueryGL.Execute();
	SelGL = ResGL.Select();
	If SelGL.Next() Then
		TongNoAR = SelGL.TongNoAR;
		TongNoAP = SelGL.TongNoAP;
		TongSoDuTien = SelGL.TongSoDuTien;
		TongThueFCT = SelGL.TongThueFCT;
	Else
		TongNoAR = 0;
		TongNoAP = 0;
		TongSoDuTien = 0;
		TongThueFCT = 0;
	EndIf;
	
	// 2. Truy vấn danh sách hóa đơn NCC chờ duyệt
	QueryAP = New Query;
	QueryAP.Text = 
		"SELECT
		|	HD.Ref AS ChungTu,
		|	HD.Number AS SoChungTu,
		|	HD.Date AS Ngay,
		|	HD.DoiTac AS DoiTac,
		|	HD.TongTien AS TongTien,
		|	HD.TrangThaiHoaDon AS TrangThaiPheDuyet,
		|	CASE
		|		WHEN HD.TrangThaiHoaDon = VALUE(Enum.TrangThaiHoaDonAP.ChoDuyetCFO) OR HD.TongTien > &NguongCFO
		|			THEN ""GIÁM ĐỐC TÀI CHÍNH (CFO)""
		|		ELSE ""KẾ TOÁN TRƯỞNG""
		|	END AS CapDuyet
		|FROM
		|	Document.HoaDonNhaCungCap AS HD
		|WHERE
		|	HD.Posted = FALSE
		|	AND HD.TrangThaiHoaDon IN (VALUE(Enum.TrangThaiHoaDonAP.ChoDuyetKTT), VALUE(Enum.TrangThaiHoaDonAP.ChoDuyetCFO))
		|	AND (HD.PhapNhan = &PhapNhan OR &PhapNhan = VALUE(Catalog.PhapNhan.EmptyRef))
		|ORDER BY
		|	HD.Date DESC";
	
	QueryAP.SetParameter("NguongCFO", NguongCFO);
	QueryAP.SetParameter("PhapNhan", PhapNhan);
	
	DanhSachChoDuyet.Load(QueryAP.Execute().Unload());
	
EndProcedure
```

### 4.3. Xử lý tương tác Client
- **Nhấp đúp chuột vào bảng chờ duyệt (`DanhSachChoDuyetSelection`):**
  ```bsl
  &AtClient
  Procedure DanhSachChoDuyetSelection(Item, SelectedRow, Field, StandardProcessing)
  	StandardProcessing = False;
  	CurrentData = Items.DanhSachChoDuyet.CurrentData;
  	If CurrentData <> Undefined And ValueIsFilled(CurrentData.ChungTu) Then
  		OpenForm("Document.HoaDonNhaCungCap.ObjectForm", New Structure("Key", CurrentData.ChungTu));
  	EndIf;
  EndProcedure
  ```
- **Các phím tắt mở tạo mới chứng từ:**
  - `TaoMoiBBNT`: `OpenForm("Document.BienBanNghiemThuGiaiDoan.ObjectForm");`
  - `TaoMoiHoaDonAR`: `OpenForm("Document.HoaDonGTGTDauRa.ObjectForm");`
  - `TaoMoiPhieuThu`: `OpenForm("Document.PhieuThuTienKhachHang.ObjectForm");`
  - `TaoMoiHoaDonAP`: `OpenForm("Document.HoaDonNhaCungCap.ObjectForm");`
  - `TaoMoiUNC`: `OpenForm("Document.UyNhiemChi.ObjectForm");`

---

## 5. Phân Quyền & Bảo Mật (Roles & Security)

Cập nhật `Rights.xml` của các vai trò trong hệ thống để cấp quyền:
- `QuanTriHeThong`: Quyền `Read`, `View` (trên DataProcessor) và đầy đủ trên các chứng từ.
- `GiamDocTaiChinh_CFO`: Quyền `Read`, `View` để mở Dashboard theo dõi tài chính và phê duyệt.
- `KeToanTruong`: Quyền `Read`, `View` để kiểm soát các khoản chờ duyệt và số dư nợ.
- `KeToanPhaiThu`, `KeToanPhaiTra`: Quyền `Read`, `View` để xem thông tin tổng quan phục vụ đối soát.

---

## 6. Xử Lý Tình Huống Biên & Ngoại Lệ (Edge Cases)

1. **Chưa có dữ liệu giao dịch / Cơ sở dữ liệu mới tinh:**
   - Kết quả hàm `Balance()` trả về bảng rỗng; logic code dùng `ISNULL` và gán mặc định `0`, đảm bảo giao diện luôn mở thành công, không gặp lỗi `NullReference`.
2. **Không chọn Pháp nhân:**
   - Nếu `PhapNhan` rỗng, câu truy vấn tính toán gộp toàn bộ các pháp nhân trong hệ thống.
3. **Cơ chế chống lỗi runtime:**
   - Tất cả các thao tác Server được bọc trong khối `Try...Except` ghi nhật ký cảnh báo qua `QuanLyVongDoiChungTuServer.GhiNhatKyError` thay vì ngắt đột ngột ứng dụng client.

---

## 7. Tiêu Chí Nghiệm Thu (Acceptance Criteria)

1. `DataProcessor.DashboardTongQuan` được định nghĩa chuẩn xác trong XML Metadata version 2.15 và đăng ký trong `src/Configuration.xml`.
2. Form Taxi hiển thị đầy đủ 3 khu vực: Banner KPI Cards, Bảng hàng đợi phê duyệt Action Center, Nhóm nút bấm Quick Actions.
3. Kiểm tra cú pháp BSL bằng `scripts/verify_bsl_syntax.py` đạt 0 lỗi cân bằng khối lệnh.
4. Điều hướng: Lệnh mở Dashboard xuất hiện trên thanh điều hướng chính `MainSectionCommandInterface.xml`.
5. Đầy đủ quyền truy cập cho các vai trò CFO, Kế toán trưởng, Kế toán viên và Quản trị hệ thống.
