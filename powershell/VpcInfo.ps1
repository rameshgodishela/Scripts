#Function to display if VPC is matching ?
# parameters = It will take below parameters 
# vpcid
# cidr block
#
Function Get-VpcInfo
{
    param (
         [Parameter(Mandatory = $true)] [string] $VpcId,
         [Parameter(Mandatory = $true)] [string] $CidrBlock
       )   

$Src = Get-FoldersCreatedToShareResults
$DateNTime = Get-Date -Format "dd_MM_yyyy_HH_mm_ss";
$ResultFileForVpcInfo = "$($Src)\$VpcId_vpc_ResultFile_" + $DateNTime + ".txt"

#Check whether VpcId exists or not
if (Get-EC2Vpc -VpcId $VpcId) {
    Write-Host "`n VPC exists with $VpcId.. `n" | Out-File -Append $ResultFileForVpcInfo
}
else {
    Write-Host "`n There is no VPC exists with the given $VpcId.., Please pass valid VpcId.`n" | Out-File -Append $ResultFileForVpcInfo
}
#Check whether $CidrBlock matches with given CidrBlock
$VpcFullInfo = Get-EC2Vpc -VpcId $VpcId
$ActualCidrBlock = $VpcFullInfo.CidrBlock
if ($CidrBlock -eq $ActualCidrBlock) {
    Write-Host "`n $VpcId CidrBlock($ActualCidrBlock) match with the given CidrBlock($CidrBlock).. `n" | Out-File -Append $ResultFileForVpcInfo
}
else {
    Write-Host "`n $VpcId CidrBlock($ActualCidrBlock) does not match with the given CidrBlock($CidrBlock).. `n" | Out-File -Append $ResultFileForVpcInfo
}
# check dns hosnames are enabled or not
$enableDnsHostnamesStatus = Get-EC2VpcAttribute -VpcId $VpcId -Attribute enableDnsHostnames

if ($enableDnsHostnamesStatus.EnableDnsHostnames -eq "True") {
    Write-Host "`n DNS Hostnames are enabled for $VpcId.. `n" | Out-File -Append $ResultFileForVpcInfo
}
else {
    Write-Host "`n DNS Hostnames are not enabled for $VpcId.. `n" | Out-File -Append $ResultFileForVpcInfo
}
#check dns support enabled or not
$enableDnsSupportStatus = Get-EC2VpcAttribute -VpcId $VpcId -Attribute enableDnsSupport
if ($enableDnsSupportStatus.EnableDnsSupport -eq "True") {
    Write-Host "`n DNS support enabled for $VpcId.. `n" | Out-File -Append $ResultFileForVpcInfo
}
else {
    Write-Host "`n DNS support not enabled for $VpcId..`n" | Out-File -Append $ResultFileForVpcInfo
}
}

Get-VpcInfo 