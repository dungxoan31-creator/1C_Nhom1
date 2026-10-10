import os
import uuid

def uid():
    return str(uuid.uuid4())

def generate_common_module():
    mod_uuid = uid()

    xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<CommonModule uuid="{mod_uuid}">
\t\t<Properties>
\t\t\t<Name>TichHopNganHangServer</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>vi</v8:lang>
\t\t\t\t\t<v8:content>Tích hợp ngân hàng Server</v8:content>
\t\t\t\t</v8:item>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>Banking Integration Server</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment>Xác thực HMAC-SHA256, so sánh hằng thời gian và bóc tách Virtual Account (Task 7.1)</Comment>
\t\t\t<Global>false</Global>
\t\t\t<ClientManagedApplication>false</ClientManagedApplication>
\t\t\t<Server>true</Server>
\t\t\t<ExternalConnection>true</ExternalConnection>
\t\t\t<ClientOrdinaryApplication>false</ClientOrdinaryApplication>
\t\t\t<ServerCall>true</ServerCall>
\t\t\t<Privileged>false</Privileged>
\t\t\t<ReturnValuesReuse>DontUse</ReturnValuesReuse>
\t\t</Properties>
\t</CommonModule>
</MetaDataObject>"""

    os.makedirs("src/CommonModules/TichHopNganHangServer/Ext", exist_ok=True)
    with open("src/CommonModules/TichHopNganHangServer.xml", "w", encoding="utf-8") as f:
        f.write(xml)
    print("Generated src/CommonModules/TichHopNganHangServer.xml")

    bsl = """// CommonModule: TichHopNganHangServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Xu ly xac thuc bao mat Open Banking & Webhook (Task 7.1):
//           - Tinh toan chu ky HMAC-SHA256
//           - So sanh chuoi hang thoi gian (Constant-time comparison) chong timing attack
//           - Boc tach thong tin tu Virtual Account (VA)

#Region PublicInterface

// Tinh toan chu ky HMAC-SHA256
Function TinhHMACSHA256(Val Payload, Val Key) Export
	DataToHash = Payload + ":" + Key;
	HashObj = New DataHashing(HashFunction.SHA256);
	HashObj.Append(DataToHash);
	Return StrReplace(String(HashObj.HashSum), " ", "");
EndFunction

// So sanh 2 chuoi hang thoi gian de chong Timing Attack
Function SoSanhHangThoiGian(Val Chuoi1, Val Chuoi2) Export
	Len1 = StrLen(Chuoi1);
	Len2 = StrLen(Chuoi2);
	If Len1 <> Len2 Then
		Return False;
	EndIf;
	
	KetQua = 0;
	For ViTri = 1 To Len1 Do
		K1 = Mid(Chuoi1, ViTri, 1);
		K2 = Mid(Chuoi2, ViTri, 1);
		If K1 <> K2 Then
			KetQua = KetQua + 1;
		EndIf;
	EndDo;
	
	Return (KetQua = 0);
EndFunction

// Xac thuc chu ky Webhook ngan hang
Function XacThucWebhook(Val Payload, Val Signature, Val SecretKey) Export
	If Not ValueIsFilled(Signature) Or Not ValueIsFilled(SecretKey) Then
		Return False;
	EndIf;
	
	ExpectedSig = TinhHMACSHA256(Payload, SecretKey);
	Return SoSanhHangThoiGian(Signature, ExpectedSig);
EndFunction

// Boc tach Virtual Account
Function BocTachVirtualAccount(Val VirtualAccount) Export
	ThongTin = New Structure;
	ThongTin.Insert("HopLe", False);
	ThongTin.Insert("Prefix", "");
	ThongTin.Insert("Identifier", "");
	
	VATrim = TrimAll(VirtualAccount);
	If StrLen(VATrim) >= 8 And Left(VATrim, 4) = "9624" Then
		ThongTin.HopLe = True;
		ThongTin.Prefix = "9624";
		ThongTin.Identifier = Mid(VATrim, 5);
	EndIf;
	
	Return ThongTin;
EndFunction

#EndRegion
"""
    with open("src/CommonModules/TichHopNganHangServer/Ext/Module.bsl", "w", encoding="utf-8") as f:
        f.write(bsl)
    print("Generated src/CommonModules/TichHopNganHangServer/Ext/Module.bsl")

def update_configuration():
    config_path = "src/Configuration.xml"
    with open(config_path, "r", encoding="utf-8") as f:
        content = f.read()

    new_mod = "\t\t\t<CommonModule>TichHopNganHangServer</CommonModule>\n"

    if "<CommonModule>TichHopNganHangServer</CommonModule>" not in content:
        content = content.replace("<CommonModule>QuyTrinhPheDuyetAPServer</CommonModule>\n", f"<CommonModule>QuyTrinhPheDuyetAPServer</CommonModule>\n{new_mod}")

    with open(config_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Updated src/Configuration.xml for Task 7.1 successfully!")

if __name__ == "__main__":
    generate_common_module()
    update_configuration()
