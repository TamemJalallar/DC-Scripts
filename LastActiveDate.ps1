Import-Module ActiveDirectory

function Get-UserLastLogon {
    param(
        [string]$username
    )
    $domainControllers = Get-ADDomainController -Filter *
    $lastLogon = 0
    $lastDC = ""

    foreach ($dc in $domainControllers) {
        $user = Get-ADUser -Identity $username -Properties lastLogon -Server $dc.HostName
        if ($user.LastLogon -gt $lastLogon) {
            $lastLogon = $user.LastLogon
            $lastDC = $dc.HostName
        }
    }

    $lastLogonDate = [datetime]::FromFileTime($lastLogon)

    if ($user.Enabled -eq $true) {
        $status = "Active"
    } else {
        $status = "Inactive"
    }

    Write-Output "User '$username' is $status. Last logon was on $lastLogonDate on $lastDC."
}

$username = Read-Host "Please enter the username to check"
Get-UserLastLogon -username $username
