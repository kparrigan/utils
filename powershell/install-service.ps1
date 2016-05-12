function Install-Service 
{
    param 
    (
        [parameter(Mandatory=$true)]            
        [ValidateNotNullOrEmpty()]  
        [string] $executablePath,

        [parameter(Mandatory=$true)]            
        [ValidateNotNullOrEmpty()]  
        [string] $serviceName,

        [parameter(Mandatory=$false)]            
        [string] $userName,

        [parameter(Mandatory=$false)]            
        [string] $password,

        [Switch]
        $StartService
    ) 

    process    
    {
     
        try
        {   
            if (!(Test-Path -Path $executablePath))
            {
                "'$executablePath' does not exist."
            }

            $credentials = $null

            #check to see if service exists, and stop/remove it if so.
	        $service = Get-WmiObject -Class Win32_Service -Filter "Name='$serviceName'"

	        if ($service) 
	        {
	          "'$serviceName' already exists. Removing it now..."
	          Stop-Service $serviceName
	          $service.Delete()
	        }

            if ((!([string]::IsNullOrEmpty($userName)) -and (!([string]::IsNullOrEmpty($password)))))
            {
                $secureString = convertto-securestring -String $password -AsPlainText -Force 
                $credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName, $secureString
            }

            "Installing '$serviceName'..."
            New-Service -BinaryPathName $executablePath -Name $serviceName -DisplayName $serviceName -StartupType Automatic 

            if ($StartService)
            {
                "Starting '$serviceName'..."
                Start-Service $serviceName
            }
        }
        catch [Exception]
        {
            "Unexpected error while installing service ' $serviceName'..."
            $_.Exception.Message
        }
    }
}