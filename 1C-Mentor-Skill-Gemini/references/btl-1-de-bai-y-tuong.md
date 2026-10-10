# Tài liệu gộp: btl-1-de-bai-y-tuong

Gồm các mục: § de-bai-btl, § jet-cho-nguoi-trai-nganh, § ngan-hang-y-tuong


---

# § de-bai-btl

# Đề bài tập lớn ERP — Base 1C:Jet (tài liệu gốc của giảng viên)

> Nguồn: file "BTL ERP – Base 1C JET" do giảng viên Phạm Viết Quý soạn. Đây là đề chính thức; khi trả lời về yêu cầu, mức M1/M2/M3, thang điểm, bám đúng văn bản này.

# **Bản đồ cấu hình 1C:Jet**

Phần này mô tả những gì 1C:Jet đang có, đọc trực tiếp từ cấu hình. Sinh
viên cần nắm phần này trước khi chọn đề, vì mọi đề tài đều bắt đầu bằng
câu hỏi: **Jet gốc đã làm được gì, và còn thiếu gì cho doanh nghiệp của
nhóm?**

## **1.1. Các phân hệ nghiệp vụ**

+---------------+--------------------------+---------------------------+
| **Phân hệ**   | **Chứng từ và danh mục** | **Sổ và báo cáo**         |
+===============+==========================+===========================+
| **Purchases** | SupplierInvoice;         | Sổ Purchases,             |
|               | Counterparties,          | SupplierBalance; báo cáo  |
| Mua hàng      | Products, Units          | Purchases,                |
|               |                          | SupplierBalance           |
+---------------+--------------------------+---------------------------+
| **Sales**     | SalesInvoice;            | Sổ Sales,                 |
|               | Counterparties,          | CustomerBalance; báo cáo  |
| Bán hàng      | Products, Units; nhóm    | Sales, CustomerBalance,   |
|               | Pricing: PriceTypes, sổ  | ProfitOnSales, PriceList  |
|               | thông tin Prices         |                           |
+---------------+--------------------------+---------------------------+
| *             | InventoryIncrease,       | Sổ InventoryInWarehouses, |
| *Warehouses** | InventoryTransfer,       | InventoryCost; báo cáo    |
|               | InventoryWriteOff;       | AvailableStock,           |
| Kho           | Warehouses, Products,    | StockStatement            |
|               | Units                    |                           |
+---------------+--------------------------+---------------------------+
| **Cas         | CashReceipt, CashVoucher | Sổ CashBalance; báo cáo   |
| hManagement** | (tiền mặt); BankReceipt, | CashStatement             |
|               | BankPayment (ngân hàng); |                           |
| Tiền          | CashAccounts,            |                           |
|               | BankAccounts, Currencies |                           |
+---------------+--------------------------+---------------------------+
| **Company**   | Companies, Currencies,   | ---                       |
|               | VATRates                 |                           |
| Doanh nghiệp  |                          |                           |
+---------------+--------------------------+---------------------------+

## **1.2. Các sổ tích lũy**

Sổ tích lũy là nơi Jet ghi nhận "trạng thái" của doanh nghiệp. Sổ loại
Balances (số dư) trả lời câu hỏi "hiện có bao nhiêu"; sổ loại Turnovers
(doanh số) trả lời câu hỏi "trong kỳ đã phát sinh bao nhiêu".

  ----------------------------------------------------------------------------------
  **Sổ**                      **Loại**    **Chiều (phân tích      **Chỉ tiêu (đo
                                          theo)**                 lường)**
  --------------------------- ----------- ----------------------- ------------------
  **InventoryInWarehouses**   Balances    Product, Warehouse      Quantity

  **InventoryCost**           Balances    Product, Warehouse      Quantity, Amount

  **CustomerBalance**         Balances    LiabilityType,          Amount
                                          Counterparty, Document  

  **SupplierBalance**         Balances    LiabilityType,          Amount
                                          Counterparty, Document  

  **CashBalance**             Balances    BankCashAccount,        AmountCur
                                          CashType                

  **Purchases**               Turnovers   Counterparty, Product,  Quantity, Amount,
                                          PurchaseDocument        VATAmount

  **Sales**                   Turnovers   Counterparty, Product,  Quantity, Amount,
                                          SalesDocument           VATAmount
  ----------------------------------------------------------------------------------

## **1.3. Chứng từ nào ghi vào sổ nào**

Đây là bảng quan trọng nhất cho phương pháp "khai báo → nhập liệu → quan
sát hệ quả". Trước khi ghi sổ một chứng từ, cần nhìn vào hàng tương ứng
để dự đoán báo cáo nào sẽ thay đổi.

+--------------+--------+-------+-------+-----+------+-------+------+
| **Chứng từ** | **I    | **I   | **P   | **S | **Su | **    | **Ca |
|              | nvIn** | nvent | urcha | ale | ppli | Custo | sh** |
|              |        | ory** | ses** | s** | er** | mer** |      |
|              | **     |       |       |     |      |       | **B  |
|              | Wareho | **C   |       |     | **B  | *     | alan |
|              | uses** | ost** |       |     | alan | *Bala | ce** |
|              |        |       |       |     | ce** | nce** |      |
+==============+========+=======+=======+=====+======+=======+======+
| **Suppl      | ●      | ●     | ●     |     | ●    |       |      |
| ierInvoice** |        |       |       |     |      |       |      |
+--------------+--------+-------+-------+-----+------+-------+------+
| **Sa         | ●      | ●     |       | ●   |      | ●     |      |
| lesInvoice** |        |       |       |     |      |       |      |
+--------------+--------+-------+-------+-----+------+-------+------+
| **Invento    | ●      | ●     |       |     |      |       |      |
| ryIncrease** |        |       |       |     |      |       |      |
+--------------+--------+-------+-------+-----+------+-------+------+
| **Invento    | ●      | ●     |       |     |      |       |      |
| ryTransfer** |        |       |       |     |      |       |      |
+--------------+--------+-------+-------+-----+------+-------+------+
| **Invento    | ●      | ●     |       |     |      |       |      |
| ryWriteOff** |        |       |       |     |      |       |      |
+--------------+--------+-------+-------+-----+------+-------+------+
| **C          |        |       |       |     |      | ●     | ●    |
| ashReceipt** |        |       |       |     |      |       |      |
+--------------+--------+-------+-------+-----+------+-------+------+
| **B          |        |       |       |     |      | ●     | ●    |
| ankReceipt** |        |       |       |     |      |       |      |
+--------------+--------+-------+-------+-----+------+-------+------+
| **C          |        |       |       |     | ●    |       | ●    |
| ashVoucher** |        |       |       |     |      |       |      |
+--------------+--------+-------+-------+-----+------+-------+------+
| **B          |        |       |       |     | ●    |       | ●    |
| ankPayment** |        |       |       |     |      |       |      |
+--------------+--------+-------+-------+-----+------+-------+------+

*Chứng từ PricesSetupAuxiliary ghi vào sổ thông tin Prices (bảng giá
theo loại giá và mặt hàng, định kỳ theo ngày). Giá vốn tính theo phương
pháp bình quân.*

## **1.4. Những gì cấu hình gốc của JET chưa có**

Danh sách này là "nguyên liệu" cho các đề tài. Mọi điểm dưới đây đã được
đối chiếu với cấu hình:

> • **Không có sản xuất** --- không có chứng từ hay sổ nào cho định mức
> nguyên vật liệu, lệnh sản xuất. Nhánh sản xuất trong sơ đồ quy trình
> chung của khóa học không thực hiện được trên Jet.
>
> • **Không có chứng từ đặt hàng** ở cả hai chiều --- không có đơn mua,
> không có đơn bán. Jet ghi nhận việc đã xảy ra, chưa quản lý cam kết.
>
> • **Không theo dõi lô, hạn sử dụng, số serial** --- tồn kho chỉ phân
> tích theo mặt hàng và kho.
>
> • **Không có chiều Company trong sổ nào** --- có danh mục Companies
> nhưng số liệu không tách theo pháp nhân.
>
> • **Không có nhân viên kinh doanh, khu vực, hạn thanh toán, hạn mức
> nợ, khoản mục chi phí, định mức tồn kho.**

# **2. Quy định chung cho các nhóm**

## **2.1. Cách chia đề**

  --------------------------------------------------------------------------
  **Phân hệ**          **Đề A**                   **Đề B**
  -------------------- -------------------------- --------------------------
  **Warehouses**       Đề 1 --- Lô hàng và hạn sử Đề 2 --- Định mức tồn kho
                       dụng                       chuỗi cửa hàng

  **Purchases**        Đề 3 --- Đơn đặt hàng nhà  Đề 4 --- Đánh giá nhà cung
                       cung cấp                   cấp

  **Sales**            Đề 5 --- Chiết khấu theo   Đề 6 --- Nhân viên kinh
                       số lượng                   doanh và khu vực

  **CashManagement**   Đề 7 --- Hạn thanh toán và Đề 8 --- Khoản mục chi phí
                       tuổi nợ                    và ngân sách
  --------------------------------------------------------------------------

## **2.2. Nội dung sản phẩm phải nộp**

> 1\. **Hồ sơ doanh nghiệp giả định** --- tên, ngành, quy mô, danh mục
> mặt hàng, số kho, khách hàng và nhà cung cấp tiêu biểu, đặc thù vận
> hành. Nhóm được tự do sáng tạo trong khung gợi ý của đề.
>
> 2\. **Vận hành trên Jet gốc** --- khai báo dữ liệu nền cho doanh
> nghiệp của nhóm, nhập tối thiểu 15 chứng từ thuộc phân hệ được giao
> trong một tháng giả định, nộp nhật ký chứng từ và phiếu quan sát
> trước/sau cho ít nhất 5 chứng từ.
>
> 3\. **Phân tích khoảng trống** --- Jet gốc đáp ứng được gì, chưa đáp
> ứng được gì cho doanh nghiệp này. Mỗi khoảng trống phải gắn với một
> hậu quả nghiệp vụ cụ thể (mất tiền, mất hàng, chậm giao, ra quyết định
> sai...).
>
> 4\. **Phát triển thêm** --- thiết kế và, tùy mức, hiện thực các đối
> tượng mới. Bắt buộc có bảng thiết kế đối tượng: tên, loại đối tượng
> 1C, các trường, lý do chọn loại đối tượng đó. Các bạn tham khảo tài
> liệu làm việc với nền tảng 1C:Enterprise ( các ví dụ mẫu trong [[link
> này]{.underline}](https://docs.google.com/document/d/1jAWDZpT1_rzmsXI_edEQnJvwxhLlac5L-ntAwElu4-Y/edit?tab=t.0):
> phần 3 và tập trung phần 3.d ), phần này không yêu cầu bắt buộc, mình
> sẽ hướng dẫn các nhóm thực hiện, các nhóm có thể xây dựng ý tưởng
> trước.
>
> ***Các nhóm cần chuẩn bị***
>
> 1\. Báo cáo chính (Word/PDF/Slide): nhật ký chứng từ + phiếu quan
> sát + phân tích gap (so sánh giữa hai thứ: Nghiệp vụ thực tế của doanh
> nghiệp giả định với Khả năng hiện có của phần mềm Jet ) + đề xuất mở
> rộng
>
> **Nhật ký chứng từ** khác đối tượng Document Journal trong phần mềm.
> Đây là bảng các nhóm tự tạo để liệt kê các chứng từ đã nhập ví dụ như
> hình ảnh dưới:
>
> *(hình minh họa trong tài liệu gốc)*
>
> Tương tự như **phiếu quan sát** cũng do các nhóm tự tạo, là bảng ghi
> lại trạng thái báo cáo/register TRƯỚC và SAU khi ghi sổ (post) một
> chứng từ. Ví dụ như ảnh:
>
> *(hình minh họa trong tài liệu gốc)*
>
> 2\. File .dt kèm theo (nộp qua Google Drive/link)
>
> 3\. Phần Demo trực tiếp trên máy ( cho buổi báo cáo hoặc quay hình lại
> nếu như không có buổi này)

## **2.3. Ba mức phát triển**

Trong 1C:Jet, việc ghi sổ của mọi chứng từ được viết bằng mã nguồn
(module chung PostingManagement). Mỗi yêu cầu trong các đề được gắn một
mức:

  ------------------------------------------------------------------------
  **Mức**   **Tên**             **Phạm vi**
  --------- ------------------- ------------------------------------------
  **M1**    Đặc tả              Mô tả bằng văn bản, sơ đồ và bảng thiết kế
                                đối tượng. Không thao tác trong Designer.
                                Bắt buộc với mọi nhóm.

  **M2**    Khai báo trực quan  Tạo trong Designer bằng thao tác trực
                                quan: danh mục, liệt kê, thuộc tính mới
                                trên chứng từ hoặc danh mục, sổ thông tin
                                nhập tay, chứng từ mới không ghi sổ, phân
                                hệ, báo cáo DCS trên dữ liệu có sẵn. Không
                                viết mã.

  **M3**    Cần lập trình       Thêm chiều hoặc sổ tích lũy mới, sửa logic
                                ghi sổ, tự động hóa trên biểu mẫu.
  ------------------------------------------------------------------------

## **2.4. Thang điểm gợi ý**

  -----------------------------------------------------------------------
  **Tiêu chí**                            **Trọng số** **Ghi chú**
  --------------------------------------- ------------ ------------------
  Hồ sơ doanh nghiệp rõ ràng, nhất quán   10%          
  với dữ liệu nhập                                     

  Vận hành Jet gốc: đủ chứng từ, phiếu    25%          Kiểm tra trong
  quan sát đúng                                        infobase của nhóm

  Phân tích khoảng trống: gắn với hậu quả 25%          Trọng tâm của lớp
  nghiệp vụ                                            Logistics

  Thiết kế đối tượng: đúng loại đối       25%          M1 + M2
  tượng, có lý do                                      

  Trình bày và trả lời câu hỏi phân tích  15%          
  của đề                                               

  Điểm cộng: hạng mục M3 hoạt động được   +10%         Tối đa
  -----------------------------------------------------------------------

# **3. Đề tài**

## **Đề 1 --- Lô hàng và hạn sử dụng**

  -----------------------------------------------------------------------
  **Phân hệ**        Warehouses
  ------------------ ----------------------------------------------------
  **Doanh nghiệp gợi Công ty phân phối thực phẩm khô (mì, đồ hộp, bánh
  ý**                kẹo) với 2 kho, khoảng 40 mặt hàng. Mỗi lần nhập
                     hàng là một lô có hạn sử dụng khác nhau; mỗi tháng
                     công ty hủy một lượng hàng hết hạn đáng kể.

  -----------------------------------------------------------------------

**Jet gốc đang có**

> • Danh mục Warehouses, Products (có ProductType: Inventory/Service)
>
> • Chứng từ InventoryIncrease, InventoryTransfer, InventoryWriteOff;
> SupplierInvoice và SalesInvoice đều có trường Warehouse
>
> • Sổ InventoryInWarehouses và InventoryCost, cùng phân tích theo
> Product và Warehouse
>
> • Báo cáo AvailableStock, StockStatement

**Khoảng trống nghiệp vụ**

Tồn kho không phân biệt lô. Công ty không biết lô nào sắp hết hạn, không
áp dụng được nguyên tắc hết hạn trước --- xuất trước (FEFO).

**Yêu cầu phát triển**

  ------------------------------------------------------------------------
  **Hạng mục**                            **Loại đối tượng**   **Mức**
  --------------------------------------- -------------------- -----------
  Danh mục Lô hàng, cấp dưới của          Catalog              **M2**
  Products, với thuộc tính Ngày sản xuất,                      
  Hạn sử dụng                                                  

  Cột Lô hàng trong phần bảng Inventory   Thuộc tính phần bảng **M2**
  của SupplierInvoice, InventoryIncrease,                      
  SalesInvoice, InventoryWriteOff                              

  Danh sách lô lọc theo hạn sử dụng còn   Báo cáo DCS trên     **M2**
  dưới N ngày                             danh mục             

  Thêm chiều Lô hàng vào                  Sửa sổ + ghi sổ      **M3**
  InventoryInWarehouses; xử lý                                 
  InventoryCost                                                

  Báo cáo tồn kho theo lô và hạn sử dụng  Báo cáo DCS trên sổ  **M3**
  ------------------------------------------------------------------------

**Câu hỏi phân tích bắt buộc**

> 1\. Jet tính giá vốn bình quân theo mặt hàng và kho. Nếu theo dõi lô,
> có cần tính giá vốn theo lô không? Vì sao?
>
> 2\. Có nên thêm chiều Lô vào cả InventoryCost hay chỉ
> InventoryInWarehouses? Hệ quả của mỗi lựa chọn là gì?
>
> 3\. Khi hủy hàng hết hạn, nhóm dùng chứng từ nào của Jet? Chứng từ đó
> đang thiếu thông tin gì?

## **Đề 2 --- Định mức tồn kho chuỗi cửa hàng**

  -----------------------------------------------------------------------
  **Phân hệ**        Warehouses
  ------------------ ----------------------------------------------------
  **Doanh nghiệp gợi Chuỗi 5 cửa hàng tiện lợi và 1 kho tổng tại Hà Nội.
  ý**                Hàng được nhập về kho tổng rồi điều chuyển xuống cửa
                     hàng. Cửa hàng thường xuyên hết hàng bán chạy trong
                     khi kho tổng tồn nhiều.

  -----------------------------------------------------------------------

**Jet gốc đang có**

> • Chứng từ InventoryTransfer với Warehouse (kho xuất) và
> WarehouseReceiver (kho nhận)
>
> • Sổ InventoryInWarehouses theo Product, Warehouse
>
> • Báo cáo AvailableStock, StockStatement
>
> • Danh mục Warehouses không có thuộc tính nghiệp vụ riêng (chỉ có
> thông tin liên hệ và thuộc tính bổ sung)

**Khoảng trống nghiệp vụ**

Không có định mức tồn tối thiểu và tối đa theo từng cửa hàng. Việc điều
chuyển dựa vào cảm tính của quản lý, không có cảnh báo.

**Yêu cầu phát triển**

  ------------------------------------------------------------------------
  **Hạng mục**                           **Loại đối tượng**    **Mức**
  -------------------------------------- --------------------- -----------
  Sổ thông tin Định mức tồn kho: chiều   Information Register  **M2**
  Warehouse, Product; chỉ tiêu Tồn tối                         
  thiểu, Tồn tối đa                                            

  Thuộc tính Loại kho (Kho tổng / Cửa    Enumeration + thuộc   **M2**
  hàng) trên Warehouses, dùng liệt kê    tính                  

  Báo cáo so sánh tồn thực tế với định   Báo cáo DCS           **M2**
  mức, đánh dấu dưới mức tối thiểu                             

  Tự tạo InventoryTransfer đề xuất từ    Xử lý dữ liệu         **M3**
  báo cáo cảnh báo                                             
  ------------------------------------------------------------------------

**Câu hỏi phân tích bắt buộc**

> 1\. Định mức nên cố định hay thay đổi theo mùa? Nếu thay đổi, sổ thông
> tin cần đặt định kỳ không?
>
> 2\. Tại sao định mức là sổ thông tin mà không phải thuộc tính của danh
> mục Products?
>
> 3\. Từ số liệu tháng giả định, cửa hàng nào điều chuyển nhiều nhất?
> Điều đó nói gì về việc đặt định mức?

## **Đề 3 --- Đơn đặt hàng nhà cung cấp**

  -----------------------------------------------------------------------
  **Phân hệ**        Purchases
  ------------------ ----------------------------------------------------
  **Doanh nghiệp gợi Doanh nghiệp nhập khẩu thiết bị điện gia dụng, đặt
  ý**                hàng trước 2--6 tuần, thường nhận hàng thành nhiều
                     đợt. Bộ phận mua hàng cần biết hàng nào đã đặt nhưng
                     chưa về để không đặt trùng.

  -----------------------------------------------------------------------

**Jet gốc đang có**

> • Chứng từ SupplierInvoice (Supplier, Warehouse, Currency, phần bảng
> Inventory, AdvanceClearing)
>
> • SupplierInvoice ghi vào 4 sổ: InventoryInWarehouses, InventoryCost,
> Purchases, SupplierBalance
>
> • Không có chứng từ đặt hàng nhà cung cấp

**Khoảng trống nghiệp vụ**

Jet chỉ ghi nhận hàng đã về. Không phân biệt được hàng đã đặt, hàng đang
về, hàng đã nhận đủ.

**Yêu cầu phát triển**

  ------------------------------------------------------------------------
  **Hạng mục**                           **Loại đối tượng**    **Mức**
  -------------------------------------- --------------------- -----------
  Chứng từ Đơn đặt hàng nhà cung cấp:    Document (không ghi   **M2**
  Supplier, Warehouse, Ngày giao dự      sổ)                   
  kiến, phần bảng hàng hóa                                     

  Liệt kê Trạng thái đơn: Mới / Đã xác   Enumeration           **M2**
  nhận / Nhận một phần / Nhận đủ / Hủy                         

  Thuộc tính "Theo đơn đặt hàng" trên    Thuộc tính            **M2**
  SupplierInvoice                                              

  Sổ Hàng đặt chưa về: đơn đặt hàng ghi  Accumulation Register **M3**
  tăng, SupplierInvoice ghi giảm                               

  Báo cáo đơn chưa hoàn thành theo nhà   Báo cáo DCS           **M3**
  cung cấp                                                     
  ------------------------------------------------------------------------

**Câu hỏi phân tích bắt buộc**

> 1\. Sổ Hàng đặt chưa về nên là Balances hay Turnovers? Giải thích bằng
> câu hỏi nghiệp vụ mà sổ phải trả lời.
>
> 2\. Đơn đặt hàng có nên ghi vào InventoryInWarehouses không? Vì sao
> không?
>
> 3\. Nếu nhà cung cấp giao thiếu và không giao bù, trạng thái đơn và số
> liệu trong sổ phải xử lý thế nào?

## **Đề 4 --- Đánh giá nhà cung cấp**

  -----------------------------------------------------------------------
  **Phân hệ**        Purchases
  ------------------ ----------------------------------------------------
  **Doanh nghiệp gợi Công ty thương mại vật liệu xây dựng mua cùng một
  ý**                mặt hàng (xi măng, thép) từ 3 nhà cung cấp với giá
                     và độ tin cậy giao hàng khác nhau. Ban giám đốc muốn
                     có căn cứ chọn nguồn cung.

  -----------------------------------------------------------------------

**Jet gốc đang có**

> • Danh mục Counterparties với cờ Supplier
>
> • Sổ Purchases (Turnovers): Counterparty, Product, PurchaseDocument;
> Quantity, Amount, VATAmount
>
> • Báo cáo Purchases
>
> • Lưu ý: thuộc tính PriceType trên Counterparties là loại giá **bán**
> cho khách hàng (SalesInvoice tự điền từ đây), không phải bảng giá mua

**Khoảng trống nghiệp vụ**

Sổ Purchases cho biết đã mua bao nhiêu và giá bao nhiêu, nhưng không có
tiêu chí thời gian giao hàng, cam kết cung ứng hay xếp hạng.

**Yêu cầu phát triển**

  ------------------------------------------------------------------------
  **Hạng mục**                           **Loại đối tượng**    **Mức**
  -------------------------------------- --------------------- -----------
  Báo cáo giá mua bình quân theo nhà     Báo cáo DCS           **M2**
  cung cấp × mặt hàng (Amount /                                
  Quantity) từ sổ Purchases                                    

  Sổ thông tin Cam kết cung ứng:         Information Register  **M2**
  Counterparty, Product; Thời gian giao                        
  cam kết (ngày), Số lượng đặt tối thiểu                       

  Thuộc tính Ngày hẹn giao trên          Thuộc tính + Báo cáo  **M2**
  SupplierInvoice; báo cáo tỷ lệ giao    DCS                   
  đúng hẹn                                                     

  Liệt kê Xếp hạng nhà cung cấp (A/B/C)  Enumeration + thuộc   **M2**
  và thuộc tính trên Counterparties      tính                  
  ------------------------------------------------------------------------

**Câu hỏi phân tích bắt buộc**

> 1\. Nhóm đề xuất trọng số nào giữa giá, thời gian giao và độ tin cậy?
> Kết quả xếp hạng thay đổi thế nào nếu đổi trọng số?
>
> 2\. Xếp hạng nên là liệt kê hay danh mục? Khi nào doanh nghiệp cần đổi
> sang danh mục?
>
> 3\. Đề này và Đề 3 bổ sung cho nhau thế nào? Nếu có đơn đặt hàng, Ngày
> hẹn giao nên nằm ở đâu?

## **Đề 5 --- Chiết khấu theo số lượng**

  -----------------------------------------------------------------------
  **Phân hệ**        Sales
  ------------------ ----------------------------------------------------
  **Doanh nghiệp gợi Nhà phân phối nước giải khát bán cho đại lý cấp 1,
  ý**                cấp 2 và cửa hàng lẻ. Đại lý mua càng nhiều thùng
                     thì được chiết khấu càng cao, theo bậc.

  -----------------------------------------------------------------------

**Jet gốc đang có**

> • Danh mục PriceTypes; sổ thông tin Prices (PriceType, Product →
> Price), định kỳ theo ngày
>
> • Chứng từ PricesSetupAuxiliary để cập nhật giá hàng loạt
>
> • Counterparties có thuộc tính PriceType; khi chọn khách trên
> SalesInvoice, loại giá được tự điền và giá được điền lại
>
> • Báo cáo PriceList

**Khoảng trống nghiệp vụ**

Jet đã giải quyết tốt giá theo nhóm khách. Điều còn thiếu là chiết khấu
theo khối lượng mua trên từng đơn.

**Yêu cầu phát triển**

  ------------------------------------------------------------------------
  **Hạng mục**                           **Loại đối tượng**    **Mức**
  -------------------------------------- --------------------- -----------
  Sổ thông tin Bậc chiết khấu:           Information Register  **M2**
  PriceType, Product, Số lượng tối                             
  thiểu; chỉ tiêu % chiết khấu                                 

  Cột % chiết khấu trên phần bảng        Thuộc tính phần bảng  **M2**
  Inventory của SalesInvoice (nhập tay)                        

  Tự áp chiết khấu khi nhập số lượng     Mã trên biểu mẫu      **M3**

  Báo cáo doanh thu trước và sau chiết   Sửa sổ Sales + báo    **M3**
  khấu                                   cáo                   
  ------------------------------------------------------------------------

**Câu hỏi phân tích bắt buộc**

> 1\. Vì sao sổ Prices được đặt định kỳ theo ngày? Điều gì xảy ra với
> hóa đơn cũ khi giá thay đổi?
>
> 2\. Chiết khấu nên phụ thuộc vào loại giá, vào khách hàng cụ thể, hay
> cả hai?
>
> 3\. Nếu chiết khấu chỉ nhập tay, rủi ro kiểm soát nội bộ là gì?

## **Đề 6 --- Nhân viên kinh doanh và khu vực**

  -----------------------------------------------------------------------
  **Phân hệ**        Sales
  ------------------ ----------------------------------------------------
  **Doanh nghiệp gợi Công ty phân phối dược mỹ phẩm có 8 nhân viên kinh
  ý**                doanh phụ trách 3 miền. Hoa hồng được tính theo
                     doanh số của từng người, và ban giám đốc cần doanh
                     số theo vùng.

  -----------------------------------------------------------------------

**Jet gốc đang có**

> • Chứng từ SalesInvoice: Customer, Warehouse, PriceType, Author,
> Total...
>
> • Sổ Sales: Counterparty, Product, SalesDocument; báo cáo Sales,
> ProfitOnSales
>
> • Lưu ý: Author là người tạo chứng từ, không phải người bán

**Khoảng trống nghiệp vụ**

Không gắn được đơn bán với nhân viên kinh doanh hay khu vực, nên không
tính được hoa hồng và không phân tích được theo vùng.

**Yêu cầu phát triển**

  ------------------------------------------------------------------------
  **Hạng mục**                           **Loại đối tượng**    **Mức**
  -------------------------------------- --------------------- -----------
  Danh mục Khu vực, phân cấp Miền → Tỉnh Catalog               **M2**
                                         (hierarchical)        

  Danh mục Nhân viên kinh doanh: Khu vực Catalog               **M2**
  phụ trách, Tỷ lệ hoa hồng                                    

  Thuộc tính Khu vực trên                Thuộc tính            **M2**
  Counterparties; Nhân viên kinh doanh                         
  trên SalesInvoice                                            

  Báo cáo doanh số theo nhân viên và khu Báo cáo DCS           **M2**
  vực, đọc từ chứng từ SalesInvoice                            

  Thêm chiều Nhân viên, Khu vực vào sổ   Sửa sổ + ghi sổ       **M3**
  Sales                                                        
  ------------------------------------------------------------------------

**Câu hỏi phân tích bắt buộc**

> 1\. Khu vực nên gắn vào khách hàng hay vào từng hóa đơn? Nếu khách
> chuyển sang vùng khác, doanh số cũ tính cho vùng nào?
>
> 2\. Báo cáo đọc từ chứng từ khác gì báo cáo đọc từ sổ? Khi nào cách
> thứ nhất không đủ?
>
> 3\. Tỷ lệ hoa hồng thay đổi theo thời gian thì nên lưu ở đâu?

## **Đề 7 --- Hạn thanh toán và tuổi nợ**

  -----------------------------------------------------------------------
  **Phân hệ**        CashManagement
  ------------------ ----------------------------------------------------
  **Doanh nghiệp gợi Công ty cung cấp văn phòng phẩm cho doanh nghiệp,
  ý**                bán chịu 30--60 ngày. Nợ quá hạn ngày càng tăng và
                     công ty không biết khách nào cần dừng bán.

  -----------------------------------------------------------------------

**Jet gốc đang có**

> • Sổ CustomerBalance: LiabilityType (Liability = nợ phải thu / Advance
> = tiền ứng trước), Counterparty, Document; Amount
>
> • CashReceipt, BankReceipt có phần bảng PaymentDetails (Document,
> PaymentAmount, Amount) để thu tiền theo từng hóa đơn
>
> • SalesInvoice có phần bảng AdvanceClearing để cấn trừ tiền ứng trước
>
> • Báo cáo CustomerBalance (thuộc phân hệ Sales)

**Khoảng trống nghiệp vụ**

Sổ theo dõi được còn nợ bao nhiêu trên từng hóa đơn, nhưng không có hạn
thanh toán, nên không biết khoản nào quá hạn và quá hạn bao lâu. Không
có hạn mức nợ.

**Yêu cầu phát triển**

  -----------------------------------------------------------------------
  **Hạng mục**                           **Loại đối tượng**   **Mức**
  -------------------------------------- -------------------- -----------
  Sổ thông tin Điều khoản thanh toán:    Information Register **M2**
  Counterparty; Số ngày được nợ, Hạn mức                      
  nợ; định kỳ                                                 

  Thuộc tính Hạn thanh toán trên         Thuộc tính           **M2**
  SalesInvoice                                                

  Báo cáo tuổi nợ: số dư CustomerBalance Báo cáo DCS          **M3**
  theo hóa đơn, chia nhóm Chưa đến hạn /                      
  1--30 / 31--60 / trên 60 ngày                               

  Cảnh báo hoặc chặn bán khi khách vượt  Mã ghi sổ            **M3**
  hạn mức nợ                                                  
  -----------------------------------------------------------------------

**Câu hỏi phân tích bắt buộc**

> 1\. Vì sao CustomerBalance cần chiều Document? Nếu bỏ chiều này thì
> mất khả năng phân tích gì?
>
> 2\. Tiền khách ứng trước (Advance) có tính vào tuổi nợ không?
>
> 3\. Chặn bán hay chỉ cảnh báo khi vượt hạn mức --- ai trong doanh
> nghiệp nên có quyền vượt?

## **Đề 8 --- Khoản mục chi phí và ngân sách**

  -----------------------------------------------------------------------
  **Phân hệ**        CashManagement
  ------------------ ----------------------------------------------------
  **Doanh nghiệp gợi Công ty dịch vụ vận tải nội địa có nhiều khoản chi
  ý**                vận hành: nhiên liệu, cầu đường, sửa chữa, lương tài
                     xế, thuê bãi. Kế toán không trả lời được tháng này
                     chi bao nhiêu cho nhiên liệu so với kế hoạch.

  -----------------------------------------------------------------------

**Jet gốc đang có**

> • CashVoucher, BankPayment có thuộc tính Operation, là liệt kê chỉ có
> 2 giá trị: Supplier và Other
>
> • Sổ CashBalance: BankCashAccount, CashType (Cash/NonCash); AmountCur
>
> • Báo cáo CashStatement

**Khoảng trống nghiệp vụ**

Mọi khoản chi không trả nhà cung cấp đều rơi vào "Other", không phân
loại được mục đích chi.

**Yêu cầu phát triển**

  ------------------------------------------------------------------------
  **Hạng mục**                           **Loại đối tượng**    **Mức**
  -------------------------------------- --------------------- -----------
  Danh mục Khoản mục chi phí, phân cấp   Catalog               **M2**
  (Vận hành → Nhiên liệu, Cầu đường...)  (hierarchical)        

  Thuộc tính Khoản mục trên CashVoucher, Thuộc tính            **M2**
  BankPayment, dùng khi Operation =                            
  Other                                                        

  Sổ thông tin Ngân sách: Khoản mục; Số  Information Register  **M2**
  tiền; định kỳ theo tháng                                     

  Báo cáo chi phí thực tế theo khoản     Báo cáo DCS           **M2**
  mục, đọc từ chứng từ chi                                     

  Sổ Chi phí (Turnovers) và báo cáo kế   Accumulation Register **M3**
  hoạch -- thực tế                                             
  ------------------------------------------------------------------------

**Câu hỏi phân tích bắt buộc**

> 1\. Operation là liệt kê, còn Khoản mục chi phí nhóm chọn là danh mục.
> Tiêu chí nào để chọn giữa hai loại này?
>
> 2\. Một khoản chi trả nhà cung cấp (Operation = Supplier) có cần gắn
> khoản mục không?
>
> 3\. Nếu ngân sách thay đổi giữa năm, sổ thông tin định kỳ giúp giữ
> lịch sử thế nào?

##  **Đề 9 --- Kiểm kê kho và xử lý chênh lệch**

  -----------------------------------------------------------------------
  **Phân hệ**        Warehouses
  ------------------ ----------------------------------------------------
  **Doanh nghiệp gợi Nhà phân phối phụ tùng xe máy có 1 kho chính khoảng
  ý**                300 mã hàng, nhiều mã nhỏ, giá trị thấp, dễ thất
                     lạc. Cuối mỗi quý công ty kiểm kê toàn bộ kho; lần
                     gần nhất lệch hàng chục mã nhưng không ai giải thích
                     được nguyên nhân.

  -----------------------------------------------------------------------

**Jet gốc đang có**

> • Chứng từ InventoryIncrease (Warehouse; phần bảng Product, Quantity,
> Price, Amount) --- thiết kế ban đầu để nhập tồn đầu kỳ
>
> • Chứng từ InventoryWriteOff (Warehouse; phần bảng Product, Quantity)
> --- không có đơn giá, không có lý do xuất hủy
>
> • Cả hai ghi vào InventoryInWarehouses và InventoryCost; giá trị hàng
> giảm lấy theo giá vốn bình quân
>
> • Báo cáo StockStatement, AvailableStock cho số lượng sổ sách
>
> • Không có chứng từ kiểm kê

**Khoảng trống nghiệp vụ**

Jet điều chỉnh được tồn kho nhưng không lưu lại cuộc kiểm kê: không có
số sổ sách và số thực tế đặt cạnh nhau, không biết điều chỉnh nào xuất
phát từ lần kiểm kê nào, và không phân biệt được hao hụt tự nhiên, mất
mát hay nhập sai.

**Yêu cầu phát triển**

  ------------------------------------------------------------------------
  **Hạng mục**                            **Loại đối tượng**   **Mức**
  --------------------------------------- -------------------- -----------
  Chứng từ Phiếu kiểm kê: Warehouse,      Document (không ghi  **M2**
  Người kiểm, phần bảng Product, SL sổ    sổ)                  
  sách, SL thực tế, Chênh lệch                                 

  Liệt kê Lý do chênh lệch: Hao hụt tự    Enumeration + thuộc  **M2**
  nhiên / Mất mát / Hư hỏng / Nhập xuất   tính phần bảng       
  sai; cột Lý do trên Phiếu kiểm kê                            

  Thuộc tính "Theo phiếu kiểm kê" và Lý   Thuộc tính           **M2**
  do trên InventoryIncrease,                                   
  InventoryWriteOff                                            

  Báo cáo tổng hợp chênh lệch theo lý do  Báo cáo DCS          **M2**
  và mặt hàng qua các kỳ kiểm kê                               

  Tự điền SL sổ sách từ                   Mã trên chứng từ     **M3**
  InventoryInWarehouses; tự tạo                                
  InventoryIncrease/WriteOff từ phiếu                          
  ------------------------------------------------------------------------

**Câu hỏi phân tích bắt buộc**

> 1\. Phiếu kiểm kê có nên tự ghi sổ tồn kho không? Vì sao doanh nghiệp
> thường tách "ghi nhận kết quả kiểm" và "điều chỉnh sổ" thành hai bước?
>
> 2\. InventoryWriteOff không có đơn giá. Giá trị hàng thiếu được xác
> định từ đâu, và điều đó ảnh hưởng thế nào đến báo cáo lợi nhuận?
>
> 3\. Nếu kho vẫn nhập xuất trong lúc kiểm, SL sổ sách phải lấy tại thời
> điểm nào? Nhóm đề xuất quy trình gì để tránh sai lệch?


---

# § jet-cho-nguoi-trai-nganh

# Jet cho người trái ngành — hướng dẫn bài tập lớn cho nhóm 2

Khi nào đọc file này: người hỏi thuộc **nhóm 2 — trái ngành** (ví dụ sinh viên Logistics, kế toán, quản trị) đang làm bài tập lớn trên 1C:Jet: cần hiểu Jet từ góc nghiệp vụ, chuẩn bị dữ liệu và lập **nhật ký chứng từ / phiếu quan sát**, tùy biến mức **M2** trong Designer, hoặc cần một đoạn code đơn giản (M3 nhẹ) kèm giải thích bằng lời thường. Đề bài gốc: `references/btl-1-de-bai-y-tuong.md#de-bai-btl`. Nhóm có nền IT (nhóm 1) thì không dùng mục 5 của file này mà theo cách gợi ý-trước trong SKILL.md.

Phiên bản Jet được mô tả: repo `1Ci-Company/Jet`, nhánh `community`, commit `80884de`, configuration 1.0.2.1. Code trích từ Jet ghi nguồn `Nguồn: Jet — cf/...` — bản quyền **1C:Jet (MIT)**. Thao tác Designer lấy từ ghi chú bài giảng `references/lessons-*.md`; chỗ nào ghi chú không có tên nút thì ghi "(tên nút/menu có thể khác theo phiên bản — kiểm tra trên máy)".

Triết lý của file: **nghiệp vụ trước, thuật ngữ sau** — mỗi khái niệm được giải thích bằng chuyện thật ở công ty trước, thuật ngữ 1C để trong ngoặc. Phương pháp: **khai báo → nhập liệu → quan sát hệ quả**.

## Mục lục

1. [Jet nhìn từ góc nghiệp vụ](#1-jet-nhìn-từ-góc-nghiệp-vụ)
2. [Phương pháp "khai báo → nhập liệu → quan sát hệ quả"](#2-phương-pháp-khai-báo--nhập-liệu--quan-sát-hệ-quả)
3. [Quy tắc an toàn trước khi tùy biến](#3-quy-tắc-an-toàn-trước-khi-tùy-biến)
4. [Hướng dẫn M2 từng bước](#4-hướng-dẫn-m2-từng-bước)
5. [Code đơn giản kèm giải thích (M3 nhẹ)](#5-code-đơn-giản-kèm-giải-thích-m3-nhẹ)
6. [Khi nào cần gọi tutor](#6-khi-nào-cần-gọi-tutor)

---

## 1. Jet nhìn từ góc nghiệp vụ

### 1.1. Bốn phân hệ là bốn khâu của một vòng tiền – hàng

Một công ty thương mại nhỏ chạy theo vòng: **mua hàng → hàng nằm trong kho → bán hàng → thu tiền / trả tiền**. Jet chia đúng bốn khâu đó thành bốn phân hệ (subsystem — mỗi phân hệ là một mục trên thanh menu bên trái):

```
  Nhà cung cấp                                                   Khách hàng
       │  hàng về                                                    ▲ giao hàng
       ▼                                                             │
 [Purchases — Mua hàng] ──► [Warehouses — Kho] ──► [Sales — Bán hàng]
   SupplierInvoice          InventoryIncrease        SalesInvoice
       │ nợ NCC tăng        InventoryTransfer             │ khách nợ tăng
       │                    InventoryWriteOff             │
       ▼                                                  ▼
 [CashManagement — Tiền]: trả NCC bằng CashVoucher / BankPayment,
                          thu khách bằng CashReceipt / BankReceipt
```

Ngoài ra có phân hệ **Company** (thông tin công ty, thuế suất VAT) và **Administration** (người dùng, quyền — phần lớn thuộc SSL, thư viện chuẩn Standard Subsystems Library). Nguồn: Jet — cf/Subsystems/*.xml (xem bảng mục 4 của `references/jet-1-overview-extending-cash.md#jet-overview`).

### 1.2. Ba loại "đồ vật" trong Jet

| Đời thực | Tên trong 1C | Ví dụ trong Jet | Đặc điểm |
|---|---|---|---|
| Sổ danh bạ, danh sách mặt hàng, danh sách kho | **Danh mục** (Catalog) | `Products`, `Counterparties`, `Warehouses`, `PriceTypes`, `CashAccounts`, `BankAccounts` | Người dùng tự thêm/sửa; chứng từ chọn từ đây thay vì gõ tay |
| Danh sách cố định, luật định sẵn | **Liệt kê** (Enumeration) | `ProductTypes` (Inventory = hàng hóa / Service = dịch vụ), `LiabilityTypes` (Liability = nợ / Advance = ứng trước) | Người dùng **không** thêm được giá trị; code dựa vào các giá trị này |
| Tờ phiếu, hóa đơn có ngày, có số | **Chứng từ** (Document) | `SupplierInvoice`, `SalesInvoice`… | Có thể **ghi sổ** (Posting — "post") thì mới làm thay đổi số liệu |
| Sổ cái ghi số liệu tích lũy | **Sổ tích lũy** (Accumulation register) | `InventoryInWarehouses`, `CustomerBalance`… | Chỉ chứng từ được ghi vào; người dùng không sửa tay |
| Bảng tra cứu theo thời gian | **Sổ thông tin** (Information register) | `Prices` (bảng giá) | Lưu "giá trị hiện hành" theo ngày, ví dụ giá bán |

Chưa ghi sổ thì chứng từ chỉ như **bản nháp** — báo cáo không đổi. Đây là điều quan trọng nhất khi lập phiếu quan sát.

### 1.3. Chín chứng từ nghiệp vụ — nghĩa ngoài đời

| Chứng từ (Synonym hiển thị) | Ngoài đời là | Những ô chính | Lưu ý khi dùng |
|---|---|---|---|
| `SupplierInvoice` (Supplier invoice) | Hóa đơn mua / phiếu nhập hàng mua | Supplier (nhà cung cấp), Warehouse (kho nhận), Currency, bảng `Inventory` (mặt hàng, số lượng, giá, VAT), bảng `AdvanceClearing` (trừ tiền đã ứng trước) | Chỉ dòng hàng loại **Inventory** mới vào kho; dòng **Service** chỉ ghi mua và công nợ |
| `SalesInvoice` (Sales invoice) | Hóa đơn bán hàng / phiếu xuất bán | Customer, Warehouse (kho xuất), PriceType (loại giá), bảng `Inventory`, `AdvanceClearing` | Chọn khách → loại giá của khách tự điền → giá tự điền lại |
| `InventoryIncrease` (Inventory increase) | Phiếu nhập kho không qua mua (nhập tồn đầu kỳ, nhập thừa) | Warehouse, bảng `Inventory` (Product, Quantity, Price, Amount) | Wiki của Jet dùng nó để nhập **tồn đầu kỳ**; Price ở đây là **giá vốn** |
| `InventoryWriteOff` (Inventory write-off) | Phiếu xuất hủy / xuất dùng nội bộ | Warehouse, bảng `Inventory` (Product, Quantity) | **Không có đơn giá, không có lý do** — giá trị tính theo giá vốn bình quân |
| `InventoryTransfer` (Inventory transfer) | Phiếu điều chuyển kho | Warehouse (kho xuất), WarehouseReceiver (kho nhận), bảng `Inventory` | Một phiếu = giảm ở kho này, tăng ở kho kia |
| `CashReceipt` (Cash receipt) | Phiếu thu tiền mặt | Operation (Customer = thu khách / Other = thu khác), CashAccount, Counterparty, bảng `PaymentDetails` (thu theo hóa đơn nào) | Để trống cột hóa đơn = khách **ứng trước** |
| `BankReceipt` (Bank receipt) | Giấy báo có ngân hàng | như trên, BankAccount thay CashAccount | |
| `CashVoucher` (Cash voucher) | Phiếu chi tiền mặt | Operation (Supplier = trả NCC / Other = chi khác) | Mọi khoản chi không trả NCC đều rơi vào "Other" |
| `BankPayment` (Bank payment) | Ủy nhiệm chi | như CashVoucher + Paid (đã chi), PaymentDate | **Chỉ ghi sổ khi tick Paid** — chưa tick thì post xong vẫn không có số liệu |

Nguồn: Jet — cf/Documents/<Tên>.xml (Synonym, attributes); điều kiện `Paid` ở cf/Documents/BankPayment/Ext/ManagerModule.bsl; điều kiện `ProductType = Inventory` ở cf/Documents/SupplierInvoice/Ext/ManagerModule.bsl và SalesInvoice tương tự; thông tin tồn đầu kỳ và tạm ứng ở wiki *1C:Jet Initial Setup Guide*, mục 11.

### 1.4. "Sổ" là gì: mỗi sổ trả lời một câu hỏi kinh doanh

Hãy hình dung mỗi sổ tích lũy (accumulation register) là một **cuốn sổ cái có kẻ cột**:

- **Cột "phân tích theo"** (Dimension — chiều): ghi theo kho nào, mặt hàng nào, khách nào…
- **Cột "con số"** (Resource — chỉ tiêu): số lượng, số tiền.
- Mỗi dòng là **ghi tăng** (Receipt) hoặc **ghi giảm** (Expense), do một chứng từ ghi vào.

Có hai loại sổ:

- **Sổ số dư** (kind **Balances**) trả lời **"hiện có bao nhiêu?"** — cộng tăng trừ giảm ra số còn lại tại một thời điểm.
- **Sổ phát sinh** (kind **Turnovers**) trả lời **"trong kỳ đã phát sinh bao nhiêu?"** — chỉ cộng dồn, không có khái niệm "còn lại".

| Sổ | Loại | Câu hỏi kinh doanh nó trả lời | Phân tích theo | Con số |
|---|---|---|---|---|
| `InventoryInWarehouses` | Balances | Kho X hiện còn bao nhiêu cái mặt hàng Y? | Product, Warehouse | Quantity |
| `InventoryCost` | Balances | Lượng hàng tồn đó trị giá bao nhiêu theo giá vốn? | Product, Warehouse | Quantity, Amount |
| `Purchases` | Turnovers | Tháng này đã mua của NCC A bao nhiêu, bao nhiêu tiền? | Counterparty, Product, PurchaseDocument | Quantity, Amount, VATAmount |
| `Sales` | Turnovers | Tháng này đã bán cho khách B bao nhiêu? | Counterparty, Product, SalesDocument | Quantity, Amount, VATAmount |
| `SupplierBalance` | Balances | Còn nợ NCC A bao nhiêu, theo hóa đơn nào; đã ứng trước bao nhiêu? | LiabilityType, Counterparty, Document | Amount |
| `CustomerBalance` | Balances | Khách B còn nợ bao nhiêu, theo hóa đơn nào; khách đã ứng trước bao nhiêu? | LiabilityType, Counterparty, Document | Amount |
| `CashBalance` | Balances | Quỹ tiền mặt / tài khoản ngân hàng hiện còn bao nhiêu? | BankCashAccount, CashType | AmountCur |

Và một **sổ thông tin** (information register) quan trọng: `Prices` — "Giá bán loại giá X của mặt hàng Y **tại ngày Z** là bao nhiêu?". Sổ này ghi theo ngày (Periodicity = Day), không cần chứng từ (Write mode = Independent), được ghi bởi công cụ `PricesSetup` (Prices setup). Nguồn: Jet — cf/AccumulationRegisters/*.xml, cf/InformationRegisters/Prices.xml.

Mẹo đọc `CustomerBalance` (ghép từ code posting, xem mục 9.1 của `references/jet-1-overview-extending-cash.md#jet-cash`): số dư dòng **Liability** dương = khách đang nợ theo hóa đơn đó; số dư dòng **Advance** âm = khách đã trả trước.

### 1.5. Chứng từ nào ghi sổ nào — nói bằng lời thường

| Khi ghi sổ chứng từ… | Sổ thay đổi thế nào |
|---|---|
| `SupplierInvoice` | Kho nhận **tăng** hàng và giá trị (chỉ hàng loại Inventory) · sổ mua **cộng thêm** · nợ NCC **tăng** (nếu có trừ ứng trước: ứng trước giảm, nợ hóa đơn giảm tương ứng) |
| `SalesInvoice` | Kho xuất **giảm** hàng, giá trị giảm theo giá vốn bình quân · sổ bán **cộng thêm** · khách nợ **tăng** |
| `InventoryIncrease` | Kho **tăng** hàng và giá trị (giá trị = Price nhập trên phiếu) |
| `InventoryTransfer` | Kho xuất **giảm**, kho nhận **tăng** — cả số lượng và giá trị |
| `InventoryWriteOff` | Kho **giảm** hàng, giá trị giảm theo giá vốn bình quân |
| `CashReceipt` / `BankReceipt` | Quỹ / tài khoản **tăng** · khách nợ **giảm** (nếu Operation = Customer) |
| `CashVoucher` / `BankPayment` | Quỹ / tài khoản **giảm** · nợ NCC **giảm** (nếu Operation = Supplier; BankPayment chỉ khi Paid) |

Ba chứng từ kho, SupplierInvoice và SalesInvoice còn **kiểm tra tồn âm**: nếu sau khi ghi mà số dư hiện tại của một mặt hàng ở kho bị âm, chứng từ bị từ chối với thông báo "Insufficient quantity on …". Nguồn: Jet — cf/AccumulationRegisters/InventoryInWarehouses/Ext/ManagerModule.bsl (procedure `NegativeBalanceControl`), lời gọi ở object module của 5 chứng từ này. Lưu ý quan sát: kiểm tra dựa trên số dư **hiện tại**, không theo ngày của chứng từ (mục 13 của `references/jet-2-purchases-sales-warehouse.md#jet-warehouse`) — đây là một điểm đáng đưa vào phân tích khoảng trống.

---

## 2. Phương pháp "khai báo → nhập liệu → quan sát hệ quả"

### 2.1. Khai báo dữ liệu nền theo đúng thứ tự

Thứ tự dưới đây bám wiki *1C:Jet Initial Setup Guide* (mục 4–11): danh mục nào được danh mục khác tham chiếu thì nhập trước.

| Bước | Ở đâu (Enterprise mode) | Nhập gì cho doanh nghiệp giả định | Vì sao trước |
|---|---|---|---|
| 1 | Company → Companies | Tên công ty, presentation currency (đồng tiền hạch toán) | Jet lấy đồng tiền hạch toán từ `Companies.MainCompany` |
| 2 | Company → VATRates; Warehouses → Units | Thuế suất, đơn vị tính (thùng, cái, kg) | Products tham chiếu tới hai danh mục này |
| 3 | Warehouses → Products | Nhóm hàng (folder), mặt hàng; chọn **ProductType** đúng (hàng hóa hay dịch vụ) | Chọn sai thành Service → hàng không vào kho |
| 4 | Sales → PriceTypes, rồi Prices setup | Loại giá (bán buôn, bán lẻ), bảng giá theo ngày hiệu lực | SalesInvoice lấy giá từ đây |
| 5 | Purchases/Sales → Counterparties | Khách, NCC; tick **Customer** / **Supplier**; gán PriceType cho khách | Một danh mục chung cho cả hai |
| 6 | Warehouses → Warehouses | Các kho / cửa hàng | |
| 7 | Cash management → CashAccounts, BankAccounts | Quỹ, tài khoản ngân hàng (chọn tiền tệ) | Tiền tệ của tài khoản bị khóa sau khi ghi |
| 8 | Chọn **ngày bắt đầu** | Ví dụ 01/03 của tháng giả định | Mọi chứng từ từ ngày này phải nhập đủ |
| 9 | Số dư đầu kỳ | Tồn kho: `InventoryIncrease` (mỗi kho một phiếu); tiền: `CashReceipt` / `BankReceipt` với Operation = **Other**; công nợ: `SalesInvoice` / `SupplierInvoice` với một mặt hàng dịch vụ giả "Opening balances input", ngày **trước** ngày bắt đầu | Không có số dư đầu thì chứng từ bán đầu tiên bị chặn vì tồn âm |

(tên mục menu có thể khác theo phiên bản — kiểm tra trên máy). Hệ quả cần ghi vào phân tích: số dư tiền đầu kỳ nhập bằng "thu khác" sẽ hiện như **một khoản thu trong kỳ** trên báo cáo CashStatement (mục 10 của `references/jet-1-overview-extending-cash.md#jet-cash`).

### 2.2. Nhập chứng từ và lập nhật ký chứng từ

Đề yêu cầu tối thiểu **15 chứng từ** của phân hệ được giao trong một tháng giả định. "Nhật ký chứng từ" là **bảng nhóm tự lập** (không phải object Document journal trong 1C). Mẫu cột gợi ý:

| STT | Ngày | Loại chứng từ | Số | Đối tượng (khách/NCC/kho) | Nội dung nghiệp vụ | Số lượng / số tiền | Đã post? | Sổ bị ảnh hưởng | Ghi chú (lỗi gặp, cách xử lý) |
|---|---|---|---|---|---|---|---|---|---|

Mẹo để bộ 15 chứng từ "có chuyện để phân tích":
- Trộn tình huống bình thường với tình huống biên: bán vượt tồn (xem Jet chặn thế nào), bán chịu rồi thu một phần, khách ứng trước, chuyển kho, hủy hàng.
- Nhập ít nhất một chứng từ **lùi ngày** so với chứng từ khác để quan sát cách Jet xử lý thứ tự thời gian.
- Ghi lại mọi thông báo lỗi Jet đưa ra — đó là bằng chứng tốt cho phần khoảng trống.

### 2.3. Quan sát trước/sau: báo cáo nào xem sổ nào

| Muốn quan sát sổ | Mở báo cáo (Synonym) | Phân hệ | Báo cáo đọc từ |
|---|---|---|---|
| InventoryInWarehouses | Available stock | Warehouses | `InventoryInWarehouses.Balance` |
| InventoryCost | Stock statement (đầu kỳ – nhập – xuất – cuối kỳ có giá trị) | Warehouses | `InventoryCost.BalanceAndTurnovers` |
| Purchases | Purchases | Purchases | `Purchases.Turnovers` |
| SupplierBalance | Supplier balance | Purchases | `SupplierBalance.Balance` |
| Sales | Sales | Sales | `Sales.Turnovers` |
| CustomerBalance | Customer balance | Sales | `CustomerBalance.Balance` |
| Sales + InventoryCost | Profit on sales (lãi gộp) | Sales | `Sales.Turnovers` + `InventoryCost.Turnovers` |
| Prices | Price list | Sales | `Prices.SliceLast` |
| CashBalance | Cash statement | Cash management | `CashBalance.BalanceAndTurnovers` |

Nguồn: Jet — cf/Reports/<Tên>/Templates/MainDataCompositionSchema/Ext/Template.xml. Chú ý báo cáo **Customer balance nằm ở phân hệ Sales**, kể cả khi nhóm làm đề Tiền (Đề 7).

Ngoài ra trên form chứng từ có lệnh xem **toàn bộ dòng sổ do chứng từ đó ghi**: báo cáo SSL "Document register records" (lệnh nằm trong nhóm "See also" của form; code SSL khai báo phím tắt Ctrl+Shift+A — ngoài giáo trình, hãy kiểm tra lại trên máy). Nguồn: Jet — cf/Reports/DocumentRegisterRecords/Ext/ManagerModule.bsl (`Command.Presentation = "Document register records"`, `New Shortcut(Key.A, False, True, True)`). (tên nút/menu có thể khác theo phiên bản — kiểm tra trên máy). Đây là cách nhanh nhất để chụp phần "SAU" của phiếu quan sát.

### 2.4. Phiếu quan sát (ít nhất 5 chứng từ)

Quy trình cho mỗi chứng từ:

1. **Dự đoán**: nhìn bảng 1.5, ghi ra sổ nào sẽ đổi, tăng hay giảm, bao nhiêu.
2. **Chụp TRƯỚC**: mở các báo cáo ở 2.3 với kỳ bao trùm ngày chứng từ, lọc đúng mặt hàng / khách / kho.
3. **Ghi sổ** chứng từ (Post).
4. **Chụp SAU**: mở lại các báo cáo (bấm tạo lại báo cáo), và mở "Document register records" của chứng từ.
5. **Đối chiếu** dự đoán với thực tế; nếu lệch, giải thích vì sao.

Mẫu bảng:

| Chứng từ | Báo cáo / sổ | Chỉ tiêu | Trước | Sau | Chênh lệch | Đúng dự đoán? | Giải thích |
|---|---|---|---|---|---|---|---|
| SalesInvoice số 0003, 12/03 | Available stock | Mì gói, Kho HN | 120 | 100 | −20 | Có | Bán 20 thùng |
| | Customer balance | Đại lý A, Liability | 0 | 5.500.000 | +5.500.000 | Có | Tổng gồm VAT |
| | Profit on sales | Mì gói | … | … | … | | Giá vốn bình quân |

Những "bất ngờ" hay gặp — đáng ghi vào cột giải thích:
- Mặt hàng dịch vụ không làm đổi Available stock (ProductType = Service).
- BankPayment post rồi mà Cash statement không đổi → chưa tick Paid.
- Customer balance tăng theo **tổng có VAT**, còn Sales ghi Amount và VATAmount riêng. Nguồn: Jet — cf/Documents/SalesInvoice/Ext/ManagerModule.bsl (`SUM(DocumentInventory.Total) AS Amount` cho CustomerBalance).
- Giá vốn trên Profit on sales là bình quân, không phải giá của lần mua gần nhất.

---

## 3. Quy tắc an toàn trước khi tùy biến

### 3.1. Sao lưu trước mỗi buổi sửa

- **Dump infobase** (sao lưu cả cấu hình lẫn dữ liệu ra file `.dt`): Designer → Administration/Tools → **Dump infobase**; khôi phục bằng **Restore infobase** (Bài 1). Đặt tên file có ngày giờ, ví dụ `Nhom05_2026-10-07_truoc-them-Lo.dt`.
- `.cf` chỉ chứa cấu hình, **không có dữ liệu** — đừng dùng `.cf` để "sao lưu" 15 chứng từ của nhóm (Bài 1, thẻ Practice 1).
- **Restore ghi đè toàn bộ** infobase đích — chỉ restore vào infobase trống hoặc bản thử.
- File `.dt` cũng là một sản phẩm phải nộp của bài tập lớn — giữ bản cuối cùng sạch sẽ.

### 3.2. Đổi tên hiển thị bằng Synonym — không bao giờ đổi Name

Mỗi object, attribute, giá trị liệt kê trong Designer có hai tên:

- **Name** — tên "kỹ thuật" mà **code và query của Jet gọi tới**. Đổi Name là làm gãy mọi chỗ code đang gọi tên cũ.
- **Synonym** — tên **người dùng nhìn thấy** trên menu, form, tiêu đề cột. Đổi tự do.

Ví dụ thật trong Jet: attribute `ProductType` của danh mục Products được query ghi sổ của SupplierInvoice gọi đích danh:

Nguồn: Jet — cf/Documents/SupplierInvoice/Ext/ManagerModule.bsl
```bsl
	|		INNER JOIN Catalog.Products AS Products
	|		ON DocumentInventory.Product = Products.Ref
	|			AND (Products.ProductType = VALUE(Enum.ProductTypes.Inventory))
```

Dòng này nghĩa là: "chỉ dòng hàng nào có loại = Inventory mới được đưa vào kho". Nếu ai đổi Name `ProductType` thành `LoaiHang`, hoặc đổi Name giá trị liệt kê `Inventory`, thì query trên (và query tương tự trong SalesInvoice) không chạy được nữa — mọi hóa đơn mua và bán sẽ **không post được**. Vì câu query là một chuỗi chữ, lỗi thường chỉ hiện ra khi chạy tới đó (khi bấm Post), không hiện lúc lưu cấu hình (ngoài giáo trình — hãy kiểm tra lại trong Syntax assistant).

Ví dụ thứ hai — attribute `Customer` của SalesInvoice có mặt ở ít nhất ba chỗ: query ghi sổ, form và mẫu in:

Nguồn: Jet — cf/Documents/SalesInvoice/Ext/ManagerModule.bsl
```bsl
	|	SalesInvoice.Customer AS Customer,
```

Nguồn: Jet — cf/Documents/SalesInvoice/Forms/DocumentForm/Ext/Form/Module.bsl
```bsl
	PriceType = GetCustomerPriceType(Object.Customer);
```

Trong khi đó ô Customer trên form **không đặt Title riêng**, nên tiêu đề ô lấy từ Synonym (Bài 9: "tiêu đề = synonym của attribute gắn item, trừ khi item có Title"). Nghĩa là: đổi Synonym `Customer` thành "Khách hàng" → form hiện "Khách hàng", mà code vẫn chạy bình thường. Nguồn: Jet — cf/Documents/SalesInvoice/Forms/DocumentForm/Ext/Form.xml (InputField `Customer` không có Title).

Synonym là **đa ngôn ngữ**: Jet khai báo bốn ngôn ngữ — English (`en`), Colombian (`es_CO`), Indonesian (`id`), Turkish (`tr`) (cf/Languages) — và mỗi Synonym có một dòng riêng cho từng ngôn ngữ (Synonym của `Customer` trên SalesInvoice hiện chỉ có dòng `en`). Sửa đúng dòng của ngôn ngữ giao diện đang chạy; sửa dòng khác thì nhãn trên màn hình không đổi.

Cũng **không đổi Name của form item** (ô trên form): code của Jet bật/tắt ô theo tên, ví dụ:

Nguồn: Jet — cf/Documents/CashVoucher/Forms/DocumentForm/Ext/Form/Module.bsl
```bsl
	If Object.Operation = PredefinedValue("Enum.CashVoucherOperations.Other") Then
		Items.Counterparty.Visible = False;
		Items.PaymentDetailsDocument.Visible = False;
```

Chọn đúng property khi Việt hóa (Bài 3, Bài 4):

| Muốn đổi | Sửa property |
|---|---|
| Tên mục menu / tên danh sách / nhãn ô | **Synonym** |
| Tên trên nút "Tạo" và tiêu đề form một phần tử | **Object presentation** (Bài 3: ghi vào Synonym thay vì Object presentation → tên danh sách cũng bị đổi) |
| Tiêu đề form danh sách | **List presentation** |
| Tên ô "nhóm cha" / "chủ sở hữu" | Synonym của standard attribute **Parent** / **Owner** (tab Data → Standard attributes) |

Nếu Designer hiện biểu tượng khóa không cho sửa một object thuộc SSL, đừng tự mở khóa — xem mục 6.

### 3.3. Mỗi lần một thay đổi, rồi cập nhật và thử ngay

1. Làm **một** thay đổi nhỏ (một attribute, một danh mục…).
2. **Update database configuration** (F7) — chưa F7 thì Enterprise mode chưa thấy gì mới (Bài 1).
3. Mở Enterprise mode (F5), **thử bằng một chứng từ thật**: tạo, ghi, post, rồi mở báo cáo liên quan xem số liệu cũ có còn đúng không.
4. Ổn → ghi lại vào nhật ký thay đổi của nhóm (ngày, ai sửa, sửa gì) → làm thay đổi tiếp theo.
5. Không ổn → sửa ngay khi còn nhớ mình vừa đổi gì; quá 2 lần không được → gọi tutor (mục 6), hoặc restore file `.dt` vừa dump.

Nếu form mở ra không thấy ô **mới thêm** (hoặc ô bị thiếu) dù đã F7, thử Enterprise mode → Menu → Window → **Restore window position** (Bài 1, thẻ Practice 1 Task 3) — form có thể đang dùng kích thước cũ đã lưu. Cách này không dành cho việc đổi nhãn (Synonym): nhãn chưa đổi thì kiểm tra lại dòng ngôn ngữ của Synonym và item có Title riêng không.

---

## 4. Hướng dẫn M2 từng bước

Mức **M2 = khai báo trực quan, không viết code** (đề, mục 2.3). Bảng dưới ghép hạng mục M2 của 9 đề với mục hướng dẫn:

| Hạng mục | Đề dùng | Mục |
|---|---|---|
| Thêm attribute vào danh mục / chứng từ | 2, 3, 4, 6, 7, 8, 9 | 4.1 |
| Thêm cột vào phần bảng (tabular section) | 1, 5, 9 | 4.2 |
| Tạo liệt kê và dùng nó | 2, 3, 4, 9 | 4.3 |
| Tạo danh mục (phân cấp, cấp dưới) | 1, 6, 8 | 4.4 |
| Tạo sổ thông tin nhập tay | 2, 4, 5, 7, 8 | 4.5 |
| Tạo chứng từ không ghi sổ | 3, 9 | 4.6 |
| Đặt ô mới lên form | tất cả | 4.7 |
| Đưa object vào phân hệ | tất cả | 4.8 |
| Cấp quyền trong role của Jet | tất cả | 4.9 |
| Báo cáo DCS trên dữ liệu có sẵn | 1, 2, 4, 6, 8, 9 | 4.10 |

Quy ước đặt tên gợi ý: Name viết tiếng Anh không dấu, viết hoa đầu từ (PascalCase) giống Jet (`Products`, `SalesInvoice`), Synonym tiếng Việt có dấu. [suy luận] Nếu nhiều nhóm sửa chung một cấu hình, nên thống nhất một tiền tố cho object mới của mỗi nhóm để khỏi trùng tên.

### 4.1. Thêm attribute vào danh mục hoặc chứng từ

Mẫu để bắt chước trong Jet: attribute `PriceType` của `Counterparties` (tham chiếu tới danh mục PriceTypes) và attribute `ProductType` của `Products` (tham chiếu tới liệt kê, có giá trị mặc định và bắt buộc nhập).

Ví dụ: Đề 6 — "Nhân viên kinh doanh" trên SalesInvoice; Đề 2 — "Loại kho" trên Warehouses; Đề 7 — "Hạn thanh toán" trên SalesInvoice.

1. Designer → cây cấu hình → mở object (ví dụ Documents → SalesInvoice).
2. Tab **Data** → danh sách **Attributes** → **Add** (tên nút có thể khác theo phiên bản — kiểm tra trên máy).
3. Điền **Name** (ví dụ `SalesRepresentative`), **Synonym** ("Nhân viên kinh doanh").
4. Chọn **Type**: kiểu tham chiếu `CatalogRef.<Danh mục>` nếu chọn từ danh sách; `Date` (Date format = Date) cho ngày; `Number` (Length, Precision, Nonnegative) cho số (Bài 2).
5. Nếu bắt buộc: **Fill checking** = Show error ("Display error"). Nếu cần giá trị mặc định: **Fill value** (Bài 3, thẻ Practice 3 Bài 4).
6. Nếu chỉ được chọn trong phạm vi một ô khác (ví dụ chỉ chọn tài khoản của đúng khách): **Choice parameter links**, Name `Filter.Owner`, data path tới ô kia (Bài 4).
7. F7 → đặt ô lên form (mục 4.7) → thử trong Enterprise mode.

Lưu ý: mọi chứng từ và danh mục nghiệp vụ của Jet đều có **form tự làm** (DocumentForm, ItemForm…), nên attribute mới **không tự hiện** trên form — phải kéo lên (Bài 10, thẻ Practice 10 Bài 1: "Thêm attribute vào metadata nhưng quên đặt field lên form → user không nhập được").

Jet còn có sẵn công cụ **Additional attributes** (thuộc tính bổ sung của SSL) thêm ô mới ngay trong Enterprise mode, không cần Designer — wiki *Initial Setup Guide* (mục 5, 7, 8) khuyên dùng nó để "adapt Jet… without development". Có thể nêu trong phân tích như một phương án; còn hạng mục M2 của đề yêu cầu làm trong Designer — hỏi tutor nếu muốn thay bằng công cụ này.

### 4.2. Thêm cột vào phần bảng

Mẫu: phần bảng `Inventory` của `SupplierInvoice` / `SalesInvoice` (cột Product, Quantity, Price, Amount, VATRate, VATAmount, Total) và của `InventoryWriteOff` (Product, Quantity).

Ví dụ: Đề 1 — cột "Lô hàng"; Đề 5 — cột "% chiết khấu"; Đề 9 — cột "Lý do".

1. Mở chứng từ → tab **Data** → **Tabular sections** → chọn `Inventory`.
2. Thêm attribute **vào trong** `Inventory` (không phải vào chứng từ) → Name, Synonym, Type (Bài 3, thẻ Practice 3 Bài 7: đặt nhầm ở chứng từ thì chỉ nhập được một giá trị cho cả phiếu).
3. Làm lại cho **từng** chứng từ đề yêu cầu (Đề 1 yêu cầu 4 chứng từ).
4. Nếu cột Lô chỉ được chọn lô của đúng mặt hàng trên dòng: Choice parameter links `Filter.Owner` trỏ tới cột Product của cùng dòng (Bài 4; tên hiển thị của đường dẫn có thể khác theo phiên bản — kiểm tra trên máy).
5. F7 → mở form, kéo cột mới vào bảng `Inventory` (mục 4.7).

Thêm cột vào phần bảng **không** làm đổi việc ghi sổ — query ghi sổ của Jet chỉ đọc các cột nó gọi tên. Đó là lý do hạng mục này là M2. Muốn cột mới đi vào sổ thì là M3 (mục 6).

### 4.3. Tạo liệt kê và dùng nó

Mẫu: liệt kê `ProductTypes` (Inventory, Service) dùng cho attribute `Products.ProductType` có **Fill value** = Inventory và **Fill checking** = Show error. Nguồn: Jet — cf/Catalogs/Products.xml.

Ví dụ: Đề 3 — Trạng thái đơn; Đề 4 — Xếp hạng A/B/C; Đề 2 — Loại kho; Đề 9 — Lý do chênh lệch.

1. Designer → **Enumerations** → **Add** → Name (ví dụ `DiscrepancyReasons`), Synonym.
2. Tab **Enum values**: thêm từng giá trị — Name tiếng Anh (`NaturalLoss`), Synonym tiếng Việt ("Hao hụt tự nhiên") (Bài 3, thẻ Practice 3 Bài 4).
3. Ở object dùng nó: thêm attribute kiểu `EnumRef.<Tên>`; đặt Fill value và Fill checking nếu cần.
4. F7; kéo ô lên form.

Liệt kê không cần cấp quyền trong role (trong Jet không role nào liệt kê Enum — đối chiếu cf/Roles/*/Ext/Rights.xml). Khi phân vân **liệt kê hay danh mục** (câu hỏi bắt buộc của Đề 4, Đề 8), các góc cần cân nhắc: ai được thêm giá trị mới (người dùng hay lập trình viên), code có rẽ nhánh theo từng giá trị không, giá trị có cần thêm thông tin đi kèm (mô tả, tỷ lệ, người phụ trách) không. Bài 3 và Bài 4: "dựa thuật toán vào predefined data hoặc Enumeration, không dựa vào code/description người dùng nhập".

### 4.4. Tạo danh mục — phẳng, phân cấp, cấp dưới

Mẫu trong Jet:
- Danh mục phẳng: `Warehouses` (Hierarchical = false).
- Danh mục phân cấp nhóm–phần tử: `Products`, `Counterparties` (Hierarchical = true, HierarchyType = Folders and items).
- Danh mục **cấp dưới** (có Owner): Jet **không có** danh mục nghiệp vụ nào có Owner (BankAccounts cũng để Owners trống) — làm theo bài thực hành `CounterpartyContracts` của Bài 4.

Nguồn: Jet — cf/Catalogs/Products.xml, Counterparties.xml, Warehouses.xml, BankAccounts.xml.

Ví dụ: Đề 1 — Lô hàng (cấp dưới của Products); Đề 6 — Khu vực (phân cấp Miền → Tỉnh); Đề 8 — Khoản mục chi phí (phân cấp).

1. Designer → **Catalogs** → **Add** → Name (ví dụ `Batches`), Synonym ("Lô hàng"); Object presentation ("Lô hàng"), List presentation (Bài 3).
2. Kiểm tra **Description length** đủ dài; **Code length** = 0 nếu không cần mã (Bài 4).
3. Attributes: ví dụ `ProductionDate`, `ExpiryDate` kiểu Date (Date format = Date).
4. **Phân cấp** (tab Hierarchy): bật Hierarchical, chọn **Hierarchy type**:
   - *Folder and item hierarchy* — nhóm chỉ để phân loại, chỉ phần tử mới được chọn vào chứng từ.
   - *Item hierarchy* — phần tử nằm dưới phần tử, **cả hai đều chọn được**.
   - Có thể giới hạn số cấp (Limit level count) (Bài 4).
   Câu hỏi cho nhóm: "Miền" có cần được chọn làm giá trị (ví dụ gán một nhân viên phụ trách cả miền) không? Câu trả lời quyết định chọn kiểu nào — ghi lý do vào bảng thiết kế đối tượng.
5. **Cấp dưới** (tab **Owners**): thêm `Catalog.Products`; đổi Synonym của standard attribute **Owner** thành "Mặt hàng". Nếu mã lô chỉ cần duy nhất trong một mặt hàng: **Code series** = Within subordination to owner (Bài 4, thẻ Practice 4 Bài 3).
6. Đưa vào phân hệ (4.8), cấp quyền (4.9), F7.
7. Form: với M2 có thể để platform tự sinh form (Bài 3: "Nếu không gán default form, platform tự sinh form động"). [suy luận] Form tự sinh sẽ không có các tiện ích SSL như thuộc tính bổ sung, file đính kèm mà form Warehouses có — chấp nhận được cho M2; muốn đủ như Jet thì làm theo checklist mục 6 của `references/jet-1-overview-extending-cash.md#jet-extending` cùng tutor.

### 4.5. Tạo sổ thông tin để nhập tay

Mẫu: `Prices` — Periodicity = **Day**, Write mode = **Independent**, dimensions `PriceType`, `Product`, resource `Price`. Nguồn: Jet — cf/InformationRegisters/Prices.xml.

Ví dụ: Đề 2 — Định mức tồn kho; Đề 4 — Cam kết cung ứng; Đề 5 — Bậc chiết khấu; Đề 7 — Điều khoản thanh toán; Đề 8 — Ngân sách.

1. Designer → **Information registers** → **Add** (tên nút có thể khác theo phiên bản — kiểm tra trên máy) → Name (ví dụ `StockNorms`), Synonym.
2. **Write mode** = Independent (mặc định khi tạo) — nhập tay được, không cần chứng từ (Bài 12).
3. **Periodicity**: None (không lưu lịch sử) hoặc Day / Month… (lưu lịch sử thay đổi) (Bài 12).
4. **Dimensions** (phân tích theo): ví dụ `Warehouse`, `Product`. **Resources** (giá trị cần tra): ví dụ `MinimumQuantity`, `MaximumQuantity`.
5. Muốn từ form của kho mở nhanh danh sách định mức của kho đó: bật property **Master** của dimension tương ứng (Bài 12).
6. Đưa vào phân hệ, cấp quyền, F7. Người dùng nhập bằng cách mở sổ trong menu và thêm dòng.

Hai quy tắc của platform cần nhớ (Bài 12):
- **Không thể có hai dòng trùng toàn bộ dimensions** (cộng thêm Period nếu sổ định kỳ) — ghi dòng trùng sẽ báo lỗi. Vì vậy chọn cái gì làm dimension chính là chọn "mỗi tổ hợp nào chỉ có một giá trị".
- Chỉ sổ **định kỳ** mới tra được "giá trị hiện hành tại ngày X" (bảng ảo **SliceLast**). Sổ không định kỳ chỉ có giá trị hiện tại, mất lịch sử khi sửa.

Định kỳ hay không là câu hỏi phân tích bắt buộc của Đề 2 và Đề 8 — góc nhìn: doanh nghiệp có cần biết "tháng trước định mức là bao nhiêu" để giải thích một quyết định cũ không; giá trị thay đổi bao lâu một lần; báo cáo so sánh có phải dùng giá trị **tại ngày phát sinh** không. Quan sát cách Jet làm với `Prices`: giá đổi theo ngày, hóa đơn cũ vẫn giữ giá đã điền lúc lập.

### 4.6. Tạo chứng từ không ghi sổ

Mẫu trong Jet: `PricesSetupAuxiliary` là chứng từ **Posting = Deny** (không ghi sổ, chỉ có phần bảng `ProductPrices`). Về cấu trúc header + phần bảng hàng hóa, nhìn `InventoryWriteOff` (Warehouse + bảng `Inventory`). Nguồn: Jet — cf/Documents/PricesSetupAuxiliary.xml, cf/Documents/InventoryWriteOff.xml.

Ví dụ: Đề 3 — Đơn đặt hàng nhà cung cấp; Đề 9 — Phiếu kiểm kê.

1. Designer → **Documents** → **Add** → Name (ví dụ `InventoryCount`), Synonym ("Phiếu kiểm kê"), Object/List presentation.
2. Header attributes: ví dụ `Warehouse` (`CatalogRef.Warehouses`, bắt buộc), `CountedBy` (người kiểm), `Comment`.
3. Tab Data → **Tabular sections** → Add `Inventory` với các cột: `Product` (`CatalogRef.Products`), `BookQuantity`, `ActualQuantity`, `Difference` (Number, có Precision nếu hàng cân đo), `Reason` (`EnumRef.DiscrepancyReasons`). Đặt tên phần bảng là `Inventory` giống Jet cho dễ nhận ra.
4. Tab **Posting**: để **Posting** = Deny / không cho phép (tên giá trị có thể khác theo phiên bản — kiểm tra trên máy). Bài 16: khi tắt Posting, kiểm tra bắt buộc nhập chạy lúc **ghi** (write), và chứng từ không có lệnh Post/Undo posting.
5. Tab **Numbering**: giữ Autonumbering, Check uniqueness (Bài 4).
6. Forms: tạo **Document form** và **List form** bằng Form wizard (Bài 10, thẻ Practice 10 Bài 3), hoặc để platform tự sinh. Lưu ý: code M3 trên form (5.1–5.5) cần một Document form tạo rõ ràng; nếu đang dùng form tự sinh thì tạo form bằng Form wizard trước.
7. Đưa vào phân hệ con chứa chứng từ của nhóm (4.8), cấp quyền (4.9), F7.

**Đừng copy chứng từ Jet có ghi sổ** (InventoryWriteOff, SupplierInvoice…) để làm chứng từ không ghi sổ: bản copy mang theo object module gọi `Documents.<TênCũ>.InitializeDocumentData` và đăng ký register records — chính là lỗi "copy document mẫu nhưng post ra số liệu của document mẫu" ở mục 8 của `references/jet-1-overview-extending-cash.md#jet-extending`. Tạo mới sạch hơn cho nhóm 2.

### 4.7. Đặt ô mới lên form

1. Mở object → tab **Forms** → double-click form (ví dụ `DocumentForm`) để mở Form editor (tên tab có thể khác theo phiên bản — kiểm tra trên máy).
2. Ở cửa sổ attributes của form, mở cây **Object**, tìm attribute mới.
3. **Kéo** attribute vào cây form items, thả vào đúng nhóm (Bài 10, thẻ Practice 10 Bài 1: "trên document form kéo attribute từ cây Object vào nhóm header"). Form SalesInvoice có các nhóm `GroupHeader`, `GroupLeft`, `GroupRight`, `GroupInfo`; form InventoryWriteOff có `GroupHeader`, `GroupLeft`, `GroupRight`, `GroupInfo`. Nguồn: Jet — cf/Documents/SalesInvoice/Forms/DocumentForm/Ext/Form.xml, cf/Documents/InventoryWriteOff/Forms/DocumentForm/Ext/Form.xml.
4. Cột mới của phần bảng: mở `Object` → `Inventory` → kéo cột vào bảng `Inventory` trên form.
5. Muốn ô chỉ xem không sửa: property **ReadOnly** của item (Bài 9).
6. Muốn sắp hai ô nằm ngang: thêm Group – Regular group, Group = horizontal, kéo hai ô vào (Bài 9).
7. F7, mở Enterprise mode kiểm tra.

Không xóa hay đổi Name các item sẵn có của form Jet (mục 3.2), và không xóa nhóm `GroupAdditionalAttributes` (nơi SSL đặt thuộc tính bổ sung — mục 10.8 của `references/jet-1-overview-extending-cash.md#jet-overview`).

### 4.8. Đưa object vào phân hệ

Mỗi phân hệ nghiệp vụ của Jet có phân hệ con. Đặt object mới theo cùng chỗ Jet đặt object cùng loại. Nguồn: Jet — cf/Subsystems/<Tên>.xml và cf/Subsystems/<Tên>/Subsystems/*.xml.

| Phân hệ | Danh mục mới vào | Chứng từ mới vào | Báo cáo, sổ mới vào |
|---|---|---|---|
| Warehouses | `Warehouses.Catalogs` | `Warehouses.Warehouse` | `Warehouses` (cha) |
| Purchases | `Purchases.Catalogs` | `Purchases.Purchases` | `Purchases` (cha) |
| Sales | `Sales.Catalogs` | `Sales.Sales` | `Sales` (cha); sổ giá nằm ở `Sales.Pricing` |
| CashManagement | `CashManagement.Catalogs` | `CashManagement.Bank` hoặc `CashManagement.CashInHand` | `CashManagement` (cha) |

Cách làm: mở object → tab **Subsystems** → tick phân hệ; hoặc mở phân hệ → tab **Content** → tick object (Bài 3, Bài 9). Một object có thể nằm trong nhiều phân hệ.

### 4.9. Cấp quyền trong role của Jet

Mỗi phân hệ nghiệp vụ có một role riêng: **`UseWarehouses`**, **`UsePurchases`**, **`UseSales`**, **`UseCashManagement`** (và `UseCompany`). Các role này có **"Set rights for new objects" = tắt**, nên object mới **không tự có quyền** — quên bước này là người dùng thường gặp "Access violation!". Role `FullAccess` thì bật, nên object mới tự nhận **đủ quyền kể cả xóa trực tiếp** — phải tắt `InteractiveDelete`. Nguồn: Jet — cf/Roles/UseWarehouses/Ext/Rights.xml (`<setForNewObjects>false</setForNewObjects>`), cf/Roles/FullAccess/Ext/Rights.xml (`<setForNewObjects>true</setForNewObjects>`).

Mẫu quyền lấy từ Jet:

| Object mới | Quyền cần tick trong role nhóm | Mẫu Jet |
|---|---|---|
| Danh mục | Read, Insert, Update, View, InteractiveInsert, Edit, InteractiveSetDeletionMark, InteractiveClearDeletionMark, InputByString | `Catalog.Warehouses` trong `UseWarehouses` |
| Chứng từ không ghi sổ | như danh mục [suy luận: bỏ các quyền Posting/UndoPosting của mẫu chứng từ có ghi sổ] | `Document.InventoryTransfer` trong `UseWarehouses` (bỏ phần posting) |
| Sổ thông tin nhập tay | Read, Update, View, Edit | `InformationRegister.Prices` trong `UseSales` (có thêm TotalsControl) |
| Báo cáo | Use, View | `Report.AvailableStock` trong `UseWarehouses` |
| Phân hệ con mới (nếu tạo) | View | `Subsystem.Warehouses.Subsystem.Catalogs` |
| Liệt kê | không cần | — |

Thao tác (Bài 20): Designer → **Roles** → mở role nhóm → tìm object trong cây → tick quyền. Mẹo của bài: tick "từ dưới lên" — tick InputByString thì Read và View tự bật. Sau đó mở `FullAccess` → object mới → **bỏ tick InteractiveDelete** (danh mục: bỏ thêm các quyền xóa/đánh dấu xóa predefined).

Hai lỗi đã gặp trong cấu trúc quyền của Jet:
- Báo cáo đọc sổ thì role phải có **Read** trên sổ đó. Ví dụ `UseCashManagement` **không có** quyền trên `AccumulationRegister.CustomerBalance` (chỉ có `CashBalance`) — báo cáo tuổi nợ của Đề 7 chạy dưới user chỉ có role này sẽ bị từ chối. Nguồn: Jet — cf/Roles/UseCashManagement/Ext/Rights.xml.
- Form đọc sổ thông tin (ví dụ code mục 5.4) cũng cần Read trên sổ đó trong role.

Thử quyền: đăng nhập bằng một user **không** có FullAccess. Trong Jet, user được tạo ở Enterprise mode (Administration → Users, theo wiki mục 12) và nhận role qua nhóm truy cập của SSL; Jet không cung cấp sẵn hồ sơ quyền nào (`AccessManagementOverridable.OnFillSuppliedAccessGroupProfiles` để trống). Nếu không tự lập được hồ sơ quyền để thử, nhờ tutor (mục 6).

### 4.10. Báo cáo DCS trên dữ liệu có sẵn

Mẫu: báo cáo `Purchases` — một data set Query đọc `AccumulationRegister.Purchases.Turnovers`, resources `Sum(Amount)`, `Sum(Quantity)`… Nguồn: Jet — cf/Reports/Purchases/Templates/MainDataCompositionSchema/Ext/Template.xml. Mọi báo cáo của Jet đều là DCS, không có module, dùng form chung.

Ví dụ: Đề 4 — giá mua bình quân NCC × mặt hàng; Đề 6 — doanh số theo nhân viên/khu vực đọc từ SalesInvoice; Đề 8 — chi phí thực tế theo khoản mục đọc từ CashVoucher/BankPayment; Đề 1 — lô sắp hết hạn từ danh mục Lô.

Các bước (Bài 18):
1. Designer → **Reports** → **Add** → Name, Synonym; đưa vào phân hệ cha của nhóm.
2. Field **Main data composition schema** → nút kính lúp → chọn kiểu Data composition schema → Finish.
3. Tab **Data sets** → thêm data set **Query** → mở Query wizard, chọn bảng:
   - số liệu đã ghi sổ: bảng ảo của sổ (`Purchases.Turnovers`, `InventoryInWarehouses.Balance`);
   - số liệu trên chứng từ: `Document.SalesInvoice.Inventory` (dòng hàng) nối với header qua `Ref`;
   - số liệu danh mục: `Catalog.Batches`;
   - giá trị hiện hành của sổ thông tin: `InformationRegister.<Tên>.SliceLast`.
   Không cần TOTALS trong query — DCS tự tính tổng.
4. Tab **Resources**: thêm các cột số (nút ">>"), biểu thức `Sum(...)`. Chỉ tiêu tỷ lệ như giá bình quân viết ở cột Expression của resource, ví dụ `Sum(Amount) / Sum(Quantity)` — chia cho 0 khi Quantity = 0, nên bọc bằng biểu thức CASE (Bài 18 nhắc dùng CASE trong expression của DCS).
5. Tab **Settings** → **Settings wizard**: chọn kiểu List hoặc Table, chọn field, grouping (ví dụ NCC → mặt hàng).
6. Đưa Period / bộ lọc ra cho người dùng: tab Parameters / Filter → "Include in custom settings", Edit mode "Quick access" (Bài 18).
7. Conditional appearance để tô màu dòng cần chú ý (ví dụ tồn dưới định mức) (Bài 18).
8. Cấp quyền Use + View cho báo cáo và Read cho bảng nguồn (4.9), F7, chạy thử.

Báo cáo đọc từ chứng từ khác báo cáo đọc từ sổ thế nào là câu hỏi bắt buộc của Đề 6 — gợi ý quan sát: chứng từ chưa post hoặc đã đánh dấu xóa có lọt vào báo cáo không; muốn số dư "còn lại" thì đọc từ chứng từ có làm được không.

Jet còn đăng ký mỗi báo cáo trong `ReportsOptionsOverridable` để có mô tả trong danh sách báo cáo (mục 7.2 của `references/jet-1-overview-extending-cash.md#jet-extending`) — đó là module SSL, nhờ tutor nếu muốn thêm.

---

## 5. Code đơn giản kèm giải thích (M3 nhẹ)

Với nhóm 2, phần này **được đưa code hoàn chỉnh** để dán vào, kèm giải thích từng dòng bằng lời nghiệp vụ; tutor vẫn duyệt trước khi nộp. Mọi đoạn dưới đây là **code minh họa — chạy thử để kiểm chứng**: tên object mới (`DiscountTiers`, `InventoryCount`, `PaymentTerms`…) là tên giả định, đổi cho khớp tên nhóm đã tạo ở mục 4. Code viết theo khuôn của Jet: handler phía client gom dữ liệu rồi gọi một hàm phía server (`&AtServerNoContext`), đặt trong đúng `#Region`.

### 5.0. Dán code vào đâu, mở thế nào

| Loại code | Đặt ở | Mở trong Designer |
|---|---|---|
| Phản ứng khi người dùng đổi một ô, bấm nút | **Form module** của form | Mở form (4.7) → phần **Form module** của Form editor (Bài 9) |
| Kiểm tra trước khi ghi, áp dụng cả khi ghi từ code | **Object module** của chứng từ | Context menu của chứng từ → mở object module (tên lệnh có thể khác theo phiên bản — kiểm tra trên máy) |

Code M3 trên form (5.1–5.5) cần một Document form tạo rõ ràng; nếu đang dùng form tự sinh (4.6 bước 6) thì tạo form bằng Form wizard trước — form tự sinh không có form module để dán code.

Gắn handler cho sự kiện của **form** (Bài 16): chọn ô trên form → **Properties palette** → mục sự kiện (ví dụ OnChange) → nút tạo handler; platform tạo procedure tên `<TênÔ><TênSựKiện>`. Handler của **object module** thì chỉ cần đúng tên chuẩn (`FillCheckProcessing`, `BeforeWrite`).

Quan trọng với form của Jet: nhiều sự kiện **đã có handler** (ví dụ `CustomerOnChange`, `InventoryQuantityOnChange` của SalesInvoice). Khi đó **thêm một dòng gọi vào trong procedure có sẵn**, đừng tạo procedure thứ hai — ô sự kiện trên Properties palette chỉ trỏ tới một procedure (Bài 16). Nguồn danh sách handler: Jet — cf/Documents/SalesInvoice/Forms/DocumentForm/Ext/Form/Module.bsl.

Đánh dấu chỗ nhóm sửa bằng một dòng chú thích, ví dụ `// Nhóm 05 — Đề 5: chiết khấu`, để tutor và nhóm khác tìm được.

### 5.1. Tự điền giá trị khi người dùng nhập (Đề 5 — tự áp % chiết khấu)

Khuôn của Jet: khi đổi mặt hàng trên dòng, form gom dữ liệu vào một `Structure` rồi gọi server lấy giá:

Nguồn: Jet — cf/Documents/SalesInvoice/Forms/DocumentForm/Ext/Form/Module.bsl
```bsl
&AtClient
Procedure InventoryQuantityOnChange(Item)
	
	InventoryTabularSectionClientServer.CalculateAmount(Items.Inventory.CurrentData);
	
EndProcedure
```

Giả định nhóm đã có: sổ thông tin **không định kỳ** `DiscountTiers` (dimensions `PriceType`, `Product`, `MinQuantity`; resource `DiscountPercent`) và cột `DiscountPercent` trong `SalesInvoice.Inventory` (mục 4.2, 4.5).

Code minh họa — chạy thử để kiểm chứng (form module của SalesInvoice):
```bsl
// Trong procedure CÓ SẴN InventoryQuantityOnChange, thêm dòng thứ hai:
&AtClient
Procedure InventoryQuantityOnChange(Item)
	
	InventoryTabularSectionClientServer.CalculateAmount(Items.Inventory.CurrentData);
	FillDiscountPercent(); // Nhóm 05 — Đề 5
	
EndProcedure

// Thêm mới, đặt trong #Region Private:
&AtClient
Procedure FillDiscountPercent()
	
	CurrentData = Items.Inventory.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	
	DataStructure = New Structure;
	DataStructure.Insert("PriceType", Object.PriceType);
	DataStructure.Insert("Product", CurrentData.Product);
	DataStructure.Insert("Quantity", CurrentData.Quantity);
	
	CurrentData.DiscountPercent = GetDiscountPercent(DataStructure);
	
EndProcedure

&AtServerNoContext
Function GetDiscountPercent(DataStructure)
	
	Query = New Query;
	Query.Text =
	"SELECT ALLOWED TOP 1
	|	DiscountTiers.DiscountPercent AS DiscountPercent
	|FROM
	|	InformationRegister.DiscountTiers AS DiscountTiers
	|WHERE
	|	DiscountTiers.PriceType = &PriceType
	|	AND DiscountTiers.Product = &Product
	|	AND DiscountTiers.MinQuantity <= &Quantity
	|
	|ORDER BY
	|	DiscountTiers.MinQuantity DESC";
	
	Query.SetParameter("PriceType", DataStructure.PriceType);
	Query.SetParameter("Product", DataStructure.Product);
	Query.SetParameter("Quantity", DataStructure.Quantity);
	
	Selection = Query.Execute().Select();
	If Selection.Next() Then
		Return Selection.DiscountPercent;
	EndIf;
	
	Return 0;
	
EndFunction
```

Dòng này nghĩa là:
- `FillDiscountPercent();` — "mỗi khi người bán sửa số lượng, tra lại mức chiết khấu".
- `CurrentData = Items.Inventory.CurrentData` — "dòng hàng người dùng đang đứng". Nếu không đứng ở dòng nào (`Undefined`) thì thôi.
- `DataStructure.Insert(...)` — "ghi ra một tờ giấy ba thông tin: loại giá của hóa đơn, mặt hàng, số lượng" để gửi lên máy chủ một lần (Jet làm y hệt trong `InventoryProductOnChange`).
- `&AtServerNoContext Function GetDiscountPercent` — "nhờ máy chủ tra bảng bậc chiết khấu"; dữ liệu sổ chỉ đọc được trên máy chủ (Bài 12).
- Câu query: "trong các bậc của đúng loại giá và mặt hàng này, lấy những bậc có số lượng tối thiểu **không vượt** số lượng đang mua, xếp bậc cao nhất lên đầu, lấy **1** dòng" — tức là bậc cao nhất mà khách đạt được.
- `Return 0` — "không đạt bậc nào thì chiết khấu 0%".

Code này chỉ **điền cột %**; nó không đổi Amount và không đổi số liệu ghi vào sổ Sales. Có trừ chiết khấu vào Amount hay không sẽ làm đổi doanh thu, công nợ khách — đó là thay đổi ghi sổ, bàn với tutor (mục 6). Muốn tra lại cả khi đổi mặt hàng, thêm cùng dòng `FillDiscountPercent();` vào cuối `InventoryProductOnChange`.

### 5.2. Tính một cột từ các cột khác (Đề 9 — Chênh lệch = Thực tế − Sổ sách)

Khuôn của Jet — InventoryIncrease tính Amount trên client mỗi khi đổi số lượng hoặc giá:

Nguồn: Jet — cf/Documents/InventoryIncrease/Forms/DocumentForm/Ext/Form/Module.bsl
```bsl
&AtClient
Procedure CalculateAmount()
	
	TabSectionRow = Items.Inventory.CurrentData;
	
	If TabSectionRow <> Undefined Then
		TabSectionRow.Amount = TabSectionRow.Quantity * TabSectionRow.Price;
	EndIf;
	
EndProcedure
```

Code minh họa — chạy thử để kiểm chứng (form module của `InventoryCount`; tạo handler OnChange cho hai cột `InventoryActualQuantity` và `InventoryBookQuantity` qua Properties palette):
```bsl
#Region FormTableItemsEventHandlersInventory

&AtClient
Procedure InventoryActualQuantityOnChange(Item)
	
	CalculateDifference();
	
EndProcedure

&AtClient
Procedure InventoryBookQuantityOnChange(Item)
	
	CalculateDifference();
	
EndProcedure

#EndRegion

#Region Private

&AtClient
Procedure CalculateDifference()
	
	TabSectionRow = Items.Inventory.CurrentData;
	
	If TabSectionRow <> Undefined Then
		TabSectionRow.Difference = TabSectionRow.ActualQuantity - TabSectionRow.BookQuantity;
	EndIf;
	
EndProcedure

#EndRegion
```

Dòng này nghĩa là:
- Hai handler `...OnChange` — "khi người kiểm sửa số thực tế, hoặc khi số sổ sách thay đổi, tính lại chênh lệch". Cả hai gọi chung một thủ tục để công thức chỉ viết một lần (Bài 4, thẻ Practice 4 Bài 6).
- `Difference = ActualQuantity - BookQuantity` — "chênh lệch dương là **thừa**, âm là **thiếu**".
- Đặt cột `Difference` trên form là **ReadOnly** (4.7) để không ai sửa tay rồi bị ghi đè.

Lưu ý: code form chỉ chạy khi người dùng sửa trên form. Nếu sau này dòng được điền bằng code (5.5), phải gọi tính lại cho từng dòng — 5.5 đã làm việc đó.

### 5.3. Hiện cảnh báo, chặn ghi khi dữ liệu sai (Đề 3 — ngày giao dự kiến)

Khuôn của Jet — chặn bằng `Common.MessageToUser(..., Cancel)` (thủ tục SSL) trong kiểm tra trước khi ghi:

Nguồn: Jet — cf/Documents/SalesInvoice/Forms/DocumentForm/Ext/Form/Module.bsl
```bsl
	If Object.Inventory.Total("Total") < Object.AdvanceClearing.Total("AmountCur") Then
		MessageText = NStr("en = 'The invoice amount is less than the clearing amount.'");
		Common.MessageToUser(MessageText,,,, Cancel);
	EndIf;
```

Và Jet kiểm tra ở object module, ví dụ BankPayment bỏ yêu cầu nhập Counterparty khi Operation = Other:

Nguồn: Jet — cf/Documents/BankPayment/Ext/ObjectModule.bsl
```bsl
Procedure FillCheckProcessing(Cancel, CheckedAttributes)
	
	If Operation = Enums.BankPaymentOperations.Other Then
		CheckedAttributes.Delete(CheckedAttributes.Find("Counterparty"));
	EndIf;
	
EndProcedure
```

Code minh họa — chạy thử để kiểm chứng. Giả định chứng từ không ghi sổ `SupplierOrder` có attribute `ExpectedDeliveryDate`. Đặt trong **object module** của `SupplierOrder`, `#Region EventHandlers`, bên trong `#If Server Or ExternalConnection Then … #EndIf` giống object module của Jet:
```bsl
Procedure FillCheckProcessing(Cancel, CheckedAttributes)
	
	If ValueIsFilled(ExpectedDeliveryDate) And ExpectedDeliveryDate < BegOfDay(Date) Then
		MessageText = NStr("en = 'Ngày giao dự kiến không được sớm hơn ngày đặt hàng.'");
		Common.MessageToUser(MessageText, ThisObject, "ExpectedDeliveryDate", , Cancel);
	EndIf;
	
EndProcedure
```

Dòng này nghĩa là:
- `FillCheckProcessing` — "bước soát lỗi trước khi lưu phiếu". Chứng từ không ghi sổ thì bước này chạy khi bấm **Write** (Bài 16). Đây cũng là ví dụ của Bài 12: "Sales order có Shipment date không được sớm hơn ngày document".
- `ValueIsFilled(ExpectedDeliveryDate)` — "chỉ soát khi đã nhập ngày giao" (chưa nhập thì để tùy chọn bắt buộc nhập lo).
- `< BegOfDay(Date)` — "ngày giao trước ngày đặt hàng là vô lý".
- `Common.MessageToUser(…, ThisObject, "ExpectedDeliveryDate", , Cancel)` — "hiện thông báo cạnh ô Ngày giao và **không cho lưu**" (`Cancel` thành True). Dùng Cancel thay vì dừng hẳn để nếu có nhiều lỗi, người dùng thấy hết một lần (Bài 12).

Chỉ muốn **nhắc** mà vẫn cho lưu: bỏ tham số `Cancel` ở cuối. Muốn nhắc ngay lúc chọn ngày (trước khi lưu): tạo handler OnChange của ô trên form và gọi `ShowMessageBox(, "…")` — Jet dùng đúng lệnh này khi chưa chọn khách mà bấm "Select advances". Nguồn: Jet — cf/Documents/SalesInvoice/Forms/DocumentForm/Ext/Form/Module.bsl (`ShowMessageBox(, NStr("en = 'Please specify the customer.'"));`). [suy luận] Chuỗi tiếng Việt đặt trong `NStr("en = '…'")` vẫn hiển thị khi giao diện chạy tiếng Anh — kiểm tra trên máy.

### 5.4. Đọc giá trị hiện hành từ sổ thông tin bằng SliceLast (Đề 7 — hạn thanh toán)

Khuôn của Jet — tra giá bán bằng `SliceLast` tại ngày chứng từ:

Nguồn: Jet — cf/CommonModules/PriceManagementServerCall/Ext/Module.bsl
```bsl
	"SELECT ALLOWED
	|	PricesSliceLast.Price * &DocumentRepetition / &DocumentRate AS Price
	|FROM
	|	InformationRegister.Prices.SliceLast(
	|			&PriceDate,
	|			PriceType = &PriceType
	|				AND Product = &Product) AS PricesSliceLast";
```

Và khuôn đọc thuộc tính của khách khi chọn khách:

Nguồn: Jet — cf/Documents/SalesInvoice/Forms/DocumentForm/Ext/Form/Module.bsl
```bsl
&AtClient
Procedure CustomerOnChange(Item)
	
	PriceType = GetCustomerPriceType(Object.Customer);
	If ValueIsFilled(PriceType) Then
		Object.PriceType = PriceType;
		PriceManagementClient.RefillTabularSectionPricesByPriceType(ThisObject);
	EndIf;
	
EndProcedure
```

Giả định: sổ thông tin **định kỳ theo ngày** `PaymentTerms` (dimension `Counterparty`; resources `PaymentDays`, `CreditLimit`) và attribute `DueDate` trên SalesInvoice.

Code minh họa — chạy thử để kiểm chứng (form module của SalesInvoice):
```bsl
// Trong procedure CÓ SẴN CustomerOnChange, thêm một dòng cuối:
	FillDueDate(); // Nhóm 07 — Đề 7

// Thêm mới, đặt trong #Region Private:
&AtClient
Procedure FillDueDate()
	
	PaymentDays = GetPaymentDays(Object.Customer, Object.Date);
	Object.DueDate = BegOfDay(Object.Date) + PaymentDays * 86400;
	
EndProcedure

&AtServerNoContext
Function GetPaymentDays(Customer, DocumentDate)
	
	If Not ValueIsFilled(Customer) Then
		Return 0;
	EndIf;
	
	Query = New Query;
	Query.Text =
	"SELECT ALLOWED
	|	PaymentTermsSliceLast.PaymentDays AS PaymentDays
	|FROM
	|	InformationRegister.PaymentTerms.SliceLast(
	|			&DocumentDate,
	|			Counterparty = &Customer) AS PaymentTermsSliceLast";
	
	Query.SetParameter("DocumentDate", DocumentDate);
	Query.SetParameter("Customer", Customer);
	
	Selection = Query.Execute().Select();
	If Selection.Next() Then
		Return Selection.PaymentDays;
	EndIf;
	
	Return 0;
	
EndFunction
```

Dòng này nghĩa là:
- `FillDueDate();` trong `CustomerOnChange` — "chọn khách xong thì, cùng lúc với việc Jet điền loại giá, điền luôn hạn thanh toán".
- `SliceLast(&DocumentDate, Counterparty = &Customer)` — "lấy điều khoản thanh toán **đang hiệu lực vào ngày lập hóa đơn** của đúng khách này". Nếu tháng 3 khách được nợ 30 ngày, tháng 5 đổi thành 45 ngày, hóa đơn ngày 10/4 vẫn lấy 30 (Bài 12, ví dụ SliceLast).
- `Return 0` — "khách chưa có điều khoản → coi như trả ngay".
- `BegOfDay(Object.Date) + PaymentDays * 86400` — "ngày hóa đơn cộng số ngày được nợ"; trong 1C, cộng một số vào ngày là cộng **giây**, nên một ngày = 86400 giây (Bài 5–6: "Date + Number cộng giây").

Lưu ý:
- Đổi **ngày** hóa đơn thì hạn không tự tính lại — muốn vậy, tạo handler OnChange của ô Date và gọi `FillDueDate();`.
- Role của người bán (`UseSales`) phải có **Read** trên sổ `PaymentTerms` (mục 4.9), vì hàm này chạy với quyền của người dùng.

### 5.5. Điền phần bảng từ số dư của sổ (Đề 9 — điền SL sổ sách)

Khuôn của Jet — đọc bảng ảo `Balance` của sổ:

Nguồn: Jet — cf/AccumulationRegisters/InventoryInWarehouses/Ext/ManagerModule.bsl
```bsl
		|		INNER JOIN AccumulationRegister.InventoryInWarehouses.Balance(, ) AS InventoryInWarehousesBalance
```

Và khuôn nạp kết quả query vào một bảng trên form bằng `Load(… .Unload())`:

Nguồn: Jet — cf/CommonForms/SelectAdvances/Ext/Form/Module.bsl
```bsl
	QueryResult = Query.Execute();
	
	AdvanceBalance.Load(QueryResult.Unload());
```

Code minh họa — chạy thử để kiểm chứng. Trên form `InventoryCount`: tạo form command `FillBookQuantity` (Bài 9, Form commands), kéo lên thanh lệnh của bảng `Inventory` thành nút "Điền SL sổ sách"; code trong form module:
```bsl
#Region FormCommandsEventHandlers

&AtClient
Procedure FillBookQuantity(Command)
	
	If Not ValueIsFilled(Object.Warehouse) Then
		ShowMessageBox(, NStr("en = 'Hãy chọn kho trước.'"));
		Return;
	EndIf;
	
	FillBookQuantityAtServer();
	
EndProcedure

#EndRegion

#Region Private

&AtServer
Procedure FillBookQuantityAtServer()
	
	// Thời điểm lấy số sổ sách — câu hỏi phân tích bắt buộc số 3 của Đề 9.
	// Phương án A (đang dùng): cuối ngày của phiếu kiểm kê.
	// Phương án B: để trống (Undefined) = số dư hiện tại.
	// Nhóm tự chọn và lập luận trong báo cáo.
	BalanceDate = EndOfDay(Object.Date);
	
	Query = New Query;
	Query.Text =
	"SELECT ALLOWED
	|	InventoryBalance.Product AS Product,
	|	InventoryBalance.QuantityBalance AS BookQuantity
	|FROM
	|	AccumulationRegister.InventoryInWarehouses.Balance(
	|			&BalanceDate,
	|			Warehouse = &Warehouse) AS InventoryBalance
	|
	|ORDER BY
	|	Product";
	
	Query.SetParameter("BalanceDate", BalanceDate);
	Query.SetParameter("Warehouse", Object.Warehouse);
	
	Object.Inventory.Load(Query.Execute().Unload());
	
	For Each TabSectionRow In Object.Inventory Do
		TabSectionRow.ActualQuantity = TabSectionRow.BookQuantity;
		TabSectionRow.Difference = 0;
	EndDo;
	
	Modified = True;
	
EndProcedure

#EndRegion
```

Dòng này nghĩa là:
- `If Not ValueIsFilled(Object.Warehouse)` — "chưa chọn kho thì không biết kiểm kho nào — nhắc và dừng".
- `FillBookQuantityAtServer()` là `&AtServer` (không phải `NoContext`) vì nó phải **sửa chính phiếu đang mở** (`Object`) và đọc sổ (Bài 7, Bài 10).
- `InventoryInWarehouses.Balance(&BalanceDate, Warehouse = &Warehouse)` — "sổ tồn kho cho biết: tại thời điểm đó, kho này còn bao nhiêu từng mặt hàng". Mặt hàng tồn bằng 0 thường không có dòng (ngoài giáo trình — hãy kiểm tra lại trong Syntax assistant).
- `QuantityBalance AS BookQuantity` — đổi tên cột cho **trùng tên cột** của phần bảng, vì `Load` ghép theo tên (Bài 10, thẻ Practice 10 Bài 6).
- `Object.Inventory.Load(...)` — "xóa các dòng cũ, chép danh sách tồn vào phiếu".
- Vòng `For Each` — "điền sẵn số thực tế bằng số sổ sách, chênh lệch 0; người kiểm chỉ sửa dòng nào đếm ra khác". Đây là một lựa chọn trình bày; nhóm có thể để trống số thực tế nếu muốn buộc người kiểm nhập từng dòng.
- `Modified = True` — "đánh dấu phiếu đã thay đổi, nhắc lưu khi đóng".
- Thời điểm `BalanceDate` cố ý để thành chú thích lựa chọn: chọn thời điểm nào, và có cần khóa nhập xuất trong lúc kiểm không, là câu hỏi phân tích được chấm điểm. Liên hệ khái niệm PointInTime / Boundary của Bài 11 nếu nhóm muốn số dư "đúng tại thời điểm phiếu".
- Role nhóm (`UseWarehouses`) đã có Read trên `InventoryInWarehouses` nên không cần cấp thêm. Nguồn: Jet — cf/Roles/UseWarehouses/Ext/Rights.xml.

Bước tự động tạo `InventoryIncrease` / `InventoryWriteOff` từ phiếu kiểm kê (phần còn lại của hạng mục M3 Đề 9) là tạo **chứng từ có ghi sổ** bằng code — làm cùng tutor (mục 6).

---

## 6. Khi nào cần gọi tutor

Gọi tutor **trước khi làm** (không phải sau khi hỏng) khi:

1. **Chạm vào việc ghi sổ**: sửa object module / manager module của chứng từ có posting (`Posting`, `InitializeDocumentData`), sửa `PostingManagement`, thêm sổ tích lũy mới, thêm sổ vào register records của chứng từ. Câu query ghi sổ của Jet là một batch đánh số `QueryResult[n]` — thêm bớt một query là lệch hết (mục 10.1 của `references/jet-1-overview-extending-cash.md#jet-overview`).
2. **Thêm chiều (dimension) vào sổ dùng chung**: `InventoryInWarehouses` và `InventoryCost` được 5 chứng từ ghi (SupplierInvoice, SalesInvoice thuộc nhóm Mua và Bán; 3 chứng từ kho), `Sales` và `CustomerBalance` dính SalesInvoice và chứng từ thu tiền. Thêm chiều Lô (Đề 1) hay Nhân viên/Khu vực (Đề 6) là phải sửa ghi sổ của mọi chứng từ đó và ảnh hưởng nhóm khác — phải thống nhất với tutor và các nhóm liên quan.
3. **Muốn đổi số liệu đi vào sổ** dù chỉ gián tiếp: trừ chiết khấu vào Amount (Đề 5), chặn bán khi vượt hạn mức (Đề 7, "mã ghi sổ"), tự tạo chứng từ có ghi sổ từ phiếu kiểm kê (Đề 9) hoặc từ báo cáo (Đề 2).
4. **Lỗi lặp lại sau 2 lần thử**: cùng một thông báo lỗi khi F7, khi mở form hoặc khi post. Mang theo: ảnh chụp thông báo, bước vừa làm, file `.dt` gần nhất.
5. **Lỗi quyền không tự sửa được**: "Access violation!" dù đã tick quyền theo 4.9; user thử không thấy phân hệ; không biết lập hồ sơ quyền (access group) của SSL để thử user thường.
6. **Bất cứ thứ gì thuộc SSL**: module có tên kết thúc `Overridable`, defined types, event subscriptions, object có biểu tượng khóa, `Configuration - Support - Support options` (Bài 21). SSL là thư viện chung — sửa sai ở đây có thể hỏng chức năng của cả cấu hình.
7. **Đổi Name** của bất cứ thứ gì đã có trong Jet, xóa attribute / object của Jet, hoặc đổi kiểu dữ liệu của attribute đã có dữ liệu.
8. **Muốn dùng Extension** (phần mở rộng cấu hình) thay vì sửa trực tiếp — có giới hạn riêng (safe mode, xóa extension là mất dữ liệu attribute đã thêm) (mục 4.3 của `references/jet-1-overview-extending-cash.md#jet-extending`).
9. **Restore `.dt`** khi không chắc infobase nào là đích — restore ghi đè toàn bộ.

Không cần gọi tutor cho: đổi Synonym / Object presentation, thêm attribute hay cột mới, tạo danh mục / liệt kê / sổ thông tin / chứng từ không ghi sổ mới, kéo ô lên form, đưa object vào phân hệ, tick quyền cho object **mới** của nhóm, làm báo cáo DCS chỉ đọc dữ liệu — miễn là đã dump `.dt` trước và thử bằng một chứng từ sau mỗi thay đổi (mục 3).


---

# § ngan-hang-y-tuong

# Ngân hàng ý tưởng mở rộng 1C:Jet cho bài tập lớn (ngoài 9 đề chính thức)

Khi nào đọc file này: khi nhóm muốn **tự đề xuất đề tài** hoặc cần **ý tưởng bổ sung** cho phần "Phát triển thêm" của bài tập lớn, khi giảng viên/tutor cần gợi ý đề mới không trùng 9 đề trong `de-bai-btl.md`, hoặc khi sinh viên hỏi "còn hướng mở rộng Jet nào khác không / tìm ý tưởng ở đâu".

> Mọi ý tưởng dưới đây là **đề xuất, chưa có trong Jet**. Phần "Jet đang có" đã đối chiếu với cấu hình Jet nhánh `community`, commit `80884de` (thư mục `cf/`). Mức M1/M2/M3, cách chấm và quy định chung theo `de-bai-btl.md` (mục 2.3). Ước lượng công sức là **[ước lượng]** của người soạn, không phải quy định của giảng viên — nhóm cần trao đổi với giảng viên trước khi chốt đề.

**9 đề chính thức (không lặp lại ở đây):** Đề 1 Lô hàng và hạn sử dụng · Đề 2 Định mức tồn kho chuỗi cửa hàng · Đề 3 Đơn đặt hàng nhà cung cấp · Đề 4 Đánh giá nhà cung cấp · Đề 5 Chiết khấu theo số lượng · Đề 6 Nhân viên kinh doanh và khu vực · Đề 7 Hạn thanh toán và tuổi nợ · Đề 8 Khoản mục chi phí và ngân sách · Đề 9 Kiểm kê kho và xử lý chênh lệch. Lưu ý Đề 1: ngay ở M2, cột Lô đã chạm SupplierInvoice và SalesInvoice của nhóm Purchases và Sales — cảnh báo va chạm áp dụng từ M2 (chi tiết: `de-tai-1-5.md`, mục 1.1 và mục 6).

## Mục lục

- [0. Cách đọc một thẻ ý tưởng](#0-cách-đọc-một-thẻ-ý-tưởng)
- [1. Ý tưởng theo phân hệ](#1-ý-tưởng-theo-phân-hệ)
  - [1.1. Warehouses (Kho) — W1–W8](#11-warehouses-kho--w1w8)
  - [1.2. Purchases (Mua hàng) — P1–P7](#12-purchases-mua-hàng--p1p7)
  - [1.3. Sales (Bán hàng) — S1–S7](#13-sales-bán-hàng--s1s7)
  - [1.4. CashManagement (Tiền) — C1–C7](#14-cashmanagement-tiền--c1c7)
  - [1.5. Liên phân hệ / Logistics — L1–L8](#15-liên-phân-hệ--logistics--l1l8)
  - [1.6. Tích hợp, di động, phân tích — I1–I3](#16-tích-hợp-di-động-phân-tích--i1i3-ngoài-24-bài-cho-nhóm-khá)
  - [1.7. Từ case doanh nghiệp thật — E1–E14](#17-từ-case-doanh-nghiệp-thật-đã-ẩn-danh--e1e14)
- [2. Bảng chọn đề nhanh](#2-bảng-chọn-đề-nhanh)
- [3. Nguồn để tìm thêm ý tưởng](#3-nguồn-để-tìm-thêm-ý-tưởng)
- [4. Hướng dẫn tự phát triển ý tưởng](#4-hướng-dẫn-tự-phát-triển-ý-tưởng)

---

## 0. Cách đọc một thẻ ý tưởng

Mỗi thẻ có cùng cấu trúc:

- **Bài toán** — nỗi đau nghiệp vụ của một doanh nghiệp giả định (bối cảnh Việt Nam).
- **Jet đang có** — những gì cấu hình gốc đã ghi nhận được, kèm `Nguồn: Jet — cf/...`.
- **Khoảng trống** — dữ liệu hoặc kiểm soát còn thiếu, gắn với hậu quả (mất tiền, mất hàng, chậm giao, quyết định sai).
- **Đối tượng thêm** — tên gợi ý (tiếng Anh, theo quy ước Jet), loại object 1C, mức M1/M2/M3.
- **Phù hợp** — *nhóm 2 (trái ngành)*: phần M2 đủ để đạt điểm thiết kế, code (nếu có) đơn giản; *nhóm 1 (IT)*: có hạng mục M3 đáng làm (posting, register mới, code form).
- **Khả thi** — công sức [ước lượng] (Thấp ≈ ≤1 tuần nhóm, Vừa ≈ 1–2 tuần, Cao ≈ >2 tuần), và **rủi ro chạm register dùng chung**: `InventoryInWarehouses`, `InventoryCost`, `CustomerBalance`, `SupplierBalance` được nhiều phân hệ ghi (`jet-overview.md` mục 5) — sửa chúng phải phối hợp với nhóm khác.

Quy ước mức (theo `de-bai-btl.md` 2.3): **M2** = Catalog, Enumeration, attribute mới, Information register nhập tay, Document **không ghi sổ**, Subsystem, báo cáo DCS trên dữ liệu có sẵn — không viết mã. **M3** = thêm dimension hoặc Accumulation register mới, sửa logic Posting, tự động hóa trên form.

> Lối tắt cho nhóm 2: Jet có sẵn **Additional attributes** của SSL cho Catalog Products, Counterparties, Warehouses… và cho 9 Document nghiệp vụ (tập `Catalog_Warehouses`, `Document_SalesInvoice`… — Nguồn: Jet — cf/CommonModules/PropertyManagerOverridable/Ext/Module.bsl). Wiki Jet gợi ý dùng công cụ này để thêm trường như "vị trí, người phụ trách, loại kho" cho kho (Nguồn: jet-wiki/1C:Jet-Initial-Setup-Guide.md). Đây là **dữ liệu nhập trong Enterprise mode**, không phải metadata mới — dùng tốt để thử ý tưởng nhanh (M1), nhưng hạng mục M2 của bài tập lớn yêu cầu thao tác trong Designer; hỏi giảng viên nếu muốn tính phần này.

---

## 1. Ý tưởng theo phân hệ

### 1.1. Warehouses (Kho) — W1–W8

#### W1 — Vị trí lưu kho (kệ / ô / bin)
- **Bài toán:** Kho phụ tùng ô tô 2.000 m² ở Bắc Ninh, thủ kho mới mất 10–15 phút tìm một mã hàng; hàng bị đặt sai kệ thì coi như "mất".
- **Jet đang có:** `Catalog.Warehouses` không phân cấp, chỉ có thông tin liên hệ và thuộc tính bổ sung; register kho chỉ phân tích theo `Product`, `Warehouse` (Nguồn: Jet — cf/Catalogs/Warehouses.xml, cf/AccumulationRegisters/InventoryInWarehouses.xml).
- **Khoảng trống:** không biết hàng nằm ở đâu trong kho → chậm soạn hàng, sai sót khi xuất.
- **Đối tượng thêm:**
  - `Catalog.StorageBins` — **Catalog** subordinate tới `Warehouses` (Owner), có thể hierarchical (Dãy → Kệ → Ô) — **M2**.
  - `InformationRegister.ProductLocations` — Warehouse, Product → StorageBin (vị trí mặc định), non-periodic — **M2**.
  - Báo cáo DCS "Tồn kho kèm vị trí": nối `InventoryInWarehouses.Balance` với register vị trí — **M2**.
  - Dimension `StorageBin` trong register tồn theo ô (register mới, không sửa `InventoryInWarehouses`) — **M3**.
- **Phù hợp:** nhóm 2 (phần M2 rất trực quan) / nhóm 1 (phần M3 register theo ô).
- **Khả thi:** M2 Thấp; M3 Cao vì phải ghi register mới từ mọi chứng từ kho. Không cần sửa register dùng chung nếu tách register riêng. Cơ chế: Owner + hierarchy (Bài 1–4), Information register (Bài 12), DCS (Bài 18).

#### W2 — Thủ kho phụ trách và lịch sử bàn giao kho
- **Bài toán:** Chuỗi 4 kho của một công ty phân phối đồ uống ở Đà Nẵng đổi thủ kho thường xuyên; khi thất thoát, không xác định được ai phụ trách kho tại ngày phát sinh.
- **Jet đang có:** Document kho có `Author` (người tạo chứng từ, kiểu `CatalogRef.Users`), không có người chịu trách nhiệm kho (Nguồn: Jet — cf/Documents/InventoryTransfer.xml, cf/Documents/SalesInvoice.xml).
- **Khoảng trống:** "người nhập liệu" khác "người chịu trách nhiệm"; không có lịch sử theo thời gian.
- **Đối tượng thêm:**
  - `Catalog.Employees` (nếu nhóm chưa có) — **M2**.
  - `InformationRegister.WarehouseResponsiblePersons` — **periodic** (Day), Warehouse → Employee — **M2**. Đây đúng mẫu "Companies responsible persons" trong Bài 12.
  - Báo cáo DCS chứng từ kho trong kỳ kèm thủ kho tại ngày chứng từ (SliceLast) — **M2/M3** (DCS có tham số ngày là M2; nếu cần lấy theo từng ngày chứng từ thì query phức tạp hơn).
  - Print form "Phiếu xuất kho" có chữ ký thủ kho — **M3** (`AddPrintCommands` của `InventoryTransfer`, `InventoryWriteOff` đang rỗng — Nguồn: Jet — cf/Documents/InventoryTransfer/Ext/ManagerModule.bsl).
- **Phù hợp:** nhóm 2 / nhóm 1 (print form).
- **Khả thi:** Thấp; không chạm register dùng chung. Bài 12 (periodic, independent), Bài 17 + 22 (print).

#### W3 — Kho cách ly hàng lỗi (quarantine) và tồn "có thể bán"
- **Bài toán:** Nhà phân phối điện gia dụng ở TP.HCM nhận hàng móp méo chờ nhà cung cấp xử lý; báo cáo tồn vẫn tính hàng này nên nhân viên bán hứa giao cho khách rồi không có hàng tốt.
- **Jet đang có:** báo cáo `AvailableStock` đọc `InventoryInWarehouses.Balance` cho mọi kho (Nguồn: Jet — cf/Reports/AvailableStock); `InventoryTransfer` chuyển hàng giữa hai kho.
- **Khoảng trống:** không phân biệt kho hàng tốt / kho chờ xử lý → bán nhầm hàng lỗi, sai cam kết giao hàng.
- **Đối tượng thêm:**
  - Attribute `IsQuarantine` (Boolean) hoặc `StockStatus` (Enumeration: Sellable / Quarantine / Damaged) trên `Warehouses` — **M2**.
  - Báo cáo DCS "Tồn có thể bán" lọc theo attribute trên — **M2**.
  - Enumeration `QuarantineReasons` + attribute trên `InventoryTransfer` khi chuyển vào kho cách ly — **M2**.
  - Chặn `SalesInvoice` xuất từ kho cách ly (FillCheckProcessing) — **M3**.
- **Phù hợp:** nhóm 2 / nhóm 1 (kiểm tra khi ghi).
- **Khả thi:** Thấp; M3 chạm `SalesInvoice` (của nhóm Sales) — phối hợp. Bài 12 (data validation).
- **Lưu ý trùng:** Đề 2 đã có "Loại kho (Kho tổng / Cửa hàng)" — ý tưởng này là trạng thái chất lượng, không phải loại kho; nhóm làm Đề 2 không chọn thêm.

#### W4 — Phiếu yêu cầu điều chuyển từ cửa hàng
- **Bài toán:** Cửa hàng gọi điện / nhắn Zalo xin hàng, kho tổng quên hoặc chuyển thiếu; không ai biết yêu cầu nào đã được đáp ứng.
- **Jet đang có:** `InventoryTransfer` (Warehouse, WarehouseReceiver, Inventory: Product, Quantity), không có chứng từ yêu cầu; `InventoryTransfer` không có `BasedOn` (Nguồn: Jet — cf/Documents/InventoryTransfer.xml).
- **Khoảng trống:** không có dấu vết "đã xin – đã chuyển – còn thiếu".
- **Đối tượng thêm:**
  - `Document.TransferRequest` — không ghi sổ: cửa hàng yêu cầu, kho nguồn, ngày cần, tabular section hàng — **M2**.
  - Enumeration `RequestStatuses` (New / Approved / PartiallyShipped / Shipped / Rejected) — **M2**.
  - Attribute `TransferRequest` trên `InventoryTransfer` — **M2**.
  - Tạo `InventoryTransfer` dựa trên yêu cầu (Generation + Filling) — **M3**.
- **Phù hợp:** nhóm 2 / nhóm 1.
- **Khả thi:** Vừa; không chạm register dùng chung. Bài 11 (Generation).
- **Lưu ý trùng:** khác Đề 2 (Đề 2 tự đề xuất điều chuyển từ định mức); có thể kết hợp nếu nhóm Đề 2 muốn thêm bước phê duyệt.

#### W5 — Quy đổi đơn vị tính (thùng / lốc / chai)
- **Bài toán:** Nhà phân phối nước giải khát nhập theo thùng 24 lon, bán lẻ theo lốc 6 lon; kế toán quy đổi bằng tay và hay sai.
- **Jet đang có:** `Catalog.Units` không có attribute nào; `Products.Unit` chỉ một đơn vị (Nguồn: Jet — cf/Catalogs/Units.xml, cf/Catalogs/Products.xml).
- **Khoảng trống:** một mặt hàng chỉ có một đơn vị → nhập sai số lượng gấp 6 hoặc 24 lần, lệch tồn kho.
- **Đối tượng thêm:**
  - `InformationRegister.ProductUnitConversions` — Product, Unit → Factor (hệ số quy về đơn vị gốc) — **M2**.
  - Cột `Unit` và `QuantityInUnit` trên tabular section `Inventory` của chứng từ — **M2** (chỉ lưu).
  - Tự tính `Quantity` = QuantityInUnit × Factor trên form — **M3**.
- **Phù hợp:** nhóm 2 (M2) / nhóm 1 (M3, cẩn thận vì `InventoryTabularSectionClientServer` dùng chung cho SupplierInvoice và SalesInvoice — Nguồn: Jet — cf/CommonModules/InventoryTabularSectionClientServer/Ext/Module.bsl).
- **Khả thi:** Vừa; M3 chạm form của nhiều chứng từ.

#### W6 — Khối lượng, thể tích và kế hoạch xếp xe
- **Bài toán:** Công ty vật liệu xây dựng giao bằng xe 2,5 tấn và 8 tấn; điều phối không biết một phiếu xuất nặng bao nhiêu nên xe chạy quá tải hoặc chạy rỗng.
- **Jet đang có:** `Products` có `DetailedDescription`, `ProductType`, `Unit`, `VATRate` — không có khối lượng, thể tích (Nguồn: Jet — cf/Catalogs/Products.xml).
- **Khoảng trống:** không tính được tải trọng chuyến → phạt quá tải, tốn chi phí vận chuyển.
- **Đối tượng thêm:**
  - Attribute `Weight`, `Volume` trên `Products` — **M2**.
  - Báo cáo DCS "Tổng khối lượng theo chứng từ xuất" đọc từ tabular section `Inventory` của `SalesInvoice` / `InventoryTransfer` nối với `Products` — **M2**.
  - Cảnh báo khi tổng khối lượng vượt tải trọng xe (kết hợp L1) — **M3**.
- **Phù hợp:** nhóm 2 (rất hợp lớp Logistics).
- **Khả thi:** Thấp; không chạm register. Báo cáo đọc từ chứng từ — xem câu hỏi "báo cáo đọc từ chứng từ khác báo cáo đọc từ sổ" ở Đề 6.

#### W7 — Mã vạch sản phẩm
- **Bài toán:** Siêu thị mini 3.000 mã hàng nhập bằng tay, nhân viên chọn nhầm mã gần tên ("Sữa TH 180ml" và "Sữa TH 110ml").
- **Jet đang có:** `Products` không có trường mã vạch (Nguồn: Jet — cf/Catalogs/Products.xml); có import danh mục từ file qua `ImportDataFromFileJet` (Nguồn: Jet — cf/CommonModules/ImportDataFromFileJet).
- **Khoảng trống:** chọn nhầm hàng → lệch tồn, sai giá.
- **Đối tượng thêm:**
  - `InformationRegister.Barcodes` — Barcode (String) → Product, Unit — **M2** (một sản phẩm nhiều mã, mỗi mã một sản phẩm: chiều là Barcode).
  - Ô nhập mã vạch trên form chứng từ, tìm sản phẩm và thêm dòng — **M3**.
- **Phù hợp:** nhóm 2 (thiết kế register) / nhóm 1 (form).
- **Khả thi:** Thấp–Vừa; không chạm register dùng chung. Câu hỏi thiết kế hay: vì sao Barcode là chiều chứ không phải attribute của Products?

#### W8 — Thẻ kho và nhật ký chứng từ kho
- **Bài toán:** Kế toán kho cần "thẻ kho" theo mẫu quen thuộc (nhập – xuất – tồn từng chứng từ) và một danh sách chung mọi chứng từ kho để rà soát cuối ngày.
- **Jet đang có:** `StockStatement` (tổng hợp theo kỳ, từ `InventoryCost.BalanceAndTurnovers`); Document journal duy nhất là `Interactions` của SSL — không có nhật ký chứng từ kho (Nguồn: Jet — cf/Reports/StockStatement, cf/DocumentJournals/Interactions.xml).
- **Khoảng trống:** khó truy vết từng nghiệp vụ của một mặt hàng.
- **Đối tượng thêm:**
  - Báo cáo DCS "Thẻ kho" theo Recorder — **M2** (DCS trên register có sẵn; xem `jet-warehouse.md` Gợi ý 4).
  - `DocumentJournal.WarehouseDocuments` gồm 5 chứng từ có ghi kho, cột Warehouse — **M2** (Bài 13).
- **Phù hợp:** nhóm 2 — đề "khởi động" tốt, nên ghép với một ý tưởng khác cho đủ khối lượng.
- **Khả thi:** Thấp; chỉ đọc dữ liệu.

### 1.2. Purchases (Mua hàng) — P1–P7

#### P1 — Trả hàng cho nhà cung cấp
- **Bài toán:** Công ty thiết bị y tế trả lại lô máy đo huyết áp lỗi; hiện kế toán "xuất hủy" bằng `InventoryWriteOff` nên công nợ phải trả không giảm.
- **Jet đang có:** chỉ `SupplierInvoice` ghi `SupplierBalance`; `InventoryWriteOff` không có đơn giá, không có nhà cung cấp (Nguồn: Jet — cf/Documents/SupplierInvoice.xml, cf/Documents/InventoryWriteOff.xml).
- **Khoảng trống:** tồn kho giảm nhưng nợ nhà cung cấp không giảm → trả tiền cho hàng đã trả lại.
- **Đối tượng thêm:**
  - `Document.SupplierReturn` — không ghi sổ, attribute `SupplierInvoice` (hóa đơn gốc), tabular section hàng — **M2**.
  - Enumeration `ReturnReasons` (Defective / WrongItem / Excess / Expired) — **M2**.
  - Posting: Expense `InventoryInWarehouses`, `InventoryCost`, `SupplierBalance`; số âm vào `Purchases` — **M3** (chi tiết: `jet-purchases.md` Gợi ý 2).
- **Phù hợp:** nhóm 2 (M2) / nhóm 1 (M3 — đề nặng).
- **Khả thi:** M3 Cao; **chạm 3 register dùng chung** và `Sequence.InventoryCostRecalculation` → phối hợp nhóm Kho và nhóm Tiền.

#### P2 — Bảng giá mua theo nhà cung cấp
- **Bài toán:** Nhà hàng chuỗi mua rau, thịt từ 5 nhà cung cấp, giá đổi hằng tuần; nhân viên mua nhập giá theo trí nhớ.
- **Jet đang có:** `SupplierInvoice` nhập giá tay; `InformationRegister.Prices` (periodic Day, Independent) chỉ dùng cho giá bán theo `PriceType` (Nguồn: Jet — cf/InformationRegisters/Prices.xml).
- **Khoảng trống:** không có giá mua thỏa thuận để đối chiếu → mua đắt mà không biết.
- **Đối tượng thêm:**
  - `InformationRegister.SupplierPrices` — periodic Day, Counterparty, Product → Price — **M2**.
  - Báo cáo DCS so sánh giá thỏa thuận (SliceLast) với giá thực mua (sổ `Purchases`) — **M2**.
  - Tự điền giá khi chọn sản phẩm trên `SupplierInvoice` — **M3** (`jet-purchases.md` Gợi ý 3).
- **Phù hợp:** nhóm 2 / nhóm 1.
- **Khả thi:** Thấp–Vừa. **Lưu ý trùng:** Đề 4 có báo cáo giá mua bình quân và cam kết cung ứng; P2 là giá thỏa thuận theo thời gian — nhóm Đề 4 không chọn thêm.

#### P3 — Chi phí mua hàng (vận chuyển, bốc xếp, hải quan)
- **Bài toán:** Công ty nhập khẩu hạt nhựa trả thêm phí vận chuyển nội địa và phí hải quan bằng 5–8% giá hàng; giá vốn trên Jet thấp hơn thực tế nên lãi gộp bị "ảo".
- **Jet đang có:** `InventoryCost` nhận `Amount` từ `SupplierInvoice`; không có chứng từ phân bổ chi phí (Nguồn: Jet — cf/AccumulationRegisters/InventoryCost.xml).
- **Khoảng trống:** giá vốn thiếu chi phí mua → định giá bán sai, báo cáo `ProfitOnSales` cao hơn thực.
- **Đối tượng thêm:**
  - `Document.AdditionalPurchaseCosts` — không ghi sổ: nhà cung cấp dịch vụ, hóa đơn hàng gốc, số tiền, cách phân bổ (Enumeration: ByAmount / ByQuantity / ByWeight) — **M2**.
  - Posting: Receipt chỉ `Amount` vào `InventoryCost`, Receipt `SupplierBalance` — **M3** (`jet-purchases.md` Gợi ý 6, đề khó nhất).
- **Phù hợp:** nhóm 2 (M1 + M2 phân tích tác động giá vốn) / nhóm 1 mạnh (M3).
- **Khả thi:** M3 Cao, rủi ro lớn: `InventoryCost`, `SupplierBalance`, Sequence.

#### P4 — Hợp đồng khung với nhà cung cấp
- **Bài toán:** Công ty xây dựng ký hợp đồng năm với nhà cung cấp thép (giá trần, thời hạn, tổng giá trị); mua vượt giá trị hợp đồng mà không ai hay.
- **Jet đang có:** `Counterparties` có `Customer`, `Supplier`, `LegalName`, `TIN`, `PriceType`… — không có hợp đồng (Nguồn: Jet — cf/Catalogs/Counterparties.xml).
- **Khoảng trống:** không gắn hóa đơn với hợp đồng → vượt hạn mức, mua sau khi hợp đồng hết hạn.
- **Đối tượng thêm:**
  - `Catalog.Contracts` — subordinate tới `Counterparties` (Owner): ValidFrom, ValidTo, ContractAmount, Currency — **M2**.
  - Attribute `Contract` trên `SupplierInvoice`, choice parameter link lọc theo `Supplier` — **M2** (Bài 1–4 có đúng ví dụ Contract lọc theo Customer bằng `Filter.Owner`).
  - Báo cáo DCS "Thực hiện hợp đồng" (đã mua / giá trị hợp đồng) đọc từ chứng từ — **M2**.
  - Chặn ghi hóa đơn ngoài thời hạn hợp đồng — **M3**.
- **Phù hợp:** nhóm 2 / nhóm 1. Áp dụng tương tự phía bán (hợp đồng khách hàng).
- **Khả thi:** Thấp–Vừa; không chạm register.

#### P5 — Kiểm tra chất lượng khi nhận hàng (QC)
- **Bài toán:** Công ty thực phẩm đông lạnh phải kiểm nhiệt độ, bao bì khi nhận; hàng không đạt vẫn được nhập kho chung vì không có bước ghi nhận.
- **Jet đang có:** `SupplierInvoice` ghi thẳng vào kho khi post; có print form `PF_MXL_GoodsReceivedNote` (Nguồn: Jet — cf/Documents/SupplierInvoice/Ext/ManagerModule.bsl).
- **Khoảng trống:** không có kết quả kiểm định → không có căn cứ đòi nhà cung cấp, hàng lỗi lẫn vào hàng tốt.
- **Đối tượng thêm:**
  - `Document.GoodsInspection` — không ghi sổ: SupplierInvoice, người kiểm, tabular section Product, QuantityChecked, QuantityRejected, Result — **M2**.
  - Enumeration `InspectionResults` (Passed / Rejected / ConditionallyAccepted) — **M2**.
  - Báo cáo DCS tỷ lệ hàng lỗi theo nhà cung cấp — **M2**.
  - Tạo `InventoryTransfer` sang kho cách ly (W3) từ phiếu kiểm — **M3**.
- **Phù hợp:** nhóm 2 / nhóm 1.
- **Khả thi:** Vừa; không chạm register ở mức M2.

#### P6 — Hàng mua đang đi đường (nhập khẩu)
- **Bài toán:** Công ty nhập linh kiện từ Thâm Quyến, nhận hóa đơn khi hàng xuống tàu, 7–12 ngày sau mới về kho Hải Phòng; báo cáo tồn kho "có hàng" khi hàng còn trên biển.
- **Jet đang có:** `SupplierInvoice` ghi Receipt vào `Warehouse` của chứng từ ngay khi post (Nguồn: Jet — cf/Documents/SupplierInvoice/Ext/ManagerModule.bsl).
- **Khoảng trống:** không tách "đã là của mình nhưng chưa về kho" → hứa giao sai, khó theo dõi container.
- **Đối tượng thêm:**
  - Cách làm **không cần Designer** (M1 + dữ liệu): tạo một item Warehouses "Hàng đi đường", nhập hóa đơn vào kho này, khi hàng về dùng `InventoryTransfer` sang kho thật — dùng để phân tích trong phần "Vận hành Jet gốc".
  - Attribute `ContainerNumber`, `VesselName`, `ETA` (ngày dự kiến về) trên `SupplierInvoice` — **M2**.
  - Báo cáo DCS "Lô hàng đang về theo ETA" — **M2**.
- **Phù hợp:** nhóm 2 (rất hợp Logistics).
- **Khả thi:** Thấp. **Lưu ý trùng:** Đề 3 theo dõi "đã đặt nhưng chưa nhận hóa đơn"; P6 là "đã nhận hóa đơn nhưng hàng chưa về" — hai giai đoạn khác nhau của cùng chuỗi.

#### P7 — Đề nghị mua hàng nội bộ và phê duyệt
- **Bài toán:** Phòng ban gửi email xin mua; giám đốc duyệt miệng; cuối tháng không biết khoản mua nào đã được duyệt.
- **Jet đang có:** không có chứng từ trước `SupplierInvoice`.
- **Khoảng trống:** mua không qua duyệt → chi vượt, khó kiểm soát nội bộ.
- **Đối tượng thêm:**
  - `Document.PurchaseRequest` — không ghi sổ: bộ phận đề nghị, người duyệt, tabular section hàng, lý do — **M2**.
  - Enumeration `ApprovalStatuses` — **M2** (dùng lại cho C6).
  - Role riêng chỉ cho người duyệt sửa trạng thái — **M2/M3** (Bài 20; tạo role là khai báo, nhưng giới hạn theo trạng thái cần code).
- **Phù hợp:** nhóm 2.
- **Khả thi:** Thấp. Bổ sung tự nhiên cho Đề 3 (đề nghị → đơn đặt hàng → hóa đơn).

### 1.3. Sales (Bán hàng) — S1–S7

#### S1 — Đơn đặt hàng của khách (SalesOrder) và giữ hàng
- **Bài toán:** Nhà phân phối thiết bị vệ sinh nhận đơn của đại lý trước 3–5 ngày; hai nhân viên bán cùng một lô cho hai khách vì không ai "giữ hàng".
- **Jet đang có:** chỉ `SalesInvoice` (ghi nhận đã bán); không có đơn bán (Nguồn: Jet — cf/Documents/SalesInvoice.xml; `de-bai-btl.md` mục 1.4).
- **Khoảng trống:** không biết hàng đã hứa cho ai → bán trùng, giao trễ.
- **Đối tượng thêm:**
  - `Document.SalesOrder` — không ghi sổ, header giống `SalesInvoice` (Customer, Warehouse, PriceType…), tabular section `Inventory` cùng cột — **M2**.
  - Enumeration `SalesOrderStatuses` (New / Confirmed / PartiallyShipped / Shipped / Cancelled) — **M2**.
  - Attribute `SalesOrder` trên `SalesInvoice` — **M2**.
  - `AccumulationRegister.SalesOrders` (Balances): SalesOrder ghi Receipt, SalesInvoice ghi Expense; báo cáo "Đơn chưa giao" — **M3** (`jet-sales.md` Gợi ý 1).
- **Phù hợp:** nhóm 2 / nhóm 1 (M3 rất đáng làm).
- **Khả thi:** M2 Thấp, M3 Vừa–Cao; M3 sửa `InitializeDocumentData` của `SalesInvoice` (nhớ chỉ số `QueryResult[i]`). Đề này là "bản đối xứng" của Đề 3 phía bán.

#### S2 — Khách trả hàng
- **Bài toán:** Chuỗi bán lẻ mỹ phẩm cho đổi trả trong 7 ngày; hiện nhập lại bằng `InventoryIncrease` nên doanh số và công nợ khách không giảm.
- **Jet đang có:** `InventoryIncrease` (dùng nhập số dư đầu) ghi kho nhưng không ghi `Sales`, `CustomerBalance` (Nguồn: Jet — cf/Documents/InventoryIncrease.xml).
- **Khoảng trống:** doanh thu và công nợ bị thổi phồng; giá vốn hàng trả lại sai.
- **Đối tượng thêm:**
  - `Document.CustomerReturn` — không ghi sổ, attribute `SalesInvoice`, Enumeration `ReturnReasons` — **M2**.
  - Posting: số âm vào `Sales`, Receipt kho theo giá vốn của hóa đơn gốc, Expense `CustomerBalance` — **M3** (`jet-sales.md` Gợi ý 2).
- **Phù hợp:** nhóm 2 (M2) / nhóm 1 (M3). Với nhóm 1: cơ chế giống bài thực hành Bài 11 (ReturnOfGoodsFromCustomer) — tutor chỉ **gợi ý** theo mục 3a của SKILL.md.
- **Khả thi:** M3 Cao; **chạm `InventoryCost`, `CustomerBalance`**, type của dimension `Sales.SalesDocument`, Sequence; báo cáo `ProfitOnSales` cần xem lại.

#### S3 — Báo giá (Quotation)
- **Bài toán:** Công ty thiết bị văn phòng gửi báo giá cho 30 khách/tuần bằng Excel; không biết tỷ lệ báo giá thành đơn, giá đã báo cho ai.
- **Jet đang có:** report `PriceList` in bảng giá theo loại giá (Nguồn: Jet — cf/Reports/PriceList); không có chứng từ báo giá.
- **Khoảng trống:** mất dấu cơ hội bán, báo giá không nhất quán giữa các nhân viên.
- **Đối tượng thêm:**
  - `Document.Quotation` — không ghi sổ: Customer, ValidUntil, PriceType, tabular section hàng — **M2**.
  - Enumeration `QuotationStatuses` (Sent / Accepted / Rejected / Expired) — **M2**.
  - Báo cáo DCS tỷ lệ chuyển đổi báo giá → hóa đơn — **M2** (nếu có attribute liên kết trên SalesInvoice).
  - Tạo `SalesOrder`/`SalesInvoice` dựa trên báo giá, in báo giá — **M3**.
- **Phù hợp:** nhóm 2 / nhóm 1.
- **Khả thi:** Thấp–Vừa; không chạm register.

#### S4 — Nhiều địa chỉ giao hàng của một khách
- **Bài toán:** Một chuỗi siêu thị có 12 điểm nhận hàng; hóa đơn chỉ ghi tên công ty nên xe giao nhầm điểm.
- **Jet đang có:** `Counterparties` có contact information kiểu `CounterpartyActualAddress`, `CounterpartyLegalAddress` (Nguồn: Jet — cf/CommonModules/ContactsManagerOverridable/Ext/Module.bsl); `SalesInvoice` không có địa chỉ giao.
- **Khoảng trống:** không xác định điểm giao trên từng hóa đơn → giao nhầm, tốn chuyến.
- **Đối tượng thêm:**
  - `Catalog.DeliveryPoints` — subordinate tới `Counterparties`: địa chỉ, người nhận, số điện thoại, khung giờ nhận — **M2**.
  - Attribute `DeliveryPoint` trên `SalesInvoice` (lọc theo Customer) — **M2**.
  - Báo cáo DCS sản lượng giao theo điểm — **M2**.
- **Phù hợp:** nhóm 2. Ghép tốt với L1.
- **Khả thi:** Thấp.

#### S5 — Kênh bán hàng (bán buôn / bán lẻ / sàn TMĐT)
- **Bài toán:** Công ty đồ gia dụng bán qua đại lý, cửa hàng, Shopee, TikTok Shop; ban giám đốc muốn biết lãi gộp theo kênh để quyết định đầu tư.
- **Jet đang có:** sổ `Sales` phân tích theo Counterparty, Product, SalesDocument (Nguồn: Jet — cf/AccumulationRegisters/Sales.xml).
- **Khoảng trống:** không phân tích được theo kênh → phân bổ ngân sách marketing sai.
- **Đối tượng thêm:**
  - `Catalog.SalesChannels` (có thể hierarchical: Online → Shopee, TikTok Shop) — **M2**.
  - Attribute `SalesChannel` trên `SalesInvoice` (mặc định từ khách hàng) — **M2**.
  - Báo cáo DCS doanh số theo kênh đọc từ chứng từ — **M2**.
  - Dimension `SalesChannel` trong `Sales` — **M3**.
- **Phù hợp:** nhóm 2 / nhóm 1.
- **Khả thi:** Thấp (M2). **Lưu ý trùng:** cùng khuôn với Đề 6 (khu vực, nhân viên) — nhóm Đề 6 không chọn thêm; câu hỏi "gắn vào khách hay vào hóa đơn" của Đề 6 áp dụng y hệt.

#### S6 — Lãi gộp chưa VAT
- **Bài toán:** Giám đốc so lãi gộp trên Jet với báo cáo của kế toán thuế, chênh đúng bằng tiền thuế GTGT.
- **Jet đang có:** report `ProfitOnSales` tính doanh thu gồm VAT:

  Nguồn: Jet — cf/Reports/ProfitOnSales/Templates/MainDataCompositionSchema/Ext/Template.xml
  ```
  	SalesTurnovers.AmountTurnover + SalesTurnovers.VATAmountTurnover
  ```
  còn giá vốn lấy từ `InventoryCost` (giá chưa VAT) — xem `jet-sales.md` mục 12.
- **Khoảng trống:** lợi nhuận gộp bị thổi phồng → định giá và thưởng sai.
- **Đối tượng thêm:** variant hoặc report DCS mới với doanh thu chưa VAT, cột tỷ suất lãi gộp — **M2** (DCS trên dữ liệu có sẵn).
- **Phù hợp:** nhóm 2 (đề phân tích tốt) / nhóm 1 (luyện DCS).
- **Khả thi:** Thấp; chỉ đọc. Nên ghép với ý tưởng khác. Trình bày như "quan sát", không khẳng định là lỗi của Jet.

#### S7 — Hóa đơn điện tử (thông tin quản lý)
- **Bài toán:** Doanh nghiệp Việt Nam phải xuất hóa đơn điện tử (Nghị định 123/2020/NĐ-CP); kế toán xuất trên phần mềm của nhà cung cấp HĐĐT rồi không đối chiếu được với hóa đơn bán trên Jet.
- **Jet đang có:** bản gốc không có gì về hóa đơn điện tử. Bản Thổ Nhĩ Kỳ **Jet-TR** có cả phân hệ `EDI` (xem mục 3.2): `SalesInvoice` thêm `IsEInvoice`, `EDocumentNumber`, `EDocumentScenario`…, register `EDocumentsStatuses` (Independent, dimension `ElectronicDocument`) (Nguồn: Jet-TR — cf/Documents/SalesInvoice.xml, cf/InformationRegisters/EDocumentsStatuses.xml).
- **Khoảng trống:** không biết hóa đơn bán nào đã có HĐĐT, số/ký hiệu nào, đã bị hủy hay thay thế chưa → rủi ro thuế.
- **Đối tượng thêm:**
  - Attribute `EInvoiceSymbol`, `EInvoiceNumber`, `EInvoiceDate` trên `SalesInvoice` — **M2**.
  - Enumeration `EInvoiceStatuses` (NotIssued / Issued / Replaced / Cancelled) — **M2**.
  - `InformationRegister.EInvoiceStatusHistory` — periodic, SalesInvoice → Status — **M2** (mô phỏng `EDocumentsStatuses` của Jet-TR).
  - Báo cáo DCS "Hóa đơn bán chưa xuất HĐĐT" — **M2**.
  - Kết nối thật với nhà cung cấp HĐĐT — **ngoài phạm vi** (Jet-TR dùng `EDMServer`, `UBLServer`; tham khảo, không yêu cầu).
- **Phù hợp:** nhóm 2 / nhóm 1 (đọc code Jet-TR để học cách tổ chức).
- **Khả thi:** M2 Thấp. Nội dung bắt buộc của HĐĐT: tra văn bản pháp luật hiện hành (mục 3.3), không suy đoán.

### 1.4. CashManagement (Tiền) — C1–C7

#### C1 — Chuyển tiền nội bộ (nộp tiền vào ngân hàng, rút về quỹ)
- **Bài toán:** Cửa hàng nộp tiền mặt cuối ngày vào ngân hàng; kế toán phải làm một `CashVoucher` "Other" và một `BankReceipt` "Other" rời rạc, hay quên một nửa.
- **Jet đang có:** 4 chứng từ thu/chi; Operation chỉ có Supplier/Customer và Other (Nguồn: Jet — cf/Enums/CashVoucherOperations.xml, cf/Enums/BankReceiptOperations.xml).
- **Khoảng trống:** tiền "biến mất" khỏi quỹ mà chưa vào ngân hàng → lệch số dư, khó phát hiện thất thoát.
- **Đối tượng thêm:**
  - `Document.CashTransfer` không ghi sổ (lệnh chuyển: AccountFrom, AccountTo, Amount) để ghi nhận yêu cầu — **M2**.
  - Posting 2 dòng vào `CashBalance` (Expense nguồn, Receipt đích) — **M3** (`jet-cash.md` Gợi ý 1).
- **Phù hợp:** nhóm 2 (M2 + phân tích) / nhóm 1 (M3 gọn, đề M3 "nhập môn" tốt).
- **Khả thi:** M3 Vừa; chỉ chạm `CashBalance` (của chính nhóm Tiền).

#### C2 — Kiểm soát quỹ âm
- **Bài toán:** Thủ quỹ chi vượt số tiền đang có, cuối ngày quỹ âm trên sổ — dấu hiệu nhập sai thứ tự hoặc chi không có tiền thật.
- **Jet đang có:** `CashBalance` không có module (không có thư mục `Ext`), trong khi `InventoryInWarehouses` có `RecordSetModule` kiểm tra âm kho (Nguồn: Jet — cf/AccumulationRegisters/CashBalance.xml, cf/AccumulationRegisters/InventoryInWarehouses/Ext/ManagerModule.bsl).
- **Khoảng trống:** không chặn chi quá số dư.
- **Đối tượng thêm:**
  - Báo cáo DCS "Quỹ/tài khoản có số dư âm trong kỳ" từ `CashBalance` — **M2**.
  - Constant "Kiểm soát âm quỹ" — **M2** (Bài 13).
  - Kiểm tra âm quỹ khi post theo mẫu `NegativeBalanceControl` — **M3** (`jet-cash.md` Gợi ý 2).
- **Phù hợp:** nhóm 2 (M2) / nhóm 1 (M3, đề kỹ thuật hay).
- **Khả thi:** M3 Vừa–Cao (DataLock, thứ tự event).

#### C3 — Mẫu in phiếu thu / phiếu chi
- **Bài toán:** Mọi khoản thu chi tiền mặt cần phiếu có chữ ký; hiện kế toán gõ lại trên Word.
- **Jet đang có:** 4 chứng từ đã được đăng ký với SSL Print nhưng `AddPrintCommands` rỗng (Nguồn: Jet — cf/Documents/CashReceipt/Ext/ManagerModule.bsl); có `CurrencyRateOperations.GenerateAmountInWords` để in số tiền bằng chữ (Nguồn: Jet — cf/CommonModules/CurrencyRateOperations/Ext/Module.bsl).
- **Khoảng trống:** không có chứng từ giấy hợp lệ để ký.
- **Đối tượng thêm:** template + print command — **M3** (print form cần code, Bài 17 + 22; `jet-cash.md` Gợi ý 5). Nhóm 2 làm phần M1: thiết kế mẫu phiếu, xác định trường lấy từ đâu.
- **Phù hợp:** nhóm 1.
- **Khả thi:** Vừa; không chạm register.

#### C4 — Đối chiếu sổ phụ ngân hàng
- **Bài toán:** Mỗi tháng kế toán so sổ phụ ngân hàng (file Excel) với Jet bằng mắt, mất 2 ngày; có giao dịch phí ngân hàng chưa ghi.
- **Jet đang có:** `CashBalance` theo `BankCashAccount`, `CashType`; report `CashStatement` (Nguồn: Jet — cf/AccumulationRegisters/CashBalance.xml, cf/Reports/CashStatement).
- **Khoảng trống:** không lưu sổ phụ để đối chiếu → sai số dư, bỏ sót phí.
- **Đối tượng thêm:**
  - `Document.BankStatement` — không ghi sổ: BankAccount, kỳ, tabular section (Date, Amount, Description, MatchedDocument) — **M2**.
  - Báo cáo DCS so sánh tổng phát sinh theo sổ phụ với `CashBalance` — **M2**.
  - Nạp sổ phụ từ Excel, tự khớp chứng từ — **M3** (Bài 19).
- **Phù hợp:** nhóm 2 / nhóm 1.
- **Khả thi:** Vừa; chỉ đọc register.

#### C5 — Lịch thu chi dự kiến theo ngày
- **Bài toán:** Công ty thương mại cần biết tuần sau có đủ tiền trả lô hàng nhập 2 tỷ không; hiện ước lượng trên Excel.
- **Jet đang có:** `CashBalance` cho số dư hiện tại; `CustomerBalance`, `SupplierBalance` cho công nợ theo hóa đơn (Nguồn: Jet — cf/AccumulationRegisters/CustomerBalance.xml).
- **Khoảng trống:** không có dòng tiền kỳ vọng theo ngày → thiếu tiền đột xuất, vay nóng.
- **Đối tượng thêm:**
  - `Document.PaymentPlan` — không ghi sổ: tabular section (PlannedDate, Counterparty, Direction: Enumeration Inflow/Outflow, Amount, BaseDocument) — **M2**.
  - Báo cáo DCS "Số dư hiện tại + thu dự kiến – chi dự kiến theo ngày" — **M2/M3** (hai data set, Bài 18).
- **Phù hợp:** nhóm 2 / nhóm 1.
- **Khả thi:** Vừa. **Lưu ý trùng:** Đề 8 lập ngân sách theo khoản mục và tháng; C5 theo ngày và đối tác. Đề 7 (hạn thanh toán) là nguồn dữ liệu tự nhiên cho C5 — không chọn cùng lúc với Đề 7.

#### C6 — Phê duyệt chi
- **Bài toán:** Kế toán thanh toán theo tin nhắn của trưởng phòng; kiểm toán nội bộ yêu cầu mọi khoản chi trên 20 triệu phải có người duyệt.
- **Jet đang có:** `BankPayment` có `Paid` và `PaymentDate`, và chỉ ghi sổ khi `Paid` = True:

  Nguồn: Jet — cf/Documents/BankPayment/Ext/ManagerModule.bsl (1C:Jet, MIT)
  ```bsl
  	|WHERE
  	|	BankPayment.Ref = &Ref
  	|	AND BankPayment.Paid
  ```
  `CashVoucher` không có cờ tương tự.
- **Khoảng trống:** không phân biệt "ai đề nghị – ai duyệt – ai chi".
- **Đối tượng thêm:**
  - Enumeration `ApprovalStatuses` + attribute `ApprovalStatus`, `ApprovedBy` trên `CashVoucher`, `BankPayment` — **M2**.
  - Role "Người duyệt chi" — **M2** (Bài 20).
  - Chặn post khi chưa duyệt, hoặc lưu lịch sử duyệt vào information register — **M3** (giống bài thực hành Bài 12 về State và lịch sử state — nhóm 1 chỉ nhận gợi ý).
- **Phù hợp:** nhóm 2 / nhóm 1.
- **Khả thi:** Thấp–Vừa; không chạm register dùng chung.

#### C7 — Tạm ứng cho nhân viên
- **Bài toán:** Công ty vận tải tạm ứng tiền dầu, phí cầu đường cho tài xế; cuối chuyến tài xế quyết toán. Kế toán không biết mỗi tài xế còn giữ bao nhiêu tiền công ty.
- **Jet đang có:** chi "Other" chỉ ghi `CashBalance`, không ghi công nợ với ai (Nguồn: Jet — cf/Documents/CashVoucher/Ext/ManagerModule.bsl: điều kiện `Operation = VALUE(Enum.CashVoucherOperations.Supplier)` cho bảng công nợ).
- **Khoảng trống:** tiền tạm ứng không được theo dõi → thất thoát, quyết toán chậm.
- **Đối tượng thêm:**
  - `Catalog.Employees` — **M2**.
  - Attribute `Employee` trên `CashVoucher`, `CashReceipt` (dùng khi Operation = Other) — **M2**.
  - `Document.AdvanceReport` (báo cáo quyết toán tạm ứng) không ghi sổ — **M2**.
  - `AccumulationRegister.EmployeeSettlements` (Balances: Employee; Amount) — **M3**.
- **Phù hợp:** nhóm 2 / nhóm 1.
- **Khả thi:** M2 Thấp; M3 Vừa (register riêng, không chạm register công nợ của khách/nhà cung cấp). **Lưu ý trùng:** Đề 8 phân loại *mục đích* chi; C7 theo dõi *người giữ tiền* — có thể kết hợp nếu giảng viên đồng ý.

### 1.5. Liên phân hệ / Logistics — L1–L8

#### L1 — Theo dõi giao hàng và vận chuyển
- **Bài toán:** Nhà phân phối hàng tiêu dùng ở Hà Nội có 6 xe tải; khách gọi hỏi "hàng đâu" thì phải gọi tài xế; không đo được tỷ lệ giao đúng hẹn.
- **Jet đang có:** `SalesInvoice`, `InventoryTransfer` ghi nhận xuất kho; không có xe, tài xế, trạng thái giao (Nguồn: Jet — cf/Documents/SalesInvoice.xml).
- **Khoảng trống:** không biết hàng đã rời kho nhưng chưa tới khách; không đánh giá được đội xe / nhà vận chuyển.
- **Đối tượng thêm:**
  - `Catalog.Vehicles` (biển số, tải trọng, thể tích thùng) và `Catalog.Drivers` (hoặc dùng `Employees`) — **M2**.
  - `Document.DeliveryNote` — không ghi sổ: Vehicle, Driver, Carrier (Counterparties), PlannedDate, ActualDate, tabular section các `SalesInvoice`/`InventoryTransfer` trên chuyến — **M2**.
  - Enumeration `DeliveryStatuses` (Planned / InTransit / Delivered / Failed) — **M2**.
  - Báo cáo DCS tỷ lệ giao đúng hẹn theo xe/tài xế — **M2**.
  - Tạo phiếu giao từ hóa đơn, kiểm tra tải trọng (kết hợp W6) — **M3**.
- **Phù hợp:** nhóm 2 (đề "đinh" cho lớp Logistics) / nhóm 1 (phần M3).
- **Khả thi:** M2 Vừa (nhiều object nhưng đều đơn giản); không chạm register.

#### L2 — Hàng đang vận chuyển giữa hai kho
- **Bài toán:** Kho Hà Nội chuyển hàng vào kho TP.HCM mất 3 ngày; `InventoryTransfer` trừ kho xuất và cộng kho nhận cùng lúc nên trong 3 ngày đó kho TP.HCM "có hàng ảo".
- **Jet đang có:** `InventoryTransfer` ghi Expense ở `Warehouse` và Receipt ở `WarehouseReceiver` trong cùng một lần post (Nguồn: Jet — cf/Documents/InventoryTransfer/Ext/ManagerModule.bsl).
- **Khoảng trống:** không phản ánh thời gian trên đường → bán hàng chưa về, khó phát hiện mất hàng khi vận chuyển.
- **Đối tượng thêm:**
  - Cách làm **không cần Designer**: thêm item Warehouses "Đang vận chuyển" và chuyển hai bước (M1 + dữ liệu — tốt cho phần vận hành).
  - Attribute `ShippedDate`, `ReceivedDate`, `ReceivedBy` trên `InventoryTransfer` — **M2**.
  - `AccumulationRegister.GoodsInTransit` (Balances: Product, WarehouseFrom, WarehouseTo) và chứng từ xác nhận nhận hàng — **M3**.
- **Phù hợp:** nhóm 2 / nhóm 1.
- **Khả thi:** M3 Cao; nếu sửa posting của `InventoryTransfer` thì chạm `InventoryInWarehouses`, `InventoryCost`, Sequence.

#### L3 — Điểm đặt hàng lại theo lead time
- **Bài toán:** Nhà phân phối thuốc thú y mỗi tháng hết hàng 4–5 mã chủ lực vì đặt hàng khi tồn đã gần 0 trong khi nhà cung cấp cần 10–20 ngày.
- **Jet đang có:** tồn kho (`InventoryInWarehouses`), doanh số theo kỳ (`Sales`, kind Turnovers) (Nguồn: Jet — cf/AccumulationRegisters/Sales.xml).
- **Khoảng trống:** không có lead time và mức tiêu thụ bình quân để biết *khi nào* phải đặt.
- **Đối tượng thêm:**
  - `InformationRegister.SupplierLeadTimes` — periodic, Counterparty, Product → LeadTimeDays — **M2**.
  - Báo cáo DCS "Đề xuất đặt hàng": tồn hiện tại so với (bán bình quân/ngày × lead time + tồn an toàn) — **M2/M3** (công thức trong DCS có thể làm bằng calculated field; nếu quá phức tạp thì là M3).
- **Phù hợp:** nhóm 2 (phân tích định lượng tốt) / nhóm 1.
- **Khả thi:** Vừa. **Lưu ý trùng:** dùng ý của Đề 2 (định mức) và Đề 4 (thời gian giao cam kết) — chỉ chọn khi nhóm **không** làm Đề 2 hoặc Đề 4, hoặc làm như phần mở rộng có xin phép.

#### L4 — Đa pháp nhân (chiều Company)
- **Bài toán:** Một chủ sở hữu có 2 công ty (thương mại và dịch vụ vận tải) dùng chung kho và nhân viên; cần báo cáo riêng từng pháp nhân để nộp thuế.
- **Jet đang có:** `Catalog.Companies` với predefined `MainCompany`; tiền tệ hạch toán đọc từ chính item này:

  Nguồn: Jet — cf/CommonModules/JetServer/Ext/Module.bsl (1C:Jet, MIT)
  ```bsl
  	Return Common.ObjectAttributeValue(Catalogs.Companies.MainCompany, "PresentationCurrency");
  ```
  Không Document nghiệp vụ nào có attribute `Company`, không register nào có chiều Company (đối chiếu `cf/Documents/*.xml`, `cf/AccumulationRegisters/*.xml`; `de-bai-btl.md` mục 1.4).
- **Khoảng trống:** số liệu trộn lẫn hai pháp nhân → báo cáo thuế sai, không tính được lãi từng công ty.
- **Đối tượng thêm:**
  - Attribute `Company` trên các chứng từ của phân hệ nhóm phụ trách, mặc định `MainCompany` — **M2**.
  - Báo cáo DCS theo Company đọc từ chứng từ — **M2**.
  - Dimension `Company` trong register của phân hệ — **M3**.
- **Phù hợp:** nhóm 1 (đề kiến trúc). Nhóm 2 làm phần M1 + M2 và phân tích hệ quả.
- **Khả thi:** M3 Cao, **rủi ro cao nhất**: thêm chiều vào register dùng chung buộc mọi nhóm sửa posting. Đây cũng là cơ chế của bài thực hành Bài 12 (Companies, dimension Company trong Sales) — nhóm 1 chỉ nhận gợi ý. Lưu ý: muốn mỗi pháp nhân có tiền tệ riêng thì `GetPresentationCurrency` cũng phải đổi.

#### L5 — Giao hàng thu hộ (COD) qua đơn vị vận chuyển
- **Bài toán:** Shop thời trang online giao qua GHN, Viettel Post; đơn vị vận chuyển thu tiền của khách rồi chuyển lại sau 3–7 ngày, trừ phí ship và hàng hoàn. Chủ shop không biết bên vận chuyển đang giữ bao nhiêu tiền của mình.
- **Jet đang có:** `CashReceipt`/`BankReceipt` thu tiền theo hóa đơn qua `PaymentDetails` (Document, PaymentAmount, Amount); `CustomerBalance` theo khách và hóa đơn (Nguồn: Jet — cf/Documents/BankReceipt.xml, cf/AccumulationRegisters/CustomerBalance.xml).
- **Khoảng trống:** người nợ thực tế là đơn vị vận chuyển, không phải người mua lẻ → không đối soát được tiền COD, phí ship, đơn hoàn.
- **Đối tượng thêm:**
  - Attribute `Carrier` (Counterparties), `TrackingNumber`, `CODAmount`, `ShippingFee` trên `SalesInvoice` — **M2**.
  - `Document.CODReconciliation` — không ghi sổ: Carrier, kỳ, tabular section (SalesInvoice, CODAmount, ShippingFee, Returned) — **M2**.
  - Báo cáo DCS "Tiền COD chưa đối soát theo đơn vị vận chuyển" — **M2**.
  - Posting chuyển công nợ từ khách sang đơn vị vận chuyển — **M3** (chạm `CustomerBalance`).
- **Phù hợp:** nhóm 2 (bối cảnh rất Việt Nam) / nhóm 1.
- **Khả thi:** M2 Vừa; M3 Cao (quy ước dấu của `CustomerBalance` — `jet-cash.md` mục 9.1).

#### L6 — Quy trình hàng trả về khép kín (RMA)
- **Bài toán:** Nhà phân phối điện thoại nhận máy lỗi từ đại lý → kiểm tra → gửi hãng bảo hành hoặc đổi máy mới; hiện không biết một máy lỗi đang ở bước nào.
- **Jet đang có:** không có chứng từ trả hàng ở cả hai chiều (xem S2, P1).
- **Khoảng trống:** mất dấu hàng bảo hành, khách chờ lâu, không đòi được hãng.
- **Đối tượng thêm:**
  - `Document.ReturnAuthorization` (RMA) — không ghi sổ: Customer, SalesInvoice gốc, Product, SerialNumber (String), Issue, Decision — **M2**.
  - Enumeration `RMAStatuses` (Received / Inspecting / SentToVendor / Replaced / Refunded / Closed) và `RMADecisions` — **M2**.
  - `InformationRegister.RMAStatusHistory` (periodic) — **M2**.
  - Liên kết sang `CustomerReturn` (S2), `SupplierReturn` (P1) — **M3**.
- **Phù hợp:** nhóm 2 (đề quy trình) / nhóm 1 (khi đã có S2/P1).
- **Khả thi:** M2 Vừa; không chạm register ở M2.

#### L7 — Phiếu điều phối kho (picking list) cho đơn hàng
- **Bài toán:** Kho cấp 1 của nhà phân phối bánh kẹo soạn 80 đơn/ngày theo hóa đơn in giấy; soạn từng đơn nên đi lại nhiều, sai sót cao.
- **Jet đang có:** `SalesInvoice` in được (template `PF_MXL_SalesInvoice`); không có phiếu soạn hàng gộp (Nguồn: Jet — cf/Documents/SalesInvoice/Templates).
- **Khoảng trống:** không gộp được hàng cần soạn của nhiều đơn theo vị trí → năng suất thấp.
- **Đối tượng thêm:**
  - `Document.PickingList` — không ghi sổ: Warehouse, ngày, danh sách `SalesInvoice`, tabular section Product, Quantity, StorageBin (W1), Picked — **M2**.
  - Báo cáo DCS "Tổng hàng cần soạn theo vị trí" — **M2**.
  - Tự gộp số lượng từ các hóa đơn đã chọn — **M3**.
- **Phù hợp:** nhóm 2 / nhóm 1. Nên đi cùng W1.
- **Khả thi:** Vừa; không chạm register.

#### L8 — Lịch nhận hàng tại kho (dock appointment)
- **Bài toán:** Kho trung chuyển ở Bình Dương có 2 cửa nhận; xe nhà cung cấp đến dồn vào buổi sáng, chờ 3–4 tiếng, bị phạt lưu xe.
- **Jet đang có:** không có kế hoạch nhận hàng; `SupplierInvoice` chỉ ghi khi hàng đã nhận.
- **Khoảng trống:** không điều phối được giờ đến → tắc kho, phát sinh chi phí chờ.
- **Đối tượng thêm:**
  - `Catalog.Docks` (cửa nhận) subordinate tới `Warehouses` — **M2**.
  - `InformationRegister.DockSchedule` — Dock, Date, TimeSlot → Supplier, VehiclePlate, Status — **M2** (câu hỏi thiết kế: chiều nào đảm bảo "một cửa một khung giờ một xe").
  - Báo cáo DCS công suất cửa nhận theo ngày — **M2**.
- **Phù hợp:** nhóm 2.
- **Khả thi:** Thấp–Vừa; không chạm register.

---

### 1.6. Tích hợp, di động, phân tích — I1–I3 (ngoài 24 bài, cho nhóm khá)

> Các ý tưởng này dùng kỹ thuật **ngoài giáo trình** (HTTP service, nền tảng di động) hoặc phân tích nâng cao — chỉ nên chọn khi nhóm có thành viên nền IT và giảng viên đồng ý. Nguồn tham khảo: `code-review/nguon-ngoai.md`.

#### I1 — Tra cứu tồn kho qua HTTP service (JSON)
- **Bài toán:** Website / ứng dụng bán hàng của công ty phải gọi điện hỏi kho "còn hàng không" — thông tin chậm, bán hàng không có sẵn.
- **Jet đang có:** register tồn kho theo kho và sản phẩm (xem `jet-warehouse.md`); chưa có HTTP service nào cho bên ngoài.
- **Khoảng trống:** hệ thống ngoài không đọc được tồn kho tức thời.
- **Đối tượng thêm:**
  - `HTTPService.Stock` với template `/stock/{ProductCode}` trả JSON `{ product, warehouse, quantity }`, đọc `.Balance` với điều kiện trong tham số virtual table — **M3** (ngoài giáo trình: HTTP service, `JSONWriter`; cần publish lên web server).
  - Role riêng chỉ đọc tồn kho cho tài khoản tích hợp — **M2** (Bài 20).
- **Phù hợp:** nhóm 1 (code) — nhóm 2 thiết kế dữ liệu trả về.
- **Khả thi:** Vừa; không ghi register. Thử bằng trình duyệt / Postman. Tham khảo phía gọi: thư viện Connector (`nguon-ngoai.md`).

#### I2 — Phân tích ABC / XYZ và vòng quay hàng tồn
- **Bài toán:** Cửa hàng không biết mặt hàng nào mang lại phần lớn doanh thu (A) và mặt hàng nào bán thất thường (Z) để đặt hàng hợp lý.
- **Jet đang có:** register doanh số / giá vốn và tồn kho; báo cáo lãi bán hàng (xem `jet-sales.md`, `jet-warehouse.md`).
- **Khoảng trống:** không có phân loại mặt hàng, không đo số ngày tồn.
- **Đối tượng thêm:**
  - Báo cáo DCS ABC theo doanh thu kỳ (cột tỷ trọng lũy kế, nhóm A/B/C bằng calculated field) — **M2**.
  - Báo cáo vòng quay = giá vốn kỳ / tồn bình quân, số ngày tồn — **M2**.
  - `InformationRegister.ProductClasses` (periodic Month) lưu kết quả phân loại do data processor tính hằng tháng — **M3**.
- **Phù hợp:** nhóm 2 (Logistics) — mạnh về nghiệp vụ, ít code.
- **Khả thi:** Thấp–Vừa; chỉ đọc dữ liệu. Câu hỏi thiết kế hay: phân loại tính lúc xem báo cáo hay lưu lại theo tháng?

#### I3 — Kiểm kê bằng điện thoại (quét mã vạch)
- **Bài toán:** Kiểm kê cuối tháng ghi giấy rồi nhập lại, sai sót nhiều.
- **Jet đang có:** chưa có mã vạch (xem W7); kiểm kê là Đề 9 chính thức.
- **Khoảng trống:** nhập liệu kiểm kê thủ công.
- **Đối tượng thêm:** ứng dụng di động riêng (cấu hình *Mobile device*) quét mã vạch bằng camera, đếm số lượng, gửi kết quả về Jet qua HTTP service — **M3+** (ngoài giáo trình: nền tảng di động, `MultimediaTools`, đồng bộ dữ liệu). Mẫu tham khảo: MobileScanner của 1C Developer Network (`nguon-ngoai.md`) — chỉ đọc để hiểu, không chép (repo không ghi giấy phép, có chỗ viết kiểu cũ).
- **Phù hợp:** nhóm có thành viên IT, sau khi xong W7 hoặc Đề 9.
- **Khả thi:** Cao; cần điện thoại Android và bản platform di động. Có thể làm phiên bản rút gọn: form nhập mã vạch trên web client thay cho điện thoại.

### 1.7. Từ case doanh nghiệp thật (đã ẩn danh) — E1–E14

> Rút từ hồ sơ khảo sát, file vận hành và tài liệu giải pháp của 1C Việt Nam; bối cảnh từng ngành: `erp-cases/case-doanh-nghiep.md`. Một số ý tưởng gần với thẻ đã có (ghi "gần") — chọn một, không làm trùng. Phần "Jet đang có" xem các file `jet/`.

**Hợp lộ trình J (trên Jet):**

#### E1 — Kho 2 pha: phiếu kho tách khỏi hóa đơn
- **Bài toán:** kế toán xuất hóa đơn, thủ kho xuất hàng vào lúc khác → tồn sổ và tồn thực lệch, hai bên đổ lỗi cho nhau.
- **Đối tượng thêm:** thuộc tính `TwoPhase` của kho — **M2**; `Document.GoodsIssue` tạo trên cơ sở SalesInvoice (chưa ghi sổ) — **M2**; register `GoodsToShip` (hàng phải xuất theo hóa đơn) và sửa posting để kho 2 pha chỉ trừ tồn khi có phiếu xuất — **M3**; báo cáo chênh lệch hóa đơn – phiếu xuất — **M3**.
- **Phù hợp:** nhóm Logistics; câu hỏi thiết kế hay: register nào "biết" hàng đã bán nhưng chưa rời kho?

#### E2 — Gửi hàng cho đại lý bán hộ (ký gửi) + hoa hồng
- **Bài toán:** hàng nằm ở đại lý vẫn là hàng của công ty, nhưng sổ sách coi như đã bán.
- **Đối tượng thêm:** Catalog `Contracts` (loại hợp đồng ký gửi, cách tính hoa hồng) — **M2**; `ConsignmentTransfer`, `ConsigneeReport` — **M2**; register `GoodsAtConsignees` — **M3**; báo cáo đại lý ghi doanh số và công nợ (trừ hoa hồng) — **M3** (chạm register dùng chung).

#### E3 — Kho dịch vụ 3PL: nhận giữ hộ hàng của chủ hàng
- **Bài toán:** công ty logistics giữ hàng cho nhiều chủ hàng, tính phí lưu kho theo pallet-ngày; hàng giữ hộ không phải tài sản của mình.
- **Đối tượng thêm:** `SafekeepingReceipt`, `SafekeepingRelease` — **M2**; register `GoodsInSafekeeping` (chủ hàng, kho, sản phẩm) — **M3**; InformationRegister `StorageTariffs` + báo cáo phí lưu kho — **M2/M3**.
- **Phù hợp:** **rất sát ngành Logistics**; không chạm register tồn kho của Jet (đúng bản chất: không phải hàng của công ty).

#### E4 — Đóng bộ / tách bộ (giỏ quà, combo)
- **Đối tượng thêm:** Catalog `KitSpecifications` (thành phần) — **M2**; `Document.KitAssembly` (đóng bộ / tách bộ) xuất thành phần, nhập bộ, giá vốn bộ = tổng giá vốn thành phần — **M3**.
- **Phù hợp:** dịch vụ giá trị gia tăng trong kho; câu hỏi hay: giá vốn của bộ tính thế nào?

#### E5 — Lương khoán bốc xếp / soạn hàng theo kiện
- **Đối tượng thêm:** Catalog `WarehouseOperations` (bốc, xếp, soạn; đơn giá) — **M2**; `PieceWorkSheet` (tổ, người, số lượng, hệ số chia) — **M2**; register `PayrollAccrued` (Turnovers) — **M3**.
- **Phù hợp:** năng suất kho — nhóm Logistics.

#### E6 — Cổng nhà máy: chuyến xe, cân 2 lần, xuất hàng (gần L1, L8)
- **Bài toán:** xe đợi nhiều giờ, cân và xuất hàng ghi tay, sai lệch khối lượng.
- **Đối tượng thêm:** `Document.Trip`, `WeighingTicket` — **M2**; InformationRegister lịch sử trạng thái chuyến (đăng ký → cân vào → xếp hàng → cân ra → rời cổng) — **M2**; chặn xuất khi lệch cân quá ngưỡng, mô phỏng đầu cân bằng data processor — **M3**.

#### E7 — Hạn mức tín dụng đại lý + duyệt vượt hạn mức
- **Đối tượng thêm:** InformationRegister `CreditLimits` (periodic theo khách) — **M2**; kiểm số dư `CustomerBalance` khi post SalesInvoice, vượt thì chặn hoặc chờ duyệt — **M3**; role người duyệt — **M2**.
- **Câu hỏi thiết kế hay:** phê duyệt có cần là Document không, hay chỉ là trạng thái / nhiệm vụ?

#### E8 — Cấp phát công cụ, đồ bảo hộ cho bộ phận
- **Đối tượng thêm:** Catalog `Departments` — **M2**; `IssueToUse` / `ReturnFromUse` — **M2**; register `ItemsInUse` (bộ phận, người, sản phẩm) — **M3**.

#### E9 — Case trọn vẹn: doanh nghiệp vật liệu trang trí nhỏ (PU-D)
- **Bài toán:** 3 kho, 4 mức giá cho một sản phẩm theo kiểu hoàn thiện, giá cố định theo từng khách, chiết khấu cuối năm theo doanh thu, thuê gia công hoàn thiện.
- **Đối tượng thêm:** dùng dạng giá của Jet cho 4 mức giá + InformationRegister giá riêng theo khách — **M2**; chiết khấu bậc thang cuối năm (query lũy kế doanh số) — **M3** (gần Đề 5); register hàng đang ở đơn vị gia công — **M3**.
- **Phù hợp:** **đề tài trọn vẹn cho một nhóm J** — đủ mua, bán, kho, tiền.

#### E10 — Kho giấy theo khổ cho xưởng carton (CARTON-C)
- **Đối tượng thêm:** thuộc tính khổ / định lượng của sản phẩm giấy, báo cáo nhập – xuất – tồn theo khổ — **M2**; đề xuất đặt giấy theo đơn và cơ cấu lớp (data processor) — **M3**; phần sản xuất chỉ phân tích ở M1.

**Hợp lộ trình M (cấu hình trống) hoặc nhóm khá:**

#### E11 — Xưởng may mini (MAY-A)
- Thiết kế đầy đủ: mã hàng (công đoạn + thời gian chuẩn), đơn hàng theo màu × size, định mức hai phiên bản, nhập vải theo cây, phiếu trải cắt, bán thành phẩm theo công đoạn, sản lượng theo giờ (InformationRegister), báo cáo cân đối vải, tiến độ đơn, hiệu suất chuyền, quyết toán mã hàng. Bối cảnh và KPI: `case-doanh-nghiep.md` mục 1.1.

#### E12 — Bảo trì thiết bị (mini-CMMS)
- Thiết bị theo cây khu vực, InformationRegister vị trí / tình trạng (periodic), yêu cầu sửa chữa → phiếu công việc → xuất phụ tùng, kế hoạch bảo trì định kỳ, scheduled job sinh phiếu đến hạn, báo cáo chi phí và thiết bị hỏng nhiều. Nhóm J: đổi bối cảnh sang xe nâng, băng tải của kho.

#### E13 — Kho nguyên liệu dược theo lô, hạn dùng, trạng thái QC (DƯỢC-E, gần Đề 1)
- Lô (hạn dùng), register tồn theo lô và vị trí, InformationRegister trạng thái lô, phiếu kiểm nghiệm; posting chặn xuất lô biệt trữ, gợi ý xuất FEFO.

**Đề phương pháp (ghép với bất kỳ đề nào, phần M1):**

#### E14 — Từ file Excel đến ma trận fit-gap
- Nhận 2–3 file Excel vận hành **đã ẩn danh / sinh lại** → kiểm kê file (ai cập nhật, tần suất, nguồn số) → vẽ quy trình as-is → ma trận fit-gap với Jet theo `erp-cases/khung-khao-sat.md` → danh sách lỗi Excel (hằng số trong công thức, liên kết ngoài, ngày đảo) và cách hệ thống kiểm soát. Biến thể: làm sạch danh mục (tách tên hàng dài thành thuộc tính) trước khi nhập.

## 2. Bảng chọn đề nhanh

Cột "Mức" ghi mức tối thiểu đạt được → mức cao nhất của ý tưởng. "Công" là [ước lượng] cho phần M2 / phần M3. "Register dùng chung" = có phải sửa `InventoryInWarehouses`, `InventoryCost`, `CustomerBalance`, `SupplierBalance` ở mức M3 không.

| ID | Ý tưởng | Phân hệ | Mức | Nhóm 2 | Nhóm 1 | Công M2 / M3 | Register dùng chung |
|---|---|---|---|---|---|---|---|
| W1 | Vị trí lưu kho | Warehouses | M2 → M3 | ●● | ● | Thấp / Cao | Không (register mới) |
| W2 | Thủ kho phụ trách | Warehouses | M2 → M3 | ●● | ● | Thấp / Vừa | Không |
| W3 | Kho cách ly, tồn có thể bán | Warehouses | M2 → M3 | ●● | ● | Thấp / Vừa | Không (sửa kiểm tra SalesInvoice) |
| W4 | Yêu cầu điều chuyển | Warehouses | M2 → M3 | ●● | ● | Vừa / Vừa | Không |
| W5 | Quy đổi đơn vị tính | Warehouses | M2 → M3 | ● | ●● | Vừa / Vừa | Không (sửa form dùng chung) |
| W6 | Khối lượng, xếp xe | Warehouses | M2 → M3 | ●● | ● | Thấp / Vừa | Không |
| W7 | Mã vạch | Warehouses | M2 → M3 | ● | ●● | Thấp / Vừa | Không |
| W8 | Thẻ kho, nhật ký chứng từ kho | Warehouses | M2 | ●● | — | Thấp / — | Không |
| P1 | Trả hàng nhà cung cấp | Purchases | M2 → M3 | ● | ●● | Thấp / Cao | **Có** (3 register + Sequence) |
| P2 | Bảng giá mua | Purchases | M2 → M3 | ●● | ● | Thấp / Vừa | Không |
| P3 | Chi phí mua hàng | Purchases | M1/M2 → M3 | ● | ●● | Vừa / Cao | **Có** (InventoryCost, SupplierBalance) |
| P4 | Hợp đồng khung | Purchases | M2 → M3 | ●● | ● | Thấp / Vừa | Không |
| P5 | Kiểm tra chất lượng nhận hàng | Purchases | M2 → M3 | ●● | ● | Vừa / Vừa | Không |
| P6 | Hàng mua đang đi đường | Purchases | M2 | ●● | — | Thấp / — | Không |
| P7 | Đề nghị mua hàng | Purchases | M2 | ●● | ● | Thấp / Vừa | Không |
| S1 | Đơn bán và giữ hàng | Sales | M2 → M3 | ●● | ●● | Thấp / Vừa–Cao | Không (register mới; sửa posting SalesInvoice) |
| S2 | Khách trả hàng | Sales | M2 → M3 | ● | ●● | Thấp / Cao | **Có** (InventoryCost, CustomerBalance) |
| S3 | Báo giá | Sales | M2 → M3 | ●● | ● | Thấp / Vừa | Không |
| S4 | Nhiều điểm giao hàng | Sales | M2 | ●● | — | Thấp / — | Không |
| S5 | Kênh bán hàng | Sales | M2 → M3 | ●● | ● | Thấp / Vừa | Không (Sales chỉ nhóm Sales ghi) |
| S6 | Lãi gộp chưa VAT | Sales | M2 | ●● | ● | Thấp / — | Không |
| S7 | Hóa đơn điện tử (quản lý) | Sales | M2 | ●● | ● | Thấp / — | Không |
| C1 | Chuyển tiền nội bộ | Cash | M2 → M3 | ● | ●● | Thấp / Vừa | Không (CashBalance của nhóm Tiền) |
| C2 | Kiểm soát quỹ âm | Cash | M2 → M3 | ● | ●● | Thấp / Vừa–Cao | Không |
| C3 | In phiếu thu/chi | Cash | M1 → M3 | ● (M1) | ●● | — / Vừa | Không |
| C4 | Đối chiếu sổ phụ ngân hàng | Cash | M2 → M3 | ●● | ● | Vừa / Vừa | Không |
| C5 | Lịch thu chi dự kiến | Cash | M2 → M3 | ●● | ● | Vừa / Vừa | Không |
| C6 | Phê duyệt chi | Cash | M2 → M3 | ●● | ● | Thấp / Vừa | Không |
| C7 | Tạm ứng nhân viên | Cash | M2 → M3 | ●● | ● | Thấp / Vừa | Không (register mới) |
| L1 | Theo dõi giao hàng | Liên phân hệ | M2 → M3 | ●● | ● | Vừa / Vừa | Không |
| L2 | Hàng chuyển kho đang đi đường | Warehouses | M2 → M3 | ● | ●● | Thấp / Cao | **Có** nếu sửa posting InventoryTransfer |
| L3 | Điểm đặt hàng lại | Warehouses + Purchases | M2 → M3 | ●● | ● | Vừa / Vừa | Không |
| L4 | Đa pháp nhân (Company) | Tất cả | M2 → M3 | ● | ●● | Vừa / Cao | **Có** (mọi register) |
| L5 | COD qua đơn vị vận chuyển | Sales + Cash | M2 → M3 | ●● | ● | Vừa / Cao | **Có** ở M3 (CustomerBalance) |
| L6 | Quy trình RMA | Sales + Purchases | M2 → M3 | ●● | ● | Vừa / Cao | Có nếu nối S2/P1 |
| L7 | Phiếu soạn hàng | Warehouses + Sales | M2 → M3 | ●● | ● | Vừa / Vừa | Không |
| L8 | Lịch nhận hàng tại kho | Warehouses + Purchases | M2 | ●● | — | Thấp–Vừa / — | Không |

Ký hiệu: ●● rất phù hợp · ● phù hợp · — không có phần đáng làm cho nhóm này.

**Gợi ý ghép đề cho đủ khối lượng** [ước lượng]: một ý tưởng "Thấp" thường chưa đủ cho cả học kỳ. Ghép theo chuỗi nghiệp vụ, ví dụ W1 + L7 (vị trí → soạn hàng), S4 + L1 + W6 (điểm giao → chuyến xe → tải trọng), P5 + W3 (kiểm định → kho cách ly), S7 + S6 (hóa đơn điện tử + lãi gộp chưa VAT). Không ghép với ý tưởng trùng 9 đề của nhóm khác trong lớp.

---

## 3. Nguồn để tìm thêm ý tưởng

### 3.1. Repo và Wiki của Jet

| Nguồn | Có gì dùng được | Cách dùng |
|---|---|---|
| README Jet (`github.com/1Ci-Company/Jet`) | Mô tả mục tiêu, danh sách bản địa hóa Jet-TR / Jet-ES / Jet-ID, kênh Telegram cộng đồng **t.me/jet1ci** (Nguồn: jet/README.md) | Hỏi cộng đồng khi vướng; xem các bản địa hóa để tìm tính năng mẫu |
| Wiki — trang *Features* | Danh sách chức năng chính thức: SSL, Purchases, Sales, Warehouse, Cash & Bank, AP/AR, Costing (Nguồn: jet-wiki/Features.md) | Đối chiếu "Jet đã có gì" trước khi viết phần khoảng trống |
| Wiki — *1C:Jet Initial Setup Guide* | Hướng dẫn dùng **Additional attributes** để thêm trường cho kho, sản phẩm, đối tác (Nguồn: jet-wiki/1C:Jet-Initial-Setup-Guide.md) | Thử nhanh một ý tưởng bằng dữ liệu trước khi khai báo metadata |
| Wiki — *How to Send E-Invoices via EDM* | Mô tả luồng Jet ↔ nhà tích hợp EDM ↔ cơ quan thuế Thổ Nhĩ Kỳ (Nguồn: jet-wiki/How-to-Send-E‐Invoices-via-EDM.md) | Tham khảo khi làm S7 |
| Mục "Gợi ý mở rộng" trong `references/jet-*.md` | `jet-warehouse.md` mục 14, `jet-purchases.md` mục 13, `jet-sales.md` mục 11, `jet-cash.md` mục 14 — kèm các object/module Jet sẽ chạm tới | Lấy chi tiết kỹ thuật cho phần M3 |
| Mục "điểm lạ trong code" | `jet-warehouse.md` mục 13, `jet-purchases.md` mục 12, `jet-sales.md` mục 12, `jet-cash.md` mục 13 | Mỗi điểm lạ là một khoảng trống tiềm năng (trình bày như quan sát, không khẳng định lỗi) |

### 3.2. Các bản địa hóa Jet — so sánh với Jet gốc

Đã clone nông (shallow) ba repo và so danh sách object trong `cf/Documents`, `Catalogs`, `InformationRegisters`, `AccumulationRegisters`, `DataProcessors` (cùng `Enums`, `CommonModules`, `Constants`, `Subsystems`, `Roles`) với Jet gốc (`community`, `80884de`):

| Repo (nhánh mặc định, commit) | Kết quả so sánh |
|---|---|
| **Jet-ES** (`develop-es`, `b9dddec`) | **Không có object nghiệp vụ mới.** Khác biệt là bản dịch: chuỗi `NStr` thêm `es_CO` (ví dụ `cf/Documents/SalesInvoice/Ext/ManagerModule.bsl`). |
| **Jet-ID** (`develop-id`, `73135ff`) | **Không có object nghiệp vụ mới.** Chuỗi `NStr` thêm `id` (ví dụ `cf/AccumulationRegisters/InventoryInWarehouses/Ext/ManagerModule.bsl`). |
| **Jet-TR** (`community-tr`, `3f4949d`) | **Có phân hệ mới `EDI`** (hóa đơn điện tử) và **khấu trừ VAT (VAT withholding)** — danh sách dưới đây. |

Object có trong Jet-TR nhưng không có trong Jet gốc (đường dẫn trong repo Jet-TR):

| Loại | Object | Ghi chú (đọc từ metadata) |
|---|---|---|
| Subsystem | `cf/Subsystems/EDI.xml` | Content gồm các object EDI bên dưới, `Role.UseEDI`, `CommonForm.EInvoicePrintForm` |
| Catalog | `EDIProfiles`, `EDocumentStatuses`, `TaxExemptionReasons`, `VATWithholdingCodes`, `VATWithholdingRates`, `XSLT` | `EDIProfiles` có `Company`, `UseEInvoice`, `EInvoiceStartDate`, `Provider`, `URL`…; `EDocumentStatuses` có `IsFinal`, `IsRejected` |
| Information register | `EDIUUIDs` (non-periodic), `EDocumentsStatuses` (periodicity Second, Independent), `TaxpayerList` (non-periodic) | `EDocumentsStatuses`: dimension `ElectronicDocument` (DocumentRef.SalesInvoice), resource `Provider`, `Status` |
| Enumeration | `EDIProviders`, `EDocumentDeliveryType`, `EDocumentScenario`, `EDocumentStatus`, `EDocumentType`, `EInvoiceTypeCode` | Giá trị theo quy định Thổ Nhĩ Kỳ (ví dụ `EArchive`, `EInvoice`) |
| Common module | `EDIClient`, `EDIClientServer`, `EDIServer`, `EDIServerCall`, `EDMServer`, `UBLServer`, `VATWithholdingServerCall`, `JetAddressManager`, `JetAddressManagerClientServer`, `JetContactsManagerLocalization` | Logic gửi/nhận, tạo UBL, khấu trừ VAT, địa chỉ |
| Data processor | `FirstLaunch` | Template nạp sẵn lý do miễn thuế, mã khấu trừ VAT khi chạy lần đầu |
| Constant / Functional option | `EDIApplicationNameEDM`, `UseVATWithholdingFromSales` (Constant + Functional option cùng tên) | Bật/tắt khấu trừ VAT |
| Attribute thêm vào object có sẵn | `SalesInvoice`: `IsEInvoice`, `EDocumentNumber`, `EDocumentScenario`, `EDocumentDeliveryType`, `UseTaxExemptionReason`, `TaxExemptionReason`, `VATWithholding`…; `Counterparties`: `EDocumentScenario`, `TaxOffice`; `Companies`: `MersisNumber`, `TaxOffice`; `Products`: `VATWithholdingCode`, `VATWithholdingRate` | So với `cf/Documents/SalesInvoice.xml` gốc |

Form của `SalesInvoice` trong Jet-TR gọi module EDI ngay trong handler của form — một mẫu tốt để học cách "cắm" tính năng mới vào chứng từ có sẵn:

Nguồn: Jet-TR — cf/Documents/SalesInvoice/Forms/DocumentForm/Ext/Form/Module.bsl (1C:Jet, MIT)
```bsl
	EDIServer.OnCreateAtServer_DocumentForm(EDIParametersOnCreate);
```

**Cách dùng cho đề tài:** Jet-TR là "đề mẫu đã giải" cho ý tưởng S7: xem cách họ chọn Catalog cho trạng thái có thuộc tính (`EDocumentStatuses` có `IsFinal`) nhưng Enumeration cho tập giá trị luật định (`EDocumentType`), và periodic Information register cho lịch sử trạng thái. Nhóm Việt Nam chỉ **mô phỏng cấu trúc**, không chép giá trị luật Thổ Nhĩ Kỳ. Clone: `GIT_LFS_SKIP_SMUDGE=1 git clone --depth 1 https://github.com/1Ci-Company/Jet-TR.git`, rồi so thư mục `cf/` như trên.

### 3.3. Nguồn nghiệp vụ bên ngoài (đã mở và kiểm tra)

| Nguồn | Nội dung | Sinh viên dùng thế nào |
|---|---|---|
| 1Ci Knowledge Base — *Trade company processes in 1C:Drive* (kb.1ci.com/1C_Drive/Tutorials/Sales_purchases/Trade_company_processes_in_1C_Drive/) | Quy trình công ty thương mại trên 1C:Drive: purchase order, sales order, giá mua/giá bán, lô và hạn dùng | So một sản phẩm 1C đầy đủ với Jet để tìm khoảng trống |
| 1Ci KB — *Warehouses catalog* của 1C:Drive (kb.1ci.com/1C_Drive/Guides/1C_Drive_User_Guide/Setting_up_business_processes/Master_catalogs/Warehouse_management_catalogs/Warehouses_catalog) | Kho có loại (Warehouse / Point of sale), storage bins tùy chọn, người phụ trách, loại giá bán lẻ | Ý tưởng cho W1, W2, W3; xem cách 1C đặt thuộc tính cho kho |
| 1Ci KB — *Purchase order overview* (kb.1ci.com/1C_Drive/Guides/1C_Drive_User_Guide/Purchases/Purchase_orders/Purchase_order_overview) | Đơn mua, trạng thái, báo cáo "ordered, received, expected goods" | Tham chiếu cho S1 (đối xứng phía bán) và P7 |
| 1Ci KB — *Practical developer guide 8.3* (kb.1ci.com/1C_Enterprise_Platform/Tutorials/Practical_developer_guide_8.3/) | Hướng dẫn chính thức tạo accumulation register, posting trong Designer | Đọc thêm khi làm M3, song song với Bài 11 |
| APQC Process Classification Framework — Cross-Industry (apqc.org/pcf-excel) | Phân loại quy trình chuẩn; nhóm 4.0 "Manage Supply Chain for Physical Products" có 4.4 logistics và kho (nhận, cất, soạn, giao, vận tải, hàng trả về) | Duyệt danh mục quy trình cấp 3–4, chọn một quy trình Jet chưa có → thành ý tưởng |
| ASCM SCOR Digital Standard (ascm.org/corporate-solutions/standards-tools/scor-ds/) | 7 nhóm quy trình chuỗi cung ứng: Orchestrate, Plan, Order, Source, Transform, Fulfill, Return; công bố theo Creative Commons | Xếp từng chứng từ Jet vào Order / Source / Fulfill / Return để thấy nhóm nào trống (Jet không có Transform, không có Return) |
| Nghị định 123/2020/NĐ-CP về hóa đơn, chứng từ (thuvienphapluat.vn/van-ban/Thue-Phi-Le-Phi/Nghi-dinh-123-2020-ND-CP-hoa-don-chung-tu-445980.aspx) | Ban hành 19/10/2020, hiệu lực 01/07/2022; Điều 10 liệt kê nội dung bắt buộc của hóa đơn điện tử. Đã được sửa đổi bởi Nghị định 70/2025/NĐ-CP; theo thuvienphapluat, Nghị định 254/2026/NĐ-CP (hiệu lực 01/07/2026) hướng dẫn thêm | Lấy danh sách trường cần lưu cho S7 — kiểm tra văn bản hiện hành tại thời điểm làm bài |

### 3.4. Bài giảng dạy cơ chế cần cho từng loại hạng mục

| Hạng mục | Bài | File |
|---|---|---|
| Catalog, Enumeration, Document, attribute, tabular section; hierarchy, Owner, choice parameter links, predefined | Bài 1–4 | `references/lessons-01-06.md#bai-01-04` |
| Subsystem, form, đặt field lên form | Bài 9 | `references/lessons-07-10.md#bai-09` |
| Query (join, CASE, nhóm khoảng) cho báo cáo | Bài 10 | `references/lessons-07-10.md#bai-10` |
| Accumulation register, Balances/Turnovers, Posting, Generation (tạo chứng từ dựa trên chứng từ khác) | Bài 11 | `references/lessons-11-15.md#bai-11` |
| FillCheckProcessing, Information register (periodic, SliceLast, independent) | Bài 12 | `references/lessons-11-15.md#bai-12` |
| Constant, Document journal, Chart of characteristic types | Bài 13 | `references/lessons-11-15.md#bai-13` |
| Functional option (bật/tắt tính năng) | Bài 15 | `references/lessons-11-15.md#bai-15` |
| Event, Event subscription (điền mặc định cho nhiều chứng từ) | Bài 16 | `references/lessons-16-20.md#bai-16` |
| Print form | Bài 17, Bài 22 | `references/lessons-16-20.md#bai-17`, `bai-22.md` |
| Báo cáo DCS (data set, parameters, nhiều data set) | Bài 18 | `references/lessons-16-20.md#bai-18` |
| Data processor, nạp Excel | Bài 19 | `references/lessons-16-20.md#bai-19` |
| Role, quyền | Bài 20 | `references/lessons-16-20.md#bai-20` |
| Extension (Customization / Add-on) | Bài Extensions | `references/lessons-21-24-extensions.md#bai-extensions` |
| Thêm object vào Jet đúng chỗ (subsystem, role, print, properties) | — | `references/jet-1-overview-extending-cash.md#jet-extending` |

---

## 4. Hướng dẫn tự phát triển ý tưởng

Phương pháp 5 bước — áp dụng cho cả hai nhóm; nhóm 2 dừng ở bước 5 với mức M2, nhóm 1 đi tiếp lên M3.

**Bước 1 — Bắt đầu từ một nỗi đau nghiệp vụ, không phải từ object.** Viết một câu: "Doanh nghiệp X **mất** (tiền / hàng / thời gian / khách) **vì** không biết / không kiểm soát được Y." Ví dụ: "Shop online mất tiền vì không biết đơn vị vận chuyển đang giữ bao nhiêu tiền COD." Nếu không nêu được hậu quả cụ thể, ý tưởng chưa đủ mạnh cho phần phân tích khoảng trống (25% điểm).

**Bước 2 — Tìm xem Jet đang ghi nhận gì liên quan.** Theo phương pháp "khai báo → nhập liệu → quan sát hệ quả":
1. Tìm chứng từ gần nhất trong bảng "Chứng từ nào ghi vào sổ nào" (`de-bai-btl.md` mục 1.3).
2. Nhập thử một chứng từ, post, mở báo cáo trước/sau — ghi vào phiếu quan sát.
3. Ghi lại: dữ liệu nào **đã có** (trường trên chứng từ, chiều trong sổ), dữ liệu nào **phải nhập ngoài Jet** (Excel, giấy, Zalo).

**Bước 3 — Xác định chính xác cái còn thiếu.** Phân loại khoảng trống thành một trong bốn dạng:

| Dạng thiếu | Dấu hiệu | Ví dụ |
|---|---|---|
| Thiếu **dữ liệu mô tả** | Cần thêm một trường / danh sách để phân loại, lọc | Kênh bán (S5), khối lượng (W6) |
| Thiếu **dữ liệu thay đổi theo thời gian** | "Tại ngày X giá trị là gì?" | Thủ kho phụ trách (W2), giá mua (P2) |
| Thiếu **ghi nhận một sự kiện** | Có một việc xảy ra, có ngày, có người, cần lưu vết | Kiểm định (P5), giao hàng (L1) |
| Thiếu **số liệu tích lũy / kiểm soát** | "Còn bao nhiêu?", "Đã phát sinh bao nhiêu?", cần chặn khi vượt | Hàng đã hứa giao (S1), quỹ âm (C2) |

**Bước 4 — Chọn loại object.** Dùng bảng quyết định sau (căn cứ: Bài 1–4 cho Catalog/Enumeration/Document, Bài 11 cho Accumulation register, Bài 12 cho Information register, Bài 13 cho Constant/Chart of characteristic types):

| Câu hỏi | Nếu "có" → chọn | Căn cứ trong bài | Ví dụ Jet |
|---|---|---|---|
| Tập giá trị **cố định**, người dùng **không được thêm**, thuật toán dựa vào từng giá trị? | **Enumeration** | Bài 3: lưu giá trị cố định, dùng khi thuật toán dựa vào giá trị đó | `ProductTypes`, `LiabilityTypes`, `CashVoucherOperations` |
| Danh sách người dùng **tự thêm/sửa**, mỗi phần tử cần **thông tin bổ sung**, chọn từ danh sách thay vì gõ chữ? | **Catalog** (hierarchical nếu cần phân cấp; có Owner nếu "thuộc về" một đối tượng khác) | Bài 3: nhập liệu nhất quán, lưu thông tin bổ sung; Bài 4: hierarchy, Owner | `Products`, `Warehouses`, `BankAccounts` |
| Chỉ **một giá trị** cho cả hệ thống, ít thay đổi? | **Constant** | Bài 13 | (ví dụ cờ "Kiểm soát âm quỹ" ở C2) |
| Thông tin **gắn với một tổ hợp** (ví dụ Kho + Sản phẩm), mỗi tổ hợp **một giá trị**, có thể cần **lịch sử theo ngày**? | **Information register** (periodic nếu cần lịch sử; independent nếu nhập tay) | Bài 12: duy nhất theo tập dimensions; periodic + SliceLast; write mode Independent | `Prices` (PriceType, Product → Price; periodic Day) |
| Một **sự kiện nghiệp vụ** có ngày, có người, cần lưu vết và có thể làm đổi số liệu? | **Document** (không ghi sổ ở M2; ghi sổ ở M3) | Bài 3: phản ánh nghiệp vụ, gắn thời gian, có thể post; thuật ngữ: không phải Document nào cũng post | `InventoryTransfer`, `PricesSetupAuxiliary` (không post) |
| Cần **cộng dồn số** theo các chiều và hỏi "còn bao nhiêu" (Balances) hoặc "đã phát sinh bao nhiêu trong kỳ" (Turnovers), chỉ thay đổi qua chứng từ? | **Accumulation register** (M3) | Bài 11: số liệu theo dimensions, records chỉ thay đổi qua recorder | `InventoryInWarehouses` (Balances), `Sales` (Turnovers) |
| Thuộc tính **chưa biết trước**, khác nhau theo nhóm đối tượng, người dùng tự định nghĩa? | **Chart of characteristic types** — trong Jet dùng sẵn Additional attributes của SSL | Bài 13 | `AdditionalAttributesAndInfo` (SSL) |

Ba câu hỏi kiểm tra nhanh trước khi chốt (cũng là dạng câu hỏi phân tích hay gặp trong 9 đề):
- **Gắn vào danh mục hay vào chứng từ?** Nếu giá trị có thể đổi mà dữ liệu cũ phải giữ nguyên (khu vực của khách, kênh bán), cân nhắc lưu trên chứng từ, hoặc dùng Information register periodic.
- **Báo cáo đọc từ chứng từ hay từ sổ?** Đọc từ chứng từ là M2 (không cần sửa posting) nhưng không có số dư; cần "còn bao nhiêu" thì phải có sổ (M3).
- **Có chạm register dùng chung không?** Nếu có, ghi rõ trong thiết kế và thống nhất với nhóm phân hệ kia (SKILL.md mục 6).

**Bước 5 — Chọn mức và lập bảng thiết kế đối tượng.**
1. Tách ý tưởng thành các hạng mục, gán mức như cách 9 đề làm: phần khai báo (Catalog, Enumeration, attribute, Information register, Document không ghi sổ, Subsystem, DCS) là **M2**; register mới, dimension mới, posting, tự động trên form là **M3**.
2. Lập bảng thiết kế bắt buộc: Tên — Loại object 1C — Các trường (kiểu) — **Lý do chọn loại object** (trích căn cứ ở bảng bước 4).
3. Đặt tên theo quy ước Jet: tiếng Anh, PascalCase, Catalog/Document số nhiều hoặc danh từ nghiệp vụ (`Warehouses`, `SalesInvoice`), Synonym tiếng Việt để người dùng thấy tên quen thuộc.
4. Xác định nơi phải đăng ký object mới trong Jet (subsystem, role `Use<Subsystem>`, properties, print) theo checklist `jet-extending.md` mục 5–7 — thiếu bước đăng ký là lỗi phổ biến nhất.
5. Viết 2–3 câu hỏi phân tích cho chính đề của nhóm theo mẫu của 9 đề (lựa chọn loại object, đánh đổi giữa các phương án, ai trong doanh nghiệp được quyền vượt kiểm soát) — chuẩn bị cho phần trình bày 15%.

Tutor lưu ý: với nhóm 1, khi ý tưởng trùng cơ chế với một bài thực hành của giáo trình (ví dụ trả hàng của khách — Bài 11; Company và lịch sử trạng thái — Bài 12), áp dụng mục 3a của SKILL.md: gợi ý theo bậc, không đưa lời giải.
