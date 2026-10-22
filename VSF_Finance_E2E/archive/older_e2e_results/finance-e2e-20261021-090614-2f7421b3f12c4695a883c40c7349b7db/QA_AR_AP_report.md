# Báo cáo QA tự động AR/AP — 21/10/2026

## Kết quả chạy

- Run: `finance-e2e-20261021-090614-2f7421b3f12c4695a883c40c7349b7db`.
- Kết quả runner: **PASS 85/85 phase, 0 phase FAIL**.
- Hậu kiểm: 14/14 PowerShell script parse được; 122/122 XML cấu hình parse được; Role `QuanTriHeThong` hợp lệ qua 9 checks.
- Runtime field matrix: 41/41 required-field case, 7/7 giá trị tự quản lý, 7/7 boundary case PASS; mọi probe rollback.
- UI: 16/16 màn hình chứng từ/Data Processor mở được; 9/9 danh sách Catalog; Create/Copy 7/7 list chứng từ và 9/9 list Catalog; Save 2 enabled được gọi, 5 disabled được giữ nguyên; Print preview 5/5 lệnh có sẵn, 2 loại không có lệnh; lọc kỳ 5/5; chọn Đối tác → Hợp đồng 5/5.
- Bản chạy là clone trong `%TEMP%`; không ghi dữ liệu kiểm thử vào `BaseInfobase` gốc.

**Phân biệt phạm vi:** tất cả test đã thực thi đều xanh. Không thể xác nhận coverage nghiêm ngặt 100% theo mọi tiêu chí ban đầu vì một số chứng từ/đối tượng không tồn tại trong metadata, và chưa fuzz mọi field hay click mọi lệnh trên mọi role. Các khoảng trống được liệt kê ở cuối báo cáo.

## Khảo sát metadata và kiến trúc

| Loại metadata | Số lượng | Thành phần |
|---|---:|---|
| Catalogs | 9 | `ChiNhanh`, `DichVuCNTT`, `DoiTac`, `DuAn`, `HopDong`, `KhoanMucDongTien`, `PhapNhan`, `TaiKhoanTien`, `TienTe` |
| Documents | 7 | `BienBanNghiemThuGiaiDoan`, `HoaDonGTGTDauRa`, `PhieuThuTienKhachHang`, `HoaDonNhaCungCap`, `UyNhiemChi`, `CanTruCongNoNoiBo`, `DoiSoatKenhThanhToan` |
| Accumulation registers | 3 | `CongNoPhaiThu`, `CongNoPhaiTra`, `DongTien` |
| Accounting registers | 1 | `SoCaiKeToan` |
| Information registers | 2 | `PhanQuyenChiNhanh`, `TyGiaHoiDoai` |
| Data processors | 1 | `BanLamViecWebERP` — dashboard và form duyệt Maker-Checker hàng loạt |
| Object modules | 10 | 7 Document, Catalog `HopDong`/`ChiNhanh`, Data Processor `BanLamViecWebERP` |
| Manager modules | 1 | `BanLamViecWebERP` |
| Form modules | 12 | List/detail cho 5 Document có custom form và 2 form Data Processor |
| Common modules | 12 | `BangDieuKhienServer`, `GeneratorAPServer`, `GeneratorARServer`, `GeneratorMasterDataServer`, `PhanQuyenBaoMatServer`, `PheDuyetDaCapServer`, `QuanLyVongDoiChungTuServer`, `QuyTrinhPheDuyetAPServer`, `SeedBoundaryTestsServer`, `ThueGTGTClientServer`, `TichHopNganHangServer`, `UserProvisioningServer` |
| Roles | 5 | Admin, AR, AP, Kế toán trưởng, CFO |
| Reports | 0 | Aging/tổng hợp được kiểm tra trên dashboard Data Processor, không phải object Reports |

Không có metadata `Sales Order`, `Purchase Order` hoặc `Payment Request`. Luồng AR trong cấu hình bắt đầu từ biên bản nghiệm thu; luồng AP bắt đầu từ hóa đơn nhà cung cấp. Hai chứng từ Cấn trừ và Đối soát dùng form mặc định 1C.

Ngoài các module đối tượng/form/manager trên, cấu hình có `ManagedApplicationModule`, `SessionModule` và `InformationRegister.PhanQuyenChiNhanh.RecordSetModule`; BSL được rà theo các luồng ghi sổ, validation, RLS, phê duyệt, thuế và tích hợp ngân hàng.

## Ma trận kiểm thử

### Màn hình

| Nhóm | Màn hình đã mở/kiểm tra |
|---|---|
| Danh sách chứng từ (7) | Biên bản nghiệm thu; Hóa đơn GTGT đầu ra; Phiếu thu khách hàng; Hóa đơn nhà cung cấp; Ủy nhiệm chi; Cấn trừ công nợ; Đối soát kênh thanh toán |
| Chi tiết chứng từ (7) | Cả 7 loại chứng từ trên; kiểm tra input, trạng thái và lệnh trong form |
| Data Processor (2) | Bàn làm việc Web ERP; Bàn duyệt Maker-Checker hàng loạt |
| Catalog (9) | Chi nhánh; Dịch vụ CNTT; Đối tác; Dự án; Hợp đồng; Khoản mục dòng tiền; Pháp nhân; Tài khoản tiền; Tiền tệ |

Create và Copy được mở rồi đóng không lưu trên 7 list chứng từ và 9 list Catalog. Dashboard có assertion cho aging, kỳ, queue và workflow. Danh sách chứng từ được kiểm tra bộ lọc kỳ trên 5 loại có form danh sách tương ứng.

### Nút và lệnh

| Lệnh | Kết quả runtime |
|---|---|
| Create / Copy | Chứng từ 7/7; Catalog 9/9 |
| Save | 2/7 lệnh enabled được gọi và form vẫn mở; 5/7 lệnh disabled được xác nhận. Các form kiểm thử ở trạng thái đã ghi sổ. |
| Save rỗng | 7/7 form bị từ chối, không cấp số, không lưu, thông báo validation hiển thị |
| Post / Undo posting | UI native trên `E2E-NET-001` và `E2E-BK-VNPAY-001`: Undo → Post 2/2; trạng thái posted cuối cùng được khôi phục |
| Print preview | Gọi và quay về form 5/5 lệnh có sẵn: BBNT, AR invoice, receipt, AP invoice, payment. Cấn trừ và đối soát không có lệnh preview. Không gửi lệnh tới máy in vật lý. |
| Chứng từ liên quan | 4/4: AR invoice, phiếu thu, AP invoice, ủy nhiệm chi |
| Gửi ngân hàng | UI trả `ACCEPTED` và `HTTP_REJECTED`; retry giữ nguyên transaction ID |
| Xác nhận hoàn tiền | UI `RefundReceived` cho hoàn tiền gốc và chứng từ duplicate; idempotency được xác nhận |
| Phân quyền posting | Admin không được enable Post/Undo; quyền metadata bị deny trên 7 chứng từ. UI posting thực tế chạy bằng Kế toán trưởng. |

### Field và validation

41 field bắt buộc được xóa riêng lẻ, kiểm tra `Write` bị từ chối, không có số chứng từ và không tồn tại sau rollback:

| Chứng từ | Field đã kiểm tra |
|---|---|
| BBNT | `PhapNhan`, `DoiTac`, `HopDong`, `GiaTriNghiemThuChuaVAT` |
| Hóa đơn GTGT đầu ra | `PhapNhan`, `DoiTac`, `HopDong`, `SoHoaDon`, `KyHieu`, `NgayHoaDon` |
| Phiếu thu | `PhapNhan`, `DoiTac`, `HopDong`, `TaiKhoanTien`, `KhoanMucDongTien`, `SoTien` |
| Hóa đơn nhà cung cấp | `PhapNhan`, `DoiTac`, `HopDong`, `SoHoaDon` |
| Ủy nhiệm chi | `PhapNhan`, `DoiTac`, `HopDong`, `TaiKhoanTien`, `KhoanMucDongTien`, `TienTe`, `SoTien` |
| Cấn trừ công nợ | `PhapNhan`, `DoiTac`, `ChungTuAR`, `ChungTuAP`, `SoTien` |
| Đối soát kênh | `PhapNhan`, `DoiTacTrungGian`, `TaiKhoanTien`, `KhoanMucDongTien`, `TienTe`, `KenhThanhToan`, `TongTienGiaoDich`, `TongPhi`, `TongTienThucNhan` |

Giá trị tự điền được kiểm tra 7/7: `TongGiaTri`/`TrangThai` BBNT; `TongTienThanhToan` hóa đơn AR; `TienTe` phiếu thu; `NgayHoaDon`, `TienTe` và `TongTien` hóa đơn AP.

Boundary 7/7 trên hóa đơn AR: ngày hóa đơn tương lai bị chặn; MST chứa chữ, có gạch nối và MST 9 chữ số bị chặn; MST số 10/13/14 chữ số được nhận. Probe được rollback. Đây không phải fuzz mọi kiểu dữ liệu cho mọi field.

### Luồng nghiệp vụ và backend

| Luồng | Kết quả |
|---|---|
| AR | BBNT → hóa đơn 216 triệu (net 200 + VAT 16) → thu đủ; dư nợ về 0. Thu vượt 1 VND bị chặn, không sinh AR/GL/tiền. Hủy ghi sổ hóa đơn đã thu bị từ chối và giữ movement. |
| AP | Hóa đơn gross 200 triệu; FCT VAT 10 triệu + CIT 10 triệu; payable 180 triệu. Maker-Checker, gửi ngân hàng, trạng thái reject và posting được kiểm tra. |
| Cấn trừ | AR/AP netting giảm đúng số dư; kiểm tra thiếu số dư, repost, không phát sinh cash; thu phần AR còn lại về 0. |
| Tỷ giá | AR/AP USD, tỷ giá ghi sổ/thanh toán, lãi/lỗ thực hiện, dư nợ và số dư tiền; over-collection, refund và duplicate idempotency. |
| Đối soát VNPAY | Gross 75 triệu; phí 1,5% = 1,125 triệu; net 73,875 triệu; lệch 1 VND bị chặn. |
| Duyệt lô | Ngưỡng AP 500 triệu và 500 triệu + 1; 3 case được KTT duyệt, 1 case high-value được CFO duyệt. |
| Bảo mật | 5 role × 10 assertion = 50/50; branch RLS PASS. |
| Posting / sổ cái | Posting lifecycle 4/4; phát hiện GL/subledger mismatch và rollback 3/3; AP lifecycle 3/3; state invariants 5/5; boundary/security 3/3. |
| Khóa đồng thời | AR DataLock có holder nền; posting thứ hai chờ khóa; thu vượt số dư bị từ chối. |
| Seed tải hồi quy | AR: 1.260 BBNT, 1.260 hóa đơn, 1.162 phiếu thu. AP: 1.260 hóa đơn, gồm 315 USD; 1.085 duyệt bởi KTT và 175 bởi CFO. |

## Lỗi được phát hiện và sửa

| Lỗi | Nguyên nhân | Sửa chữa |
|---|---|---|
| Có thể ghi chứng từ rỗng qua luồng `Write` | Chỉ dựa vào kiểm tra FillChecking ở form, thiếu validation object-level dùng chung cho các đường ghi | Thêm `ValidateRequiredFieldsForWrite(Cancel)` và gọi trong `BeforeWrite` cho cả 7 Document; báo lỗi gắn với field, không xóa validation nghiệp vụ |
| Hóa đơn AR trực tiếp bị FillChecking chặn dù không có BBNT là luồng hợp lệ | `BienBanNghiemThu` bắt buộc ở metadata nhưng nghiệp vụ cho phép xuất hóa đơn trực tiếp | Đặt FillChecking của nguồn BBNT thành `DontCheck`; nếu nguồn được chọn, BSL vẫn so pháp nhân/đối tác/hợp đồng |
| MST đúng độ dài nhưng có chữ/ký tự vẫn qua validation | Validator cũ chỉ xét số ký tự | Chuẩn hóa chuỗi, kiểm từng ký tự thuộc `0123456789`, giữ độ dài hợp lệ 10/13/14 |
| Posting dimension có thể lệch chủ hợp đồng/pháp nhân | Chưa kiểm đủ chủ hợp đồng và dimensions trước khi ghi sổ | Kiểm tra chủ hợp đồng, pháp nhân và đối tác trước movement ở BBNT/AR/AP; case sai bị rollback |
| Admin có quyền posting theo mặc định nhưng server SoD từ chối | `Rights.xml` không khai báo quyền theo từng Document; default 1C khiến UI/backend quyền metadata rộng hơn ý định | Deny `Posting`, `UndoPosting` và quyền tương tác tương ứng trên 7 Document; giữ server guard SoD |
| UI test bấm nhầm Save | Có hai nút cùng tên; locator chọn icon Save thanh trên, có thể mở `Save As`, thay vì nút chữ Save của form | Locator phân biệt command row của form, fallback chỉ khi có đúng một candidate; blank Save giờ chạy đúng validation và 7/7 PASS |
| Runner yêu cầu Admin phải thấy nút Post | Assertion cũ không còn đúng sau khi quyền Admin bị khóa | Đổi assertion: Save phải hiện, không được có lệnh Post/Undo enabled; KTT kiểm tra thao tác thật riêng |

## File code/harness đã chỉnh

- Validation `BeforeWrite` cho cả 7 chứng từ: [BBNT](../../Configuration/Documents/BienBanNghiemThuGiaiDoan/Ext/ObjectModule.bsl), [AR invoice](../../Configuration/Documents/HoaDonGTGTDauRa/Ext/ObjectModule.bsl), [receipt](../../Configuration/Documents/PhieuThuTienKhachHang/Ext/ObjectModule.bsl), [AP invoice](../../Configuration/Documents/HoaDonNhaCungCap/Ext/ObjectModule.bsl), [payment](../../Configuration/Documents/UyNhiemChi/Ext/ObjectModule.bsl), [netting](../../Configuration/Documents/CanTruCongNoNoiBo/Ext/ObjectModule.bsl), [reconciliation](../../Configuration/Documents/DoiSoatKenhThanhToan/Ext/ObjectModule.bsl).
- Metadata luồng hóa đơn AR trực tiếp: [HoaDonGTGTDauRa.xml](../../Configuration/Documents/HoaDonGTGTDauRa.xml), `BienBanNghiemThu.FillChecking = DontCheck`.
- Fixture và runtime matrix: [SeedBoundaryTestsServer](../../Configuration/CommonModules/SeedBoundaryTestsServer/Ext/Module.bsl) — required-field, system fill, boundary MST/ngày, contract dimension, rollback.
- Tách nhiệm vụ posting cho Admin: [Rights.xml](../../Configuration/Roles/QuanTriHeThong/Ext/Rights.xml) — 35 quyền deny trên 7 Documents.
- UI locator và form/field/posting workflows: [run_finance_ui_e2e.ps1](../../scripts/run_finance_ui_e2e.ps1). Phase orchestration và quyền assertion: [run_finance_e2e.ps1](../../scripts/run_finance_e2e.ps1). Static/runtime form contract: [test_form_smoke_audit.ps1](../../scripts/test_form_smoke_audit.ps1).

Ví dụ MST trong `HoaDonGTGTDauRa/Ext/ObjectModule.bsl`:

```bsl
MaSoThueChuanHoa = TrimAll(MaSoThueNguoiMua);
DoDaiMST = StrLen(MaSoThueChuanHoa);
ChiCoChuSo = True;
For ViTriMST = 1 To DoDaiMST Do
    If StrFind("0123456789", Mid(MaSoThueChuanHoa, ViTriMST, 1)) = 0 Then
        ChiCoChuSo = False;
        Break;
    EndIf;
EndDo;
If (DoDaiMST <> 10 And DoDaiMST <> 13 And DoDaiMST <> 14) Or Not ChiCoChuSo Then
    Cancel = True;
    Msg = New UserMessage;
    Msg.Text = StrTemplate(NStr("vi = 'Mã số thuế ''%1'' không hợp lệ! MST phải gồm 10 chữ số hoặc 13-14 chữ số theo quy định.'; en = 'Tax identification number ''%1'' is invalid! Must contain 10 digits or 13-14 digits.'"), MaSoThueNguoiMua);
    Msg.Field = "MaSoThueNguoiMua";
    Msg.SetData(ThisObject);
    Msg.Message();
EndIf;
```

## Bằng chứng

- [summary.json](summary.json) — 85 phase PASS và dữ liệu tóm tắt.
- [ui-document-forms.json](ui-document-forms.json) — form, field inventory, Save/Print/related actions.
- [ui-posting-command-actions.json](ui-posting-command-actions.json) — Undo/Post 2/2, trạng thái cuối posted.
- [required_field_runtime_matrix.json](required_field_runtime_matrix.json) — 41 + 7 + 7 field cases.
- [ui-required-field-validation.json](ui-required-field-validation.json) — blank Save UI 7/7.
- [ui-reference-choice.json](ui-reference-choice.json) — chọn đối tác/hợp đồng 5/5.
- [ui-list-periods.json](ui-list-periods.json) — bộ lọc kỳ 5/5.
- [ui-catalog-lists.json](ui-catalog-lists.json) — Catalog list UI 9/9.

## Giới hạn coverage còn lại

- Không có Sales Order, Purchase Order, Payment Request hoặc object Reports nên không thể ghi PASS cho các luồng đó. Dashboard được kiểm tra như Data Processor.
- Không tìm thấy cơ chế khóa kỳ kế toán trong metadata/service; test sửa chứng từ trong kỳ đã khóa chưa thực hiện được.
- Chưa click mọi nút chuẩn/custom trên mọi role và mọi form. Post/Undo native UI thực hiện trên 2 loại chứng từ; các kiểm tra posting khác chạy backend.
- Chưa fuzz null, ký tự đặc biệt, độ dài và định dạng cho mọi field. Có 41 required-field riêng lẻ, 7 auto-fill và 7 biên ngày/MST.
- Hai chứng từ không có Print preview command; không in ra máy in vật lý.
- Đã kiểm tra một tình huống tranh chấp DataLock AR; chưa chạy stress test dài để chứng minh không deadlock dưới tải tùy ý.

Do đó, kết quả chính xác là **ALL EXECUTED TESTS GREEN (85/85)**; báo cáo không khẳng định strict 100% coverage cho các đối tượng/tình huống chưa có trong cấu hình hoặc chưa được chạy.
