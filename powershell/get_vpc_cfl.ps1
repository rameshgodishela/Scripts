
Function Get-VpcFlowLogInfo
{
    param (
         [Parameter(Mandatory = $true)] [string] $VpcId,
         [Parameter(Mandatory = $true)] [string] $IamRoleArn,
         [Parameter(Mandatory = $true)] [string] $LogGroupName
       )   
$Src = Get-FoldersCreatedToShareResults
$DateNTime = Get-Date -Format "dd_MM_yyyy_HH_mm_ss";
$ResultFileForVpcFlowlogInfo = "$($Src)\$VpcId_vpcflowlog_ResultFile_" + $DateNTime + ".txt"
#Check whether VpcId exists or not
if (Get-EC2Vpc -VpcId $VpcId) {
    Write-Host "`n VPC exists with $VpcId.. `n" | Out-File -Append $ResultFileForVpcFlowlogInfo
}
else {
    Write-Host "`n There is no VPC exists with the given $VpcId.., Please pass valid VpcId.`n" | Out-File -Append $ResultFileForVpcFlowlogInfo
}
$Ec2FlowLog = Get-EC2FlowLog
$ActualLogGroupName = $Ec2FlowLog.LogGroupName
if ($LogGroupName -eq $ActualLogGroupName) {
    Write-Host "`n  Log group name ($LogGroupName) matches with the given Log group name ($ActualLogGroupName)..`n" | Out-File -Append $ResultFileForVpcFlowlogInfo
}
else {
    Write-Host "`n  Log group name ($LogGroupName) does not match with the given Log group name ($ActualLogGroupName)..`n" | Out-File -Append $ResultFileForVpcFlowlogInfo
}
$IamRole = Get-IAMRole -RoleName $rolename 
$ActualIamRoleArn = $IamRole.Arn 
if ($IamRoleArn -eq $ActualIamRoleArn) {
    Write-Host "`n  Iam role arn  ($IamRoleArn) matches with the given Iam role arn ($ActualIamRoleArn)..`n" | Out-File -Append $ResultFileForVpcFlowlogInfo
}
else {
    Write-Host "`n  Iam role arn ($IamRoleArn) does not match with the given Iam role arn ($IamRoleArn)..`n" | Out-File -Append $ResultFileForVpcFlowlogInfo
}

Get-VpcFlowLogInfo 