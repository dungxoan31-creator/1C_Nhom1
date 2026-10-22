# Functional Inventory — cấu hình 1C VSF

**Trạng thái:** baseline discovery, lập trước khi sửa source BSL/XML. Đây là inventory kỹ thuật, chưa phải kết luận PASS.

## 1. Nền tảng và phạm vi

| Thuộc tính | Bằng chứng/giá trị |
|---|---|
| Nền tảng | 1C:Enterprise 8.3.22.1704 (`C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe`) |
| CompatibilityMode | Version8_3_22 |
| Configuration | Cấu hình tự phát triển; ManagedApplication; Taxi UI; BSL identifiers tiếng Anh |
| Locking | Managed (`DataLockControlMode=Managed`) |
| Database | File mode (`BaseInfobase/1Cv8.1CD`); runner làm việc trên bản sao disposable |
| Extensions | 0 extension gắn vào infobase đã kiểm tra; không có source CFE trong workspace |
| Thư viện | Không tìm thấy SSL/BSP hoặc Jet trong source |
| Source | 114 XML, 31 BSL, 9236 dòng BSL, 12 XML form quản lý |

## 2. Metadata inventory

| Loại metadata | Số | Đối tượng |
|---|---:|---|
| Subsystems | 5 | PhanHeDanhMuc, PhanHeNganHangVaQuy, PhanHePhaiThu, PhanHePhaiTra, PhanHeSoCaiVaDongBo |
| Catalogs | 8 | DichVuCNTT, DoiTac, DuAn, HopDong, KhoanMucDongTien, PhapNhan, TaiKhoanTien, TienTe |
| Documents | 5 | BienBanNghiemThuGiaiDoan, HoaDonGTGTDauRa, HoaDonNhaCungCap, PhieuThuTienKhachHang, UyNhiemChi |
| AccumulationRegisters | 3 | CongNoPhaiThu, CongNoPhaiTra, DongTien |
| AccountingRegisters | 1 | SoCaiKeToan |
| InformationRegisters | 1 | TyGiaHoiDoai |
| ChartsOfAccounts | 1 | HeThongTaiKhoan |
| DataProcessors | 1 | BanLamViecWebERP |
| CommonModules | 10 | BangDieuKhienServer, GeneratorAPServer, GeneratorARServer, GeneratorMasterDataServer, PhanQuyenBaoMatServer, PheDuyetDaCapServer, QuanLyVongDoiChungTuServer, QuyTrinhPheDuyetAPServer, SeedBoundaryTestsServer, UserProvisioningServer |
| Roles | 5 | GiamDocTaiChinh_CFO, KeToanPhaiThu, KeToanPhaiTra, KeToanTruong, QuanTriHeThong |
| Enums | 6 | HuongDongTien, LoaiDoiTac, TrangThaiHoaDonAP, TrangThaiHoaDonDienTu, TrangThaiLenhThanhToan, TrangThaiNghiemThuAR |
| Constants | 3 | ChoPhepSinhDuLieuMau, NguongPheDuyetChiTienCFO, PhapNhanMacDinh |
| CommonForms | 1 | TrangChuTongQuan |
| CommonPictures | 6 | LogoVSF, PhanHeDanhMuc, PhanHeNganHangVaQuy, PhanHePhaiThu, PhanHePhaiTra, PhanHeSoCaiVaDongBo |
| CommonTemplates | 1 | MauHTMLTrangChu |
| StyleItems | 14 | FunctionsPanelSectionColor, MauCanhBaoDoVSF, MauCanhBaoVangVSF, MauChuDaoDamVSF, MauChuDaoVSF, MauNenChinhVSF, MauNenPhuVSF, MauThongTinVSF, MauTrangThaiNhap, MauTrangThaiThanhCong, MauVanBanChinhVSF, MauVanBanPhuVSF, MauVanBanTrangVSF, MauVienChinhVSF |
| Languages | 2 | English, TiengViet |

**Tổng object metadata cấp cao:** 73; không bao gồm thuộc tính, dimension/resource và child objects.

### Phân hệ và khai báo nội dung

| Phân hệ | Đối tượng khai báo |
|---|---|
| PhanHeDanhMuc | DataProcessor.BanLamViecWebERP, Catalog.PhapNhan, Catalog.DoiTac, Catalog.HopDong, Catalog.TaiKhoanTien, Catalog.DichVuCNTT, Catalog.DuAn, Catalog.KhoanMucDongTien, Catalog.TienTe, InformationRegister.TyGiaHoiDoai |
| PhanHeNganHangVaQuy | DataProcessor.BanLamViecWebERP, Document.PhieuThuTienKhachHang, Document.UyNhiemChi, AccumulationRegister.DongTien |
| PhanHePhaiThu | DataProcessor.BanLamViecWebERP, Document.BienBanNghiemThuGiaiDoan, Document.HoaDonGTGTDauRa, Document.PhieuThuTienKhachHang, AccumulationRegister.CongNoPhaiThu |
| PhanHePhaiTra | DataProcessor.BanLamViecWebERP, Document.HoaDonNhaCungCap, Document.UyNhiemChi, AccumulationRegister.CongNoPhaiTra |
| PhanHeSoCaiVaDongBo | DataProcessor.BanLamViecWebERP, ChartOfAccounts.HeThongTaiKhoan, AccountingRegister.SoCaiKeToan |

### Chứng từ và sổ — trường chính

| Object | Attributes/Dimensions/Resources | Register records |
|---|---|---|
| Documents.BienBanNghiemThuGiaiDoan | Attribute:PhapNhan, Attribute:DoiTac, Attribute:HopDong, Attribute:GiaTriNghiemThuChuaVAT, Attribute:TyLeVAT, Attribute:TienVAT, Attribute:TongGiaTri, Attribute:TrangThai, Attribute:NguoiTao, Attribute:NguoiDuyet, Attribute:NgayNghiemThu, Attribute:DienGiai | AccountingRegister.SoCaiKeToan, AccumulationRegister.CongNoPhaiThu |
| Documents.HoaDonGTGTDauRa | Attribute:PhapNhan, Attribute:DoiTac, Attribute:MaSoThueNguoiMua, Attribute:DiaChiNguoiMua, Attribute:HopDong, Attribute:BienBanNghiemThu, Attribute:SoHoaDon, Attribute:KyHieu, Attribute:NgayHoaDon, Attribute:TienChuaThue, Attribute:ThueSuatVAT, Attribute:TienThueVAT, Attribute:TongTienThanhToan, Attribute:TrangThaiHDDT, Attribute:MaCQT, Attribute:DienGiai, Attribute:NguoiLap, Attribute:NguoiDuyet | AccountingRegister.SoCaiKeToan, AccumulationRegister.CongNoPhaiThu |
| Documents.HoaDonNhaCungCap | Attribute:PhapNhan, Attribute:DoiTac, Attribute:HopDong, Attribute:SoHoaDon, Attribute:NgayHoaDon, Attribute:TienTe, Attribute:TyGia, Attribute:TongTien, Attribute:TongTienNgoaiTe, Attribute:TienDichVu, Attribute:TienThueVAT, Attribute:CoKhauTruFCT, Attribute:TyLeThueVATNhaThau, Attribute:TyLeThueTNDNNhaThau, Attribute:TienThueVATNhaThau, Attribute:TienThueTNDNNhaThau, Attribute:ChiPhiVSF, Attribute:NoThucTraNCC, Attribute:TrangThai, Attribute:TaiKhoanChiPhi, Attribute:DienGiai, Attribute:NguoiLap, Attribute:NguoiDuyet | AccumulationRegister.CongNoPhaiTra, AccountingRegister.SoCaiKeToan |
| Documents.PhieuThuTienKhachHang | Attribute:PhapNhan, Attribute:DoiTac, Attribute:HopDong, Attribute:ChungTuGoc, Attribute:TaiKhoanTien, Attribute:KhoanMucDongTien, Attribute:TienTe, Attribute:SoTien, Attribute:SoTienNgoaiTe, Attribute:TyGia, Attribute:NgayThu, Attribute:DienGiai, Attribute:NguoiLap, Attribute:NguoiDuyet | AccumulationRegister.DongTien, AccountingRegister.SoCaiKeToan, AccumulationRegister.CongNoPhaiThu |
| Documents.UyNhiemChi | Attribute:PhapNhan, Attribute:DoiTac, Attribute:HopDong, Attribute:ChungTuGoc, Attribute:TaiKhoanTien, Attribute:KhoanMucDongTien, Attribute:TienTe, Attribute:TyGia, Attribute:SoTien, Attribute:SoTienNgoaiTe, Attribute:PhiNganHang, Attribute:TrangThai, Attribute:NgayLap, Attribute:NgayGhiSo, Attribute:LaTraSoatHoanTra, Attribute:NguoiLap, Attribute:NguoiDuyet, Attribute:DienGiai | AccumulationRegister.DongTien, AccumulationRegister.CongNoPhaiTra, AccountingRegister.SoCaiKeToan |
| AccumulationRegisters.CongNoPhaiThu | Resource:SoTien, Resource:SoTienNgoaiTe, Dimension:PhapNhan, Dimension:DoiTac, Dimension:HopDong, Dimension:ChungTuGoc | — |
| AccumulationRegisters.CongNoPhaiTra | Resource:SoTien, Resource:SoTienNgoaiTe, Dimension:PhapNhan, Dimension:DoiTac, Dimension:HopDong, Dimension:ChungTuGoc | — |
| AccumulationRegisters.DongTien | Resource:SoTien, Resource:SoTienNgoaiTe, Dimension:PhapNhan, Dimension:TaiKhoanTien, Dimension:TienTe, Dimension:KhoanMucDongTien | — |
| AccountingRegisters.SoCaiKeToan | Dimension:PhapNhan, Dimension:TienTe, Resource:SoTien, Resource:SoTienNgoaiTe, Attribute:ChungTuGoc, Attribute:TyGia, Attribute:DienGiai, Attribute:DoiTac, Attribute:HopDong, Attribute:TaiKhoanTien, Attribute:DoiTacNo, Attribute:DoiTacCo, Attribute:HopDongNo, Attribute:HopDongCo, Attribute:ChungTuGocNo, Attribute:ChungTuGocCo, Attribute:TaiKhoanTienNo, Attribute:TaiKhoanTienCo | — |
| InformationRegisters.TyGiaHoiDoai | Resource:TyGiaMua, Resource:TyGiaBan, Resource:TyGiaHachToan, Dimension:TienTe | — |
| ChartsOfAccounts.HeThongTaiKhoan | Attribute:MaLogic, Attribute:TenTaiKhoan, Attribute:TinhChat | — |
| Catalogs.DichVuCNTT | Attribute:MaDichVu, Attribute:TenDichVu, Attribute:TyLeVATMacDinh | — |
| Catalogs.DoiTac | Attribute:LaBenLienKet, Attribute:DaDangKyThueTrucTiep, Attribute:LoaiDoiTac, Attribute:MaSoThue, Attribute:DiaChi, Attribute:SoTaiKhoanNganHang, Attribute:TenNganHang | — |
| Catalogs.DuAn | Attribute:MaDuAn, Attribute:TenDuAn, Attribute:PhapNhan | — |
| Catalogs.HopDong | Attribute:PhapNhan, Attribute:ChuSoHuu, Attribute:GrossUpThue, Attribute:HanThanhToanNgay, Attribute:DongTienThanhToan | — |
| Catalogs.KhoanMucDongTien | Attribute:LoaiDongTien | — |
| Catalogs.PhapNhan | Attribute:MaSoThue, Attribute:DiaChi | — |
| Catalogs.TaiKhoanTien | Attribute:SoTaiKhoan, Attribute:NganHang, Attribute:TienTe | — |
| Catalogs.TienTe | Attribute:MaTienTe, Attribute:TenDayDu | — |

### Common modules: compiler flags and exported APIs

| Module | Server / ServerCall / Client / Privileged | Exported functions/procedures |
|---|---|---|
| BangDieuKhienServer | true / true / false / false | LayDuLieuTongQuan, ChuyenHTMLSangASCII |
| GeneratorAPServer | true / true / false / false | KhoiTaoChungTuAP, KiemTraChungTuAP |
| GeneratorARServer | true / true / false / false | KhoiTaoChungTuAR, KiemTraChungTuAR |
| GeneratorMasterDataServer | true / true / false / false | KhoiTaoMasterDataToanDien, KiemTraMasterData, BaoCaoThongKeTaiKhoan, KhoiTaoCacTaiKhoanConThieu, KhoiTaoHeThongTaiKhoanTT200 |
| PhanQuyenBaoMatServer | true / true / false / false | KiemTraMakerChecker, KiemTraQuyenChungTu, KiemTraQuyenBaoCao, LaAdminToanQuyen, LaQuanTriKhongNghiepVu, ThucThiKiemThuBaoMatToanDien, ThucThiKiemThuTask2Runtime, KiemTraMakerCheckerToanDien, DienThongTinAPMau, KiemTraMakerSessionRuntime, KiemTraCheckerSessionRuntime, KiemTraAdminSessionRuntime, KiemTraNhayCocTrangThaiRuntime, KiemTraDataExchangeLoadBypassRuntime, KiemTraLuuDaGhiSoUnpostedRuntime, KiemTraQuyTrinhTuanTuHopLeRuntime |
| PheDuyetDaCapServer | true / true / false / false | LayBoNhoMoPhong, XacDinhCapPheDuyetTheoSoTien, TinhTongLuyKeTrongThang, XacDinhCapPheDuyetHoaDon, KiemTraYeuCauDuyetCFO, DangKyHoaDon, XoaDuLieuLuyKeMoPhong |
| QuanLyVongDoiChungTuServer | true / true / false / false | GhiNhatKyInfo, GhiNhatKyError, KiemTraChoPhepSinhDuLieuMau, LaySoDuARTheoChungTu, LayTrangThaiDaLuu, TenTrangThai, KiemTraTrangThaiVaQuyen, KiemTraChuyenTrangThai, GanNguoiLapKhiTaoMoi, XuLyHuyGhiSo, DanhSachChungTuPhuThuoc, KiemTraKhopGLVaSoPhu, ThongBaoLoiChungTu, LayTaiKhoanTheoMaLogic, BangAnhXaTaiKhoanMacDinh, KiemTraCanDoiSoCai, KiemTraDoiSoatDocLapGLVaSoPhu, KiemTraDoiSoatTheoChieuDoiTacGiaLap, KiemTraDoiSoatTheoChieuTaiKhoanNganHangGiaLap, KiemTraDoiSoatThueGiaLap, KiemTraCachLyTheoCutoffGiaLap, KiemTraSaiTaiKhoanNhungDrBangCrGiaLap, ThucThiKiemThuTask6IntegrityRuntime, KiemThuChuTrinhGhiSoRuntime, KiemThuUATRollbackConcurrencyServer, LayDauVanMovements |
| QuyTrinhPheDuyetAPServer | true / true / false / false | XacDinhTrangThaiTiepTheo, KiemTraQuyenDuyet, TuChoiPheDuyet, KiemTraAntiSplit, KiemTraBuocDuyetAP, HoaDonCanDuyetCFO |
| SeedBoundaryTestsServer | true / true / false / false | RunFinanceE2EPhase, RunAPSeedRegression, PrepareFinanceE2E, SubmitFinanceE2EAcceptance, ApproveFinanceE2EAcceptance, PostFinanceE2EAcceptance, SubmitFinanceE2ESalesInvoice, IssueFinanceE2ESalesInvoice, CreateFinanceE2EReceipts, PostFinanceE2EReceipts, SubmitFinanceE2EVendorInvoice, PostFinanceE2EVendorInvoice, SubmitFinanceE2EPayment, ApproveFinanceE2EPayment, PostAndVerifyFinanceE2EPayment, RunBoundaries, KiemTraLogicARDemoV3, KiemTraLogicAPDemoV3, KiemTraAPNguongBienV3 |
| UserProvisioningServer | true / true / false / true | KhoiTaoDanhSachNguoiDung, KiemTraNguoiDungDaKhoiTao, DanhSachNguoiDungChuan |

### Entry points and security

- UI: 12 managed form XML (12 total), including document forms and two workspace forms; managed application startup module.
- HTTP/SOAP, scheduled jobs, exchange plans, reports, document journals and functional options: 0 metadata objects. OData exposure is not declared in the checked configuration properties; runtime exposure not separately confirmed.
- No `.epf`, `.erf`, `.cf` or CFE source found. No event subscriptions. Document ObjectModules directly implement `Filling`, `BeforeWrite`, `Posting`, and (where present) `UndoPosting`.
- Five roles exist. All five Rights.xml have 0 explicit object grant and 0 explicit RLS rules; effective runtime user permissions must be tested directly. `UserProvisioningServer` provisions Admin and four business users. DOCX names an additional reconciliation role that is absent.
- No ManagerModule on the five business documents. Data processor entrypoints: cockpit data, pending-approval list, bulk approval.

## 3. Functional Inventory (capability-level)

Grouping is by distinct business outcome, not metadata count. A documented flow is not counted as implemented without source evidence.

| ID | Capability | Entry point | Outputs | Test evidence / gap |
|---|---|---|---|---|
| C01 | Master data, chart of accounts, FX rates, demo setup and user provisioning | `GeneratorMasterDataServer`, `UserProvisioningServer` | Catalogs, ChartOfAccounts, `TyGiaHoiDoai` | Setup/seed exists; no production migration/import flow |
| C02 | Acceptance and AR revenue recognition | `BienBanNghiemThuGiaiDoan` | AR + GL | E2E covers; lifecycle/negative branches need wider runtime checks |
| C03 | Outgoing VAT invoice and AR debt transfer | `HoaDonGTGTDauRa` | AR + GL, VAT | E2E + boundary helper; DOCX reports autofill/UI gaps |
| C04 | Customer receipts, over-collection guard, cash/bank receipt | `PhieuThuTienKhachHang` | AR, cash, GL | VND happy + over-receipt; FX/refund/unpost unverified |
| C05 | Vendor invoice, FCT calculation, AP and approval threshold | `HoaDonNhaCungCap`, `QuyTrinhPheDuyetAPServer` | AP + GL + FCT liabilities | VND E2E and AP generated regression; tax scenarios are limited |
| C06 | AP payment, bank balance, fees/FX fields and overpayment guard | `UyNhiemChi` | AP, cash, GL | VND E2E; FX/fees/refund/return/unpost unverified |
| C07 | Maker-checker and AP staged approval | `PhanQuyenBaoMatServer`, `QuyTrinhPheDuyetAPServer` | document state and posting | Partial boundary tests; not a complete role × action matrix |
| C08 | Document lifecycle, unpost/repost, logs and GL/subledger reconciliation | `QuanLyVongDoiChungTuServer` | GL + subledger | Lifecycle routine not in runner; rollback/concurrency routine is placeholder |
| C09 | CFO dashboard and financial KPIs | workspace forms + `BangDieuKhienServer` | query aggregates/HTML | no value, empty-period or role-filter E2E checks |
| C10 | Batch approval | workspace manager/object/form | multiple document writes | uncovered; code treats a non-exception posting attempt as success |
| C11 | Four-tier AP approval, anti-split, budget CFO unlock | `PheDuyetDaCapServer` | approval escalation | exported code without production caller; missing budget register and approver roles |
| C12 | Deterministic data generation and boundary/regression harness | `GeneratorARServer`, `GeneratorAPServer`, `SeedBoundaryTestsServer` | fixtures and JSON results | part of existing E2E and stress aggregate |
| C13 | Internal AR/AP netting | No implementation in source metadata/BSL | none | DOCX describes it; current configuration has no document/register/flow |
| C14 | Payment channel/bank statement reconciliation | No implementation in source metadata/BSL | none | DOCX describes VNPAY/OnePay; current configuration has no document/register/import |

## 4. Business flow inventory

| ID | Flow | Steps / dependencies | Current runtime evidence |
|---|---|---|---|
| F01 | Setup/master data | user → legal entity/partner/contract/bank/account/currency/chart/rate → fixture opening balance | E2E setup + AP seed group |
| F02 | AR order-to-cash | acceptance submit/approve/post → issue VAT invoice → receive cash → verify AR/GL/cash residual | E2E covers core VND path; no UI or reversal/correction flow |
| F03 | AP invoice-to-pay | vendor invoice → KTT/CFO route → post → payment request → approve/send/post → verify AP/GL/cash/FCT | E2E covers one VND path; FX, fee, return, tax remittance not covered |
| F04 | Authorization | maker → checker → threshold route → role-specific post/deny | partial runtime assertions; effective 1C grants/RLS unproven |
| F05 | Dashboard/batch | KPI query → displayed values → eligible approval queue → per-document outcome | UI entrypoints exist; runtime automation absent |
| F06 | Lifecycle/reconciliation | post → movements → unpost/rollback → empty records → repost parity → GL/subledger check | helper routines exist but not wired to runner; UAT placeholder remains |
| F07 | Internal netting (documented) | check AR/AP minimum balance → reduce both subledgers → balanced GL | no current implementation |
| F08 | Channel reconciliation (documented) | gateway gross/fee/net equation → cash/fee/clearing postings | no current implementation |

## 5. Existing automation evidence (before this audit rerun)

- Runner: `VSF_Finance_E2E/scripts/run_finance_e2e.ps1`; copies file base, runs Designer `LoadConfigFromFiles` + `/UpdateDBCfg`, executes 1C Enterprise phases, asserts process exit code and JSON. It is CLI automation, not UI automation.
- Prior artifact: `VSF_Finance_E2E/results/finance-e2e-20261020-050752-5f7585e158794f89ac3741b092b28e2f/summary.json` reports 13/13 phases and 3/3 boundary-helper cases PASS; AP seed group reports 1,260 posted invoices/315 USD-valid. This evidence is from before the current audit and does not cover all capabilities.
- Existing groups: 13 phases + 3 boundary cases + 1 AP seed regression group. The 1,260 AP invoice count is data volume, not 1,260 independently reported assertions. Other callable security/lifecycle helpers are not in this runner.
- Do not label UI, external bank/e-invoice, internal netting, bank-statement reconciliation, or effective RLS as PASS without actual evidence.

## 6. Risks to reproduce before changing production source

| ID | Evidence | Suspected root | Reproduction needed |
|---|---|---|---|
| R01 | Batch approval catches ignored approver assignment; always marks success after `Write(Posting)` returns | false success if Posting sets `Cancel=True` or state is ineligible | real DB test using rejected/unpostable document; verify Posted/state/movements/result |
| R02 | UNC Posting clears records then returns for non-`DaGhiSo` without setting `Cancel` | posted document with no movements | `Write(Posting)` on ineligible state; verify Posted false and no registers |
| R03 | Outgoing invoice Posting returns for corrected/cancelled/replaced states without setting `Cancel` | posted document with no movements | runtime state/post consistency test |
| R04 | UAT rollback/concurrency test raises `NOT_RUN` | requested coverage is missing | implement transaction rollback and competing-balance test |
| R05 | Role Rights.xml has no explicit grants/RLS; payment Posting metadata is privileged | authorization may rely only on BSL guards | test actual role rights and unauthorized write/post for every business role |
| R06 | Dormant 4-tier approval module conflicts with two-stage AP; missing budget register/roles | conflicting/incomplete policy implementation | trace production call sites and mark unresolved policy NEED BUSINESS CONFIRMATION |
| R07 | DOCX describes netting and payment-channel reconciliation absent from source | scope mismatch, no runnable flow | confirm artifact/base metadata; do not count as existing implementation |
| R08 | Lifecycle/reconciliation suite has simulated cases and is not invoked by runner | weak runtime evidence | classify real DB vs simulated checks and wire real tests |
| R09 | Empty Except blocks across BSL modules | some failures may be silently swallowed | inspect each branch; fix only with repro and root cause |

## 7. Count summary

- Subsystems: 5; metadata objects: 73; functional capability groups: 14; implemented/source-backed capabilities: 12; described-only capabilities: 2.
- Business flows: 8 catalogued (6 source-backed/partial, 2 documentation-only).
- HTTP/SOAP services: 0; scheduled jobs: 0; exchange plans: 0; reports: 0; roles: 5.
- Existing runnable groups: 17 (13 phases + 3 boundary cases + 1 aggregate regression); no claim that all have passed in the current run.

> Scope note: C13–C14 are included because the DOCX describes them, but they are absent from current source metadata and are therefore not counted as working system capabilities. The previous user requirement named internal netting and banking reconciliation, so these remain explicit scope gaps pending source-level assessment and implementation decision.
