[CmdletBinding()]
param(
	[int]$Port = 17891,
	[Parameter(Mandatory = $true)][string]$ReadyPath,
	[Parameter(Mandatory = $true)][string]$LogPath,
	[Parameter(Mandatory = $true)][string]$FailurePath
)

$ErrorActionPreference = 'Stop'
$Listener = New-Object System.Net.HttpListener
$Prefix = "http://127.0.0.1:$Port/"
try {
	$Listener.Prefixes.Add($Prefix)
	$Listener.Start()
	[IO.File]::WriteAllText($ReadyPath, (ConvertTo-Json -Compress @{ pid = $PID; port = $Port; prefix = $Prefix }), (New-Object Text.UTF8Encoding($false)))
}
catch {
	[IO.File]::WriteAllText($FailurePath, $_.Exception.ToString(), (New-Object Text.UTF8Encoding($false)))
	exit 2
}

$SeenRequests = @{}
$SeenRefunds = @{}
$Utf8 = New-Object Text.UTF8Encoding($false)
while ($Listener.IsListening) {
	$Context = $null
	try { $Context = $Listener.GetContext() }
	catch { break }
	try {
		$Response = $Context.Response
		$Response.ContentType = 'application/json; charset=utf-8'
		$Response.KeepAlive = $false
		$StatusCode = 200
		if ($Context.Request.HttpMethod -eq 'GET' -and $Context.Request.Url.AbsolutePath -eq '/health') {
			$ResponseText = '{"status":"READY"}'
		}
		elseif ($Context.Request.HttpMethod -eq 'POST' -and $Context.Request.Url.AbsolutePath -eq '/v1/payments') {
			$Reader = New-Object IO.StreamReader($Context.Request.InputStream, [Text.Encoding]::UTF8)
			try { $RequestText = $Reader.ReadToEnd() } finally { $Reader.Dispose() }
			$Payload = $RequestText | ConvertFrom-Json
			$RequestId = [string]$Context.Request.Headers['Idempotency-Key']
			$ClientReference = [string]$Payload.clientReference
			if ($ClientReference -eq 'E2E-BANK-REJECT') {
				$StatusCode = 422
				$ResponseText = '{"status":"REJECTED","transactionId":""}'
				$BankStatus = 'REJECTED'
				$TransactionId = ''
				$Replay = $false
			}
			elseif ($SeenRequests.ContainsKey($RequestId)) {
				$TransactionId = $SeenRequests[$RequestId]
				$ResponseText = ConvertTo-Json -Compress @{ status = 'ACCEPTED'; transactionId = $TransactionId }
				$BankStatus = 'ACCEPTED'
				$Replay = $true
			}
			else {
				$Bytes = [Text.Encoding]::UTF8.GetBytes($RequestId)
				$Hash = [BitConverter]::ToString(([Security.Cryptography.SHA256]::Create()).ComputeHash($Bytes)).Replace('-', '')
				$TransactionId = 'BANK-' + $Hash.Substring(0, 20)
				$SeenRequests[$RequestId] = $TransactionId
				$ResponseText = ConvertTo-Json -Compress @{ status = 'ACCEPTED'; transactionId = $TransactionId }
				$BankStatus = 'ACCEPTED'
				$Replay = $false
			}
			$Record = [ordered]@{
				request_id = $RequestId
				client_reference = $ClientReference
				status = $BankStatus
				transaction_id = $TransactionId
				replay = $Replay
				amount_vnd = $Payload.amountVnd
				amount_foreign = $Payload.amountForeign
				currency = $Payload.currency
			}
			[IO.File]::AppendAllText($LogPath, ((ConvertTo-Json -Compress -Depth 5 $Record) + [Environment]::NewLine), $Utf8)
		}
		elseif ($Context.Request.HttpMethod -eq 'POST' -and $Context.Request.Url.AbsolutePath -eq '/v1/refunds/confirm') {
			$Reader = New-Object IO.StreamReader($Context.Request.InputStream, [Text.Encoding]::UTF8)
			try { $RequestText = $Reader.ReadToEnd() } finally { $Reader.Dispose() }
			$Payload = $RequestText | ConvertFrom-Json
			$RequestId = [string]$Context.Request.Headers['Idempotency-Key']
			$RefundReference = [string]$Payload.refundReference
			$SourcePaymentReference = [string]$Payload.sourcePaymentReference
			$SourceBankTransactionId = [string]$Payload.sourceBankTransactionId
			if ([string]::IsNullOrWhiteSpace($RequestId) -or [string]::IsNullOrWhiteSpace($SourceBankTransactionId)) {
				$StatusCode = 422
				$ResponseText = '{"status":"REJECTED","transactionId":""}'
				$BankStatus = 'REJECTED'
				$TransactionId = ''
				$Replay = $false
			}
			elseif ($SeenRefunds.ContainsKey($RequestId)) {
				$TransactionId = $SeenRefunds[$RequestId]
				$ResponseText = ConvertTo-Json -Compress @{ status = 'REFUND_RECEIVED'; transactionId = $TransactionId }
				$BankStatus = 'REFUND_RECEIVED'
				$Replay = $true
			}
			else {
				$Bytes = [Text.Encoding]::UTF8.GetBytes($RequestId + ':' + $SourceBankTransactionId)
				$Hash = [BitConverter]::ToString(([Security.Cryptography.SHA256]::Create()).ComputeHash($Bytes)).Replace('-', '')
				$TransactionId = 'REFUND-' + $Hash.Substring(0, 20)
				$SeenRefunds[$RequestId] = $TransactionId
				$ResponseText = ConvertTo-Json -Compress @{ status = 'REFUND_RECEIVED'; transactionId = $TransactionId }
				$BankStatus = 'REFUND_RECEIVED'
				$Replay = $false
			}
			$Record = [ordered]@{
				request_id = $RequestId
				operation = 'refund_receipt_confirmation'
				refund_reference = $RefundReference
				source_payment_reference = $SourcePaymentReference
				source_bank_transaction_id = $SourceBankTransactionId
				status = $BankStatus
				transaction_id = $TransactionId
				replay = $Replay
				amount_vnd = $Payload.amountVnd
				amount_foreign = $Payload.amountForeign
				currency = $Payload.currency
			}
			[IO.File]::AppendAllText($LogPath, ((ConvertTo-Json -Compress -Depth 5 $Record) + [Environment]::NewLine), $Utf8)
		}
		else {
			$StatusCode = 404
			$ResponseText = '{"status":"NOT_FOUND"}'
		}
		$Response.StatusCode = $StatusCode
		$ResponseBytes = [Text.Encoding]::UTF8.GetBytes($ResponseText)
		$Response.ContentLength64 = $ResponseBytes.Length
		$Response.OutputStream.Write($ResponseBytes, 0, $ResponseBytes.Length)
	}
	catch {
		try { [IO.File]::AppendAllText($FailurePath, ($_.Exception.ToString() + [Environment]::NewLine), $Utf8) } catch { }
	}
	finally {
		if ($Context -and $Context.Response) { try { $Context.Response.Close() } catch { } }
	}
}

try { $Listener.Stop() } catch { }
try { $Listener.Close() } catch { }
