# Codebase Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Loại bỏ các nguy cơ mất dữ liệu, sai số kế toán và kết quả kiểm thử sai lệch đã xác minh trong codebase 1C; chỉ công bố trạng thái đạt khi có bằng chứng chạy trên bản sao infobase.

**Architecture:** Giữ nguyên cấu trúc metadata 1C và các module nghiệp vụ hiện có. Chặn thao tác seed tại điểm vào, sửa giao dịch/khóa đúng luồng, rồi thay các test dựa vào chuỗi log cũ bằng kết quả có mã phiên chạy. Mọi thao tác ghi dữ liệu và `/LoadConfigFromFiles` chỉ chạy trên infobase clone dùng riêng cho UAT.

**Tech Stack:** 1C:Enterprise 8.3.22.1704, BSL, XML metadata, Python stdlib, PowerShell, Git.

**Spec:** `docs/superpowers/specs/2026-10-14-comprehensive-audit-remediation-design.md` (bối cảnh nghiệp vụ). Kế hoạch này thay các khẳng định “100/100” của spec bằng các gate có thể kiểm chứng và bổ sung các lỗi phát hiện trực tiếp trong source.

**Trạng thái đo hiện tại:** Khắc phục đã được chấp thuận, mới xác minh một phần; chưa đạt 100/100 hay đủ điều kiện go-live. [Báo cáo tiến độ](../reports/2026-10-14-hardening-progress.md) do main cập nhật; manifest cuối `docs/evidence/hardening_verification.json` do main tổng hợp kết quả chính xác theo từng run/hash source. Checkbox chỉ đánh dấu phần đã hoàn tất; bước tổng hợp còn thiếu bằng chứng giữ mở. Không commit trong đợt cập nhật tài liệu này.

- Final2: native CheckConfig PASS; hardening mới nhất 3 ca PASS run `e6ff5fadff7b4f8e9ce8c277769cc3e8` gồm Admin tự posting đối soát qua DataExchange.Load RED → GREEN, guard checker trước import và trong Posting. Unit 2 ca PASS run `b10d7a97d1fd4a5a9fd2a9afdf733834`, phí PASS run `02a645200b6c45ce94294b9e9b7e5631`, lifecycle 3 ca PASS run `9cd312e36c4f4568af3bf64d0dbbbfe0` với checker `ketoan_truong`, RBAC rerun 6 người dùng/12 ca PASS. Lifecycle so POST chuẩn bằng build hiện tại trong transaction rollback rồi UNPOST/REPOST; không xác minh legacy-key migration parity (baseline legacy sẽ khác vì fields analytic mới). Native `review-check.log` sau đăng ký NettingReversal module PASS. Admin bị từ chối duyệt đúng chính sách; CLI lifecycle mặc định checker.
- Final3 bổ sung: lifecycle 3 ca PASS run `79bb1718fa474687bae86dddca6a7d9f`, gồm POST lần hai trên cùng object rồi UNPOST/GetObject/REPOST bằng build hiện tại trong transaction rollback. Native RED VAT AR/AP GL row count 2 thay vì 1; clear movement sets do document sở hữu ở đầu Posting, GREEN. Không chứng minh legacy-key migration parity. Netting characterization 6 ca PASS run `d9332e59d23041a292b76118719a164e`, gồm foreign_units/duplicate_reversal; không chứng minh concurrency.
- Final3 native CheckConfig run `e8111bd968cf45e4bad24587d449ad94` PASS, exit 0, No errors found; source/dump 180/180 file, 0 khác biệt sau kiểm/canonical hóa 3 XML biểu diễn native (newline/BOM, namespace/indent). Mapping 641 và quyền role gốc được giữ, không phải migration.
- Offline hiện đo: audit 24 OK, runtime 22 OK (1 ca skip quyền symlink), clone creation 14 OK, netting offline 3 OK. Concurrent offline 22, self-test 4 và backfill wrapper 3 ca được agent báo PASS; tổng host dự kiến 101 test = 100 PASS + 1 skip chờ phần final run còn lại kết thúc. Manifest final3 chờ main; chưa công bố tổng hoàn tất.
- Payment 4 và FX 3 ca PASS tuần tự, không chứng minh concurrency. Hai phiên thật vẫn NOT_RUN vì giới hạn giấy phép/kết nối Training Edition; genuine rerun cùng source final3 được lên kế hoạch.
- GL data quality FAIL: 8.215/8.579 đủ partner + contract, thiếu 364 (360 dòng đối soát 1388 thiếu contract, 4 dòng AR/AP thiếu cả partner và contract). Không tạo contract giả/backfill khi thiếu khóa ngoại hợp lệ. Backfill wrapper đã bỏ global Stop-Process/password, yêu cầu clone tường minh và trả unsupported NOT_RUN; đây chưa phải bằng chứng mutation thành công.
- Seed dương supplementary: smoke GREEN run `6c4a16567cf2411ea3ebbb886b833397`, 10 Ref; bounded full 210/21 tháng GREEN run `c90fc51b640e45a4b4d4f3e9aa804ae0`, AR 105 + AP 63 + netting 42 Ref. Mỗi run đủ 9 phase PASS, GL keys mới PASS, 3 maker thật + checker/Admin restore. Wrapper full yêu cầu `-BoundedWorkflow`, massive yêu cầu `-MetadataOnly`; bulk generator gốc giữ có guard để tương thích.
- Supplementary atomic boundaries 1/49/50/51 PASS run `cbdc24580e814156982f72eaf1bace03` trên prepared clone `20261014-seed-positive`, Admin enable/restore PASS. Fingerprint toàn bộ AR gồm tabular sections giữ mọi Ref/content, GL count không đổi, transaction đóng và manifest của seed lỗi không được công bố. Collision đi qua lookup số thật của NewSample; không chứng minh legacy batch-50 partial commits.
- Còn mở: legacy batch-50 biên 1/49/50/51 NOT_RUN, legacy full-volume khoảng 4.800+ NOT_RUN, SourceBslReference NOT_RUN (21 unit + 3 migration = 24 file), pilot và phê duyệt finance. Full canary phải giữ đúng phạm vi đã đo ở supplementary AR, không mở rộng sang mọi legacy seed. Chờ manifest cuối để đối chiếu final metadata/source.

## Global Constraints

- Không chạy seed, xóa chứng từ, backfill, cập nhật cấu hình hoặc test có ghi dữ liệu trên `Infobase_FullData` hay file `.dt` phát hành. Tạo clone riêng, xác nhận đường dẫn và backup trước khi chạy.
- Không gọi `Stop-Process -Name '1cv8*'`: script chỉ được dừng tiến trình do chính nó tạo nếu cần.
- Mỗi test runtime phải có ID phiên chạy, kết quả mới, đủ số ca kỳ vọng và exit code phản ánh thất bại. Không chấp nhận log cũ hoặc chỉ tìm một chuỗi `PASS`.
- Không thêm `pytest` chỉ vì môi trường thiếu nó; dùng `unittest`/`assert` của Python stdlib và 1C Designer `/CheckConfig` cho cú pháp BSL.
- Không sửa hàng loạt `DataExchange.Load`, `CurrentDate()` hoặc tách module chỉ để làm sạch số cảnh báo; yêu cầu chứng minh tác động nghiệp vụ trước.

## Review Focus

- Chứng từ người dùng có cùng loại/số gần giống chứng từ mẫu vẫn được giữ nguyên sau seed: Task 1 kiểm tra số lượng, Ref và hash các bản ghi canary trước/sau.
- Seed lỗi giữa lô không để transaction mở hoặc làm mất dữ liệu đã có: Task 2 tiêm lỗi ở đầu, giữa và cuối lô; kiểm tra rollback/partial commit theo hợp đồng đã định.
- Hai phiên cùng chi/đánh giá lại một số dư không được cùng vượt số dư: Task 4 chạy hai phiên 1C độc lập và đối chiếu ledger cuối.
- Một test con thất bại hoặc runner chết sớm không thể tạo báo cáo xanh: Task 3 kiểm tra cả hai nhánh và log sai run ID.
- Document `DataExchange.Load` không thể ghi trạng thái đã ghi sổ nhưng chưa Posted: Task 5 chạy âm tính trên clone qua `BeforeWrite` thực tế.

---

### Task 1 — P0: Khóa an toàn cho toàn bộ seed, bỏ xóa AR quá rộng

**Files:** `src/CommonModules/GeneratorARServer/Ext/Module.bsl:20,478`, `src/CommonModules/GeneratorAPServer/Ext/Module.bsl:335`, `src/CommonModules/GeneratorNettingReconcileServer/Ext/Module.bsl:258`, `src/CommonModules/GeneratorMasterDataServer/Ext/Module.bsl`, `src/CommonModules/SeedDataCleanServer/Ext/Module.bsl`, `src/CommonModules/SeedFullTestDataServer/Ext/Module.bsl`, `src/Ext/ManagedApplicationModule.bsl`, `src/Configuration.xml`, `src/Constants/ChoPhepSinhDuLieuMau.xml` (mới), `scripts/run_seed_ar_data.ps1`, `scripts/run_seed_ap_data.ps1`, `scripts/run_seed_netting_data.ps1`, `scripts/run_seed_master_data.ps1`, `scripts/run_seed_clean_data.ps1`, `scripts/run_seed_full_data.ps1`, `scripts/run_seed_massive_data.ps1`, test runtime mới tại `scripts/test_seed_safety.py`.

**Interfaces:** `KiemTraChoPhepSinhDuLieuMau()` (BSL, fail closed) được gọi trước mọi entry point `Seed*` và `KhoiTao*`; constant Boolean mặc định `False`, chỉ bật trong clone UAT. Các runner nhận `-IBPath` rõ ràng và từ chối tên/path `Infobase_FullData`.

- [x] Guard đã triển khai; hồi quy sáu entry point seed cờ False từ RED sang GREEN trên clone. Đây là phần đã đo, chưa hoàn tất full canary hoặc legacy full-volume.
- [x] Seed dương supplementary bounded smoke: run `6c4a16567cf2411ea3ebbb886b833397` đủ 9 phase PASS, 10 Ref riêng biệt và GL keys mới PASS bằng ba maker thật/checker/Admin restore. Wrapper full yêu cầu `-BoundedWorkflow -Smoke`; massive metadata-only yêu cầu `-MetadataOnly`. Lệnh tại [README](../../../README.md#seed-dương-bổ-sung-trên-clone).
- [x] Tái hiện native RED: `15809b62f5ad431a93918fc651d08279` acceptance 1312 thiếu keys; `645a1bc57b7e47ce84591bdfc8b23ca3` thiếu helper AR; `03ed208743344c7e91c1f38ca50adb78` AR/AP PASS, đối soát 1388 thiếu contract FAIL. Source sửa acceptance/VAT debit keys, AP credit keys từ trường chứng từ hợp lệ, helper current AR availability có khóa/loại own recorder và GL đối soát theo partner/contract từng dòng; smoke GREEN kiểm chứng 10 Ref mới.
- [x] Xác minh supplementary bounded full 210 Ref/21 tháng: run `c90fc51b640e45a4b4d4f3e9aa804ae0`, AR 105 + AP 63 + netting 42; đủ 9 phase PASS gồm restore bằng bốn người dùng tài chính thật và Admin metadata.
- [ ] Xác minh full canary ngoài phạm vi supplementary AR và legacy full-volume khoảng 4.800+; không thay nghiệm thu lớn bằng supplementary bounded 10/210. Legacy full-volume và legacy batch-50 biên 1/49/50/51 vẫn NOT_RUN; bulk generator gốc giữ có guard.

- [ ] Viết test âm tính: trên clone có canary chứng từ thật ở cả bốn loại AR, gọi seed khi cờ `False` phải bị từ chối và không đổi bất kỳ Ref/record count nào.
- [ ] Xác nhận test đỏ; bổ sung guard tại entry point BSL và script; kiểm tra tất cả call site `/C Seed...` bằng `rg -n 'Seed.*Data|KhoiTao.*' src/Ext scripts`. Bật constant bằng thao tác quản trị trên clone UAT sau khi xác minh đường dẫn; giữ mặc định `False` trong mọi `.dt` phát hành.
- [ ] Xóa `XoaDuLieuARCu()` và lời gọi đang `SELECT Ref FROM Document.<loại>` không có `WHERE`; dùng clone sạch cho mỗi lần seed AR. Với AP/netting, bỏ dọn tự động hoặc chỉ giữ dọn theo Ref/provenance được tạo trong cùng phiên chạy; không chọn theo partner/prefix đơn lẻ.
- [ ] Kiểm tra `FindByNumber` của AR/AP không ghi đè chứng từ không do phiên seed tạo; nếu đụng số, fail với danh sách Ref va chạm, không sửa bản ghi đó.
- [ ] Chạy test lại: canary không đổi, seed trên clone được phép với cờ `True`, gọi trên clone cờ `False` bị chặn. Commit riêng P0.

### Task 2 — P0: Giao dịch lô và xử lý lỗi của generator

**Files:** `src/CommonModules/GeneratorARServer/Ext/Module.bsl:57,478`, `src/CommonModules/GeneratorAPServer/Ext/Module.bsl:145,335`, `src/CommonModules/GeneratorNettingReconcileServer/Ext/Module.bsl:258,318,411`, `src/CommonModules/SeedFullTestDataServer/Ext/Module.bsl`, test runtime `scripts/test_seed_transactions.py`.

**Interfaces:** Hợp đồng legacy cần xác minh: một lô tối đa 50 chứng từ; lỗi rollback lô đang mở, giữ lô đã commit và dừng seed. Supplementary workflow dùng transaction atomic riêng; kết quả của nó không nghiệm thu partial commits của legacy batch-50.

- [x] Supplementary atomic AR boundaries 1/49/50/51: native run `cbdc24580e814156982f72eaf1bace03` đủ 4 ca PASS, Admin enable/restore PASS. Prepared clone giữ mọi AR Ref/content gồm tabular sections và GL count; collision qua NewSample lookup thật, transaction đóng, failed seed manifest không được công bố. Chỉ chứng minh atomic supplemental error handling.
- [ ] Tiêm lỗi legacy batch-50 ở chứng từ 1/49/50/51: kiểm transaction đóng, GL/subledger không dở dang và số lô đã commit đúng hợp đồng partial commits. NOT_RUN; không lấy supplementary atomic PASS thay cho gate này.
- [x] Xác nhận collision netting RED; đưa `BeginTransaction/CommitTransaction/RollbackTransaction` của vòng lặp vào cùng `Try/Except`, cập nhật cờ transaction, `Raise` sau rollback. Collision GREEN chứng minh transaction đóng và GL không đổi; chưa chứng minh legacy batch-50 biên 1/49/50/51.
- [ ] Thay `Except` rỗng trong các hàm dọn dữ liệu bằng rollback + log Ref lỗi + `Raise`; không bỏ qua `UndoPosting`/`Delete` thất bại.
- [ ] Chạy bốn điểm tiêm lỗi legacy batch-50 và seed legacy bình thường trên clone, đối chiếu chứng từ/GL/subledger và partial commits. Supplementary bounded seed/atomic boundaries đã đo riêng, không hoàn tất gate legacy này.

### Task 3 — P0: Kết quả kiểm thử phải phản ánh ca thực sự đã chạy

**Files:** `src/Ext/ManagedApplicationModule.bsl:244`, `scripts/run_unit_tests.ps1`, `scripts/test_posting_lifecycle_runtime.py`, `scripts/test_runtime_rbac_real_users.py`, `scripts/test_uat_rollback_concurrency.py`, `scripts/export_operational_evidence.py`, `scripts/test_contract_fees.py`, `tests/unit/*.bsl`, `tests/README.md` (mới).

**Interfaces:** `/C "RunUnitTests;<run_id>;<result_path>"`; JSON hiện tại chứa cùng `run_id`, `status` và `cases[{name,passed,error}]`. Runner chọn file mới riêng mỗi run, kiểm tra exit code 0, đúng danh sách ca đăng ký, Boolean `passed=true`, `error` rỗng và `status=PASS`; số ca được tính từ danh sách đã kiểm chứng.

- [x] Viết self-check Python cho parser kết quả: log cũ, run ID sai, thiếu ca, `[FAIL]` kèm dòng tổng kết thành công, process exit khác 0 đều phải FAIL; suite runner offline kiểm tra kết quả lỗi, timeout và exit code.
- [ ] Xác nhận test đỏ; sửa nhánh `RunUnitTests` đang luôn ghi “tất cả thành công” dù có `[FAIL]`, bỏ hai đường dẫn log hardcoded và `Except` nuốt lỗi. Runner so `total` với danh sách ca được đăng ký trong cùng nhánh, để số ca tự báo không che được ca bị bỏ qua.
- [x] Lập inventory 21 file `tests/unit/*.bsl` + 3 file `tests/migration/*.bsl` = 24 file tham khảo tại [tests/README.md](../../../tests/README.md); SourceBslReference NOT_RUN. Chỉ tính ca đăng ký runtime: unit 2, lifecycle 3, hardening 3 và RBAC 2 mỗi người. Không gọi 24 file này là “24 test đã pass”.
- [x] Hồi quy native same-instance posting: VAT AR/AP RED GL row count 2 thay vì 1; clear owned movement sets ở đầu Posting; lifecycle final3 GREEN 3 ca run `79bb1718fa474687bae86dddca6a7d9f` kiểm POST lần hai trên cùng object, UNPOST/GetObject/REPOST. Baseline trong cùng build, không phải migration parity.
- [x] Netting characterization final3 GREEN đủ 6 ca run `d9332e59d23041a292b76118719a164e`, gồm foreign units và duplicate reversal; không đổi gate hai phiên thật NOT_RUN.
- [ ] Bỏ `kill_1c()` và `Stop-Process` toàn cục khỏi các script runtime; thêm timeout, đường dẫn clone, process handle riêng và kết quả per-run. Chạy một ca PASS, một ca FAIL có chủ đích và một ca timeout để xác nhận script trả mã lỗi đúng. Commit.

### Task 4 — P1: Khóa số dư và chứng minh chống tranh chấp hai phiên

**Files:** `src/Documents/UyNhiemChi/Ext/ObjectModule.bsl:36,281,334`, `src/Documents/DanhGiaLaiNgoaiTe/Ext/ObjectModule.bsl:42,70,149`, `src/Documents/CanTruCongNoNoiBo/Ext/ObjectModule.bsl:165`, `src/CommonModules/QuanLyVongDoiChungTuServer/Ext/Module.bsl:1138`, `scripts/test_uat_rollback_concurrency.py`.

**Interfaces:** Khóa theo cùng bộ chiều số dư mà query dùng, trước khi đọc `Balance`; thời gian chờ/ngoại lệ được trả thành lỗi nghiệp vụ, không tạo thêm movements.

- [ ] Viết test đồng thời với hai tiến trình 1C độc lập dùng cùng hóa đơn/tài khoản: tổng chi/cấn trừ không vượt số dư, đúng một kết quả thành công khi tổng yêu cầu vượt khả năng.
- [ ] Xác nhận test hiện tại không đủ bằng chứng vì `KiemThuUATRollbackConcurrencyServer` chỉ tự lấy khóa trong một transaction; chạy test hai phiên để thu baseline.
- [x] Thêm khóa cho `UyNhiemChi` và `DanhGiaLaiNgoaiTe`, kiểm tra số dư sau khóa; native compile PASS. Payment 4/FX 3 ca PASS tuần tự; bằng chứng hai phiên thật vẫn NOT_RUN.
- [ ] Chạy test hai phiên nhiều lần trên clone và xác nhận GL/subledger không có số dư âm hay bản ghi trùng. Chỉ khi đó mới giữ marker `UAT_DATALOCK_CONCURRENCY_VERIFIED`. Commit.

### Task 5 — P1: Kiểm soát trạng thái, quyền và các cảnh báo tĩnh thật

**Files:** `src/CommonModules/QuanLyVongDoiChungTuServer/Ext/Module.bsl:70`, bảy `src/Documents/*/Ext/ObjectModule.bsl` được nêu trong audit, `src/CommonModules/PhanQuyenBaoMatServer/Ext/Module.bsl`, `scripts/audit_codebase.py`, test `scripts/test_task2_security.py` và test runtime tương ứng.

**Interfaces:** `KiemTraTrangThaiVaQuyen` là kiểm tra chung cho `DataExchange.Load`, maker/checker, trạng thái Posted; chỉ thêm guard tại document khi có đường đi bỏ qua hàm chung. Kết quả audit chia `confirmed`, `false_positive`, `needs_runtime_proof`.

- [x] Hồi quy import ghi thật: StateGuard RED cho Adjustment/Request/Refund, sửa đường đi guard và hardening GREEN 3 ca tại run `274fbb715d394d83a1a3f5fbb26d9f60`.
- [x] Hồi quy Admin tự posting đối soát qua DataExchange.Load: RED run `5e6cad52e30f4d5bae5c6c59060e4089` (`ReconciliationMaker=No`), guard quyền/checker trước import và maker/checker trong Posting; hardening mới nhất GREEN 3 ca run `e6ff5fadff7b4f8e9ce8c277769cc3e8`.
- [x] Rerun RBAC final2 sáu phiên người dùng thật, đủ 12 ca ActualRole/PermissionBoundary PASS; ID tại [báo cáo audit](../../ERP_AUDIT_2026-10-14_FINAL_100.md).

- [ ] Với từng cảnh báo `BeforeWrite`/transaction/`CurrentDate`, ghi call chain và ca test chứng minh tác động; không dùng số đếm token transaction như kết luận về rollback.
- [ ] Viết ca âm tính runtime: sửa trạng thái Posted, maker tự duyệt, DataExchange.Load ghi `DaGhiSo` khi chưa Posted; ca dương tính: import draft hợp lệ.
- [ ] Sửa đúng đường đi còn lọt nếu test đỏ; dùng `CurrentSessionDate()` ở nơi quyết định ngày chứng từ/phiên, để nguyên `CurrentDate()` nếu chỉ ghi log máy chủ và đã được xác nhận là chủ ý.
- [ ] Cập nhật `audit_codebase.py` để không báo lỗi thiếu guard khi document đã gọi hàm chung; báo issue transaction theo từng procedure, không dựa vào tổng số lệnh toàn file. Chạy audit + test runtime; commit.

### Task 6 — P1: Gate build và parity có thể tái lập

**Files:** `scripts/verify_bsl_syntax.py`, `scripts/audit_config_diff.py`, `scripts/update_db.ps1`, `scripts/run_unit_tests.ps1`, `docs/evidence/` (manifest kết quả mới).

**Interfaces:** `verify_bsl_syntax.py` là kiểm tra heuristic phụ; 1C `/CheckConfig` là gate cú pháp chính. Mọi gate ghi thời điểm, Git HEAD, hash source và ID/path clone đã chạy.

- [ ] Viết self-check BOM cho ba BSL đang báo giả và một file có `Procedure` thiếu `EndProcedure`; xác nhận checker cũ báo sai, rồi sửa đọc `utf-8-sig` và trả exit code khác 0 khi có issue.
- [x] Sửa `update_db.ps1` nhận đường dẫn clone bắt buộc, truyền exit code lỗi của `/LoadConfigFromFiles` và `/UpdateDBCfg`; self-check runner kiểm tra dừng sau load failure và update failure.
- [x] Chạy native `/CheckConfig -Config -Server` trên final2: `check.log` và `review-check.log` No errors found; review check sau đăng ký NettingReversal module PASS.
- [x] Final3 native CheckConfig run `e8111bd968cf45e4bad24587d449ad94` PASS; dump cùng ID so bằng `audit_config_diff.py` với src/dump tường minh: 180/180 file, 0 khác biệt, exit 0. Đã kiểm/canonical hóa 3 XML theo native dump; không nới checker. Mapping 641/quyền role gốc giữ nguyên, không migration.
- [ ] Gắn kết quả final3 CheckConfig/parity và hash source/dump vào manifest cuối do main tổng hợp.
- [ ] Tạo manifest kết quả từ lệnh thật, hash source/dump và số lỗi; failure gate phải khiến lệnh tổng trả exit code khác 0. Commit.

### Task 7 — P2: Bảo trì, tài liệu và repo hygiene

**Files:** `.gitignore`, `README.md`, `docs/ERP_AUDIT_2026-10-14_FINAL_100.md`, `docs/DATA_PROVENANCE_LEDGER.md`, các module BSL lớn nếu Task 1–5 cần chỉnh sâu.

**Interfaces:** README chứa một lệnh kiểm tra tĩnh và một lệnh UAT trên clone; báo cáo audit chỉ nêu số liệu có manifest của lần chạy hiện tại.

- [x] `__pycache__/` đã có trong `.gitignore`; không xóa thư mục chưa theo dõi.
- [ ] Chỉ tách `QuanLyVongDoiChungTuServer`, `PhanQuyenBaoMatServer`, `BaoCaoQuanTriServer` theo nhóm hàm đã sửa nếu có test bảo vệ và diff ngắn hơn/dễ review hơn; kích thước file tự nó không phải bug.
- [x] Sửa README/tests README để phân biệt test host, test runtime và 21 unit + 3 migration = 24 file BSL tham khảo; báo cáo audit/provenance ghi khắc phục mới xác minh một phần, data quality FAIL và các gate NOT_RUN/còn mở. Không công bố `100/100`, “Go-Live ready” hay phê duyệt chưa có bằng chứng. Giữ UTF-8.
- [x] Kiểm tra `git diff --check` cho tài liệu và link nội bộ của năm file được giao; kiểm kê thực tế xác nhận 21 unit + 3 migration.
- [ ] Đối chiếu manifest cuối với source/build đã chạy; hoàn tất review và quyết định commit riêng theo chỉ dẫn người dùng.

### Task 8 — Gate nghiệm thu cuối

**Files:** manifest và báo cáo từ Task 6–7; không tạo thêm logic nghiệp vụ.

- [x] Tạo clone mới từ bản backup đã xác minh; xác nhận `Infobase_FullData` và `.dt` phát hành không đổi hash.
- [x] Chạy theo thứ tự: checker BOM → `/CheckConfig` → update clone → dump/diff → seed safety → transaction injection → quyền/FSM → posting/unposting/reposting → hai phiên tranh chấp → đối chiếu GL/subledger.
- [x] Ghi `pass/fail/not_run` từng gate, số bản ghi trước/sau và run ID. Chỉ gọi “đã sửa” với gate PASS; không suy điểm tuyệt đối hay kết luận triển khai production nếu thiếu phê duyệt nghiệp vụ độc lập.
- [x] Review diff, loại thay đổi ngoài scope, rồi bàn giao danh sách rủi ro còn lại và cách khôi phục clone. Commit cuối sau khi tất cả gate bắt buộc PASS.

## Thứ tự và phạm vi dự kiến

Task 1–3 là đường găng, nên làm trước mọi lần seed/UAT. Task 4–6 có thể chia nhánh sau khi Task 3 đã tạo runner tin cậy. Task 7–8 chỉ bắt đầu khi các bài kiểm tra trọng yếu trả kết quả thật. Dự kiến 5–8 ngày kỹ thuật, phụ thuộc thời gian chạy 1C và việc xác nhận nghiệp vụ kế toán; đây là ước lượng, không phải cam kết nghiệm thu.
