# Task 2.4 Brief: Thư viện `PheDuyetDaCapServer` - Anti-Split Quét Hóa Đơn & Luồng Phê Duyệt 4+1 Cấp

## 1. Mục tiêu
Xây dựng CommonModule `PheDuyetDaCapServer` (Server, ServerCall, ReturnValuesReuse: DontUse) phụ trách logic phê duyệt chi tiêu AP cho VinSmart Future:
1. **Quy tắc phân cấp phê duyệt 4 cấp theo giá trị hóa đơn/đề nghị chi:**
   - Cấp 1 (`TruongBoPhan`): Giá trị $\le 100.000.000$ VND.
   - Cấp 2 (`KeToanTruong`): Giá trị $> 100.000.000$ VND và $\le 500.000.000$ VND.
   - Cấp 3 (`GiamDocKhoi`): Giá trị $> 500.000.000$ VND và $\le 2.000.000.000$ VND.
   - Cấp 4 (`TongGiamDoc`): Giá trị $> 2.000.000.000$ VND.
2. **Cơ chế phát hiện gian lận Anti-Split (Lách hạn mức):**
   - Quét tổng giá trị các hóa đơn mua dịch vụ phát sinh trong cùng tháng dương lịch của cùng một Nhà cung cấp và cùng Pháp nhân.
   - Nếu tổng lũy kế trong tháng (bao gồm cả hóa đơn hiện tại) vượt qua ngưỡng phê duyệt cao hơn, cấp phê duyệt của hóa đơn hiện tại TỰ ĐỘNG LEO THANG (Escalate) lên cấp tương ứng với tổng giá trị lũy kế!
   - *Ví dụ:* Hóa đơn 1 = 300tr (Kế toán trưởng duyệt). Hóa đơn 2 cùng tháng cho NCC đó = 250tr (lẻ ra chỉ cần KTT duyệt), nhưng tổng lũy kế $= 300tr + 250tr = 550tr > 500tr \rightarrow$ Leo thang lên Giám đốc khối (`GiamDocKhoi`) phê duyệt!
3. **Nhánh phê duyệt đặc biệt +1 (CFO Special Unlock):**
   - Kiểm tra ngân sách chi tiêu trong sổ `InformationRegister.KeHoachChiTien`.
   - Nếu số tiền chi tiêu thực tế/đã duyệt của Dự án/Khoản mục trong tháng vượt quá ngân sách $> 10\%$, hóa đơn bắt buộc phải có thêm chữ ký duyệt của Giám đốc Tài chính (`GiamDocTaiChinh_CFO`).

## 2. File tác động
- `tests/unit/PheDuyetDaCapTest.bsl` (New)
- `src/CommonModules/PheDuyetDaCapServer.xml` (New)
- `src/CommonModules/PheDuyetDaCapServer/Ext/Module.bsl` (New)

## 3. Chữ ký hàm bắt buộc trong `PheDuyetDaCapServer`
```bsl
// Xac dinh cap phe duyet co ban dua tren so tien
Function XacDinhCapPheDuyetTheoSoTien(Val SoTien) Export

// Tinh tong gia tri luy ke trong thang cua Nha cung cap de chong chia nho hoa don (Anti-Split)
Function TinhTongLuyKeTrongThang(Val PhapNhan, Val DoiTac, Val ThoiDiem) Export

// Xac dinh cap phe duyet cuoi cung sau khi kiem tra Anti-Split
Function XacDinhCapPheDuyetHoaDon(Val PhapNhan, Val DoiTac, Val SoTien, Val ThoiDiem) Export

// Kiem tra dieu kien vuot ngan sach > 10% de yeu cau CFO phe duyet (+1 Special Unlock)
Function KiemTraYeuCauDuyetCFO(Val PhapNhan, Val DuAn, Val KhoanMucDongTien, Val ThoiDiem, Val SoTienChi) Export
```

## 4. Kịch bản kiểm thử `tests/unit/PheDuyetDaCapTest.bsl` (5 Test Cases)
1. **Test 1 (Phân cấp cơ bản):**
   - 80tr $\rightarrow$ `TruongBoPhan`.
   - 250tr $\rightarrow$ `KeToanTruong`.
   - 1.2 tỷ $\rightarrow$ `GiamDocKhoi`.
   - 3.5 tỷ $\rightarrow$ `TongGiamDoc`.
2. **Test 2 (Anti-Split leo thang cấp duyệt):**
   - Hóa đơn 1 = 300tr trong tháng $\rightarrow$ `KeToanTruong`.
   - Hóa đơn 2 = 250tr cùng tháng cho cùng đối tác $\rightarrow$ Tổng lũy kế = 550tr $\rightarrow$ Leo thang lên `GiamDocKhoi` (thay vì chỉ KTT).
3. **Test 3 (Anti-Split vượt 2 tỷ):**
   - Lũy kế trước đó = 1.8 tỷ. Hóa đơn mới = 300tr $\rightarrow$ Tổng lũy kế = 2.1 tỷ $\rightarrow$ Leo thang lên `TongGiamDoc`.
4. **Test 4 (Phân lập đối tác & tháng khác nhau):**
   - Hóa đơn tháng trước không bị cộng dồn vào tháng này.
   - Hóa đơn của NCC khác không làm ảnh hưởng đến NCC hiện tại.
5. **Test 5 (Nhánh CFO Unlock khi vượt ngân sách > 10%):**
   - Ngân sách tháng = 100tr, đã duyệt 95tr. Hóa đơn mới = 16tr (tổng 111tr > 110tr = 110% ngân sách) $\rightarrow$ `YeuCauDuyetCFO = True`.
   - Ngân sách tháng = 100tr, đã duyệt 80tr. Hóa đơn mới = 25tr (tổng 105tr $\le$ 110tr) $\rightarrow$ `YeuCauDuyetCFO = False`.

## 5. Báo cáo nghiệm thu
- Ghi báo cáo tại `.superpowers/sdd/2026-10-10-vinsmart-future-ar-ap/task-2.4-report.md`.
- Trả về: Trạng thái (DONE), danh sách file tạo mới, kết quả kiểm thử 5/5 test pass.
