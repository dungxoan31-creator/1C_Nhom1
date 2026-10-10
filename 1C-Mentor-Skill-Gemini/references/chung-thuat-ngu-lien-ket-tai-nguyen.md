# Tài liệu gộp: chung-thuat-ngu-lien-ket-tai-nguyen

Gồm các mục: § terminology, § lien-ket-bai-giang, § practice-index, § tai-nguyen


---

# § terminology

# Thuật ngữ và cách diễn đạt chuẩn

Đọc file này khi giải thích khái niệm nền tảng, khi sinh viên dùng thuật ngữ sai, hoặc khi viết nội dung sẽ được trình bày lại (báo cáo, slide, bài thuyết trình).

## 1. Quy tắc bắt buộc

| Không nói | Nói đúng | Lý do |
|---|---|---|
| "Catalog *kế thừa* (inherit) từ class Catalogs" | Metadata object được **tạo từ prototype** (metadata class) có **basic implementation** sẵn | "Kế thừa" mang nghĩa OOP, không đúng với cơ chế 1C. Developer không tạo được metadata class mới. |
| "Module *tự sinh code*" | Module là **container rỗng** với **các event có tên định sẵn**; developer viết handler vào đó | Platform không sinh code cho module. (Wizard như Record wizard có thể *đề xuất* code, nhưng đó là công cụ, không phải module tự sinh.) |
| "Catalog/Register có event Posting" | **Posting chỉ có ở Document** — luôn nói rõ "Posting của Document" | Posting là đặc trưng phân biệt Document với các metadata object khác. |
| "SSL — giao thức bảo mật" | **SSL = Standard Subsystems Library** (thư viện các subsystem chuẩn) | Trong ngữ cảnh 1C, SSL không phải Secure Sockets Layer. |
| "SSL là một loại extension" / ngược lại | SSL và Extensions là **hai cơ chế khác nhau**, có thể dùng chồng lên nhau | SSL được nhúng vào configuration; Extension là lớp mở rộng tách rời configuration. |
| "Privileged mode on posting" | **Post in privileged mode** / **Unpost in privileged mode** | Tên property đúng của Document (giao diện tiếng Anh, platform 8.5). |
| "Extension giúp sửa code dễ" | Extension = **tùy biến an toàn khi cập nhật (upgrade-safe customization)** | Giá trị cốt lõi là không sửa trực tiếp configuration gốc. |
| "Extension loại sửa lỗi / loại bổ sung…" | Ba **Purpose** chính thức: **Patch / Customization / Add-on** | Giữ đúng tên tiếng Anh, không thay bằng từ chung chung. |

## 2. Nguyên tắc thiết kế cần nhắc sinh viên

- **Không phải bước nghiệp vụ nào cũng thành Document.** Chỉ những sự kiện cần ghi nhận, có ngày giờ và (thường) làm thay đổi số liệu mới nên là Document.
- **Không phải Document nào cũng post vào register.** Khi thiết kế, hỏi: chứng từ này có làm thay đổi số liệu cần theo dõi (tồn kho, công nợ…) không? Nếu không thì không cần register records.
- Thuật toán nên dựa vào **Predefined data** hoặc **Enumeration**, không dựa vào Code/Description người dùng có thể sửa.
- **Không thể sửa data object qua reference** — muốn sửa phải lấy object, sửa, rồi ghi lại (ví dụ `Ref.GetObject()` → sửa → `Write()` — ngoài giáo trình, kiểm tra trong Syntax assistant).

## 3. Bảng thuật ngữ Anh – Việt

Luôn giữ thuật ngữ tiếng Anh (đúng như trong Designer) và có thể kèm giải thích tiếng Việt ở lần đầu.

| Thuật ngữ | Giải thích ngắn |
|---|---|
| Platform | Nền tảng thực thi và phát triển (1C:Enterprise 8) |
| Applied solution / Configuration | Ứng dụng nghiệp vụ chạy trên platform, mô tả bằng metadata |
| Infobase | Cơ sở thông tin = configuration + dữ liệu |
| Designer | Chế độ phát triển (cấu hình) |
| Enterprise mode | Chế độ người dùng chạy ứng dụng |
| Metadata class | Loại đối tượng do platform định sẵn (Catalogs, Documents…) |
| Metadata object | Đối tượng developer tạo trong một metadata class (Catalog Products) |
| Data object | Bản ghi cụ thể người dùng tạo (một sản phẩm cụ thể) |
| Standard attributes | Thuộc tính có sẵn theo class (Code, Description, Date, Number…) |
| Attribute | Thuộc tính developer thêm |
| Tabular section | Bảng con của object, lưu ở bảng DB riêng |
| Reference (Ref) | Tham chiếu tới data object |
| Catalog | Danh mục |
| Enumeration (Enum) | Liệt kê — tập giá trị cố định |
| Document | Chứng từ — phản ánh nghiệp vụ, có thể post |
| Posting | Ghi sổ chứng từ — chỉ Document |
| Register records | Các bản ghi register do Document tạo ra khi post |
| Accumulation register | Sổ tích lũy (kind Balances / Turnovers) |
| Information register | Sổ thông tin (có thể periodic) |
| Virtual table | Bảng ảo của register (Balance, Turnovers, SliceLast…) |
| Chart of characteristic types | Kế hoạch loại đặc tính |
| Chart of accounts / Accounting register | Hệ thống tài khoản / Sổ kế toán |
| Constant | Hằng số lưu một giá trị duy nhất |
| Document journal | Nhật ký chứng từ |
| Subsystem | Nhóm chức năng hiển thị trên giao diện |
| Role | Vai trò — tập quyền truy cập |
| Common module | Module dùng chung |
| Object module / Manager module / Form module | Module của object / manager / form |
| Compilation directive | &AtClient, &AtServer, &AtServerNoContext, &AtClientAtServerNoContext |
| Query language | Ngôn ngữ truy vấn của 1C |
| Data composition system (DCS) | Hệ thống bố cục dữ liệu dùng làm report |
| Data processor | Xử lý dữ liệu (built-in hoặc external .epf) |
| Event subscription | Đăng ký event chung cho nhiều object |
| Functional option | Tùy chọn chức năng bật/tắt phần giao diện/chức năng |
| Configuration extension | Mở rộng cấu hình (Patch / Customization / Add-on) |
| SSL | Standard Subsystems Library |


---

# § lien-ket-bai-giang

# Liên kết tài liệu bài giảng gốc (Google Drive)

> **Khi nào đọc file này:** khi câu trả lời giải thích nội dung thuộc một bài trong giáo trình, hoặc người học hỏi "tài liệu bài N ở đâu". Thêm một dòng **"Đọc thêm"** ở cuối câu trả lời theo quy tắc trong SKILL.md.

Nguồn: thư mục `JDCourseLessons` của giảng viên Phạm Viết Quý (đọc ngày 07/10/2026; bài Extensions bổ sung cùng ngày). Mỗi bài có bản Lý thuyết (Theory) và đề Thực hành (Practice), tiếng Việt và tiếng Anh. Thư mục **không có video**. Nếu link không mở được, người học liên hệ giảng viên (quypv@1c.com.vn).

Đề Thực hành chỉ là **đề bài**, không có lời giải. 

| Bài | Chủ đề (tên thư mục) | File trong skill | Lý thuyết (VI) | Lý thuyết (EN) | Đề thực hành (VI) | Đề thực hành (EN) |
|---|---|---|---|---|---|---|
| 1 | Introduction | `bai-01-04.md` | [1. Giới thiệu lý thuyết](https://drive.google.com/file/d/1FWIyhFaz_O2CO-0_FayMZL6PYkOR0rY7/view) | [1. Introduction theory](https://drive.google.com/file/d/18Z0IqHW1NSzffH1SlSmUo2hci3NPEyiS/view) | [1. Giới thiệu thực hành](https://drive.google.com/file/d/1Ns1UQuL9bN3g8wyls1vCeFutadoT5EVM/view) | [1. Introduction practice](https://drive.google.com/file/d/179fwlhT6SwSn4GquwitY38mWnUjR7Eaf/view) |
| 2 | Theory, primitive types, storing of objects and references to objects | `bai-01-04.md` | [2. Lý thuyết](https://drive.google.com/file/d/1R4B9oDYLx0ozftnWkQmexCq0t9XlDlEJ/view) | [2. Theory](https://drive.google.com/file/d/1i1j3smuoVnf_iannCR0EwD8J6oBRIFfB/view) | [2. Thực hành](https://drive.google.com/file/d/1J3k_Ip9wnksoKIMEcdymRdcvm1xK_j2z/view) | [2. Practice](https://drive.google.com/file/d/1Vodri_QdMox_l1FOxAvUT_aWDdLKpeKQ/view) |
| 3 | Catalogs, enumerations, documents | `bai-01-04.md` | [3. Lý thuyết](https://drive.google.com/file/d/1oWEWAosgt7fMM_aqHROJ4ql8aelsGeHw/view) | [3. Theory](https://drive.google.com/file/d/1TGQQb8ermgcPTvmEadQ6bLZNwS5P6Hd3/view) | [3. Thực hành](https://drive.google.com/file/d/13j8QFlb-GVJikgH-PeCuN39BYM7nEmS7/view) | [3. Practice](https://drive.google.com/file/d/1t-LfkBvTHmAatb6HWtT_ilXCnr5h8mEz/view) |
| 4 | Hierarchical data, owners, predefined data | `bai-01-04.md` | [4. Lý thuyết](https://drive.google.com/file/d/1Jia7HFoeGrV5FP8kYYD_cSfdvQlfs445/view) | [4. Theory](https://drive.google.com/file/d/1TTCGPEGCtgqyfo37RqtYFZgE7SvinPIt/view) | [4. Thực hành](https://drive.google.com/file/d/1CjNo5HXtjbacuzYESKxxctYGHc6BhfRy/view) | [4. Practice](https://drive.google.com/file/d/1kV_cv5mLNHVpIxInSZf_0A0QjU5m82kj/view) |
| 5-6 | Basics of 1C script, syntax assistant. Operators, collections | `bai-05-06.md` | [5-6. Lý thuyết](https://drive.google.com/file/d/1whK4BvSaYHSu_fUlOQXFaIyXuj_VNfm9/view) | [5-6. Theory](https://drive.google.com/file/d/1SbuFb0kpOPUPy8U8eJJRA3VosJq2wIvE/view) | [5-6. Thực hành](https://drive.google.com/file/d/1TtVJ1MCfI1FRQkOzNc8N-HT9qqWUykRN/view) | [5-6. Practice](https://drive.google.com/file/d/1DB6KwsMvBEbSoST2645DcyzzvAUQAT4S/view) |
| 7 | Client-server interaction | `bai-07.md` | [7. Lý thuyết](https://drive.google.com/file/d/1SS6bHaBJx5j6979EjUQ2LXEn6mUWkcH6/view) | [7. Theory](https://drive.google.com/file/d/1UeRHjT3tj996v67Tyu0ZJAuaFPXnu-u-/view) | [7. Thực hành](https://drive.google.com/file/d/1E90SONlzORI0m8rdUVKlG4QHe6LHNUXY/view) | [7. Practice](https://drive.google.com/file/d/1L88bgU4m2aSVf2cLcX-aZLaE-3j5Jmer/view) |
| 8 | Debugging. Performance meter | `bai-08.md` | [8. Lý thuyết](https://drive.google.com/file/d/1p-Suz-XLA1HSY6wKKwz7jj2qc92OK759/view) | [8. Theory](https://drive.google.com/file/d/1bJC_QaXtVDLkXpgWFxMmuOdt-TATngnR/view) | [8. Thực hành](https://drive.google.com/file/d/1P5RTOH51E86e-1xjXFXOGK2NZm3Li_WS/view) | [8. Practice](https://drive.google.com/file/d/1RlSUMLJHcui6E-jKY45zRgM3nBBBLsQP/view) |
| 9 | User interface | `bai-09.md` | [9. Lý thuyết](https://drive.google.com/file/d/1HEWa3kXsT0tQx1BrRV3CDW17i6qSwIml/view) | [9. Theory](https://drive.google.com/file/d/1y-bUF-yvkpPxH45ecXdFXIZW9y_JxYdt/view) | [9. Thực hành](https://drive.google.com/file/d/1afMiPkWdjsOZj7sRnfDHhqSydhwbHMQQ/view) | [9. Practice](https://drive.google.com/file/d/1JxoKM4hsEJzpDj-LkdEXcy7OuNodJ14k/view) |
| 10 | Query language | `bai-10.md` | [10. Lý thuyết](https://drive.google.com/file/d/18OUygHP0N7F5HxmeXbrRROzHi1kF3D0r/view) | [10. Theory](https://drive.google.com/file/d/1QS11dHi4uW9hSlZ74DyXlQ3q2C4D3xHY/view) | [10. Thực hành](https://drive.google.com/file/d/1rWMAbBCMD2z4Rh2x8RZHc9HtCZ8NMmCq/view) | [10. Practice](https://drive.google.com/file/d/1z-1kqsXVBvrcvyrbflmDpM7UiKv8NC_Y/view) |
| 11 | Accumulation registers, document posting | `bai-11.md` | [11. Theory - vi](https://drive.google.com/file/d/1FHhmjDnYVG9AXHyanXWEkABjq_wDzGhJ/view) | [11. Theory](https://drive.google.com/file/d/1PFg-YPIxXa0-ZrYELvHOXzFkqi9zjW4_/view) | [11. Practice - vi](https://drive.google.com/file/d/1Blryg1J1jqwsJIBRdbd1I1qpxpdDVO-V/view) | [11. Practice](https://drive.google.com/file/d/15Jt4ZsgLpJ-yYGaE6oR2-7V3kuExwrQ5/view) |
| 12 | Data validation, information registers | `bai-12.md` | [12. Theory - VN](https://drive.google.com/file/d/1dBMMxbG8fC0IQDH1M_8ywVa5KUZHeu_S/view) | [12. Theory](https://drive.google.com/file/d/1Qki-Gv7vfMmqNGfsRzLMiB5n2zzJv3iH/view) | [12. Practice - VN](https://drive.google.com/file/d/1BeBjMn3gATVvbMF-hoElkqPbMnIVWzHD/view) | [12. Practice](https://drive.google.com/file/d/1MR3hJ4NBHTSF4WMZuzbTRAs_58BwzRjj/view) |
| 13 | Constants, Charts of characteristic types, document journals | `bai-13.md` | [13. Theory VN](https://drive.google.com/file/d/16ms_tr5tEv6SOU0JSTwXHiw8FAlorjF3/view) | [13. Theory](https://drive.google.com/file/d/1i-S6gtAX6kgrtgzYiwSt4HJGQGYfsbXU/view) | [13. Practice VN](https://drive.google.com/file/d/1osvI6dWwwTWnKvkIbmoqkUQCHMqPsS2v/view) | [13. Practice](https://drive.google.com/file/d/1wlUGWMlGywXG6o6eZ6yDcfcMDOCElGOA/view) |
| 14 | Common modules. Modules of application. Commands | `bai-14.md` | [14. Theory - vi](https://drive.google.com/file/d/1nkSZtUYYzf-7ZbGCrkVL_J8IepboRRVc/view) | [14. Theory](https://drive.google.com/file/d/1g48dr6NtnBvvzvq5-bt-pEShBqYwIwOk/view) | [14. Practice - vi](https://drive.google.com/file/d/1tTbk2PhoK0JCQmLDCz-f1xh-wkcsjpti/view) | [14. Practice](https://drive.google.com/file/d/1rdHNLp-vE84riVLL2xIMteracvjX6zvy/view) |
| 15 | Functional options. Object and non-object entities. Referential integrity | `bai-15.md` | [15. Theory - vi](https://drive.google.com/file/d/1f-h4xP2O12lA_xumUCjrTtWjVENtVvWy/view) | [15. Theory](https://drive.google.com/file/d/1Hv5WDNSIfRWA0mzuz-ABK5GPxbttLpQ_/view) | — | [15. Practice](https://drive.google.com/file/d/1vT6JAQxDHW4hBMXiBqSVh3w4hX1wb7NM/view) |
| 16 | Events, handlers and subscriptions | `bai-16.md` | [16. Theory - vi](https://drive.google.com/file/d/1GXM7MwrwizuNliGO8OcN1zRDb0O6qaUu/view) | [16. Theory](https://drive.google.com/file/d/1_cm-GQLuP-vRZwOhqF4INK7ff4NoyLMR/view) | [16. Practice - vi](https://drive.google.com/file/d/1DmQ5hhyX3y5nWIncHRlu9iM0L0DpWhgW/view) | [16. Practice](https://drive.google.com/file/d/1pNiwLq3WxW7yyOOVLxiU241aZict7zVd/view) |
| 17 | Internal print forms. Template-based reports | `bai-17.md` | [17. Theory - vi](https://drive.google.com/file/d/1bfPfyOSgIs4h7rlt4YHIsMAW8PMgXG0R/view) | [17. Theory](https://drive.google.com/file/d/1_gYCFS7dYZS3Sz1vmltQMXlPmRaDU-l7/view) | [17. Practice - vi](https://drive.google.com/file/d/1zJsD4xjk-q34plhUI-48WOsS7NN31Fqv/view) | [17. Practice](https://drive.google.com/file/d/1eFMOX3z110raf7JG4JTc_cD_CpOKCsSm/view) |
| 18 | Data composition scheme based reports | `bai-18.md` | [18. Theory - vi](https://drive.google.com/file/d/1d4cd5UEG3osRlCKs-k21y5fIngefd4x-/view) | [18. Theory](https://drive.google.com/file/d/1vsp4qghq85ptejuzXMvia-NahFNvQaoB/view) | [18. Practice - vi](https://drive.google.com/file/d/1qGk-TLBr-bUeiC_YMkstIazsBn4MxBYN/view) | [18. Practice](https://drive.google.com/file/d/11Jnjg8PJgJ15HszHVYCffJpxDBWPJbZA/view) |
| 19 | Data processors | `bai-19.md` | [19. Theory - vi](https://drive.google.com/file/d/1s3rJxJafBaRfyO0dXxlGmp5CtCA6sO-0/view) | [19. Theory](https://drive.google.com/file/d/1JOxsg1xu81joays8ij3tfVUyIEHVOBBE/view) | [19. Practice - vi](https://drive.google.com/file/d/1UgXJIi89LZ8sYJlq9780eXgYYKeEdjRU/view) | [19. Practice](https://drive.google.com/file/d/1NcoIG9WmkcidfxFMcnpkrAWkpUqh8Eum/view) |
| 20 | Roles and access rights | `bai-20.md` | [20. Theory - vi](https://drive.google.com/file/d/1RaUxiDQHfiANbn895-3r_Su6OWVIDin7/view) | [20. Theory](https://drive.google.com/file/d/1-HDnDe9uSqh3rYICArKfAqCUquoDg65S/view) | [20. Practice - vi](https://drive.google.com/file/d/1GoWo-OSb_3V2edMxxBTFXF4sc1L4PIzB/view) | [20. Practice](https://drive.google.com/file/d/1KYc_UPtZSpQLj4slkEOHeAJN2pdOtGI9/view) |
| 21 | SSL. Additional reports and data processors | `bai-21.md` | [21. Theory - vi](https://drive.google.com/file/d/1CSp9GEzdfXqotDzmW_BmYyj121NaKjUz/view) | [21. Theory](https://drive.google.com/file/d/1j339E2w_IA2o-bODKK6KPOAbUPn99xKN/view) | [21. Practice - vi](https://drive.google.com/file/d/1FZbOJGADvyQl1fzl9IFr1NDsFzG4KhW9/view) | [21. Practice](https://drive.google.com/file/d/1eNBK4XCje-60or5kTeft4063ek_EBH1Q/view) |
| 22 | SSL. Print | `bai-22.md` | [22. Theory - vi](https://drive.google.com/file/d/1kKU4dPY3kDw4h2wgIbJXG9_dZKhyIUA2/view) | [22. Theory](https://drive.google.com/file/d/1rTFpes2JcO7fKzcVz4yWTZFFY41Znt83/view) | [22. Practice - vi](https://drive.google.com/file/d/1oR_6Xs1MIhtAfQGvn4kQmgekH_M-akw2/view) | [22. Practice](https://drive.google.com/file/d/1THpXbcl2h-U7fOMg20waImWdHux5R1r2/view) |
| 23 | SSL. Work with files | `bai-23.md` | [23. Theory - vi](https://drive.google.com/file/d/1sILWRocYgwjZltlznR147QAGTWcRsGYL/view) | [23. Theory](https://drive.google.com/file/d/1toVC-c_5DVVk_ZooRu9c8a_vfsnj7lIo/view) | [23. Practice - vi](https://drive.google.com/file/d/1AozuHipZszAvE_Qsu0ghv0EKamd-rtpy/view) | [23. Practice](https://drive.google.com/file/d/191YeZDyiDQrWPAITQlvoWl1vvtrqYczu/view) |
| 24 | Accounting | `bai-24.md` | [24. Theory - vi](https://drive.google.com/file/d/1ptr0qqf6vVpejaT-y9HUB5SMrcojtLrC/view) | [24. Theory](https://drive.google.com/file/d/1GkwM1d1KC280Jb8fY2M1a5lbOR0ZiWlf/view) | [24. Practice - vi](https://drive.google.com/file/d/1kJ4zu71yupc4G55i0WLYowgTN2XAMa44/view) | [24. Practice](https://drive.google.com/file/d/1XMQGUjy9Hl-LsCMBhQxiMi6DUwbaTZeQ/view) |
| Extensions | Configuration extensions | `bai-extensions.md` | [Extensions theory - vi](https://drive.google.com/file/d/1FdxSfvAsszmM3lVQfWkDy4FTnTVCN-fB/view) | [Extensions theory](https://drive.google.com/file/d/1KmNj00MHnltu807U50w2bAGJz8h33l_U/view) | [Extensions practice - vi](https://drive.google.com/file/d/1x-_csWDXZQ43G4Ae9dkjK-5UEgwY4eGn/view) | [Extensions practice](https://drive.google.com/file/d/1w4157zNP1HWLX6SfNVO9bH9uCvxHirwB/view) |

Tài liệu chung: [Tài liệu làm việc với nền tảng 1C:Enterprise](https://docs.google.com/document/d/1jAWDZpT1_rzmsXI_edEQnJvwxhLlac5L-ntAwElu4-Y/edit?tab=t.0) (được dẫn trong đề bài tập lớn).

Không đưa link thư mục cho sinh viên: một số thư mục bài có file kèm dành cho giảng viên. Chỉ dẫn link từng file trong bảng trên.


---

# § practice-index

# Danh mục bài thực hành của giáo trình (để nhận diện, không có lời giải)

> **Khi nào đọc file này:** trước khi viết code cho một yêu cầu, để kiểm tra yêu cầu có trùng một bài thực hành của 24 bài hoặc bài Extensions không (bước 2 trong `chinh-sach-code.md`). File chỉ liệt kê tên bài tập (thẻ gợi ý của 24 bài + Extensions, và các đề đánh giá Intern / Partner); đề tóm tắt và gợi ý nằm trong file bài tương ứng.

Cách đối chiếu: so **cơ chế + object + chức năng**, không so tên. Đổi tên object (ví dụ `GoodsInWarehouses` → `TonKho`), đổi ngành, hay tách đề thành nhiều câu hỏi nhỏ không làm yêu cầu thôi là bài thực hành.

## `bai-01-04.md` — Thẻ gợi ý bài thực hành (Practice 1–4)
- Practice 1 — Bài tập Task 1 (tạo infobase, load configuration, dump/restore)
- Practice 1 — Bài tập Task 2 (danh sách infobase, web client, server infobase)
- Practice 1 — Bài tập Task 3 (Compare and merge, cache form)
- Practice 2 — Bài tập Task 1 (reference và primitive types)
- Practice 2 — Bài tập Task 2 (Standard attributes)
- Practice 3 — Bài tập 1 (infobase mang tên bạn)
- Practice 3 — Bài tập 2 (Countries)
- Practice 3 — Bài tập 3 (Products với presentation khác nhau)
- Practice 3 — Bài tập 4 (ProductsTypes và attribute bắt buộc có giá trị mặc định)
- Practice 3 — Bài tập 5 (subsystem Master data)
- Practice 3 — Bài tập 6 (Counterparties)
- Practice 3 — Bài tập 7 (SalesInvoice với tabular section Products)
- Practice 3 — Bài tập 8 (subsystem Sales)
- Practice 3 — Bài tập 9 (cập nhật và nhập dữ liệu)
- Practice 4 — Bài tập 1 (Products có group, tối đa 4 cấp group)
- Practice 4 — Bài tập 2 (predefined "Vietnam" làm giá trị mặc định)
- Practice 4 — Bài tập 3 (CounterpartyContracts: owner, hierarchy hợp đồng/phụ lục, code)
- Practice 4 — Bài tập 4 (Contract trong SalesInvoice lọc theo Customer)
- Practice 4 — Bài tập 5 (số SalesInvoice duy nhất trong năm)
- Practice 4 — Bài tập 6 (Amount tự tính khi đổi Quantity/Price, procedure CalculateAmountAtRow)

## `bai-05-06.md` — Thẻ gợi ý bài thực hành (Practice 5-6)
- Bài tập 1 — DocumentTotal tự tính từ tabular section Products
- Bài tập 2 — Giá bán tối thiểu (MinimumSalePrice)
- Bài tập 3 — ValidUntil và "Days left" trên form hợp đồng
- Bài tập 4 — Common form TestCollections và SortArray
- Bài tập 5 — ShowSelectionFromValueList (ShowChooseItem + CallbackDescription)
- Bài tập 6 — CopyAndSearchValueTable (Copy theo filter + Total)
- Bài tập 7 — CalculateTotalAtValueTree (cây 3 cấp + function đệ quy)
- Code demo của bài Theory (repo 1CJDCourse, nhánh lesson/05-theory)

## `bai-07.md` — Thẻ gợi ý bài thực hành (Practice 7)
- Bài tập 1 — Attribute Discount (hợp đồng và SalesInvoice)
- Bài tập 2 — FillDiscount trong object module
- Bài tập 3 — Tính Amount có discount, dùng được ở client và server
- Bài tập 4 — DocumentTotal tính trên server
- Bài tập 5 — Cảnh báo hợp đồng hết hiệu lực

## `bai-08.md` — Thẻ gợi ý bài thực hành (Practice 8)
- Bài tập 1 — Breakpoint cơ bản
- Bài tập 2 — Breakpoint bị disable
- Bài tập 3 — Conditional breakpoint
- Bài tập 4 — Step In / Step Out / Step Over
- Bài tập 5 — Đổi giá trị biến khi debug (SendMessage)
- Bài tập 6 — Tìm lỗi trong CreateSalesInvoiceAtServer (Try/Except, ErrorInfo)
- Bài tập 7 — Performance snapshot

## `bai-09.md` — Thẻ gợi ý bài thực hành (Practice 9)
- Bài tập 1 — Subsystem Purchases, picture và explanation
- Bài tập 2 — Document PurchaseInvoice
- Bài tập 3 — Number và Date trên cùng một dòng
- Bài tập 4 — Mặc định chỉ hai panel
- Bài tập 5 — Quan hệ của Counterparty (vendor / customer / other)
- Bài tập 6 — Chỉ chọn Vendor / Customer phù hợp
- Bài tập 7 — Tabular section Services trên page riêng
- Bài tập 8 — Dùng chung thuật toán cho Services
- Bài tập 9 — DocumentTotal = goods + services
- Bài tập 10 — Số dòng trên tiêu đề page "Products (2)"
- Bài tập 11 — Lọc Product theo loại trong Products / Services
- Bài tập 12 — Nút Pick cho Products và Services
- Bài tập 13 — Footer tổng Amount
- Bài tập 14 — List form trên Home page

## `bai-10.md` — Thẻ gợi ý bài thực hành (Practice 10)
- Bài tập 1 — Object Warehouses và attribute Warehouse trong PurchaseInvoice / SalesInvoice
- Bài tập 2 — Subsystem Warehouse
- Bài tập 3 — Document InventoryTransfer
- Bài tập 4 — Bố cục form InventoryTransfer (2 cột header)
- Bài tập 5 — Nút "Pick" trên InventoryTransfer
- Bài tập 6 — Nút "Fill in by the remaining goods" (batch query với temporary tables)
- Bài tập 7 — Catalog Banks
- Bài tập 8 — Catalog BankAccounts (phụ thuộc Banks)
- Bài tập 9 — Subsystem Funds
- Bài tập 10 — Document PaymentExpense (tạo dựa trên PurchaseInvoice)
- Bài tập 11 — Document PaymentReceipt (tạo dựa trên SalesInvoice)
- Bài tập 12 — Nút "Fill in by balance" trên PaymentExpense / PaymentReceipt
- Bài tập T1 — Sales order có tổng services không quá 1000
- Bài tập T2 — Sales order: services > 5000 và goods = 0
- Bài tập T3 — Products có tổng mua và tổng bán > 0 (TempTablesManager, chỉ document đã post)
- Bài tập T4 — Products: từ lần mua cuối tới lần bán cuối không quá một tuần
- Bài tập T5 — Mua và bán theo document trong kỳ, kết quả hai cấp (TOTALS)
- Bài tập T6 — Products: Description + Details "This is a group" / "This is not a group"
- Bài tập T7 — Products KHÔNG nằm trong group có tên chứa "water"

## `bai-11.md` — Thẻ gợi ý bài thực hành (Practice 11)
- Bài tập 1 — Accumulation register GoodsInWarehouses
- Bài tập 2 — Ba document ghi movements vào GoodsInWarehouses
- Bài tập 3 — Viết lại "Fill in by the remaining goods" bằng dữ liệu register
- Bài tập 4 — Document ReturnOfGoodsFromCustomer (Generation từ SalesInvoice)
- Bài tập 5 — Form ReturnOfGoodsFromCustomer: tính amount, khóa Price/Amount, tổng document
- Bài tập 6 — ReturnOfGoodsFromCustomer ghi vào GoodsInWarehouses
- Bài tập 7 — Accumulation register Sales (bán − trả, theo customer và contract)
- Bài tập 8 — RequiredSalesAmount và discount theo doanh số tháng trước

## `bai-12.md` — Thẻ gợi ý bài thực hành (Practice 12)
- Bài tập 1 — InventoryTransfer: chặn posting khi kho gửi = kho nhận
- Bài tập 2 — Catalog Companies và attribute Company trong documents
- Bài tập 3 — Dimension Company trong register Sales
- Bài tập 4 — Banks, BankAccounts (subordinate tới Companies/Counterparties), subsystem Funds
- Bài tập 5 — Attribute "Bank account" với giới hạn lựa chọn
- Bài tập 6 — Kiểm tra đủ hàng trong kho khi post SalesInvoice và InventoryTransfer
- Bài tập 7 — Attribute State của SalesInvoice (Planned, InDelivery, Completed)
- Bài tập 8 — Lịch sử state của SalesInvoice
- Bài tập 9 — Giá theo ngày: document PriceSetup và register ProductPrices
- Bài tập 10 — SalesInvoice tự điền giá theo register, khóa Price/Amount

## `bai-13.md` — Thẻ gợi ý bài thực hành (Practice 13)
- Bài tập 1 — Constant "Control balances of goods" và form "Goods turnover settings"
- Bài tập 2 — Document journal "Sales documents"
- Bài tập 3 — Chart of characteristic types AdditionalAttributesAndProperties
- Bài tập 4 — Characteristics như attributes thường; "Primary supplier" và filter trên list form Products

## `bai-14.md` — Thẻ gợi ý bài thực hành (Practice 14)
- Bài tập 1 — Server common module ProductsInDocuments: kiểm tra số dư dùng chung
- Bài tập 2 — Server call common module: function lấy giá
- Bài tập 3 — Client-server common module: tính amount của dòng, discount tùy chọn
- Bài tập 4 — Parameterizable command "Set price"
- Bài tập 5 — Main section command interface
- Bài tập 6 — Lệnh tạo mới trong command interface của subsystems
- Bài tập 7 — Enumeration WriteOffMethods và constant WriteOffOrder
- Bài tập 8 — Dimension Batch trong GoodsInWarehouses

## `bai-15.md` — Thẻ gợi ý bài thực hành (Practice 15)
- Bài tập 1 — Functional option UseCharacteristics và form cài đặt
- Bài tập 2 — FO có parameter ControlBalanceOfGoods theo từng company
- Bài tập 3 — Prefix số document theo company (CompanyPrefix + OnSetNewNumber)
- Bài tập 4 — Thử xoá object với và không có referential integrity control
- Bài tập 5 — Purchase invoice ghi chính nó vào dimension Batch
- Bài tập 6 — Cột Batch trong Sales invoice và lệnh "Pick batch"

## `bai-16.md` — Thẻ gợi ý bài thực hành (Practice 16)
- Bài tập 1 — Bảng products của document đang chọn trên home page
- Bài tập 2 — Mở item Products khi chọn dòng trong bảng mới
- Bài tập 3 — Event subscription điền Company mặc định cho mọi document
- Bài tập 4 — Posting Sales invoice: phân bổ batch FIFO/LIFO/Manually
- Bài tập 5 — Return of goods from customer: dòng chỉ theo Sales document, trả batch theo thứ tự ngược
- Bài tập 6 — Nút "Fill by sales document" gọi event Filling chuẩn
- Bài tập 7 — Amount trong GoodsInWarehouses theo giá vốn

## `bai-17.md` — Thẻ gợi ý bài thực hành (Practice 17)
- Bài tập 1 — Batch FIFO/LIFO/Manually cho document Inventory transfer
- Bài tập 2 — Print form "List of goods movement" cho Inventory transfer
- Bài tập 3 — Print form cho 2 documents
- Bài tập 4 — Report "Sales by customers" 3 cấp (programmatic template)

## `bai-18.md` — Thẻ gợi ý bài thực hành (Practice 18)
- Bài tập 1 — Report "Sales with price deviation"
- Bài tập 2 — Report "Goods movement" và tồn tối thiểu từ hệ thống ngoài

## `bai-19.md` — Thẻ gợi ý bài thực hành (Practice 19)
- Bài tập 1 — Data processor nạp giá từ Excel vào document PriceSetup

## `bai-20.md` — Thẻ gợi ý bài thực hành (Practice 20)
- Bài tập 1 — Ba role bắt buộc và user Administrator
- Bài tập 2 — Đổi tên configuration
- Bài tập 3 — Role theo chức danh: CEO, PurchaseManager, SalesManager, Storekeeper, MasterDataSpecialist
- Bài tập 4 — Characteristics cho mọi user, quyền xóa chỉ cho CEO, constants chỉ CEO/FullAccess
- Bài tập 5 — Không role nào có Interactive delete và quyền xóa predefined
- Bài tập 6 — Không cấp Update/Edit cho accumulation register, post ở privileged mode
- Bài tập 7 — Tạo user cho từng role và test toàn bộ ứng dụng
- Bài tập 8 — Flag "Modifies saved data" cho nút "Fill by sales document"

## `bai-21.md` — Thẻ gợi ý bài thực hành (Practice 21)
- Bài tập 1 — Global data processor "Revaluation" trong subsystem mới "My projects"
- Bài tập 2 — Đổi giá theo số cho _DemoCustomerProformaInvoice (ObjectFilling)
- Bài tập 3 — Điền giá hiện hành từ register cho _DemoGoodsSales và _DemoCustomerProformaInvoice, có cảnh báo
- Bài tập 4 — Giống bài 3 nhưng FormFilling: không ghi DB, chỉ một object, không hỏi

## `bai-22.md` — Thẻ gợi ý bài thực hành (Practice 22)
- Chuẩn bị — Kết nối _DemoSalesOrder vào Print subsystem (bước chung cho bài 1–3)
- Bài tập 1 — Print form "Sales order" (trong data processor PrintSalesOrder) và "Delivery order" (trong document)
- Bài tập 2 — "Sales order details" bằng PrintManagement, chỉ hiện với document từ 01.01.2025
- Bài tập 3 — "Document set": 2 bản "Sales order" + 1 bản "Delivery order"
- Bài tập 4 (bổ sung) — External print form "Sales order (external)"

## `bai-23.md` — Thẻ gợi ý bài thực hành (Practice 23)
- Bài tập — Phần 1: Kết nối catalog _DemoStorageLocations vào FilesOperations (catalog file riêng)
- Bài tập — Phần 2: Item form có submenu file và hyperlink "Attachments"
- Bài tập — Phần 3: Cột "Paperclip" trên list form
- Bài tập — Phần 4: Ảnh chính trên item form (như _DemoProducts)

## `bai-24.md` — Thẻ gợi ý bài thực hành (Practice 24)
- Bài tập 1 — Cơ chế kế toán: chart of accounts, extra dimensions, accounting register
- Bài tập 2 — Cho user bật/tắt kế toán
- Bài tập 3 — Tài khoản 01 Goods, 02 Trade payables, 03 Trade receivables
- Bài tập 4 — Bút toán khi mua, bán, trả hàng, chuyển kho
- Bài tập 5 — Report Trial Balance
- Bài tập 6 — Document nhập bút toán tay, không posting, xử lý deletion mark

## `bai-extensions.md` — Thẻ gợi ý bài thực hành (Extensions practice)
- Bài tập 1 — Extension "Patch" sửa lỗi lời gọi SetMainProject
- Bài tập 2 — Extension "Customization": ReleasedBy/ReceivedBy cho _DemoInventoryTransfer
- Bài tập 3 — Print form "Transfer Note" in Released/Received by từ attribute mới
- Bài tập 4 — Thử thứ tự gọi khi nhiều extension cùng mở rộng một method

## Đề đánh giá Intern và đề thi Partner (không phải bài thực hành 24 bài, nhưng xử lý như bài thực hành)

Đề gốc nằm trong project của giảng viên. Người học hỏi các đề này → chỉ gợi ý theo bậc, minh họa cơ chế bằng ví dụ khác đề.

- Intern Task 0 — FIFO / LIFO / chọn lô thủ công: register tồn theo lô, xuất theo thứ tự lô, giá bán lẻ periodic do chứng từ ghi
- Intern Task 1.1 — Personal Financial Management (PocketMoney) Module 1: Accounts, ExpenseTypes, Income, Expense, sổ Ledger, kiểm tra số dư, subsystem, panel, common form Balances
- Intern Task 1.2 — PocketMoney Module 2: DefaultAccount, hierarchy, tiền tố số chứng từ, predefined Other, ngân sách Budget / BudgetExecution, StrictBudgetCheck, kiểm tra chỉ khi post real-time
- Intern Task 1.3 — PocketMoney Module 3: tabular section Details cho Income, common module ServiceSrv.ProcessIncomeDocs, ghi log
- Intern Task 4 — Bike rental company: văn phòng, khách, xe, biểu giá Tỉnh × Hạng, nhập xe, cho thuê, trả xe, quỹ, công nợ
- Intern Task 5 — Nạp giá từ Excel vào ProductsPrices (1C:Company Management)
- Intern Task 6 — Mẫu in ngoài cho SalesOrder (1C:Company Management)
- Intern Task 7 — Additional data processor chạy như nhiệm vụ thường kỳ, tạo / đánh dấu xóa Notes (SSL)
- Intern Task 8 — Chart of accounts + accounting register riêng, data processor MonthlyOperations, báo cáo Accounts status (AccountingSuite)
- Intern Task 9 — Chứng từ nhập hàng mới tích hợp vào AccountingSuite (posting, lệnh, role, mẫu in, nạp Excel, báo cáo)
- Partner Exam Stage 1, Đề 1 — điểm thưởng: sơ đồ tích điểm theo ngưỡng doanh số có ngày hiệu lực, thẻ thưởng, báo cáo số dư điểm
- Partner Exam Stage 1, Đề 2 — đa tiền tệ (tỷ giá tới giây), giá nhiều loại tiền tối đa một lần mỗi ngày, chiết khấu theo hợp đồng, báo cáo giá và doanh số
- Partner Exam Stage 1, Đề 3 — PurchaseInvoice, báo cáo tồn kho theo ngày, mẫu in phiếu xuất kho với người phụ trách kho theo ngày


---

# § tai-nguyen

# Tài nguyên: cài đặt nền tảng, Query console, file Jet, khóa học

> **Khi nào đọc file này:** chỉ khi người học **hỏi** về cài đặt platform, tải Query console, lấy file Jet, tài liệu giới thiệu công nghệ 1C:Enterprise, hoặc khóa học có chứng chỉ — hoặc khi họ bị kẹt vì thiếu công cụ (ví dụ cần chạy thử query mà chưa có Query console). Không chèn link vào mọi câu trả lời.
>
> Cập nhật: 08/10/2026. Nếu link không mở được, người học liên hệ giảng viên (quypv@1c.com.vn).

## 1. Thư mục cài đặt của khóa

**Link:** https://drive.google.com/drive/folders/1OV7Lq2TYbfqMMKFSu0hYDXK69kcXRIe6?usp=drive_link

Trong thư mục có:
- **Bộ cài nền tảng 1C:Enterprise** cho Windows và macOS.
- `queryconsole.epf` — Query console (external data processor).
- `jet.dt` — bản dump infobase Jet (cấu hình và dữ liệu có trong bản đó).
- `jet.cf` — file cấu hình Jet (chỉ cấu hình, không có dữ liệu).

**Phiên bản khuyến nghị: 8.3.25.1445** — cấu hình Jet của khóa chạy trên bản này. Trên macOS, nếu không cài được bản 8.3.25.1445 thì mới thử bản khác, và báo giảng viên bản đã cài.

Nhiều phiên bản platform cài song song được trên cùng máy — cần khi một khóa học yêu cầu bản mới hơn (mục 4).

## 2. Hướng dẫn nhanh

**Tạo infobase từ `jet.dt` (có sẵn cấu hình và dữ liệu):**
1. Mở 1C:Enterprise → **Add** → tạo infobase mới **không có cấu hình** (Create an infobase without a configuration…), chọn thư mục lưu.
2. Mở infobase đó bằng **Designer** → **Administration / Tools → Restore infobase** → chọn `jet.dt`.
3. Restore **ghi đè toàn bộ** infobase đích — chỉ restore vào infobase trống hoặc bản thử.

**Nạp `jet.cf` (chỉ cấu hình):**
1. Tạo infobase trống như trên → Designer → **Configuration → Open configuration**.
2. **Configuration → Load configuration from file** → chọn `jet.cf` → đồng ý **Update database configuration** (F7).
3. Lần đầu vào Enterprise mode: tạo user Administrator và làm các bước thiết lập ban đầu (`jet/jet-overview.md` mục 2, chỉ lộ trình J).

Chọn file nào: muốn có ngay dữ liệu để học, quan sát → `jet.dt`. Muốn một cấu hình sạch để tự nhập liệu → `jet.cf`. Sao lưu bài làm luôn dùng **Dump infobase** ra `.dt`; `.cf` không chứa dữ liệu (Bài 1).

**Query console:**
1. Chạy infobase ở chế độ **1C:Enterprise** → **File → Open** → chọn `queryconsole.epf`.
2. Viết hoặc dán query (có thể mở Query wizard), đặt giá trị tham số, bấm chạy để xem kết quả.
3. Dùng để: thử query trước khi đưa vào code, xem số dư / số phát sinh của register (`.Balance`, `.Turnovers`), kiểm tra posting đã ghi đúng chưa.
4. Mở được file `.epf` từ ổ đĩa cần quyền tương ứng; dùng user Administrator khi học.

## 3. Giới thiệu công nghệ nền tảng

**https://1c-dn.com/1c_enterprise/** — trang giới thiệu công nghệ 1C:Enterprise của 1C Developer Network. Gợi ý khi người học (hoặc đối tác) hỏi "1C:Enterprise là gì, kiến trúc ra sao, khác gì phần mềm đóng gói": platform và applied solution tách rời, phát triển dựa trên metadata, các loại client, chế độ file và client-server, công cụ phát triển, tích hợp. Khi trích một nhận định cụ thể từ trang này, dẫn đúng trang con, không tự diễn giải thêm.

## 4. Khóa học trực tuyến có chứng chỉ — 1C Skills Hub

**https://skillshub.1c-dn.com/login?next=/dashboard** — đăng ký tài khoản miễn phí; các khóa miễn phí và có chứng chỉ hoàn thành.

| Khóa | Nội dung | Yêu cầu | Gợi ý cho |
|---|---|---|---|
| **1C:Enterprise Development Basics. Junior Course** | Khóa nền: dùng các object có sẵn của platform để xây ứng dụng nghiệp vụ vừa phải; học trước mọi khóa phát triển khác | Biết khái niệm lập trình cơ bản, cơ sở dữ liệu quan hệ | D; M; thành viên có nền IT của nhóm J. Song song hoặc thay cho phần nền của giáo trình 24 bài |
| **Operational business processes in 1C:Company Management** | Ví dụ trọn vẹn tự động hóa chu trình thương mại trong 1C:Company Management | — | J và M — **hiểu quy trình nghiệp vụ trước khi thiết kế** |
| **1C Standard Subsystems Library Overview** | SSL từ đầu, làm trên cấu hình trống, tự dựng từng thành phần | Platform 8.3.24 trở lên; nền Junior Course (hoặc tự học 24 bài lý thuyết + series video lý thuyết trên YouTube) | D; J có nền IT (Jet xây trên SSL); sau Bài 21–23 |
| **1C:Enterprise. Modification of AccountingSuite Solution** | Tùy biến giải pháp có sẵn: phân tích yêu cầu tùy biến, chọn cách làm (sửa trực tiếp, event subscription, extension, external report / data processor), đánh đổi về bảo trì và cập nhật | Biết phát triển 1C cơ bản, quen Designer; nên học trước First Step và Development Basics. Beginners Course; **platform 8.3.27 trở lên** + cấu hình AccountingSuite của khóa | D (đối tác, thực tập sinh); J có nền IT muốn hiểu cách tùy biến an toàn; sau bài Extensions |
| **Data exchange in 1C** | Trao đổi dữ liệu, tích hợp, làm trên cấu hình trống | Junior Course; platform 8.3.24 trở lên | D; M muốn làm phần tích hợp |
| **IT Software for business WorldSkills training course** | Khóa thực hành cho lập trình viên 1C chuẩn bị thi WorldSkills | — | Sinh viên khá muốn thi đấu |
| **1C:Enterprise Mobile Developer** (có bản tiếng Việt) | Phát triển ứng dụng di động trên 1C | — | Tùy chọn, ngoài giáo trình |

Lưu ý khi giới thiệu:
- Khóa AccountingSuite cần platform 8.3.27 trở lên, khác bản 8.3.25.1445 dùng cho Jet — cài thêm bản mới cho khóa đó, giữ bản 8.3.25.1445 cho bài tập lớn.
- Lộ trình M: giới thiệu khóa để học kỹ thuật và hiểu quy trình; không coi quy trình trong khóa là thiết kế "chuẩn" cho doanh nghiệp của nhóm.
- Mẫu câu: "Nếu muốn học thêm có chứng chỉ, với hướng của bạn mình gợi ý khóa **<tên khóa>** trên 1C Skills Hub — đăng ký tài khoản miễn phí tại đây: <link>."
