param(
  [string]$Env
)

function CreateNewDefaultPolicyForEnv($Env) {
   $RoleNames = @{}
   $RoleNames.Add("D", "D-U-AWS26-CRYPTO-DEVELOPERS")
   $RoleNames.Add("N", "D-U-AWS33-ESSACRYPTO")
   $RoleNames.Add("P", "P-U-AWS34-ESSACRYPTO")

   $AccountID = (Get-STSCallerIdentity).Account
   $RootARN = "arn:aws:iam::" + $AccountID + ":root"

  If ($Env -eq "D") {
     $RoleName = $RoleNames.Get_Item("$Env")
     $ReplacableValueInPolicy = "arn:aws:iam::" + $AccountID + ":role/" + $RoleName
  }
  ElseIf ($Env -eq "N"){
     $RoleName = $RoleNames.Get_Item("$Env")
     $ReplacableValueInPolicy = "arn:aws:iam::" + $AccountID + ":role/" + $RoleName
  }
  ElseIf ($Env -eq "P"){
     $RoleName = $RoleNames.Get_Item("$Env")
	   $ReplacableValueInPolicy = "arn:aws:iam::" + $AccountID + ":role/" + $RoleName
  }
  Else {
    	Write-Output "We are supporting D(Dev), N(Non-Prod) and P(Prod) environments only"
	    Exit
  }

   $KeyPolicyString = Get-Content .\default-view.json | convertfrom-json
   Get-Content .\default-view.json | Out-File .\DefaultKeyPolicyContent.json

   $ChangableValuesInPolicy = [System.Collections.ArrayList]@()
   $KeyPolicyString.Statement.Principal.AWS | foreach {
     $ChangableValuesInPolicy += $_
   }
   $ChangableValuesInPolicy | foreach {
     If ($_ -match "arn:aws:iam::.*:root") {
        (Get-Content .\DefaultKeyPolicyContent.json).Replace($_ , $RootARN) | Out-File .\DefaultKeyPolicyContent.json 
     }
     Else {
         (Get-Content .\DefaultKeyPolicyContent.json).Replace($_ , $ReplacableValueInPolicy) | Out-File .\DefaultKeyPolicyContent.json 
     }
      
   }
   
   Write-Output "Success"
}
CreateNewDefaultPolicyForEnv($Env)