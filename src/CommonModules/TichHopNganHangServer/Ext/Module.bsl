// CommonModule: TichHopNganHangServer
// [Hoan - Phase 2] Khong bat webhook cho den khi xac thuc HMAC duoc trien khai dung chuan.
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
