function Set-ServiceStartupType {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateSet('Automatic', 'Manual', 'Disabled', 'AutomaticDelayedStart')]
        [string]$StartupType
    )

    process {
        try {
            Write-Verbose "Configuring service '$Name' to startup type '$StartupType'..."

            # Special handling for Delayed Start in PowerShell v5.1
            if ($StartupType -eq 'AutomaticDelayedStart') {
                # 1. Set the service to Automatic first
                Set-Service -Name $Name -StartupType Automatic -ErrorAction Stop

                # 2. Modify the registry key to enable DelayedAutostart (Required for PS v5.1)
                $RegistryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$Name"
                Set-ItemProperty -Path $RegistryPath -Name "DelayedAutostart" -Value 1 -ErrorAction Stop
            } else {
                # Standard types natively supported by Set-Service in PS v5.1
                Set-Service -Name $Name -StartupType $StartupType -ErrorAction Stop

                # Clean up the registry flag if it was previously set to delayed start
                $RegistryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$Name"
                if (Test-Path $RegistryPath) {
                    $Properties = Get-ItemProperty -Path $RegistryPath
                    if ($Properties.DelayedAutostart -eq 1) {
                        Set-ItemProperty -Path $RegistryPath -Name "DelayedAutostart" -Value 0 -ErrorAction SilentlyContinue
                    }
                }
            }

            Write-Host "Successfully updated '$Name' to '$StartupType'." -ForegroundColor Green
        } catch {
            Write-Error "Failed to update service '$Name'. Error: $_"
        }
    }
}
