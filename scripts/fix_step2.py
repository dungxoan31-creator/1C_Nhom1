with open('src/ChartsOfAccounts/Main.xml', 'r', encoding='utf-8') as f:
    coa = f.read()

coa = coa.replace('\t\t\t<CodeType>String</CodeType>\n', '')
coa = coa.replace('\t\t\t<AutoOrderName>true</AutoOrderName>\n', '')

with open('src/ChartsOfAccounts/Main.xml', 'w', encoding='utf-8') as f:
    f.write(coa)

# Add AccountingRegister.GeneralLedger to RegisterRecords of ReceiveAndImportProducts
with open('src/Documents/ReceiveAndImportProducts.xml', 'r', encoding='utf-8') as f:
    doc = f.read()

rec_item = '\t\t\t\t<xr:Item xsi:type="xr:MDObjectRef">AccountingRegister.GeneralLedger</xr:Item>\n'
if 'AccountingRegister.GeneralLedger' not in doc:
    doc = doc.replace(
        '<xr:Item xsi:type="xr:MDObjectRef">AccumulationRegister.Inventory</xr:Item>',
        '<xr:Item xsi:type="xr:MDObjectRef">AccumulationRegister.Inventory</xr:Item>\n' + rec_item
    )
    with open('src/Documents/ReceiveAndImportProducts.xml', 'w', encoding='utf-8') as f:
        f.write(doc)

print("Updated Main.xml properties and added GeneralLedger as RegisterRecord to ReceiveAndImportProducts")
