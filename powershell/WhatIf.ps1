
Function ConvertCSVIntoHashTableForSwitchAliasFunc() {
    param(
      [string] $InputFile
    )
    $ReportArray = Get-Content $InputFile | ConvertFrom-Csv 
    $ReportHashTable = @{} 
    $ReportArray | Foreach-Object {
        $ReportHashTable[$_.AliasName] = $_.TargetKeyId
    }
    return $ReportHashTable
}

Function GetTheAliasListForSwitchAliasFunc {
    $AliasList = [System.Collections.ArrayList]@()
    try{
      $AliasNameList = (Get-KMSAliasList).AliasName
      $AliasNameList | Foreach-object {
        If ($_ -Match "([A-Z])-.*") {
            $AliasList += $_
        }
      }
    }
    catch [System.Exception] {
      Write-Error "Unable to run Get-KMSAliasList to AWS. Cannot Continue"
      exit
    }
    return $AliasList
}

Function Process_SwitchAliasFunc() {
   [CmdletBinding(SupportsShouldProcess=$True, ConfirmImpact = 'Medium')]
   param(
     [hashtable] $ReportHashTable, 
     [string[]] $AliasList
   )
   
   foreach ($ReportHashTablekey in $ReportHashTable.Keys) {
      $ReportAliasName = $ReportHashTablekey.Substring(0,$ReportHashTablekey.Length-3)
      $ReportAliasName = 'alias/' +  $ReportAliasName + "CURRENT"
      $AliasList | Foreach-Object {
   	  if ($ReportAliasName -eq $_) {

          if ($pscmdlet.ShouldProcess($_,'Update-KMSAlias')) {
          try {
	             Update-KMSAlias -TargetKeyId $ReportHashTable.Item($ReportHashTablekey) -AliasName $ReportAliasName 
	        }
          catch {
                Write-Error "Couldnot find $ReportAliasName to switch to new key."
                continue
          }
          finally{
          $line = New-object -TypeName psobject -Property (@{'AliasName' = $ReportAliasName; 'TargetKeyId' = $ReportHashTable.Item($ReportHashTablekey)})
          $result += $line
          }
      }
      } 
	  }
    }
    return $result 
}

Function Main() {

param(
    [string] $InputFile
)

$TestHashTable = ConvertCSVIntoHashTableForSwitchAliasFunc $InputFile
$TestArray = GetTheAliasListForSwitchAliasFunc
Process_SwitchAliasFunc $TestHashTable $TestArray -WhatIf

}
Main report.csv

