# CHÍNH SÁCH KẾ TOÁN & QUY CHẾ TÀI CHÍNH NĂM 2026
## CÔNG TY CỔ PHẦN VINSMART FUTURE (VSF)
**Số hiệu: CSKT-VSF-2026/01 | Ngày ban hành: 01/01/2026 | Kỳ áp dụng: 2025 - 2026**

---

### PHẦN I: CĂN CỨ PHÁP LÝ & NGUYÊN TẮC CHUNG
1. **Căn cứ pháp lý:**
   - Luật Kế toán số 88/2015/QH13 ngày 20/11/2015.
   - Chuẩn mực Kế toán Việt Nam (VAS), đặc biệt là VAS 10 (Ảnh hưởng của việc thay đổi tỷ giá hối đoái), VAS 14 (Doanh thu và thu nhập khác), VAS 16 (Chi phí đi vay).
   - Thông tư số 200/2014/TT-BTC hướng dẫn Chế độ kế toán doanh nghiệp.
   - Nghị định số 123/2020/NĐ-CP và Thông tư số 78/2021/TT-BTC về hóa đơn, chứng từ điện tử.
   - Thông tư số 99/2025/TT-BTC về quản lý tài chính doanh nghiệp công nghệ số.

2. **Đơn vị tiền tệ hạch toán & Kỳ kế toán:**
   - Đơn vị tiền tệ kế toán chính thức: Đồng Việt Nam (VND).
   - Ngoại tệ hạch toán phụ trợ: Đô la Mỹ (USD).
   - Kỳ kế toán triển khai UAT/Vận hành Go-Live chuẩn hóa: 638 ngày (từ 01/01/2025 đến 30/09/2026).

---

### PHẦN II: PHƯƠNG PHÁP TÍNH TOÁN KPI QUẢN TRỊ TÀI CHÍNH (DSO & DPO)
Nhằm phản ánh trung thực và đồng nhất năng lực luân chuyển vốn lưu động trong toàn bộ chu kỳ 638 ngày, chính sách kế toán VSF quy định công thức tính chỉ số DSO và DPO như sau:

1. **Số ngày thu tiền bình quân (Days Sales Outstanding - DSO):**
   $$\text{DSO} = \frac{\overline{\text{Công nợ phải thu AR (TK 131)}}}{\text{Tổng doanh thu thuần thuần ghi nhận trong kỳ}} \times 638 \text{ ngày}$$
   - **Chỉ tiêu mục tiêu 2026:** $\le 45$ ngày.
   - **Thực tế vận hành:** Đạt 40,5 ngày (vượt chuẩn kiểm soát).

2. **Số ngày trả tiền bình quân (Days Payable Outstanding - DPO):**
   $$\text{DPO} = \frac{\overline{\text{Công nợ phải trả AP (TK 331)}}}{\text{Tổng chi phí mua hàng & dịch vụ phát sinh trong kỳ}} \times 638 \text{ ngày}$$
   - **Chỉ tiêu mục tiêu 2026:** Từ 55 - 65 ngày.
   - **Thực tế vận hành:** Đạt 59,8 ngày (tối ưu hóa dòng tiền hoạt động).

3. **Chỉ số tiết kiệm chi phí dịch vụ thanh toán (Cost Savings):**
   - Tiết kiệm lũy kế thông qua cơ chế cấn trừ nội bộ Tập đoàn Vingroup và định tuyến phí tự động qua Virtual Account (VA) Techcombank/VPBank đạt 18,2 tỷ VND.

---

### PHẦN III: CHÍNH SÁCH QUẢN LÝ TỶ GIÁ & NGOẠI TỆ
1. **Nguyên tắc ghi nhận ban đầu:**
   - Các nghiệp vụ mua sắm dịch vụ đám mây (AWS, GCP, Azure, Oracle) hoặc phần mềm bản quyền bằng ngoại tệ (USD) được quy đổi sang VND theo tỷ giá thực tế tại thời điểm phát sinh giao dịch (tỷ giá bán của Ngân hàng thương mại nơi giao dịch).
   - Tỷ giá ghi nhận trên chứng từ gốc là tỷ giá hạch toán bắt buộc, không được làm tròn thô hoặc suy đoán.

2. **Xử lý chênh lệch tỷ giá phát sinh trong kỳ:**
   - Thanh toán nợ phải trả bằng ngoại tệ có chênh lệch tỷ giá:
     + Lãi tỷ giá hạch toán: Nợ TK 3313 / Có TK 515.
     + Lỗ tỷ giá hạch toán: Nợ TK 635 / Có TK 3313.

3. **Đánh giá lại số dư ngoại tệ cuối kỳ (30/09/2026):**
   - Đánh giá lại toàn bộ số dư tiền gửi ngân hàng ngoại tệ (TK 1122), công nợ phải thu ngoại tệ (TK 1313) và công nợ phải trả ngoại tệ (TK 3313).
   - Chênh lệch tỷ giá do đánh giá lại được phản ánh vào TK 4131 - Chênh lệch tỷ giá hối đoái đánh giá lại, sau đó kết chuyển toàn bộ vào TK 515 (nếu lãi thuần) hoặc TK 635 (nếu lỗ thuần) trước khi khóa sổ lập BCTC.

---

### PHẦN IV: NGUYÊN TẮC CẤN TRỪ CÔNG NỢ & ĐỐI SOÁT TỰ ĐỘNG
1. **Quy định về loại tiền tệ cấn trừ (Currency Matching Invariant):**
   - Bắt buộc đồng nhất loại tiền tệ giữa công nợ phải thu và công nợ phải trả ($\text{TienTe}_{\text{AR}} = \text{TienTe}_{\text{AP}}$).
   - Nghiêm cấm tuyệt đối hành vi cấn trừ chéo giữa các đồng tiền khác nhau khi chưa thực hiện chuyển đổi tỷ giá thành văn bản kế toán hợp lệ.
   - Sổ Cái SoCaiKeToan phải ghi nhận chính xác mã tiền tệ phát sinh và số tiền nguyên tệ tương ứng.

2. **Cấn trừ bắc cầu / đa bên (Tripartite Netting):**
   - Cấn trừ bắc cầu ba bên bắt buộc phải qua tài khoản trung gian TK 1388 (Phải thu khác).
   - Bắt buộc phải có Số văn bản thỏa thuận ba bên (`SoVanBanThoaThuan`) và được lưu trữ chứng từ điện tử đầy đủ trước khi kích hoạt ghi sổ.
   - Điền đầy đủ Analytic Keys (Đối tác nợ, Đối tác có, Hợp đồng nợ, Hợp đồng có) trên cả hai vế bút toán.

3. **Biểu phí cổng thanh toán & Đối soát tự động:**
   - Kênh OnePay: Áp dụng 1,5% cho thẻ ATM/tài khoản nội địa; 2,2% cho thẻ quốc tế (Visa/Mastercard/JCB).
   - Kênh Virtual Account (VA Techcombank / VPBank): Cố định 0,5% trên giá trị giao dịch đối soát tự động.

---

### PHẦN V: KIỂM SOÁT NỘI BỘ & PHÊ DUYỆT
1. **Nguyên tắc Maker-Checker:**
   - Người lập chứng từ (`NguoiLap`) tuyệt đối không được tự phê duyệt (`NguoiDuyet`).
   - Mọi chứng từ tài chính kế toán phải được phê duyệt bởi Kế toán trưởng hoặc Giám đốc Tài chính trước khi ghi sổ.
   - Tài khoản Admin hệ thống chỉ phục vụ cấu hình kỹ thuật, không có quyền ký duyệt bút toán kế toán.

2. **Hiệu lực thi hành:**
   - Chính sách này có hiệu lực áp dụng thống nhất trên toàn hệ thống phần mềm 1C:Enterprise ERP VSF kể từ ngày ký.

---

### PHÊ DUYỆT CHÍNH THỨC

| KẾ TOÁN TRƯỞNG | GIÁM ĐỐC TÀI CHÍNH (CFO) |
| :---: | :---: |
| *(Đã ký số điện tử)* | *(Đã ký số điện tử)* |
| **Nguyễn Văn Trưởng** | **Trần Quốc Cường** |
| Ngày duyệt: 01/01/2026 | Ngày duyệt: 01/01/2026 |
