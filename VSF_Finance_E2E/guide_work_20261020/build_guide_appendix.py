from pathlib import Path
import re
import xml.etree.ElementTree as ET

root = Path(__file__).parent / "Configuration"
guide = Path(__file__).resolve().parents[2] / "docs" / "Huong_dan_su_dung_VSF_2026-10-20.md"
forms_text = (Path(__file__).parent / "forms_inventory.txt").read_text(encoding="utf-8-sig")
marker = "<!-- GENERATED INVENTORY -->"


def local(tag):
    return tag.rsplit("}", 1)[-1]


def child(node, name):
    return next((x for x in node if local(x.tag) == name), None)


def field_text(node, name):
    x = child(node, name)
    return "" if x is None else "".join(x.itertext()).strip()


def label(props):
    syn = child(props, "Synonym")
    if syn is not None:
        for item in syn:
            if field_text(item, "lang") == "vi":
                return field_text(item, "content")
    return field_text(props, "Name")


def field_type(props):
    t = child(props, "Type")
    if t is None:
        return ""
    types = [x.text.strip().removeprefix("cfg:") for x in t.iter() if local(x.tag) == "Type" and x.text and x.text.strip()]
    if types:
        return ", ".join(types)
    return ""


def clean(value):
    return value.replace("|", "\\|").replace("\n", " ")


section_names = {
    "Catalogs": "Danh mục",
    "Documents": "Chứng từ",
    "InformationRegisters": "Sổ thông tin",
    "AccumulationRegisters": "Sổ tích lũy",
    "AccountingRegisters": "Sổ cái",
    "ChartsOfAccounts": "Kế hoạch tài khoản",
    "Constants": "Hằng số",
    "Enums": "Giá trị chọn",
}

lines = [marker, "### A. Toàn bộ trường của từng đối tượng", ""]
for folder, heading in section_names.items():
    files = sorted((root / folder).glob("*.xml"))
    lines.extend([f"#### {heading}", ""])
    for xml_file in files:
        tree = ET.parse(xml_file)
        obj = next(iter(tree.getroot()))
        props = child(obj, "Properties")
        if props is None:
            continue
        name = field_text(props, "Name")
        lines.extend([f"**{clean(label(props))}** (`{name}`)", ""])
        if folder == "Catalogs":
            lines.append("Trường chuẩn: `Code` (Mã), `Description` (Tên), `DeletionMark` (Đánh dấu xóa).")
        elif folder == "Documents":
            lines.append("Trường chuẩn: `Number` (Số tự động), `Date` (Ngày, bắt buộc), `Posted` (Đã ghi sổ), `DeletionMark` (Đánh dấu xóa).")
        elif folder == "ChartsOfAccounts":
            lines.append("Trường chuẩn: `Code`, `Description`, `Parent`, `Type`, `OffBalance`, `Order`, `DeletionMark`.")
        elif folder == "InformationRegisters" and field_text(props, "InformationRegisterPeriodicity") not in ("", "Nonperiodical"):
            lines.append("Trường chuẩn: `Period` (Ngày/Kỳ ghi tỷ giá).")
        if folder == "Constants":
            lines.append(f"Giá trị: `{clean(field_type(props))}`.")
        co = child(obj, "ChildObjects")
        entries = []
        if co is not None:
            for item in co:
                kind = local(item.tag)
                ip = child(item, "Properties")
                if ip is None or kind not in ("Attribute", "Dimension", "Resource", "EnumValue", "TabularSection"):
                    continue
                n = field_text(ip, "Name")
                title = label(ip)
                typ = field_type(ip)
                required = "Có" if field_text(ip, "FillChecking") == "ShowError" else ""
                entries.append((n, title, typ, required, kind))
        if entries:
            lines.extend(["", "| Trường kỹ thuật | Nhãn tiếng Việt | Kiểu / nhóm | Bắt buộc |", "|---|---|---|---|"])
            for n, title, typ, required, kind in entries:
                desc = typ or {"EnumValue": "Giá trị trạng thái", "TabularSection": "Bảng"}.get(kind, kind)
                lines.append(f"| `{clean(n)}` | {clean(title)} | {clean(desc)} | {required} |")
        lines.append("")

lines.extend(["### B. Từng điều khiển trên 12 form tự thiết kế", "", "Ký hiệu trong danh sách: `[Input]` là ô nhập/chọn, `[Check]` là checkbox, `[Page]` là tab, `[Button]` là nút riêng; `[ro]` là chỉ đọc. Tên sau `->` là dữ liệu được ghi/đọc. Các trường lặp ở hai tab cùng trỏ vào **một** trường dữ liệu. Thanh lệnh `[autofill]` do 1C tự tạo và phụ thuộc quyền.", ""])
for block in re.split(r"(?=^### )", forms_text, flags=re.M):
    if not block.strip():
        continue
    raw = block.splitlines()
    path = raw[0][4:].strip().replace("\\", "/")
    summary = next((x for x in raw if x.startswith("=== Form:")), "")
    title = summary.split(" — ", 1)[1].rsplit(" (", 1)[0].strip('"') if " — " in summary else path
    lines.extend([f"#### {title}", "", f"Nguồn: `{path}`", "", "```text"])
    start = next((i for i, x in enumerate(raw) if x.startswith("AutoCommandBar") or x.startswith("Elements:")), 0)
    lines.extend(raw[start:])
    lines.extend(["```", ""])

original = guide.read_text(encoding="utf-8")
original = original.split(marker, 1)[0]
guide.write_text(original + "\n".join(lines) + "\n", encoding="utf-8")
print(f"Wrote {guide}, {len(lines)} appendix lines")
