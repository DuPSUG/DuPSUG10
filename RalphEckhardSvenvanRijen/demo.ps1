Set-Location "C:\Users\SvenvanRijen\OneDrive\DuPSUG 10"

#region Add AzureRM module

Find-Module -Name *azurerm*

Install-Module -Name AzureRM

#endregion Add AzureRM module

#region Add 'old' Azure module

Install-Module -Name Azure -AllowClobber

#endregion Add 'old' Azure module

#region login AzureRM

Login-AzureRmAccount

#endregion login AzureRM

#region define parameters

$resourcegroupname = "DuPSUG10"

$location = "West Europe"

$AutomAccountName = "DuPSUG10"

#endregion define parameters

#region Create AzureRM Resource Group

New-AzureRmResourceGroup -Name $resourcegroupname -Location $location

#endregion Create AzureRM Resource Group

#region Create AzureRM Automation Account

New-AzureRmAutomationAccount -Name $AutomAccountName `
                             -ResourceGroupName $resourcegroupname `
                             -Location $location

#endregion Create AzureRM Automation Account

#region Get AzureRM Registration Info

Get-AzureRmAutomationRegistrationInfo -ResourceGroupName $resourcegroupname `
                                      -AutomationAccountName $AutomAccountName

#endregion Get AzureRM Registration Info

#region Open & Edit meta config AzureDSCPullConfig.ps1

psEdit .\AzureDSCPullConfig.ps1

psEdit .\DuPSUGDSCPullConfig.ps1

# Save with different file name!

# Edit RegURL & RegKey

#endregion Open & Edit meta config AzureDSCPullConfig.ps1

#region Open & Edit node config TestConfig.ps1

psEdit .\TestConfig.ps1

psEdit .\DuPSUG_domain.ps1

# Save with different file name!
# Edit NodeConfig in Meta Pull Config

# Make sure DSC Resources/modules are on local workstation while editing

Install-Module -Name xActiveDirectory, `
                     xNetworking, `
                     xDnsServer, `
                     xPendingReboot, `
                     xDHCPServer, `
                     xPSDesiredStateConfiguration

#endregion Open & Edit node config TestConfig.ps1

#region Add admin creds to Azure Automation

Add-AzureAccount

New-AzureAutomationAccount -Name $AutomAccountName -Location $location

$user = "dupsug.com\Administrator"

$pw = ConvertTo-SecureString "P@ssW0rd" -AsPlainText -Force

$cred = New-Object –TypeName System.Management.Automation.PSCredential `
                   –ArgumentList $user, $pw

New-AzureAutomationCredential -AutomationAccountName $AutomAccountName `
                              -Name "Local domain admin" `
                              -Value $cred

#endregion Add admin creds to Azure Automation

#region Add modules to Azure Automation modules store

# Make sure DSC Resources/modules are in the online modules store

# Unfortunately, only available on the portal :(

# xActiveDirectory
# xNetworking
# xDnsServer
# xPendingReboot
# xDHCPServer
# xPSDesiredStateConfiguration

#endregion Add modules to Azure Automation modules store

#region upload config

Login-AzureRmAccount

Import-AzureRmAutomationDscConfiguration -SourcePath "C:\Users\SvenvanRijen\OneDrive\DuPSUG 10\DuPSUG_domain.ps1" `
                                         -Published `
                                         -ResourceGroupName $resourcegroupname `
                                         -AutomationAccountName $AutomAccountName `
                                         -Force

#endregion

#region compile config

$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = "*"             
            DomainName = "dupsug.com"             
            RetryCount = 20              
            RetryIntervalSec = 30
            ConfigurationMode = 'ApplyAndAutoCorrect'            
            PsDscAllowPlainTextPassword = $true
          }

        @{             
        Nodename = "DC01"             
        Role = "Primary DC"             
        DomainName = "dupsug.com"             
        RetryCount = 20              
        RetryIntervalSec = 30            
        PsDscAllowPlainTextPassword = $true
        PsDscAllowDomainUser = $true        
       }
     )
}

Start-AzureRmAutomationDscCompilationJob -ResourceGroupName $resourcegroupname `
                                         -AutomationAccountName $AutomAccountName `
                                         -ConfigurationName "DuPSUG_domain" `
                                         -ConfigurationData $ConfigData

#endregion compile config

#region Get Job status

Get-AzureRmAutomationJob -Id <fill me in> `
                         -ResourceGroupName $resourcegroupname `
                         -AutomationAccountName $AutomAccountName

#endregion Get Job status

#region Get DSC Node Configs

Get-AzureRmAutomationDscNodeConfiguration -ResourceGroupName $resourcegroupname `
                                      -AutomationAccountName $AutomAccountName

#endregion Get DSC Node Configs

#region Install New-LabEnvironment

Install-Module NewLabEnvironment

#endregion Install New-LabEnvironment

#region Open New-LabVM module

psEdit "C:\Users\SvenvanRijen\Documents\WindowsPowerShell\Modules\NewLabEnvironment\New-LabVM.psm1"

#endregion Open New-LabVM module

#region Create NATSwitch

New-NATSwitch -Name dupsug `
              -IPAddress 10.0.1.1 `
              -PrefixLength 24 `
              -NATName dupsug `
              -Verbose

#endregion Create NATSwitch

#region Create DC01

New-LabVM -VMName DC01 `
          -VMIP 10.0.1.100 `
          -GWIP 10.0.1.1 `
          -diskpath "C:\vhdx\" `
          -ParentDisk "C:\vhdx\W2K16_Template.vhdx" `
          -VMSwitch dupsug `
          -DNSIP 8.8.8.8 `
          -DSC $true `
          -DSCPullConfig "C:\users\SvenvanRijen\OneDrive\DuPSUG 10\DuPSUGDSCPullConfig.ps1" `
          -NestedVirt $false `
          -Verbose

#endregion Create DC01

#region Logon to DC01

#password: P@ssW0rd

#endregion Logon to DC01