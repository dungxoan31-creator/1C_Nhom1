# Báo cáo QA tự động AR/AP — 21/10/2026

## Kết quả run cuối

- Run: `finance-e2e-20261021-115703-8f32d72c589c4e71b1b1e218958738ad`.
- Full E2E: **85/85 phase PASS, 0 phase FAIL**, tiến trình kết thúc exit code 0.
- Metadata document fields: **114/114 được phân loại và có runtime case**: 41 trường bắt buộc bị từ chối khi rỗng, 7 trường tự điền/tính toán được xác nhận, 66 trường được lưu/đọc lại trong transaction rồi rollback.
- Boundary: 7 ca AR và 8 ca AP về MST/ngày, VAT, tỷ giá và FCT PASS. Ca `UyNhiemChi.SoTienNgoaiTe` xác nhận giá trị khác 0 bị từ chối khi tiền tệ là VND.
- Native UI: 16/16 màn hình mở được; 20/20 tab trên 5 custom document form được thăm; 7/7 form required-field từ chối Save rỗng; 5/5 bộ lọc hợp đồng theo đối tác và 5/5 bộ lọc kỳ danh sách PASS.
- Quyền: 5 vai trò × 10 assertion = **50/50 PASS**. Posting lifecycle, GL/subledger, DataLock concurrency, branch RLS, FX, netting, đối soát, ngân hàng và dashboard aging đều PASS.
- Test chạy trên clone tạm trong `%TEMP%`; `BaseInfobase` gốc không dùng làm nơi ghi dữ liệu kiểm thử.

**Phạm vi hiện có đều xanh; chưa thể xác nhận coverage strict 100% theo toàn bộ yêu cầu ban đầu.** Repo chưa có Sales Order, Purchase Order, Payment Request, metadata Report riêng hoặc dịch vụ khóa kỳ; một số command không có trên mọi form; field probe 66 trường xác nhận một giá trị hợp lệ qua lưu/đọc lại chứ không fuzz mọi kiểu sai, độ dài và ký tự cho từng field. Ma trận chi tiết ở [QA_AR_AP_coverage_matrix.md](QA_AR_AP_coverage_matrix.md).

## Kiến trúc và metadata đã khảo sát

| Loại | Số lượng | Ghi chú |
|---|---:|---|
| Catalog | 9 | ChiNhanh, DichVuCNTT, DoiTac, DuAn, HopDong, KhoanMucDongTien, PhapNhan, TaiKhoanTien, TienTe |
| Document | 7 | BBNT, hóa đơn AR, phiếu thu, hóa đơn AP, UNC, cấn trừ, đối soát kênh thanh toán |
| Accumulation register | 3 | CongNoPhaiThu, CongNoPhaiTra, DongTien |
| Accounting register | 1 | SoCaiKeToan |
| Information register | 2 | PhanQuyenChiNhanh, TyGiaHoiDoai |
| Data Processor | 1 | BanLamViecWebERP: dashboard và duyệt Maker-Checker |
| Common Module | 12 | Seed, workflow, quyền, thuế, FX, ngân hàng, dashboard và kiểm thử |
| Role | 5 | Admin, AR, AP, Kế toán trưởng, CFO |
| Report metadata | 0 | Aging chạy trên dashboard Data Processor, không có Report object riêng |

Đã đọc/đối chiếu object, manager và form modules liên quan đến vòng đời chứng từ, validation, posting/undo, quyền, tỷ giá, thuế và ngân hàng. Không có metadata Sales Order, Purchase Order hoặc Payment Request; luồng AR hiện bắt đầu từ BBNT và luồng AP từ hóa đơn nhà cung cấp. Không tìm thấy dịch vụ/metadata khóa kỳ kế toán.

## Lỗi được xử lý và nguyên nhân

| Phát hiện | Nguyên nhân gốc | Sửa chữa |
|---|---|---|
| Gọi `Write()` từ BSL có thể lưu chứng từ thiếu trường dù form có `FillChecking` | `FillChecking` của form không bảo vệ các lệnh ghi object trực tiếp | Thêm `ValidateRequiredFieldsForWrite(Cancel)` vào `BeforeWrite` của 7 document; thông báo gắn đúng field, validation nghiệp vụ vẫn được giữ. |
| Hóa đơn AR trực tiếp bị buộc phải có BBNT | Metadata đánh dấu `BienBanNghiemThu` bắt buộc dù luồng phát hành trực tiếp hợp lệ | Chuyển `FillChecking` thành `DontCheck`; nếu có nguồn BBNT thì BSL vẫn kiểm tra pháp nhân, đối tác, hợp đồng và trạng thái nguồn. |
| MST có thể lọt ký tự không phải số nếu chỉ kiểm tra độ dài | Validator cũ chưa xét từng ký tự | Chuẩn hóa khoảng trắng, chỉ nhận chữ số; độ dài cho phép là 10, 13 hoặc 14. |
| Tổng tiền, VAT, tỷ giá và FCT có thể lệch sau khi sửa chứng từ | Giá trị tính toán không luôn được tính lại nhất quán trước khi lưu/ghi sổ | Tính lại VAT/tổng AR; kiểm tra dung sai FX; tính FCT VAT/CIT, phải trả ròng và chi phí AP; boundary và GL/subledger regression PASS. |
| Quyền metadata mặc định không phản ánh Maker-Checker/SoD | Quyền Posting/Undo rộng hơn vai trò được phép nghiệp vụ | Khai báo quyền từ chối rõ trong Rights và kiểm thử 50 assertion theo 5 role. |
| UI automation chọn nhầm command cùng tên hoặc mở menu hai lần | Locator Save mơ hồ; 1C chưa foreground hoặc menu chưa kịp mở | Chọn đúng command row; `Open-ListCommand` phục hồi foreground, chờ có giới hạn và chỉ retry khi menu quan sát được là chưa mở. |
| Fixture đối soát âm thiếu cash-flow category loại Chi | Fixture âm được gọi trước setup dữ liệu phụ thuộc | Tạo category trong setup E2E trước khi chạy case âm; 7 ca lỗi và fee 0 PASS. |

### Sửa test harness trong vòng field-probe

- Probe ban đầu dùng số chứng từ trùng fixture `E2E-REQ-NOPARTNER`; cấp số riêng `XFP<case>` cho từng probe.
- Giá trị 1 ngoại tệ trên UNC VND bị logic hiện hành từ chối đúng. Probe hợp lệ dùng 0; một biến thể âm riêng khẳng định lỗi `A VND payment cannot contain a foreign-currency amount`.
- Không truy vấn database trong transaction sau một exception được mong đợi vì 1C đánh dấu transaction lỗi. Probe xác nhận exception, rollback transaction và kiểm tra document không tồn tại sau rollback.
- Đây là sửa fixture/automation; không bỏ assertion, không comment validation và không sửa logic kế toán để làm xanh test.

## File và điểm sửa chính

- Bảy ObjectModule bổ sung kiểm tra trường bắt buộc trong `BeforeWrite`: [BBNT](../../Configuration/Documents/BienBanNghiemThuGiaiDoan/Ext/ObjectModule.bsl#L41), [hóa đơn AR](../../Configuration/Documents/HoaDonGTGTDauRa/Ext/ObjectModule.bsl#L57), [phiếu thu](../../Configuration/Documents/PhieuThuTienKhachHang/Ext/ObjectModule.bsl#L53), [hóa đơn AP](../../Configuration/Documents/HoaDonNhaCungCap/Ext/ObjectModule.bsl#L52), [UNC](../../Configuration/Documents/UyNhiemChi/Ext/ObjectModule.bsl#L54), [cấn trừ](../../Configuration/Documents/CanTruCongNoNoiBo/Ext/ObjectModule.bsl#L15), [đối soát](../../Configuration/Documents/DoiSoatKenhThanhToan/Ext/ObjectModule.bsl#L21).
- Kiểm tra MST số-only và tính lại VAT/tổng AR: [HoaDonGTGTDauRa ObjectModule](../../Configuration/Documents/HoaDonGTGTDauRa/Ext/ObjectModule.bsl#L175).
- Field-probe 66 trường theo type, lưu/đọc lại và rollback: [SeedBoundaryTestsServer](../../Configuration/CommonModules/SeedBoundaryTestsServer/Ext/Module.bsl#L4674).
- Contract kiểm tra đủ 41 required + 7 auto + 66 field probes và case VND âm: [test_required_field_matrix.ps1](../../scripts/test_required_field_matrix.ps1#L46).
- Inventory metadata/form/runtime: [export_finance_field_inventory.ps1](../../scripts/export_finance_field_inventory.ps1#L25); tích hợp vào runner: [run_finance_e2e.ps1](../../scripts/run_finance_e2e.ps1#L236).
- Sửa thao tác menu/list trong UI automation: [run_finance_ui_e2e.ps1](../../scripts/run_finance_ui_e2e.ps1#L407).

## Bằng chứng run cuối

- [summary.json](summary.json) — trạng thái PASS, 85 phase.
- [required_field_runtime_matrix.json](required_field_runtime_matrix.json) — 41 required, 7 auto, 66 lưu/đọc lại, 7 boundary AR, 8 boundary AP.
- [document-field-inventory.csv](document-field-inventory.csv) và [summary](document-field-inventory.summary.json) — 114/114 thuộc tính, 20 tab audited, 0 thuộc tính không được phân loại.
- [ui-document-forms.json](ui-document-forms.json), [ui-required-field-validation.json](ui-required-field-validation.json), [ui-reference-choice.json](ui-reference-choice.json), [ui-list-periods.json](ui-list-periods.json), [ui-catalog-lists.json](ui-catalog-lists.json), [ui-posting-command-actions.json](ui-posting-command-actions.json).
- [ar-concurrency.json](ar-concurrency.json), [payment_reconciliation.json](payment_reconciliation.json), [dashboard_verify.json](dashboard_verify.json), [ar-seed-regression.json](ar-seed-regression.json), [ap-seed-regression.json](ap-seed-regression.json).
- Preview đã mở được cho 5/7 document có command; nội dung preview chưa đủ để xác nhận bản in nghiệp vụ hoàn chỉnh.
