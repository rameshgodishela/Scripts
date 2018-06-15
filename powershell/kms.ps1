#Build AliasList
$AliasList = Get-KMSAliasList | Where-Object {$_.AliasName -match 'alias/[SNP]-AWS-\d{4}-\d{3}'}

#Build KeysList which are created within last 30 days
$Limit = (Get-Date).AddDays(-30)
(Get-KMSKeys).KeyId | ForEach-Object {
     $KeyList = Get-KMSKey -KeyId $_ | Where-Object { $_.CreationDate -gt $Limit }
 }

#Compare the list
Foreach ($Alias in $AliasList) {
   If ($Alias).keyid -in ($KeyList).keyid {
	   $Polciy = Get-KMSPolicy -KeyId ($Alias).keyid -PolicyName "default"
       $PolicyObj = $Policy | Out-String | ConvertFrom-Json
       $PolicyARN = ($PolicyObj.Statement | where {$_.Sid -eq "Allow use of the key"}).Principal.AWS
       $ARN = @()
       $ARN += $PolicyARN
       $ARN | ForEach-Object {
           If ($TestAccount -contains $_)
           {
             
                      }   
       }
       If $Polciy has NO external permission {
            Add Alias to Array newkeys
        else
            write-error "placeholder key is already permissioned to account"
        }
    }
    #Build NewKeys array
    return NewKeys	
}

#foreach($alias in $AliasList){
     #if($alias.TargetKeyId -in $Keylist.KeyId){
      # $policy = Get-KMSKeyPolicy -KeyId $alias.TargetKeyId -PolicyName "default"
       #$obj = Get-Content .\ExampleKeyPolicy.json| out-string | ConvertFrom-Json
      # $obj
       #$obj.Statement
      
      #$ParseARN = ($obj.Statement | where {$_.Sid -eq "Allow use of the key"}).Principal.AWS
     #}
#}