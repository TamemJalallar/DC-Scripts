Import-Module ActiveDirectory

function GetUserDetails {
    param (
        [string]$emailAddress
    )
    $user = Get-ADUser -Filter {emailAddress -eq $emailAddress} -Properties lastLogon, userAccountControl

    if($user) {
        $lastLogonDate = [datetime]::FromFileTime($user.lastLogon)
        $accountStatus = if ($user.userAccountControl -band 2) {'Inactive'} else {'Active'}

    Write-Host "User: $($user.Name)"
    Write-Host "Last Log On Date: $lastLogonDate"
    Write-Host "Account Status: $accountStatus"
    } else {
        Write-Host "User not found"
    }
}

$email = Read-Host -Prompt "Enter User's E-Mail Address"
GetUserDetails -emailAddress $email
