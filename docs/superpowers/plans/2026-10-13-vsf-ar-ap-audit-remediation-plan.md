# Kế hoạch khắc phục audit VSF AR/AP

> **Dành cho người thực thi:** Dùng `superpowers:executing-plans` hoặc một quy trình triển khai có review độc lập để thực hiện từng task. Không chạy task ghi dữ liệu trên infobase gốc.

**Mục tiêu:** Khắc phục các lỗi có bằng chứng trong audit hiện tại, chứng minh tính đúng đắn trên 1C:Enterprise 8.3 và dữ liệu vận hành được phê duyệt, rồi chấm lại theo cùng rubric mà không đặt trước điểm đích.

**Kiến trúc:** Giữ 1C là nguồn dữ liệu kế toán và quản trị duy nhất; chứng từ, sổ phụ, Sổ Cái và KPI phải truy nguyên về dữ liệu trong infobase. Tách khắc phục thành các cổng độc lập: hạch toán và netting, kiểm soát quyền, báo cáo/dữ liệu, rồi hardening và nghiệm thu runtime. Mọi thay đổi schema phải có phương án nâng cấp/backfill được kiểm tra trên bản sao infobase.

**Tech Stack:** 1C:Enterprise 8.3 (BSL, XML metadata, infobase `.1CD`), Python cho kiểm tra tĩnh và điều phối test, PowerShell cho vận hành môi trường.

**Spec:** Finding của audit hiện tại trong phiên làm việc ngày 13/10/2026 và các yêu cầu audit của người dùng. `docs/ERP_AUDIT_2026-10-12.md` cùng `docs/superpowers/plans/2026-10-13-audit-score-elevation-plan.md` chỉ là tài liệu tham khảo cũ; không lấy điểm, kết luận hoặc giả định “đã sửa” từ các tài liệu này làm yêu cầu hiện trạng.

## Ràng buộc chung

- Chỉ dùng 1C làm nguồn dữ liệu nghiệp vụ/kế toán; không thêm endpoint, adapter, job, bảng trạng thái hay luồng đọc/ghi SAP, Oracle ERP hoặc ERP ngoài.
- Không sửa/xóa infobase gốc, `.dt` gốc hoặc dữ liệu vận hành. Chỉ nâng cấp và chạy test ghi dữ liệu trên bản sao có thể khôi phục.
- Không đưa mật khẩu mẫu/secret vào source, log, tài liệu phát hành hoặc kết quả test; không để tài khoản tạo sẵn có mật khẩu rỗng.
- Bút toán ghi sổ phải cân Nợ/Có, đúng kỳ, pháp nhân, đối tượng, hợp đồng và loại tiền; chạy lại cùng một thao tác không được nhân đôi nghiệp vụ.
- Không dùng test Python mô phỏng làm bằng chứng thay cho thực thi chứng từ trên runtime 1C.
- Không đánh dấu kiểm soát là đã xác minh khi mới đọc tĩnh BSL/XML. Mỗi cổng nghiệm thu phải nêu riêng bằng chứng static, test tự động và kiểm thử 1C runtime.
- Audit ban đầu đối chiếu TT200 theo yêu cầu. Trước go-live năm tài chính 2026, kế toán trưởng/pháp chế phải phê duyệt ma trận áp dụng TT99/2025/TT-BTC và quy tắc chuyển tiếp; không suy ra tuân thủ chỉ từ việc giữ tên tài khoản.

## Review focus

1. Ghi sổ đồng thời: hai phiên thanh toán/netting cùng đọc một số dư và ghi vượt số dư; kiểm thử lock và retry ở task 1.
2. Người tạo giả mạo người duyệt qua form, gọi server trực tiếp, sửa trạng thái hoặc `DataExchange.Load`; kiểm thử từ tài khoản thực ở task 2.
3. Chứng từ lịch sử thiếu analytic keys hoặc có nhiều pháp nhân/đối tác; đối chiếu backfill và cách ly ngoại lệ ở task 3.
4. Kỳ báo cáo rỗng, kỳ ngắn, biên ngày, đảo/hủy chứng từ, tỷ giá tăng/giảm; test ở task 1 và task 4.
5. Một báo cáo con lỗi nhưng batch tiếp tục; trạng thái tổng phải phản ánh lỗi, kèm danh sách thành công/thất bại ở task 4.

## Phạm vi và cách chia workstream

Đây là master plan cho bốn mảng có thể review độc lập. Thực hiện tuần tự theo các phụ thuộc dưới đây vì schema và quy tắc ghi sổ là nền cho KPI/đối soát. Nếu đội triển khai cần phân công song song, chốt interface của task trước rồi mới tách; không để hai nhánh cùng sửa một module BSL hoặc metadata.

### Task 0: Chốt baseline và bộ chứng cứ tái lập

**Files:**
- Create: `scripts/audit/remediation_manifest.json` (danh sách test, môi trường, hash đầu vào và loại bằng chứng).
- Create: `docs/superpowers/reports/remediation-evidence-template.md`.
- Reference only: `scripts/test_1c_only.py`, `scripts/verify_bsl_syntax.py`, `scripts/audit_codebase.py` và các script test nêu ở task sau.

**Interfaces:**
- Xuất manifest theo từng test gồm `command`, `target_infobase`, `mutates_data`, `expected_artifacts`, `evidence_class` (`static`, `python_simulation`, `1c_runtime`).
- Mọi test ghi dữ liệu bắt buộc target bản sao UAT, kèm snapshot/restore ID.

- [ ] Đọc `git rev-parse --show-toplevel`, branch, commit, `git status --short` và ghi lại các thay đổi có sẵn; tuyệt đối không đưa file local của người dùng vào commit sửa lỗi.
- [ ] Tạo bản sao infobase UAT từ nguồn được phê duyệt; xác nhận mở được bằng đúng phiên bản 1C 8.3 và lưu hash/snapshot trước test.
- [ ] Lập manifest cho test hiện hữu và đánh dấu các script có side effect: `test_executive_reports.py`, `test_user_roles.py`, `test_dashboard_cfo.py`, `test_ledger_integrity.py`, generators/seeds.
- [ ] Chạy baseline chỉ đọc: `python scripts/test_1c_only.py`, `python scripts/test_env_isolation.py`, `python scripts/verify_bsl_syntax.py`, `python scripts/audit_codebase.py`; lưu stdout/stderr, exit code và phân loại cảnh báo heuristic.
- [ ] Không chạy script có side effect trước khi kiểm tra nội dung script, backup UAT và xác nhận đường dẫn target không trỏ về infobase gốc.

**Điều kiện qua cổng:** Manifest và snapshot UAT có thể tái lập; mọi test đã biết có trạng thái mutating/read-only; baseline được lưu cùng commit/hash. Task này không làm tăng điểm chức năng.

### Task 1: Đúng đắn kế toán, FX, netting và tính toàn vẹn sổ

**Files dự kiến:**
- Modify: `src/Documents/UyNhiemChi/Ext/ObjectModule.bsl`.
- Modify: `src/Documents/CanTruCongNoNoiBo/Ext/ObjectModule.bsl`.
- Modify nếu test xác nhận cần: `src/CommonModules/QuanLyVongDoiChungTuServer/Ext/Module.bsl`.
- Inspect/modify có căn cứ: `src/Documents/HoaDonNhaCungCap/Ext/ObjectModule.bsl`, `src/AccountingRegisters/SoCaiKeToan.xml`, chart of accounts metadata và các module ghi register liên quan.
- Tests: `tests/unit/UyNhiemChiStateReversalTest.bsl`, `scripts/test_ledger_integrity.py`; thêm test chuyên biệt FX/netting dưới `tests/` hoặc `scripts/` theo pattern hiện có.

**Interfaces:**
- Ghi nhận thanh toán bằng hai giá trị riêng: `GiaTriTatToanCongNoVND` theo giá trị ghi sổ của khoản phải trả; `GiaTriGiamTienGuiVND` theo số tiền thực xuất ngân hàng. Chênh lệch thực hiện được sinh thành bút toán 515/635, không sửa sai số dư AP/cash để ép cân.
- Netting kiểm tra số dư theo khóa đầy đủ trước ghi sổ; check và consume số dư nằm trong cùng transaction/lock. Nếu 1C cung cấp idempotency key phù hợp, dùng khóa nghiệp vụ bền vững; nếu không, xác định khóa duy nhất từ chứng từ nguồn và loại nghiệp vụ.
- Hàm xác minh bút toán trả về tổng Nợ/Có và chênh lệch theo chứng từ/pháp nhân/tiền tệ; reject chứng từ không cân trước khi commit.

- [ ] Viết test đỏ cho thanh toán USD với hóa đơn USD 100, tỷ giá ghi nợ 25.000 và tỷ giá ngân hàng 26.000: AP giảm 2.500.000 VND, 1122 giảm 2.600.000 VND, Nợ 635 là 100.000 VND, tổng Nợ = tổng Có. Thêm ca tỷ giá giảm tạo Có 515, làm tròn, thanh toán một phần, hủy/đảo và chạy post lại.
- [ ] Chạy test trên harness hiện có để xác nhận test thất bại trên logic hiện tại; nếu harness không gọi BSL/runtime, ghi rõ đây chỉ là unit/static test, không nâng thành bằng chứng 1C.
- [ ] Sửa `UyNhiemChi` để lấy giá trị công nợ gốc từ chứng từ/ledger nguồn, lấy giá trị xuất quỹ từ tỷ giá và loại tiền thanh toán; loại bỏ `Try/Except` nuốt lỗi quanh phần xác định FX. Lỗi dữ liệu/tỷ giá phải rollback đầy đủ và được log có correlation/document reference.
- [ ] Thêm kiểm tra đối chiếu `CongNoPhaiTra`, `DongTien`, `SoCaiKeToan` sau post, unpost và repost. Chứng minh đảo chứng từ tạo bút toán đảo đối xứng, không để lại register movement hoặc số dư ngoại tệ lệch.
- [ ] Viết test đỏ cho netting: thiếu chứng từ gốc, số dư bằng 0/âm, số tiền vượt số dư, sai đối tác/pháp nhân/tiền tệ, cùng chứng từ nguồn bị net hai lần, hai phiên cạnh tranh và chạy lại cùng request.
- [ ] Sửa `CanTruCongNoNoiBo` để bắt buộc chứng từ nguồn hợp lệ; số dư phải lớn hơn hoặc bằng số netting và khớp pháp nhân, đối tác, hợp đồng, loại tiền. Chỉ cho netting đa phương khi có đủ căn cứ pháp lý/metadata về novation và các chân bút toán đối ứng.
- [ ] Thực hiện lock dữ liệu đúng phạm vi và transaction ngắn: đọc số dư, kiểm tra, tạo movement và ghi idempotency marker trong một đơn vị nguyên tử. Khi xung đột, báo lỗi có thể retry; không ghi một phần.
- [ ] Thêm test tính bất biến cho netting song phương/đa phương: `ΣNợ = ΣCó`, tổng giảm AR/AP đúng bằng phần được cấn trừ, số dư tài khoản bắc cầu theo thiết kế bằng 0, lần chạy lại không phát sinh thêm movement.
- [ ] Rà soát tài khoản theo chart of accounts và mapping hiện hành: 1311/1312, 3311/3312/3313/3318, 1121/1122, 5113, 33311, 1331, 641/642/627, 635/515, 1388/3388. Ghi rõ tài khoản nào dùng theo loại nghiệp vụ và pháp nhân; không hard-code thay đổi tài khoản khi chưa có phê duyệt kế toán trưởng.
- [ ] Điều tra tài khoản 4131: xác định chính sách kế toán và kỳ đánh giá lại được phê duyệt, phân biệt chênh lệch đã thực hiện/chưa thực hiện, lập bút toán cuối kỳ và bút toán đảo đầu kỳ nếu yêu cầu. Chỉ tạo chứng từ/mapping mới sau khi chốt chính sách; không tự động chuyển toàn bộ số dư 4131 sang 515/635 nếu quy định hoặc chính sách chưa xác nhận.
- [ ] Kiểm tra quy tắc thuế ở `HoaDonNhaCungCap`: loại bỏ mặc định 5% nếu không được xác định bằng loại dịch vụ, pháp nhân, ngày hiệu lực và căn cứ thuế; lưu dấu vết quy tắc đã áp dụng. Test dịch vụ chịu thuế/không chịu thuế, nhiều mức và ngày hiệu lực.
- [ ] Chạy kiểm thử trên bản sao UAT bằng 1C: tạo/post/unpost/repost chứng từ; truy vấn trực tiếp register và đối chiếu từng bút toán; lưu trace/query và snapshot trước-sau. Chỉ chấp nhận nếu delta GL–subledger theo pháp nhân/đối tác/hợp đồng/tiền tệ bằng 0 hoặc có danh sách ngoại lệ được phê duyệt.

**Điều kiện qua cổng:** Không lỗi cân Nợ/Có hoặc chênh lệch subledger; FX loss/gain ghi đúng 515/635 và tách trị giá AP với dòng tiền; netting không vượt số dư và idempotent khi chạy lại; đảo/hủy chính xác; chính sách thuế và 4131 có phê duyệt. Không dùng mock Python làm cổng cuối.

### Task 2: Maker–Checker, SoD, quyền 1C và an toàn vận hành

**Files dự kiến:**
- Modify: `src/CommonModules/PhanQuyenBaoMatServer/Ext/Module.bsl`.
- Modify: `src/CommonModules/QuanLyVongDoiChungTuServer/Ext/Module.bsl`.
- Modify các `src/Documents/*/Ext/ObjectModule.bsl` thực sự phát sinh hoặc phê duyệt: tối thiểu kiểm kê `UyNhiemChi`, `CanTruCongNoNoiBo`, `HoaDonNhaCungCap`, `HoaDonGTGTDauRa`, `BaoCoNganHang`.
- Modify theo role/object sau khi lập matrix: `src/Roles/*/Ext/Rights.xml`.
- Modify: `src/CommonModules/UserProvisioningServer/Ext/Module.bsl`, `scripts/setup_sample_users.ps1`, tài liệu hướng dẫn credential.
- Tests: `scripts/test_user_roles.py` và test 1C runtime maker-checker/SoD chuyên biệt.

**Interfaces:**
- `KiemTraMakerChecker(ChungTu, NguoiDungHienTai, HanhDong)` xác định maker từ dữ liệu máy chủ/audit trail; approver lấy từ session 1C; từ chối nếu maker=approver hoặc caller cung cấp danh tính khác `UserName()`.
- Mọi chuyển trạng thái gọi một service phía server duy nhất, ví dụ `QuanLyVongDoiChungTuServer.KiemTraChuyenTrangThai(ChungTu, TrangThaiCu, TrangThaiMoi, NguoiDungHienTai)`, có quyền rõ cho từng transition. Form chỉ là UX, không phải ranh giới bảo mật.
- Trạng thái lưu cần có audit trail bất biến gồm người, thời điểm, trạng thái trước/sau và lý do; không cho bypass bằng sửa thuộc tính trực tiếp hoặc load không được ủy quyền.

- [ ] Tạo test đỏ cho từng loại chứng từ: maker tự duyệt qua form, gọi exported server function, sửa status trực tiếp, sửa `NguoiDuyet`, user không có role, và `DataExchange.Load`; xác nhận quyền được đánh giá theo principal/session thực tại server.
- [ ] Lập state-transition matrix cho draft/submit/approve/reject/post/cancel/unpost và actor-role; xác minh đúng tên status/enum hiện có trước khi sửa. Gọi `KiemTraChuyenTrangThai` tại tất cả điểm ghi thực tế, không chỉ thêm helper không có caller.
- [ ] Ràng buộc người duyệt lấy từ `UserName()`/session đã xác thực; không tin `TenNguoiDung` do client truyền lên. Lưu maker/approver bằng reference người dùng nếu metadata hỗ trợ, hoặc một định danh ổn định đã được chuẩn hóa; không dựa trên tên hiển thị có thể đổi.
- [ ] Chặn maker tự duyệt ở server cho mọi chứng từ quan trọng. Kiểm tra lại ngay trước Post trong cùng transaction để tránh race giữa approve và post. Revoke/đảo chứng từ dùng transition và quyền riêng.
- [ ] Điều tra mọi nhánh `If DataExchange.Load Then Return`: phân biệt import được ủy quyền với bypass kiểm soát. Không cấm bulk migration hợp lệ một cách mù quáng; dùng service principal/quyền import giới hạn, audit log, validate tương đương và test cả importer lẫn user thường.
- [ ] Lập ma trận SoD theo object, CRUD, Post, approve, unpost, quyền quản trị. Cấu hình Rights XML tối thiểu cần thiết cho AR, AP, PM/TechLead; xác minh quyền metadata và kiểm tra BSL đồng nhất. Chặn quyền tại thao tác server/ghi sổ thật, không chỉ ẩn command trên form.
- [ ] Thêm test âm runtime cho tài khoản `KeToanPhaiThu`, `KeToanPhaiTra`, `PM`, `TechLead` và test dương cho role đúng; kiểm tra gọi API/server, direct write, post và approve. Test admin riêng, không dùng admin để chứng minh kiểm soát nghiệp vụ.
- [ ] Loại bỏ mật khẩu mặc định `123` và đường fallback mật khẩu rỗng trong `UserProvisioningServer`; provisioning phải nhận secret từ nguồn bảo mật của môi trường hoặc dừng với lỗi rõ. Không ghi secret ra console/log.
- [ ] Sửa `setup_sample_users.ps1`: không mặc định AdminPassword rỗng; yêu cầu secret tương tác/secure input hoặc secret store và từ chối placeholder ở production. Xóa mật khẩu mẫu khỏi hướng dẫn phát hành; mọi tài khoản test chỉ dùng UAT và được thay secret.
- [ ] Kiểm thử Operational Safety Gate: bên liên quan Vingroup quá hạn vẫn không tự động bị khóa dịch vụ; khách ngoài quá hạn trên 60 ngày chỉ tạo cờ/đề xuất, không tự đổi trạng thái hạn mức/khóa bán. Kiểm chứng cả service server-side và giao diện.
- [ ] Kiểm thử `DataExchange.Load` ở hai lớp: import principal hợp lệ có audit/validate; user không đủ quyền bị chặn. Kiểm tra không thể gọi module/hàm nội bộ từ client để giả principal.

**Điều kiện qua cổng:** Không có đường tự duyệt hoặc ghi sổ trái quyền từ bất kỳ entry point nào được kiểm kê; quyền runtime khớp matrix; DataExchange chỉ chạy theo principal được cấp quyền và có log; không có credential mặc định/rỗng; các gate quá hạn giữ đúng hành vi.

### Task 3: Analytic keys, dữ liệu lịch sử và khả năng đối chiếu

**Files dự kiến:**
- Inspect/modify: `src/AccountingRegisters/SoCaiKeToan.xml`.
- Modify các module ghi GL/subledger và `src/Documents/BaoCoNganHang/Ext/ObjectModule.bsl` nếu kiểm tra xác nhận hợp đồng/đối tượng đang bị mất.
- Modify: `scripts/test_ledger_integrity.py`; thêm kiểm tra migration/backfill dưới `scripts/audit/` hoặc suite hiện có.

**Interfaces:**
- Mọi dòng GL AR/AP lưu hoặc truy xuất được `PhapNhan`, `DoiTac`, `HopDong`, `ChungTuGoc`, `TienTe`, tài khoản và kỳ. Khi tài khoản/kịch bản không áp dụng một chiều đối tác thì ghi null theo quy tắc được tài liệu hóa, không tự điền giả.
- Migration/backfill là dry-run trước; xuất số lượng dòng đủ/thiếu/không duy nhất/không thể suy ra, không tự suy đoán đối tượng từ tên hoặc số dư tổng.
- Đối chiếu nhận phạm vi kỳ/pháp nhân và trả sai lệch theo khóa chi tiết; tổng toàn cục không được che mất lệch giữa đối tượng.

- [ ] Phân tích metadata register và toàn bộ writer để lập inventory analytic keys thực tế. Truy vấn dữ liệu GL hiện có, tính tỷ lệ thiếu theo từng key, tài khoản, pháp nhân, kỳ và loại chứng từ; lưu kết quả trước thay đổi.
- [ ] Nếu cần bổ sung dimension, viết kiểm thử metadata/configuration và kiểm thử mở configuration bằng 1C trước. Xác nhận ảnh hưởng tới register dimensions, query, report, exchange/load, posting và dung lượng; không tự thêm trường `DoiTacNo/DoiTacCo` nếu một dimension `DoiTac` theo dòng đã đủ về nghiệp vụ.
- [ ] Thiết kế backfill có provenance: lấy từ chứng từ nguồn/metadata liên kết đáng tin cậy; phân loại dòng không suy ra được thành ngoại lệ. Chạy dry-run trên snapshot, review danh sách và số lượng trước apply.
- [ ] Kiểm tra `BaoCoNganHang` giảm công nợ theo khóa `(PhapNhan, DoiTac, HopDong, ChungTuGoc, TienTe)` và không bỏ mất hợp đồng. Không dùng tổng số tiền để tự chọn một hóa đơn khi nhiều dòng có thể khớp.
- [ ] Sửa `KiemTraDoiSoatDocLapGLVaSoPhu` hoặc service tương ứng để so theo pháp nhân/tài khoản/đối tác/hợp đồng/tiền tệ/kỳ; thêm đối chiếu 112 với sổ phụ dòng tiền/ngân hàng và giải thích timing items.
- [ ] Viết test dữ liệu lịch sử: đầy đủ keys, thiếu key xác định được, thiếu key không thể xác định, duplicate reference, nhiều pháp nhân, tiền tệ khác nhau. Không báo PASS nếu chỉ tổng toàn cục cân trong khi một nhóm chi tiết lệch.
- [ ] Chạy migration và reconcile trên bản sao UAT; đối chiếu trước/sau số dư tổng, số dư theo key, số dòng, số dòng ngoại lệ. Khóa dữ liệu/đảm bảo rollback nếu migration fail.

**Điều kiện qua cổng:** Mọi dòng mới có analytic keys bắt buộc; dữ liệu lịch sử được backfill có provenance hoặc nằm trong danh sách ngoại lệ có chủ sở hữu/phê duyệt; đối chiếu AR/AP/cash theo chiều chi tiết; Configuration.xml và tất cả object tham chiếu mở/compile được trên 1C.

### Task 4: CFO Dashboard, báo cáo, chỉ số và bộ sinh dữ liệu

**Files dự kiến:**
- Modify: `src/DataProcessors/DashboardLanhDaoCFO/Ext/ObjectModule.bsl`.
- Modify: `src/CommonModules/BaoCaoQuanTriServer/Ext/Module.bsl`.
- Inspect/modify: `src/CommonModules/GeneratorARServer/Ext/Module.bsl`, `GeneratorAPServer`, `GeneratorNettingReconcileServer`, `SeedFullTestData` và schema `docs/superpowers/reports/executive_reports_data.json` chỉ như fixture nếu được quản lý test.
- Tests: `scripts/test_dashboard_cfo.py`, `scripts/test_executive_reports.py`, generator tests chuyên biệt.

**Interfaces:**
- Mỗi KPI có hợp đồng: định nghĩa, công thức, numerator/denominator, ngày bắt đầu/kết thúc, ngày ghi nhận hay ngày chứng từ, pháp nhân, trạng thái chứng từ và nguồn register/query.
- AR/AP ageing tính theo số dư mở tại ngày báo cáo; nhóm tuổi rời nhau và bao phủ toàn bộ dư nợ; loại bỏ chứng từ bị hủy/đảo theo quy tắc đã chốt.
- DSO/DPO dùng số dư bình quân đầu/cuối kỳ khi có dữ liệu; công thức và kỳ đo được hiển thị. Nếu dùng ending balance do giới hạn dữ liệu thì nêu rõ, không gán nhãn chuẩn nếu chưa được kế toán duyệt.
- Bộ xuất báo cáo trả trạng thái và lỗi theo từng report; tổng trạng thái chỉ `SUCCESS` khi tất cả report bắt buộc thành công.

- [ ] Viết test cho kỳ báo cáo bắt đầu/kết thúc, đúng biên ngày, chứng từ tương lai, kỳ rỗng, nhiều pháp nhân, posted/unposted/cancelled và chứng từ đảo. Chứng minh truy vấn có lower bound nếu KPI được định nghĩa theo kỳ.
- [ ] Chốt công thức KPI với kế toán/CFO trước khi đổi code: revenue nội bộ/khách ngoài theo doanh thu ghi nhận trong kỳ; AR/AP ageing theo số dư mở tại ngày chốt; DSO/DPO theo định nghĩa được phê duyệt, cùng mẫu số/kỳ đo và ngày thực tế. Không chỉnh generator để ép doanh thu vào 75/25 hoặc dùng một tỷ lệ mẫu như mục tiêu thực tế.
- [ ] Sửa query `DashboardLanhDaoCFO` để áp dụng đúng phạm vi kỳ, pháp nhân, trạng thái; hỗ trợ drill-through từ KPI tới chứng từ/register source, có bộ lọc/correlation đủ để tái lập số.
- [ ] Tính lại KPI từ fixture có số liệu biết trước và từ dữ liệu sinh ra. Ghi rõ công thức, mẫu số, ngày đầu/cuối, số ngày, nguồn data; test cả số dư bình quân/ending balance theo chính sách được duyệt.
- [ ] Kiểm tra phí cổng thanh toán và Virtual Account: xác định hợp đồng/cấu hình làm căn cứ cho 1,5%, 2,2%, 0,5%; tách phí theo kênh khỏi tài khoản nhận tiền VA. Thêm test để `KP-TEST1` thật sự đi qua nhánh phí 0,5% nếu đó là yêu cầu nghiệp vụ đã duyệt; nếu không, sửa tài liệu/test expectation cho đúng hợp đồng, không suy từ tên kênh.
- [ ] Kiểm tra scenario pháp nhân VinFast sau tái cấu trúc bằng danh mục pháp nhân/effective dates có nguồn phê duyệt; test phân loại liên công ty theo pháp nhân hiệu lực tại ngày giao dịch. Không tuyên bố tỷ trọng doanh thu VSF thực tế từ seed.
- [ ] Chạy seed AR/AP/netting trên UAT hai lần và chứng minh idempotency, rollback khi lỗi, số dòng và tổng tiền ổn định; điều tra cảnh báo transaction heuristic bằng call graph/runtime log trước khi sửa. Không chia transaction chỉ để làm hết cảnh báo static nếu điều đó phá tính nguyên tử.
- [ ] Sửa batch export: thu thập kết quả từng báo cáo; log exception có report ID; trả `PARTIAL_FAILURE`/`FAILED` nếu có lỗi; chỉ `SUCCESS` khi đủ toàn bộ report. Test lỗi giữa batch và chạy lại an toàn.
- [ ] Tính độc lập các chỉ số trên output thực tế: tỷ lệ revenue nội bộ/ngoài, tuổi nợ, DSO/DPO, gross/net payment và phí. Lưu input rows hoặc query extract đã ẩn dữ liệu nhạy cảm để auditor tái tính. Gắn nhãn mọi output generator là sample/test data, không phải số liệu vận hành xác nhận.

**Điều kiện qua cổng:** Dashboard/report truy vết được tới source, đúng phạm vi kỳ và trạng thái; lỗi con không thể bị báo thành success toàn phần; mọi tỷ lệ được tái tính bằng input đã lưu; seed chạy lặp không duplicate; tỷ lệ nội bộ/ngoài chỉ được báo cáo theo dataset cụ thể và không bị dùng như assertion về cơ cấu thực tế.

### Task 5: Quyền triển khai, compile và kiểm thử end-to-end trên 1C

**Files:**
- Validate: `src/Configuration.xml` và toàn bộ `src/**/*.xml`, `src/**/*.bsl`.
- Review/modify tests: `scripts/test_executive_reports.py`, `scripts/test_user_roles.py`, `scripts/test_dashboard_cfo.py`, `scripts/test_ledger_integrity.py`.
- Create: `docs/superpowers/reports/vsf-ar-ap-uat-acceptance-<date>.md`.

**Interfaces:**
- Release candidate gồm source revision, configuration version, DB/schema migration revision, 1C platform version, extension list, role matrix, test manifest và rollback procedure.
- Acceptance report cho từng test lưu command, user/role, infobase snapshot ID, exit code, log reference, assertions, evidence class, reviewer.

- [ ] Chạy parser XML cho toàn bộ metadata; kiểm tra từng reference object/attribute/form/module và phát hiện orphan hoặc tên sai. Xác nhận compiler 1C chấp nhận toàn bộ configuration; `verify_bsl_syntax.py` chỉ là gate phụ.
- [ ] Kiểm tra quyền export/import, file paths, logging không lộ secret, xử lý lỗi/transaction, lock/retry, quyền client/server và version tối thiểu thực tế. Chạy static scanner; mỗi cảnh báo đóng bằng sửa có test hoặc tài liệu hóa false positive dựa trên code path.
- [ ] Đọc từng script test trước khi chạy; điều chỉnh runner để nhận `--infobase`/environment config rõ ràng, fail-closed nếu đường dẫn là production/original. Đảm bảo `test_executive_reports.py` không ghi đè artifact người dùng ngoài thư mục output riêng.
- [ ] Chạy tuần tự trên snapshot UAT với user phù hợp: kiểm soát `test_user_roles`, maker-checker/SoD, chứng từ FX/netting, `test_ledger_integrity`, `test_dashboard_cfo`, `test_executive_reports`, seeds và các case đảo/hủy. Chạy lại các test idempotency sau restore hoặc với idempotency key mới được kiểm soát.
- [ ] Thực hiện UAT có kế toán: mẫu AR/AP VND và USD, payment gain/loss, netting song phương/đa phương, bank receipt, over-60-day external customer, Vingroup overdue, fee/VA, kỳ đóng sổ và reverse. Lưu chứng từ nguồn, GL lines, subledger, register balance, báo cáo và phê duyệt expected values.
- [ ] Kiểm tra hiệu năng/khóa trên khối lượng dữ liệu đại diện và concurrency; đo thời gian truy vấn dashboard/reconcile, deadlock/retry và thời gian migration. Không chạy load test trên production.
- [ ] Chuẩn bị rollback source/configuration và database migration; chạy diễn tập restore từ snapshot và đối chiếu hash/số dư.
- [ ] Tái audit từng finding F01–F11 theo trạng thái `fixed-static`, `verified-runtime`, `not-applicable-with-evidence`, `open`. Không xóa finding cũ khi chưa có bằng chứng kiểm chứng.
- [ ] Chấm lại bốn tiêu chí /25 bằng cùng rubric audit. Nêu phần điểm chưa thể xác minh vì thiếu dữ liệu thực tế, cấu hình thuế/pháp lý hoặc runtime. Chỉ ký nghiệm thu khi các cổng critical/high đóng và kế toán trưởng/phụ trách 1C phê duyệt.

**Điều kiện qua cổng:** Configuration import/compile thành công trên đúng 1C 8.3; test runtime và UAT có trace; snapshot rollback được; không có finding Critical/High còn mở; mọi ngoại lệ Medium/Low có owner và chấp nhận rủi ro; điểm mới phản ánh bằng chứng thu được, không phải mức điểm đặt trước.

## Bản đồ finding và phụ thuộc

| Finding audit | Task khắc phục chính | Bằng chứng cần có để đóng |
|---|---|---|
| F01 Maker–Checker và bypass trạng thái/DataExchange | 2, 5 | Negative tests từ server/form/runtime cho mọi transition và principal |
| F02 Thanh toán USD, AP/cash và FX 515/635 | 1, 5 | GL, AP, cash movement cân theo hai trị giá; runtime gain/loss/reversal |
| F03 Netting thiếu kiểm tra số dư, khóa, idempotency | 1, 5 | Concurrency test, retry test, GL/subledger zero delta trên 1C |
| F04 Mật khẩu mặc định/rỗng | 2, 5 | Static scan + provisioning/runtime tests; không có secret trong output |
| F05 SoD và rights metadata không chứng minh chặn tại điểm ghi | 2, 5 | Role matrix và runtime deny/allow cho direct server/write/post |
| F06 Thiếu analytic keys trên GL hiện hữu | 3, 5 | Profile dữ liệu lịch sử, backfill provenance, reconcile chi tiết |
| F07 KPI phạm vi kỳ/công thức chưa đủ căn cứ | 4, 5 | Công thức được phê duyệt và tái tính từ input có ngày/phạm vi rõ |
| F08 Báo cáo con lỗi nhưng trả success | 4, 5 | Injected failure runtime tạo status non-success và log truy vết |
| F09 Chưa thấy đánh giá lại 4131; thuế FCT mặc định | 1, 5 | Chính sách kế toán/thuế được duyệt và test posting/period-end |
| F10 Phí 1,5%/0,5%/2,2% và VA chưa được chứng minh theo hợp đồng | 4, 5 | Mapping hợp đồng–kênh–phí–VA và case runtime cho từng nhánh |
| F11 Compile/runtime, transaction heuristic, binary infobase chưa xác minh | 0, 1–5 | Compile 1C, test UAT, log transaction/concurrency, backup/restore |
| Kiến trúc độc lập 1C | 0, 5 | Tái quét source/metadata/config/scripts, không có luồng ERP ngoài |

## Nguyên tắc chấm điểm lại

- Dùng rubric 4 × 25 điểm của audit gốc. Mỗi khoản trừ phải trỏ đến finding và tác động riêng; không trừ hai lần cùng nguyên nhân gốc.
- Test tĩnh có thể đóng lỗi cấu hình/tên tham chiếu nhưng không thể chứng minh hành vi runtime. Kiểm soát trọng yếu chỉ được xác minh khi compile/chạy 1C và kiểm thử role/transaction thực tế.
- Không đặt trước 95/100 hay 100/100. Điểm tối đa chỉ xem xét khi có runtime evidence cho kiểm soát trọng yếu, dữ liệu lịch sử và policy thực tế được phê duyệt, đồng thời không còn giới hạn xác minh chưa giải quyết.
- Mẫu dữ liệu chỉ xác nhận generator/test scenario. Tỷ lệ doanh thu, tuổi nợ và phí của mẫu không đại diện số vận hành nếu chưa có dữ liệu nguồn và xác nhận chủ sở hữu.

