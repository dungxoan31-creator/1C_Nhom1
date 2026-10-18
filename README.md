# VinSmart Future: Quản lý công nợ AR/AP trên 1C:Enterprise 8.3

Cấu hình 1C quản lý phải thu, phải trả, cấn trừ nội bộ và báo cáo tài chính. Khắc phục theo kế hoạch đã được chấp thuận, mới xác minh một phần; chưa đạt 100/100 hay đủ điều kiện go-live. [Báo cáo tiến độ hardening](docs/superpowers/reports/2026-10-14-hardening-progress.md) và [phạm vi kết quả](docs/ERP_AUDIT_2026-10-14_FINAL_100.md) ghi CheckConfig trên clone `20261014-final2`, hardening 3 ca, unit 2 ca, lifecycle 3 ca và RBAC rerun 6 người dùng/12 ca PASS. Payment 4 ca và FX 3 ca PASS tuần tự, chưa chứng minh concurrency. Hai phiên thật vẫn NOT_RUN do giới hạn kết nối Training Edition. GL analytic keys hiện FAIL: 8.215/8.579 bản ghi đủ khóa, 364 bản ghi thiếu theo gate partner + contract nghiêm ngặt. Manifest cuối `docs/evidence/hardening_verification.json` do người chạy tổng hợp sẽ ghi kết quả chính xác theo từng run/source.

## 📌 Hướng dẫn Demo & Thuyết trình (Mới nhất)

- 🌟 **[Kịch bản demo chi tiết từng thao tác, nút bấm, nhập liệu](docs/08_KICH_BAN_DEMO_CHI_TIET_THAO_TAC_NUT_BAM.md)**: Hướng dẫn thực chiến chi tiết từng cú click chuột, phím tắt, từng ô nhập liệu, ca test biên và lời thoại thuyết trình trước Hội đồng.
- 🎯 **[Kịch bản demo 5 phút & Bản đặc tả nghiệp vụ AR/AP](docs/07_KICH_BAN_DEMO_5_PHUT.md)**: Sơ đồ nghiệp vụ Mermaid và câu trả lời chuẩn phản biện về thuế FCT.
- 📖 **[Hướng dẫn nạp và sử dụng file .DT](HUONG_DAN_SU_DUNG_FILE_DT.md)**: Cách nạp Infobase và danh mục dữ liệu mẫu 43 chứng từ đã ghi sổ.

## Cấu trúc dự án

| Đường dẫn | Nội dung |
| :--- | :--- |
| [docs/08_KICH_BAN_DEMO_CHI_TIET_THAO_TAC_NUT_BAM.md](docs/08_KICH_BAN_DEMO_CHI_TIET_THAO_TAC_NUT_BAM.md) | **Kịch bản demo thực chiến chi tiết từng thao tác nút bấm.** |
| [src/](src/) | Metadata XML và mã BSL của cấu hình. |
| [scripts/](scripts/) | Checker, runner Python và wrapper PowerShell. |
| [tests/README.md](tests/README.md) | Inventory 21 file unit + 3 file migration BSL, tổng 24 file tham khảo; hợp đồng runtime riêng. |
| [docs/](docs/) | Đặc tả, kế hoạch, báo cáo và bằng chứng. |
| [Lessons/](Lessons/) và [Bài thực hành/](Bài%20thực%20hành/) | Tài liệu đào tạo 1C. |
| [1C-Mentor-Skill-Gemini/](1C-Mentor-Skill-Gemini/) | Tài nguyên hướng dẫn lập trình. |
| [VinSmart_Future_AR_AP_Full.dt](VinSmart_Future_AR_AP_Full.dt) | Gói CSDL chuẩn duy nhất (Full standalone package) chứa toàn bộ cấu hình 1C và dữ liệu giao dịch 100% kiểm toán. |

## Kiểm tra offline

Chạy từ thư mục gốc workspace, dùng Python stdlib, không cần pytest:

```text
python -B -m unittest discover -s scripts -p test_audit_tools.py -v
python -B -m unittest discover -s scripts -p test_onec_runtime.py -v
python -B -m unittest discover -s scripts -p test_clone_creation.py -v
python -B scripts/verify_bsl_syntax.py
```

Ba lệnh unittest chỉ chọn đúng file được nêu. Kết quả offline hiện đo: audit 24 OK, runtime 22 OK (1 ca skip vì thiếu quyền symlink), clone creation 14 OK. Các test này dùng fixture/tiến trình giả lập, không chạy engine 1C. Không dùng blanket discovery cho toàn bộ scripts: một số test cũ có thể khởi động 1C hoặc thao tác dữ liệu. Kiểm tra token BSL là heuristic phụ; Designer /CheckConfig là gate cú pháp chính.

## Tạo clone UAT

[create_uat_clone.py](scripts/create_uat_clone.py) tạo infobase trống và restore `.dt` vào thư mục UAT mới. Chạy từ gốc workspace:

```text
python -B scripts/create_uat_clone.py --source-dt "<absolute-path>/VinSmart_Future_AR_AP_Full.dt" --run-id "<new-runid>"
```

Thay placeholder bằng giá trị thực tế. Nếu bỏ `--run-id`, helper dùng UUID mới. Có thể chỉ định `--target-path "<absolute-workspace>/scratch/uat/<runid>/ib"`; helper từ chối cả target lẫn thư mục run đã tồn tại, không xóa để tái sử dụng. Nó đọc/hash backup nguồn, tạo clone bằng `CREATEINFOBASE`, restore bằng `/RestoreIB`, kiểm tra database độc lập và hash nguồn không đổi, rồi ghi marker. Lỗi giữ lại thư mục/log để xem xét; lần thử sau dùng run ID mới. JSON trả về chứa `ib_path` dùng cho các lệnh tiếp theo. Wrapper [backup_and_prepare_env.ps1](scripts/backup_and_prepare_env.ps1) hiện gọi helper này với `-SourceDT`, không xóa `Infobase_FullData`.

Nếu cần tạo clone qua giao diện, người vận hành thực hiện các bước sau và tự ghi marker:

1. Chọn một runid mới và đường dẫn tuyệt đối, chuẩn hóa, cục bộ trong workspace: `scratch/uat/<runid>/ib`. Thay mọi placeholder trong các ví dụ bằng đường dẫn thực tế; trên Windows có thể dùng `C:/path/to/workspace/scratch/uat/<runid>/ib`.
2. Trong trình khởi động 1C, tạo một infobase trống, không có cấu hình, tại đúng thư mục ib mới đó.
3. Mở Designer của infobase trống vừa tạo, chọn Administration > Restore infobase và nạp file .dt đã xác minh. Chỉ restore vào clone mới này. Giữ nguyên Infobase, Infobase_FullData và các file .dt phát hành.
4. Tính SHA-256 của backup nguồn, ghi nhận nguồn và thời điểm restore, rồi tạo marker `scratch/uat/<runid>/.uat-clone.json` cạnh thư mục ib.

Ví dụ đọc hash backup từ gốc workspace:

```text
python -B -c "import hashlib; from pathlib import Path; print(hashlib.sha256(Path('VinSmart_Future_AR_AP_Full.dt').read_bytes()).hexdigest())"
```

Helper tự ghi marker sau restore thành công. Clone tạo thủ công cần hai trường sau; thay các giá trị minh họa bằng đường dẫn canonical thực tế và hash gồm đúng 64 ký tự hex:

```json
{
  "ib_path": "<absolute-workspace>/scratch/uat/<runid>/ib",
  "source_sha256": "<64-hex-SHA-256-of-source-dt>"
}
```

`onec_runtime.py` từ chối đường dẫn tương đối, UNC/server connection, đường dẫn ngoài workspace hoặc sai cấu trúc `scratch/uat/<runid>/ib`, đường dẫn có symlink/junction, và mọi thành phần tên `Infobase` hay `Infobase_FullData`. Marker phải gắn đúng đường dẫn canonical; `1Cv8.1CD` phải là file độc lập, không phải link/hardlink chia sẻ. `source_sha256` là provenance do người tạo clone cung cấp; runner không tự xác minh hash backup gốc từ database đã thay đổi.

## Nạp cấu hình và chạy runtime trên clone

Cài 1C trên máy chạy. Dùng --exe-path để chỉ rõ executable, hoặc ONEC_EXE_PATH; mặc định runner tìm 1cv8t phiên bản 8.3.22.1704 trong Program Files (x86). Thông tin tài khoản snapshot tham khảo tại [hướng dẫn file .dt](HUONG_DAN_SU_DUNG_FILE_DT.md).

Sau khi marker hợp lệ, nạp src hiện tại và cập nhật clone:

```text
python -B scripts/onec_runtime.py update-db --ib-path "<absolute-workspace>/scratch/uat/<runid>/ib" --source-path "<absolute-workspace>/src" --user Admin
```

Runner dừng nếu LoadConfigFromFiles hoặc UpdateDBCfg lỗi. --password chỉ hỗ trợ Designer update-db. Người chạy phải thu thập kết quả Designer /CheckConfig -Config -Server, rồi dump cấu hình vào thư mục mới của lần chạy và đối chiếu với cả hai đường dẫn tường minh:

```text
python -B scripts/audit_config_diff.py --src "<absolute-workspace>/src" --dump "<absolute-workspace>/scratch/uat/<runid>/dump"
```

Giữ constant ChoPhepSinhDuLieuMau = False cho ca seed safety; chỉ bật trong clone khi kịch bản đã xác định yêu cầu đó. Các ca UAT có ghi dữ liệu, nên dùng clone riêng cho mỗi lần chạy.

```text
python -B scripts/onec_runtime.py RunHardeningUAT --ib-path "<absolute-workspace>/scratch/uat/<runid>/ib" --user Admin
```

Clone final2 có hardening mới nhất 3 ca PASS tại run `e6ff5fadff7b4f8e9ce8c277769cc3e8`, gồm hồi quy ghi thật đối soát: Admin tự ghi sổ qua DataExchange.Load từ RED sang GREEN (bị chặn). Guard quyền/checker chung chạy trước nhánh import; Posting cũng kiểm maker/checker. Hồi quy Adjustment/Request/Refund đã GREEN trước đó. Unit hiện tại 2 ca PASS run `b10d7a97d1fd4a5a9fd2a9afdf733834`; biểu phí PASS run `02a645200b6c45ce94294b9e9b7e5631`. Mọi thay đổi source sau lần chạy vẫn cần rerun tương ứng. Runner truyền `/C "command;run_id;result_path"`, tạo JSON riêng dưới `scratch/uat/<runid>/results` và yêu cầu đúng run_id, file mới, đủ tên ca, passed là Boolean true, error rỗng, status PASS và process exit 0. Log chứa PASS hoặc exit 0 đơn lẻ không đủ. Command chưa có hợp đồng structured result trả NOT_RUN, exit khác 0; lỗi hoặc timeout trả FAIL.

RunUnitTests hiện đăng ký đúng 2 ca SecurityAndSoD và GLSubledger. Nó không tự nạp/chạy 24 file BSL trong tests. Xem [inventory và danh sách ca runtime](tests/README.md).

Lifecycle phải chạy với checker `ketoan_truong` (CLI hiện mặc định checker); final3 run `79bb1718fa474687bae86dddca6a7d9f` PASS 3 ca. Native RED phát hiện VAT AR/AP posting lần hai trên cùng object tạo 2 GL row thay vì 1; source xóa movement sets do chứng từ sở hữu ở đầu Posting để xây lại. Test tạo baseline POST bằng build hiện tại, POST lần hai trên cùng object, rồi UNPOST/GetObject/REPOST trong transaction rollback. Đây là parity trong cùng build, không chứng minh legacy-key migration parity; movements legacy khác vì fields analytic mới. Admin bị từ chối duyệt đúng chính sách:

```text
python -B scripts/test_posting_lifecycle_runtime.py --ib-path "<absolute-workspace>/scratch/uat/<runid>/ib" --user ketoan_truong
```

Ba wrapper đọc đã có hợp đồng structured result: `test_contract_fees.py` chạy `VerifyContractFees`, `verify_gl_analytic_keys.py` chạy `VerifyGLAnalyticKeys`, và `export_operational_evidence.py` chạy `ExportTrialBalanceEvidence`. Mỗi command có đúng một ca mang cùng tên command; truyền `--ib-path` như trên. Final2 ghi VerifyContractFees và ExportTrialBalanceEvidence PASS, VerifyGLAnalyticKeys FAIL. Export ghi thêm `<result_path>.evidence.json` cho chính lần chạy đó; export PASS không chứng minh data quality PASS. Các wrapper này không cập nhật phí hoặc backfill. Seed command cũ qua generic runner vẫn NOT_RUN; đường seed dương bổ sung dùng [seed_workflow.py](scripts/seed_workflow.py) riêng.

## Seed dương bổ sung trên clone

Bounded `full --smoke` GREEN tại run `6c4a16567cf2411ea3ebbb886b833397`: 9 phase PASS, đúng 10 Ref tài chính riêng biệt, kiểm tra GL keys mới PASS. Bounded full 210 Ref/21 tháng cũng native PASS tại run `c90fc51b640e45a4b4d4f3e9aa804ae0`: AR 105 + AP 63 + netting 42, đủ 9 phase gồm restore. Các maker là `ketoan_ar`, `ketoan_ap`, `chuyenvien_doisoat`; `ketoan_truong` duyệt/post, Admin chuẩn bị metadata và enable/restore cờ seed. Đây là supplementary positive UAT sample; bỏ `-Smoke` trong lệnh dưới để chọn bounded 210 đã xác minh. Legacy full-volume khoảng 4.800+ chứng từ và tiêm lỗi biên 49/50/51 vẫn NOT_RUN; bulk generator gốc giữ với guard để tương thích.

Các wrapper AR, AP, netting và full yêu cầu cờ `-BoundedWorkflow` tường minh để chọn supplementary UAT, không thay thế khối lượng legacy. Chạy smoke trên clone riêng:

```text
powershell -NoProfile -File scripts/run_seed_full_data.ps1 -IBPath "<absolute-workspace>/scratch/uat/<runid>/ib" -User Admin -BoundedWorkflow -Smoke
```

Wrapper massive yêu cầu `-MetadataOnly`, chỉ chuẩn bị metadata bằng Admin. Khi thiếu cờ lựa chọn tương ứng, cả năm wrapper gọi `onec_runtime.py` với command seed legacy: helper xác minh clone trước, trả `FAIL` cho đường dẫn không an toàn và `NOT_RUN` cho clone hợp lệ, không khởi động 1C. Stdout chỉ có JSON kết quả từ helper. Xem [wrapper full](scripts/run_seed_full_data.ps1) và [wrapper massive](scripts/run_seed_massive_data.ps1). Tên `full` của bounded workflow không xác nhận legacy full-volume đã chạy. Manifest final3 do main tổng hợp còn chờ.

`test_concurrent_posting.py --sequential` chạy characterization theo thứ tự, không chứng minh hai phiên tranh chấp khóa.

Netting characterization final3 PASS 6 ca tại run `d9332e59d23041a292b76118719a164e`, gồm foreign_units và duplicate_reversal; đây không phải concurrency proof. Netting offline 3 ca OK, runtime host hiện tại 22 OK (1 skip). Tổng host dự kiến 101 test = 100 PASS + 1 skip đang chờ phần final run còn lại kết thúc; chưa công bố tổng này là kết quả hoàn tất. Main tiếp tục thu manifest final3.

Final3 native CheckConfig run `e8111bd968cf45e4bad24587d449ad94` PASS, exit 0, No errors found. Dump cùng ID đối chiếu source: 180/180 file, 0 khác biệt, exit 0. Ban đầu chỉ 3 XML khác biểu diễn newline/BOM, namespace/indent; main đã kiểm và canonical hóa source theo native dump. Các sửa same-instance giữ mapping 641 và quyền role gốc, không phải migration tài khoản/quyền.

```text
python -B scripts/test_concurrent_posting.py --sequential --scenario payment --repeats 1 --ib-path "<absolute-workspace>/scratch/uat/<runid>/ib" --snapshot-backup "<absolute-path>/VinSmart_Future_AR_AP_Full.dt" --results-dir "<absolute-workspace>/scratch/uat/<runid>/results"
```

Đổi `--scenario payment` thành `--scenario revaluation` cho 3 ca FX với baseline mục tiêu độc lập. Backup phải khớp SHA-256 marker. Bỏ `--sequential` để yêu cầu hai phiên thật; Training Edition hiện không mở được đủ kết nối, nên gate đó vẫn NOT_RUN. Runner giữ `execution` trong kết quả để phân biệt hai chế độ.

Runner characterization dùng `ketoan_ap` để tạo fixture và `ketoan_truong` để duyệt/post. Nếu tài khoản có mật khẩu, cung cấp qua `ONEC_MAKER_PASSWORD` và `ONEC_CHECKER_PASSWORD`; dùng `--onec-exe` để chỉ executable khác mặc định.

## Bằng chứng và phạm vi báo cáo

[Báo cáo rà soát hiện tại](docs/ERP_AUDIT_2026-10-14_FINAL_100.md) và [ledger nguồn số liệu](docs/DATA_PROVENANCE_LEDGER.md) phân biệt snapshot lịch sử với kết quả mới. Các số liệu ở docs/evidence/operational_trial_balance_evidence.json thuộc snapshot cũ, không chứng minh trạng thái production hiện tại.

Manifest dự kiến phải ghi lệnh thật, thời điểm, Git HEAD/hash source, clone path/run ID, hash dump và pass/fail/not_run của từng gate. Chỉ báo cáo gate đã có bằng chứng mới; quyết định phát hành cần phê duyệt của người có thẩm quyền. Module lớn chỉ được tách khi có nhu cầu sửa chức năng và test bảo vệ; kích thước file tự nó không phải lý do chia module.

Các mục còn mở: tiêm lỗi biên lô 49/50/51 NOT_RUN, full canary, legacy full-volume NOT_RUN, SourceBslReference (24 file BSL tham khảo) NOT_RUN, pilot và phê duyệt finance; manifest final3 còn chờ main. GL data quality vẫn FAIL ở lần đo đã ghi: 360 dòng đối soát tài khoản 1388 thiếu contract và 4 dòng AR/AP thiếu partner + contract. GL keys PASS của bounded 10/210 Ref mới không thay đổi kết luận dữ liệu lịch sử. Không tạo hợp đồng giả hoặc backfill khi chưa có khóa ngoại hợp lệ.

Backfill wrapper yêu cầu clone tường minh, đã bỏ global Stop-Process/password và trả unsupported NOT_RUN; chưa chứng minh mutation thành công. Agent báo concurrent offline 22, self-test 4 và backfill wrapper 3 ca PASS, đang chờ final rerun. Genuine two-session cùng source final3 được lên kế hoạch rerun; giữ NOT_RUN cho tới khi có kết quả mới.

Tài liệu liên quan: [kế hoạch hardening](docs/superpowers/plans/2026-10-14-codebase-hardening-plan.md), [báo cáo kiểm toán lịch sử](docs/ERP_AUDIT_2026-10-12.md), [báo cáo cleanup](CLEANUP_REPORT.md), [tài liệu nền tảng](docs/reference/). Những tài liệu lịch sử cần được đọc theo thời điểm snapshot của chúng.
