# Đặc tả Thiết kế Giao diện ERP: "Modern 3D Enterprise" — VinSmart Future (VSF)

- **Dự án**: Hệ thống Kế toán Quản trị AR/AP, Netting & Sổ Cái VAS — VinSmart Future (VSF)
- **Nền tảng**: 1C:Enterprise 8.3 (Taxi UI, Managed Forms)
- **Phiên bản tài liệu**: 1.0 (Ngày 14/10/2026)
- **Phong cách thẩm mỹ**: Modern 3D Enterprise (Chiều sâu 3D, Soft Elevation, Ngôn ngữ Fintech cao cấp, Tương thích chuẩn 1C)

---

## 1. Hệ thống Design Tokens & Màu sắc (WCAG AA Compliant)

| Token | Mã HEX | Tên Style 1C (`StyleItem`) | Vai trò & Mục đích |
| :--- | :--- | :--- | :--- |
| **VSF Brand Red** | `#E4202A` | `MauChuDaoVSF` | Màu đỏ thương hiệu VSF, điểm nhấn header, logo, nút chính |
| **VSF Dark Red** | `#991B1B` | `MauCanhBaoDoVSF` | Nợ quá hạn > 90 ngày, rủi ro tài chính cao |
| **Metallic Slate** | `#475569` | `MauVienChinhVSF` | Đường viền phân cách, khung card kim loại titan |
| **Canvas Background** | `#F8FAFC` | `MauNenChinhVSF` | Nền ứng dụng sáng tuyết, khử sắc xám u tối mặc định |
| **Surface Container** | `#FFFFFF` | `MauNenPhuVSF` | Nền form, thẻ Card nổi, bảng biểu |
| **Deep Text** | `#0F172A` | `MauVanBanChinhVSF` | Chữ chính, số tiền (tương phản 15.8:1 trên nền trắng) |
| **Muted Text** | `#64748B` | `MauVanBanPhuVSF` | Nhãn trường, thông tin phụ |
| **Success Emerald** | `#059669` | `MauTrangThaiThanhCong`| Chứng từ đã duyệt, đã thanh toán, Sổ Cái cân đối |
| **Warning Amber** | `#D97706` | `MauCanhBaoVangVSF` | Quá hạn 1-60 ngày, Cloud USD vượt 80% hạn mức |
| **Draft Slate** | `#64748B` | `MauTrangThaiNhap` | Trạng thái nháp, chưa ghi sổ |

### Quy tắc tương phản & Định dạng số
1. **WCAG AA**: Độ tương phản chữ/nền tối thiểu 4.5:1 với văn bản thường, 3:1 với chữ lớn và thành phần điều khiển.
2. **Số tiền tài chính**: Bắt buộc dùng `tabular-nums` với định dạng `#,,##0.00` (hoặc phân cách dấu chấm theo kế toán Việt Nam `#.##0,00`).

---

## 2. Bố cục Kiến trúc Giao diện Hệ thống

### 2.1. Khung ứng dụng (`ClientApplicationInterface.xml`)
- **Sections Panel**: Đặt ở cạnh trái màn hình (`<left>`), hiển thị dạng thanh dọc hiện đại kèm logo và bộ icon 3D của 6 phân hệ.
- **Open Items Panel**: Đặt ở đỉnh (`<top>`), hiển thị dạng các thẻ tab cửa sổ đang mở.
- **Quick Menu / Favorites**: Cho phép ghim nhanh các chức năng thường dùng.

### 2.2. Bàn làm việc Lãnh đạo CFO (`DashboardLanhDaoCFO`)
- **Vị trí**: Đặt tại phân hệ Sổ Cái và Bàn làm việc chính của Ban Điều hành / CFO.
- **Thành phần**:
  1. *Hero Header*: Banner nhận diện VinSmart Future 3D, hiển thị thời điểm báo cáo và tình trạng phê duyệt chính sách kế toán (`PolicyApproved = True`).
  2. *Thẻ chỉ số tài chính (4 Thẻ KPI 3D)*:
     - **Tổng Phải thu AR**: 39.549.200.000 VND (chỉ báo biến động).
     - **Tổng Phải trả AP**: 34.440.537.922 VND (trong hạn mức chi trả).
     - **Tiền gửi khả dụng**: 817.817.013.237 VND (Techcombank VND + Vietcombank USD + VPBank VA).
     - **Tỷ lệ nợ quá hạn (>90 ngày)**: 10.1% (Cảnh báo quản trị).
  3. *Trực quan hóa Tuổi nợ (5 Buckets)*: Biểu đồ thanh 3D phân bổ Trong hạn, 1-30, 31-60, 61-90, >90 ngày.
  4. *Top 5 Khách hàng quá hạn & Ma trận Netting*: Bảng tóm lược tương tác.

### 2.3. Báo cáo & Bảng biểu: Tô màu có điều kiện (`Conditional Appearance`)
- Nợ quá hạn > 90 ngày: Nền đỏ nhạt (`#FEF2F2`), chữ đỏ đậm (`#991B1B`), in đậm (`Bold`).
- Nợ quá hạn 1-60 ngày: Chữ màu vàng hổ phách (`#D97706`).
- Đã tất toán / Đã duyệt: Chữ màu xanh ngọc (`#059669`).
- Số tiền âm / sai lệch: Bật `MarkNegatives` đổi màu đỏ.

---

## 3. Bản đồ triển khai kỹ thuật 1C:Enterprise 8.3

1. **Native 1C**:
   - `StyleItems`: Khai báo bộ màu chuẩn nhận diện.
   - `RegularGroup` (Horizontal/Vertical) + `Representation = StrongHighlight`.
   - `Pages` & `Page` với `TitleDataPath` tự động đếm số dòng.
   - `Conditional Appearance` trên danh sách và bảng dữ liệu.
   - `ShowUserNotification()` cho toast thông báo phi đồng bộ.
2. **Tài nguyên Đồ họa (`CommonPictures`)**:
   - Icon 3D chuẩn 48x48 px PNG Transparent cho 6 phân hệ.
   - `Splash.png` (800x500 px) cho màn hình chào.
3. **HTMLDocumentField**:
   - Tích hợp HTML5 / CSS Grid / SVG Charts vào trường `TrangDashboardHTML` của form `DashboardLanhDaoCFO` để đạt độ tinh xảo 3D vượt trội.
