Function Do-Stuff{
[CmdletBinding(SupportsShouldProcess=$true)]
    param([string[]]$Objects)
ForEach($item in $Objects){
        if ($pscmdlet.ShouldProcess("$item", "DoStuff")){
            write-output "Actually performing `$Action on $item"
            }
 }
 }