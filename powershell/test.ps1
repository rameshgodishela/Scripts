param(
  [string]$Env
)

function CreateNewDefaultPolicyForEnv($Env) {
   $RoleNames = @{}
   $RoleNames.Add("S", "D-U-AWS26-CRYPTO-DEVELOPERS")
   $RoleNames.Add("N", "D-U-AWS33-ESSACRYPTO")
   $RoleNames.Add("P", "P-U-AWS34-ESSACRYPTO")

   $AccountID = (Get-STSCallerIdentity).Account
   $RootARN = "arn:aws:iam::" + $AccountID + ":root"
   

  If ($Env -eq "S") {
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
    	Write-Output "We are supporting S(Sandbox), N(Non-Prod) and P(Prod) environments only"
	    Exit
  }

   $KeyPolicyString = Get-Content .\default-view.json | convertfrom-json
   #Get-Content .\default-view.json | Out-File .\DefaultKeyPolicyContent.json
   $KeyPolicy = Get-Content .\default-view.json 

   $ChangableValuesInPolicy = [System.Collections.ArrayList]@()
   $KeyPolicyString.Statement.Principal.AWS | foreach {
     $ChangableValuesInPolicy += $_
   }
   $ChangableValuesInPolicy | foreach {
     If ($_ -match "arn:aws:iam::.*:root") {
        #(Get-Content .\DefaultKeyPolicyContent.json).Replace($_ , $RootARN) | Out-File .\DefaultKeyPolicyContent.json 
       $KeyPolicy =  ($KeyPolicy).Replace($_ , $RootARN)
       
     }
     Else {

         #(Get-Content .\DefaultKeyPolicyContent.json).Replace($_ , $ReplacableValueInPolicy) | Out-File .\DefaultKeyPolicyContent.json
       $KeyPolicy =  ($KeyPolicy).Replace($_ , $ReplacableValueInPolicy)
     }
       
       
     
      
   }
   
   #Write-KMSKeyPolicy -KeyId $KeyId -Policy .\DefaultKeyPolicyContent.json -PolicyName default
   Write-Output $KeyPolicy
   #Write-Output $X
   Write-Output "Success"
}
CreateNewDefaultPolicyForEnv($Env)