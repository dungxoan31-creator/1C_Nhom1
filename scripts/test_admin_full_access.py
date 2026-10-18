import unittest
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent

class TestAdminFullAccess(unittest.TestCase):
    def setUp(self):
        self.bsl_path = WORKSPACE_ROOT / "src" / "CommonModules" / "PhanQuyenBaoMatServer" / "Ext" / "Module.bsl"
        self.rights_path = WORKSPACE_ROOT / "src" / "Roles" / "QuanTriHeThong" / "Ext" / "Rights.xml"
        self.assertTrue(self.bsl_path.exists(), "PhanQuyenBaoMatServer Module.bsl must exist")
        self.assertTrue(self.rights_path.exists(), "QuanTriHeThong Rights.xml must exist")
        self.bsl_content = self.bsl_path.read_text(encoding="utf-8")
        self.rights_content = self.rights_path.read_text(encoding="utf-8")

    def test_admin_not_blocked_in_kiem_tra_quyen_chung_tu(self):
        """Admin and QuanTriHeThong must have unrestricted access to document write, post, unpost."""
        self.assertNotIn('Raise "Tài khoản quản trị hệ thống không được phép ghi sổ hoặc hủy ghi sổ chứng từ tài chính!"', self.bsl_content,
                         "Admin must not be blocked from posting/unposting documents")

    def test_admin_not_blocked_in_maker_checker(self):
        """Admin must not be blocked from business approval when performing system actions."""
        self.assertNotIn('Raise "Tài khoản quản trị hệ thống không được phép ký duyệt chứng từ tài chính kế toán!"', self.bsl_content,
                         "Admin must not be blocked by Maker-Checker restriction")
        self.assertNotIn('Raise "Admin kỹ thuật có thể bảo trì cấu hình nhưng không tự cấp chữ ký kế toán phê duyệt chứng từ tài chính!"', self.bsl_content,
                         "Admin must not have technical approval barrier")

    def test_maker_checker_still_protects_operational_roles(self):
        """Operational users (AR/AP/Accountants) must still strictly comply with Maker-Checker."""
        self.assertIn('Vi phạm nguyên tắc Maker-Checker: Người tạo/lập không thể tự phê duyệt chứng từ!', self.bsl_content)
        self.assertIn('Vi phạm phân định trách nhiệm (Segregation of Duties): Kế toán Phải thu (AR) không được phép ghi sổ', self.bsl_content)
        self.assertIn('Vi phạm phân định trách nhiệm (Segregation of Duties): Kế toán Phải trả (AP) không được phép ghi sổ', self.bsl_content)

    def test_admin_rights_xml_configured(self):
        """QuanTriHeThong must have setForNewObjects and setForAttributesByDefault enabled."""
        self.assertIn("<setForNewObjects>true</setForNewObjects>", self.rights_content)
        self.assertIn("<setForAttributesByDefault>true</setForAttributesByDefault>", self.rights_content)

if __name__ == "__main__":
    unittest.main()
