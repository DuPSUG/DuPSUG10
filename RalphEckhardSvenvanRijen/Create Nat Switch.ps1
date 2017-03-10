# create a new 'internal' vSwitch
New-VMSwitch -SwitchName 'RE-Lab' -SwitchType Internal
# find the interface index for the new interface
Get-NetAdapter 'vEthernet (RE-Lab)'
# Add an IP-address to the new interface
$adapter = get-netadapter 'vEthernet (RE-Lab)'
New-NetIPAddress -IPAddress 172.16.10.1 -PrefixLength 24 -InterfaceIndex $adapter.ifIndex
# Configure NAT with the new IP-address
New-NetNat -Name Lab_Nat -InternalIPInterfaceAddressPrefix 172.16.10.0/24
#region inbound traffic
# add static mapping
Add-NetNatStaticMapping -NatName RE-Lab -ExternalIPAddress 0.0.0.0 -ExternalPort 5001 -InternalIPAddress 172.16.0.251 -InternalPort 3389 -Protocol TCP
# Open firewall on host server
New-NetFirewallRule -Name TCP5001 -Protocol TCP -LocalPort 5001 -Action Allow -Enabled True
#endregion 