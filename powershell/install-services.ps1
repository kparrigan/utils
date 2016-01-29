function Install-Services ([string] $fileName) {
    "Installing services from '$fileName'"

    #read list of services to install from file.
    $services = @{}
    $contents = [io.file]::ReadAllLines($fileName)

    foreach ($line in $contents) {
        $lineSplit = $line.split(",")
        $services.Add($lineSplit[0], $lineSplit[1])
    }

    #iterate through services hash table and install each service
    foreach ($serviceName in $services.Keys) {
	    $servicePath = $services.Item($serviceName)
	    "Processing service '$key' from '$servicePath'"

	    #check to see if service exists, and stop/remove it if so.
	    $service = Get-WmiObject -Class Win32_Service -Filter "Name='$serviceName'"

	    if ($service) 
	    {
	      "'$serviceName' already exists. Removing it now."
	      Stop-Service $serviceName
	      $service.Delete()
	    }

	    "Installing service '$serviceName'"
	    New-Service -Name $serviceName -BinaryPathName $servicePath
	    Start-Service $serviceName
    }
}