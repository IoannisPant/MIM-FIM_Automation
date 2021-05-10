# Written by Ioannis Pantelidis

# Current path location
$here = Get-Location

# Load all users
$Users = Import-csv $here"\Users.csv"

function WriteLog
{
    Param ([string]$LogString)
	$LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
    $DateTime = "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
	$LogFile = "$($here)\Logs\$(gc env:computername)_$($LogTime).log"
    $LogMessage = "$Datetime $LogString"
    Add-content $LogFile -value $LogMessage
}

Write-Host "Trying to connect, please wait..."
$testConnection = Test-Connection <IP of FIM Server>

If (($testConnection -ne "") -or ($testconnection -ne $null)){
    Write-Host "Connection Established ! "
	
		# Enter your luiss credential
		$credential = Get-Credential
		
		# Open remote session 
		$s = New-PSSession -ComputerName <IP of FIM Server> -Credential $credential 
		Write-Host "In progress...Please wait."
		
		# Execute the script
		$script = Invoke-Command -Session $s -filepath $here"\process.ps1" -ArgumentList $Users
		echo $script
		WriteLog($script)
		
		# Exit remote session
		Remove-PSSession -Session $s
}
Else{
    Write-Host "Connection Failed. Be sure that you're using VPN." 
}





