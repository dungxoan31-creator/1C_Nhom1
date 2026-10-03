with open(r'C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\accntt.dll', 'rb') as f:
    d = f.read()

import re
for m in re.finditer(b'c\x00a\x00t\x00e\x00g\x00o\x00r\x00y\x00=\x00"\x00([^"]+)\x00"\x00', d):
    print('Found category:', m.group(1).decode('utf-16le', errors='ignore'))
