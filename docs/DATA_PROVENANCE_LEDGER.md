# Ledger nguồn số liệu ERP VSF AR/AP

Các số liệu dưới đây thuộc snapshot lịch sử và tài liệu trước hardening. Nguồn chính là [operational_trial_balance_evidence.json](evidence/operational_trial_balance_evidence.json), tự ghi database Infobase_FullData, ExportTime 2026-10-14 08:50:42 và kỳ 2025-01-01 đến 2026-09-30 (638 ngày).

JSON cũ chưa gắn với Git HEAD/hash source, clone path và run ID của đợt hardening hiện tại. Các trường status/Boolean trong snapshot không chứng minh dữ liệu production hiện tại, nguồn dữ liệu thực tế hay một phê duyệt đã được ký. Trường PolicyApproved = true và tham chiếu CSKT-VSF-2026/01 là metadata của snapshot; cần hồ sơ phê duyệt riêng để xác nhận chính sách.

[Tiến độ hardening](superpowers/reports/2026-10-14-hardening-progress.md) ghi các ca runtime đã đo. Khắc phục đã được chấp thuận nhưng mới xác minh một phần, chưa đạt 100/100 hay nghiệm thu go-live. Manifest cuối `docs/evidence/hardening_verification.json` do người chạy tổng hợp sẽ ghi kết quả chính xác theo run/source, gồm clone `20261014-final2`; các số liệu snapshot dưới đây vẫn giữ phạm vi lịch sử của chúng.

## Bằng chứng hồi quy mới và phạm vi số liệu

Người thực hiện runtime đã ghi seed safety từ FAIL sang PASS và collision netting từ rò transaction sang đóng transaction/GL không đổi. Final2 có CheckConfig PASS và RBAC rerun 6 người dùng thật/12 ca PASS. Hardening mới nhất 3 ca PASS run `e6ff5fadff7b4f8e9ce8c277769cc3e8`, gồm hồi quy Admin tự posting đối soát qua DataExchange.Load RED → GREEN: guard quyền/checker trước import và maker/checker trong Posting chặn thao tác. Unit hiện tại 2 ca PASS run `b10d7a97d1fd4a5a9fd2a9afdf733834`; phí PASS run `02a645200b6c45ce94294b9e9b7e5631`. [Báo cáo hiện tại](ERP_AUDIT_2026-10-14_FINAL_100.md) ghi tên ca/run ID, gồm sáu run RBAC.

Lifecycle final3 3 ca PASS run `79bb1718fa474687bae86dddca6a7d9f`, user `ketoan_truong`; Admin bị từ chối duyệt đúng chính sách. Native RED phát hiện VAT AR/AP POST lần hai trên cùng object tạo 2 GL row thay vì 1; source clear movement sets do document sở hữu ở đầu Posting. Test tạo snapshot POST chuẩn bằng build hiện tại, kiểm POST lần hai trên cùng object, tiếp tục UNPOST/GetObject/REPOST, kiểm zero ở 5 register rồi rollback. Đây là parity trong cùng build; không xác minh legacy-key migration parity. Movements legacy thiếu keys sẽ khác các trường analytic mới, nên PASS không chứng minh migration/backfill dữ liệu lịch sử. Các kết quả clone không biến số dư/KPI của export cũ thành số liệu production mới.

Netting characterization final3 PASS đủ 6 ca run `d9332e59d23041a292b76118719a164e`, gồm foreign_units và duplicate_reversal; đây không phải concurrency proof. Genuine two-session trên final3 cùng source được lên kế hoạch rerun, vẫn NOT_RUN. Main đang thu manifest final3; không gán kết quả final2 cho source cuối khi chưa đối chiếu.

Native CheckConfig final3 run `e8111bd968cf45e4bad24587d449ad94` PASS, exit 0, No errors found. Source/dump ban đầu chỉ 3 XML khác biểu diễn newline/BOM, namespace/indent; main kiểm rồi canonical hóa source theo native dump cùng ID. Đối chiếu sau đó đã đo 180 source/180 dump file, 0 khác biệt, exit 0. Mapping 641 và quyền role gốc được giữ; đây không phải migration tài khoản/quyền hay backfill dữ liệu.

Characterization payment tuần tự tái hiện code cũ cho cả hai payment post và số dư âm; bản sửa đạt 4 ca. FX đạt 3 ca với baseline mục tiêu độc lập theo nhóm và giữ nguyên nguyên tệ. Snapshot lịch sử đã có một số nhóm số dư âm; không coi việc revaluation đạt mục tiêu của nó là sửa toàn bộ dữ liệu lịch sử. Hai-session concurrency vẫn NOT_RUN vì startup Training Edition giới hạn kết nối. Kết quả `--sequential` phải giữ nhãn `sequential_characterization` khi đưa vào manifest.

Ba command đọc `VerifyContractFees`, `VerifyGLAnalyticKeys`, `ExportTrialBalanceEvidence` có hợp đồng structured result, mỗi command một ca cùng tên. Final2 ghi biểu phí và export PASS; GL analytic keys/data quality FAIL: 8.215/8.579 bản ghi đủ partner + contract, thiếu 364. Diagnostics tại run `af358f9f120c4e23ac10373b11113234` phân loại 360 dòng đối soát tài khoản 1388 thiếu contract và 4 dòng AR/AP thiếu cả partner + contract. Không tạo hợp đồng giả hay backfill khi chưa có khóa ngoại hợp lệ; data quality vẫn FAIL.

Export final2 run `37d6a3c92ee74af1945a2261d472b6f8` ghi `<result_path>.evidence.json`, tách khỏi JSON kết quả strict, và `PolicyApproved = false`. Đây là export của clone, không phải phê duyệt finance. Các tổng trong export và mẫu số của gate GL khác phạm vi/thời điểm, không trộn với số 8.412 của snapshot lịch sử. Chỉ dùng export khi đã gắn với cùng run/clone/hash source. Generic runner vẫn trả NOT_RUN cho Seed* cũ; seed dương supplementary dùng workflow riêng.

Bounded `full --smoke` trên clone `20261014-seed-positive` GREEN tại run `6c4a16567cf2411ea3ebbb886b833397`: 9 phase PASS, đúng 10 Ref tài chính riêng biệt và GL keys mới PASS. Manifest từng domain ghi maker `ketoan_ar`, `ketoan_ap`, `chuyenvien_doisoat`, checker `ketoan_truong`; Admin chỉ enable/metadata/restore. Các lần RED trước đó phát hiện acceptance debit 1312 thiếu keys, helper AR chưa tồn tại và đối soát credit 1388 thiếu contract; source đã sửa keys từ trường chứng từ hợp lệ, thêm helper current availability có khóa/loại own recorder và GL partner + contract từng dòng. [Báo cáo hiện tại](ERP_AUDIT_2026-10-14_FINAL_100.md) ghi các run ID RED/GREEN.

Bounded full 210 Ref/21 tháng đã native PASS tại run `c90fc51b640e45a4b4d4f3e9aa804ae0`: AR 105 + AP 63 + netting 42, đủ 9 phase gồm restore. Manifest ghi ba maker và checker thật như smoke; Admin enable/metadata/restore. Cả smoke 10 và bounded 210 thuộc supplementary positive UAT sample, không phải backfill các dòng lịch sử thiếu khóa. Legacy full-volume khoảng 4.800+ và tiêm lỗi biên 49/50/51 vẫn NOT_RUN. Bulk generator gốc giữ guard để tương thích. Wrapper full yêu cầu `-BoundedWorkflow`, thêm `-Smoke` cho 10 hoặc bỏ để chọn 210; wrapper massive yêu cầu `-MetadataOnly` (Admin chỉ chuẩn bị metadata). Lệnh ở [README](../README.md#seed-dương-bổ-sung-trên-clone). Data quality lịch sử vẫn FAIL; manifest cuối còn chờ main.

Offline hiện đo audit 24 OK, runtime 22 OK (1 ca skip vì thiếu quyền symlink), clone creation 14 OK; không phải bằng chứng engine. Agent báo concurrent offline 22, self-test 4 và backfill wrapper 3 ca PASS, final rerun đang chờ. SourceBslReference gồm 21 unit + 3 migration = 24 file BSL vẫn NOT_RUN. Tiêm lỗi biên 49/50/51, full canary, pilot và phê duyệt finance còn mở; two-session concurrency vẫn NOT_RUN vì giấy phép/kết nối Training Edition, genuine rerun cùng source final3 được lên kế hoạch.

Host hiện tại runtime 22 OK (1 skip), netting offline 3 OK. Tổng host dự kiến 101 test = 100 PASS + 1 skip vẫn chờ phần final run còn lại kết thúc; không dùng tổng dự kiến làm bằng chứng nghiệm thu.

## Giá trị có trong JSON snapshot

| Chỉ tiêu | Giá trị lịch sử | Trường nguồn |
| :--- | :--- | :--- |
| Database được ghi trong export | Infobase_FullData | Provenance.Database |
| Số bản ghi GL | 8.412 | Provenance.TotalGLRecords |
| Tổng phát sinh Nợ | 3.087.498.695.648 VND | TrialBalance.TongPhatSinhNo |
| Tổng phát sinh Có | 3.087.498.695.648 VND | TrialBalance.TongPhatSinhCo |
| Delta bảng cân đối | 0 | TrialBalance.DeltaTrialBalance |
| AR subledger / GL | 39.549.200.000 VND mỗi bên; DeltaAR = 0 | Reconciliation.TongDuSubAR / TongDuGL_AR / DeltaAR |
| AP subledger / GL | 34.440.537.922 VND mỗi bên; DeltaAP = 0 | Reconciliation.TongDuSubAP / TongDuGL_AP / DeltaAP |
| Bank subledger / GL | 817.817.013.237 VND mỗi bên; DeltaBank = 0 | Reconciliation.TongDuSubBank / TongDuGL_Bank / DeltaBank |
| TK 1311 phát sinh Nợ | 320.657.000.000 VND | TrialBalance.ChiTietTaiKhoan, MaTaiKhoan 1311 |
| TK 1312 phát sinh Nợ | 837.721.500.000 VND | TrialBalance.ChiTietTaiKhoan, MaTaiKhoan 1312 |
| TK 5113 phát sinh Có | 1.053.136.000.000 VND | TrialBalance.ChiTietTaiKhoan, MaTaiKhoan 5113 |
| Số giao dịch USD | 1.060 | ForeignExchangeEvidence.SoLuongGiaoDichUSD |
| Tổng nguyên tệ / quy đổi | 18.536.239,83 USD / 467.738.369.148 VND | ForeignExchangeEvidence.TongNguyenTeUSD / TongQuyDoiVND |
| TK 515 / 635 / 4131 | 0 trong export | ForeignExchangeEvidence.LaiTyGia515 / LoTyGia635 / DanhGiaLai4131 |

Các delta bằng 0 chỉ là nội dung snapshot. Chúng không thay thế ca tiêm lỗi rollback, kiểm thử hai phiên cạnh tranh số dư hoặc đối chiếu ledger sau thay đổi source. Số 8.412 cũng không chứng minh toàn bộ bản ghi có đủ analytic keys.

## Giá trị chỉ được nêu trong tài liệu lịch sử

Các giá trị sau xuất hiện trong phiên bản ledger/báo cáo trước hardening, chưa được kiểm chứng lại; JSON trên không chứa đủ trường để xác nhận chúng:

| Nội dung được tài liệu cũ nêu | Giá trị | Giới hạn |
| :--- | :--- | :--- |
| Cơ cấu doanh thu AR | Nội bộ 72,3%, khách ngoài 27,7% | Snapshot có phát sinh Nợ 1311/1312; ý nghĩa doanh thu và tỷ trọng cần query cùng định nghĩa chỉ tiêu. |
| Chi phí hoạt động | 378.113.887.896 VND | Không có tổng chỉ tiêu này trong JSON snapshot. |
| Lợi nhuận trước thuế / biên lợi nhuận | 675.022.112.104 VND / 64,1% | Chưa có export chi tiết theo công thức chỉ tiêu. |
| DSO / DPO / CCC | 40,8 / 60,1 / -19,3 ngày | Cần số dư bình quân, doanh thu/chi phí và công thức theo kỳ thực tế. |
| Cost Savings | 18.200.000.000 VND | Cần cơ sở tính và phê duyệt nghiệp vụ; không ghi nhận phê duyệt mới. |
| Tiền theo ngân hàng | TCB 790.705.454.350 VND; VCB 185.184,83 USD (4.561.873.887 VND quy đổi); VPBank VA 22.549.685.000 VND | JSON hiện có tổng subledger Bank, không có toàn bộ chiều tài khoản tiền để xác nhận bảng này. |
| Số bộ chứng từ | AR 1.260; AP 840; cấn trừ 180; đối soát 180; UNC/thu tiền 1.000 | Cần kiểm kê Ref/Posted theo loại; số bộ không tự đồng nghĩa số chứng từ hoặc nguồn production. |

Công thức trong tài liệu cũ là DSO = số dư bình quân AR / doanh thu × 638; DPO = số dư bình quân AP / chi phí × 638; CCC = DSO - DPO. Kỳ 638 ngày và các định nghĩa mẫu này cần được người phụ trách nghiệp vụ xác nhận trước khi dùng để nghiệm thu KPI.

## Ánh xạ nguồn cần truy vết

| Chỉ tiêu | Chứng từ / register cần xem | Nội dung cần đối chiếu trên clone |
| :--- | :--- | :--- |
| Doanh thu và chi phí | Document.HoaDonGTGTDauRa, Document.HoaDonNhaCungCap; AccountingRegister.SoCaiKeToan | Tài khoản 5113, 642, 632; dự án DA_K1_*, DA_K2_*, DA_K3_*, DA_K4_*, DA_BO_*. |
| AR | AccumulationRegister.CongNoPhaiThu; GL 1311, 1312 | Ref chứng từ, đối tác, hợp đồng, thời điểm Balance và số dư GL từng chiều. |
| AP | AccumulationRegister.CongNoPhaiTra; GL 3311, 3312, 3313 | NCC, hợp đồng, nghĩa vụ gốc, nguyên tệ và quy đổi. |
| Ngân hàng | AccumulationRegister.DongTien; GL 1121, 1122 | TaiKhoanTien, loại tiền, chứng từ thanh toán và số dư sau posting/unposting. |
| Netting / savings | Document.CanTruCongNoNoiBo; AR/AP và GL | Số tiền cấn trừ thực tế, cơ sở phí tránh được và giả định tính savings. |
| CFO KPI | DataProcessor.DashboardLanhDaoCFO và nguồn số dư/phát sinh | Công thức, kỳ, mẫu số, dữ liệu đầu vào và kết quả export mới. |

Đây là các điểm truy vết theo tên module/metadata trong repository. Việc kiểm tra source không chứng minh một query hoặc quy tắc đã chạy trên engine.

## Mẫu chứng từ được ghi trong tài liệu cũ

Bảng này giữ thông tin lịch sử để tìm lại mẫu. Chưa có Ref/hash bản ghi của lần chạy hardening xác nhận các dòng này:

| Loại | Số mẫu | Ngày | Đối tác / kênh | Giá trị lịch sử | Trạng thái tài liệu cũ nêu |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Nghiệm thu AR | BB-25-000001 | 01/01/2025 | TEST_VG_01 (Vinhomes) | 385.000.000 VND | Posted, DaDuyetNoiBo |
| Hóa đơn đầu ra | HD-25-000001 | 01/01/2025 | TEST_VG_01 (Vinhomes) | 385.000.000 VND | Posted, DaPhatHanh |
| Cấn trừ nội bộ | CT-TEST-00001 | 10/01/2025 | TEST_VG_01 (Vinhomes) | 120.000.000 VND | Posted, DaDuyet |
| Đối soát OnePay ATM 1,5% | DS-TEST-00001 | 08/01/2025 | OnePay ATM | 185.000.000 VND | Posted, DaDoiSoat |
| Đối soát OnePay Visa/Master 2,2% | DS-TEST-00001 | 08/01/2025 | OnePay Visa/Master | 132.000.000 VND | Posted, DaDoiSoat |
| Đối soát VA 0,5% | DS-TEST-00003 | 15/01/2025 | VPBank VA | 245.000.000 VND | Posted, DaDoiSoat |
| Hóa đơn NCC USD | HDC-25-00001 | 05/01/2025 | AWS Cloud Inc. | 17.500 USD; tỷ giá 25.450 | Posted, DaGhiSo |

Hai dòng OnePay dùng cùng số mẫu trong tài liệu cũ. Cần Ref và loại/kênh để phân biệt, không suy ra tính duy nhất chỉ từ số chứng từ.

## Bằng chứng cần bổ sung

Người chạy phải ghi backup nguồn và SHA-256, đường dẫn clone canonical, run ID, thời điểm, Git HEAD/hash source, lệnh thật, số ca kỳ vọng và kết quả mới vào manifest. Với số liệu, giữ query/tham số và export của cùng clone/phiên cùng đối chiếu GL/subledger; với canary, ghi Ref, count và hash trước/sau.

Giữ các mục thiếu bằng chứng ở not_run hoặc chưa xác minh. Hồ sơ phê duyệt chính sách, kế toán và phát hành cần được xác nhận riêng. Hướng dẫn clone và runner ở [README](../README.md); phạm vi audit ở [báo cáo hiện tại](ERP_AUDIT_2026-10-14_FINAL_100.md).
