SELECT
	Movement.PhapNhan AS PhapNhan,
	Movement.DoiTac AS DoiTac,
	Movement.HopDong AS HopDong,
	Movement.ChungTuGoc AS ChungTuGoc,
	Movement.Recorder AS ChungTuPhatSinh,
	Movement.Period AS NgayChungTu,
	Movement.Recorder.Number AS SoChungTu,
	Movement.Recorder.Presentation AS LoaiChungTu,
	Movement.Recorder.DienGiai AS DienGiai,
	ISNULL(APInvoice.TienTe, ISNULL(Payment.TienTe, VND.Ref)) AS TienTe,
	Opening.SoTienBalance AS SoDuDauKy,
	CASE WHEN Movement.RecordType = VALUE(AccumulationRecordType.Receipt) THEN Movement.SoTien ELSE 0 END AS PhatSinhTang,
	CASE WHEN Movement.RecordType = VALUE(AccumulationRecordType.Expense) THEN Movement.SoTien ELSE 0 END AS PhatSinhGiam,
	CASE WHEN Movement.RecordType = VALUE(AccumulationRecordType.Receipt) THEN Movement.SoTien ELSE -Movement.SoTien END AS SoTienBienDong,
	Closing.SoTienBalance AS SoDuCuoiKy,
	Movement.SoTien AS SoTien
FROM
	AccumulationRegister.CongNoPhaiTra AS Movement
	LEFT JOIN AccumulationRegister.CongNoPhaiTra.Balance(&NgayBatDau, ) AS Opening
	ON Opening.PhapNhan = Movement.PhapNhan
		AND Opening.DoiTac = Movement.DoiTac
		AND Opening.HopDong = Movement.HopDong
		AND Opening.ChungTuGoc = Movement.ChungTuGoc
	LEFT JOIN AccumulationRegister.CongNoPhaiTra.Balance(DATEADD(&NgayKetThuc, DAY, 1), ) AS Closing
	ON Closing.PhapNhan = Movement.PhapNhan
		AND Closing.DoiTac = Movement.DoiTac
		AND Closing.HopDong = Movement.HopDong
		AND Closing.ChungTuGoc = Movement.ChungTuGoc
	LEFT JOIN Document.HoaDonNhaCungCap AS APInvoice ON APInvoice.Ref = Movement.ChungTuGoc
	LEFT JOIN Document.UyNhiemChi AS Payment ON Payment.Ref = Movement.ChungTuGoc
	LEFT JOIN Catalog.TienTe AS VND ON VND.Code = "VND"
WHERE
	Movement.Active = TRUE
	AND Movement.Period >= &NgayBatDau
	AND Movement.Period < DATEADD(&NgayKetThuc, DAY, 1)
