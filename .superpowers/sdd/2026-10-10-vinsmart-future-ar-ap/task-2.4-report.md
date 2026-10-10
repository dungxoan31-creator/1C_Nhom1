# Báo Cáo Triển Khai Task 2.4: Thư Viện `PheDuyetDaCapServer` — Anti-Split Quét Hóa Đơn & Luồng Phê Duyệt 4+1 Cấp

**Dự án:** Phân hệ Quản lý Công nợ AR & AP — Công ty Cổ phần VinSmart Future (VSF), Tập đoàn Vingroup  
**Nền tảng:** 1C:Enterprise 8.3 (Managed Application / Taxi / BSL / XML Metadata Version 2.15)  
**Nhiệm vụ:** Task 2.4 - Thư viện `PheDuyetDaCapServer`: Anti-Split Quét Hóa Đơn & Luồng Phê Duyệt 4+1 Cấp (Phase 2)  
**Trạng thái (Status):** **DONE** (100% Pass)  
**Thời gian hoàn thành:** 10/10/2026  

---

## 1. Tóm Tắt Kết Quả Triển Khai (Executive Summary)

Implementer đã hoàn thành toàn bộ các yêu cầu kỹ thuật theo đúng `task-2.4-brief.md`, Architecture Spec v5.0 và Implementation Plan:
1. **Tuân thủ quy trình Test-Driven Development (TDD / Test-first):**
   - Khởi tạo bộ kiểm thử tự động `tests/unit/PheDuyetDaCapTest.bsl` trước khi cài đặt module nghiệp vụ.
   - Định nghĩa đầy đủ 5 kịch bản kiểm thử bao phủ toàn bộ các quy tắc phê duyệt, phát hiện gian lận lách hạn mức (Anti-Split) và nhánh phê duyệt đặc biệt CFO Unlock khi vượt ngân sách > 10%.
2. **Khởi tạo CommonModule `PheDuyetDaCapServer`:**
   - Cấu hình thuộc tính: `Server = true`, `ServerCall = true`, `ReturnValuesReuse = DontUse`.
   - Chuẩn hóa 100% định danh BSL theo PascalCase không dấu tiếng Việt.
   - Thiết lập cơ chế đa tầng linh hoạt: vừa truy vấn trực tiếp bảng cơ sở dữ liệu (`AccumulationRegister.CongNoPhaiTra`, `Document.HoaDonNhaCungCap`, `InformationRegister.KeHoachChiTien`), vừa hỗ trợ kho lưu trữ mô phỏng cho unit test độc lập.
3. **Cài đặt 4 chữ ký hàm bắt buộc:**
   - `XacDinhCapPheDuyetTheoSoTien(Val SoTien)`: Phân loại 4 cấp phê duyệt cơ bản dựa trên giá trị đơn lẻ ($\le 100$tr $\rightarrow$ `TruongBoPhan`, $\le 500$tr $\rightarrow$ `KeToanTruong`, $\le 2$ tỷ $\rightarrow$ `GiamDocKhoi`, $> 2$ tỷ $\rightarrow$ `TongGiamDoc`).
   - `TinhTongLuyKeTrongThang(Val PhapNhan, Val DoiTac, Val ThoiDiem)`: Quét và tính tổng giá trị các hóa đơn mua dịch vụ phát sinh trong cùng tháng dương lịch của cùng một Nhà cung cấp và Pháp nhân.
   - `XacDinhCapPheDuyetHoaDon(Val PhapNhan, Val DoiTac, Val SoTien, Val ThoiDiem)`: Cơ chế phát hiện gian lận Anti-Split (Lách hạn mức) — tự động leo thang cấp phê duyệt lên cấp tương ứng với tổng lũy kế trong tháng.
   - `KiemTraYeuCauDuyetCFO(Val PhapNhan, Val DuAn, Val KhoanMucDongTien, Val ThoiDiem, Val SoTienChi)`: Cơ chế +1 CFO Special Unlock — kiểm tra ngân sách 4 chiều trên `InformationRegister.KeHoachChiTien`, yêu cầu bổ sung chữ ký phê duyệt của CFO nếu tổng chi tiêu vượt $> 10\%$ ngân sách tháng.
4. **Tuân thủ tuyệt đối ranh giới file tác động:**
   - Chỉ tạo/chỉnh sửa 3 file được chỉ định: `tests/unit/PheDuyetDaCapTest.bsl`, `src/CommonModules/PheDuyetDaCapServer.xml`, và `src/CommonModules/PheDuyetDaCapServer/Ext/Module.bsl`.
   - Không gây xung đột với Task 2.3 đang chạy song song và sẵn sàng cho Orchestrator tích hợp vào `Configuration.xml`.

---

## 2. Danh Sách File Đã Tạo (Artifacts Created)

| STT | Đường Dẫn File | Loại Đối Tượng | Mô Tả Kỹ Thuật |
| :-: | :--- | :--- | :--- |
| 1 | `tests/unit/PheDuyetDaCapTest.bsl` | BSL Test Suite | Bộ unit test kiểm thử tự động 5 test cases theo Test-first (Phân cấp, Anti-Split leo thang, Ngưỡng 2 tỷ, Phân lập tháng/đối tác, CFO Unlock) |
| 2 | `src/CommonModules/PheDuyetDaCapServer.xml` | CommonModule XML | Metadata Common Module v2.15 (Server=true, ServerCall=true, ReturnValuesReuse=DontUse) |
| 3 | `src/CommonModules/PheDuyetDaCapServer/Ext/Module.bsl` | BSL Source | Logic phân cấp phê duyệt 4 cấp, thuật toán quét Anti-Split leo thang, và kiểm tra vượt ngân sách CFO Unlock |

---

## 3. Chi Tiết Kỹ Thuật Của Thư Viện `PheDuyetDaCapServer`

### 3.1. Quy Tắc Phân Cấp Phê Duyệt 4 Cấp Cơ Bản (`XacDinhCapPheDuyetTheoSoTien`)
Quy tắc phân quyền tài chính AP của VinSmart Future:

| Cấp | Định Danh Trả Về | Ngưỡng Giá Trị Hóa Đơn (VND) | Ghi Chú Phân Quyền |
| :-: | :--- | :--- | :--- |
| Cấp 1 | `TruongBoPhan` | $\text{Giá trị} \le 100.000.000$ VND | Trưởng bộ phận phụ trách dịch vụ |
| Cấp 2 | `KeToanTruong` | $100.000.000 < \text{Giá trị} \le 500.000.000$ VND | Kế toán trưởng xét duyệt thanh toán |
| Cấp 3 | `GiamDocKhoi` | $500.000.000 < \text{Giá trị} \le 2.000.000.000$ VND | Giám đốc khối phụ trách kinh doanh / hạ tầng |
| Cấp 4 | `TongGiamDoc` | $\text{Giá trị} > 2.000.000.000$ VND | Tổng Giám đốc phê duyệt chi ngân sách lớn |

### 3.2. Cơ Chế Chống Gian Lận Lách Hạn Mức Anti-Split (`XacDinhCapPheDuyetHoaDon`)
- **Vấn đề nghiệp vụ:** Nhà cung cấp hoặc bộ phận mua sắm có thể cố tình chia nhỏ một gói dịch vụ lớn thành nhiều hóa đơn có giá trị $\le 500$tr VND để tránh việc phải trình Giám đốc khối hoặc Tổng Giám đốc phê duyệt.
- **Giải pháp Anti-Split:**
  $$\text{Tổng Lũy Kế Sau Hóa Đơn} = \text{Tổng Lũy Kế Đã Phát Sinh Trong Tháng} + \text{Giá Trị Hóa Đơn Mới}$$
- **Quy tắc leo thang (Escalation Rule):**
  $$\text{Cấp Phê Duyệt} = \max\Big(\text{Cấp Theo Giá Trị Hóa Đơn}, \text{Cấp Theo Tổng Lũy Kế Sau Hóa Đơn}\Big)$$
- Khi tổng lũy kế vượt ngưỡng phê duyệt cao hơn, cấp phê duyệt của hóa đơn hiện tại **TỰ ĐỘNG LEO THANG** lên cấp cao hơn tương ứng.

### 3.3. Nhánh Phê Duyệt Đặc Biệt +1 CFO Unlock (`KiemTraYeuCauDuyetCFO`)
- Kiểm tra ngân sách 4 chiều trên `InformationRegister.KeHoachChiTien`:
  $$\big(\text{Thang}, \text{DuAn}, \text{KhoanMucDongTien}, \text{PhapNhan}\big)$$
- Thuật toán xác định vượt ngân sách:
  $$\text{Tổng Chi Sau Hóa Đơn} = \max(\text{Số Tiền Đã Duyệt}, \text{Số Tiền Thực Chi}) + \text{Số Tiền Đề Nghị Chi}$$
  $$\text{Ngưỡng Cho Phép (110\% Ngân Sách)} = \text{Số Tiền Ngân Sách} \times 1.10$$
- Nếu $\text{Tổng Chi Sau Hóa Đơn} > \text{Ngưỡng Cho Phép}$ (vượt $> 10\%$ ngân sách):
  $$\rightarrow \text{Yêu Cầu Duyệt CFO} = \text{True}$$
  *(Hóa đơn bắt buộc phải có thêm chữ ký phê duyệt của Giám đốc Tài chính `GiamDocTaiChinh_CFO`)*.
- Nếu không có kế hoạch ngân sách ($\text{Ngân Sách} \le 0$) nhưng phát sinh chi tiêu $> 0$:
  $$\rightarrow \text{Yêu Cầu Duyệt CFO} = \text{True (Bắt buộc phê duyệt ngoại lệ)}$$

---

## 4. Kết Quả Kiểm Thử Unit Test (5/5 Test Cases PASS)

Toàn bộ 5 kịch bản kiểm thử trong `tests/unit/PheDuyetDaCapTest.bsl` đã được thực thi và xác nhận đạt kết quả 100% PASS:

```text
=================================================================
   VINSMART FUTURE - AP APPROVAL & ANTI-SPLIT TEST (TASK 2.4)   
   Thoi gian chay: 10/10/2026 12:52:15 PM
=================================================================
[PASS] Test 1: Phan cap phe duyet 4 cap theo gia tri hoa don co ban thanh cong.
[PASS] Test 2: Anti-Split phat hien chia nho hoa don va leo thang len GiamDocKhoi thanh cong.
[PASS] Test 3: Anti-Split luy ke vuot 2 ty tu dong leo thang len TongGiamDoc thanh cong.
[PASS] Test 4: Phan lap luy ke theo thang duong lich va theo doi tac chinh xac.
[PASS] Test 5: Nhanh phe duyet dac biet CFO Unlock khi vuot ngan sach > 10% thanh cong.
-----------------------------------------------------------------
Tong so test: 5 | Thanh cong: 5 | That bai: 0
=================================================================
```

### Chi Tiết Diễn Giải Từng Kịch Bản Kiểm Thử:
1. **Test 1 — Phân cấp cơ bản:**
   - $80.000.000$ VND $\rightarrow$ `TruongBoPhan` (PASS)
   - $250.000.000$ VND $\rightarrow$ `KeToanTruong` (PASS)
   - $1.200.000.000$ VND $\rightarrow$ `GiamDocKhoi` (PASS)
   - $3.500.000.000$ VND $\rightarrow$ `TongGiamDoc` (PASS)
   - Điểm mốc ranh giới: $100$tr đúng ngưỡng $\rightarrow$ `TruongBoPhan`, $100\text{tr} + 1$ VND $\rightarrow$ `KeToanTruong`; $500$tr $\rightarrow$ `KeToanTruong`, $500\text{tr} + 1$ VND $\rightarrow$ `GiamDocKhoi`; $2$ tỷ $\rightarrow$ `GiamDocKhoi`, $2\text{ tỷ} + 1$ VND $\rightarrow$ `TongGiamDoc`.
2. **Test 2 — Anti-Split leo thang cấp duyệt:**
   - Hóa đơn 1 của AWS = $300.000.000$ VND $\rightarrow$ `KeToanTruong`.
   - Hóa đơn 2 của AWS cùng tháng = $250.000.000$ VND: Riêng lẻ chỉ cần `KeToanTruong`, nhưng tổng lũy kế $= 300\text{tr} + 250\text{tr} = 550\text{tr} > 500\text{tr}$ $\rightarrow$ Tự động leo thang lên `GiamDocKhoi` (PASS).
3. **Test 3 — Anti-Split vượt ngưỡng 2 tỷ:**
   - Tổng lũy kế trước đó của NCC trong tháng = $1.800.000.000$ VND.
   - Hóa đơn mới = $300.000.000$ VND (đơn lẻ chỉ cần KTT), nhưng tổng lũy kế $= 1.8\text{ tỷ} + 300\text{tr} = 2.1\text{ tỷ} > 2.000.000.000$ VND $\rightarrow$ Tự động leo thang lên `TongGiamDoc` (PASS).
4. **Test 4 — Phân lập đối tác & tháng dương lịch:**
   - Hóa đơn tháng trước (tháng 9) của AWS = $400.000.000$ VND $\rightarrow$ Không bị cộng dồn vào lũy kế tháng 10 của AWS ($\text{Lũy kế} = 0$).
   - Hóa đơn tháng 10 của NCC Microsoft = $450.000.000$ VND $\rightarrow$ Không làm ảnh hưởng đến NCC AWS.
   - Hóa đơn tháng 10 của AWS = $200.000.000$ VND $\rightarrow$ Giữ nguyên cấp `KeToanTruong`, không bị leo thang nhầm (PASS).
5. **Test 5 — Nhánh CFO Unlock khi vượt ngân sách > 10%:**
   - Ngân sách tháng $= 100.000.000$ VND, đã duyệt $= 95.000.000$ VND. Hóa đơn mới $= 16.000.000$ VND $\rightarrow$ Tổng sau chi $= 111.000.000 > 110.000.000$ ($110\%$ ngân sách) $\rightarrow$ `YeuCauDuyetCFO = True` (PASS).
   - Ngân sách tháng $= 100.000.000$ VND, đã duyệt $= 80.000.000$ VND. Hóa đơn mới $= 25.000.000$ VND $\rightarrow$ Tổng sau chi $= 105.000.000 \le 110.000.000$ $\rightarrow$ `YeuCauDuyetCFO = False` (PASS).

---

## 5. Rà Soát Tuân Thủ Ràng Buộc & Tiêu Chuẩn Kỹ Thuật

- [x] **Không vi phạm ranh giới file:** Chỉ tác động vào 3 file được cấp phép (`PheDuyetDaCapTest.bsl`, `PheDuyetDaCapServer.xml`, `PheDuyetDaCapServer/Ext/Module.bsl`). Tuyệt đối không chạm vào `Configuration.xml` hay các file của Task 2.3.
- [x] **Quy ước đặt tên BSL:** 100% PascalCase tiếng Việt không dấu (`XacDinhCapPheDuyetTheoSoTien`, `TinhTongLuyKeTrongThang`, `XacDinhCapPheDuyetHoaDon`, `KiemTraYeuCauDuyetCFO`).
- [x] **Cấu trúc XML 1C:** Chuẩn 1C Metadata Version 2.15, đầy đủ XML namespace và thuộc tính.
- [x] **Quy trình Test-first:** Bộ test được tạo lập và kiểm chứng trước khi hoàn thiện logic.
- [x] **Sẵn sàng tích hợp:** Cấu trúc CommonModule tương thích hoàn toàn để Orchestrator tích hợp vào `Configuration.xml` khi nghiệm thu Phase 2.
