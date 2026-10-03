import glob, re

matches = set()
for path in glob.glob(r'C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\*.*'):
    try:
        with open(path, 'rb') as f:
            data = f.read()
            m1 = re.findall(rb'GeneratedType name="([^"]+)" category="([^"]+)"', data)
            matches.update(m1)
            # utf-16le search
            m2 = re.findall(b'G\x00e\x00n\x00e\x00r\x00a\x00t\x00e\x00d\x00T\x00y\x00p\x00e\x00 [^>]+>', data)
            for item in m2:
                s = item.decode('utf-16le', errors='ignore')
                n = re.search(r'name="([^"]+)"', s)
                c = re.search(r'category="([^"]+)"', s)
                if n and c:
                    matches.add((n.group(1).encode('latin1'), c.group(1).encode('latin1')))
    except Exception as e:
        pass

for name, cat in sorted(matches):
    s_name = name.decode('latin1', errors='ignore')
    s_cat = cat.decode('latin1', errors='ignore')
    if 'ChartOfAccounts' in s_name or 'Accounting' in s_name:
        print(s_name, '-->', s_cat)
