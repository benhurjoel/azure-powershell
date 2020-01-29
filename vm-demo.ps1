ssh-keygen -t rsa -b 2048
New-AzResourceGroup -Name "demo-rg-01" -Location "SouthEastAsia"
# Create a subnet configuration
$subnetConfig = New-AzVirtualNetworkSubnetConfig  -Name "demo-subnet-01"  -AddressPrefix 10.1.1.0/24

# Create a virtual network
$vnet = New-AzVirtualNetwork `
  -ResourceGroupName "demo-rg-01" `
  -Location "SouthEastAsia"`
  -Name "demo-vnet-01" `
  -AddressPrefix 10.1.0.0/16 `
  -Subnet $subnetConfig

# Create a public IP address and specify a DNS name
$pip = New-AzPublicIpAddress `
  -ResourceGroupName "demo-rg-01"  `
  -Location "SouthEastAsia" `
  -AllocationMethod Static `
  -IdleTimeoutInMinutes 4 `
  -Name "demo-pip-01"


  # Create a virtual network card and associate with public IP address and NSG
$nic = New-AzNetworkInterface `
-Name "demo-nic-01" `
-ResourceGroupName "demo-rg-01" `
-Location "SouthEastAsia" `
-SubnetId $vnet.Subnets[0].Id `
-PublicIpAddressId $pip.Id `
-NetworkSecurityGroupId $nsg.Id


# Define a credential object
$securePassword = ConvertTo-SecureString ' ' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("ben", $securePassword)

# Create a virtual machine configuration
$vmConfig = New-AzVMConfig `
  -VMName "demo-vm-01" `
  -VMSize "Standard_D1" | `
Set-AzVMOperatingSystem `
  -Linux `
  -ComputerName "demo-vm" `
  -Credential $cred `
  -DisablePasswordAuthentication | `
Set-AzVMSourceImage `
  -PublisherName "Canonical" `
  -Offer "UbuntuServer" `
  -Skus "16.04-LTS" `
  -Version "latest" | `
Add-AzVMNetworkInterface `
  -Id $nic.Id

# Configure the SSH key
$sshPublicKey = cat ~/.ssh/id_rsa.pub
Add-AzVMSshPublicKey `
  -VM $vmconfig `
  -KeyData $sshPublicKey `
  -Path "/home/ben/.ssh/authorized_keys"

  New-AzVM `
  -ResourceGroupName "demo-rg-01" `
  -Location southeastasia -VM $vmConfig

  Get-AzPublicIpAddress -ResourceGroupName "demo-rg-01" | Select-Object "IpAddress" > ipaddr.txt

  
