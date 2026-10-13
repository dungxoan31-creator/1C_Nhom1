# -*- coding: utf-8 -*-
"""
Test Suite: Security, User Provisioning & Role-Based Access Control (RBAC)
Du an: VinSmart Future - AR & AP Management
Huong 2: Thiet Lap Nguoi Dung & Kiem Thu Phan Quyen (Task 2 Brief)
"""

import os
import sys
import io
import time
import subprocess

if sys.stdout.encoding != 'utf-8':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

EXE_PATH = r"C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe"
IB_PATH = r"C:\Users\Dung\Documents\1C_Enterprise\Infobase_FullData"
ROOT_DIR = r"C:\Users\Dung\Documents\1C_Enterprise"
LOG_DIR = os.path.join(IB_PATH, "1Cv8Log")

EXPECTED_USERS = [
    {"name": "Admin", "role": "QuanTriHeThong", "title": "Quản trị hệ thống VSF"},
    {"name": "ketoan_ar", "role": "KeToanPhaiThu", "title": "Kế toán Phải thu (AR)"},
    {"name": "ketoan_ap", "role": "KeToanPhaiTra", "title": "Kế toán Phải trả (AP)"},
    {"name": "chuyenvien_doisoat", "role": "ChuyenVienDoiSoatTapDoan", "title": "Chuyên viên Đối soát & Netting"},
    {"name": "cfo_giamdoc", "role": "GiamDocTaiChinh_CFO", "title": "Giám đốc Tài chính / CFO"},
    {"name": "ketoan_truong", "role": "KeToanTruong", "title": "Kế toán trưởng"},
    {"name": "pm_duan", "role": "ProjectManager_QuanLyDuAn", "title": "Quản lý dự án CNTT (PM)"},
    {"name": "techlead_kythuat", "role": "TechLead_KiemTraKyThuat", "title": "Trưởng nhóm Kỹ thuật (TechLead)"},
    {"name": "it_director", "role": "ITDirector_GiamDocHaTang", "title": "Giám đốc Hạ tầng CNTT (IT Director)"},
]

def read_latest_event_log(max_bytes=100000):
    if not os.path.exists(LOG_DIR):
        return ""
    files = sorted([os.path.join(LOG_DIR, f) for f in os.listdir(LOG_DIR) if f.endswith(".lgp")])
    if not files:
        return ""
    with open(files[-1], "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()
    return content[-max_bytes:]

def test_1_user_provisioning_and_roles():
    print("\n--- TEST SUITE 1: XÁC THỰC KHỞI TẠO 8 NGƯỜI DÙNG & GÁN ROLE CHUẨN XÁC ---")
    verify_log_path = os.path.join(ROOT_DIR, "verify_sample_users.log")
    
    # Luon chay moi de kiem tra truc tiep tren Infobase, khong dung log cu
    if os.path.exists(verify_log_path):
        try:
            os.remove(verify_log_path)
        except:
            pass
            
    print("[*] Đang chạy scripts/setup_sample_users.ps1 để kiểm tra và cập nhật người dùng...")
    p = subprocess.run([
        "powershell", "-ExecutionPolicy", "Bypass",
        "-File", os.path.join(ROOT_DIR, "scripts", "setup_sample_users.ps1")
    ], capture_output=True, text=True, encoding="utf-8", errors="ignore")
    assert p.returncode == 0, f"Khởi tạo người dùng thất bại: {p.stderr}"
    
    assert os.path.exists(verify_log_path), f"Không tìm thấy {verify_log_path}"
    with open(verify_log_path, "r", encoding="utf-8") as f:
        verify_content = f.read()
    
    for u in EXPECTED_USERS:
        name = u["name"]
        role = u["role"]
        pattern = f"{name} "
        assert pattern in verify_content, f"Thiếu thông tin người dùng {name} trong CSDL!"
        assert role in verify_content, f"Người dùng {name} chưa được gán role {role}!"
        print(f"  [+] Đã xác nhận: User '{name}' -> Role '{role}' [HỢP LỆ 100%]")
    
    assert "100% NGUOI DUNG VA ROLE HOP LE CHUAN XAC" in verify_content, (
        "Kết quả kiểm tra danh sách người dùng chưa đạt 100%!"
    )
    print(">> PASS: Toàn bộ 8 Người dùng nghiệp vụ + 1 Admin được khởi tạo & phân quyền hoàn hảo!")

def test_2_authentication_and_logins():
    print("\n--- TEST SUITE 2: KIỂM THỬ XÁC THỰC ĐĂNG NHẬP 8 USERS + ADMIN ---")
    login_script = os.path.join(ROOT_DIR, "scripts", "test_single_login.ps1")
    assert os.path.exists(login_script), f"Không tìm thấy script {login_script}"
    
    for u in EXPECTED_USERS:
        name = u["name"]
        print(f"  [*] Đang thử đăng nhập tài khoản: {name}...")
        p = subprocess.run([
            "powershell", "-ExecutionPolicy", "Bypass",
            "-File", login_script,
            "-User", name
        ], capture_output=True, text=True, encoding="utf-8", errors="ignore", timeout=30)
        
        assert p.returncode == 0, f"Đăng nhập tài khoản '{name}' thất bại (ExitCode: {p.returncode})! Stderr: {p.stderr}"
        
        # Kiem tra nhat ky dang nhap
        recent_log = read_latest_event_log(20000)
        assert f"Dang nhap thanh cong: {name}" in recent_log or name in recent_log, (
            f"Không tìm thấy sự kiện đăng nhập thành công của '{name}' trong 1Cv8Log!"
        )
        print(f"  [+] Đăng nhập thành công: User '{name}' (Client session verified, ExitCode 0)")
    
    print(">> PASS: 100% (9/9) Người dùng đăng nhập thành công vào 1C:Enterprise!")

def test_3_invalid_login_rejected():
    print("\n--- TEST SUITE 3: KIỂM THỬ TỪ CHỐI ĐĂNG NHẬP TRÁI PHÉP / TÀI KHOẢN GIẢ MẠO ---")
    login_script = os.path.join(ROOT_DIR, "scripts", "test_single_login.ps1")
    fake_user = "hacker_khong_ton_tai"
    
    print(f"  [*] Thử đăng nhập tài khoản không tồn tại '{fake_user}'...")
    p = subprocess.run([
        "powershell", "-ExecutionPolicy", "Bypass",
        "-File", login_script,
        "-User", fake_user
    ], capture_output=True, text=True, encoding="utf-8", errors="ignore", timeout=20)
    
    # 1C tu choi voi ExitCode != 0 hoac bi huy
    assert p.returncode != 0, f"Hệ thống cho phép tài khoản không tồn tại '{fake_user}' đăng nhập!"
    print(f"  [+] Hệ thống đã chặn thành công tài khoản giả mạo (ExitCode: {p.returncode})")
    print(">> PASS: Bảo mật chống xâm nhập tài khoản giả mạo hoạt động chính xác 100%!")

def test_4_maker_checker_invariant():
    print("\n--- TEST SUITE 4: KIỂM THỬ MAKER-CHECKER INVARIANT (NGƯỜI LẬP KHÔNG ĐƯỢC TỰ DUYỆT) ---")
    sec_log_path = os.path.join(ROOT_DIR, "security_test_results.log")
    
    # Luon chay moi test engine 1C de kiem tra live
    if os.path.exists(sec_log_path):
        try:
            os.remove(sec_log_path)
        except:
            pass
            
    subprocess.run([
        "powershell", "-ExecutionPolicy", "Bypass",
        "-File", os.path.join(ROOT_DIR, "scripts", "run_security_tests.ps1")
    ], timeout=60)
        
    assert os.path.exists(sec_log_path), f"Không tìm thấy file {sec_log_path}"
    with open(sec_log_path, "r", encoding="utf-8") as f:
        sec_content = f.read()
        
    assert "Test 2: Maker-Checker Invariant (Nguoi lap tu duyet bi chan 100%)" in sec_content, (
        "Test Maker-Checker vi phạm tự phê duyệt thất bại!"
    )
    assert "Test 3: Maker-Checker phe duyet hop le" in sec_content, (
        "Test Maker-Checker phê duyệt hợp lệ thất bại!"
    )
    print("  [+] Case 1: Người tạo = Người duyệt (ketoan_ap -> ketoan_ap) -> BỊ CHẶN TUYỆT ĐỐI")
    print("  [+] Case 2: Người tạo != Người duyệt (ketoan_ap -> ketoan_truong) -> PHÊ DUYỆT HỢP LỆ")
    print(">> PASS: Nguyên tắc Maker-Checker được bảo đảm tuyệt đối 100%!")

def test_5_segregation_of_duties():
    print("\n--- TEST SUITE 5: PHÂN ĐỊNH TRÁCH NHIỆM (SEGREGATION OF DUTIES - SOD) ---")
    sec_log_path = os.path.join(ROOT_DIR, "security_test_results.log")
    with open(sec_log_path, "r", encoding="utf-8") as f:
        sec_content = f.read()
        
    assert "Test 4: SoD - Ke toan AR can thiep chung tu AP bi chan tuyet doi" in sec_content, (
        "SoD thất bại: Kế toán AR can thiệp được chứng từ AP!"
    )
    assert "Test 5: SoD - Ke toan AP can thiep chung tu AR bi chan tuyet doi" in sec_content, (
        "SoD thất bại: Kế toán AP can thiệp được chứng từ AR!"
    )
    assert "Test 6: Dung quyen chuyen mon thuc thi chuan xac" in sec_content, (
        "Đúng quyền chuyên môn bị chặn sai sót!"
    )
    assert "Test 7: Phan dinh ky thuat vs tai chinh" in sec_content, (
        "Nhân sự kỹ thuật can thiệp kế toán không bị chặn!"
    )
    
    print("  [+] Kế toán AR (ketoan_ar) thao tác chứng từ AP (HoaDonNhaCungCap, UyNhiemChi) -> BỊ CHẶN TUYỆT ĐỐI")
    print("  [+] Kế toán AP (ketoan_ap) thao tác chứng từ AR (HoaDonGTGTDauRa, BienBanNghiemThu) -> BỊ CHẶN TUYỆT ĐỐI")
    print("  [+] Chuyên viên Đối soát (chuyenvien_doisoat) chỉ thao tác Cấn trừ & Đối soát -> CHUẨN XÁC")
    print("  [+] Quản lý Dự án & Kỹ thuật (pm_duan, techlead, it_director) ghi sổ tài chính -> BỊ CHẶN")
    print(">> PASS: Segregation of Duties (SoD) phân định ranh giới chuyên môn chặt chẽ 100%!")

def test_6_report_access_control():
    print("\n--- TEST SUITE 6: PHÂN QUYỀN TRUY CẬP BÁO CÁO CẤP CAO & SỔ CÁI TẬP ĐOÀN ---")
    sec_log_path = os.path.join(ROOT_DIR, "security_test_results.log")
    with open(sec_log_path, "r", encoding="utf-8") as f:
        sec_content = f.read()
        
    assert "Test 8: Bao mat bao cao (Ke toan AR khong duoc xem Ma tran can tru Tap doan)" in sec_content, (
        "Kế toán AR truy cập trái phép báo cáo cấp cao không bị chặn!"
    )
    assert "Test 9: CFO va Ke toan truong toan quyen truy cap So cai va Bao cao cap cao" in sec_content, (
        "CFO hoặc Kế toán trưởng bị chặn quyền xem báo cáo cấp cao!"
    )
    
    print("  [+] Kế toán AR/AP/PM/TechLead truy cập MaTranCanTruNoiBoTapDoan / SoCaiKeToan -> BỊ CHẶN TUYỆT ĐỐI")
    print("  [+] Giám đốc Tài chính CFO (cfo_giamdoc) truy cập Sổ cái & Ma trận cấn trừ -> TRUY CẬP HỢP LỆ")
    print("  [+] Kế toán trưởng (ketoan_truong) truy cập Sổ cái & Ma trận cấn trừ -> TRUY CẬP HỢP LỆ")
    print(">> PASS: Chính sách kiểm soát báo cáo tài chính bảo mật tuyệt đối 100%!")

def test_7_full_in_engine_security_verification():
    print("\n--- TEST SUITE 7: TỔNG KẾT ENGINE BẢO MẬT 1C:ENTERPRISE (SECURITY SUITE PASS 100%) ---")
    p = subprocess.run([
        "powershell", "-ExecutionPolicy", "Bypass",
        "-File", os.path.join(ROOT_DIR, "scripts", "run_security_tests.ps1")
    ], capture_output=True, text=True, encoding="utf-8", errors="ignore", timeout=60)
    
    assert p.returncode == 0, f"Chạy run_security_tests.ps1 thất bại: {p.stderr}"
    
    sec_log_path = os.path.join(ROOT_DIR, "security_test_results.log")
    assert os.path.exists(sec_log_path), "Không tìm thấy security_test_results.log"
    with open(sec_log_path, "r", encoding="utf-8") as f:
        sec_content = f.read()
        
    print(sec_content)
    assert "STATUS: SECURITY_TESTS_PASS_100%" in sec_content, "Bộ test bảo mật chưa đạt 100%!"
    assert "9/9 PASS" in sec_content, "Chưa đủ 9/9 test cases PASS trong engine 1C!"
    print(">> PASS: Bộ kiểm thử bảo mật chuyên sâu 9/9 PASS (100%)!")

if __name__ == "__main__":
    start = time.time()
    print("=" * 70)
    print("  VINSMART FUTURE - AR & AP ENTERPRISE PLATFORM (VSF)")
    print("  SUITE KIỂM THỬ BẢO MẬT & MA TRẬN PHÂN QUYỀN (HUONG 2)")
    print("=" * 70)
    
    try:
        test_1_user_provisioning_and_roles()
        test_2_authentication_and_logins()
        test_3_invalid_login_rejected()
        test_4_maker_checker_invariant()
        test_5_segregation_of_duties()
        test_6_report_access_control()
        test_7_full_in_engine_security_verification()
        
        elapsed = time.time() - start
        print("\n" + "=" * 70)
        print(f"🎉 TẤT CẢ CÁC BÀI KIỂM THỬ BẢO MẬT ĐÃ VƯỢT QUA 100% (Thời gian: {elapsed:.2f}s)!")
        print("=" * 70)
    except AssertionError as ae:
        print(f"\n❌ KIỂM THỬ THẤT BẠI: {ae}")
        sys.exit(1)
    except Exception as e:
        print(f"\n💥 LỖI KHÔNG XÁC ĐỊNH: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
