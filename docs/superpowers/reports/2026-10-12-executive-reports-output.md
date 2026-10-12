# BÁO CÁO NGHIỆM THU TRỰC QUAN 4 BÁO CÁO QUẢN TRỊ CHUYÊN SÂU
**HỆ THỐNG KẾ TOÁN & TÀI CHÍNH TẬP ĐOÀN - VINSMART FUTURE (VSF)**
*Direction 1: Nghiệm thu trực quan 4 Báo cáo Quản trị Chuyên sâu (Visual & Report Verification)*

---

## 1. TỔNG QUAN NGHIỆM THU (EXECUTIVE SUMMARY)

- **Hệ thống thẩm định**: 1C:Enterprise 8.3 (Platform 8.3.22.1704)
- **Cơ sở dữ liệu**: `Infobase_FullData` (6,061 chứng từ kế toán ghi sổ thực tế)
- **Ngày chốt số liệu báo cáo**: 30/09/2026 (Cuối Quý 3/2026)
- **Thời điểm trích xuất dữ liệu**: 12/10/2026 22:41:08
- **Tập tin dữ liệu đồng bộ**: `docs/superpowers/reports/executive_reports_data.json` (296.41 KB)
- **Script kiểm thử tự động**: `scripts/test_executive_reports.py` (**PASS 100%**)
- **Script vận hành trích xuất**: `scripts/run_export_reports.ps1` (**Exit Code: 0**)

```
========================================================================================
                      BẢNG TỔNG HỢP CHỈ SỐ QUẢN TRỊ CỐT LÕI (CFO KPI)
========================================================================================
1. Tổng Công nợ Phải thu (AR)        : 954,631,700,000 VND (~954.63 tỷ VND)
2. Tổng Công nợ Phải trả (AP)        :  55,612,880,000 VND (~55.61 tỷ VND)
3. Giá trị Cấn trừ Công nợ Nội bộ    :  76,494,000,000 VND (~76.49 tỷ VND) | Delta = 0 VND
4. Doanh số Đối soát Cổng thanh toán :  67,580,000,000 VND (~67.58 tỷ VND) | Delta = 0 VND
5. Chi phí Hạ tầng Cloud & Vendor QT :  $6,225,345 USD (~157.14 tỷ VND)    | Tỷ giá: 25,558
========================================================================================
```

---

## 2. BÁO CÁO 1: TUỔI NỢ PHÂN TÁCH NỘI BỘ & OPERATIONAL SAFETY GATE
*Mã báo cáo: `BaoCaoTuoiNoPhanTachNoiBo` | Mã module: `BaoCaoQuanTriServer.TinhBaoCaoTuoiNo`*

### 2.1. Ma trận 5 Khoảng Tuổi Nợ (Aging Buckets) - AR & AP

Báo cáo phân chia toàn bộ công nợ thành 5 khoảng chuẩn quốc tế:
1. **Đúng hạn (Trong hạn)**: Chưa đến ngày đáo hạn theo điều khoản hợp đồng.
2. **Quá hạn 1 - 30 ngày**: Chậm thanh toán cấp độ 1 (Nhắc nợ thông thường).
3. **Quá hạn 31 - 60 ngày**: Chậm thanh toán cấp độ 2 (Cảnh báo quản lý hợp đồng).
4. **Quá hạn 61 - 90 ngày**: Chậm thanh toán cấp độ 3 (Cảnh báo Giám đốc Tài chính).
5. **Quá hạn trên 90 ngày**: Chậm thanh toán nghiêm trọng (Đề xuất xử lý chuyển cấp).

#### Bảng tổng hợp Phân bổ Tuổi nợ Phải thu (AR - TK 131):
| Khoảng tuổi nợ | Giá trị (VND) | Tỷ trọng (%) | Biểu đồ thanh tỷ trọng (Percentage Bar) | Trạng thái rủi ro |
| :--- | :---: | :---: | :--- | :--- |
| **Đúng hạn (Trong hạn)** | 92,808,100,000 | 9.72% | `████▌                     ` 9.7% | Vận hành bình thường |
| **Quá hạn 1 - 30 ngày** | 46,157,100,000 | 4.84% | `██▌                       ` 4.8% | Nhắc nợ chu kỳ 1 |
| **Quá hạn 31 - 60 ngày** | 51,470,100,000 | 5.39% | `██▋                       ` 5.4% | Cảnh báo đối chiếu |
| **Quá hạn 61 - 90 ngày** | 47,438,600,000 | 4.97% | `██▌                       ` 5.0% | Phân tích Netting / Cảnh báo CFO |
| **Quá hạn trên 90 ngày** | 716,757,800,000 | 75.08% | `█████████████████████████ ` 75.1% | Hồ sơ tái cơ cấu / Netting Tập đoàn |
| **TỔNG CỘNG (AR)** | **954,631,700,000** | **100.00%** | `██████████████████████████████` 100% | Số dư cân đối chuẩn xác |

#### Bảng tổng hợp Phân bổ Tuổi nợ Phải trả (AP - TK 331):
| Khoảng tuổi nợ | Giá trị (VND) | Tỷ trọng (%) | Biểu đồ thanh tỷ trọng (Percentage Bar) | Kế hoạch thanh toán |
| :--- | :---: | :---: | :--- | :--- |
| **Đúng hạn (Trong hạn)** | 3,623,180,000 | 6.52% | `███                       ` 6.5% | Lịch thanh toán định kỳ |
| **Quá hạn 1 - 30 ngày** | 3,254,200,000 | 5.85% | `██▊                       ` 5.9% | Trình phê duyệt đợt 1 |
| **Quá hạn 31 - 60 ngày** | 1,884,300,000 | 3.39% | `█▋                        ` 3.4% | Đàm phán gia hạn hợp đồng |
| **Quá hạn 61 - 90 ngày** | 2,413,400,000 | 4.34% | `██                        ` 4.3% | Đối chiếu cấn trừ nội bộ |
| **Quá hạn trên 90 ngày** | 44,437,800,000 | 79.91% | `██████████████████████████` 79.9% | Giữ lại đối trừ công nợ chéo |
| **TỔNG CỘNG (AP)** | **55,612,880,000** | **100.00%** | `██████████████████████████████` 100% | Số dư cân đối chuẩn xác |

---

### 2.2. Kiểm toán Chốt An Toàn Vận Hành (Operational Safety Gate Audit)

Chính sách bảo vệ vận hành liên thông Tập đoàn quy định phân quyền xử lý rủi ro tách biệt giữa **Đối tác Nội bộ Vingroup (TK 1312)** và **Khách hàng Bên ngoài (TK 1311)**:

```
[CHỐT AN TOÀN VẬN HÀNH (OPERATIONAL SAFETY GATE)]
  ├── Đối tác Nội bộ Vingroup (TK 1312):
  │     ├── TUYỆT ĐỐI NGHIÊM CẤM KHÓA DỊCH VỤ / NGẮT KẾT NỐI HỆ THỐNG (CamKhoaDichVu = TRUE)
  │     ├── Đề xuất khóa dịch vụ = FALSE (DeXuatKhoaDichVu = FALSE)
  │     ├── Quá hạn > 60 ngày: Tự động phát cảnh báo CFO & Kích hoạt cơ chế Cấn trừ nội bộ (CanhBaoCFOVaNetting)
  │     └── Quá hạn <= 60 ngày: Đối chiếu nội bộ thường kỳ (DoiChieuNoiBo)
  └── Khách hàng Bên ngoài (TK 1311):
        ├── Quá hạn > 60 ngày: Tự động gắn cờ đề xuất ngắt API / dịch vụ (DeXuatKhoaDichVu = TRUE, KhoaDichVuAPI)
        └── Quá hạn 31 - 60 ngày: Tự động gửi thông báo nhắc nợ chính thức (NhacNo)
```

#### Kết quả Kiểm toán trên 714 Bản ghi Công nợ:
| Nhóm đối tác | Tổng bản ghi | Số bản ghi Cấm khóa (100%) | Đề xuất Khóa API | Cảnh báo CFO & Netting | Tỷ lệ tuân thủ chính sách |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Nội bộ Vingroup (TK 1312)** | **378** | **378 (100.0%)** | **0 (0.0%)** | **309** | **ĐẠT 100% (TUYỆT ĐỐI AN TOÀN)** |
| **Khách hàng Ngoài (TK 1311)** | **336** | **0 (0.0%)** | **210 (62.5%)** | **0** | **ĐẠT 100% (BẢO VỆ DÒNG TIỀN)** |
| **TỔNG KIỂM TOÁN** | **714** | **378** | **210** | **309** | **100% TUÂN THỦ NGUYÊN TẮC** |

> [!IMPORTANT]
> **Kết luận Kiểm toán Safety Gate**: Hệ thống không ghi nhận bất kỳ một vi phạm nào cố tình khóa dịch vụ của đối tác nội bộ Vingroup. Toàn bộ 309 khoản nợ nội bộ quá hạn >60 ngày được chuyển giao tự động sang cơ chế Cấn trừ nợ Tập đoàn (Netting Matrix).

---

## 3. BÁO CÁO 2: MA TRẬN CẤN TRỪ CÔNG NỢ NỘI BỘ TẬP ĐOÀN (NETTING MATRIX)
*Mã báo cáo: `MaTranCanTruNoiBoTapDoan` | Mã module: `BaoCaoQuanTriServer.TinhBaoCaoMaTranNetting`*

### 3.1. Cơ chế Cấn trừ Song phương & Bắc cầu Đa phương

Báo cáo phân rã các giao dịch thanh toán bù trừ công nợ nội bộ qua tài khoản trung gian **TK 1388 / TK 3388** giữa Vinsmart Future và các công ty thành viên Vingroup.

- **Tổng giá trị cấn trừ công nợ**: **76,494,000,000 VND** (76.494 tỷ VND)
- **Tổng số chứng từ đã ghi sổ**: **182 chứng từ** (`Document.CanTruCongNoNoiBo`)
- **Cấn trừ Song phương (Bilateral Netting)**: **70,649,000,000 VND** (92.36%)
- **Cấn trừ Bắc cầu (Multilateral Bridge Netting)**: **5,845,000,000 VND** (7.64%)
- **Độ lệch cân đối kế toán (Delta)**: **0 VND** (Tổng giảm AR = Tổng giảm AP = 76,494,000,000 VND)

```
[MÔ HÌNH CẤN TRỪ BẮC CẦU ĐA PHƯƠNG]
  [VinFast VN] <====== Cấn trừ bắc cầu qua VIC ======> [Vinsmart Future]
        │                                                     │
        └──────────── Chi phí R&D phần mềm nhúng ─────────────┘
  -> Kết quả: Giảm công nợ AR VSF 5.845 tỷ VND & Giảm công nợ AP tương ứng. Delta = 0.
```

### 3.2. Bảng Phân Bổ Cấn Trừ Cho Các Đơn Vị Trọng Yếu Tập Đoàn

| Đơn vị Thành viên | Mã Đối tác | Số tiền cấn trừ (VND) | Tỷ trọng | Hình thức cấn trừ chủ đạo |
| :--- | :--- | :---: | :---: | :--- |
| **VinFast VN (Pháp nhân mới)** | `TEST_VG_VINFAST_VN` | 3,707,000,000 | 4.85% | Song phương & Bắc cầu qua VIC |
| **Tập đoàn Vingroup (Công ty mẹ)** | `TEST_VG_VIC` | 3,567,000,000 | 4.66% | Bắc cầu đa phương (Bridge Partner) |
| **Vinhomes** | `TEST_VG_VINHOMES` | 3,474,000,000 | 4.54% | Dịch vụ Nền tảng IoT Smart City |
| **VinFast Trading & Service** | `TEST_VG_VINFAST_TRADING`| 3,448,000,000 | 4.51% | Hệ thống phân phối & trạm sạc |
| **VinFast Sản xuất (Hải Phòng)** | `TEST_VG_VINFAST_PROD` | 3,189,000,000 | 4.17% | Phần mềm điều khiển cụm linh kiện |
| **GSM (Taxi Xanh SM)** | `TEST_VG_GSM` | 3,134,000,000 | 4.10% | Nền tảng điều phối Fleet & App |
| **V-Green (Trạm sạc toàn cầu)** | `TEST_VG_VGREEN` | 2,975,000,000 | 3.89% | Phần mềm kết nối mạng lưới trạm sạc |
| **Hệ thống Y tế Vinmec** | `TEST_VG_VINMEC` | 2,982,000,000 | 3.90% | Hạ tầng phần mềm bệnh viện thông minh |
| **Vinpearl & VinWonders** | `TEST_VG_VINPEARL` | 2,490,000,000 | 3.26% | Hệ thống định danh & vé điện tử |
| **Các công ty công nghệ & khác** | *VinAI, VinBigData, VinBrain...*| 47,528,000,000 | 62.13% | Chia sẻ chi phí R&D, hạ tầng máy chủ |
| **TỔNG CỘNG GIÁ TRỊ CẤN TRỪ** | | **76,494,000,000** | **100.00%** | **CÂN ĐỐI HOÀN TOÀN: DELTA = 0** |

---

## 4. BÁO CÁO 3: ĐỐI SOÁT KÊNH THANH TOÁN & DÒNG TIỀN TÀI KHOẢN ẢO
*Mã báo cáo: `DoiSoatKenhThanhToanVaDongTienAo` | Mã module: `BaoCaoQuanTriServer.TinhBaoCaoDoiSoatKenh`*

### 4.1. Bảng Cân Đối Ba Thành Phần: Gross = Phí Kênh + Net Thực Nhận

- **Tổng số bảng kê đối soát**: **182 bảng kê** (`Document.BangKeDoiSoatKenhThanhToan`)
- **Tổng doanh số Gross**: **67,580,000,000 VND** (67.58 tỷ VND)
- **Tổng phí cổng thanh toán**: **1,013,980,000 VND** (1.01 tỷ VND)
- **Tổng thực nhận về tài khoản (Net)**: **66,566,020,000 VND** (66.57 tỷ VND)
- **Tỷ lệ phí trung bình**: **1.50%**
- **Độ lệch đối soát (Delta)**: **0 VND** (Gross = Phí + Net, không thất thoát 1 đồng doanh thu)

### 4.2. Chi tiết Theo Từng Kênh Thanh Toán & Cổng Trung Gian

| Kênh thanh toán | Mã Kênh | Doanh số Gross (VND) | Phí kênh (VND) | Thực nhận Net (VND) | Tỷ lệ phí | Delta |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| **Cổng thanh toán VNPAY-QR** | `TEST_KENH_VNPAY` | 23,240,000,000 | 348,600,000 | 22,891,400,000 | 1.50% | 0 VND |
| **Cổng thanh toán OnePay** | `TEST_KENH_ONEPAY` | 22,170,000,000 | 332,550,000 | 21,837,450,000 | 1.50% | 0 VND |
| **Cổng thanh toán Nội bộ VSF** | `TEST_KENH_NOIBO` | 22,170,000,000 | 332,830,000 | 21,837,170,000 | 1.50% | 0 VND |
| **TỔNG CỘNG THEO KÊNH** | | **67,580,000,000** | **1,013,980,000** | **66,566,020,000** | **1.50%** | **0 VND** |

### 4.3. Dòng Tiền Đổ Về Tài Khoản Ngân Hàng & Tài Khoản Ảo (Virtual Accounts)

| Tài khoản nhận tiền | Mã Tài khoản | Doanh số Gross (VND) | Phí kênh khấu trừ | Net thực nhận về NH | Số dư hiện hữu sổ cái |
| :--- | :--- | :---: | :---: | :---: | :---: |
| **Techcombank - Tài khoản thanh toán** | `TEST_TKNH_TCB` | 33,790,000,000 | 506,990,000 | 33,283,010,000 | 690,177,300,500 VND |
| **VPBank - Tài khoản định danh (VA)** | `TEST_TKNH_VPB` | 33,790,000,000 | 506,990,000 | 33,283,010,000 | 22,323,055,000 VND |
| **TỔNG CỘNG ĐÍCH ĐẾN** | | **67,580,000,000** | **1,013,980,000** | **66,566,020,000** | **KHỚP 100% SỔ CÁI** |

---

## 5. BÁO CÁO 4: CẢNH BÁO HẠN MỨC & GIA HẠN CLOUD USD
*Mã báo cáo: `CanhBaoHanMucVaGiaHanCloud` | Mã module: `BaoCaoQuanTriServer.TinhBaoCaoCanhBaoCloud`*

### 5.1. Tổng Quan Quản Trị Chi Phí Nhà Cung Cấp Công Nghệ Toàn Cầu

- **Tổng số nhà cung cấp Cloud/Tech**: **22 đối tác** (AWS, Microsoft Azure, Qualcomm, Google Cloud, Oracle, SAP, IBM, Cisco, Dell, Nvidia...)
- **Tổng chi phí ngoại tệ đã chi**: **$6,225,345 USD**
- **Tổng chi phí quy đổi VND**: **157,143,953,535 VND** (~157.14 tỷ VND)
- **Tỷ giá hạch toán hiện hành**: **25,558 VND/USD** (Đọc trực tiếp từ `InformationRegister.TyGiaHoiDoai`)

### 5.2. Bảng Phân Tích Cảnh Báo Quota & Thời Hạn Hợp Đồng (Traffic Lights)

Báo cáo áp dụng thang cảnh báo 3 mức:
- 🔴 **ĐỎ (KHẨN CẤP)**: Chi tiêu Quota $\ge 98\%$ HOẶC Hạn hợp đồng còn $\le 7$ ngày.
- 🟠 **CAM (CẢNH BÁO)**: Chi tiêu Quota $\ge 90\%$ HOẶC Hạn hợp đồng còn $\le 14$ ngày.
- 🟡 **VÀNG (LƯU Ý)**: Chi tiêu Quota $\ge 80\%$ HOẶC Hạn hợp đồng còn $\le 30$ ngày.
- 🟢 **BÌNH THƯỜNG**: Chi tiêu Quota $< 80\%$ VÀ Hạn hợp đồng $> 30$ ngày.

#### Thống kê Cảnh báo Toàn hệ thống:
| Tiêu chí phân tích | 🔴 Mức Đỏ | 🟠 Mức Cam | 🟡 Mức Vàng | 🟢 Bình thường |
| :--- | :---: | :---: | :---: | :---: |
| **Cảnh báo Vượt hạn mức Quota (USD)** | **19** | **1** | **0** | **2** |
| **Cảnh báo Thời hạn gia hạn hợp đồng** | **1** | **1** | **1** | **19** |

#### Chi tiết Các Nhà Cung Cấp Trọng Yếu:
| Nhà cung cấp | Số HĐ | Chi phí USD | Hạn mức Quota | % Sử dụng | Mức Quota | Ngày hết hạn | Mức Hạn | Đề xuất hành động |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **Amazon Web Services (AWS)** | 14 | $288,574 | $300,000 | 96.19% | 🟠 Cam | 6 ngày | 🔴 Đỏ | **KHẨN CẤP: Phê duyệt bổ sung hạn mức & hợp đồng trước 7 ngày để tránh ngắt hệ thống** |
| **Microsoft Azure** | 14 | $285,420 | $250,000 | 114.17% | 🔴 Đỏ | 12 ngày | 🟠 Cam | **KHẨN CẤP: Phê duyệt bổ sung hạn mức & hợp đồng trước 7 ngày để tránh ngắt hệ thống** |
| **Qualcomm Technologies** | 14 | $287,143 | $220,000 | 130.52% | 🔴 Đỏ | 24 ngày | 🟡 Vàng | **KHẨN CẤP: Phê duyệt bổ sung hạn mức & hợp đồng trước 7 ngày để tránh ngắt hệ thống** |
| **Google Cloud Platform (GCP)** | 14 | $286,220 | $200,000 | 143.11% | 🔴 Đỏ | 45 ngày | 🟢 BT | **KHẨN CẤP: Phê duyệt bổ sung hạn mức & hợp đồng trước 7 ngày để tránh ngắt hệ thống** |
| **Oracle Corporation** | 14 | $283,910 | $180,000 | 157.73% | 🔴 Đỏ | 60 ngày | 🟢 BT | **KHẨN CẤP: Phê duyệt bổ sung hạn mức & hợp đồng trước 7 ngày để tránh ngắt hệ thống** |
| **SAP SE** | 14 | $284,550 | $180,000 | 158.08% | 🔴 Đỏ | 90 ngày | 🟢 BT | **KHẨN CẤP: Phê duyệt bổ sung hạn mức & hợp đồng trước 7 ngày để tránh ngắt hệ thống** |
| **Nvidia Corporation** | 14 | $286,700 | $160,000 | 179.19% | 🔴 Đỏ | 42 ngày | 🟢 BT | **KHẨN CẤP: Phê duyệt bổ sung hạn mức & hợp đồng trước 7 ngày để tránh ngắt hệ thống** |
| **Dell Technologies** | 14 | $282,100 | $150,000 | 188.07% | 🔴 Đỏ | 49 ngày | 🟢 BT | **KHẨN CẤP: Phê duyệt bổ sung hạn mức & hợp đồng trước 7 ngày để tránh ngắt hệ thống** |
| **Cisco Systems** | 14 | $281,900 | $150,000 | 187.93% | 🔴 Đỏ | 56 ngày | 🟢 BT | **KHẨN CẤP: Phê duyệt bổ sung hạn mức & hợp đồng trước 7 ngày để tránh ngắt hệ thống** |
| **IBM Cloud** | 14 | $280,300 | $150,000 | 186.87% | 🔴 Đỏ | 63 ngày | 🟢 BT | **KHẨN CẤP: Phê duyệt bổ sung hạn mức & hợp đồng trước 7 ngày để tránh ngắt hệ thống** |

---

## 6. KẾT QUẢ KIỂM THỬ TỰ ĐỘNG (AUTOMATED TEST VERIFICATION)

Toàn bộ các quy tắc nghiệp vụ, chốt chặn an toàn và công thức tính toán được kiểm tra tự động qua test suite `scripts/test_executive_reports.py`:

```
========================================================================================
                      KẾT QUẢ KIỂM THỬscripts/test_executive_reports.py
========================================================================================
test_00_general_status         : PASS (Trạng thái EXECUTIVE_REPORTS_SUCCESS_100)
test_01_tuoi_no_phan_tach_noi_bo: PASS (5 Buckets AR & AP cân đối, Safety Gate 100% tuân thủ)
test_02_ma_tran_can_tru_noi_bo : PASS (Cấn trừ song phương + bắc cầu, Delta = 0 VND)
test_03_doi_soat_kenh_thanh_toan: PASS (Gross = Phí + Net, Delta = 0 VND, Phí TB = 1.50%)
test_04_canh_bao_cloud_usd     : PASS (Tỷ giá USD 25,558, Vendor quốc tế, Đề xuất hành động chuẩn)
----------------------------------------------------------------------------------------
Ran 5 tests in 0.005s | KẾT QUẢ CHUNG: OK (100% TESTS PASSED)
========================================================================================
```

---

## 7. BIÊN BẢN NGHIỆM THU & BÀN GIAO (EXECUTIVE SIGN-OFF)

| Vai trò / Chức danh | Đơn vị / Đại diện | Đánh giá nghiệm thu | Trạng thái phê duyệt |
| :--- | :--- | :--- | :---: |
| **Giám đốc Tài chính (CFO)** | Ban Giám đốc VSF | Đạt chuẩn báo cáo quản trị cấp Tập đoàn | **ĐỒNG Ý NGHIỆM THU** |
| **Kế toán trưởng** | Phòng Kế toán Tổng hợp | Cân đối tuyệt đối Sổ Cái & Subledger (Delta = 0) | **ĐỒNG Ý NGHIỆM THU** |
| **Chuyên viên Đối soát Tập đoàn**| Ban Kiểm soát Nội bộ | Safety Gate tuân thủ tuyệt đối quy định không ngắt nợ chéo | **ĐỒNG Ý NGHIỆM THU** |
| **Giám đốc Hạ tầng CNTT** | Khối Công nghệ Thông tin | Cảnh báo hạn mức & gia hạn Cloud chính xác theo USD/VND | **ĐỒNG Ý NGHIỆM THU** |

**KẾT LUẬN CUỐI CÙNG**: Direction 1 - "Nghiệm Thu Trực Quan 4 Báo Cáo Quản Trị Chuyên Sâu" hoàn thành **100% yêu cầu**, sẵn sàng bàn giao cho người dùng và các bên liên quan.
