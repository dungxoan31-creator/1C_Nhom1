# Inventory kiểm thử

Hiện có 21 file BSL ở unit/ và 3 file ở migration/, tổng 24. Các file này là bộ kịch bản tham khảo, chưa tự đăng ký trong cấu hình runtime. Gate SourceBslReference là NOT_RUN; số file không phải số test đã pass. Khắc phục đã được chấp thuận nhưng mới xác minh một phần, chưa đạt 100/100 hay nghiệm thu go-live.

## Kiểm tra host offline

Từ thư mục gốc workspace:

```text
python -B -m unittest discover -s scripts -p test_audit_tools.py -v
python -B -m unittest discover -s scripts -p test_onec_runtime.py -v
python -B -m unittest discover -s scripts -p test_clone_creation.py -v
```

Chỉ chọn đúng pattern của ba file. Kết quả đo hiện tại: audit 24 OK; runtime 22 OK (1 ca skip vì thiếu quyền symlink); clone creation 14 OK. Bộ test dùng child Python/fixture giả, có kiểm tra timeout và quản lý tiến trình fixture, không chạy engine 1C. Một số script test khác có side effect runtime, nên không chạy discovery không giới hạn trong scripts/.

Concurrent offline 22, self-test 4 và backfill wrapper 3 ca được agent báo PASS, final rerun đang chờ manifest. Backfill wrapper yêu cầu clone tường minh, bỏ global Stop-Process/password và trả unsupported NOT_RUN; test host không chứng minh mutation đã chạy trên engine.

Host hiện tại runtime 22 OK (1 skip), netting offline 3 OK. Tổng dự kiến 101 test = 100 PASS + 1 skip vẫn chờ phần final run còn lại kết thúc; chưa ghi tổng này là kết quả hoàn tất. Final3 source/dump parity đã đo PASS 180/180 file, 0 khác biệt; main đang thu manifest cuối.

## File BSL unit tham khảo (21)

- [AccumulationRegistersTest.bsl](unit/AccumulationRegistersTest.bsl)
- [BaoCaoChuyenSauTest.bsl](unit/BaoCaoChuyenSauTest.bsl)
- [BaoCaoTuoiNoVaSafetyGateTest.bsl](unit/BaoCaoTuoiNoVaSafetyGateTest.bsl)
- [BienBanNghiemThuTest.bsl](unit/BienBanNghiemThuTest.bsl)
- [CatalogsCoreTest.bsl](unit/CatalogsCoreTest.bsl)
- [ChartOfAccountsTest.bsl](unit/ChartOfAccountsTest.bsl)
- [CurrencyEngineTest.bsl](unit/CurrencyEngineTest.bsl)
- [DeNghiThanhToanTest.bsl](unit/DeNghiThanhToanTest.bsl)
- [DoiSoatKenhThanhToanTest.bsl](unit/DoiSoatKenhThanhToanTest.bsl)
- [DongCoDoiSoatTest.bsl](unit/DongCoDoiSoatTest.bsl)
- [EnumsConstantsTest.bsl](unit/EnumsConstantsTest.bsl)
- [HoaDonGTGTDauRaTest.bsl](unit/HoaDonGTGTDauRaTest.bsl)
- [HoaDonNhaCungCapTest.bsl](unit/HoaDonNhaCungCapTest.bsl)
- [InformationRegistersTest.bsl](unit/InformationRegistersTest.bsl)
- [MaTranCanTruNettingTest.bsl](unit/MaTranCanTruNettingTest.bsl)
- [NghiemThuThauPhuTest.bsl](unit/NghiemThuThauPhuTest.bsl)
- [PheDuyetDaCapTest.bsl](unit/PheDuyetDaCapTest.bsl)
- [PhieuThuTienTest.bsl](unit/PhieuThuTienTest.bsl)
- [TranhChapSauGhiSoTest.bsl](unit/TranhChapSauGhiSoTest.bsl)
- [UyNhiemChiStateReversalTest.bsl](unit/UyNhiemChiStateReversalTest.bsl)
- [WorkflowPheDuyetAPTest.bsl](unit/WorkflowPheDuyetAPTest.bsl)

## File BSL migration tham khảo (3)

- [FinancialTaxSignOffTest.bsl](migration/FinancialTaxSignOffTest.bsl)
- [MigrationSoDuDauKyTest.bsl](migration/MigrationSoDuDauKyTest.bsl)
- [UATEndToEndTest.bsl](migration/UATEndToEndTest.bsl)

Tên FinancialTaxSignOffTest không xác nhận một quyết định phê duyệt kế toán hoặc thuế. Muốn chạy những kịch bản này phải tích hợp chúng vào metadata/module và đăng ký ca trong runner, sau đó chứng minh kết quả trên clone.

## Ca runtime được host runner đăng ký

| Command | Số ca cần đủ cho mỗi lần chạy | Tên ca bắt buộc |
| :--- | :---: | :--- |
| RunUnitTests | 2 | SecurityAndSoD, GLSubledger |
| RunPostingLifecycleTests | 3 | ZeroResidual, RepostParity, GLSubledger |
| RunHardeningUAT | 3 | SeedSafety, SeedTransactions, StateGuard |
| RunSecurityTests | 1 | SecurityAndSoD |
| RunRBACChecks | 2 mỗi người dùng | ActualRole, PermissionBoundary |
| VerifyContractFees | 1 | VerifyContractFees |
| VerifyGLAnalyticKeys | 1 | VerifyGLAnalyticKeys |
| ExportTrialBalanceEvidence | 1 | ExportTrialBalanceEvidence |

Đây là hợp đồng EXPECTED_CASES trong [onec_runtime.py](../scripts/onec_runtime.py); bảng kết quả đo bên dưới ghi riêng phạm vi đã chạy. RunUnitTests gọi các module được đăng ký qua ManagedApplicationModule; nó không đọc tests/unit hay tests/migration. Ba command đọc cuối bảng đã được port sang structured result, mỗi command có một ca trùng tên; chúng không còn thuộc nhóm unsupported. Generic runner vẫn từ chối command Seed* cũ bằng NOT_RUN và exit khác 0.

## Kết quả runtime đã đo và giới hạn

| Phạm vi | Kết quả đã ghi nhận | Giới hạn |
| :--- | :--- | :--- |
| SeedSafety | Code cũ FAIL; guard mới PASS với 6 entry point | Chặn seed khi cờ False; không phải nghiệm thu full seed. |
| SeedTransactions | Collision netting cũ rò transaction, FAIL; bản sửa PASS | Transaction đóng và GL giữ nguyên cho collision; biên 49/50/51 chưa chạy. |
| RunHardeningUAT | Final2 mới nhất: SeedSafety, SeedTransactions, StateGuard: 3 ca PASS | Run `e6ff5fadff7b4f8e9ce8c277769cc3e8`; Admin tự posting đối soát qua DataExchange.Load RED → GREEN, bị chặn sau sửa. Guard quyền/checker trước import và maker/checker trong Posting; Adjustment/Request/Refund đã GREEN. Full canary còn mở. |
| Bounded seed dương supplementary UAT | Smoke 10 PASS; bounded full 210 Ref/21 tháng PASS, mỗi run đủ 9 phase gồm restore | Smoke run `6c4a16567cf2411ea3ebbb886b833397`; 210 run `c90fc51b640e45a4b4d4f3e9aa804ae0`, AR 105 + AP 63 + netting 42; 3 maker thật + checker, Admin enable/metadata/restore. Legacy khoảng 4.800+ NOT_RUN. |
| Netting characterization | Final3: 6 ca PASS | Run `d9332e59d23041a292b76118719a164e`: backdated_netting, netting_repost, foreign_units, current_ap_exhausted, current_ar_exhausted, duplicate_reversal. Không chứng minh concurrency. |
| RunRBACChecks | Final2 rerun: 6 người dùng thật, mỗi người 2 ca: tổng 12 PASS | ActualRole và PermissionBoundary; sáu run ID tại [báo cáo hiện tại](../docs/ERP_AUDIT_2026-10-14_FINAL_100.md). |
| RunPostingLifecycleTests | Final3: 3 ca PASS | Run `79bb1718fa474687bae86dddca6a7d9f`, user `ketoan_truong`; POST hiện tại → POST lần hai trên cùng object → UNPOST/GetObject/REPOST trong transaction rollback. Zero residual ở 5 register; không phải legacy-key migration parity. |
| RunUnitTests | Final2 hiện tại: 2 ca PASS | Run `b10d7a97d1fd4a5a9fd2a9afdf733834`; SecurityAndSoD và GLSubledger, không phải 24 file tham khảo. |
| Payment tuần tự | Code cũ cho cả hai payment post và số dư âm, FAIL; bản sửa 4 ca PASS | one_payment, no_overdraw, payment_ledger, loser_rollback. |
| FX tuần tự | 3 ca PASS | revaluation_balances, revaluation_ledger, no_duplicate_fx; baseline mục tiêu độc lập theo nhóm. |
| Hai phiên đồng thời | NOT_RUN | Startup log xác nhận Training Edition giới hạn kết nối; cần nền tảng cho phép hai phiên để chứng minh concurrency. |
| Native CheckConfig / source-dump parity | Final3 PASS | Native run `e8111bd968cf45e4bad24587d449ad94`: No errors found; parity 180 source/180 dump file, 0 khác biệt sau canonical hóa 3 XML đã kiểm theo native dump. |
| VerifyContractFees / ExportTrialBalanceEvidence | Final2: mỗi command 1 ca PASS | Fees mới nhất run `02a645200b6c45ce94294b9e9b7e5631`; export đã ghi ở run riêng. Export thành công không chứng minh data quality hay phê duyệt finance. |
| VerifyGLAnalyticKeys / data quality | FAIL: 8.215/8.579 đủ khóa, thiếu 364 | Gate partner + contract nghiêm ngặt: 360 dòng đối soát 1388 thiếu contract; 4 dòng AR/AP thiếu cả partner và contract. |
| SourceBslReference | NOT_RUN | 21 unit + 3 migration = 24 file BSL tham khảo chưa chạy qua engine. |

Các ca payment/FX dùng [test_concurrent_posting.py](../scripts/test_concurrent_posting.py) với `--sequential`; kết quả ghi `execution = sequential_characterization`. PASS của characterization không được chuyển thành PASS cho hai phiên đồng thời. Manifest cuối do main tổng hợp ghi kết quả chính xác theo từng run/source. Biên 49/50/51, full canary, pilot và phê duyệt finance còn mở. Không tạo contract giả hoặc backfill thiếu khóa ngoại hợp lệ để làm xanh GL.

Lifecycle dùng snapshot canonical của lần POST đầu bằng source/build hiện tại trong transaction, kiểm POST lần hai trên cùng object, tiếp tục UNPOST/GetObject/REPOST rồi rollback. Native RED ở VAT AR/AP cho GL row count 2 thay vì 1; sửa clear movement sets do document sở hữu ở đầu Posting, final3 GREEN. RepostParity so toàn bộ record với baseline hiện tại; không so movements legacy thiếu analytic keys. Phép so legacy → build đã sửa sẽ khác các trường mới, nên PASS không xác nhận migration/backfill hay legacy-key parity.

Các sửa này giữ mapping 641 và quyền role gốc; không có migration tài khoản/quyền. Parity trước canonical hóa có đúng 3 XML khác biểu diễn (newline/BOM, namespace, indentation); source đã đưa về biểu diễn native dump đã kiểm, không nới checker để bỏ qua khác biệt.

Bounded seed dùng [seed_workflow.py](../scripts/seed_workflow.py), với kết quả mỗi phase và manifest Ref riêng, không qua bảng EXPECTED_CASES của generic runner. Trước GREEN: run `15809b62f5ad431a93918fc651d08279` FAIL acceptance debit 1312 thiếu analytic keys; run `645a1bc57b7e47ce84591bdfc8b23ca3` FAIL thiếu `LaySoDuARTheoChungTu`; run `03ed208743344c7e91c1f38ca50adb78` check-ar/check-ap PASS nhưng check-netting FAIL contract credit 1388. Source đã sửa keys bằng trường chứng từ hợp lệ, thêm helper số dư AR hiện tại có khóa và loại movements của chính recorder khi repost, ghi GL đối soát theo partner/contract từng dòng. GREEN kiểm chứng positive UAT sample 10/210 Ref mới; data quality lịch sử vẫn FAIL.

[Wrapper full](../scripts/run_seed_full_data.ps1) yêu cầu `-BoundedWorkflow`; thêm `-Smoke` chọn mẫu 10 chứng từ, bỏ để chọn bounded 210/21 tháng đã PASS. [Wrapper massive](../scripts/run_seed_massive_data.ps1) yêu cầu `-MetadataOnly` và chỉ chuẩn bị metadata. Bulk generator gốc vẫn được giữ có guard; legacy full-volume và tiêm lỗi biên 49/50/51 vẫn NOT_RUN. Lệnh trên clone ở [README](../README.md#seed-dương-bổ-sung-trên-clone).

Mỗi lần chạy sử dụng /C "command;run_id;result_path". JSON mới cần đúng schema:

```json
{
  "run_id": "<ID-created-by-runner>",
  "status": "PASS",
  "cases": [
    {"name": "SecurityAndSoD", "passed": true, "error": ""},
    {"name": "GLSubledger", "passed": true, "error": ""}
  ]
}
```

Ví dụ schema trên dành cho RunUnitTests, không phải evidence đã chạy. Runner yêu cầu file mới trong results/ của clone, đúng run ID, không thiếu/thừa/trùng ca, Boolean passed thật, error rỗng, tổng status PASS và process exit 0. Một dòng ALL TESTS PASS, marker cũ hay một subprocess exit 0 không đủ; timeout hoặc ca lỗi phải fail.

## Chuẩn bị và ghi nhận runtime

Xem [README](../README.md) và [create_uat_clone.py](../scripts/create_uat_clone.py) để tạo clone trống mới, restore `.dt` chỉ vào clone đó và tự ghi marker `.uat-clone.json` với `ib_path` canonical và `source_sha256`. Helper từ chối thư mục run đã tồn tại. Chỉ dùng đường dẫn tuyệt đối trong workspace `scratch/uat/<runid>/ib`; cập nhật src và chạy Designer /CheckConfig trước khi thu bằng chứng.

```text
python -B scripts/onec_runtime.py RunHardeningUAT --ib-path "<absolute-workspace>/scratch/uat/<runid>/ib" --user Admin
```

Các ca này có ghi dữ liệu và cần clone riêng. Kết quả cuối do người chạy tổng hợp tại `docs/evidence/hardening_verification.json`; xem [tiến độ](../docs/superpowers/reports/2026-10-14-hardening-progress.md). Không suy kết quả runtime từ test offline. Two-session concurrency vẫn NOT_RUN; kiểm kê canary và đối chiếu ledger cuối phải giữ phạm vi bằng chứng riêng ngoài số ca tổng hợp.

Lifecycle dùng `python -B scripts/test_posting_lifecycle_runtime.py --ib-path "<absolute-workspace>/scratch/uat/<runid>/ib" --user ketoan_truong`; CLI hiện mặc định checker cho lifecycle. Admin bị từ chối duyệt đúng chính sách; không coi đó là lỗi quyền cần mở rộng. Genuine two-session trên final3 cùng source được lên kế hoạch rerun; trạng thái giữ NOT_RUN tới khi có bằng chứng mới.
