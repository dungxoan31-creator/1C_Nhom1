# -*- coding: utf-8 -*-
import os
import shutil
import uuid
from PIL import Image, ImageDraw, ImageFont

# 1. Colors
VSF_RED = (234, 11, 42)      # #EA0B2A
VSF_DARK_RED = (183, 0, 11)  # #B7000B
WHITE = (255, 255, 255)
LIGHT_BG = (253, 248, 248)
TRANSPARENT = (0, 0, 0, 0)

COMMON_PICTURES_DIR = os.path.join('src', 'CommonPictures')
STYLE_ITEMS_DIR = os.path.join('src', 'StyleItems')
os.makedirs(COMMON_PICTURES_DIR, exist_ok=True)
os.makedirs(STYLE_ITEMS_DIR, exist_ok=True)

# 2. Setup VSF Logo
logo_src = r'C:\Users\Dung\AppData\Local\Temp\orca-paste-1791696378264-3db24008-1353-4efd-9080-8b6b8f1c9702.png'
logo_dir = os.path.join(COMMON_PICTURES_DIR, 'LogoVSF', 'Ext')
os.makedirs(logo_dir, exist_ok=True)
if os.path.exists(logo_src):
    shutil.copy2(logo_src, os.path.join(logo_dir, 'Picture.png'))
    print('Copied LogoVSF from temp path')

def create_common_picture_xml(name, vi_title, en_title):
    obj_uuid = str(uuid.uuid4())
    xml_content = f'''<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<CommonPicture uuid="{obj_uuid}">
\t\t<Properties>
\t\t\t<Name>{name}</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>vi</v8:lang>
\t\t\t\t\t<v8:content>{vi_title}</v8:content>
\t\t\t\t</v8:item>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>{en_title}</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment>Biểu tượng phong cách đỏ trắng VinSmart Future</Comment>
\t\t\t<AvailabilityForChoice>false</AvailabilityForChoice>
\t\t\t<AvailabilityForAppearance>false</AvailabilityForAppearance>
\t\t</Properties>
\t</CommonPicture>
</MetaDataObject>
'''
    with open(os.path.join(COMMON_PICTURES_DIR, f'{name}.xml'), 'w', encoding='utf-8') as f:
        f.write(xml_content)

create_common_picture_xml('LogoVSF', 'Logo VinSmart Future', 'VSF Logo')

# 3. Helper to draw sharp icons with 4x supersampling (192x192 -> 48x48)
def draw_base_badge(size=192):
    img = Image.new('RGBA', (size, size), TRANSPARENT)
    draw = ImageDraw.Draw(img)
    # Rounded badge in VSF red
    margin = 8
    radius = 36
    draw.rounded_rectangle([margin, margin, size - margin, size - margin], radius=radius, fill=VSF_RED)
    # Subtle inner white border
    draw.rounded_rectangle([margin + 4, margin + 4, size - margin - 4, size - margin - 4], radius=radius - 4, outline=(255, 255, 255, 60), width=3)
    return img, draw

# Icon 1: PhanHePhaiThu (Accounts Receivable - Invoice with incoming arrow)
def make_icon_phai_thu():
    img, draw = draw_base_badge()
    # Document sheet
    draw.rounded_rectangle([48, 40, 120, 144], radius=8, fill=WHITE)
    # Lines on document
    draw.line([(60, 60), (108, 60)], fill=VSF_RED, width=6)
    draw.line([(60, 78), (108, 78)], fill=VSF_RED, width=5)
    draw.line([(60, 96), (96, 96)], fill=VSF_RED, width=5)
    # Big incoming green/white badge arrow pointing down-left or plus sign
    draw.ellipse([100, 100, 164, 164], fill=VSF_DARK_RED, outline=WHITE, width=4)
    # Arrow in badge
    draw.polygon([(132, 114), (132, 140), (144, 140), (132, 154), (120, 140), (126, 140), (126, 114)], fill=WHITE)
    return img.resize((48, 48), Image.Resampling.LANCZOS)

# Icon 2: PhanHePhaiTra (Accounts Payable - Credit card / payment outgoing)
def make_icon_phai_tra():
    img, draw = draw_base_badge()
    # Credit card shape
    draw.rounded_rectangle([36, 52, 156, 124], radius=12, fill=WHITE)
    draw.rectangle([36, 70, 156, 88], fill=VSF_DARK_RED) # magnetic stripe
    # Chip
    draw.rounded_rectangle([52, 96, 76, 114], radius=4, fill=VSF_RED)
    # Small outgoing arrow badge
    draw.ellipse([104, 104, 168, 168], fill=VSF_DARK_RED, outline=WHITE, width=4)
    draw.polygon([(136, 154), (136, 128), (124, 128), (136, 114), (148, 128), (142, 128), (142, 154)], fill=WHITE)
    return img.resize((48, 48), Image.Resampling.LANCZOS)

# Icon 3: PhanHeNganHangVaQuy (Bank building / vault)
def make_icon_ngan_hang():
    img, draw = draw_base_badge()
    # Bank pediment triangle roof
    draw.polygon([(96, 36), (36, 68), (156, 68)], fill=WHITE)
    # Architrave beam
    draw.rectangle([40, 68, 152, 78], fill=WHITE)
    # 4 columns
    for x in [48, 74, 106, 132]:
        draw.rectangle([x, 82, x + 12, 134], fill=WHITE)
    # Foundation base steps
    draw.rectangle([34, 134, 158, 144], fill=WHITE)
    draw.rectangle([28, 144, 164, 154], fill=WHITE)
    return img.resize((48, 48), Image.Resampling.LANCZOS)

# Icon 4: PhanHeCanTruNetting (Multilateral netting balance scale / exchange arrows)
def make_icon_can_tru():
    img, draw = draw_base_badge()
    # Balance beam scale
    # Central pole
    draw.rectangle([92, 44, 100, 148], fill=WHITE)
    draw.ellipse([88, 36, 104, 52], fill=WHITE) # top finial
    # Horizontal bar
    draw.line([(44, 64), (148, 64)], fill=WHITE, width=8)
    # Left pan strings and pan
    draw.line([(48, 68), (32, 106)], fill=WHITE, width=4)
    draw.line([(48, 68), (64, 106)], fill=WHITE, width=4)
    draw.chord([28, 100, 68, 120], start=0, end=180, fill=WHITE)
    # Right pan strings and pan
    draw.line([(144, 68), (128, 106)], fill=WHITE, width=4)
    draw.line([(144, 68), (160, 106)], fill=WHITE, width=4)
    draw.chord([124, 100, 164, 120], start=0, end=180, fill=WHITE)
    # Base
    draw.polygon([(76, 152), (116, 152), (108, 140), (84, 140)], fill=WHITE)
    return img.resize((48, 48), Image.Resampling.LANCZOS)

# Icon 5: PhanHeSoCaiVaDongBo (General Ledger & CFO Dashboard)
def make_icon_so_cai():
    img, draw = draw_base_badge()
    # Ledger book
    draw.rounded_rectangle([40, 44, 152, 148], radius=10, fill=WHITE)
    # Book spine
    draw.rectangle([40, 44, 56, 148], fill=VSF_DARK_RED)
    # Spreadsheet / ledger lines
    draw.line([(70, 64), (136, 64)], fill=VSF_RED, width=5)
    draw.line([(70, 84), (136, 84)], fill=VSF_RED, width=5)
    draw.line([(70, 104), (136, 104)], fill=VSF_RED, width=5)
    draw.line([(70, 124), (136, 124)], fill=VSF_RED, width=5)
    draw.line([(100, 56), (100, 136)], fill=VSF_RED, width=4)
    return img.resize((48, 48), Image.Resampling.LANCZOS)

# Icon 6: PhanHeDanhMuc (Master Data / Catalog cards)
def make_icon_danh_muc():
    img, draw = draw_base_badge()
    # 3 layered catalog cards / folders
    draw.rounded_rectangle([60, 36, 148, 92], radius=8, fill=(255, 255, 255, 160))
    draw.rounded_rectangle([48, 64, 140, 120], radius=8, fill=(255, 255, 255, 210))
    draw.rounded_rectangle([36, 92, 156, 152], radius=8, fill=WHITE)
    # Card lines
    draw.line([(52, 112), (100, 112)], fill=VSF_RED, width=6)
    draw.line([(52, 130), (140, 130)], fill=VSF_DARK_RED, width=5)
    return img.resize((48, 48), Image.Resampling.LANCZOS)

icons = {
    'PhanHePhaiThu': (make_icon_phai_thu(), '1. Phải thu (AR)', 'Accounts Receivable (AR)'),
    'PhanHePhaiTra': (make_icon_phai_tra(), '2. Phải trả (AP)', 'Accounts Payable (AP)'),
    'PhanHeNganHangVaQuy': (make_icon_ngan_hang(), '3. Ngân hàng & Quỹ', 'Banking & Treasury'),
    'PhanHeCanTruNetting': (make_icon_can_tru(), '4. Cấn trừ nợ (Netting)', 'Intercompany Netting'),
    'PhanHeSoCaiVaDongBo': (make_icon_so_cai(), '5. Sổ cái & Bàn làm việc CFO', 'General Ledger & CFO Dashboard'),
    'PhanHeDanhMuc': (make_icon_danh_muc(), '6. Danh mục hệ thống', 'Master Data Catalogs')
}

for name, (img, vi_syn, en_syn) in icons.items():
    pdir = os.path.join(COMMON_PICTURES_DIR, name, 'Ext')
    os.makedirs(pdir, exist_ok=True)
    img_path = os.path.join(pdir, 'Picture.png')
    img.save(img_path, format='PNG')
    create_common_picture_xml(name, vi_syn, en_syn)
    print(f'Generated icon: {img_path}')

# 4. Create StyleItems for Red-White palette
style_items = [
    ('MauChuDaoVSF', 'Màu đỏ thương hiệu VSF', 'VSF Crimson Red', '#EA0B2A'),
    ('MauChuDaoDamVSF', 'Màu đỏ đậm VSF', 'VSF Dark Red Accent', '#B7000B'),
    ('MauNenChinhVSF', 'Màu nền trắng VSF', 'VSF Main White Background', '#FFFFFF'),
    ('MauNenPhuVSF', 'Màu nền trắng ấm VSF', 'VSF Light Off-White Background', '#FDF8F8'),
    ('MauVanBanChinhVSF', 'Màu văn bản chính VSF', 'VSF Primary Text Color', '#1E2124'),
    ('MauVanBanTrangVSF', 'Màu chữ trắng trên nền đỏ VSF', 'VSF White Text on Red', '#FFFFFF'),
    ('MauCanhBaoDoVSF', 'Màu đỏ cảnh báo VSF', 'VSF Alert Red Color', '#EA0B2A'),
    ('MauVienChinhVSF', 'Màu đường viền xám nhạt VSF', 'VSF Border Light Grey', '#E0E0E0'),
]

for name, vi_syn, en_syn, hex_val in style_items:
    si_uuid = str(uuid.uuid4())
    si_xml = f'''<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<StyleItem uuid="{si_uuid}">
\t\t<Properties>
\t\t\t<Name>{name}</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>vi</v8:lang>
\t\t\t\t\t<v8:content>{vi_syn}</v8:content>
\t\t\t\t</v8:item>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>{en_syn}</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment/>
\t\t\t<Type>Color</Type>
\t\t\t<Value xsi:type="v8ui:Color">{hex_val}</Value>
\t\t</Properties>
\t</StyleItem>
</MetaDataObject>
'''
    with open(os.path.join(STYLE_ITEMS_DIR, f'{name}.xml'), 'w', encoding='utf-8') as f:
        f.write(si_xml)
    print(f'Generated StyleItem: {name}')

print('All assets generated successfully!')
