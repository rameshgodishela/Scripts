#Function to display if VPC is matching ?
# parameters = It will take below parameters 
# vpcid
# cidr block
#
Function Get-VpcInfo
{
    param (
         [Parameter(Mandatory = $true)] [string] $VpcServiceName,
         [Parameter(Mandatory = $true)] [string] $VpcId,
         [Parameter(Mandatory = $true)] [string] $PrivateSubnetNum,
         [Parameter(Mandatory = $true)] [string] $RouteTableOfPrivateSubnetNum
       )   
write-output "The VPC Id is $VpcId"
write-output "The Cidr Block is $CidrBlock"
write-output "The End Point Service Name is $VpcEndPointServiceName"
#Check whether VpcId exists or not
if (Get-EC2Vpc -VpcId $VpcId) {
    Write-Host "VPC exists with $VpcId.."
}
else {
    Write-Host "There is no VPC exists with the given $VpcId.., Please pass valid VpcId."
}
#Check whether $CidrBlock matches with given CidrBlock
$VpcFullInfo = Get-EC2Vpc -VpcId $VpcId
$ActualCidrBlock = $VpcFullInfo.CidrBlock
if ($CidrBlock -eq $ActualCidrBlock) {
    Write-Host "$VpcId CidrBlock($ActualCidrBlock) match with the given CidrBlock($CidrBlock).."
}
else {
    Write-Host "$VpcId CidrBlock($ActualCidrBlock) does not match with the given CidrBlock($CidrBlock).."
}
# check dns hosnames are enabled or not
$enableDnsHostnamesStatus = Get-EC2VpcAttribute -VpcId $VpcId -Attribute enableDnsHostnames

if ($enableDnsHostnamesStatus.EnableDnsHostnames -eq "True") {
    Write-Host "DNS Hostnames are enabled for $VpcId.."
}
else {
    Write-Host "DNS Hostnames are not enabled for $VpcId.."
}
#check dns support enabled or not
$enableDnsSupportStatus = Get-EC2VpcAttribute -VpcId $VpcId -Attribute enableDnsSupport
if ($enableDnsSupportStatus.EnableDnsSupport -eq "True") {
    Write-Host "DNS support enabled for $VpcId.."
}
else {
    Write-Host "DNS support not enabled for $VpcId.."
}
# Check whether the service name matches with actual service name
$ActualEndPointServiceName = Get-EC2VpcEndpointService
if ($VpcEndPointServiceName -eq $ActualEndPointServiceName) {
    Write-Host "$VpcId vpc end point service name($VpcEndPointServiceName) macthes with actual endpoint service name($ActualEndPointServiceName).."
}
else {
    Write-Host "$VpcId vpc end point service name($VpcEndPointServiceName) does not match with actual endpoint service name($ActualEndPointServiceName).."
}

#Verify how many private subnets are in the given VpcId

#List of private subnet route tables
#Log_group_name
#iam_role_arn
}

Get-VpcInfo 