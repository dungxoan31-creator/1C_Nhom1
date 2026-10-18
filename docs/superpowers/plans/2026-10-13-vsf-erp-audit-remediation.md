# VSF ERP Audit Remediation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Sửa tận gốc các sai lệch kế toán, quyền hạn, cấn trừ và báo cáo; chỉ chấm 100/100 sau khi kiểm chứng trên 1C runtime và ký duyệt nghiệp vụ.

**Architecture:** 1C:Enterprise 8.3 là nguồn dữ liệu và sổ cái duy nhất. Các chứng từ ghi đồng thời vào sổ phụ và `SoCaiKeToan`; một bộ quy tắc truy vấn tại cùng thời điểm chốt tạo số liệu cho tuổi nợ và Dashboard CFO. Kiểm soát quyền và chuyển trạng thái chạy ở phía server trên mọi đường ghi sổ.

**Tech Stack:** 1C:Enterprise 8.3, BSL, metadata XML, Python `unittest`, PowerShell, Git.

**Spec:** Yêu cầu audit và nguyên tắc 1C độc lập do chủ dự án nêu; [audit hiện có](../../ERP_AUDIT_2026-10-12.md). [Đặc tả 10/10](../specs/2026-10-10-vinsmart-future-ar-ap-management-design.md) chỉ dùng cho nghiệp vụ không mâu thuẫn với nguyên tắc này; phần 1C/SAP trong đó là lịch sử, không phải yêu cầu triển khai.

## Global Constraints

- Không thêm kết nối, metadata, adapter, lịch đồng bộ hoặc trạng thái đồng bộ với SAP/Oracle ERP hay hệ thống ngoài. Tên nhà cung cấp SAP/Oracle trong dữ liệu mẫu chỉ là danh mục thương mại.
- Không thay số liệu mẫu hay nới test để che chênh lệch thực tế. Số dư âm, khoản ứng trước và bút toán đảo phải được phân loại rõ.
- Mọi thao tác tiền, duyệt, ghi sổ, cấn trừ phải fail closed khi thiếu đầu vào, quyền, tỷ giá hoặc số dư.
- Xác nhận chế độ kế toán cho năm tài chính đang chạy trước khi đổi tài khoản/quy tắc FX. [Bộ Tài chính xác nhận TT99/2025/TT-BTC](https://www.mof.gov.vn/tin-tuc-tai-chinh/tin-chinh-sach-tai-chinh/tap-huan-trien-khai-thong-tu-so-992025tt-btc) áp dụng cho năm tài chính bắt đầu từ hoặc sau 01/01/2026; dữ liệu lịch sử trước đó cần quy tắc chuyển tiếp có phê duyệt.
- Không tuyên bố đã kiểm chứng nghiệp vụ 1C từ kết quả Python/static check. Không dùng event log cũ làm bằng chứng test mới.
- Công việc sửa ở branch/worktree Antigravity đã tạo; không push/merge khi chưa được yêu cầu.

## Review Focus

- Ghi sổ cấn trừ khi số dư AR/AP bằng 0, âm, thiếu chứng từ gốc hoặc sai đối tác: phải từ chối và không sinh movement.
- Thanh toán USD một phần/toàn phần ở cả chiều lãi và lỗ tỷ giá: Có 112 và sổ tiền phải bằng đúng số tiền ngân hàng chi.
- Người lập tự duyệt, hai người dùng trống, sửa trạng thái qua payload hoặc `DataExchange.Load`: không được tạo chứng từ đã duyệt/đã ghi sổ.
- Một hóa đơn có khoản thanh toán vượt mức, khoản ứng trước hoặc hoàn trả: tuổi nợ, dashboard, GL và sổ phụ vẫn khớp tại cùng ngày chốt.
- Chạy kiểm thử trên infobase sạch rồi cố ý tiêm bút toán sai: bộ đối soát phải phát hiện, kể cả khi tổng Nợ = tổng Có.

## Scorecard và điều kiện dừng

| Trụ cột | Điểm tối đa | Bằng chứng bắt buộc để đạt trọn điểm |
| --- | ---: | --- |
| 1C độc lập | 25 | Metadata và đường thực thi không có adapter/sync ngoài; tài liệu hiện hành chỉ mô tả GL và báo cáo nội sinh 1C; test chống tái xuất hiện chạy qua. |
| Kế toán và GL | 25 | Bộ ca hạch toán được kế toán trưởng duyệt; FX, netting, đảo bút toán đúng; đối soát theo chứng từ/tài khoản/kỳ/tài khoản ngân hàng bằng 0 sai lệch. |
| Dữ liệu và KPI | 25 | Dataset có nguồn gốc, ngày chốt, tỷ trọng và phân bố tuổi nợ hợp lý; Dashboard = báo cáo chi tiết tại cùng cutoff; DSO/DPO đúng mẫu số/kỳ; không có tiền gửi âm không giải thích. |
| Kiến trúc, quyền và kiểm thử | 25 | Metadata XML khớp BSL; toàn bộ posting paths áp quyền; test âm tính và 1C runtime/UAT pass, log có run ID mới và exit code hợp lệ. |

**Hard gates:** Bất kỳ dấu vết tích hợp ERP ngoài còn hoạt động, sai số tiền ngân hàng, maker tự duyệt, cấn trừ vượt số dư, hoặc không chạy được kiểm thử 1C runtime đều chặn nhãn **100/100** bất kể tổng điểm cơ học. Điểm 100 là kết quả audit lại độc lập, không phải kết quả tự khai của test suite.

---

### Task 1: Chốt nguồn sự thật và baseline có thể tái lập

**Files:** Modify `scripts/test_ledger_integrity.py`, `scripts/run_unit_tests.ps1`; create `docs/superpowers/reports/2026-10-13-remediation-baseline.md`.

**Interfaces:** Mỗi lần chạy tạo `run_id`, thời điểm bắt đầu/kết thúc, commit SHA, phiên bản platform, tên infobase và file kết quả mới. Test runner trả mã khác 0 khi thiếu kết quả hoặc có lỗi.

- [ ] Ghi kết quả hiện tại của `git status`, danh sách metadata XML/BSL, baseline KPI tại một cutoff cố định và phiên bản infobase được dùng.
- [ ] Viết test phản ví dụ: subprocess lỗi, log cũ vẫn chứa `DELTA = 0`, hoặc không có file kết quả mới đều phải fail.
- [ ] Sửa runner kiểm `returncode`, timestamp/run ID và kết quả runtime mới; bỏ phụ thuộc vào tìm chuỗi bất kỳ trong `.lgp` lịch sử.
- [ ] Chạy test phản ví dụ và test bình thường; lưu lệnh, đầu ra, commit SHA. Chỉ tiếp tục khi có baseline đáng tin.

### Task 2: Xóa yêu cầu kiến trúc cũ có thể tái sinh SAP sync

**Files:** Modify `docs/superpowers/specs/2026-10-10-vinsmart-future-ar-ap-management-design.md`, `docs/superpowers/plans/2026-10-10-vinsmart-future-ar-ap-implementation-plan.md`, `scripts/test_1c_only.py`; giữ báo cáo lịch sử dưới nhãn lưu trữ rõ ràng.

**Interfaces:** Test quét metadata đang dùng và tài liệu **hiện hành** cho các tên `DongBoButToanSAP`, `TrangThaiDongBoSAP`, `TuDongDongBoSAP`, IDoc/RFC/BAPI; cho phép tên SAP/Oracle ở danh mục NCC và báo cáo lưu trữ được đánh dấu.

- [ ] Chứng minh `src/Configuration.xml` và module hiện hành không tham chiếu tích hợp ERP ngoài; phân biệt tên NCC với adapter.
- [ ] Sửa những đoạn đặc tả/kế hoạch còn viết SAP là GL of Record, batch sync, webhook/HTTP integration thành GL và đối soát nội sinh 1C; không xóa bằng chứng lịch sử cần lưu trữ.
- [ ] Mở rộng `python -m unittest scripts.test_1c_only -v` với ca vi phạm giả; ca giả phải fail, cấu hình sạch phải pass.

### Task 3: Khóa quyền ghi sổ và chuyển trạng thái trên server

**Files:** Modify `src/CommonModules/PhanQuyenBaoMatServer/Ext/Module.bsl`, `src/CommonModules/QuanLyVongDoiChungTuServer/Ext/Module.bsl` và các `src/Documents/*/Ext/ObjectModule.bsl` có `Posting`; update `tests/unit/WorkflowPheDuyetAPTest.bsl`, `tests/unit/PheDuyetDaCapTest.bsl`, `scripts/test_user_roles.py`.

**Interfaces:** Mọi `Posting` gọi cùng kiểm soát quyền dựa trên `UserName()`/role của phiên; maker và checker đều bắt buộc và khác nhau; trạng thái mới phải được so với trạng thái đã lưu, không chỉ so với field payload. Quyền Admin kỹ thuật không tự biến thành quyền phê duyệt kế toán.

- [ ] Lập ma trận **tất cả** 13 document posting paths: loại AR/AP/netting, role được phép lập/duyệt/ghi sổ, trường hợp `DataExchange.Load`, rollback/repost.
- [ ] Viết ca fail trước cho cả hai user trống, maker=checker, AR ghi AP, AP ghi AR, PM/TechLead ghi sổ, sửa field `NguoiDuyet`/`TrangThai` trực tiếp, import bypass.
- [ ] Sửa helper tập trung rồi nối toàn bộ posting paths vào helper; `WriteLogEvent` lưu loại chứng từ, ref, user phiên, chuyển trạng thái và nguyên nhân từ chối.
- [ ] Chạy suite quyền trên runtime 1C với tài khoản thật, bao gồm Admin; đối chiếu kết quả với ma trận.

### Task 4: Sửa hợp đồng hạch toán thanh toán USD

**Files:** Modify `src/Documents/UyNhiemChi/Ext/ObjectModule.bsl`, `src/CommonModules/QuanLyTyGiaVaNgoaiTeServer/Ext/Module.bsl`; update `tests/unit/CurrencyEngineTest.bsl`, `tests/unit/UyNhiemChiStateReversalTest.bsl`.

**Interfaces:** Một giao dịch giữ riêng `SoUSD`, `VNDNoGocDaTatToan`, `VNDChiThucTe`, `ChenhLechDaThucHien`; phép tính áp cho phần nợ được tất toán, không dùng tỷ giá hóa đơn cho toàn bộ khi thanh toán một phần.

- [ ] Kế toán trưởng xác nhận cách ghi tỷ giá ghi sổ của 1122 và 3313, thứ tự phân bổ thanh toán, làm tròn, phí ngân hàng và reversal theo kỳ kế toán áp dụng.
- [ ] Viết bốn ca fail trước: trả 2,6 triệu cho nợ gốc 2,5 triệu, chiều lãi, thanh toán một phần, hoàn trả; mỗi ca kiểm 331/112/515/635, `DongTien`, `CongNoPhaiTra` và số USD.
- [ ] Sửa bút toán để 331 giảm theo giá trị ghi sổ của khoản nợ tất toán, 112 giảm theo giá trị ghi sổ của tiền xuất; chênh lệch thực hiện vào 515/635 theo chính sách được duyệt. Không nuốt lỗi tỷ giá bằng `Except` rỗng.
- [ ] Chạy 1C runtime tests và đối chiếu từng dòng với sao kê giả lập, kể cả phí và partial payment.

### Task 5: Cấn trừ song phương và bắc cầu có chứng từ đủ điều kiện

**Files:** Modify `src/Documents/CanTruCongNoNoiBo/Ext/ObjectModule.bsl`, `src/DataProcessors/LapMaTranCanTruTapDoan/Ext/ObjectModule.bsl`; update `tests/unit/MaTranCanTruNettingTest.bsl`, `scripts/test_netting_and_edge_cases.py`.

**Interfaces:** Mỗi dòng netting chỉ tham chiếu chứng từ AR/AP đang mở, cùng pháp nhân/đối tác được phép, với `0 < SoTienCanTru <= min(SoDuAR, SoDuAP)` tính trước movement hiện tại. Netting đa phương có danh sách bên, văn bản đồng thuận và đối soát 1388/3388 theo từng bên; số dư bridge phải được tất toán hoặc có nghĩa vụ tồn đọng được thuyết minh.

- [ ] Chốt với kế toán trưởng liệu cấn trừ bắc cầu có quan hệ pháp lý ba bên và tài khoản trung gian nào là phù hợp; không dùng hai bút toán cân đối kép để suy ra nghĩa vụ đã tất toán.
- [ ] Viết ca fail cho số dư 0/âm/thiếu chứng từ, sai đối tác, vượt số dư, repost và bridge chưa được tất toán.
- [ ] Sửa truy vấn số dư theo đủ khóa tại boundary trước chứng từ và khóa đồng thời cần thiết; trạng thái chỉ chuyển theo luồng hợp lệ.
- [ ] Chạy kiểm thử 1C và soát sau ghi sổ: AR/AP/GL giảm đúng giá trị, 1388/3388 khớp nghĩa vụ và tổng Nợ = tổng Có.

### Task 6: Một định nghĩa công nợ mở cho tuổi nợ và CFO Dashboard

**Files:** Modify `src/CommonModules/BaoCaoQuanTriServer/Ext/Module.bsl`, `src/DataProcessors/DashboardLanhDaoCFO/Ext/ObjectModule.bsl`, `src/CommonModules/GeneratorARServer/Ext/Module.bsl`, `src/CommonModules/GeneratorAPServer/Ext/Module.bsl`; update `tests/unit/BaoCaoTuoiNoVaSafetyGateTest.bsl`, `scripts/test_dashboard_cfo.py`, `scripts/test_executive_reports.py`.

**Interfaces:** Cùng `NgayChot` và cùng khóa pháp nhân/đối tác/hợp đồng/chứng từ gốc: số dư dương là công nợ mở, số dư âm là ứng trước/thu thừa riêng. `TongAR` trên dashboard bằng tổng 5 bucket AR; `TongAP` bằng tổng 5 bucket AP. Chỉ số DSO/DPO ghi rõ cửa sổ tính và mẫu số; DPO không âm chỉ vì có ứng trước Cloud, ứng trước được trình bày riêng.

- [ ] Tạo bảng chênh lệch theo chứng từ tại cutoff 2026-09-30; giải thích vì sao ageing 874,797 tỷ khác dashboard 43,588 tỷ trước khi sửa query.
- [ ] Viết test fail cho hóa đơn dương và credit âm cùng đối tác, khoản ứng trước, cutoff khác nhau, biên ngày quá hạn 0/30/60/90, khách Vingroup quá hạn và khách ngoài >60 ngày.
- [ ] Sửa logic phân bổ thanh toán hoặc truy vấn gộp, tùy nguyên nhân gốc; chỉ đề xuất khóa API cho khách ngoài, không tự ngắt dịch vụ. Tính DSO/DPO từ doanh thu/chi phí cùng kỳ, xử lý mẫu số bằng 0.
- [ ] Đổi KPI `LoiNhuanTruocThue`/`TySuatLoiNhuanRong` nếu thiếu 641/642/635/thuế; hoặc tính đủ từ GL theo định nghĩa được kế toán duyệt. Chạy báo cáo tại hai cutoff và so khớp nguồn 1C.

### Task 7: Đối soát độc lập, FX cuối kỳ và dữ liệu mẫu

**Files:** Modify `src/CommonModules/QuanLyVongDoiChungTuServer/Ext/Module.bsl`, `src/CommonModules/SeedFullTestDataServer/Ext/Module.bsl`, các generator thực sự gây lỗi; update `tests/unit/AccumulationRegistersTest.bsl`, `tests/unit/ChartOfAccountsTest.bsl`, `scripts/test_ledger_integrity.py`.

**Interfaces:** Bộ đối soát trả số lượng và chênh lệch theo chứng từ/tài khoản/kỳ/pháp nhân/đối tác, thêm 112 theo tài khoản ngân hàng, 131/331 và thuế; kết quả có tổng sai lệch bằng 0 và danh sách ngoại lệ rỗng. `KiemTraCanDoiSoCai` không được dùng như bằng chứng duy nhất vì mỗi dòng Dr/Cr đang chia sẻ cùng `SoTien`.

- [ ] Cố ý tiêm sai GL nhưng cân Nợ=Có, sai sổ phụ và sai 112; bộ đối soát phải phát hiện từng loại.
- [ ] Sửa đối soát theo dimension thay vì chỉ so net toàn hệ thống; cấm bỏ qua lỗi query. Soát lại logic số dư VCB USD âm 5.364.663,99 và sửa giao dịch hoặc số dư đầu kỳ theo chứng từ nguồn.
- [ ] Lập ca đánh giá lại ngoại tệ cuối kỳ theo TT99 đã xác nhận: 1122/3313 và tài khoản chênh lệch theo tình huống; có ca kỳ 2025/2026 chuyển tiếp. Không tự sinh bút toán 413/515/635 khi chưa có chính sách được ký.
- [ ] Sinh dataset mới từ infobase sạch, ghi seed/version, rồi đối chiếu tỷ trọng doanh thu nội bộ 70–80%, khách ngoài 20–30%, phân bố 5 bucket, và khoản ứng trước Cloud. DSO ~51 ngày là mục tiêu kịch bản, không ép bằng sửa công thức; DPO âm phải là chỉ số ứng trước riêng nếu có.

### Task 8: Runtime UAT, audit lại và bàn giao

**Files:** Create `docs/superpowers/reports/2026-10-13-remediation-verification.md`; update `docs/ERP_AUDIT_2026-10-12.md` bằng phụ lục kết quả mới, không ghi đè lịch sử.

**Interfaces:** Báo cáo cuối chứa commit, danh sách file thay đổi, phiên bản 1C, infobase, `run_id`, lệnh và kết quả, bảng bút toán mẫu, chênh lệch trước/sau, điểm từng trụ cột và chữ ký/phê duyệt nghiệp vụ còn thiếu.

- [ ] Parse tất cả metadata XML; chạy `python scripts/verify_bsl_syntax.py`, `python -m unittest scripts.test_1c_only scripts.test_executive_reports -v`, `python scripts/test_dashboard_cfo.py`, `python scripts/test_ledger_integrity.py` với runner đã sửa.
- [ ] Nạp cấu hình lên infobase thử nghiệm sạch; chạy toàn bộ `tests/unit/*.bsl` và các migration/UAT liên quan bằng 1C platform. Thu file kết quả **mới**, kiểm tra exit code và số ca fail bằng 0.
- [ ] UAT với kế toán AR, AP, kế toán trưởng, CFO và kỹ thuật: duyệt chứng từ, thanh toán USD, netting, safety gate, ngày chốt, hoàn trả và khóa kỳ. Kế toán trưởng ký mapping tài khoản/tỷ giá; chủ nghiệp vụ ký KPI và số liệu mẫu.
- [ ] Reviewer khác người sửa kiểm diff, chạy lại test và chấm 4 trụ cột. Chỉ công bố **100/100** khi tất cả hard gates đạt, mọi ngoại lệ được đóng, bằng chứng runtime mới và sign-off có đủ; nếu chưa, công bố điểm thực tế cùng hạng mục còn mở.

## Thứ tự triển khai và checkpoint

1. **Cổng A — Baseline:** Task 1–2. Có bằng chứng sạch và không còn yêu cầu SAP sync hiện hành.
2. **Cổng B — Chống ghi sai:** Task 3–5. Không thể ghi sổ sai quyền, vượt số dư hoặc sai tiền ngân hàng.
3. **Cổng C — Báo cáo đáng tin:** Task 6–7. AR/AP/GL/tiền ngân hàng/KPI cùng khớp tại cutoff.
4. **Cổng D — Nghiệm thu:** Task 8. Runtime 1C, UAT và audit độc lập quyết định điểm cuối.

Mỗi task có test fail trước, thay đổi nhỏ nhất ở nguyên nhân gốc, test pass sau và một commit riêng để reviewer có thể chấp nhận/từ chối độc lập.
