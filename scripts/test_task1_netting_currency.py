# -*- coding: utf-8 -*-
"""
Test Suite: Task 1 - Cấn trừ đa tệ & Xác thực tiền tệ đồng nhất (CanTruCongNoNoiBo)
Kiểm tra:
1. Thuộc tính TienTe trong metadata CanTruCongNoNoiBo.xml
2. Loại bỏ hoàn toàn hardcode VND trong CanTruCongNoNoiBo/Ext/ObjectModule.bsl
3. Bắt buộc kiểm tra đồng nhất loại tiền giữa AR và AP
4. Lọc tiền tệ trong truy vấn số dư khả dụng
"""

import os
import sys
import io
import xml.etree.ElementTree as ET

if sys.stdout.encoding != 'utf-8':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
XML_PATH = os.path.join(ROOT_DIR, "src", "Documents", "CanTruCongNoNoiBo.xml")
BSL_PATH = os.path.join(ROOT_DIR, "src", "Documents", "CanTruCongNoNoiBo", "Ext", "ObjectModule.bsl")

def test_metadata_has_tiente():
    assert os.path.exists(XML_PATH), f"Không tìm thấy file {XML_PATH}"
    tree = ET.parse(XML_PATH)
    root = tree.getroot()
    
    # Tìm Attribute có Name = TienTe
    has_tiente = False
    for attr in root.findall(".//{http://v8.1c.ru/8.3/MDClasses}Attribute"):
        name_elem = attr.find("./{http://v8.1c.ru/8.3/MDClasses}Properties/{http://v8.1c.ru/8.3/MDClasses}Name")
        if name_elem is not None and name_elem.text == "TienTe":
            type_elem = attr.find(".//{http://v8.1c.ru/8.1/data/core}Type")
            assert type_elem is not None and "CatalogRef.TienTe" in type_elem.text, "Type của TienTe phải là CatalogRef.TienTe"
            has_tiente = True
            break
            
    assert has_tiente, "Metadata CanTruCongNoNoiBo.xml thiếu thuộc tính bắt buộc: TienTe!"
    print("  [+] PASS: Metadata CanTruCongNoNoiBo.xml đã có thuộc tính TienTe (CatalogRef.TienTe)")

def test_bsl_logic_currency_validation():
    assert os.path.exists(BSL_PATH), f"Không tìm thấy file {BSL_PATH}"
    with open(BSL_PATH, "r", encoding="utf-8") as f:
        content = f.read()
        
    # 1. Không được hardcode VND trong Sổ Cái
    assert 'RefVND = Catalogs.TienTe.FindByCode("VND");' not in content, (
        "LỖI: CanTruCongNoNoiBo vẫn hardcode RefVND gán cố định cho Sổ Cái!"
    )
    assert 'Row1.TienTe = RefVND;' not in content, "LỖI: Row1.TienTe đang gán RefVND thay vì tiền tệ chứng từ!"
    assert 'Row2.TienTe = RefVND;' not in content, "LỖI: Row2.TienTe đang gán RefVND thay vì tiền tệ chứng từ!"
    
    # 2. Phải có kiểm tra đồng nhất loại tiền giữa AR và AP
    assert 'TienTeAR' in content and 'TienTeAP' in content, (
        "LỖI: CanTruCongNoNoiBo chưa bóc tách và so sánh loại tiền tệ TienTeAR vs TienTeAP!"
    )
    assert 'TienTeAR <> TienTeAP' in content or 'TienTeAP <> TienTeAR' in content, (
        "LỖI: CanTruCongNoNoiBo chưa chặn trường hợp AR và AP khác loại tiền tệ!"
    )
    
    # 3. Phải lọc tiền tệ trong query kiểm tra số dư
    assert 'DongTienThanhToan' in content or 'TienTe' in content, (
        "LỖI: Query kiểm tra số dư AR/AP chưa lọc theo tiền tệ!"
    )
    assert 'Row1.TienTe = TienTe;' in content or 'Row1.TienTe = TienTeAR;' in content, (
        "LỖI: Chưa gán tiền tệ động vào bút toán Sổ Cái Row1!"
    )
    assert 'Row2.TienTe = TienTe;' in content or 'Row2.TienTe = TienTeAR;' in content, (
        "LỖI: Chưa gán tiền tệ động vào bút toán Sổ Cái Row2!"
    )
    print("  [+] PASS: BSL Logic đã xác thực tiền tệ đồng nhất và hạch toán Sổ Cái đúng loại tiền.")

if __name__ == "__main__":
    print("\n--- CHẠY TEST TASK 1: KIỂM TRA TIỀN TỆ CẤN TRỪ CÔNG NỢ ---")
    try:
        test_metadata_has_tiente()
        test_bsl_logic_currency_validation()
        print(">> KẾT QUẢ: 100% PASS!\n")
    except AssertionError as e:
        print(f"FAILED: {e}\n")
        sys.exit(1)
