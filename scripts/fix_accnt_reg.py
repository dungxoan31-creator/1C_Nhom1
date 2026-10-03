import uuid

with open('src/AccountingRegisters/GeneralLedger.xml', 'r', encoding='utf-8') as f:
    content = f.read()

internal_info = f"""\t\t<InternalInfo>
\t\t\t<xr:GeneratedType name="AccountingRegisterSelection.GeneralLedger" category="Selection">
\t\t\t\t<xr:TypeId>{uuid.uuid4()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uuid.uuid4()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="AccountingRegisterList.GeneralLedger" category="List">
\t\t\t\t<xr:TypeId>{uuid.uuid4()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uuid.uuid4()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="AccountingRegisterManager.GeneralLedger" category="Manager">
\t\t\t\t<xr:TypeId>{uuid.uuid4()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uuid.uuid4()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="AccountingRegisterRecord.GeneralLedger" category="Record">
\t\t\t\t<xr:TypeId>{uuid.uuid4()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uuid.uuid4()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="AccountingRegisterRecordSet.GeneralLedger" category="RecordSet">
\t\t\t\t<xr:TypeId>{uuid.uuid4()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uuid.uuid4()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="AccountingRegisterRecordKey.GeneralLedger" category="RecordKey">
\t\t\t\t<xr:TypeId>{uuid.uuid4()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uuid.uuid4()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="AccountingRegisterExtDimensions.GeneralLedger" category="ExtDimensions">
\t\t\t\t<xr:TypeId>{uuid.uuid4()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uuid.uuid4()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t</InternalInfo>"""

import re
content = re.sub(r'\t\t<InternalInfo>.*?</InternalInfo>', internal_info, content, flags=re.DOTALL)

with open('src/AccountingRegisters/GeneralLedger.xml', 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated GeneralLedger.xml with all 7 GeneratedTypes!")
