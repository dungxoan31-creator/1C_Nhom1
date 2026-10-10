# Task 2.3 Brief: Thư viện `QuanLyTyGiaVaNgoaiTeServer` - Tỷ Giá Xuất Quỹ BQGQ Di Động & Xử Lý Ngoại Tệ

## 1. Mục tiêu
Xây dựng CommonModule `QuanLyTyGiaVaNgoaiTeServer` (Server, ServerCall, ReturnValuesReuse: DontUse) phụ trách:
1. Tính tỷ giá xuất quỹ bình quân gia quyền (BQGQ) di động tại một thời điểm theo công thức:
   $$\text{Tỷ giá BQGQ} = \frac{\text{Số dư VND trên Sổ cái / Sổ Dòng tiền}}{\text{Số dư Ngoại tệ trên Sổ cái / Sổ Dòng tiền}}$$
2. Lọc bắt buộc theo 3 chiều dữ liệu và thời điểm: `PhapNhan`, `TaiKhoanTien`, `TienTe`, `ThoiDiem`.
3. Xử lý trường hợp biên: Khi số dư ngoại tệ $= 0$ (hoặc chưa từng phát sinh), hàm tự động tra cứu tỷ giá hạch toán hiệu lực gần nhất từ `InformationRegister.TyGiaHoiDoai.SliceLast(ThoiDiem, New Structure("TienTe", TienTe)).TyGiaHachToan`.
4. Hàm quy đổi số tiền ngoại tệ sang VND theo tỷ giá hạch toán / tỷ giá BQGQ: `QuyDoiNgoaiTeSangVND(SoTienNgoaiTe, TyGia)`.
5. Đảm bảo phân lập đa pháp nhân: VSF Corp và VSF Software cùng có tiền USD nhưng không bị tính lẫn số dư của nhau.

## 2. File tác động
- `tests/unit/CurrencyEngineTest.bsl` (New)
- `src/CommonModules/QuanLyTyGiaVaNgoaiTeServer.xml` (New)
- `src/CommonModules/QuanLyTyGiaVaNgoaiTeServer/Ext/Module.bsl` (New)

## 3. Chữ ký hàm bắt buộc trong `QuanLyTyGiaVaNgoaiTeServer`
```bsl
// Tinh ty gia xuat quy BQGQ di dong tai thoi diem
Function TinhTyGiaXuatQuyBQGQ(Val PhapNhan, Val TaiKhoanTien, Val TienTe, Val ThoiDiem) Export

// Quy doi so tien sang VND
Function QuyDoiNgoaiTeSangVND(Val SoTienNgoaiTe, Val TyGia) Export

// Lay ty gia hach toan gan nhat tu InformationRegister.TyGiaHoiDoai
Function LayTyGiaHachToanHieuLuc(Val TienTe, Val ThoiDiem) Export
```

## 4. Kịch bản kiểm thử `tests/unit/CurrencyEngineTest.bsl` (5 Test Cases)
1. **Test 1 (Số dư ngoại tệ 0):** Tài khoản USD chưa có số dư -> Trả về tỷ giá hạch toán từ `TyGiaHoiDoai` (ví dụ 25.350).
2. **Test 2 (Nhập USD lần 1):** Nhập 10.000 USD tỷ giá 25.000 (250tr VND) -> Tỷ giá BQGQ = 25.000.
3. **Test 3 (Nhập USD lần 2):** Nhập tiếp 10.000 USD tỷ giá 25.500 (255tr VND) -> Tổng dư: 20.000 USD, 505tr VND -> Tỷ giá BQGQ = 505.000.000 / 20.000 = 25.250 VND/USD.
4. **Test 4 (Xuất USD):** Xuất 5.000 USD trả nợ AWS -> Quy đổi ghi nhận theo đúng tỷ giá BQGQ 25.250 = 126.250.000 VND. Dư sau xuất: 15.000 USD và 378.750.000 VND (tỷ giá BQGQ giữ nguyên 25.250).
5. **Test 5 (Phân lập đa pháp nhân):** VSF Corp có 10.000 USD tỷ giá 25.000; VSF Software có 10.000 USD tỷ giá 26.000. Khi tính tỷ giá BQGQ cho VSF Corp, kết quả bắt buộc là 25.000, không bị hòa trộn số dư của VSF Software.

## 5. Báo cáo nghiệm thu
- Ghi báo cáo tại `.superpowers/sdd/2026-10-10-vinsmart-future-ar-ap/task-2.3-report.md`.
- Trả về: Trạng thái (DONE), danh sách file tạo mới, kết quả kiểm thử 5/5 test pass.
