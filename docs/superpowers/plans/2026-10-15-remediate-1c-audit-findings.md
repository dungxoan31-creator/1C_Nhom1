# Kế Hoạch Khắc Phục Lỗi Logic & Mã Số Kế Toán 1C:Enterprise (Dành Cho Newbie)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Khắc phục toàn bộ 7 lỗi nghiêm trọng (Critical) và các lỗi trọng yếu phát hiện qua đợt kiểm toán hệ thống VSF 1C:Enterprise, đưa hệ thống tuân thủ 100% Thông tư 200/2014/TT-BTC, Nghị định 123/2020/NĐ-CP, Nghị quyết 204/2025/QH15 và Nghị định 174/2025/NĐ-CP, với hướng dẫn chi tiết, dễ hiểu nhất cho lập trình viên mới học (Newbie).

**Architecture:** Bổ sung cấu trúc dữ liệu Metadata XML cho các chỉ tiêu pháp lý hóa đơn (MST, Địa chỉ, Số TK), chuẩn hóa quy tắc hạch toán kép trong `ObjectModule.bsl` (Doanh thu bán dịch vụ 5113, Tỷ giá ngoại tệ nguyên tệ, Tài khoản phí ngân hàng 6427, Đánh giá lại ngoại tệ 1312), và kích hoạt liên kết ràng buộc dữ liệu `ChoiceParameterLinks` giữa Hợp đồng và Đối tác.

**Tech Stack:** Nền tảng 1C:Enterprise 8.3 (Managed Application / Taxi UI), Business Scripting Language (BSL), Metadata XML Schema 2.15, Python 3.14 (Test Suite runner & Host Audit tool).

**Spec:** [Báo cáo Audit Codebase 1C:Enterprise VSF](file:///C:/Users/Dung/Documents/1C_Enterprise/audit_logic_1c.md)

---

## Cẩm Nang Nhập Môn 1C:Enterprise Dành Cho Newbie (Đọc Trước Khi Làm)

Nếu bạn là người mới bước vào thế giới **1C:Enterprise** và **Kế toán Việt Nam**, hãy ghi nhớ 4 quy tắc vàng sau:

### 1. Kiến trúc tách biệt: Metadata XML vs Mã nguồn BSL
- **Metadata XML** (`src/Documents/HoaDonGTGTDauRa.xml`, `src/Catalogs/DoiTac.xml`...): Đây là nơi định nghĩa "khung xương" cơ sở dữ liệu (tên trường, kiểu dữ liệu `xs:string`, `xs:decimal`, độ dài, khóa ngoại, bộ lọc). Nếu bạn không khai báo thuộc tính trong XML, code BSL sẽ báo lỗi `Field not found`.
- **ObjectModule.bsl** (`src/Documents/.../Ext/ObjectModule.bsl`): Chạy hoàn toàn trên **Server** trong transaction ghi dữ liệu. Đây là nơi chứa 2 sự kiện sống còn:
  - `BeforeWrite(Cancel, WriteMode, PostingMode)`: Chạy trước khi lưu xuống DB. Dùng để tính toán bổ sung (`TongTien = TienChuaThue + TienThueVAT`) hoặc kiểm tra hợp lệ (`If Not ValueIsFilled(...) Then Cancel = True; EndIf;`).
  - `Posting(Cancel, Mode)`: Chạy khi người dùng bấm "Ghi sổ" (Post). Dùng để ghi các dòng bút toán Nợ/Có vào Sổ cái (`SoCaiKeToan`) và Sổ tích lũy (`CongNoPhaiThu`, `CongNoPhaiTra`).

### 2. Nguyên tắc Bút toán Kép (Double Entry) trong 1C
Trong Sổ cái `SoCaiKeToan`:
- Mỗi dòng ghi sổ có: `AccountDr` (Tài khoản Nợ), `AccountCr` (Tài khoản Có), `SoTien` (Số tiền VNĐ).
- **Quy tắc bất biến:** `Tổng phát sinh Nợ = Tổng phát sinh Có`.
- Tài sản (1xx, 2xx): Tăng ghi Nợ, Giảm ghi Có.
- Nợ phải trả & Nguồn vốn (3xx, 4xx): Tăng ghi Có, Giảm ghi Nợ.
- Doanh thu (5xx, 7xx): Tăng ghi Có, Kết chuyển giảm ghi Nợ.
- Chi phí (6xx, 8xx): Tăng ghi Nợ, Kết chuyển giảm ghi Có.

### 3. Vòng đời Transaction & Lock dữ liệu
- Khi ghi sổ (`Posting`), 1C tự động mở một Transaction. Nếu bạn gán `Cancel = True` hoặc gặp lệnh `Raise`, toàn bộ dữ liệu ghi vào các sổ trong transaction đó sẽ bị Rollback (hủy bỏ hoàn toàn), không để lại rác dữ liệu.
- Phải luôn gọi `RegisterRecords.TenSo.Clear()` ở đầu thủ tục `Posting` để tránh việc ghi trùng dòng khi người dùng bấm "Ghi sổ lại" (Reposting).

---

## Global Constraints

- **Toàn vẹn Metadata:** Mọi thuộc tính thêm mới vào XML phải tuân thủ đúng XML Schema 2.15 của 1C, sinh UUID hợp lệ không trùng lặp, đầy đủ thẻ `<Synonym>` (song ngữ `vi` và `en`).
- **Bảo toàn Invariant P0.1:** Nghiệm thu giai đoạn (`BienBanNghiemThuGiaiDoan`) ghi nhận doanh thu thuần Nợ 131 / Có 5113; Hóa đơn GTGT (`HoaDonGTGTDauRa`) liên kết nghiệm thu chỉ ghi nhận thuế Nợ 131 / Có 33311. Tuyệt đối không ghi nhận doanh thu 2 lần.
- **Không phá vỡ Suite Test:** Bộ test `python -B -m unittest discover -s scripts -p test_audit_tools.py -v` (24 ca) và `test_onec_runtime.py` (22 ca) phải luôn luôn ở trạng thái **PASS 100%**.

---

## Review Focus

1. **Gian lận/Thiếu Doanh thu:** Hóa đơn GTGT đầu ra lập trực tiếp (không có Biên bản nghiệm thu) có bị rơi vào tình trạng chỉ ghi nhận thuế VAT mà quên ghi nhận Doanh thu Có 5113 không?
2. **Sai lệch Tiền lẻ Ngoại tệ:** Hóa đơn nhà cung cấp quốc tế (USD) có bị tính ngược ngoại tệ bằng phép chia số tiền VNĐ đã làm tròn không?
3. **Cưỡng bức Thuế 10%:** Dịch vụ xuất khẩu (0%) hoặc Dịch vụ phần mềm không chịu thuế (KCT) khi điều chỉnh công nợ có bị biến thành 10% VAT không?
4. **Trích nợ nhầm Tài khoản:** Phí ngân hàng khi chi từ tài khoản USD 1122 có bị ép ghi Có giảm tiền trên tài khoản VNĐ 1121 không?
5. **Bỏ quên Tài khoản 1312:** Cuối kỳ đánh giá lại tỷ giá ngoại tệ có quét đủ các khoản công nợ khách hàng ngoại tệ (1312) bên cạnh 1122 và 3313 không?

---

### Task 1: Bổ Sung Thuộc Tính Pháp Lý (MST, Địa Chỉ, Số TK) Vào Catalog.DoiTac & Validate MST

**Files:**
- Modify: `src/Catalogs/DoiTac.xml:89-130`
- Modify: `src/Documents/HoaDonGTGTDauRa.xml:130-175`
- Modify: `src/Documents/HoaDonGTGTDauRa/Ext/ObjectModule.bsl:10-30`

**Interfaces:**
- Consumes: `Catalog.DoiTac` (các thuộc tính mới: `MaSoThue`, `DiaChi`, `SoTaiKhoanNganHang`, `TenNganHang`)
- Produces: `Object.MaSoThueNguoiMua`, `Object.DiaChiNguoiMua` tự động lấy từ `DoiTac` khi người dùng lưu chứng từ.

**Kiến thức Newbie:**
- *Tại sao phải làm việc này?* Theo Điều 10 Nghị định 123/2020/NĐ-CP, hóa đơn điện tử bắt buộc phải có MST và Địa chỉ của người mua. Trước đây `Catalog.DoiTac` của VSF bị thiếu các trường này, buộc kế toán phải tự gõ MST bằng tay trên từng hóa đơn và không có nơi lưu địa chỉ!
- *Cách sửa trong 1C:* Mở file metadata XML `DoiTac.xml`, thêm thẻ `<Attribute>` với kiểu dữ liệu `xs:string`.

- [ ] **Step 1: Kiểm tra cấu trúc hiện tại của `Catalog.DoiTac.xml`**

Chạy lệnh kiểm tra các Attribute hiện có:
```powershell
python -c "import xml.etree.ElementTree as ET; tree = ET.parse('src/Catalogs/DoiTac.xml'); print([elem.text for elem in tree.findall('.//{http://v8.1c.ru/8.3/MDClasses}Name')])"
```
Kỳ vọng: Hiện tại chỉ có `['DoiTac', 'LaBenLienKet', 'DaDangKyThueTrucTiep', 'LoaiDoiTac']`.

- [ ] **Step 2: Khai báo 4 thuộc tính mới trong `src/Catalogs/DoiTac.xml`**

Mở `src/Catalogs/DoiTac.xml`, thêm vào bên dưới thẻ `<ChildObjects>` các Attribute:
1. `MaSoThue` (Type: `xs:string`, Length: 14)
2. `DiaChi` (Type: `xs:string`, Length: 250)
3. `SoTaiKhoanNganHang` (Type: `xs:string`, Length: 50)
4. `TenNganHang` (Type: `xs:string`, Length: 150)

Mẫu XML chuẩn cho thuộc tính `MaSoThue`:
```xml
<Attribute uuid="d01cac01-0001-4000-8000-000000000001">
	<Properties>
		<Name>MaSoThue</Name>
		<Synonym>
			<v8:item>
				<v8:lang>vi</v8:lang>
				<v8:content>Mã số thuế</v8:content>
			</v8:item>
			<v8:item>
				<v8:lang>en</v8:lang>
				<v8:content>Tax Identification Number</v8:content>
			</v8:item>
		</Synonym>
		<Comment>Mã số thuế doanh nghiệp (10 hoặc 13-14 ký tự)</Comment>
		<Type>
			<v8:Type>xs:string</v8:Type>
			<v8:StringQualifiers>
				<v8:Length>14</v8:Length>
				<v8:AllowedLength>Variable</v8:AllowedLength>
			</v8:StringQualifiers>
		</Type>
		<FillChecking>DontCheck</FillChecking>
		<FullTextSearch>Use</FullTextSearch>
		<DataHistory>Use</DataHistory>
	</Properties>
</Attribute>
```
*(Tương tự cho `DiaChi`, `SoTaiKhoanNganHang`, `TenNganHang`)*.

- [ ] **Step 3: Bổ sung Auto-fill và Validation MST trong `HoaDonGTGTDauRa/Ext/ObjectModule.bsl`**

Mở `src/Documents/HoaDonGTGTDauRa/Ext/ObjectModule.bsl`, thêm logic vào thủ tục `BeforeWrite`:
```bsl
// Tự động điền MST từ thông tin Đối tác nếu trên Hóa đơn đang để trống
If IsBlankString(MaSoThueNguoiMua) And ValueIsFilled(DoiTac) Then
	MaSoThueNguoiMua = DoiTac.MaSoThue;
EndIf;

// Kiểm tra tính hợp lệ của Mã số thuế theo chuẩn Tổng cục Thuế (10 số hoặc 13-14 số chi nhánh)
If Not IsBlankString(MaSoThueNguoiMua) Then
	DoDaiMST = StrLen(TrimAll(MaSoThueNguoiMua));
	If DoDaiMST <> 10 And DoDaiMST <> 13 And DoDaiMST <> 14 Then
		Cancel = True;
		Msg = New UserMessage;
		Msg.Text = StrTemplate("Mã số thuế '%1' không hợp lệ! MST phải gồm 10 số hoặc 13-14 số theo quy định.", MaSoThueNguoiMua);
		Msg.Field = "MaSoThueNguoiMua";
		Msg.SetData(ThisObject);
		Msg.Message();
	EndIf;
EndIf;
```

- [ ] **Step 4: Chạy kiểm tra bộ test audit tools**

Run: `python -B -m unittest discover -s scripts -p test_audit_tools.py -v`  
Expected: PASS 24/24.

- [ ] **Step 5: Commit thay đổi**

```bash
git add src/Catalogs/DoiTac.xml src/Documents/HoaDonGTGTDauRa/Ext/ObjectModule.bsl
git commit -m "feat(catalog): add tax ID and legal address attributes to DoiTac and validate in HoaDonGTGTDauRa"
```

---

### Task 2: Sửa Lỗi Bỏ Quên Doanh Thu (TK 5113) & Invariant P0.1 Trong HoaDonGTGTDauRa

**Files:**
- Modify: `src/Documents/HoaDonGTGTDauRa/Ext/ObjectModule.bsl:30-130`

**Interfaces:**
- Consumes: `BienBanNghiemThu`, `TienChuaThue`, `TienThueVAT`, `TongTienThanhToan`
- Produces: Bút toán Có 5113 khi không có BBNT, hoặc chỉ Có 33311 khi có BBNT.

**Kiến thức Newbie:**
- *Nghiệp vụ hạch toán:* 
  - Trường hợp 1 (Có nghiệm thu giai đoạn): Doanh thu bán dịch vụ đã được ghi nhận ở Biên bản nghiệm thu (`Nợ 131 / Có 5113: TienChuaThue`). Khi xuất hóa đơn GTGT, kế toán chỉ ghi nhận nghĩa vụ thuế (`Nợ 131 / Có 33311: TienThueVAT`). Đây là thiết kế **Invariant P0.1** của VSF.
  - Trường hợp 2 (Hóa đơn xuất trực tiếp): Không có Biên bản nghiệm thu (bán lẻ dịch vụ, thu tiền ngay, gói cước ngắn hạn). Nếu hệ thống chỉ ghi Có 33311 thì **toàn bộ doanh thu biến mất khỏi sổ sách**! Do đó, phải kiểm tra: Nếu `Not ValueIsFilled(BienBanNghiemThu)`, bắt buộc phải ghi cả Doanh thu (Có 5113) và Thuế (Có 33311).
- *Validation ngày:* Hóa đơn điện tử không được phép ghi ngày trong tương lai (`NgayHoaDon > BegOfDay(CurrentDate())`).

- [ ] **Step 1: Viết kịch bản kiểm tra logic ghi sổ**

Quan sát logic hiện tại ở `HoaDonGTGTDauRa/Ext/ObjectModule.bsl`:
Dòng 55 đang chặn cứng:
`If Not ValueIsFilled(PhapNhan) Or Not ValueIsFilled(DoiTac) Or Not ValueIsFilled(HopDong) Or Not ValueIsFilled(BienBanNghiemThu) Then`
Nếu cho phép xuất hóa đơn trực tiếp, `BienBanNghiemThu` không được là điều kiện bắt buộc chặn lỗi!

- [ ] **Step 2: Điều chỉnh điều kiện bắt buộc trong thủ tục `Posting`**

Sửa dòng 55 của `src/Documents/HoaDonGTGTDauRa/Ext/ObjectModule.bsl`:
```bsl
// Bỏ BienBanNghiemThu ra khỏi danh sách bắt buộc tuyệt đối
If Not ValueIsFilled(PhapNhan) Or Not ValueIsFilled(DoiTac) Or Not ValueIsFilled(HopDong) Then
	Cancel = True;
	Msg = New UserMessage;
	Msg.Text = NStr("vi = 'Thiếu thông tin bắt buộc: Pháp nhân, Đối tác hoặc Hợp đồng!'; en = 'Mandatory attributes missing: Legal Entity, Counterparty, or Contract!'");
	Msg.SetData(ThisObject);
	Msg.Message();
	Return;
EndIf;
```

- [ ] **Step 3: Bổ sung bút toán ghi nhận Doanh thu 5113 khi không có BBNT**

Tại phần ghi sổ cái `RegisterRecords.SoCaiKeToan` (sau dòng 95), thêm phân nhánh nghiệp vụ:
```bsl
If ValueIsFilled(BienBanNghiemThu) Then
	// =========================================================================
	// LUỒNG 1: Có BBNT - Tuân thủ Invariant P0.1 (Doanh thu đã ghi ở BBNT)
	// Chỉ ghi nhận duy nhất nghĩa vụ thuế VAT
	// =========================================================================
	RecordAR = RegisterRecords.CongNoPhaiThu.Add();
	RecordAR.RecordType = AccumulationRecordType.Receipt;
	RecordAR.Period = Date;
	RecordAR.PhapNhan = PhapNhan;
	RecordAR.DoiTac = DoiTac;
	RecordAR.HopDong = HopDong;
	RecordAR.ChungTuGoc = BienBanNghiemThu;
	RecordAR.SoTien = TienThueVAT;
	RecordAR.SoTienNgoaiTe = 0;

	RecordGL = RegisterRecords.SoCaiKeToan.Add();
	RecordGL.Period = Date;
	RecordGL.AccountDr = TKCongNo;
	RecordGL.AccountCr = TKThueVAT;
	RecordGL.DoiTacNo = DoiTac;
	RecordGL.HopDongNo = HopDong;
	RecordGL.PhapNhan = PhapNhan;
	RecordGL.TienTe = Catalogs.TienTe.FindByCode("VND");
	RecordGL.ChungTuGoc = BienBanNghiemThu;
	RecordGL.TyGia = 1;
	RecordGL.SoTien = TienThueVAT;
	RecordGL.DienGiai = StrTemplate("Thuế GTGT đầu ra theo HĐ %1", SoHoaDon);
Else
	// =========================================================================
	// LUỒNG 2: Hóa đơn trực tiếp - BẮT BUỘC ghi nhận toàn bộ Doanh thu + Thuế
	// =========================================================================
	TKDoanhThu = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("5113");
	
	// 1. Tăng công nợ toàn bộ (Gross) trên Sổ tích lũy
	RecordAR = RegisterRecords.CongNoPhaiThu.Add();
	RecordAR.RecordType = AccumulationRecordType.Receipt;
	RecordAR.Period = Date;
	RecordAR.PhapNhan = PhapNhan;
	RecordAR.DoiTac = DoiTac;
	RecordAR.HopDong = HopDong;
	RecordAR.ChungTuGoc = Ref;
	RecordAR.SoTien = TongTienThanhToan;
	RecordAR.SoTienNgoaiTe = 0;

	// 2. Bút toán Doanh thu: Nợ 131 / Có 5113 (Tiền chưa thuế)
	RecordRev = RegisterRecords.SoCaiKeToan.Add();
	RecordRev.Period = Date;
	RecordRev.AccountDr = TKCongNo;
	RecordRev.AccountCr = TKDoanhThu;
	RecordRev.DoiTacNo = DoiTac;
	RecordRev.HopDongNo = HopDong;
	RecordRev.PhapNhan = PhapNhan;
	RecordRev.TienTe = Catalogs.TienTe.FindByCode("VND");
	RecordRev.ChungTuGoc = Ref;
	RecordRev.TyGia = 1;
	RecordRev.SoTien = TienChuaThue;
	RecordRev.DienGiai = StrTemplate("Doanh thu cung cấp dịch vụ theo HĐ %1", SoHoaDon);

	// 3. Bút toán Thuế VAT: Nợ 131 / Có 33311 (Tiền thuế VAT)
	If TienThueVAT > 0 Then
		RecordTax = RegisterRecords.SoCaiKeToan.Add();
		RecordTax.Period = Date;
		RecordTax.AccountDr = TKCongNo;
		RecordTax.AccountCr = TKThueVAT;
		RecordTax.DoiTacNo = DoiTac;
		RecordTax.HopDongNo = HopDong;
		RecordTax.PhapNhan = PhapNhan;
		RecordTax.TienTe = Catalogs.TienTe.FindByCode("VND");
		RecordTax.ChungTuGoc = Ref;
		RecordTax.TyGia = 1;
		RecordTax.SoTien = TienThueVAT;
		RecordTax.DienGiai = StrTemplate("Thuế GTGT đầu ra theo HĐ %1", SoHoaDon);
	EndIf;
EndIf;
```

- [ ] **Step 4: Kiểm tra và chạy unit test**

Run: `python -B -m unittest discover -s scripts -p test_audit_tools.py -v`  
Expected: PASS.

- [ ] **Step 5: Commit thay đổi**

```bash
git add src/Documents/HoaDonGTGTDauRa/Ext/ObjectModule.bsl
git commit -m "fix(ar): recognize revenue TK 5113 for standalone invoices while preserving P0.1 invariant"
```

---

### Task 3: Sửa Lỗi Tỷ Giá Ngoại Tệ & Tính Tổng Tiền Trong HoaDonNhaCungCap

**Files:**
- Modify: `src/Documents/HoaDonNhaCungCap/Ext/ObjectModule.bsl:31-75, 160-175`

**Interfaces:**
- Consumes: `TongTienNgoaiTe`, `TyGia`, `NoThucTraNCC`
- Produces: `RecordAP.SoTienNgoaiTe` chính xác theo nguyên tệ gốc hợp đồng.

**Kiến thức Newbie:**
- *Toán học và Kế toán ngoại tệ:*
  - Giả sử hóa đơn AWS là 10.000 USD, tỷ giá 25.450 VND/USD. Thành tiền quy đổi: 254.500.000 VNĐ.
  - Nếu áp dụng FCT 10% (thuế nhà thầu gồm VAT 5% và TNDN 5%): Số thực trả nhà cung cấp là 9.000 USD (tương đương 229.050.000 VNĐ).
  - Code cũ viết: `RecordAP.SoTienNgoaiTe = Round(NoThucTraNCC / TyGia, 2)`. Nếu `NoThucTraNCC` bị làm tròn trước đó, phép chia này sẽ ra `8.999,99` hoặc `9.000,01` USD!
  - Lệch 0.01 USD (1 cent) này sẽ khiến tài khoản ngoại tệ của nhà cung cấp không bao giờ tất toán được về 0, gây đau đầu cho kế toán thanh toán.
  - *Cách sửa:* Số ngoại tệ phải tính trực tiếp từ số nguyên tệ gốc: `TongTienNgoaiTe * (NoThucTraNCC / TongTien)` hoặc gán thẳng `TongTienNgoaiTe` nếu không trừ FCT.

- [ ] **Step 1: Định vị đoạn mã tính sai trong `HoaDonNhaCungCap/Ext/ObjectModule.bsl`**

Xem dòng 170-174:
```bsl
If TongTienNgoaiTe > 0 And TyGia > 0 Then
	RecordAP.SoTienNgoaiTe = Round(NoThucTraNCC / TyGia, 2);
Else
	RecordAP.SoTienNgoaiTe = 0;
EndIf;
```

- [ ] **Step 2: Sửa thủ tục `BeforeWrite` để tự động tính `TongTien` VNĐ từ ngoại tệ**

Trong `BeforeWrite`, trước khi tính FCT, thêm đoạn mã sau:
```bsl
// Tự động tính TongTien quy đổi ra VNĐ nếu người dùng nhập số ngoại tệ
If TongTien = 0 And TongTienNgoaiTe > 0 And TyGia > 0 Then
	TongTien = Round(TongTienNgoaiTe * TyGia, 0);
EndIf;
```

- [ ] **Step 3: Sửa thủ tục `Posting` để giữ nguyên giá trị nguyên tệ gốc**

Thay thế dòng 170-174 bằng đoạn mã chuẩn xác:
```bsl
If TongTienNgoaiTe > 0 Then
	If CoKhauTruFCT And TongTien > 0 Then
		// Ngoại tệ thực trả được phân bổ theo tỷ lệ Net / Gross gốc
		RecordAP.SoTienNgoaiTe = Round(TongTienNgoaiTe * (NoThucTraNCC / TongTien), 2);
	Else
		// Không khấu trừ thuế nhà thầu -> Số ngoại tệ đúng bằng số tiền trên hóa đơn gốc
		RecordAP.SoTienNgoaiTe = TongTienNgoaiTe;
	EndIf;
Else
	RecordAP.SoTienNgoaiTe = 0;
EndIf;
```

- [ ] **Step 4: Chạy kiểm thử tự động**

Run: `python -B -m unittest discover -s scripts -p test_audit_tools.py -v`  
Expected: PASS.

- [ ] **Step 5: Commit thay đổi**

```bash
git add src/Documents/HoaDonNhaCungCap/Ext/ObjectModule.bsl
git commit -m "fix(ap): eliminate FX rounding drift by preserving original currency amount"
```

---

### Task 4: Loại Bỏ Cưỡng Bức Thuế 10% & Hỗ Trợ Thuế Suất 8% Tại DieuChinhCongNo

**Files:**
- Modify: `src/Documents/DieuChinhCongNo/Ext/ObjectModule.bsl:30-55`

**Interfaces:**
- Consumes: `ThueSuatVAT` (nhận hợp lệ 0, 8, 10, KCT)
- Produces: Tỷ lệ phân bổ giảm Doanh thu và Giảm thuế VAT chính xác.

**Kiến thức Newbie:**
- *Chính sách Thuế GTGT tại Việt Nam:*
  - Theo Luật Thuế GTGT, dịch vụ phần mềm và xuất khẩu dịch vụ ra nước ngoài chịu thuế suất **0%** hoặc thuộc diện **Không chịu thuế (KCT)**.
  - Nghị quyết 204/2025/QH15 và Nghị định 174/2025/NĐ-CP tiếp tục gia hạn chính sách giảm 2% thuế GTGT (từ 10% xuống **8%**) đến hết ngày 31/12/2026.
  - Đoạn code cũ: `If ThueSuatVAT = 0 Then ThueSuatVAT = 10; EndIf;` là một lỗi tai hại! Nó biến các hợp đồng gia công phần mềm 0% thuế thành 10%, khiến công ty phải nộp oan hàng trăm triệu tiền thuế cho nhà nước!

- [ ] **Step 1: Kiểm tra đoạn code cũ tại `DieuChinhCongNo/Ext/ObjectModule.bsl`**

Quan sát dòng 32-35:
```bsl
// Thue suat mac dinh la 10% neu chua nhap
If ThueSuatVAT = 0 Then
	ThueSuatVAT = 10;
EndIf;
```

- [ ] **Step 2: Sửa logic cho phép thuế suất 0% và tính toán theo đúng tỷ lệ**

Thay thế dòng 32-52 bằng đoạn code chuẩn:
```bsl
// Cho phép thuế suất 0% (Không chịu thuế hoặc Thuế 0% cho dịch vụ phần mềm/xuất khẩu)
// Không tự ý ép ThueSuatVAT = 10 khi người dùng nhập 0%

If TongTienGiam > 0 Then
	If GiamDoanhThu = 0 Then
		If ThueSuatVAT > 0 Then
			TyLeHeSo = 1 + ThueSuatVAT / 100;
			GiamDoanhThu = Round(TongTienGiam / TyLeHeSo, 0);
		Else
			// Thuế suất 0% hoặc KCT -> Toàn bộ số tiền giảm là giảm doanh thu
			GiamDoanhThu = TongTienGiam;
		EndIf;
	EndIf;
	If GiamThueVAT = 0 Then
		GiamThueVAT = TongTienGiam - GiamDoanhThu;
	EndIf;
ElsIf GiamDoanhThu > 0 Then
	If GiamThueVAT = 0 And ThueSuatVAT > 0 Then
		GiamThueVAT = Round(GiamDoanhThu * ThueSuatVAT / 100, 0);
	EndIf;
	TongTienGiam = GiamDoanhThu + GiamThueVAT;
EndIf;
```

- [ ] **Step 3: Chạy test kiểm thử**

Run: `python -B -m unittest discover -s scripts -p test_audit_tools.py -v`  
Expected: PASS.

- [ ] **Step 4: Commit thay đổi**

```bash
git add src/Documents/DieuChinhCongNo/Ext/ObjectModule.bsl
git commit -m "fix(ar): allow zero and 8-percent VAT rates in DieuChinhCongNo without forcing 10 percent"
```

---

### Task 5: Chuẩn Hóa Tài Khoản Phí Ngân Hàng (6427) & Xử Lý Nguồn Chi Ngoại Tệ Tại UyNhiemChi

**Files:**
- Modify: `src/CommonModules/SeedDataCleanServer/Ext/Module.bsl:270-275`
- Modify: `src/Documents/UyNhiemChi/Ext/ObjectModule.bsl:130-135, 605-620`

**Interfaces:**
- Consumes: `Constants.TaiKhoanPhiNganHang`, `TaiKhoanNganHangDi`, `PhiNganHang`
- Produces: Bút toán phí ngân hàng ghi Nợ 6427 / Có 1121 (hoặc Có 1122 tương ứng tài khoản trích tiền).

**Kiến thức Newbie:**
- *Đối chiếu Thông tư 200:*
  - TK `6425`: "Thuế, phí và lệ phí" -> Chỉ dùng cho các loại thuế nộp nhà nước (thuế môn bài, lệ phí trước bạ, thuế đất...).
  - TK `6427`: "Chi phí dịch vụ mua ngoài" -> Đây mới là nơi hạch toán phí chuyển tiền, phí SMS banking, phí phát hành bảo lãnh của ngân hàng.
- *Lỗi ghi nhầm tài khoản nguồn:* Khi chuyển tiền từ tài khoản USD (`1122`), nếu ngân hàng trừ phí trực tiếp trên tài khoản USD, phải ghi Có `1122`. Code cũ đang hardcode `TK1121 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1121"); Row2.AccountCr = TK1121;` khiến TK 1121 bị trừ tiền oan và âm quỹ!

- [ ] **Step 1: Sửa hằng số cài đặt trong `SeedDataCleanServer/Ext/Module.bsl`**

Mở `src/CommonModules/SeedDataCleanServer/Ext/Module.bsl`, tìm dòng 273:
```bsl
// CŨ:
Constants.TaiKhoanPhiNganHang.Set(ChartsOfAccounts.HeThongTaiKhoan.FindByCode("6425"));
// MỚI:
Constants.TaiKhoanPhiNganHang.Set(ChartsOfAccounts.HeThongTaiKhoan.FindByCode("6427"));
```

- [ ] **Step 2: Đọc tài khoản phí từ Constant và phân nhánh tài khoản nguồn trong `UyNhiemChi/Ext/ObjectModule.bsl`**

Mở `src/Documents/UyNhiemChi/Ext/ObjectModule.bsl`:
Tại dòng 133, thay vì hardcode chuỗi, đọc từ Hằng số:
```bsl
TKPhiNganHang = Constants.TaiKhoanPhiNganHang.Get();
If Not ValueIsFilled(TKPhiNganHang) Then
	TKPhiNganHang = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("6427");
EndIf;
```

Tại dòng 607-615, sửa bút toán phí chuyển tiền:
```bsl
If PhiNganHang > 0 Then
	// Xác định tài khoản tiền trích nợ phí:
	// Nếu tài khoản xuất tiền là ngoại tệ (1122) và phí thu bằng ngoại tệ -> Ghi Có 1122
	// Nếu tài khoản xuất tiền là VNĐ hoặc phí thu bằng VNĐ -> Ghi Có 1121
	If MaTKTien = "1122" And LaNgoaiTe Then
		TKCoPhi = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1122");
	Else
		TKCoPhi = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1121");
	EndIf;
	
	Row2 = RegisterRecords.SoCaiKeToan.Add();
	Row2.Period = NgayHachToan;
	Row2.AccountDr = TKPhiNganHang;
	Row2.AccountCr = TKCoPhi;
	Row2.SoTien = PhiNganHang;
	Row2.DienGiai = StrTemplate("Phí chuyển tiền ngân hàng UNC %1", Number);
	Row2.PhapNhan = PhapNhan;
	Row2.TienTe = TienTeVND;
	Row2.ChungTuGoc = ChungTuGoc;
	Row2.TyGia = 1;
```

- [ ] **Step 3: Chạy kiểm thử tự động**

Run: `python -B -m unittest discover -s scripts -p test_audit_tools.py -v`  
Expected: PASS.

- [ ] **Step 4: Commit thay đổi**

```bash
git add src/CommonModules/SeedDataCleanServer/Ext/Module.bsl src/Documents/UyNhiemChi/Ext/ObjectModule.bsl
git commit -m "fix(gl): set bank fee account to 6427 and support dynamic credit cash account"
```

---

### Task 6: Bổ Sung Đánh Giá Lại Tỷ Giá Công Nợ Phải Thu Ngoại Tệ (TK 1312)

**Files:**
- Modify: `src/Documents/DanhGiaLaiNgoaiTe/Ext/ObjectModule.bsl:55-80, 120-160`

**Interfaces:**
- Consumes: `InformationRegisters.TyGiaHoiDoai`, `AccumulationRegister.CongNoPhaiThu`
- Produces: Bút toán chênh lệch tỷ giá cuối kỳ cho TK 1312 kết chuyển vào TK 4131 / 515 / 635.

**Kiến thức Newbie:**
- *Quy định tại Điều 69 Thông tư 200:*
  - Vào ngày cuối năm tài chính (31/12), doanh nghiệp bắt buộc phải đánh giá lại tất cả các khoản mục tiền tệ có gốc ngoại tệ theo tỷ giá thực tế cuối kỳ:
    - Tiền gửi ngân hàng ngoại tệ (TK 1122)
    - Phải trả nhà cung cấp ngoại tệ (TK 3313)
    - **Phải thu khách hàng ngoại tệ (TK 1312)** -> Code cũ của VSF bị bỏ quên hoàn toàn tài khoản này!
  - Nếu tỷ giá USD tăng: Khoản phải thu khách hàng USD được đánh giá tăng giá trị VNĐ -> Ghi nhận Lãi tỷ giá (`Nợ 1312 / Có 4131` rồi kết chuyển `Có 515`).
  - Nếu tỷ giá USD giảm: Khoản phải thu khách hàng USD bị giảm giá trị VNĐ -> Ghi nhận Lỗ tỷ giá (`Nợ 4131 / Có 1312` rồi kết chuyển `Nợ 635`).

- [ ] **Step 1: Khai báo thêm `TK1312` và khóa dữ liệu `CongNoPhaiThu` trong `DanhGiaLaiNgoaiTe`**

Mở `src/Documents/DanhGiaLaiNgoaiTe/Ext/ObjectModule.bsl`:
Tại dòng 58-62, thêm:
```bsl
TK1312 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1312");
```
Tại khối `DataLock` (dòng 72-82), thêm khóa cho `CongNoPhaiThu`:
```bsl
LockAR = New DataLock;
KeyAR = LockAR.Add("AccumulationRegister.CongNoPhaiThu");
KeyAR.Mode = DataLockMode.Exclusive;
KeyAR.SetValue("PhapNhan", RefPN);
LockAR.Lock();
```

- [ ] **Step 2: Bổ sung truy vấn và vòng lặp hạch toán đánh giá lại TK 1312**

Thêm truy vấn lấy số dư công nợ phải thu ngoại tệ tại thời điểm `BoundaryNgayChot`:
```bsl
Q_AR = New Query;
Q_AR.Text = 
	"SELECT
	|	AR.DoiTac AS DoiTac,
	|	AR.HopDong AS HopDong,
	|	AR.ChungTuGoc AS ChungTuGoc,
	|	ISNULL(SUM(AR.SoTienBalance), 0) AS SoTienVND,
	|	ISNULL(SUM(AR.SoTienNgoaiTeBalance), 0) AS SoTienUSD
	|FROM
	|	AccumulationRegister.CongNoPhaiThu.Balance(&BoundaryDate, PhapNhan = &PhapNhan) AS AR
	|WHERE
	|	AR.SoTienNgoaiTeBalance > 0
	|GROUP BY
	|	AR.DoiTac,
	|	AR.HopDong,
	|	AR.ChungTuGoc";

Q_AR.SetParameter("BoundaryDate", BoundaryNgayChot);
Q_AR.SetParameter("PhapNhan", RefPN);

RsAR = Q_AR.Execute().Unload();

For Each Row In RsAR Do
	GiaTriMoiVND = Round(Row.SoTienUSD * TyGiaMoi, 0);
	ChenhLech = GiaTriMoiVND - Row.SoTienVND;
	
	If ChenhLech > 0 Then
		// Lãi tỷ giá: Nợ 1312 / Có 4131
		RowGL = RegisterRecords.SoCaiKeToan.Add();
		RowGL.Period = NgayChot;
		RowGL.AccountDr = TK1312;
		RowGL.AccountCr = TK4131;
		RowGL.SoTien = ChenhLech;
		RowGL.DoiTacNo = Row.DoiTac;
		RowGL.HopDongNo = Row.HopDong;
		RowGL.ChungTuGoc = Row.ChungTuGoc;
		RowGL.DienGiai = StrTemplate("Đánh giá lại tăng công nợ phải thu ngoại tệ theo tỷ giá %1", TyGiaMoi);
	ElsIf ChenhLech < 0 Then
		// Lỗ tỷ giá: Nợ 4131 / Có 1312
		RowGL = RegisterRecords.SoCaiKeToan.Add();
		RowGL.Period = NgayChot;
		RowGL.AccountDr = TK4131;
		RowGL.AccountCr = TK1312;
		RowGL.SoTien = -ChenhLech;
		RowGL.DoiTacCo = Row.DoiTac;
		RowGL.HopDongCo = Row.HopDong;
		RowGL.ChungTuGoc = Row.ChungTuGoc;
		RowGL.DienGiai = StrTemplate("Đánh giá lại giảm công nợ phải thu ngoại tệ theo tỷ giá %1", TyGiaMoi);
	EndIf;
EndDo;
```

- [ ] **Step 3: Chạy bộ kiểm thử tự động**

Run: `python -B -m unittest discover -s scripts -p test_audit_tools.py -v`  
Expected: PASS.

- [ ] **Step 4: Commit thay đổi**

```bash
git add src/Documents/DanhGiaLaiNgoaiTe/Ext/ObjectModule.bsl
git commit -m "feat(gl): include foreign currency AR account 1312 in year-end FX revaluation"
```

---

### Task 7: Cấu Hình ChoiceParameterLinks Lọc Hợp Đồng Theo Đối Tác

**Files:**
- Modify: `src/Documents/HoaDonGTGTDauRa.xml:185-205`
- Modify: `src/Documents/HoaDonNhaCungCap.xml:185-205`

**Interfaces:**
- Consumes: Thuộc tính `DoiTac` trên form chứng từ.
- Produces: Danh sách sổ xuống (dropdown) của `HopDong` chỉ hiển thị các hợp đồng thuộc sở hữu của Đối tác đó.

**Kiến thức Newbie:**
- *Khái niệm ChoiceParameterLinks:* Trong 1C, nếu một trường là con của trường khác (ví dụ Hợp đồng thuộc về một Đối tác cụ thể), bạn không cần viết code sự kiện mở form. Bạn chỉ cần khai báo liên kết `ChoiceParameterLinks` trong XML metadata. Nền tảng 1C sẽ tự động áp bộ lọc `ChuSoHuu = Object.DoiTac` mỗi khi người dùng bấm vào ô chọn Hợp đồng!

- [ ] **Step 1: Mở `src/Documents/HoaDonGTGTDauRa.xml` tại thẻ thuộc tính `HopDong`**

Tìm đến Attribute `HopDong`, vị trí thẻ `<ChoiceParameterLinks/>`.

- [ ] **Step 2: Thêm định nghĩa bộ lọc phụ thuộc**

Thay thế thẻ rỗng `<ChoiceParameterLinks/>` bằng:
```xml
<ChoiceParameterLinks>
	<xr:Link>
		<xr:Name>Filter.ChuSoHuu</xr:Name>
		<xr:DataPath xsi:type="xs:string">Object.DoiTac</xr:DataPath>
		<xr:ValueChange>Clear</xr:ValueChange>
	</xr:Link>
</ChoiceParameterLinks>
```
*(Ý nghĩa: Khi người dùng đổi `DoiTac`, trường `HopDong` sẽ tự động xóa giá trị cũ (`Clear`) và chỉ mở ra danh sách hợp đồng của đối tác mới)*.

- [ ] **Step 3: Áp dụng tương tự cho `src/Documents/HoaDonNhaCungCap.xml`**

Thực hiện bổ sung cấu hình `ChoiceParameterLinks` tương tự cho trường `HopDong` liên kết với `Object.DoiTac` (hoặc `Object.NhaCungCap`).

- [ ] **Step 4: Chạy kiểm thử tự động**

Run: `python -B -m unittest discover -s scripts -p test_audit_tools.py -v`  
Expected: PASS.

- [ ] **Step 5: Commit thay đổi**

```bash
git add src/Documents/HoaDonGTGTDauRa.xml src/Documents/HoaDonNhaCungCap.xml
git commit -m "feat(ui): add ChoiceParameterLinks to filter contracts strictly by selected counterparty"
```

---

### Task 8: Kiểm Thử Hồi Quy Toàn Diện & Nghiệm Thu Hệ Thống

**Files:**
- Test scripts: `scripts/test_audit_tools.py`, `scripts/test_onec_runtime.py`, `scripts/test_clone_creation.py`

**Kiến thức Newbie:**
- Sau khi chỉnh sửa code kế toán và metadata, luôn luôn chạy toàn bộ các bài test có sẵn để đảm bảo:
  1. Không làm hỏng các tính năng cũ đang chạy tốt (Regression).
  2. Không có lỗi cú pháp BSL nào bị bỏ sót.
  3. Cấu trúc XML chuẩn xác, không bị lỗi thẻ đóng/mở.

- [ ] **Step 1: Chạy kiểm tra bộ công cụ Audit**

Run:
```powershell
python -B -m unittest discover -s scripts -p test_audit_tools.py -v
```
Expected: `Ran 24 tests ... OK`

- [ ] **Step 2: Chạy kiểm tra môi trường 1C Runtime**

Run:
```powershell
python -B -m unittest discover -s scripts -p test_onec_runtime.py -v
```
Expected: `Ran 22 tests ... OK (skipped=1)`

- [ ] **Step 3: Chạy kiểm tra cơ chế sao chép cơ sở dữ liệu kiểm thử**

Run:
```powershell
python -B -m unittest discover -s scripts -p test_clone_creation.py -v
```
Expected: `Ran 14 tests ... OK`

- [ ] **Step 4: Tổng kết và đánh dấu hoàn thành**

Kiểm tra trạng thái git:
```powershell
git status
git log -n 5 --oneline
```
Expected: Cây thư mục sạch sẽ (Clean working tree), toàn bộ 5 commit mới nằm gọn gàng trên nhánh làm việc.

---

## Hướng Dẫn Thực Hiện Dành Cho Người Dùng

Kế hoạch đã được biên soạn chi tiết và lưu trữ tại tệp:  
[docs/superpowers/plans/2026-10-15-remediate-1c-audit-findings.md](file:///C:/Users/Dung/Documents/1C_Enterprise/docs/superpowers/plans/2026-10-15-remediate-1c-audit-findings.md)

Bạn muốn triển khai kế hoạch này theo phương thức nào?
1. **Subagent-driven (Khuyên dùng):** Sử dụng các subagent song song thực hiện từng task độc lập và có subagent kiểm tra chéo sau mỗi task. Phương thức này an toàn, chặt chẽ và chuẩn quy trình nhất.
2. **Native (Trực tiếp trong phiên này):** Tôi sẽ tuần tự thực thi từng Task ngay tại phiên làm việc hiện tại, báo cáo tiến độ và nghiệm thu kết quả từng bước.
