# -*- coding: utf-8 -*-
"""
Audit Script: Đối chiếu cấu hình CSDL 1CD với mã nguồn src/ (Hash Parity 0-diff)
Nhiệm vụ:
1. Đọc toàn bộ file trong src/ và thư mục dump scratch/dumped_config/
2. Chuẩn hóa line endings (CRLF -> LF) để tính hash nội dung chính xác
3. So sánh 100% file tồn tại và hash SHA-256
4. Báo cáo 0 khác biệt (0-diff) để nghiệm thu kiến trúc
"""

import os
import sys
import io
import hashlib

if sys.stdout.encoding != 'utf-8':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC_DIR = os.path.join(ROOT_DIR, "src")
DUMP_DIR = os.path.join(ROOT_DIR, "scratch", "dumped_config")

def compute_content_sha256(file_path):
    with open(file_path, "rb") as f:
        data = f.read()
    # Loại bỏ UTF-8 BOM và chuẩn hóa line-ending CRLF -> LF
    data = data.lstrip(b"\xef\xbb\xbf")
    normalized = data.replace(b"\r\n", b"\n").strip()
    return hashlib.sha256(normalized).hexdigest()

def get_relative_files(base_dir):
    rel_files = {}
    for root, dirs, files in os.walk(base_dir):
        for f in files:
            # Bỏ qua manifest tự sinh của 1C khi dump
            if f == "ConfigDumpInfo.xml":
                continue
            full_path = os.path.join(root, f)
            rel_path = os.path.relpath(full_path, base_dir).replace("\\", "/")
            rel_files[rel_path] = full_path
    return rel_files

def run_parity_audit():
    print(f"\n--- ĐỐI CHIẾU MÃ NGUỒN VỚI CSDL 1C (DUMP PARITY AUDIT) ---")
    print(f"  Source dir: {SRC_DIR}")
    print(f"  Dumped dir: {DUMP_DIR}")
    
    assert os.path.exists(SRC_DIR), f"Không tìm thấy thư mục src: {SRC_DIR}"
    assert os.path.exists(DUMP_DIR), f"Không tìm thấy thư mục dump cấu hình: {DUMP_DIR}"
    
    src_files = get_relative_files(SRC_DIR)
    dump_files = get_relative_files(DUMP_DIR)
    
    print(f"  [i] Tổng số file trong src/: {len(src_files)}")
    print(f"  [i] Tổng số file trong dump/: {len(dump_files)}")
    
    missing_in_dump = []
    extra_in_dump = []
    hash_mismatches = []
    
    for rel_path, src_full in src_files.items():
        if rel_path not in dump_files:
            missing_in_dump.append(rel_path)
        else:
            h_src = compute_content_sha256(src_full)
            h_dump = compute_content_sha256(dump_files[rel_path])
            if h_src != h_dump:
                hash_mismatches.append((rel_path, h_src, h_dump))
                
    for rel_path in dump_files:
        if rel_path not in src_files:
            extra_in_dump.append(rel_path)
            
    if missing_in_dump:
        print(f"  [!] Missing in dump ({len(missing_in_dump)} files):")
        for f in missing_in_dump[:10]:
            print(f"      - {f}")
            
    if extra_in_dump:
        print(f"  [!] Extra in dump ({len(extra_in_dump)} files):")
        for f in extra_in_dump[:10]:
            print(f"      + {f}")
            
    if hash_mismatches:
        print(f"  [!] Hash mismatches ({len(hash_mismatches)} files):")
        for path, h1, h2 in hash_mismatches[:10]:
            print(f"      * {path} (src: {h1[:8]} vs dump: {h2[:8]})")
            
    total_diff = len(missing_in_dump) + len(extra_in_dump) + len(hash_mismatches)
    print(f"\n>> Tổng số sai lệch: {total_diff}")
    
    assert total_diff == 0, f"Cấu hình CSDL không khớp 100% với mã nguồn src/ (Diff = {total_diff})!"
    print(">> PASS: Cấu hình trong CSDL 1CD khớp 100% với mã nguồn src/ (0-diff, Hash Parity Verified)!\n")

if __name__ == "__main__":
    try:
        run_parity_audit()
    except AssertionError as e:
        print(f"FAILED: {e}")
        sys.exit(1)
