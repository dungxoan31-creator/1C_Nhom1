# -*- coding: utf-8 -*-
"""
Test Suite: Admin Full CRUD and Unrestricted System Access
Verifies:
1. QuanTriHeThong role Rights.xml has full object CRUD and administrative rights.
2. All Document form modules allow Admin full editing (do not lock ReadOnly=True for Admin).
3. Lifecycle & Security server modules (QuanLyVongDoiChungTuServer, PhanQuyenBaoMatServer,
   QuyTrinhPheDuyetAPServer) have Admin bypass for workflow transitions, Maker-Checker, and unposting.
4. Document Object modules allow Admin posting and lifecycle progression without blockage.
5. UserProvisioningServer grants all roles to Admin.
"""

import os
import re
import unittest
import xml.etree.ElementTree as ET

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

class TestAdminCrudFullAccess(unittest.TestCase):

    def test_quan_tri_he_thong_rights_xml(self):
        rights_path = os.path.join(REPO_ROOT, "src", "Roles", "QuanTriHeThong", "Ext", "Rights.xml")
        self.assertTrue(os.path.exists(rights_path), f"Rights.xml not found at {rights_path}")

        tree = ET.parse(rights_path)
        root = tree.getroot()

        # Check setForNewObjects
        set_for_new = root.find("{http://v8.1c.ru/8.2/roles}setForNewObjects")
        self.assertIsNotNone(set_for_new, "setForNewObjects tag missing")
        self.assertEqual(set_for_new.text.strip().lower(), "true", "setForNewObjects must be true")

        # Check setForAttributesByDefault
        set_for_attr = root.find("{http://v8.1c.ru/8.2/roles}setForAttributesByDefault")
        self.assertIsNotNone(set_for_attr, "setForAttributesByDefault tag missing")
        self.assertEqual(set_for_attr.text.strip().lower(), "true", "setForAttributesByDefault must be true")

        # Find Configuration object rights
        config_obj = None
        for obj in root.findall("{http://v8.1c.ru/8.2/roles}object"):
            name_tag = obj.find("{http://v8.1c.ru/8.2/roles}name")
            if name_tag is not None and name_tag.text.strip() == "Configuration":
                config_obj = obj
                break

        self.assertIsNotNone(config_obj, "Configuration object missing in Rights.xml")

        granted_rights = set()
        for right in config_obj.findall("{http://v8.1c.ru/8.2/roles}right"):
            r_name = right.find("{http://v8.1c.ru/8.2/roles}name")
            r_val = right.find("{http://v8.1c.ru/8.2/roles}value")
            if r_name is not None and r_val is not None and r_val.text.strip().lower() == "true":
                granted_rights.add(r_name.text.strip())

        expected_admin_rights = [
            "Administration",
            "DataAdministration",
            "UpdateDataBaseConfiguration",
            "ActiveUsers",
            "EventLog",
            "ThinClient",
            "WebClient",
            "ThickClient",
            "ExternalConnection",
            "Automation",
            "TechnicalSpecialistMode",
            "InteractiveOpenExtDataProcessors",
            "InteractiveOpenExtReports",
            "Output",
            "SaveUserData"
        ]
        for exp in expected_admin_rights:
            self.assertIn(exp, granted_rights, f"QuanTriHeThong must have Configuration right '{exp}'")

    def test_form_modules_do_not_lock_admin(self):
        forms = [
            "src/Documents/BienBanNghiemThuGiaiDoan/Forms/FormChungTu/Ext/Form/Module.bsl",
            "src/Documents/HoaDonGTGTDauRa/Forms/FormChungTu/Ext/Form/Module.bsl",
            "src/Documents/HoaDonNhaCungCap/Forms/FormChungTu/Ext/Form/Module.bsl",
            "src/Documents/PhieuThuTienKhachHang/Forms/FormChungTu/Ext/Form/Module.bsl",
            "src/Documents/UyNhiemChi/Forms/FormChungTu/Ext/Form/Module.bsl",
        ]
        for f in forms:
            fpath = os.path.join(REPO_ROOT, f)
            self.assertTrue(os.path.exists(fpath), f"Form file not found: {f}")
            with open(fpath, "r", encoding="utf-8") as fp:
                content = fp.read()

            self.assertIn("LaAdmin", content, f"{f} must check LaAdmin")
            self.assertIn('If Object.Posted And Not LaAdmin Then', content,
                          f"{f} must only lock ReadOnly when Not LaAdmin")
            self.assertIn('If Not LaAdmin Then', content,
                          f"{f} must only lock Number.ReadOnly when Not LaAdmin")

    def test_quan_ly_vong_doi_admin_bypass(self):
        server_path = os.path.join(REPO_ROOT, "src", "CommonModules", "QuanLyVongDoiChungTuServer", "Ext", "Module.bsl")
        self.assertTrue(os.path.exists(server_path))
        with open(server_path, "r", encoding="utf-8") as fp:
            content = fp.read()

        # KiemTraTrangThaiVaQuyen Admin bypass
        self.assertTrue(
            re.search(r"Procedure\s+KiemTraTrangThaiVaQuyen.*?(?=EndProcedure)", content, re.DOTALL),
            "KiemTraTrangThaiVaQuyen procedure missing"
        )
        kt_proc = re.search(r"Procedure\s+KiemTraTrangThaiVaQuyen.*?(?=EndProcedure)", content, re.DOTALL).group(0)
        self.assertIn("LaTaiKhoanAdmin", kt_proc)
        self.assertIn("Return;", kt_proc)

        # KiemTraChuyenTrangThai Admin bypass
        self.assertTrue(
            re.search(r"Procedure\s+KiemTraChuyenTrangThai.*?(?=EndProcedure)", content, re.DOTALL),
            "KiemTraChuyenTrangThai procedure missing"
        )
        chuyen_proc = re.search(r"Procedure\s+KiemTraChuyenTrangThai.*?(?=EndProcedure)", content, re.DOTALL).group(0)
        self.assertIn("LaTaiKhoanAdmin", chuyen_proc)
        self.assertIn("Return;", chuyen_proc)

        # GanNguoiLapKhiTaoMoi Admin bypass
        gan_proc = re.search(r"Procedure\s+GanNguoiLapKhiTaoMoi.*?(?=EndProcedure)", content, re.DOTALL).group(0)
        self.assertIn("LaTaiKhoanAdmin", gan_proc)

        # XuLyHuyGhiSo Admin bypass
        huy_proc = re.search(r"Procedure\s+XuLyHuyGhiSo.*?(?=EndProcedure)", content, re.DOTALL).group(0)
        self.assertIn("LaTaiKhoanAdmin", huy_proc)

    def test_quy_trinh_phe_duyet_ap_admin_bypass(self):
        ap_server = os.path.join(REPO_ROOT, "src", "CommonModules", "QuyTrinhPheDuyetAPServer", "Ext", "Module.bsl")
        self.assertTrue(os.path.exists(ap_server))
        with open(ap_server, "r", encoding="utf-8") as fp:
            content = fp.read()

        # KiemTraQuyenDuyet
        self.assertTrue(
            re.search(r"Procedure\s+KiemTraQuyenDuyet.*?(?=EndProcedure)", content, re.DOTALL),
            "KiemTraQuyenDuyet procedure missing"
        )
        proc1 = re.search(r"Procedure\s+KiemTraQuyenDuyet.*?(?=EndProcedure)", content, re.DOTALL).group(0)
        self.assertIn("LaTaiKhoanAdmin", proc1)
        self.assertIn("Return;", proc1)

        # KiemTraBuocDuyetAP
        self.assertTrue(
            re.search(r"Procedure\s+KiemTraBuocDuyetAP.*?(?=EndProcedure)", content, re.DOTALL),
            "KiemTraBuocDuyetAP procedure missing"
        )
        proc2 = re.search(r"Procedure\s+KiemTraBuocDuyetAP.*?(?=EndProcedure)", content, re.DOTALL).group(0)
        self.assertIn("LaTaiKhoanAdmin", proc2)
        self.assertIn("Return;", proc2)

    def test_document_object_modules_admin_bypass(self):
        docs = [
            ("src/Documents/BienBanNghiemThuGiaiDoan/Ext/ObjectModule.bsl", "DaGhiSo"),
            ("src/Documents/HoaDonGTGTDauRa/Ext/ObjectModule.bsl", "DaPhatHanh"),
            ("src/Documents/HoaDonNhaCungCap/Ext/ObjectModule.bsl", "DaGhiSo"),
            ("src/Documents/UyNhiemChi/Ext/ObjectModule.bsl", "DaGhiSo"),
        ]
        for rel_path, state in docs:
            fpath = os.path.join(REPO_ROOT, rel_path)
            self.assertTrue(os.path.exists(fpath), f"File not found: {rel_path}")
            with open(fpath, "r", encoding="utf-8") as fp:
                content = fp.read()

            self.assertIn("LaTaiKhoanAdmin", content, f"{rel_path} must check LaTaiKhoanAdmin")
            self.assertIn(state, content, f"{rel_path} must assign/allow {state} for Admin")

    def test_user_provisioning_assigns_all_roles_to_admin(self):
        prov_path = os.path.join(REPO_ROOT, "src", "CommonModules", "UserProvisioningServer", "Ext", "Module.bsl")
        self.assertTrue(os.path.exists(prov_path))
        with open(prov_path, "r", encoding="utf-8") as fp:
            content = fp.read()

        self.assertIn('If Item.Name = "Admin" Then', content)
        self.assertIn('For Each OtherRole In Metadata.Roles Do', content)
        self.assertIn('User.Roles.Add(OtherRole);', content)

if __name__ == "__main__":
    unittest.main()
