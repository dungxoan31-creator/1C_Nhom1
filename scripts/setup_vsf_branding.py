# -*- coding: utf-8 -*-
import os
import shutil
from PIL import Image, ImageDraw

def setup_branding():
    print("Setting up VSF Branding (Red & White)...")
    
    # 1. Ensure directories for CommonPictures exist with proper 1C format:
    # CommonPictures/<Name>/Ext/Picture.xml
    # CommonPictures/<Name>/Ext/Picture/Picture.png
    
    xml_template = """<?xml version="1.0" encoding="UTF-8"?>
<ExtPicture xmlns="http://v8.1c.ru/8.3/xcf/extrnprops" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<Picture>
\t\t<xr:Abs>Picture.png</xr:Abs>
\t\t<xr:LoadTransparent>false</xr:LoadTransparent>
\t</Picture>
</ExtPicture>
"""
    
    pictures = [
        "LogoVSF",
        "PhanHeDanhMuc",
        "PhanHePhaiThu",
        "PhanHeNganHangVaQuy",
        "PhanHePhaiTra",
        "PhanHeCanTruNetting",
        "PhanHeSoCaiVaDongBo"
    ]
    
    for pic in pictures:
        ext_dir = os.path.join("src", "CommonPictures", pic, "Ext")
        pic_sub_dir = os.path.join(ext_dir, "Picture")
        os.makedirs(pic_sub_dir, exist_ok=True)
        
        # Write Ext/Picture.xml
        with open(os.path.join(ext_dir, "Picture.xml"), "w", encoding="utf-8") as f:
            f.write(xml_template)
            
        # If Picture.png is in Ext/, copy or move it to Ext/Picture/Picture.png
        old_png = os.path.join(ext_dir, "Picture.png")
        target_png = os.path.join(pic_sub_dir, "Picture.png")
        if os.path.exists(old_png):
            shutil.copy2(old_png, target_png)
            print(f"  Copied {pic} to {target_png}")
        elif not os.path.exists(target_png):
            print(f"  Warning: {target_png} not found!")

    # 2. Setup src/Ext/Splash and src/Ext/MainSectionPicture
    splash_dir = os.path.join("src", "Ext", "Splash")
    os.makedirs(splash_dir, exist_ok=True)
    
    main_sec_dir = os.path.join("src", "Ext", "MainSectionPicture")
    os.makedirs(main_sec_dir, exist_ok=True)
    
    with open(os.path.join("src", "Ext", "Splash.xml"), "w", encoding="utf-8") as f:
        f.write(xml_template)
        
    with open(os.path.join("src", "Ext", "MainSectionPicture.xml"), "w", encoding="utf-8") as f:
        f.write(xml_template)

    # Copy VSF logo for Splash and MainSectionPicture
    logo_src = "src/CommonPictures/LogoVSF/Ext/Picture/Picture.png"
    if os.path.exists(logo_src):
        # Create high-res splash image (600x350) with white background and red VSF branding
        splash_img = Image.new("RGBA", (640, 360), (255, 255, 255, 255))
        draw = ImageDraw.Draw(splash_img)
        # Red top and bottom accent bars
        draw.rectangle([0, 0, 640, 8], fill=(234, 11, 42, 255))
        draw.rectangle([0, 352, 640, 360], fill=(234, 11, 42, 255))
        
        # Paste logo in center
        logo_img = Image.open(logo_src).convert("RGBA")
        # Resize logo nicely
        logo_w, logo_h = logo_img.size
        target_w = 420
        target_h = int(logo_h * (target_w / logo_w))
        logo_resized = logo_img.resize((target_w, target_h), Image.Resampling.LANCZOS)
        
        offset_x = (640 - target_w) // 2
        offset_y = (360 - target_h) // 2
        splash_img.paste(logo_resized, (offset_x, offset_y), mask=logo_resized.split()[3] if 'A' in logo_resized.getbands() else None)
        splash_img.save(os.path.join(splash_dir, "Picture.png"), "PNG")
        print("  Created src/Ext/Splash/Picture.png")
        
        # Create MainSection icon (48x48)
        ms_img = Image.new("RGBA", (48, 48), (255, 255, 255, 0))
        draw_ms = ImageDraw.Draw(ms_img)
        # Red rounded box
        draw_ms.rounded_rectangle([2, 2, 45, 45], radius=10, fill=(234, 11, 42, 255))
        # White "V" symbol for VinSmart
        draw_ms.polygon([(14, 14), (20, 14), (24, 30), (28, 14), (34, 14), (27, 34), (21, 34)], fill=(255, 255, 255, 255))
        ms_img.save(os.path.join(main_sec_dir, "Picture.png"), "PNG")
        print("  Created src/Ext/MainSectionPicture/Picture.png")

    # 3. Create FunctionsPanelSectionColor StyleItem
    func_color_xml = """<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<StyleItem uuid="43d8dd53-df3e-407e-a3c1-5b893cc1976c">
\t\t<Properties>
\t\t\t<Name>FunctionsPanelSectionColor</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>vi</v8:lang>
\t\t\t\t\t<v8:content>Màu phân hệ thanh chức năng VSF</v8:content>
\t\t\t\t</v8:item>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>Functions panel section color</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment>Tông đỏ VinSmart Future cho thanh phân hệ Taxi</Comment>
\t\t\t<Type>Color</Type>
\t\t\t<Value xsi:type="v8ui:Color">#EA0B2A</Value>
\t\t</Properties>
\t</StyleItem>
</MetaDataObject>
"""
    with open("src/StyleItems/FunctionsPanelSectionColor.xml", "w", encoding="utf-8") as f:
        f.write(func_color_xml)
    print("  Created src/StyleItems/FunctionsPanelSectionColor.xml")

    # 4. Create ClientApplicationInterface.xml with Sections Panel on top and Open Items Panel
    client_interface_xml = """<?xml version="1.0" encoding="UTF-8"?>
<ClientApplicationInterface xmlns="http://v8.1c.ru/8.2/managed-application/core" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="InterfaceLayouter">
\t<left>
\t\t<group id="left_group">
\t\t\t<group>
\t\t\t\t<panel id="sections_panel">
\t\t\t\t\t<uuid>8e10648b-f52d-4ec2-b4dd-87de33778d95</uuid>
\t\t\t\t</panel>
\t\t\t</group>
\t\t\t<group>
\t\t\t\t<panel id="functions_panel">
\t\t\t\t\t<uuid>13322b22-3960-4d68-93a6-fe2dd7f28ca3</uuid>
\t\t\t\t</panel>
\t\t\t</group>
\t\t</group>
\t</left>
\t<top>
\t\t<group id="top_group">
\t\t\t<panel id="open_items_panel">
\t\t\t\t<uuid>b553047f-c9aa-4157-978d-448ecad24248</uuid>
\t\t\t</panel>
\t\t</group>
\t</top>
\t<panelDef id="8e10648b-f52d-4ec2-b4dd-87de33778d95"/>
\t<panelDef id="b553047f-c9aa-4157-978d-448ecad24248"/>
\t<panelDef id="13322b22-3960-4d68-93a6-fe2dd7f28ca3"/>
\t<panelDef id="c933ac92-92cd-459d-81cc-e0c8a83ced99"/>
</ClientApplicationInterface>
"""
    with open("src/Ext/ClientApplicationInterface.xml", "w", encoding="utf-8") as f:
        f.write(client_interface_xml)
    print("  Created src/Ext/ClientApplicationInterface.xml")

    # 5. Create MainSectionCommandInterface.xml
    main_cmd_xml = """<?xml version="1.0" encoding="UTF-8"?>
<CommandInterface xmlns="http://v8.1c.ru/8.3/xcf/extrnprops" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<CommandsVisibility>
\t\t<Command name="Document.BienBanNghiemThuGiaiDoan.StandardCommand.OpenList">
\t\t\t<Visibility>
\t\t\t\t<xr:Common>true</xr:Common>
\t\t\t</Visibility>
\t\t</Command>
\t\t<Command name="Document.HoaDonGTGTDauRa.StandardCommand.OpenList">
\t\t\t<Visibility>
\t\t\t\t<xr:Common>true</xr:Common>
\t\t\t</Visibility>
\t\t</Command>
\t\t<Command name="Document.PhieuThuTienKhachHang.StandardCommand.OpenList">
\t\t\t<Visibility>
\t\t\t\t<xr:Common>true</xr:Common>
\t\t\t</Visibility>
\t\t</Command>
\t\t<Command name="Document.HoaDonNhaCungCap.StandardCommand.OpenList">
\t\t\t<Visibility>
\t\t\t\t<xr:Common>true</xr:Common>
\t\t\t</Visibility>
\t\t</Command>
\t\t<Command name="Document.UyNhiemChi.StandardCommand.OpenList">
\t\t\t<Visibility>
\t\t\t\t<xr:Common>true</xr:Common>
\t\t\t</Visibility>
\t\t</Command>
\t\t<Command name="Document.CanTruCongNoNoiBo.StandardCommand.OpenList">
\t\t\t<Visibility>
\t\t\t\t<xr:Common>true</xr:Common>
\t\t\t</Visibility>
\t\t</Command>
\t\t<Command name="Document.BaoCoNganHang.StandardCommand.OpenList">
\t\t\t<Visibility>
\t\t\t\t<xr:Common>true</xr:Common>
\t\t\t</Visibility>
\t\t</Command>
\t</CommandsVisibility>
\t<CommandsPlacement>
\t\t<Command name="Document.BienBanNghiemThuGiaiDoan.StandardCommand.OpenList">
\t\t\t<CommandGroup>NavigationPanelOrdinary</CommandGroup>
\t\t\t<Placement>Manual</Placement>
\t\t</Command>
\t\t<Command name="Document.HoaDonGTGTDauRa.StandardCommand.OpenList">
\t\t\t<CommandGroup>NavigationPanelOrdinary</CommandGroup>
\t\t\t<Placement>Manual</Placement>
\t\t</Command>
\t\t<Command name="Document.PhieuThuTienKhachHang.StandardCommand.OpenList">
\t\t\t<CommandGroup>NavigationPanelOrdinary</CommandGroup>
\t\t\t<Placement>Manual</Placement>
\t\t</Command>
\t\t<Command name="Document.HoaDonNhaCungCap.StandardCommand.OpenList">
\t\t\t<CommandGroup>NavigationPanelOrdinary</CommandGroup>
\t\t\t<Placement>Manual</Placement>
\t\t</Command>
\t\t<Command name="Document.UyNhiemChi.StandardCommand.OpenList">
\t\t\t<CommandGroup>NavigationPanelOrdinary</CommandGroup>
\t\t\t<Placement>Manual</Placement>
\t\t</Command>
\t\t<Command name="Document.CanTruCongNoNoiBo.StandardCommand.OpenList">
\t\t\t<CommandGroup>NavigationPanelOrdinary</CommandGroup>
\t\t\t<Placement>Manual</Placement>
\t\t</Command>
\t\t<Command name="Document.BaoCoNganHang.StandardCommand.OpenList">
\t\t\t<CommandGroup>NavigationPanelOrdinary</CommandGroup>
\t\t\t<Placement>Manual</Placement>
\t\t</Command>
\t</CommandsPlacement>
\t<CommandsOrder>
\t\t<Command name="Document.BienBanNghiemThuGiaiDoan.StandardCommand.OpenList">
\t\t\t<CommandGroup>NavigationPanelOrdinary</CommandGroup>
\t\t</Command>
\t\t<Command name="Document.HoaDonGTGTDauRa.StandardCommand.OpenList">
\t\t\t<CommandGroup>NavigationPanelOrdinary</CommandGroup>
\t\t</Command>
\t\t<Command name="Document.PhieuThuTienKhachHang.StandardCommand.OpenList">
\t\t\t<CommandGroup>NavigationPanelOrdinary</CommandGroup>
\t\t</Command>
\t\t<Command name="Document.HoaDonNhaCungCap.StandardCommand.OpenList">
\t\t\t<CommandGroup>NavigationPanelOrdinary</CommandGroup>
\t\t</Command>
\t\t<Command name="Document.UyNhiemChi.StandardCommand.OpenList">
\t\t\t<CommandGroup>NavigationPanelOrdinary</CommandGroup>
\t\t</Command>
\t\t<Command name="Document.CanTruCongNoNoiBo.StandardCommand.OpenList">
\t\t\t<CommandGroup>NavigationPanelOrdinary</CommandGroup>
\t\t</Command>
\t\t<Command name="Document.BaoCoNganHang.StandardCommand.OpenList">
\t\t\t<CommandGroup>NavigationPanelOrdinary</CommandGroup>
\t\t</Command>
\t</CommandsOrder>
</CommandInterface>
"""
    with open("src/Ext/MainSectionCommandInterface.xml", "w", encoding="utf-8") as f:
        f.write(main_cmd_xml)
    print("  Created src/Ext/MainSectionCommandInterface.xml")

    # 6. Update Configuration.xml to register FunctionsPanelSectionColor
    with open("src/Configuration.xml", "r", encoding="utf-8") as f:
        cfg = f.read()
    if "<StyleItem>FunctionsPanelSectionColor</StyleItem>" not in cfg:
        cfg = cfg.replace(
            "<StyleItem>MauVienChinhVSF</StyleItem>",
            "<StyleItem>MauVienChinhVSF</StyleItem>\n\t\t\t<StyleItem>FunctionsPanelSectionColor</StyleItem>"
        )
        with open("src/Configuration.xml", "w", encoding="utf-8") as f:
            f.write(cfg)
        print("  Registered FunctionsPanelSectionColor in Configuration.xml")

if __name__ == "__main__":
    setup_branding()
