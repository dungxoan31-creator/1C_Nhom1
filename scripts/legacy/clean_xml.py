import re

with open("src/Documents/BangKeDoiSoatKenhThanhToan.xml", "r", encoding="utf-8") as f:
    content = f.read()

# In TabularSection, remove FillFromFillingValue and FillValue
parts = content.split("<TabularSection")
header_part = parts[0]
tab_part = "<TabularSection" + parts[1]

tab_part = re.sub(r"\s*<FillFromFillingValue>false</FillFromFillingValue>", "", tab_part)
tab_part = re.sub(r"\s*<FillValue xsi:nil=\"true\"/>", "", tab_part)

with open("src/Documents/BangKeDoiSoatKenhThanhToan.xml", "w", encoding="utf-8") as f:
    f.write(header_part + tab_part)

print("Cleaned BangKeDoiSoatKenhThanhToan.xml successfully!")
