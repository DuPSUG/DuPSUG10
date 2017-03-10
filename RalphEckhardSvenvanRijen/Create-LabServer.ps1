#region define variables
# User defined variables that varies per server
$VMName = 'DEMO-SRV01'
$VMIP = '172.16.10.201/24'
$DNSIP = '8.8.8.8'
$GWIP = '172.16.10.1'

# Script Variables that don't vary
$diskpath = "C:\lab\$VMName.vhdx"
$ParentDisk = 'c:\lab\BASE\Server2016Base.vhdx'
$VMSwitch = 'RE-Lab'
$SourceXML = 'c:\lab\Scripts\Lab VM\unattend.xml'
#endregion

#region create diff disk
# Create a new differencing disk
New-VHD -ParentPath $ParentDisk -Path $diskpath -Differencing
#endregion

#region import and adjust the answer file and copy this to the new disk
# mount VHD
$VHD = (Mount-VHD -Path $diskpath -Passthru |
  Get-Disk |
  Get-Partition |
  Where-Object -FilterScript {
    $_.Type -eq 'Basic' 
}).DriveLetter
# add XML Content
[xml]$Unattend = Get-Content $SourceXML
$Unattend.unattend.settings[1].component[2].ComputerName = $VMName
$Unattend.unattend.settings[1].component[3].Interfaces.Interface.UnicastIpAddresses.IpAddress.'#text' = $VMIP
$Unattend.unattend.settings[1].component[3].Interfaces.Interface.Routes.Route.NextHopAddress = $GWIP
$Unattend.unattend.settings[1].component[4].Interfaces.Interface.DNSServerSearchOrder.IpAddress.'#Text' = $DNSIP
$Unattend.Save("${VHD}:\\Unattend.xml")
# dismount VHD
Dismount-VHD $diskpath
#endregion

#region create the new vm
# Create VM with new VHD
New-VM -Name $VMName -MemoryStartupBytes 2048MB -SwitchName $VMSwitch -VHDPath $diskpath -Generation 2 -BootDevice VHD
#endregion

#region start new vm and connect to console
# Start VM
Start-VM $VMName
Start-Process vmconnect -ArgumentList localhost,$VMName
#endregion