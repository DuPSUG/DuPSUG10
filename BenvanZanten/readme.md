
After the demo given by Ralph Eckhard and Sven van Rijen  about how to build your home-lab with virtual machines and  DSC to configure (Domain Controller) Roles & features on your machines: 
https://github.com/DuPSUG/DuPSUG10/tree/master/RalphEckhardSvenvanRijen

I showed how I use PowerShell scripts to install & Configure a fully functional AD Domain with the following features:

* Use data files (XML, JSON) to enhance your scripting solution
  * If deploying your 'Infrastructure as Code', you also need 'Infrastructure as Data' to describe your infrastructure
  * Your code needs to be checked (and preferably signed with a digital certificate) and thus shouldn't change for each environment
  * Therefore your code should not contain any local data (no domain names, server names, IP addresses, passwords etc)
* an Active Directory forest can be seen as a hierarchy:  Forest, Domains, OU structure. This can easily be described in an XML file since it is also hierarchical.
* use XML elements and attributes to further describe your data
  * use [Powershell parameter splatting](https://blogs.technet.microsoft.com/heyscriptingguy/2010/10/18/use-splatting-to-simplify-your-powershell-scripts) to dynamically create your parameters.
  * created a function to convert an XML element to a hash table
  * use the created hash table to splat the powershell parameters.
  * this greatly reduces the number of lines you need in code, not every parameter needs to be programmed. Your XML drives the powershell commands
  * downside is: if creating junk XML files, the parameters will fail / posibilities for 'code injection'.

The current code has the following features:
* Install Domain Controller roles and features
* Install Active Directory, the script automatically determines whether to create a new forest, an additional domain in existing forest, or an additional DC in existing domain, by comparing the local computername to the Forest Schema master (if match: new forest), (sub)domain PDC (if match: new domain in existing forst) else: additional DC in existing domain
* Configure DC
* Sites:
  * Create sites
  * create subnets
  * create site links
  * (assign DCs to sites)
* DNS
  * configure DNS
  * configure DNS zones
  * configure DNS forwarding
* Domain Contents:
  * create OU structure
  * create users in currect OU
  * create groups
  * assign users to groups
  * create GPO (some work to be done).

Etc etc. resulting in potentially a production - ready Active Directory forest.

I'll add an example ADStructure.xml   and an example Install Domain Controller to this folder, just to tease you. The rest of the project is placed in a separate GitHub repository: https://github.com/BZanten/DeployADDS
Please feel free to comment and work on that !

Regards, 
Ben van Zanten
