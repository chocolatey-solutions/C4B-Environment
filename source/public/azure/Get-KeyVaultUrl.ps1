function Get-KeyVaultUrl {
    <#
        .Synopsis
            In times where the task has been created, it would be good to be able to get a KeyVault URL on the system.
    #>
    [CmdletBinding()]
    param()

    if ((Get-ScheduledTask -TaskName UpdateCertificateFromKeyVault).Actions.Arguments -match '-KeyVaultUrl (?<KeyVaultUrl>.+)') {
        $Matches.KeyVaultUrl.Trim()
    }
}