#-------------------------------------------------------------------------#
#-----------------------Editable variables------------------------------#

#Replace Variables with your vcenter information

$vcenter = "vcenter.domain.com"
$dcenter = "DatacenterName"
$Cluster = "ClusterName"

#StartTranscript
Start-Transcript Set-Perennial$dcenter.log

#-------------------------------------------------------------------------#
#-------------------------Do Not Edit Below-------------------------------#

function Set-PerennialReservation
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()

    Process
    {
        $connected = Connect-VIServer -Server $vcenter | Out-Null

        #Creates List of NAAs
        $clusterInfo = Get-Datacenter -Name $dcenter | get-cluster $cluster
        $vmHosts = $clusterInfo | get-vmhost | select -ExpandProperty Name
        $RDMNAAs = $clusterInfo | Get-VM | Get-HardDisk -DiskType "RawPhysical","RawVirtual" | Select -ExpandProperty ScsiCanonicalName -Unique


        foreach ($EsxiHost in $vmHosts)
        {
            echo "Setting Perennial Reservation on $EsxiHost"
            #Store Vcenter hosts
            $esxcli = Get-EsxCli -VMHost $EsxiHost
            #Applies Perennial property on each NAA 
            foreach ($naa in $RDMNAAs) {$esxcli.storage.core.device.setconfig($false, $naa, $true)}
        }
        #Disconnect from VCenter Server
        Disconnect-VIServer $vcenter -confirm:$false | Out-Null
   }
}

#Execution
Set-PerennialReservation

#End Transcript
Stop-Transcript
