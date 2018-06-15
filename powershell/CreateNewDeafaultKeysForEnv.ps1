
param(
  [string]$Env,
  [string]$KeyID
)

function CreateNewDeafaultKeysForEnv() {
    
  #Creating Hash Table 
   $RoleNames = @{}
   $RoleNames.Add("D", "D-U-AWS26-CRYPTO-DEVELOPERS")
   $RoleNames.Add("N", "D-U-AWS33-ESSACRYPTO")
   $RoleNames.Add("P", "P-U-AWS34-ESSACRYPTO")
   write-output @RoleNames


  #Get the kms key policy
   Get-KMSKeyPolicy -KeyId $KeyID -PolicyName default | Out-File DefaultKeyPolicyContent.json
   $KeyPolicy = Get-KMSKeyPolicy -KeyId $KeyID -PolicyName default | convertfrom-json
   $AccountID = (Get-STSCallerIdentity).Account
   write-output $AccountID

  #Construct the value to replace with
  If ($Env -eq "D") {
     $RoleName = $RoleNames.Get_Item("$Env")
     write-output $rolename
     $ReplacableValueInPolicy = "arn:aws:iam::" + $AccountID + ":role/" + $RoleName
     write-output $ReplacableValueInPolicy
  }
  ElseIf ($Env -eq "N"){
     $RoleName = $RoleNames.Get_Item("$Env")
     write-output $rolename
     $ReplacableValueInPolicy = "arn:aws:iam::" + $AccountID + ":role/" + $RoleName
     write-output $ReplacableValueInPolicy
  }
  ElseIf ($Env -eq "P"){
     $RoleName = $RoleNames.Get_Item("$Env")
     write-output $rolename
	 $ReplacableValueInPolicy = "arn:aws:iam::" + $AccountID + ":role/" + $RoleName
	 write-output $ReplacableValueInPolicy
  }
  Else {
    	Write-Output "We are supporting D(Dev), N(Non-Prod) and P(Prod) environments only"
	    Exit
  }

  #Construct the value to change from
   $ChangableValuesInPolicy = @()
   $ChangableValuesInPolicy = $KeyPolicy.Statement.Principal.AWS
   write-output $ChangableValuesInPolicy
   $ChangableValuesInPolicy | foreach {
    (Get-Content .\DefaultKeyPolicyContent.json ).Replace('$_','ReplacableValueInPolicy') | Out-File .\DefaultKeyPolicyContent.json
   }

  #Write Key policy
   Write-KMSKeyPolicy -KeyId $KeyID -Policy $KeyPolicy -PolicyName default
}
CreateNewDeafaultKeysForEnv
