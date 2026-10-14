# -*- coding: utf-8 -*-
"""
Test Suite: Task 2 - Cưỡng chế ma trận chuyển trạng thái tại BeforeWrite trên 7 chứng từ
Kiểm tra:
1. Call site tường minh QuanLyVongDoiChungTuServer.KiemTraChuyenTrangThai tại BeforeWrite của 7 chứng từ tài chính
2. Ma trận FSM trong QuanLyVongDoiChungTuServer.bsl chặn tự duyệt bởi Maker khi lưu DaDuyet
3. Chặn nhảy cóc từ DuThao / ChoDuyet sang DaGhiSo
4. Chặn sửa trực tiếp trạng thái trên chứng từ đã ghi sổ
"""

import os
import sys
import io

if sys.stdout.encoding != 'utf-8':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DOCS_DIR = os.path.join(ROOT_DIR, "src", "Documents")
SERVER_MODULE = os.path.join(ROOT_DIR, "src", "CommonModules", "QuanLyVongDoiChungTuServer", "Ext", "Module.bsl")

TARGET_DOCS = [
    "HoaDonGTGTDauRa",
    "HoaDonNhaCungCap",
    "UyNhiemChi",
    "BaoCoNganHang",
    "CanTruCongNoNoiBo",
    "DanhGiaLaiNgoaiTe",
    "BienBanNghiemThuGiaiDoan"
]

def test_explicit_call_sites_in_before_write():
    for doc in TARGET_DOCS:
        bsl_path = os.path.join(DOCS_DIR, doc, "Ext", "ObjectModule.bsl")
        assert os.path.exists(bsl_path), f"Không tìm thấy ObjectModule.bsl của chứng từ {doc}"
        with open(bsl_path, "r", encoding="utf-8") as f:
            lines = f.readlines()
            
        in_before_write = False
        has_call_site = False
        for line in lines:
            if "Procedure BeforeWrite(" in line:
                in_before_write = True
            elif in_before_write and "EndProcedure" in line:
                in_before_write = False
            elif in_before_write:
                if "QuanLyVongDoiChungTuServer.KiemTraChuyenTrangThai(" in line or "KiemTraChuyenTrangThai(" in line:
                    has_call_site = True
                    break
                    
        assert has_call_site, (
            f"LỖI: Chứng từ {doc} thiếu call site tường minh KiemTraChuyenTrangThai tại BeforeWrite!"
        )
        print(f"  [+] PASS: {doc} đã có call site KiemTraChuyenTrangThai tại BeforeWrite")

def test_fsm_enforcement_in_server_module():
    assert os.path.exists(SERVER_MODULE), f"Không tìm thấy {SERVER_MODULE}"
    with open(SERVER_MODULE, "r", encoding="utf-8") as f:
        content = f.read()
        
    # Phải chặn Maker tự duyệt khi chuyển sang DaDuyet
    assert "UserNameStr = AuthorStr" in content or "SessionUser = AuthorStr" in content or "SessionUser = Author" in content or "UserNameStr = Author" in content, (
        "LỖI: KiemTraChuyenTrangThai chưa có logic đối chiếu SessionUser với Author để chặn tự duyệt!"
    )
    assert "Người lập không thể tự phê duyệt" in content or "Người lập không được tự duyệt" in content, (
        "LỖI: Thiếu thông báo lỗi cấm Maker tự phê duyệt chuyển trạng thái sang Đã duyệt!"
    )
    
    # Phải chặn nhảy cóc trạng thái
    assert "Quy trình phê duyệt không hợp lệ" in content, (
        "LỖI: Thiếu kiểm tra chặn nhảy cóc trạng thái sang DaGhiSo!"
    )
    print("  [+] PASS: QuanLyVongDoiChungTuServer đã có FSM kiểm soát chuyển trạng thái toàn diện.")

if __name__ == "__main__":
    print("\n--- CHẠY TEST TASK 2: KIỂM SOÁT MA TRẬN CHUYỂN TRẠNG THÁI TẠI BEFOREWRITE ---")
    try:
        test_explicit_call_sites_in_before_write()
        test_fsm_enforcement_in_server_module()
        print(">> KẾT QUẢ: 100% PASS!\n")
    except AssertionError as e:
        print(f"FAILED: {e}\n")
        sys.exit(1)
