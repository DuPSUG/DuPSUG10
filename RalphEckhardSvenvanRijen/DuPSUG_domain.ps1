configuration DuPSUG_domain
 {
    Import-DscResource -ModuleName xActiveDirectory, `
                                   xNetworking, `
                                   xDnsServer, `
                                   xPendingReboot, `
                                   xDHCPServer, `
                                   xPSDesiredStateConfiguration

    [pscredential]$domainCred = Get-AutomationPSCredential -Name 'Local domain admin'
    [pscredential]$safemodeAdministratorCred = New-Object -TypeName System.Management.Automation.PSCredential ("(Password Only)",$domaincred.Password)

     Node $AllNodes.Where{$_.Role -eq "Primary DC"}.Nodename  
                 
    {             
            
        LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyAndAutoCorrect'            
            RebootNodeIfNeeded = $true          
        }            
            
        File ADFiles            
        {            
            DestinationPath = 'C:\NTDS'            
            Type = 'Directory'            
            Ensure = 'Present'            
        } 
        
        WindowsFeature DNS
        {
            Ensure = "Present"
            Name = "DNS"
        } 

        WindowsFeature DNS-Tools
        {
            Ensure = "Present"
            Name = "RSAT-DNS-Server"
        } 
        
        xDNSServerForwarder Forwarders
        {
            IsSingleInstance = 'Yes'            IPAddresses = '8.8.8.8', '8.8.4.4'
            DependsOn = "[WindowsFeature]DNS"         
        }

        xDNSServerAddress DNSServerAddress
        {
          InterfaceAlias = 'Ethernet'
          AddressFamily = 'IPv4'
          Address = '127.0.0.1'
          DependsOn = "[WindowsFeature]DNS"
        }
        
        WindowsFeature DHCP
        {
          Ensure = "Present"
          Name = "DHCP"
          IncludeAllSubFeature = $true
        }

        WindowsFeature DHCP-Tools
        {
          Ensure = "Present"
          Name = "RSAT-DHCP"
          IncludeAllSubFeature = $true
        }

        xDhcpServerAuthorization Authorization
        {
        DependsOn = "[WindowsFeature]DHCP"
        Ensure = "Present"
        DnsName = "DC01.dupsug.com"
        IPAddress = "10.0.1.100"
        }
        
        xDhcpServerScope Scope
        {
          DependsOn = "[xDhcpServerAuthorization]Authorization"
          Ensure = "Present"
          IPStartRange = "10.0.1.150"
          IPEndRange = "10.0.1.220"
          Name = "DefaultScope"
          SubnetMask = "255.255.255.0"
          LeaseDuration = "00:08:00"
          State = "Active"
          AddressFamily = "IPv4"
        }
        
        xDhcpServerOption Option
        {
          DependsOn = "[xDhcpServerScope]Scope"
          Ensure = "Present"
          ScopeID = "10.0.1.0"
          DnsDomain = $Node.DomainName
          DnsServerIPAddress = "10.0.1.100"
          AddressFamily = "IPv4"
          Router = "10.0.1.1"
        }        
                    
        WindowsFeature ADDSInstall             
        {             
            Ensure = "Present"             
            Name = "AD-Domain-Services"             
        }            
            
        # Optional GUI tools            
        WindowsFeature ADDSTools            
        {             
            Ensure = "Present"             
            Name = "RSAT-ADDS"             
        }            
            
        # No slash at end of folder paths            
        xADDomain FirstDS             
        {             
            DomainName = $Node.DomainName             
            DomainAdministratorCredential = $domainCred             
            SafemodeAdministratorPassword = $safemodeAdministratorCred            
            DatabasePath = 'C:\NTDS'            
            LogPath = 'C:\NTDS'            
            DependsOn = "[WindowsFeature]ADDSInstall","[File]ADFiles"            
        }            
            
    } 


     }