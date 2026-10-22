from pathlib import Path

root = Path(__file__).parent / "Configuration"
guide = Path(__file__).resolve().parents[2] / "docs" / "Huong_dan_su_dung_VSF_2026-10-20.md"
text = guide.read_text(encoding="utf-8")
folders = [
    "Catalogs", "Documents", "InformationRegisters", "AccumulationRegisters",
    "AccountingRegisters", "ChartsOfAccounts", "Constants", "Enums",
]
objects = [p for folder in folders for p in (root / folder).glob("*.xml")]
forms = list(root.glob("**/Form.xml"))
missing_objects = [p.name for p in objects if f"(`{p.stem}`)" not in text]
missing_forms = [str(p) for p in forms if p.relative_to(root).as_posix() not in text]
bad = [value for value in (", xs:string", ", xs:decimal", '#### "') if value in text]
fences_even = text.count("```text") == text.count("\n```\n")
print(f"Objects: {len(objects)}; forms: {len(forms)}; guide bytes: {len(text.encode('utf-8'))}")
print(f"Missing objects: {missing_objects}; missing forms: {missing_forms}")
print(f"Bad tokens: {bad}; balanced form code blocks: {fences_even}")
assert len(forms) == 12
assert not missing_objects and not missing_forms and not bad and fences_even
