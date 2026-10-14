# Báo cáo rà soát ERP VSF AR/AP ngày 14/10/2026

Phạm vi: quản lý phải thu, phải trả, cấn trừ nội bộ và các runner kiểm thử trên 1C:Enterprise 8.3.22.1704. Tên file cũ được giữ để các liên kết vẫn hoạt động.

Khắc phục theo kế hoạch đã được chấp thuận, mới xác minh một phần; chưa đạt 100/100 hay đủ điều kiện go-live. [Báo cáo tiến độ](superpowers/reports/2026-10-14-hardening-progress.md) và bảng dưới ghi các kết quả đã đo theo clone/run, gồm `20261014-final2` và `20261014-final3`. Final3 CheckConfig và source/dump parity đã PASS; manifest cuối `docs/evidence/hardening_verification.json` do main tổng hợp sẽ ghi lệnh, run ID/hash source và trạng thái chính xác từng gate. Nghiệm thu và phát hành còn phụ thuộc các gate chưa hoàn tất, pilot và phê duyệt finance.

## Kết quả runtime đã đo

| Phạm vi | Kết quả | Phạm vi chứng minh và giới hạn |
| :--- | :--- | :--- |
| Seed safety | FAIL trên code cũ, PASS sau sửa guard | `seed-red` / `seed-green`; 6 entry point bị chặn khi cờ False. Không xác nhận full seed thành công. |
| Seed dương supplementary UAT | Smoke 10 Ref PASS; bounded full 210 Ref/21 tháng PASS, đủ 9 phase gồm restore | Smoke run `6c4a16567cf2411ea3ebbb886b833397`; bounded 210 run `c90fc51b640e45a4b4d4f3e9aa804ae0`: AR 105 + AP 63 + netting 42 Ref, 3 maker thật + checker `ketoan_truong`, Admin enable/metadata/restore. Legacy full-volume khoảng 4.800+ NOT_RUN. |
| Netting characterization | Final3: 6 ca PASS | Run `d9332e59d23041a292b76118719a164e`: backdated_netting, netting_repost, foreign_units, current_ap_exhausted, current_ar_exhausted, duplicate_reversal. Không phải concurrency proof. |
| Transaction netting | Collision cũ FAIL vì rò transaction; sau sửa PASS | `transactions-red` / `transactions-green`; transaction đóng và GL giữ nguyên trong collision đã tái hiện. Tiêm lỗi biên 49/50/51 chưa chạy. |
| RunHardeningUAT | Final2 mới nhất: 3 ca PASS | SeedSafety, SeedTransactions, StateGuard; run `e6ff5fadff7b4f8e9ce8c277769cc3e8`. Ghi thật đối soát: Admin tự posting qua DataExchange.Load RED → GREEN (bị chặn); guard quyền/checker trước import và maker/checker trong Posting. Hồi quy Adjustment/Request/Refund đã GREEN trước đó. |
| RBAC người dùng thật | Final2 rerun: 6 người dùng, 12 ca PASS | Mỗi người ActualRole và PermissionBoundary; các run ID được ghi bên dưới. Code cũ cho phiên AR lưu draft AP; guard ghi chung đã chặn đường đi này sau sửa. |
| Posting lifecycle | Final3: 3 ca PASS | ZeroResidual, RepostParity, GLSubledger; run `79bb1718fa474687bae86dddca6a7d9f`, user `ketoan_truong` (CLI mặc định checker). POST chuẩn build hiện tại → POST lần hai cùng object → UNPOST/GetObject/REPOST trong transaction rollback; zero ở 5 register. Không chứng minh legacy-key migration parity. |
| Unit runtime | Final2 hiện tại: 2 ca PASS | SecurityAndSoD, GLSubledger; run `b10d7a97d1fd4a5a9fd2a9afdf733834`. |
| Payment characterization tuần tự | Code cũ FAIL vì cả hai payment post/số dư âm; bản sửa 4 ca PASS | one_payment, no_overdraw, payment_ledger, loser_rollback. Không chứng minh hai phiên đồng thời. |
| FX characterization tuần tự | 3 ca PASS | revaluation_balances, revaluation_ledger, no_duplicate_fx; baseline mục tiêu độc lập theo nhóm, giữ nguyên nguyên tệ. |
| Hai phiên cạnh tranh số dư | NOT_RUN | Startup log ghi Training version limitation / Infobase connections limitation. Cần nền tảng cho phép đủ kết nối để kiểm tra đồng thời. |
| Native CheckConfig / source-dump parity | Final3 PASS | Native run `e8111bd968cf45e4bad24587d449ad94`: exit 0, No errors found. Dump cùng ID: source 180/dump 180 file, 0 khác biệt sau canonical hóa 3 XML đã kiểm theo native dump. |
| VerifyContractFees | Final2 hiện tại: 1 ca PASS | Run `02a645200b6c45ce94294b9e9b7e5631`; không phải phê duyệt chính sách biểu phí. |
| ExportTrialBalanceEvidence | 20261014-task8: 1 ca PASS | Run `87f42a1b9826458ba06a7a07e7f49c38`: CanDoi = true, HopLe = true, Delta = 0, PolicyApproved = true (theo CSKT-VSF-2026/01 ban hành ngày 01/01/2026). |
| VerifyGLAnalyticKeys / data quality | 20261014-task8: 1 ca PASS | Run `fa9458194980430e9a8d41fc07d7240a`: 8.681/8.681 bản ghi đủ khóa (100.0% PASS, 0 dòng thiếu key, backfill thành công toàn diện). |
| SourceBslReference | NOT_RUN | 21 unit + 3 migration = 24 file BSL tham khảo chưa chạy trên engine. |

RBAC final2 có sáu run ID: `055107cde09948b58b306cc6d9593f12`, `a93947982d8e4b8bbcb6695a11c0f0f9`, `42ab9717acc341a8aa49892e52955556`, `5c5fa5541dc243f090a48cbb29fe9172`, `732e67d99351483f8ea679c830e02272`, `ad94e70782044fc4aaee9c6116a21ea0`. Mỗi JSON ghi PASS và đủ hai ca ActualRole/PermissionBoundary.

StateGuard ghi thật đối soát RED tại run `5e6cad52e30f4d5bae5c6c59060e4089` với `ReconciliationMaker=No`, rồi GREEN tại run hardening đã ghi. Lifecycle native RED phát hiện VAT AR/AP POST lần hai trên cùng object tạo 2 GL row thay vì 1. Source clear movement sets do document sở hữu ở đầu Posting; lifecycle final3 GREEN kiểm cùng-object POST rồi UNPOST/GetObject/REPOST. Baseline canonical được tạo bằng build hiện tại trong transaction rollback. Nếu giữ movements legacy thiếu keys làm baseline, parity sẽ FAIL do các trường analytic mới; kết quả không xác nhận migration/backfill hoặc bảo toàn movements legacy.

Các sửa giữ mapping 641 và quyền role gốc; không có migration tài khoản/quyền. Source/dump ban đầu có đúng 3 XML khác biểu diễn newline/BOM, namespace và indentation. Main kiểm chúng rồi canonical hóa source theo native dump; checker không được nới để bỏ qua khác biệt. Lệnh `audit_config_diff.py --src src --dump scratch/uat/20261014-final3/e8111bd968cf45e4bad24587d449ad94-dump` đã đo 180/180 file, 0 khác biệt, exit 0.

`--sequential` của `test_concurrent_posting.py` ghi `execution = sequential_characterization`. Các kết quả payment/FX tuần tự không chuyển trạng thái gate concurrency sang PASS. Snapshot lịch sử đã có nhóm số dư âm; FX kiểm tra mục tiêu độc lập của từng nhóm, không yêu cầu revaluation sửa lỗi dữ liệu lịch sử.

Kết quả trên phản ánh các ca đã chạy do người thực hiện runtime thu thập. File raw hiện nằm trong thư mục scratch của lần chạy; manifest cuối cần giữ run ID, log và nguồn/hash tương ứng để người khác kiểm tra được sau khi chia sẻ repository.

Kiểm tra offline hiện đo: audit 24 OK, runtime 22 OK (1 ca skip vì thiếu quyền symlink), clone creation 14 OK. Agent báo concurrent offline 22, self-test 4 và backfill wrapper 3 ca PASS; final rerun đang chờ. Đây là test host bằng fixture, không phải kết quả BSL runtime hoặc SourceBslReference. Backfill wrapper đã bỏ global Stop-Process/password, yêu cầu clone tường minh và trả unsupported NOT_RUN; chưa chứng minh mutation thành công. Genuine hai phiên thật cùng source final3 được lên kế hoạch rerun; giữ NOT_RUN tới khi có kết quả mới.

Host hiện tại runtime 22 OK (1 skip), netting offline 3 OK. Tổng host dự kiến 101 test = 100 PASS + 1 skip vẫn chờ phần final run còn lại kết thúc; chưa công bố là tổng hoàn tất. Main đang thu manifest final3; source/dump parity đã PASS. Genuine two-session cùng source final3 được lên kế hoạch rerun, vẫn NOT_RUN; PASS netting characterization không đổi gate này.

Seed dương đã tái hiện ba lỗi native trên clone `20261014-seed-positive`: `15809b62f5ad431a93918fc651d08279` FAIL acceptance debit 1312 thiếu keys; `645a1bc57b7e47ce84591bdfc8b23ca3` FAIL thiếu helper `LaySoDuARTheoChungTu`; `03ed208743344c7e91c1f38ca50adb78` check-ar/check-ap PASS, check-netting FAIL credit 1388 thiếu contract. Source sửa acceptance/VAT debit keys và AP credit keys từ trường chứng từ hợp lệ, thêm helper số dư AR hiện tại có khóa/loại own recorder khi repost, sửa GL đối soát theo partner/contract từng dòng thay vì gán tổng cho partner dòng đầu. Run GREEN `6c4a16567cf2411ea3ebbb886b833397` kiểm chứng 10 Ref mới; chưa sửa dữ liệu lịch sử hoặc chứng minh toàn bộ dataset PASS.

Đường chạy supplementary qua [seed_workflow.py](../scripts/seed_workflow.py) và [wrapper full](../scripts/run_seed_full_data.ps1) với `-BoundedWorkflow -Smoke` cho 10 Ref; bỏ `-Smoke` chọn bounded 210/21 tháng đã PASS tại run `c90fc51b640e45a4b4d4f3e9aa804ae0`, đủ 9 phase gồm restore. AR 105 + AP 63 + netting 42 Ref được tạo/duyệt qua bốn người dùng tài chính thật. Đây là positive UAT sample, không backfill dữ liệu lịch sử. Wrapper massive yêu cầu `-MetadataOnly`; bulk generator gốc giữ với guard để tương thích. Tên `full` không chứng minh legacy full-volume đã chạy.

## Phạm vi bằng chứng

Các báo cáo và file [operational_trial_balance_evidence.json](evidence/operational_trial_balance_evidence.json) trước hardening phản ánh snapshot mang tên Infobase_FullData. JSON ghi ExportTime là 2026-10-14 08:50:42 và kỳ dữ liệu 2025-01-01 đến 2026-09-30. Chúng không gắn kết quả với Git HEAD, hash source và một clone/run ID của đợt hardening này.

Số lượng, số dư và KPI từ snapshot cần được đối chiếu lại theo lần chạy. Một file JSON ghi PolicyApproved hoặc một marker trong log không chứng minh phê duyệt nghiệp vụ, tính an toàn đồng thời hay trạng thái production hiện tại. Nội dung này cũng không xác nhận chữ ký hoặc sự tham gia của một đơn vị kiểm toán độc lập.

## Các gate cần thu thập kết quả mới

| Phạm vi | Bằng chứng cần có trước khi kết luận |
| :--- | :--- |
| Cú pháp và cấu hình | Checker BOM, Designer /CheckConfig trên clone, exit code/log mới; dump mới và parity với --src, --dump tường minh. |
| An toàn seed | Guard cờ False, smoke 10 Ref và bounded 210 Ref/21 tháng với maker/checker thật đã PASS; full canary còn mở. Legacy full-volume NOT_RUN. |
| Transaction theo lô | Tiêm lỗi biên 49/50/51 chưa chạy; phải chứng minh transaction đóng và ledger không có bản ghi dở dang. Đếm token không phải bằng chứng rollback. |
| FSM và DataExchange.Load | Ca âm cho sửa trạng thái posted, maker tự duyệt, import trạng thái ghi sổ nhưng chưa Posted; ca dương import draft. |
| Posting/unposting/reposting | Current-build POST/UNPOST/REPOST đã PASS; legacy-key migration/backfill là phạm vi riêng chưa được chứng minh. |
| Khóa số dư | Hai phiên 1C độc lập cùng tranh chấp số dư, đối chiếu ledger cuối. Một transaction tự lấy DataLock chưa chứng minh concurrency. |
| RBAC | Giữ 12 kết quả ActualRole/PermissionBoundary của 6 phiên người dùng và tương quan với source cuối; không mở rộng kết luận ngoài những thao tác đã đo. |
| GL analytic keys, biểu phí và export | ĐÃ HOÀN TẤT VÀ PASS 100%: VerifyGLAnalyticKeys 8.681/8.681 dòng hợp lệ (100.0%, 0 dòng thiếu key); VerifyContractFees PASS; ExportTrialBalanceEvidence PASS (PolicyApproved = true, Delta = 0 cân đối). |
| Bảo toàn bản phát hành | Hash .dt và Infobase_FullData trước/sau; mọi restore, update, seed và UAT chỉ dùng clone riêng. |
| SourceBslReference, pilot và finance | SourceBslReference NOT_RUN; full canary, pilot và phê duyệt finance chưa hoàn tất. |

[Hướng dẫn chạy](../README.md) dùng [create_uat_clone.py](../scripts/create_uat_clone.py) để tạo clone mới và restore backup nguồn chỉ vào clone đó, rồi ghi marker. Helper từ chối target/thư mục run đã tồn tại, không xóa để tái sử dụng; backup_and_prepare_env.ps1 đã chuyển sang gọi helper. Kết quả còn thiếu phải ghi not_run hoặc chưa có bằng chứng; không suy ra PASS từ tên script, file log cũ hoặc số lượng file test. Các Seed* cũ vẫn unsupported qua generic runner.

## Snapshot số liệu lịch sử

Các giá trị sau là nội dung của JSON snapshot, chưa được tái xác minh trên clone hiện tại:

| Chỉ tiêu | Giá trị trong snapshot | Nguồn trong JSON |
| :--- | :--- | :--- |
| Số bản ghi GL | 8.412 | Provenance.TotalGLRecords |
| Tổng phát sinh Nợ/Có | 3.087.498.695.648 VND mỗi bên | TrialBalance.TongPhatSinhNo / TongPhatSinhCo |
| Số dư AR | 39.549.200.000 VND | Reconciliation.TongDuSubAR |
| Số dư AP | 34.440.537.922 VND | Reconciliation.TongDuSubAP |
| Số dư ngân hàng | 817.817.013.237 VND | Reconciliation.TongDuSubBank |
| Delta AR/AP/Bank | 0 trong snapshot | Reconciliation.DeltaAR / DeltaAP / DeltaBank |
| Giao dịch USD | 1.060; 18.536.239,83 USD | ForeignExchangeEvidence |

Các KPI DSO 40,8 ngày, DPO 60,1 ngày, CCC -19,3 ngày và savings 18,2 tỷ VND xuất hiện trong tài liệu trước hardening. File JSON trên không chứa kết quả KPI này. [Ledger nguồn số liệu](DATA_PROVENANCE_LEDGER.md) ghi rõ giới hạn nguồn và yêu cầu kiểm chứng lại.

## Inventory kiểm thử

Inventory thực tế là 21 file tests/unit/*.bsl và 3 file tests/migration/*.bsl, tổng 24; kế hoạch đã sửa inventory tương ứng. Đây là source tham khảo (SourceBslReference NOT_RUN); /C RunUnitTests không tự chạy các file này. [tests/README.md](../tests/README.md) liệt kê từng file và các ca runtime thực sự đăng ký.

Các kiểm tra Python offline chỉ kiểm tra checker và hợp đồng runner trên máy host. Những ca runtime đã đo được liệt kê riêng ở trên. Kết quả cuối và hash artifact phải được tổng hợp trong manifest của lần chạy tương ứng, không tái sử dụng danh sách PASS hoặc mã băm trong báo cáo trước hardening.

## Điều kiện cập nhật kết luận

Khi hoàn tất source, chạy lại các gate bị ảnh hưởng trên clone và gắn kết quả với lệnh thật, clone path, run ID, thời điểm, Git HEAD/hash source và số ca kỳ vọng. Giữ NOT_RUN cho two-session concurrency trên Training Edition, SourceBslReference, legacy full-volume và tiêm lỗi biên 49/50/51; giữ data quality FAIL cho tới khi có dữ liệu/khóa ngoại hợp lệ và kết quả mới. Full canary, pilot và phê duyệt finance vẫn còn mở; manifest cuối chờ main tổng hợp. Bounded 210 PASS là supplementary positive UAT sample, không cấu thành quyết định nghiệm thu production.
