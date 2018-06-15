function SwitchAliastoNewKey(
    [CmdLetBinding(SupportsShouldProcess=$True)]
    [Parameter(Mandatory=$true)]
    [Parameter(ValueFromPipelineByPropertyName)][String]$InputFile)
    {
      $result = @()
      $ReportArray = Get-Content $InputFile | ConvertFrom-Csv 
      $Reporthash = @{} 
      $ReportArray | Foreach-Object {
      $Reporthash[$_.AliasName] = $_.TargetKeyId
      }
      try{
        $AliasNameList = (Get-KMSAliasList).AliasName
      }
      catch [System.Exception] {
        Write-Error "Unable to run Get-KMSAliasList to AWS. Cannot Continue"
        exit
      }

      foreach ($Reporthashkey in $Reporthash.Keys) 
      {
        $ReportAliasName = $Reporthashkey.Substring(0,$Reporthashkey.Length-3)
        $ReportAliasName = 'alias/' +  $ReportAliasName + "CURRENT"
	      $AliasNameList | Foreach-object {
          if ($ReportAliasName -eq $_) {
            try {
                if ($PSCmdlet.ShouldProcess($InputFile)) {
                  Write-Output "WhatIf: $Reporthashkey targetkeyid value will assigned to $ReportAliasName targetkeyid."
                  exit
                }
                else {
                  Update-KMSAlias -TargetKeyId $Reporthash.Item($Reporthashkey) -AliasName $ReportAliasName
                  $line = New-object -TypeName psobject -Property (@{'AliasName' = $ReportAliasName; 'TargetKeyId' = $Reporthash.Item($Reporthashkey)})
                  $result += $line
                }
            }       
            catch {
              Write-Error "Couldnot find $ReportAliasName to switch to new key."
              continue
            }
          }
        }
      }  
Write-Output $result
}
Param(
  [string]$InputFile
)
SwitchAliastoNewKey -InputFile $InputFile