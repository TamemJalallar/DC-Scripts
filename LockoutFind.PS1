Import-Module ActiveDirectory

function Get-LockoutLocation {
    param(
        [string]$UserName
    )
    $DomainControllers = Get-ADDomainController -Filter *
    foreach ($DC in $DomainControllers) {
        $UserInfo = Get-ADUser -Identity $UserName -Server $DC.HostName -Properties LockedOut
        if ($UserInfo.LockedOut) {
            Write-Output "Account is locked out on $($DC.HostName)."
            Search-LockoutEvents -UserName $UserName -DomainController $DC.HostName
            Check-Services -UserName $UserName -ComputerName $DC.HostName
        } else {
            Write-Output "Account is not locked out on $($DC.HostName)."
        }
    }
}

function Search-LockoutEvents {
    param(
        [string]$UserName,
        [string]$DomainController
    )
    $EventID = 4740
    Get-WinEvent -LogName "Security" -ComputerName $DomainController | 
        Where-Object { $_.Id -eq $EventID -and $_.Properties[0].Value -eq $UserName } |
        ForEach-Object {
            $Event = $_
            $EventTime = $Event.TimeCreated
            $ClientName = $Event.Properties[1].Value
            Write-Output "Lockout on $DomainController at $EventTime from $ClientName."
        }
}

function Check-Services {
    param(
        [string]$UserName,
        [string]$ComputerName
    )
    Get-WmiObject Win32_Service -ComputerName $ComputerName | 
        Where-Object { $_.StartName -eq $UserName } |
        Select-Object Name, StartName, State |
        ForEach-Object {
            Write-Output "Service $($_.Name) running under $UserName on $ComputerName is in state $($_.State)."
        }
}

# Gather username from user input
$Username = Read-Host "Please enter the username to check for lockout status"
Get-LockoutLocation -UserName $Username
