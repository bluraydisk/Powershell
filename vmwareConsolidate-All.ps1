Write-Host -ForegroundColor Green ("Reading VMs needed to be consolidated. . .")
$ConsVM=get-view -ViewType VirtualMachine | ?{$_.Runtime.ConsolidationNeeded} | Get-VIObjectByVIView

$RestartedHosts=@()

ForEach ($VM in $ConsVM) {
        Write-Host -ForegroundColor Green ("Starting Consolidation of {0} on host {1}. . ." -f $VM.Name,$VM.VMHost.Name )
	if ( $RestartedHosts -notcontains $VM.VMHost.Name ) {
		$RestartedHosts+=$VM.VMHost.Name
		Write-Host -ForegroundColor Green ("Host VPXA service not yet restarted. Restarting. . .")
		$VM.VMHost | Get-VMHostService | ?{ $_.Key -eq "vpxa" } | Restart-VmHostService -confirm:$False -ErrorAction:SilentlyContinue
		Start-sleep 10
		Write-Host -ForegroundColor Green -NoNewLine ("Waiting for service to be up.")
		While ( -not ((Get-VMHost -Name $VM.VMHost.Name ).Connectionstate -eq "Connected") ) {
			Start-Sleep 1
			Write-Host -ForegroundColor Green -NoNewLine (" .")
		}
		Write-Host -ForegroundColor Green ("Up.")
		Start-Sleep 5		
	}
	Write-Host -ForegroundColor Green ("Doing Consolidation of {0}" -f $VM.Name)
	$VM.ExtensionData.ConsolidateVMDisks()
}