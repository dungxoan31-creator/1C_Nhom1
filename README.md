# VinSmart Future AR/AP trên 1C:Enterprise 8.3

## Bắt đầu từ đâu

| Thư mục / file | Nội dung |
| --- | --- |
| `src/` | Metadata XML và mã BSL của cấu hình 1C. |
| `scripts/` | Lệnh nạp cấu hình, tạo dữ liệu và chạy kiểm thử. |
| `tests/` | Kiểm thử BSL và kịch bản nghiệp vụ. |
| `docs/` | Kế hoạch, báo cáo kiểm toán và tài liệu dự án. |
| `docs/reference/` | Tài liệu hướng dẫn 1C và tài liệu học tập. |
| `HUONG_DAN_SU_DUNG_FILE_DT.md` | Hướng dẫn sử dụng các bản sao `.dt` ở thư mục gốc. |

Các thư mục `Infobase/`, `Infobase_FullData/` và `Infobase_TestClone/` chứa dữ liệu 1C local. Không coi chúng là cache để xóa. Các file `.dt` được giữ ở thư mục gốc vì script nhập, xuất và hướng dẫn bàn giao đang dùng những đường dẫn này.

Các file `.log` ở thư mục gốc cũng được giữ nguyên vị trí khi còn script hoặc mã BSL ghi/đọc trực tiếp. `build/` và `scratch/` chứa kết quả làm việc local; kiểm tra từng file trước khi dọn. `Lessons/`, `Bài thực hành/` và `1C-Mentor-Skill-Gemini/` là tài liệu học tập và công cụ hỗ trợ.
